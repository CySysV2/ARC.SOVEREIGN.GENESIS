# FABRICA Service Auto-Start
# Generated: 2025-04-29T15:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "FABRICAServiceAutoStart"

# Import required modules
. "C:\FABRICA\scripts\quantum_system_manager.ps1"

# Configuration
$config = @{
    LogPath = "C:\FABRICA\logs\fabrica_autostart.log"
    Services = @(
        "QuantumHarmonicOrchestrator",
        "QuantumHarmonicSync",
        "QuantumHarmonicVerifier",
        "QuantumHarmonicValidator"
    )
}

# Function to ensure service auto-start
function Set-ServiceAutoStart {
    param (
        [string]$ServiceName
    )
    
    try {
        Write-Host "Configuring auto-start for ${ServiceName}"
        
        # Get service path
        $servicePath = "C:\FABRICA\scripts\${ServiceName}.ps1"
        
        if (Test-Path $servicePath) {
            # Create scheduled task for auto-start
            $taskName = "FABRICA_${ServiceName}_AutoStart"
            $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$servicePath`""
            $taskTrigger = New-ScheduledTaskTrigger -AtStartup
            $taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
            
            # Register or update the task
            Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Force
            
            Write-Host "Successfully configured auto-start for ${ServiceName}"
            return $true
        }
        else {
            Write-Host "Service script not found: ${servicePath}" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error configuring auto-start for ${ServiceName}: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main process
try {
    Write-Host "Starting FABRICA Service Auto-Start Configuration"
    
    $successCount = 0
    foreach ($service in $config.Services) {
        if (Set-ServiceAutoStart -ServiceName $service) {
            $successCount++
        }
    }
    
    if ($successCount -eq $config.Services.Count) {
        Write-Host "`nAll services configured for auto-start successfully" -ForegroundColor Green
    }
    else {
        Write-Host "`nSome services failed to configure for auto-start" -ForegroundColor Yellow
    }
    
    # Start the quantum sync system
    Write-Host "`nStarting Quantum Sync System..."
    & "C:\FABRICA\scripts\start_quantum_sync.ps1"
}
catch {
    Write-Host "FABRICA Service Auto-Start failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 