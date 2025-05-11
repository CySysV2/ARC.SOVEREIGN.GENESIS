# Quantum Harmonic Validator
# Generated: 2025-04-28T11:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumHarmonicValidator"

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

# Function to validate service integrity
function Test-ServiceIntegrity {
    param (
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    $checks = @{
        FileExists     = $false
        FileHash       = $null
        ProcessRunning = $false
        ProcessHash    = $null
    }
    
    # Check if service file exists
    if (Test-Path $ServicePath) {
        $checks.FileExists = $true
        
        # Calculate file hash
        $checks.FileHash = (Get-FileHash -Path $ServicePath -Algorithm SHA256).Hash
    }
    
    # Check if process is running
    $process = Get-Process -Name $ServiceName -ErrorAction SilentlyContinue
    if ($process) {
        $checks.ProcessRunning = $true
        
        # Get process file path
        $processPath = $process.Path
        if (Test-Path $processPath) {
            $checks.ProcessHash = (Get-FileHash -Path $processPath -Algorithm SHA256).Hash
        }
    }
    
    return $checks
}

# Function to update validation metrics
function Update-ValidationMetrics {
    param (
        [string]$ServiceName,
        [hashtable]$Checks
    )
    
    $metrics = Get-Content $configPath | ConvertFrom-Json -AsHashtable
    $metrics.Services[$ServiceName].Validation = @{
        FileExists     = $Checks.FileExists
        FileHash       = $Checks.FileHash
        ProcessRunning = $Checks.ProcessRunning
        ProcessHash    = $Checks.ProcessHash
        LastValidation = Get-Date
    }
    $metrics | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath
}

# Main validation loop
Write-Log "Starting Quantum Harmonic Validator" "INFO"

while ($true) {
    $config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
    
    foreach ($service in $config.Services) {
        $name = $service.Name
        $path = $service.Path
        
        # Validate service integrity
        $checks = Test-ServiceIntegrity -ServiceName $name -ServicePath $path
        
        # Log validation results
        if (-not $checks.FileExists) {
            Write-Log "Service file not found for $name" "ERROR"
        }
        
        if (-not $checks.ProcessRunning) {
            Write-Log "Process not running for $name" "ERROR"
        }
        
        if ($checks.FileHash -and $checks.ProcessHash -and $checks.FileHash -ne $checks.ProcessHash) {
            Write-Log "Hash mismatch detected for $name" "ERROR"
        }
        
        # Update metrics
        Update-ValidationMetrics -ServiceName $name -Checks $checks
    }
    
    Start-Sleep -Seconds 45
} 