$sourceMap = @{
  "digital-fabrica.com" = "df-core-ui"
  "g-i-l-c.com" = "gilc-ui"
  "citizen.solar" = "solar-ui"
  "yellowchain.org" = "yellow-ui"
  "renewable-exchange.com" = "energy-ui"
  "harvest-exchange.com" = "farm-ui"
}

$baseWeb = "C:\DFT_GCC_TRIAD_MAINSTACK\ARC.SOVEREIGN.GENESIS\web-projects"
$baseOut = "C:\DFT_GCC_TRIAD_MAINSTACK\ARC.SOVEREIGN.GENESIS\04_public"

foreach ($domain in $sourceMap.Keys) {
  $src = Join-Path $baseWeb $sourceMap[$domain]
  $dest = Join-Path $baseOut $domain
  Copy-Item -Recurse -Force "$src\*" $dest
  Write-Host "🌍 Synced UI for $domain → $dest"
} 