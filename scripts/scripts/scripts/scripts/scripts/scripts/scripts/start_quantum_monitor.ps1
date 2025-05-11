# Start Quantum Monitoring System
param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "PRODUCTION",
    
    [Parameter(Mandatory=$false)]
    [string]$Epoch = "ΣΩΩ.3.0"
)

$ErrorActionPreference = "Stop"

# Configuration
$CONFIG = @{
    QUANTUM_BRIDGE_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\Docker\quantum-bridge"
    LOG_DIR = "C:\DFT_GCC_TRIAD_MAINSTACK\logs"
    REDIS_PORT = 6380
    REDIS_HOST = "localhost"
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$Level] $Message"
    
    $color = switch ($Level) {
        'INFO' { 'White' }
        'WARNING' { 'Yellow' }
        'ERROR' { 'Red' }
        'SUCCESS' { 'Green' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
}

function Start-QuantumMonitor {
    try {
        Write-Log "Starting Quantum Monitor in $Environment mode" -Level INFO
        Write-Log "Epoch: $Epoch" -Level INFO

        # Check Redis status
        Write-Log "Checking Redis status..." -Level INFO
        try {
            $redisPath = Join-Path $env:ProgramFiles "Redis\redis-cli.exe"
            if (-not (Test-Path $redisPath)) {
                $redisPath = Join-Path "C:\DFT_GCC_TRIAD_MAINSTACK\Redis" "redis-cli.exe"
            }
            
            $redisArgs = @{
                FilePath = $redisPath
                ArgumentList = "-h", $CONFIG.REDIS_HOST, "-p", $CONFIG.REDIS_PORT, "ping"
                RedirectStandardOutput = $true
                Wait = $true
                NoNewWindow = $true
            }
            
            $redisPing = Start-Process @redisArgs
            if ($redisPing.ExitCode -ne 0) {
                Write-Log "Redis is not responding. Starting Redis..." -Level WARNING
                & $PSScriptRoot\start_redis.ps1
                Start-Sleep -Seconds 2
            }
        } catch {
            Write-Log "Error checking Redis status: $_" -Level ERROR
            Write-Log "Starting Redis..." -Level WARNING
            & $PSScriptRoot\start_redis.ps1
            Start-Sleep -Seconds 2
        }

        # Start Quantum Bridge monitor
        Write-Log "Starting Quantum Bridge monitor..." -Level INFO
        $bridgePath = Join-Path $PSScriptRoot "..\SBS\Docker\quantum-bridge"
        $npmPath = Join-Path $env:ProgramFiles "nodejs\npm.cmd"
        if (-not (Test-Path $npmPath)) {
            $npmPath = "npm.cmd"  # Try using npm from PATH
        }

        # Initialize quantum state
        Write-Log "Initializing quantum state..." -Level INFO
        try {
            $result = & $PSScriptRoot\resync_sovereign_network.ps1 -Epoch $Epoch -NodeSet "ALL" -Mode "FULL"
            if (-not $result) {
                Write-Log "Failed to initialize quantum state" -Level ERROR
                return $false
            }
        } catch {
            Write-Log "Error initializing quantum state: $_" -Level ERROR
            return $false
        }

        # Start monitoring service
        Write-Log "Starting monitoring service..." -Level INFO
        try {
            $env:REDIS_PORT = $CONFIG.REDIS_PORT
            $env:REDIS_HOST = $CONFIG.REDIS_HOST
            $env:NODE_ENV = $Environment
            $env:QUANTUM_EPOCH = $Epoch

            # Change to quantum bridge directory
            Push-Location $CONFIG.QUANTUM_BRIDGE_PATH

            # Start monitor process
            $processArgs = @{
                FilePath = "node"
                ArgumentList = "src/services/monitor.js"
                PassThru = $true
                NoNewWindow = $true
                RedirectStandardOutput = "monitor.log"
                RedirectStandardError = "monitor.error.log"
                UseNewEnvironment = $true
            }

            $monitorProcess = Start-Process @processArgs

            # Wait for process to start
            Start-Sleep -Seconds 5

            # Check if process is still running
            if ($monitorProcess.HasExited) {
                Write-Log "Monitor process failed to start with exit code $($monitorProcess.ExitCode)" -Level ERROR
                
                # Check error log
                if (Test-Path "monitor.error.log") {
                    $errorContent = Get-Content "monitor.error.log" -Raw
                    Write-Log "Error log contents:" -Level ERROR
                    Write-Log $errorContent -Level ERROR
                }
                
                Pop-Location
                return $false
            }

            # Check monitor.log for initialization success
            if (Test-Path "monitor.log") {
                $logContent = Get-Content "monitor.log" -Raw
                if ($logContent -match "Quantum state initialized successfully") {
                    Write-Log "Quantum monitoring system initialized successfully" -Level SUCCESS
                    Pop-Location
                    return $true
                }
            }

            Write-Log "Monitor process started but initialization status unknown" -Level WARNING
            Pop-Location
            return $true
        } catch {
            Write-Log "Error starting monitor process: $_" -Level ERROR
            if ($pwd.Path -eq $CONFIG.QUANTUM_BRIDGE_PATH) {
                Pop-Location
            }
            return $false
        }
    } catch {
        Write-Log "Fatal error in quantum monitor initialization: $_" -Level ERROR
        throw $_
    }
}

# Execute startup
try {
    $success = Start-QuantumMonitor
    if ($success) {
        Write-Log "Quantum monitoring system initialized successfully" -Level SUCCESS
        exit 0
    } else {
        Write-Log "Failed to initialize quantum monitoring system" -Level ERROR
        exit 1
    }
} catch {
    Write-Log "Fatal error: $_" -Level ERROR
    exit 1
}
