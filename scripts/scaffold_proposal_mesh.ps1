$base = "C:\DFT_GCC_TRIAD_MAINSTACK\ARC.SOVEREIGN.GENESIS\04_public"
$domains = @(
  "digital-fabrica.com",
  "g-i-l-c.com",
  "citizen.solar",
  "yellowchain.org",
  "renewable-exchange.com",
  "harvest-exchange.com"
)
foreach ($domain in $domains) {
  $path = Join-Path $base $domain
  if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
  $proposal = '[{ "title": "Initial Proposal", "type": "policy", "status": "pending" }]'
  Set-Content -Path (Join-Path $path 'proposals.json') -Value $proposal
  Write-Host "🗳️ Initialized proposal file for $domain"
} 