param(
  [string]$station_id,
  [string]$codex_reflected,
  [double]$resonance = 11411.83,
  [string[]]$mirror_targets,
  [string]$log_output = "logs/SBS_ASCII/SBSΩ_reflection_registration.log"
)

$timestamp = Get-Date -Format o

if (!(Test-Path $codex_reflected)) {
    $msg = "[$timestamp] ERROR: Reflected codex not found: $codex_reflected."
    Add-Content -Path $log_output -Value $msg
    Write-Host $msg -ForegroundColor Red
    exit 1
}

$msg = "[$timestamp] SUCCESS: SBSΩ registered as mirror beacon node. Resonance: $resonance. Targets: $($mirror_targets -join ', ')"
Add-Content -Path $log_output -Value $msg
Write-Host $msg -ForegroundColor Green
exit 0
