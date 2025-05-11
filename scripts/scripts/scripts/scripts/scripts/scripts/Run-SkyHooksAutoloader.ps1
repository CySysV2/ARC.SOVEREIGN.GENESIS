# Run-SkyHooksAutoloader.ps1
# Auto-inject Windsurf enhancements & sync Codex memory streams

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Configuration
$CONFIG = @{
    MAINSTACK = "C:\DFT_GCC_TRIAD_MAINSTACK"
    CODEX = "C:\DFT_GCC_TRIAD_MAINSTACK\Codex"
    SKYHOOKS = "C:\SBS_MIRROR\SkyHooks"
    NODE0_MOUNT = "C:\DFT_GCC_TRIAD_MAINSTACK\Node0_mount"
    MEMORY_SYNC_INTERVAL = 300  # 5 minutes
    ENHANCEMENT_CHECK_INTERVAL = 600  # 10 minutes
    LOG_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\Logs\skyhooks_autoloader.log"
    SYNC_PORTS = @{
        NODE0 = 19000
        QUANTUM = 18080
        MEMORY = 17500
    }
}

# Ensure required directories exist
@($CONFIG.MAINSTACK, $CONFIG.CODEX, $CONFIG.SKYHOOKS, $CONFIG.NODE0_MOUNT) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Force -Path $_ | Out-Null
    }
}

function Write-AutoloaderLog {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffffK"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage
    Add-Content -Path $CONFIG.LOG_PATH -Value $logMessage
}

function Test-Node0Connection {
    try {
        $result = Test-NetConnection -ComputerName localhost -Port $CONFIG.SYNC_PORTS.NODE0 -WarningAction SilentlyContinue
        return $result.TcpTestSucceeded
    } catch {
        Write-AutoloaderLog "Node0 connection test failed: $_" "ERROR"
        return $false
    }
}

function Sync-CodexMemory {
    try {
        Write-AutoloaderLog "Starting Codex memory synchronization" "INFO"
        
        # Verify Node0 connection
        if (-not (Test-Node0Connection)) {
            Write-AutoloaderLog "Node0 not accessible, using fallback sync" "WARNING"
            return $false
        }

        # Prepare memory sync manifest
        $syncManifest = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffffK"
            source = "SBS-11411"
            memoryPaths = @(
                "$($CONFIG.CODEX)\Memory\infinity_manifest.json",
                "$($CONFIG.CODEX)\Memory\navigator_tensor_sync.json",
                "$($CONFIG.CODEX)\Memory\quantum_state.json"
            )
        } | ConvertTo-Json

        Set-Content -Path "$($CONFIG.SKYHOOKS)\memory_sync.manifest" -Value $syncManifest

        # Trigger memory sync
        $response = Invoke-WebRequest -Uri "http://localhost:$($CONFIG.SYNC_PORTS.MEMORY)/sync" -Method POST -Body $syncManifest -ContentType "application/json"
        
        if ($response.StatusCode -eq 200) {
            Write-AutoloaderLog "Memory sync successful" "SUCCESS"
            return $true
        }
        
        Write-AutoloaderLog "Memory sync failed: $($response.StatusCode)" "ERROR"
        return $false
    } catch {
        Write-AutoloaderLog "Memory sync error: $_" "ERROR"
        return $false
    }
}

function Get-WindsurfEnhancements {
    try {
        Write-AutoloaderLog "Checking for Windsurf enhancements" "INFO"
        
        # Query Node0 for available enhancements
        $enhancementsUrl = "http://localhost:$($CONFIG.SYNC_PORTS.NODE0)/enhancements"
        $response = Invoke-WebRequest -Uri $enhancementsUrl -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            $enhancements = $response.Content | ConvertFrom-Json
            Write-AutoloaderLog "Found $($enhancements.Count) enhancement(s)" "INFO"
            return $enhancements
        }
        
        Write-AutoloaderLog "No enhancements found" "WARNING"
        return @()
    } catch {
        Write-AutoloaderLog "Enhancement check failed: $_" "ERROR"
        return @()
    }
}

function Install-WindsurfEnhancement {
    param($Enhancement)
    try {
        Write-AutoloaderLog "Installing enhancement: $($Enhancement.name)" "INFO"
        
        # Download enhancement package
        $packagePath = Join-Path $CONFIG.SKYHOOKS "enhancements\$($Enhancement.id).zip"
        Invoke-WebRequest -Uri $Enhancement.packageUrl -OutFile $packagePath
        
        # Verify package integrity
        $hash = Get-FileHash $packagePath -Algorithm SHA256
        if ($hash.Hash -ne $Enhancement.sha256) {
            Write-AutoloaderLog "Enhancement package integrity check failed" "ERROR"
            return $false
        }
        
        # Extract and install
        Expand-Archive -Path $packagePath -DestinationPath "$($CONFIG.MAINSTACK)\Enhancements\$($Enhancement.id)" -Force
        
        # Run enhancement installer if present
        $installerPath = "$($CONFIG.MAINSTACK)\Enhancements\$($Enhancement.id)\install.ps1"
        if (Test-Path $installerPath) {
            & $installerPath
        }
        
        Write-AutoloaderLog "Enhancement $($Enhancement.name) installed successfully" "SUCCESS"
        return $true
    } catch {
        Write-AutoloaderLog "Enhancement installation failed: $_" "ERROR"
        return $false
    }
}

# Main autoloader loop
Write-AutoloaderLog "Starting SkyHooks Autoloader" "INFO"

while ($true) {
    try {
        # Sync Codex memory streams
        Sync-CodexMemory
        
        # Check and install Windsurf enhancements
        $enhancements = Get-WindsurfEnhancements
        foreach ($enhancement in $enhancements) {
            if (-not $enhancement.installed) {
                Install-WindsurfEnhancement $enhancement
            }
        }
        
        # Alternate between memory sync and enhancement checks
        Start-Sleep -Seconds $CONFIG.MEMORY_SYNC_INTERVAL
        
        # Signal active status
        $status = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffffK"
            status = "ACTIVE"
            lastSync = (Get-Date).AddSeconds(-$CONFIG.MEMORY_SYNC_INTERVAL)
            nextSync = (Get-Date).AddSeconds($CONFIG.MEMORY_SYNC_INTERVAL)
            enhancementsInstalled = $enhancements.Count
        } | ConvertTo-Json
        
        Set-Content -Path "$($CONFIG.SKYHOOKS)\autoloader_status.json" -Value $status
        
    } catch {
        Write-AutoloaderLog "Autoloader error: $_" "ERROR"
        Start-Sleep -Seconds 30  # Brief pause on error
    }
}
