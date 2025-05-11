# Quantum Harmonic OBZ/FNS Mirror Finalization (Production)
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
    # Production-grade: robust, recursive, quantum-compliant copy
    Copy-Item $meshPath -Destination $obzDst -Recurse -Force -ErrorAction Stop
    # Verification step: ensure files are present in destination
    $srcCount = (Get-ChildItem -Path $meshPath -Recurse | Measure-Object).Count
    $dstCount = (Get-ChildItem -Path $obzDst -Recurse | Measure-Object).Count
    if ($srcCount -ne $dstCount) {
        throw "Mirror verification failed: source count $srcCount, destination count $dstCount."
    }
    $entry = "[$timestamp] [SUCCESS] OBZ/FNS mirror finalized: $meshPath -> $obzDst (Files: $dstCount)"
    $artifactObj = @{ timestamp = $timestamp; source = $meshPath; destination = $obzDst; status = "success"; files_mirrored = $dstCount }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] OBZ/FNS mirror finalized and verified."
} catch {
    $entry = "[$timestamp] [ERROR] $_"
    $artifactObj = @{ timestamp = $timestamp; source = $meshPath; destination = $obzDst; error = $_.Exception.Message; status = "error" }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] ERROR during OBZ/FNS mirror finalization: $_" -ForegroundColor Red
}
Add-Content -Path "$logDir/finalize_obz_fns_mirror_full.log" -Value $entry
