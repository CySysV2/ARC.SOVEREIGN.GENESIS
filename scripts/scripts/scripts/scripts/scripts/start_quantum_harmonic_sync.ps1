# Quantum Harmonic Sync Starter
# Generated: 2025-04-29T18:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumHarmonicSyncStarter"

# Configuration paths
$configPath = "C:\FABRICA\quantum_sync_mode.json"
$logPath = "C:\FABRICA\logs\quantum_harmonic_sync.log"
$executorPath = "C:\FABRICA\scripts\quantum_harmonic_sync_executor.ps1"

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $logPath -Value $logMessage -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to write to log: $_" -ForegroundColor Red
    }
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Function to verify quantum harmonic sync configuration
function Test-QuantumHarmonicSyncConfig {
    try {
        if (-not (Test-Path $configPath)) {
            Write-Log "Quantum harmonic sync configuration not found" "ERROR"
            return $false
        }
        
        $config = Get-Content -Path $configPath | ConvertFrom-Json -AsHashtable
        
        # Verify required services
        $requiredServices = @(
            "QuantumHarmonicOrchestrator",
            "QuantumHarmonicSync",
            "QuantumHarmonicMonitor",
            "QuantumHarmonicValidator",
            "QuantumHarmonicVerifier"
        )
        
        foreach ($service in $requiredServices) {
            if (-not $config.Services.ContainsKey($service)) {
                Write-Log "Missing required service: ${service}" "ERROR"
                return $false
            }
        }
        
        Write-Log "Quantum harmonic sync configuration verified successfully"
        return $true
    }
    catch {
        Write-Log "Failed to verify quantum harmonic sync configuration: $_" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "Starting quantum harmonic sync mode initialization"
    
    # Verify configuration
    $configValid = Test-QuantumHarmonicSyncConfig
    if (-not $configValid) {
        Write-Log "Invalid quantum harmonic sync configuration" "ERROR"
        exit 1
    }
    
    # Start quantum harmonic sync executor with elevated privileges
    Write-Log "Starting quantum harmonic sync executor"
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"${executorPath}`"" -Verb RunAs
    
    # Wait for executor to initialize
    Start-Sleep -Seconds 10
    
    # Verify executor is running
    $executorProcess = Get-Process -Name "powershell" | Where-Object { $_.MainWindowTitle -eq "QuantumHarmonicSyncExecutor" }
    if ($executorProcess) {
        Write-Log "Quantum harmonic sync executor started successfully (PID: $($executorProcess.Id))"
    }
    else {
        Write-Log "Failed to verify quantum harmonic sync executor is running" "ERROR"
        exit 1
    }
    
    Write-Log "Quantum harmonic sync mode started successfully"
    Write-Host "`nQuantum Harmonic Sync Mode is now active" -ForegroundColor Green
    Write-Host "Logs: ${logPath}" -ForegroundColor Cyan
    Write-Host "Metrics: ${configPath}" -ForegroundColor Cyan
}
catch {
    Write-Log "Failed to start quantum harmonic sync mode: $_" "ERROR"
    exit 1
} 