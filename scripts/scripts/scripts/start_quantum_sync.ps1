# Quantum Sync Starter
# Generated: 2025-04-29T17:15:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumSyncStarter"

# Import required modules
. "C:\FABRICA\scripts\quantum_process_manager.ps1"

# Configuration
$config = @{
    LogPath  = "C:\FABRICA\logs\quantum_sync.log"
    Services = @(
        "QuantumHarmonicOrchestrator",
        "QuantumHarmonicSync",
        "QuantumHarmonicVerifier",
        "QuantumHarmonicValidator"
    )
}

# Main process
try {
    Write-Host "Starting Quantum Sync System"
    
    # Start process manager
    $processManager = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"C:\FABRICA\scripts\quantum_process_manager.ps1`"" -PassThru
    
    # Wait for process manager to initialize
    Start-Sleep -Seconds 5
    
    # Start services through process manager
    foreach ($service in $config.Services) {
        $servicePath = "C:\FABRICA\scripts\${service}.ps1"
        if (Test-Path $servicePath) {
            $success = Start-ManagedService -ServiceName $service -ServicePath $servicePath
            if (-not $success) {
                Write-Host "Failed to start ${service}" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Service script not found: ${servicePath}" -ForegroundColor Red
        }
    }
    
    Write-Host "`nQuantum Sync System started successfully" -ForegroundColor Green
}
catch {
    Write-Host "Quantum Sync System failed to start: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 