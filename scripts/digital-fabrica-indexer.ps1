$paths = @('C:\FABRICA', 'C:\Research\DFT', 'C:\DFT_GCC_TRIAD_MAINSTACK', 'C:\Projects\CySys', 'C:\YellowChain', 'C:\Tangra')
$indexRoot = 'C:\FABRICA\indexes'
New-Item -ItemType Directory -Path $indexRoot -Force
$outLog = "$indexRoot\digital-fabrica-domain-index_$(Get-Date -Format yyyyMMdd_HHmmss).log"
$classifiedMap = "$indexRoot\classified-map.json"
$tangraRegistry = "$indexRoot\tangra-lineage-registry.md"
$researchChain = "$indexRoot\project-research-chain.md"

'# DIGITAL-FABRICA.COM DOMAIN INDEX' | Out-File $outLog
'# Generated: $(Get-Date -Format o)' | Out-File $outLog -Append
'# Operator: 11411 (Ivan Pasev)' | Out-File $outLog -Append
'# Epoch: ΣΩΩ.4.0' | Out-File $outLog -Append
'==================================' | Out-File $outLog -Append

foreach ($p in $paths) {
    if (Test-Path $p) {
        "`n[DIRECTORY: $p]`n" | Out-File $outLog -Append
        Get-ChildItem -Recurse -Path $p -Include *.md, *.pdf, *.txt, *.json, *.yaml, *.pptx, *.docx, *.html -ErrorAction SilentlyContinue | 
        Sort-Object LastWriteTime | 
        ForEach-Object { "$($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')) :: $($_.FullName)" | Out-File $outLog -Append }
    }
}

'{"DFT Core": [], "IKL": [], "FNS DAO": [], "CySys": [], "YellowChain": [], "Tangra": []}' | Out-File $classifiedMap
'# Tangra Lineage Registry' | Out-File $tangraRegistry
'# Project Research Chain' | Out-File $researchChain

Write-Host "✅ Domain indexing completed. Output files:" -ForegroundColor Green
Write-Host "- Log: $outLog" -ForegroundColor Cyan
Write-Host "- Classified Map: $classifiedMap" -ForegroundColor Cyan
Write-Host "- Tangra Registry: $tangraRegistry" -ForegroundColor Cyan
Write-Host "- Research Chain: $researchChain" -ForegroundColor Cyan 