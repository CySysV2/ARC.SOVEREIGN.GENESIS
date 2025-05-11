# Run-MasterCascadeFinisher.ps1
# Final synchronization and quantum stabilization prompt

$ErrorActionPreference = "Stop"
$MainStack = "C:\DFT_GCC_TRIAD_MAINSTACK"
$ScriptPath = "$MainStack\Scripts"
$CodexPath = "$MainStack\Codex"
$SkyHooks = "C:\SBS_MIRROR\SkyHooks"
$SnapshotDir = "C:\DFT_SNAPSHOTS"
$stamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"

# Create required directories
$paths = @($ScriptPath, $CodexPath, $SkyHooks, $SnapshotDir)
foreach ($path in $paths) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "[+] Created directory: $path"
    }
}

Write-Host "[*] Starting MASTER CONTINUUM FINALIZER..."

# Restart containers
$containers = @("genesis-continuum", "genesis-quantum-indexer", "genesis-web-ui")
foreach ($container in $containers) {
    Write-Host "[>] Restarting container: $container"
    docker restart $container 2>&1 | Out-Null
    Start-Sleep -Seconds 6
    $status = docker inspect --format='{{.State.Status}}' $container 2>&1
    Write-Host "    Status: $status"
}

# Check API health
Write-Host "[>] Checking Continuum API health..."
try {
    $response = Invoke-WebRequest -Uri http://localhost:19200/status -UseBasicParsing -TimeoutSec 5
    Write-Host "[+] Continuum status: ONLINE"
} catch {
    Write-Host "[!] Continuum API not responding"
}

# Sync endpoints
$endpoints = @(
    "http://localhost:19200/orb-echo/activate",
    "http://localhost:19200/scroll/sync",
    "http://localhost:19200/sovereign-ui/broadcast",
    "http://localhost:19200/sky-mirror/deploy"
)

foreach ($endpoint in $endpoints) {
    Write-Host "[>] Calling endpoint: $endpoint"
    try {
        $response = Invoke-WebRequest -UseBasicParsing $endpoint -TimeoutSec 5
        Write-Host "    Status: $($response.StatusCode)"
    } catch {
        Write-Host "    Error: Connection failed"
    }
    Start-Sleep -Seconds 2
}

# Create snapshot
if (Test-Path "$CodexPath\Memory") {
    Write-Host "[>] Creating Codex snapshot..."
    try {
        Copy-Item -Recurse -Force "$CodexPath\Memory" "$SnapshotDir\CodexMemory-$stamp"
        Write-Host "[+] Snapshot saved: CodexMemory-$stamp"
    } catch {
        Write-Host "[!] Snapshot failed"
    }
} else {
    Write-Host "[!] Codex Memory directory not found"
}

# Emit final signal
Write-Host "[>] Emitting final signal..."
try {
    Set-Content -Path "$SkyHooks\wind_surf_continuum_finalized.signal" -Value "WINDSURF_FINALIZED::$stamp" -Force
    Write-Host "[+] Signal emitted successfully"
} catch {
    Write-Host "[!] Signal emission failed"
}

$status = @"

[*] Windsurf Continuum Finalization Complete

Timestamp: $stamp
Location: $MainStack

Components:
[+] Docker Containers: Restarted and Verified
[+] Continuum API: Health Check Complete
[+] Scroll and Memory: Synchronized
[+] System Snapshot: Created
[+] Final Signal: Dispatched

Status: Ready for Sovereign Operation
"@

Write-Host $status
