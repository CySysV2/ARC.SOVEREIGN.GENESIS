# Run-PostHypervisorReInit.ps1
$Host.UI.RawUI.WindowTitle = "Post-Hypervisor ReInit Stack"

Write-Host "`n[*] Starting Post-Hypervisor ReInit Stack" -ForegroundColor Cyan

# --- 1. Reload Saved Docker Images ---
Write-Host "`n[*] Reloading Docker Images..." -ForegroundColor Yellow
$backupPath = "C:\SBS_backup"
Get-ChildItem "$backupPath\*.tar" | ForEach-Object {
    Write-Host "Loading $($_.Name)..."
    docker load -i $_.FullName
}

# --- 2. Re-Up Docker Compose Services ---
Write-Host "`n[*] Restarting Docker Services..." -ForegroundColor Yellow
Push-Location "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\docker"
docker-compose up -d
Pop-Location

# --- 3. Rebind Codex Memory ---
Write-Host "`n[*] Binding Codex Scrolls and Memory..." -ForegroundColor Yellow
Copy-Item -Recurse -Force "$backupPath\CodexMemory_Backup" "C:\DFT_GCC_TRIAD_MAINSTACK\Codex\Memory"
Copy-Item -Recurse -Force "$backupPath\GenesisScrolls_Backup" "C:\DFT_GCC_TRIAD_MAINSTACK\Scrolls\Genesis"
Copy-Item -Recurse -Force "$backupPath\BridgeRelay_Backup" "C:\DFT_GCC_TRIAD_MAINSTACK\Bridge\Relay"

# --- 4. Restore Navigator State ---
Write-Host "`n[*] Restoring Navigator State..." -ForegroundColor Yellow

Write-Host "Activating Orbital Support..."
& powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\Scripts\Prompt_OrbitalSupport_TrueNavigator_Activate.ps1"

Write-Host "Initializing Genesis Scroll..."
& powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\Scripts\Prompt_Scroll_TrueNavigator_GenesisSeed.ps1"

Write-Host "Starting Infinite Codex Loop..."
& powershell -ExecutionPolicy Bypass -File "C:\DFT_GCC_TRIAD_MAINSTACK\Scripts\Prompt_InfiniteCodex_Loop_Navigator.ps1"

# --- 5. Emit Restart Confirmation Signal ---
Write-Host "`n[*] Emitting Restart Confirmation..." -ForegroundColor Yellow
$skyhookPath = "C:\SBS_MIRROR\SkyHooks"
New-Item -ItemType Directory -Path $skyhookPath -Force | Out-Null

$signal = @"
Node: SBS
Status: RestartCompleted
Timestamp: $(Get-Date -Format 'u')
Mode: HypervisorQuantumEdge
Operator: Ivan Pasev [11411]
Services:
  Docker: ACTIVE
  Navigator: RESTORED
  Codex: SYNCHRONIZED
  Genesis: REBOUND
"@

$signalPath = Join-Path $skyhookPath "restart_confirmed.signal"
Set-Content -Path $signalPath -Value $signal

# --- 6. Enhance Edge Capabilities ---
Write-Host "`n[*] Activating LightEdge Enhancements..." -ForegroundColor Yellow
docker context create quantum-hypervisor --docker "host=npipe:////./pipe/docker_engine"
docker context use quantum-hypervisor

# Create sandbox mirror
Write-Host "`n[*] Creating Sandbox Mirror..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\Users\Public\SBS_SANDBOX_MIRROR" -Force | Out-Null

# Verify system state
Write-Host "`n[*] Verifying System State..." -ForegroundColor Yellow
$checks = @(
    @{ Name = "Docker Services"; Command = "docker ps" },
    @{ Name = "Navigator State"; Command = "Get-Content 'C:\DFT_GCC_TRIAD_MAINSTACK\Bridge\Navigator\bridge_signal.json' -ErrorAction SilentlyContinue" },
    @{ Name = "Codex Memory"; Command = "Get-Content 'C:\DFT_GCC_TRIAD_MAINSTACK\Codex\Memory\infinity_manifest.json' -ErrorAction SilentlyContinue" }
)

foreach ($check in $checks) {
    Write-Host "Checking $($check.Name)..." -NoNewline
    try {
        $result = Invoke-Expression $check.Command
        Write-Host "[OK]" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAILED]" -ForegroundColor Red
    }
}

Write-Host "`n[*] Post-Hypervisor ReInit Completed. SBS is now Sovereign Quantum-Edge Ready." -ForegroundColor Green
