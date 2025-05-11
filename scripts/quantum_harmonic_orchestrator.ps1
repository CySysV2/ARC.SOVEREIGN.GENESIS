# Quantum Harmonic Orchestrator
# Generated: 2025-04-28T11:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumHarmonicOrchestrator"

# Configuration paths
$configPath = "C:\FABRICA\quantum_sync_mode.json"
$logPath = "C:\FABRICA\logs\quantum_sync_mode_log.txt"

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logPath -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Function to update metrics
function Update-Metrics {
    param (
        [string]$ServiceName,
        [string]$Status,
        [bool]$IsSynchronized
    )
    
    try {
        $json = Get-Content $configPath -Raw
        $metrics = $json | ConvertFrom-Json
        
        if (-not $metrics.Services) {
            $metrics.Services = @{}
        }
        
        $metrics.Services.$ServiceName.Status = $Status
        $metrics.Services.$ServiceName.LastUpdate = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        $metrics.Services.$ServiceName.IsSynchronized = $IsSynchronized
        
        $json = $metrics | ConvertTo-Json -Depth 10
        Set-Content -Path $configPath -Value $json
    }
    catch {
        Write-Log "Failed to update metrics: $_" "ERROR"
    }
}

# Function to check service health
function Test-ServiceHealth {
    param (
        [string]$ServiceName
    )
    
    $process = Get-Process -Name $ServiceName -ErrorAction SilentlyContinue
    if ($process) {
        return $true
    }
    return $false
}

# Function to restart service
function Restart-Service {
    param (
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = "powershell"
        $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ServicePath`""
        $startInfo.Verb = "RunAs"
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $startInfo.UseShellExecute = $true
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        
        if ($process) {
            Write-Log "Restarted service $ServiceName" "INFO"
            return $true
        }
        else {
            throw "Failed to start process"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Failed to restart service ${ServiceName}: ${errorMessage}" "ERROR"
        return $false
    }
}

# Main orchestration loop
Write-Log "Starting Quantum Harmonic Orchestrator" "INFO"

while ($true) {
    try {
        $json = Get-Content $configPath -Raw
        $config = $json | ConvertFrom-Json
        
        foreach ($serviceName in $config.Services.PSObject.Properties.Name) {
            $service = $config.Services.$serviceName
            
            if ($service.Name -and $service.Path) {
                # Check service health
                $isHealthy = Test-ServiceHealth -ServiceName $service.Name
                
                if (-not $isHealthy) {
                    Write-Log "Service $($service.Name) is not running, attempting restart" "WARN"
                    $restartSuccess = Restart-Service -ServiceName $service.Name -ServicePath $service.Path
                    
                    if ($restartSuccess) {
                        Update-Metrics -ServiceName $service.Name -Status "Running" -IsSynchronized $false
                    }
                    else {
                        Update-Metrics -ServiceName $service.Name -Status "Error" -IsSynchronized $false
                    }
                }
                else {
                    Update-Metrics -ServiceName $service.Name -Status "Running" -IsSynchronized $true
                }
            }
        }
    }
    catch {
        Write-Log "Error in orchestration loop: $_" "ERROR"
    }
    
    Start-Sleep -Seconds 30
} 