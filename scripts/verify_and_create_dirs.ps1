# Quantum Harmonic Directory Verification & Creation Script
$dirs = @(
  "C:\DFT_GCC_TRIAD_MAINSTACK\logs\SBS_ASCII",
  "C:\DFT_GCC_TRIAD_MAINSTACK\logs\C-STATION",
  "C:\DFT_GCC_TRIAD_MAINSTACK\vaults\SBS_ASCII",
  "C:\DFT_GCC_TRIAD_MAINSTACK\vaults\C-STATION",
  "C:\DFT_GCC_TRIAD_MAINSTACK\mirror",
  "C:\DFT_GCC_TRIAD_MAINSTACK\MeshSync\SBS_ASCII",
  "C:\DFT_GCC_TRIAD_MAINSTACK\MeshSync\C-STATION",
  "C:\DFT_GCC_TRIAD_MAINSTACK\AGI_Context",
  "C:\DFT_GCC_TRIAD_MAINSTACK\scripts",
  "C:\DFT_GCC_TRIAD_MAINSTACK\Gospels\MasterStacks"
)
foreach ($dir in $dirs) {
  if (!(Test-Path $dir)) {
    try {
      New-Item -ItemType Directory -Path $dir -Force | Out-Null
      Write-Host "Created: $dir"
    } catch {
      Write-Host "ERROR: Could not create $dir -- $_" -ForegroundColor Red
    }
  } else {
    Write-Host "Exists: $dir"
  }
}
