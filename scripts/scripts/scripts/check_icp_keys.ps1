# ICP Fabric Keys Checker
# Generated: 2025-04-29T18:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "FABRICA ICP Keys Check"

# Configuration paths
$vaultPath = "C:\FABRICA\vaults\FABRICA"
$keysPath = Join-Path $vaultPath "ICP_Fabric_Keys.json"
$logPath = "C:\FABRICA\logs\icp_keys_check.log"
$syncScriptPath = "C:\FABRICA\scripts\fabrica_sync_icp_fabrics.ps1"

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

# Main execution
try {
    Write-Log "Starting ICP Fabric Keys check"
    
    # Ensure vault directory exists
    if (-not (Test-Path $vaultPath)) {
        Write-Log "Creating vault directory: ${vaultPath}"
        New-Item -ItemType Directory -Force -Path $vaultPath | Out-Null
    }
    
    # Check for ICP Fabric Keys
    if (Test-Path $keysPath) {
        Write-Log "ICP Fabric Keys found at: ${keysPath}"
        Write-Log "Initiating synchronization process"
        
        # Start sync process with elevated privileges
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"${syncScriptPath}`"" -Verb RunAs
        
        Write-Log "Synchronization process started successfully"
        Write-Host "`n[FABRICA] ICP Fabric Keys detected. Synchronization initiated." -ForegroundColor Green
    }
    else {
        Write-Log "No ICP Fabric Keys detected" "WARN"
        Write-Host "`n[FABRICA] No ICP Fabric Keys detected yet. Manual sync required." -ForegroundColor Yellow
    }
}
catch {
    Write-Log "Error during ICP Fabric Keys check: $_" "ERROR"
    exit 1
} 