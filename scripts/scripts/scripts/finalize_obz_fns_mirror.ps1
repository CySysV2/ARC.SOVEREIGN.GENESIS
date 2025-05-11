# Quantum Harmonic OBZ/FNS Mirror Finalization
$logDir = "C:/DFT_GCC_TRIAD_MAINSTACK/logs/SBS_ASCII"
$vaultDir = "C:/DFT_GCC_TRIAD_MAINSTACK/vaults/SBS_ASCII"
$timestamp = Get-Date -Format o
# Robust path selection: prefer Q:, fallback to UNC
$qPath = "Q:\\MeshSync\\SBSO"
$uncPath = "\\\\bbs\\GCC.LFN.DRIVE\\MeshSync\\SBSO"
$obzDst = "C:\DFT_GCC_TRIAD_MAINSTACK\OBZ_CELLS\SBSO"
$artifact = "$vaultDir/SBSO_OBZ_FNS_Mirror_Artifact_$($timestamp.Replace(':','-')).json"
$meshPath = if (Test-Path $qPath) { $qPath } elseif (Test-Path $uncPath) { $uncPath } else { throw "Mesh path not found on Q: or UNC." }

try {
    if (!(Test-Path $obzDst)) { New-Item -ItemType Directory -Path $obzDst -Force | Out-Null }
    Copy-Item $meshPath -Destination $obzDst -Recurse -Force
    $entry = "[$timestamp] [SUCCESS] OBZ/FNS mirror finalized: $meshPath -> $obzDst"
    $artifactObj = @{ timestamp = $timestamp; source = $meshPath; destination = $obzDst; status = "success"; }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] OBZ/FNS mirror finalized."
} catch {
    $entry = "[$timestamp] [ERROR] $_"
    $artifactObj = @{ timestamp = $timestamp; source = $meshPath; destination = $obzDst; error = $_.Exception.Message; status = "error"; }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] ERROR during OBZ/FNS mirror finalization: $_" -ForegroundColor Red
}
Add-Content -Path "$logDir/finalize_obz_fns_mirror.log" -Value $entry
