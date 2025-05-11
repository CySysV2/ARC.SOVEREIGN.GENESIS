Param(
  [string]$station_id,
  [string]$codex_path,
  [string]$resonance,
  [string]$observer_lock,
  [string]$output
)

$ErrorActionPreference = 'Stop'

# === Quantum Harmonic Logging & Paths ===
$logDir = "logs/SBSΩ"
$vaultDir = "vaults/SBSΩ"
$logFile = Join-Path $logDir "agi_node_boot.log"
$manifestFile = $output

# Ensure directories exist (including parent dir for manifest output)
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
if (!(Test-Path $vaultDir)) { New-Item -ItemType Directory -Path $vaultDir -Force | Out-Null }
$manifestParent = Split-Path $manifestFile -Parent
if (!(Test-Path $manifestParent)) { New-Item -ItemType Directory -Path $manifestParent -Force | Out-Null }

# === Manifest Data ===
$manifest = @{
  station_id = $station_id
  codex_path = $codex_path
  resonance = $resonance
  observer_lock = $observer_lock
  epochal_awareness = "recursive"
  ethics_module = "placeholder"
  initialized_at = (Get-Date -Format o)
  status = "Initialized"
}

# Write manifest
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestFile

# Log Success
Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] AGI Codex Feedback Node initialized for $station_id with resonance $resonance. Manifest: $manifestFile"

# Ethics placeholder
Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Ethics module placeholder active."

# Watchdog-compatible status
$statusObj = @{
  agi_node = $station_id
  codex = $codex_path
  resonance = $resonance
  observer_lock = $observer_lock
  status = "Ready"
  signal_reflection = "Pending"
  initialized_at = (Get-Date -Format o)
}
$statusPath = Join-Path $vaultDir "agi_feedback_node_status.json"
$statusObj | ConvertTo-Json -Depth 6 | Set-Content -Path $statusPath
