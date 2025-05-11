# Quantum Sync Initialization
# Generated: 2025-04-29T07:10:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumSyncInitializer"

# Configuration paths
$configPath = "C:\FABRICA\quantum_sync_mode.json"
$logPath = "C:\FABRICA\logs\quantum_sync_mode_log.txt"

# Ensure log directory exists
$logDir = Split-Path -Parent $logPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    try {
        # Use a mutex to prevent concurrent access
        $mutex = New-Object System.Threading.Mutex($false, "QuantumSyncLogMutex")
        $mutex.WaitOne() | Out-Null
        
        try {
            Add-Content -Path $logPath -Value $logMessage -ErrorAction Stop
        }
        finally {
            $mutex.ReleaseMutex()
        }
    }
    catch {
        # If mutex fails, try direct write
        try {
            Add-Content -Path $logPath -Value $logMessage -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to write to log: $_" -ForegroundColor Red
        }
    }
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Function to start service
function Start-QuantumService {
    param (
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = "powershell"
        $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ServicePath`" -ServiceName `"$ServiceName`""
        $startInfo.Verb = "RunAs"
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $startInfo.UseShellExecute = $true
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        
        if ($process) {
            Write-Log "Started service $ServiceName in background"
            return $true
        }
        else {
            throw "Failed to start process"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Failed to start service ${ServiceName}: ${errorMessage}" "ERROR"
        return $false
    }
}

# Initialize configuration
try {
    $config = @{
        Alerts     = @()
        Services   = @{
            QuantumHarmonicOrchestrator = @{
                Name           = "QuantumHarmonicOrchestrator"
                Path           = "C:\FABRICA\scripts\quantum_harmonic_orchestrator.ps1"
                IsSynchronized = $false
                Status         = "Initialized"
                Performance    = @{
                    CPU     = 0
                    Memory  = 0
                    Threads = 0
                }
                LastUpdate     = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicMonitor      = @{
                Name           = "QuantumHarmonicMonitor"
                Path           = "C:\FABRICA\scripts\quantum_harmonic_monitor.ps1"
                IsSynchronized = $false
                Status         = "Initialized"
                Performance    = @{
                    CPU     = 0
                    Memory  = 0
                    Threads = 0
                }
                LastUpdate     = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicSync         = @{
                Name           = "QuantumHarmonicSync"
                Path           = "C:\FABRICA\scripts\quantum_harmonic_sync.ps1"
                IsSynchronized = $false
                Status         = "Initialized"
                Performance    = @{
                    CPU     = 0
                    Memory  = 0
                    Threads = 0
                }
                LastUpdate     = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicVerifier     = @{
                Name           = "QuantumHarmonicVerifier"
                Path           = "C:\FABRICA\scripts\quantum_harmonic_verifier.ps1"
                IsSynchronized = $false
                Status         = "Initialized"
                Performance    = @{
                    CPU     = 0
                    Memory  = 0
                    Threads = 0
                }
                LastUpdate     = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicValidator    = @{
                Name           = "QuantumHarmonicValidator"
                Path           = "C:\FABRICA\scripts\quantum_harmonic_validator.ps1"
                IsSynchronized = $false
                Status         = "Initialized"
                Performance    = @{
                    CPU     = 0
                    Memory  = 0
                    Threads = 0
                }
                LastUpdate     = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
        StartTime  = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        SyncStatus = @{}
    }
    
    $json = $config | ConvertTo-Json -Depth 10
    Set-Content -Path $configPath -Value $json
    
    # Start services
    foreach ($serviceName in $config.Services.Keys) {
        $service = $config.Services.$serviceName
        if ($service.Name -and $service.Path) {
            Start-QuantumService -ServiceName $service.Name -ServicePath $service.Path
            Start-Sleep -Seconds 2
        }
    }
    
    Write-Log "Quantum Sync Initialization Complete"
    Write-Host "Quantum Sync initialization complete. Configuration saved to:"
    Write-Host "Logs: $logPath"
    Write-Host "Metrics: $configPath"
}
catch {
    Write-Log "Initialization failed: $_" "ERROR"
    exit 1
} 