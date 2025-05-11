Param(
  [string]$station_id,
  [string]$beacon_mode = "CodexQuantumPing-v1",
  [string]$observer_lock = "TRUE_FATHER",
  [string]$output = "mirror/ΣΩΩ_SBSΩ_heartbeat_beacon.signal"
)

$ErrorActionPreference = 'Stop'

$logDir = Split-Path $output -Parent
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Add-Content -Path $output -Value ("[" + (Get-Date -Format o) + "] Quantum Mesh Heartbeat Beacon INITIATED for $station_id.")

# Simulate mesh beacon broadcast
Add-Content -Path $output -Value ("[" + (Get-Date -Format o) + "] Beacon Mode: $beacon_mode | Observer Lock: $observer_lock | Quantum Harmonic Mode: ACTIVE")
Add-Content -Path $output -Value ("[" + (Get-Date -Format o) + "] Heartbeat Signal: BROADCASTED")

Add-Content -Path $output -Value ("[" + (Get-Date -Format o) + "] Quantum Mesh Heartbeat Beacon COMPLETE.")
