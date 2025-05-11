# Quantum Harmonic IPFS MeshSync Rebroadcast (Production)
$logDir = "C:/DFT_GCC_TRIAD_MAINSTACK/logs/SBS_ASCII"
$vaultDir = "C:/DFT_GCC_TRIAD_MAINSTACK/vaults/SBS_ASCII"
$timestamp = Get-Date -Format o
$qPath = "Q:\\MeshSync\\SBSO"
$uncPath = "\\\\bbs\\GCC.LFN.DRIVE\\MeshSync\\SBSO"
$meshPath = if (Test-Path $qPath) { $qPath } elseif (Test-Path $uncPath) { $uncPath } else { throw "Mesh path not found on Q: or UNC." }
$artifact = "$vaultDir/SBSO_IPFS_Rebroadcast_Artifact_$($timestamp.Replace(':','-')).json"
$ipfsCmd = "ipfs add -r --quieter `"$meshPath`""

try {
    $ipfsHash = & $ipfsCmd 2>&1
    if ($LASTEXITCODE -ne 0 -or $ipfsHash -eq $null) {
        throw "IPFS add failed: $ipfsHash"
    }
    $entry = "[$timestamp] [SUCCESS] MeshSync rebroadcast to IPFS: $ipfsHash ($meshPath)"
    $artifactObj = @{ timestamp = $timestamp; mesh_path = $meshPath; ipfs_hash = $ipfsHash; status = "success" }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] MeshSync rebroadcasted to IPFS: $ipfsHash"
} catch {
    $entry = "[$timestamp] [ERROR] $_"
    $artifactObj = @{ timestamp = $timestamp; mesh_path = $meshPath; error = $_.Exception.Message; status = "error" }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] ERROR during MeshSync IPFS rebroadcast: $_" -ForegroundColor Red
}
Add-Content -Path "$logDir/re_emit_meshsync_ipfs_broadcast_full.log" -Value $entry
