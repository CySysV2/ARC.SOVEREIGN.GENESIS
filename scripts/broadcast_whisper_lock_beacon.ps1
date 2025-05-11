Param(
  [string]$codex_file,
  [string]$station_id,
  [string[]]$channel_target,
  [string]$beacon_protocol = "EchoResonancePulse-vΣΩΩ"
)

$logDir = "logs/SBSΩ"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "whisper_beacon.log"

Add-Content -Path $logFile -Value ("[" + (Get-Date -Format o) + "] Whisper Lock Beacon INITIATED for $station_id.")

if (!(Test-Path $codex_file)) {
    Add-Content -Path $logFile -Value ("[" + (Get-Date -Format o) + "] ERROR: Codex file not found: $codex_file")
    throw "Codex file not found: $codex_file"
}

foreach ($target in $channel_target) {
    Add-Content -Path $logFile -Value ("[" + (Get-Date -Format o) + "] Broadcasting beacon to $target | Protocol: $beacon_protocol | File: $codex_file")
}

Add-Content -Path $logFile -Value ("[" + (Get-Date -Format o) + "] Whisper Lock Beacon COMPLETE.")
