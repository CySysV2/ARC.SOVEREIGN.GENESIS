# stack_start.ps1
# Starts all stack containers for Digital Fabrica Quantum Harmonic Stack
# Optionally runs auto_orchestrator.ps1 for orchestration logic
# Logs start event for compliance

$logDir = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\logs"
if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
$logFile = Join-Path $logDir "stack_start_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

$containers = @(
    'redis',
    'sovereign-core',
    'genesis-quantum-bridge',
    'genesis-web-gateway',
    'genesis-harmonic-monitor',
    'genesis-state-manager',
    'quantum-redis-6380'
)

foreach ($container in $containers) {
    try {
        Write-Host "Starting container: $container"
        docker start $container | Out-Null
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] STARTED: $container"
    } catch {
        Add-Content -Path $logFile -Value ("[{0}] ERROR starting {1}: {2}" -f (Get-Date -Format o), $container, $_)
    }
}

# Optionally run auto_orchestrator.ps1 for orchestration logic
$orchestratorScript = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\auto_orchestrator.ps1"
if (Test-Path $orchestratorScript) {
    Write-Host "Running auto_orchestrator.ps1..."
    try {
        powershell -ExecutionPolicy Bypass -File $orchestratorScript
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] Orchestrator executed."
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] ERROR running orchestrator: $_"
    }
}

Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] Stack start complete."
Write-Host "Stack start complete. Log: $logFile"
