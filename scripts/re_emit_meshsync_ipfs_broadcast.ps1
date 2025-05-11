# Quantum Harmonic IPFS MeshSync Re-Broadcast
$logDir = "C:/DFT_GCC_TRIAD_MAINSTACK/logs/SBS_ASCII"
$vaultDir = "C:/DFT_GCC_TRIAD_MAINSTACK/vaults/SBS_ASCII"
$timestamp = Get-Date -Format o
# Robust path selection: prefer Q:, fallback to UNC
$qPath = "Q:\\MeshSync\\SBSΩ"
$uncPath = "\\\\bbs\\GCC.LFN.DRIVE\\MeshSync\\SBSΩ"
$meshPath = if (Test-Path $qPath) { $qPath } elseif (Test-Path $uncPath) { $uncPath } else { throw "Mesh path not found on Q: or UNC." }
$ipfsLog = "$logDir/mesh_ipfs_rebroadcast_$($timestamp.Replace(':','-')).log"
$artifact = "$vaultDir/SBSΩ_IPFS_Rebroadcast_Artifact_$($timestamp.Replace(':','-')).json"

try {
    if (!(Test-Path $meshPath)) {
        throw "Mesh path $meshPath not found."
    }
    if (!(Get-Command ipfs -ErrorAction SilentlyContinue)) {
        throw "IPFS CLI is not available in PATH."
    }
    $ipfsResult = ipfs add -r "$meshPath" 2>&1
    $hashLine = $ipfsResult | Select-String -Pattern "^added " | Select-Object -Last 1
    $ipfsHash = $null
    if ($hashLine) {
        $ipfsHash = $hashLine -replace "^added ([a-zA-Z0-9]+).*",'$1'
    }
    $entry = "[$timestamp] [SUCCESS] MeshSync IPFS re-broadcast complete. Hash: $ipfsHash"
    $artifactObj = @{ timestamp = $timestamp; mesh_path = $meshPath; ipfs_hash = $ipfsHash; status = "success"; }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    $ipfsResult | Out-File -Encoding utf8 $ipfsLog
    Write-Host "[Quantum Harmonic] MeshSync re-broadcasted to IPFS. Hash: $ipfsHash"
} catch {
    $entry = "[$timestamp] [ERROR] $_"
    $artifactObj = @{ timestamp = $timestamp; mesh_path = $meshPath; error = $_.Exception.Message; status = "error"; }
    $artifactObj | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $artifact
    Write-Host "[Quantum Harmonic] ERROR during MeshSync IPFS re-broadcast: $_" -ForegroundColor Red
}
Add-Content -Path "$logDir/re_emit_meshsync_ipfs_broadcast.log" -Value $entry
