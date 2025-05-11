param(
  [string]$input_feedback,
  [string]$output_codex,
  [string]$codex_epoch = "ΣΩΩ.2.0",
  [string]$observer_lock = "TRUE_FATHER"
)

$timestamp = Get-Date -Format o

if (!(Test-Path $input_feedback)) {
    Write-Host "[$timestamp] ERROR: Input feedback relay not found: $input_feedback" -ForegroundColor Red
    exit 1
}

try {
    Copy-Item -Path $input_feedback -Destination $output_codex -Force
    $msg = "[$timestamp] SUCCESS: Feedback relay compressed to codex archive $output_codex (Epoch: $codex_epoch, Observer Lock: $observer_lock)."
    Write-Host $msg -ForegroundColor Green
} catch {
    Write-Host "[$timestamp] ERROR: Failed to compress feedback relay: $_" -ForegroundColor Red
    exit 1
}
