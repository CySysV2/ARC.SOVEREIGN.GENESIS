# Quantum Harmonic Verifier
# Generated: 2025-04-28T11:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumHarmonicVerifier"

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

# Function to verify service synchronization
function Test-ServiceSync {
    param (
        [string]$ServiceName
    )
    
    $sourcePath = "C:\FABRICA\quantum_source\${ServiceName}_source.txt"
    $targetPath = "C:\FABRICA\quantum_target\${ServiceName}_target.txt"
    
    $checks = @{
        SourceExists = $false
        TargetExists = $false
        ContentMatch = $false
        LastSync     = $null
    }
    
    # Check if source file exists
    if (Test-Path $sourcePath) {
        $checks.SourceExists = $true
        $sourceContent = Get-Content $sourcePath -Raw
        $checks.LastSync = (Get-Item $sourcePath).LastWriteTime
    }
    
    # Check if target file exists
    if (Test-Path $targetPath) {
        $checks.TargetExists = $true
        $targetContent = Get-Content $targetPath -Raw
    }
    
    # Compare content if both files exist
    if ($checks.SourceExists -and $checks.TargetExists) {
        $checks.ContentMatch = ($sourceContent -eq $targetContent)
    }
    
    return $checks
}

# Function to update sync metrics
function Update-SyncMetrics {
    param (
        [string]$ServiceName,
        [hashtable]$Checks
    )
    
    $metrics = Get-Content $configPath | ConvertFrom-Json -AsHashtable
    $metrics.Services[$ServiceName].Sync = @{
        SourceExists     = $Checks.SourceExists
        TargetExists     = $Checks.TargetExists
        ContentMatch     = $Checks.ContentMatch
        LastSync         = $Checks.LastSync
        LastVerification = Get-Date
    }
    $metrics | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath
}

# Main verification loop
Write-Log "Starting Quantum Harmonic Verifier" "INFO"

while ($true) {
    $config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
    
    foreach ($service in $config.Services) {
        $name = $service.Name
        
        # Verify service synchronization
        $checks = Test-ServiceSync -ServiceName $name
        
        # Log verification results
        if (-not $checks.SourceExists) {
            Write-Log "Source file not found for $name" "ERROR"
        }
        
        if (-not $checks.TargetExists) {
            Write-Log "Target file not found for $name" "ERROR"
        }
        
        if ($checks.SourceExists -and $checks.TargetExists -and -not $checks.ContentMatch) {
            Write-Log "Content mismatch detected for $name" "ERROR"
        }
        
        # Update metrics
        Update-SyncMetrics -ServiceName $name -Checks $checks
    }
    
    Start-Sleep -Seconds 90
} 