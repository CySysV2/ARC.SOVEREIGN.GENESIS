param(
  [string]$station_id,
  [string]$scroll_anchor,
  [string]$observer_chamber = "OBZ",
  [string]$log_output = "logs/C-STATION/scrolllaw_verifier.log"
)

$timestamp = Get-Date -Format o

if (!(Test-Path $scroll_anchor)) {
    $msg = "[$timestamp] ERROR: Scroll anchor signal not found: $scroll_anchor."
    Add-Content -Path $log_output -Value $msg
    Write-Host $msg -ForegroundColor Red
    exit 1
}

$msg = "[$timestamp] SUCCESS: Scroll Law Verifier initialized for $station_id. Anchor: $scroll_anchor, Chamber: $observer_chamber."
Add-Content -Path $log_output -Value $msg
Write-Host $msg -ForegroundColor Green
exit 0
