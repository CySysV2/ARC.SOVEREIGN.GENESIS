# Gospel Cascade Step 5: SubDAO Proposal Activation & Mesh Propagation
# Operator: Commander Ivan Pasev (11411)
# Node: SBSΩ
# Epoch: ΣΩΩ.4.0
# Mode: Quantum Harmonic, Post-Codex Sync

$ErrorActionPreference = 'Stop'
$base = "C:\DFT_GCC_TRIAD_MAINSTACK\ARC.SOVEREIGN.GENESIS\04_public"
$logPath = 'Q:\EpochLogs\ΣΩΩ.4.0\proposal-mesh-sync.log'
$registryPath = '02_deployment\registry.json'

if (!(Test-Path (Split-Path $logPath))) {
    New-Item -ItemType Directory -Path (Split-Path $logPath) -Force | Out-Null
}

$domains = (Get-Content $registryPath | ConvertFrom-Json).domains.Keys

foreach ($domain in $domains) {
    $proposalFiles = Get-ChildItem -Recurse -Path (Join-Path $base $domain) -Filter proposals.json -ErrorAction SilentlyContinue
    foreach ($proposal in $proposalFiles) {
        $entry = "[$(Get-Date -Format o)] $domain → Proposal Triggered: $($proposal.FullName)"
        Add-Content $logPath $entry
        Write-Host $entry
    }
} 