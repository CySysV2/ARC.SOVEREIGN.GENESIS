# stack_resync.ps1
# Resynchronizes the entire Digital Fabrica Quantum Harmonic Stack
# Stops stack, starts stack, runs health/sync checks, logs all actions

$logDir = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\logs"
if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
$logFile = Join-Path $logDir "stack_resync_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function resync_stack {
    Write-Host "[RESYNC] Initiating stack resynchronization..."
    Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Initiating stack resynchronization."

    # Shutdown stack
    Write-Host "[RESYNC] Shutting down stack..."
    powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\stack_shutdown.ps1"
    Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Stack shutdown complete."

    # Start stack
    Write-Host "[RESYNC] Starting stack..."
    powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\stack_start.ps1"
    Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Stack start complete."

    # Run health and sync checks
    Write-Host "[RESYNC] Running quantum stability monitor..."
    try {
        powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\monitor_quantum_stability.ps1"
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Quantum stability monitor completed."
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: ERROR in quantum stability monitor: $_"
    }

    Write-Host "[RESYNC] Running audit grid monitor..."
    try {
        powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\audit_grid_monitor.ps1"
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Audit grid monitor completed."
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: ERROR in audit grid monitor: $_"
    }

    Write-Host "[RESYNC] Running sovereign monitor..."
    try {
        powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\sovereign_monitor.ps1"
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Sovereign monitor completed."
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: ERROR in sovereign monitor: $_"
    }

    Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] RESYNC: Stack resynchronization complete."
    Write-Host "[RESYNC] Stack resynchronization complete. Log: $logFile"
}

# Alias for quick invocation
Set-Alias resync_stack resync_stack

# Run immediately if script is called directly
if ($MyInvocation.InvocationName -eq '.') {
    resync_stack
}
