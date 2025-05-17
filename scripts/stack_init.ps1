# stack_init.ps1
# Canonical stack initialization for Digital Fabrica Quantum Harmonic Stack

# Robustly map Q: drive at startup using provided credentials
$QDrivePath = "\\Bbs\gcc.lfn.drive"
$QDriveUser = "blockchainsyndicate@outlook.com"
$QDrivePass = "f0rdude+"

# Remove any existing Q: mapping
net use Q: /delete /y | Out-Null

# Attempt to map Q: drive
$netUseResult = net use Q: $QDrivePath /user:$QDriveUser $QDrivePass
if (-not (Test-Path 'Q:\')) {
    Write-Host "ERROR: Q: drive could not be mapped. Please check network path and credentials." -ForegroundColor Red
    Write-Host $netUseResult -ForegroundColor Red
    exit 1
} else {
    Write-Host "Q: drive is mapped and accessible." -ForegroundColor Green
    # Optional: Test write access
    try {
        $testFile = 'Q:\stack_init_test.txt'
        Set-Content -Path $testFile -Value 'Stack initialization test.' -Force
        Remove-Item $testFile -Force
        Write-Host "Q: drive write test passed." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Q: drive is mapped but not writable." -ForegroundColor Red
        exit 1
    }
}

$stackRoot = "C:\DFT_GCC_TRIAD_MAINSTACK"
$logDir = "$stackRoot\scripts\logs"
$configDir = "$stackRoot\config"
$logPath = "$logDir\stack_init_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$configPath = "$configDir\stack_services_config.json"

# Ensure directories exist
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Force -Path $configDir | Out-Null }

# Logging function
function Write-Log {
    param ([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logPath -Value $logMessage
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO"  { Write-Host $logMessage -ForegroundColor Green }
        default  { Write-Host $logMessage }
    }
}

# Define core stack services
$services = @(
    @{ Name = "Quantum-Network-PathManager"; Path = "$stackRoot\scripts\Quantum-Network-PathManager.ps1" },
    @{ Name = "Stack Start"; Path = "$stackRoot\scripts\stack_start.ps1" },
    @{ Name = "Stack Shutdown"; Path = "$stackRoot\scripts\stack_shutdown.ps1" },
    @{ Name = "Stack Resync"; Path = "$stackRoot\scripts\stack_resync.ps1" },
    @{ Name = "Fractal Stack"; Path = "$stackRoot\scripts\fractal_stack.ps1" }
)

# Save config
$config = @{ Services = $services; InitTime = Get-Date -Format o }
$config | ConvertTo-Json -Depth 5 | Set-Content -Path $configPath

# Log and check service scripts
foreach ($svc in $services) {
    if (Test-Path $svc.Path) {
        Write-Log "Service '$($svc.Name)' script found at $($svc.Path)" "INFO"
    } else {
        Write-Log "Service '$($svc.Name)' script NOT FOUND at $($svc.Path)" "ERROR"
    }
}

Write-Log "Stack initialization complete."

# User guide
Write-Host "\n=== Stack Initialization Complete ===" -ForegroundColor Cyan
Write-Host "Log: $logPath" -ForegroundColor Cyan
Write-Host "Config: $configPath" -ForegroundColor Cyan
Write-Host "\nAvailable actions (run from $stackRoot/scripts):" -ForegroundColor Yellow
Write-Host "  1. Start stack:      powershell -ExecutionPolicy Bypass -File stack_start.ps1" -ForegroundColor Green
Write-Host "  2. Shutdown stack:   powershell -ExecutionPolicy Bypass -File stack_shutdown.ps1" -ForegroundColor Green
Write-Host "  3. Resync stack:     powershell -ExecutionPolicy Bypass -File stack_resync.ps1" -ForegroundColor Green
Write-Host "  4. Orchestrate:      powershell -ExecutionPolicy Bypass -File Quantum-Network-PathManager.ps1" -ForegroundColor Green
Write-Host "  5. Fractal stack:    powershell -ExecutionPolicy Bypass -File fractal_stack.ps1" -ForegroundColor Green
Write-Host "  6. Check logs:       Get-Content .\logs\<logfile> -Tail 40" -ForegroundColor Green
Write-Host "\nFor more options, see the scripts directory or documentation." -ForegroundColor Yellow

# Remap the drive
net use Q: \\Bbs\gcc.lfn.drive

# Verify the drive is accessible
Test-Path Q:\