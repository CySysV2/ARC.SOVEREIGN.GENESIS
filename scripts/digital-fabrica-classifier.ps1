$inputLog = Get-ChildItem "C:\FABRICA\indexes\digital-fabrica-domain-index_*.log" | Sort-Object LastWriteTime | Select-Object -Last 1
$outDir = "C:\FABRICA\indexes\projects"
New-Item -ItemType Directory -Path $outDir -Force

# Initialize category structure
$tags = @{
    'ikl' = 'IKL';
    'yellow' = 'YellowChain';
    'cysys' = 'CySys';
    'fns' = 'DAO';
    'tangra' = 'Tangra';
    'fabric' = 'DFT Core'
}

# Initialize empty project index files
foreach ($tag in $tags.Keys) {
    $category = $tags[$tag]
    $targetFile = Join-Path $outDir "$($category.ToLower())-index.json"
    '[]' | Out-File $targetFile
}

# Load or initialize classified map
$classifiedMap = "C:\FABRICA\indexes\classified-map.json"
if (!(Test-Path $classifiedMap)) {
    $mapContent = @{}
    foreach ($tag in $tags.Values) {
        $mapContent.$tag = @()
    }
    $mapContent | ConvertTo-Json | Out-File $classifiedMap
}
$mapContent = Get-Content $classifiedMap | ConvertFrom-Json

# Process each line from the index log
foreach ($line in (Get-Content $inputLog.FullName)) {
    foreach ($tag in $tags.Keys) {
        if ($line -match $tag) {
            $category = $tags[$tag]
            
            # Add to project index
            $targetFile = Join-Path $outDir "$($category.ToLower())-index.json"
            $jsonContent = Get-Content $targetFile | ConvertFrom-Json
            $jsonContent += $line
            $jsonContent | ConvertTo-Json | Out-File $targetFile
            
            # Update classified map
            if (-not $mapContent.PSObject.Properties[$category]) {
                $mapContent | Add-Member -MemberType NoteProperty -Name $category -Value @()
            }
            $mapContent.$category += $line
        }
    }
}

# Save updated classified map
$mapContent | ConvertTo-Json | Out-File $classifiedMap

Write-Host "✅ Project classification completed. Output files:" -ForegroundColor Green
Write-Host "- Project Indexes: $outDir\*" -ForegroundColor Cyan
Write-Host "- Updated Classified Map: $classifiedMap" -ForegroundColor Cyan 