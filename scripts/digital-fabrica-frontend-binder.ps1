# FRONTEND DATA BINDING SCRIPT
# Converts project indexes into frontend-consumable JSON

$projectDir = "C:\FABRICA\indexes\projects"
$outDir = "C:\FABRICA\frontend"
New-Item -ItemType Directory -Path $outDir -Force

# 1. Transform project indexes
$categories = @('ikl','yellowchain','cysys','dao','tangra','dft-core')

foreach ($category in $categories) {
    $inputFile = Join-Path $projectDir "$category-index.json"
    $outputFile = Join-Path $outDir "$category-frontend.json"
    
    if (Test-Path $inputFile) {
        $data = Get-Content $inputFile | ConvertFrom-Json
        $frontendData = @()
        
        foreach ($item in $data) {
            $frontendData += @{
                id = [guid]::NewGuid().ToString()
                content = $item
                category = $category
                epoch = "ΣΩΩ.4.0"
                timestamp = (Get-Date).ToString("o")
                zkAnchor = $null
            }
        }
        
        $frontendData | ConvertTo-Json -Depth 5 | Out-File $outputFile
    }
}

# 2. Generate DAO-ready exports
$daoDir = Join-Path $outDir "dao"
New-Item -ItemType Directory -Path $daoDir -Force

foreach ($category in $categories) {
    $inputFile = Join-Path $outDir "$category-frontend.json"
    $outputFile = Join-Path $daoDir "$category.dao.json"
    
    if (Test-Path $inputFile) {
        $data = Get-Content $inputFile | ConvertFrom-Json
        $daoData = $data | Select-Object @{
            Name="title"; Expression={$_.category.ToUpper() + "_" + [guid]::NewGuid().ToString().Substring(0,8)}
        }, @{
            Name="content"; Expression={$_.content}
        }, @{
            Name="category"; Expression={$_.category}
        }, @{
            Name="epoch"; Expression={$_.epoch}
        }, @{
            Name="hash"; Expression={[guid]::NewGuid().ToString()}
        }, @{
            Name="provenance"; Expression={"Operator_11411"}
        }
        
        $daoData | ConvertTo-Json -Depth 5 | Out-File $outputFile
    }
}

# 3. Verify frontend integration points
$webProjectsDir = "C:\DFT_GCC_TRIAD_MAINSTACK\ARC.SOVEREIGN.GENESIS\web-projects"
$integrationPoints = @(
    "$webProjectsDir/digital-fabrica.com/src/pages/projects/data.js",
    "$webProjectsDir/digital-fabrica.com/src/pages/research/data.js",
    "$webProjectsDir/digital-fabrica.com/src/pages/dao/data.js"
)

foreach ($point in $integrationPoints) {
    if (Test-Path $point) {
        Write-Host "✅ Integration point verified: $point" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Missing integration point: $point" -ForegroundColor Yellow
    }
}

Write-Host "🌀 Quantum sync complete. Frontend data prepared at: $outDir" -ForegroundColor Cyan 