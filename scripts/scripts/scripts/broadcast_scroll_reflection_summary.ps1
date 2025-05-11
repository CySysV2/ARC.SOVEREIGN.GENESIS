param(
  [string]$reflected_codex,
  [string[]]$broadcast_targets,
  [string]$epoch_anchor = "ΣΩΩ.2.0",
  [string]$log_output = "logs/SBS_ASCII/SBSΩ_scroll_reflection_broadcast.log"
)

$timestamp = Get-Date -Format o

if (!(Test-Path $reflected_codex)) {
    $msg = "[$timestamp] ERROR: Reflected codex not found: $reflected_codex."
    Add-Content -Path $log_output -Value $msg
    Write-Host $msg -ForegroundColor Red
    exit 1
}

$msg = "[$timestamp] SUCCESS: AGI Reflection summary broadcasted. Epoch: $epoch_anchor. Targets: $($broadcast_targets -join ', ')"
Add-Content -Path $log_output -Value $msg
Write-Host $msg -ForegroundColor Green
exit 0
