# Quantum Harmonic Mesh: Automated Startup Task Registration
# This script registers all key mesh harmonization and monitoring scripts as Windows startup tasks (SYSTEM, highest privileges).
# Run this script as Administrator!

$tasks = @(
    @{ Name = "SBSOmega_ProjectHarmonizer";
       Script = "C:\DFT_GCC_TRIAD_MAINSTACK\Gospels\MasterStacks\OmegaXi33_SBSΩ_PROJECT_DISCOVERY_HARMONIZER.ps1";
       Description = "Quantum Harmonic Mesh Project Harmonizer" },
    @{ Name = "QuantumSyncManager";
       Script = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\QuantumSyncManager.ps1";
       Description = "Quantum Sync Monitoring & Health" },
    @{ Name = "SovereignSystemMonitor";
       Script = "C:\DFT_GCC_TRIAD_MAINSTACK\scripts\SovereignSystemOrchestrationMonitor.ps1";
       Description = "Sovereign System Orchestration Monitor" }
)

foreach ($task in $tasks) {
    if (Test-Path $task.Script) {
        Write-Host "[INFO] Registering $($task.Name) for startup..."
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File '$($task.Script)'"
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        try {
            Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false -ErrorAction SilentlyContinue
        } catch {}
        Register-ScheduledTask -TaskName $task.Name -Action $action -Trigger $trigger -Principal $principal -Description $task.Description
    } else {
        Write-Host "[WARNING] Script not found: $($task.Script). Skipping $($task.Name)."
    }
}

Write-Host "[SUCCESS] All mesh harmonization and monitoring tasks registered for Windows startup. Quantum sync mode enabled."
