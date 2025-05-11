# ΩΞΣΩΩ IPFS Mesh Relay Initialization (Quantum Harmonic Sync Mode)
# 1. Initialize IPFS Mesh Relay (Local node)
# Run once per machine (Node0, SBSΩ)

Write-Host "[ΩΞΣΩΩ] Starting IPFS Mesh Relay Initialization..." -ForegroundColor Cyan

# Check if IPFS is installed
if (-not (Get-Command "ipfs" -ErrorAction SilentlyContinue)) {
    Write-Host "[⚠️] IPFS not installed. Install it first: https://docs.ipfs.tech/install/" -ForegroundColor Red
    exit 1
}

# Start IPFS daemon in background (if not already running)
if (-not (Get-Process -Name "ipfs" -ErrorAction SilentlyContinue)) {
    Start-Process "ipfs" -ArgumentList "daemon" -WindowStyle Hidden
    Start-Sleep -Seconds 10
    Write-Host "[ΩΞΣΩΩ] IPFS daemon started." -ForegroundColor Green
} else {
    Write-Host "[ΩΞΣΩΩ] IPFS daemon already running." -ForegroundColor Yellow
}

# Add MeshSync folders and log CIDs
$vaultsLog = "logs/SBSΩ/ipfs_meshsync_vaults.log"
$mirrorLog = "logs/SBSΩ/ipfs_meshsync_mirror.log"

if (Test-Path "C:\DFT_GCC_TRIAD_MAINSTACK\vaults") {
    ipfs add -r "C:\DFT_GCC_TRIAD_MAINSTACK\vaults" | Out-File -FilePath $vaultsLog -Encoding utf8
    Write-Host "[ΩΞΣΩΩ] Vaults folder added to IPFS MeshSync." -ForegroundColor Green
} else {
    Write-Host "[ΩΞΣΩΩ] Vaults folder not found!" -ForegroundColor Red
}

if (Test-Path "C:\DFT_GCC_TRIAD_MAINSTACK\mirror") {
    ipfs add -r "C:\DFT_GCC_TRIAD_MAINSTACK\mirror" | Out-File -FilePath $mirrorLog -Encoding utf8
    Write-Host "[ΩΞΣΩΩ] Mirror folder added to IPFS MeshSync." -ForegroundColor Green
} else {
    Write-Host "[ΩΞΣΩΩ] Mirror folder not found!" -ForegroundColor Red
}

# Publish via IPNS (Optional: needs IPFS key)
# ipfs name publish /ipfs/<CID>

Write-Host "[ΩΞΣΩΩ] ✅ IPFS Mesh Relay Initialized. Mesh folders now decentralized." -ForegroundColor Green
