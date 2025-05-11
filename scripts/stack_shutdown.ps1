# stack_shutdown.ps1
# Stops all stack containers for Digital Fabrica Quantum Harmonic Stack
# Logs shutdown event for compliance

$logDir = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\logs"
if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
$logFile = Join-Path $logDir "stack_shutdown_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

$containers = @(
    'sovereign-core',
    'redis',
    'genesis-quantum-bridge',
    'genesis-web-gateway',
    'genesis-harmonic-monitor',
    'genesis-state-manager',
    'quantum-redis-6380'
)

foreach ($container in $containers) {
    try {
        Write-Host "Stopping container: $container"
        docker stop $container | Out-Null
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] STOPPED: $container"
    } catch {
        Add-Content -Path $logFile -Value ("[{0}] ERROR stopping {1}: {2}" -f (Get-Date -Format o), $container, $_)
    }
}

Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] Stack shutdown complete."
Write-Host "Stack shutdown complete. Log: $logFile"
