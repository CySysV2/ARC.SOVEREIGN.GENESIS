# Quantum Service Manager
# Generated: 2025-04-29T18:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumServiceManager"

# Configuration paths
$configPath = "C:\FABRICA\quantum_sync_mode.json"
$logPath = "C:\FABRICA\logs\quantum_service_manager.log"
$metricsPath = "C:\FABRICA\quantum_service_metrics.json"

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
        $mutex = New-Object System.Threading.Mutex($false, "QuantumServiceLogMutex")
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

# Function to initialize service configuration
function Initialize-ServiceConfig {
    $config = @{
        Services   = @{
            QuantumHarmonicOrchestrator = @{
                Name         = "QuantumHarmonicOrchestrator"
                Path         = "C:\FABRICA\scripts\quantum_harmonic_orchestrator.ps1"
                Priority     = 1
                Dependencies = @()
                Status       = "Initialized"
                LastUpdate   = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicMonitor      = @{
                Name         = "QuantumHarmonicMonitor"
                Path         = "C:\FABRICA\scripts\quantum_harmonic_monitor.ps1"
                Priority     = 2
                Dependencies = @("QuantumHarmonicOrchestrator")
                Status       = "Initialized"
                LastUpdate   = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicSync         = @{
                Name         = "QuantumHarmonicSync"
                Path         = "C:\FABRICA\scripts\quantum_harmonic_sync.ps1"
                Priority     = 3
                Dependencies = @("QuantumHarmonicOrchestrator", "QuantumHarmonicMonitor")
                Status       = "Initialized"
                LastUpdate   = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicVerifier     = @{
                Name         = "QuantumHarmonicVerifier"
                Path         = "C:\FABRICA\scripts\quantum_harmonic_verifier.ps1"
                Priority     = 4
                Dependencies = @("QuantumHarmonicSync")
                Status       = "Initialized"
                LastUpdate   = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            QuantumHarmonicValidator    = @{
                Name         = "QuantumHarmonicValidator"
                Path         = "C:\FABRICA\scripts\quantum_harmonic_validator.ps1"
                Priority     = 5
                Dependencies = @("QuantumHarmonicVerifier")
                Status       = "Initialized"
                LastUpdate   = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
        Alerts     = @()
        StartTime  = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        SyncStatus = @{}
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath
    Write-Log "Service configuration initialized" "INFO"
}

# Function to start a quantum service
function Start-QuantumService {
    param (
        [string]$Name,
        [string]$Path
    )
    
    try {
        Write-Log "Starting service: $Name" "INFO"
        
        # Check if service is already running
        $process = Get-Process -Name $Name -ErrorAction SilentlyContinue
        if ($process) {
            Write-Log "Service $Name is already running" "WARN"
            return $true
        }
        
        # Start the service
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = "powershell.exe"
        $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Path`""
        $startInfo.UseShellExecute = $true
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        if ($process) {
            Write-Log "Successfully started service: $Name" "INFO"
            return $true
        }
        else {
            throw "Failed to start process"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Failed to start service $Name: $errorMessage" "ERROR"
        return $false
    }
}

# Function to verify service dependencies
function Test-ServiceDependencies {
    param (
        [string]$Name
    )
    
    try {
        $service = ${config}.Services.${Name}
        if (-not $service) {
            Write-Log "Service ${Name} not found in configuration" "ERROR"
            return $false
        }
        
        foreach ($dependency in $service.Dependencies) {
            $process = Get-Process -Name $dependency -ErrorAction SilentlyContinue
            if (-not $process) {
                Write-Log "Dependency ${dependency} is not running for service ${Name}" "ERROR"
                return $false
            }
        }
        
        Write-Log "All dependencies are running for service ${Name}" "INFO"
        return $true
    }
    catch {
        Write-Log "Failed to verify dependencies for ${Name}: $_" "ERROR"
        return $false
    }
}

# Function to monitor service health
function Monitor-ServiceHealth {
    param (
        [string]$Name
    )
    
    try {
        $process = Get-Process -Name ${Name} -ErrorAction SilentlyContinue
        if (-not $process) {
            Write-Log "Service ${Name} is not running" "ERROR"
            return $false
        }
        
        # Check CPU and memory usage
        $cpuUsage = $process.CPU
        $memoryUsage = $process.WorkingSet64 / 1MB
        
        if ($cpuUsage -gt 90) {
            Write-Log "High CPU usage detected for service ${Name}: ${cpuUsage}%" "WARN"
        }
        
        if ($memoryUsage -gt 1024) {
            Write-Log "High memory usage detected for service ${Name}: ${memoryUsage} MB" "WARN"
        }
        
        return $true
    }
    catch {
        Write-Log "Failed to monitor service ${Name}: $_" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "Starting Quantum Service Manager" "INFO"
    
    # Initialize configuration
    Initialize-ServiceConfig
    
    # Start services in order of priority
    $servicesByPriority = $config.Services.GetEnumerator() | Sort-Object { $_.Value.Priority }
    
    foreach ($service in $servicesByPriority) {
        $serviceName = $service.Key
        $servicePath = $service.Value.Path
        
        # Verify dependencies
        if (-not (Test-ServiceDependencies -Name $serviceName)) {
            Write-Log "Skipping service $serviceName due to missing dependencies" "WARN"
            continue
        }
        
        # Start service
        if (Start-QuantumService -Name $serviceName -Path $servicePath) {
            # Monitor service health
            Start-Job -ScriptBlock {
                param($Name)
                while ($true) {
                    Monitor-ServiceHealth -Name $Name
                    Start-Sleep -Seconds 30
                }
            } -ArgumentList $serviceName
        }
    }
    
    Write-Log "Quantum Service Manager initialization complete" "INFO"
}
catch {
    Write-Log "Quantum Service Manager failed: $_" "ERROR"
    exit 1
} 