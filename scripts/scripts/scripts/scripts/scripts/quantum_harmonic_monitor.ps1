# Quantum Harmonic Monitor
# Generated: 2025-04-29T09:45:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumHarmonicMonitor"

# Import required modules
. "C:\FABRICA\scripts\quantum_harmonic_sync.ps1"

# Quantum harmonic monitoring configuration
$monitorConfig = @{
    CheckInterval  = 30  # seconds
    AlertThreshold = 0.8
    MaxAlerts      = 3
    LogPath        = "C:\FABRICA\logs\harmonic_monitor.log"
}

# Function to log messages with proper file handling
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        
        # Ensure log directory exists
        $logDir = Split-Path -Parent $monitorConfig.LogPath
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        # Use a mutex to prevent file access conflicts
        $mutex = New-Object System.Threading.Mutex($false, "QuantumHarmonicMonitorLogMutex")
        try {
            $mutex.WaitOne() | Out-Null
            Add-Content -Path $monitorConfig.LogPath -Value $logMessage -ErrorAction Stop
        }
        finally {
            $mutex.ReleaseMutex()
        }
        
        # Also output to console
        Write-Host $logMessage
    }
    catch {
        Write-Host "Failed to write to log: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to check service health
function Test-ServiceHealth {
    param (
        [string]$ServiceName
    )
    
    try {
        # Check if service is running
        $process = Get-Process | Where-Object { $_.ProcessName -like "*${ServiceName}*" }
        
        if (-not $process) {
            Write-Log "${ServiceName} is not running" "ERROR"
            return $false
        }
        
        # Check harmonic alignment
        $isAligned = Test-HarmonicAlignment -ServiceName $ServiceName
        
        if (-not $isAligned) {
            Write-Log "${ServiceName} is out of harmonic alignment" "WARN"
            return $false
        }
        
        # Check CPU and memory usage
        $cpuUsage = $process.CPU
        $memoryUsage = $process.WorkingSet64 / 1MB
        
        if ($cpuUsage -gt $monitorConfig.AlertThreshold * 100) {
            Write-Log "${ServiceName} CPU usage is high: ${cpuUsage}%" "WARN"
            return $false
        }
        
        if ($memoryUsage -gt $monitorConfig.AlertThreshold * 1000) {
            Write-Log "${ServiceName} memory usage is high: ${memoryUsage}MB" "WARN"
            return $false
        }
        
        Write-Log "${ServiceName} is healthy (CPU: ${cpuUsage}%, Memory: ${memoryUsage}MB)"
        return $true
    }
    catch {
        Write-Log "Error checking ${ServiceName} health: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to monitor harmonic services
function Monitor-HarmonicServices {
    param (
        [hashtable]$Services
    )
    
    try {
        Write-Log "Starting quantum harmonic monitoring"
        
        $alertCount = @{}
        
        foreach ($service in $Services.QuantumServices.GetEnumerator()) {
            $serviceName = $service.Value.Name
            
            if (-not $alertCount.ContainsKey($serviceName)) {
                $alertCount[$serviceName] = 0
            }
            
            $isHealthy = Test-ServiceHealth -ServiceName $serviceName
            
            if (-not $isHealthy) {
                $alertCount[$serviceName]++
                
                if ($alertCount[$serviceName] -ge $monitorConfig.MaxAlerts) {
                    Write-Log "Critical alert: ${ServiceName} has failed $($monitorConfig.MaxAlerts) health checks" "ERROR"
                    
                    # Attempt to restart the service
                    $success = Initialize-QuantumServices -ServiceName $serviceName -ServicePath $service.Value.Path
                    
                    if ($success) {
                        Write-Log "Successfully restarted ${ServiceName}"
                        $alertCount[$serviceName] = 0
                    }
                    else {
                        Write-Log "Failed to restart ${ServiceName}" "ERROR"
                    }
                }
            }
            else {
                $alertCount[$serviceName] = 0
            }
        }
        
        Write-Log "Quantum harmonic monitoring complete"
    }
    catch {
        Write-Log "Quantum harmonic monitoring failed: $($_.Exception.Message)" "ERROR"
    }
}

# Main monitoring process
try {
    Write-Log "Starting quantum harmonic monitoring process"
    
    # Get current system state
    $systemState = Get-SystemServices
    
    # Start monitoring loop
    while ($true) {
        Monitor-HarmonicServices -Services $systemState
        Start-Sleep -Seconds $monitorConfig.CheckInterval
    }
}
catch {
    Write-Log "Quantum harmonic monitoring process failed: $($_.Exception.Message)" "ERROR"
    exit 1
} 