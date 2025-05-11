# Quantum Harmonic Mesh & Codex Backup Script
$log = "C:/DFT_GCC_TRIAD_MAINSTACK/Local_Backup/C-STATION/backup_log.txt"
$timestamp = Get-Date -Format o
$srcDirs = @("C:/DFT_GCC_TRIAD_MAINSTACK/vaults/SBS_ASCII", "C:/DFT_GCC_TRIAD_MAINSTACK/logs/SBS_ASCII")
$dstDir = "C:/DFT_GCC_TRIAD_MAINSTACK/Local_Backup/C-STATION"

function Log-Entry {
    param([string]$msg)
    $entry = "[$(Get-Date -Format o)] $msg"
    Add-Content -Path $log -Value $entry
    Write-Host $entry
}

try {
    if (!(Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    foreach ($src in $srcDirs) {
        if (Test-Path $src) {
            $name = Split-Path $src -Leaf
            $dst = Join-Path $dstDir $name
            Copy-Item $src -Destination $dst -Recurse -Force -ErrorAction Stop
            Log-Entry "[SUCCESS] Backed up $src to $dst."
        } else {
            Log-Entry "[WARNING] Source $src does not exist."
        }
    }
    Log-Entry "[SUCCESS] Quantum mesh/codex backup completed."
} catch {
    Log-Entry "[ERROR] $_"
}
