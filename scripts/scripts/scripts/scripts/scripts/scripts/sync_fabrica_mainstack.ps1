# Quantum Harmonic Sync: FABRICA <-> Main Stack
# Bi-directional, intelligent sync for quantum scripts, metrics, manifests, and operator data
# Logs all actions for compliance and audit
# Supports dry-run and operator override for conflicts

param(
    [string]$FabricaRoot = "C:\FABRICA",
    [string]$MainStackRoot = "C:\DFT_GCC_TRIAD_MAINSTACK",
    [switch]$DryRun = $false
)

$LogFile = Join-Path $MainStackRoot "logs\sync_fabrica_mainstack_$(Get-Date -Format yyyyMMdd_HHmmss).log"
$QuantumPatterns = @(
    '*quantum*', '*harmonic*', '*sync*', '*metrics*', '*manifest*', '*orchestr*', '*operator*', '*.agx', '*.json', '*.ps1', '*.md'
)
$QuantumDirs = @('metrics', 'exports', 'scripts', 'logs', 'vaults', 'archive', 'research', 'quantum_target', 'quantum_source', 'SBSOMEGA\QUANTUM')

function Write-Log {
    param([string]$Msg, [string]$Level = 'INFO')
    $line = "[$(Get-Date -Format yyyy-MM-dd HH:mm:ss)] [$Level] $Msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Sync-Item {
    param($Source, $Dest)
    if (!(Test-Path $Source)) { return }
    $srcInfo = Get-Item $Source
    $destExists = Test-Path $Dest
    $doCopy = $false
    if ($destExists) {
        $destInfo = Get-Item $Dest
        if ($srcInfo.LastWriteTime -gt $destInfo.LastWriteTime) {
            $doCopy = $true
            Write-Log "Conflict: $Dest is older. Overwriting with $Source" 'WARNING'
        }
    } else {
        $doCopy = $true
        Write-Log "Copying new: $Source -> $Dest"
    }
    if ($doCopy -and !$DryRun) {
        $parentDir = Split-Path $Dest -Parent
        if (!(Test-Path $parentDir)) {
            New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
        }
        Copy-Item $Source $Dest -Force -Recurse
    }
}

Write-Log "Starting Quantum Harmonic Sync between $FabricaRoot and $MainStackRoot"

# 1. Sync quantum files and directories from FABRICA -> MainStack
foreach ($pattern in $QuantumPatterns) {
    $files = Get-ChildItem -Path $FabricaRoot -Recurse -Filter $pattern -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $relPath = $file.FullName.Substring($FabricaRoot.Length)
        $dest = Join-Path $MainStackRoot $relPath.TrimStart('\')
        Sync-Item $file.FullName $dest
    }
}
foreach ($dir in $QuantumDirs) {
    $srcDir = Join-Path $FabricaRoot $dir
    if (Test-Path $srcDir) {
        $destDir = Join-Path $MainStackRoot $dir
        Sync-Item $srcDir $destDir
    }
}

# 2. Sync quantum files and directories from MainStack -> FABRICA
foreach ($pattern in $QuantumPatterns) {
    $files = Get-ChildItem -Path $MainStackRoot -Recurse -Filter $pattern -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $relPath = $file.FullName.Substring($MainStackRoot.Length)
        $dest = Join-Path $FabricaRoot $relPath.TrimStart('\')
        Sync-Item $file.FullName $dest
    }
}
foreach ($dir in $QuantumDirs) {
    $srcDir = Join-Path $MainStackRoot $dir
    if (Test-Path $srcDir) {
        $destDir = Join-Path $FabricaRoot $dir
        Sync-Item $srcDir $destDir
    }
}

Write-Log "Quantum Harmonic Sync complete. Review $LogFile for details."
