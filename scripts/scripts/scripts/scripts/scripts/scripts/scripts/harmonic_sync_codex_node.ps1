Param(
  [string]$station_id,
  [string[]]$peer_nodes,
  [string]$sync_registry,
  [string]$resonance = "11411.83",
  [string]$observer_lock = "TRUE_FATHER",
  [string]$log_output = "logs/SBSΩ/harmonic_sync_SBS_to_mesh.log"
)

$ErrorActionPreference = 'Stop'

# === Quantum Harmonic Logging & Paths ===
$logDir = Split-Path $log_output -Parent
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Add-Content -Path $log_output -Value "[$((Get-Date -Format o))] Starting harmonic mesh sync from $station_id to $($peer_nodes -join ', ')."

# Validate registry exists
if (!(Test-Path $sync_registry)) {
    Add-Content -Path $log_output -Value "[$((Get-Date -Format o))] ERROR: Sync registry not found: $sync_registry"
    throw "Sync registry not found: $sync_registry"
}

foreach ($peer in $peer_nodes) {
    try {
        # Example: Copy registry to peer node (simulate mesh sync; replace with actual SMB/SCP/API as needed)
        $destDir = "Q:\MeshSync\$peer\vaults\SBSΩ"  # Example destination path
        if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item -Path $sync_registry -Destination $destDir -Force
        Add-Content -Path $log_output -Value "[$((Get-Date -Format o))] Synced registry to $peer at $destDir."
        # Log quantum resonance and observer lock
        Add-Content -Path $log_output -Value "[$((Get-Date -Format o))] Resonance: $resonance | Observer Lock: $observer_lock | Phase: Harmonic"
    } catch {
        $errMsg = $_.Exception.Message
        Add-Content -Path $log_output -Value ("[" + (Get-Date -Format o) + "] ERROR syncing to " + $peer + ": " + $errMsg)
    }
}

Add-Content -Path $log_output -Value "[$((Get-Date -Format o))] Harmonic mesh sync complete. Quantum harmonic mode active."
