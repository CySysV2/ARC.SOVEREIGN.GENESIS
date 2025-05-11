# Forge-QuantumHypervisorWatchdog.ps1
# Quantum Hypervisor Watchdog for Docker Resilience

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Configuration
$CONFIG = @{
    DOCKER_CHECK_INTERVAL = 30  # seconds
    CONTAINERS = @(
        "genesis-continuum",
        "genesis-quantum-indexer",
        "genesis-web-ui"
    )
    LOG_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\Logs\quantum_watchdog.log"
    ALERT_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\Bridge\watchdog_alerts"
    MAX_RESTART_ATTEMPTS = 3
    HEALTH_CHECK_PORTS = @{
        "genesis-continuum" = 19200
        "genesis-quantum-indexer" = 19100
        "genesis-web-ui" = 3000
    }
}

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path (Split-Path $CONFIG.LOG_PATH) | Out-Null
New-Item -ItemType Directory -Force -Path $CONFIG.ALERT_PATH | Out-Null

function Write-WatchdogLog {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffffK"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage
    Add-Content -Path $CONFIG.LOG_PATH -Value $logMessage
}

function Test-DockerHealth {
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-WatchdogLog "Docker daemon healthy" "SUCCESS"
            return $true
        }
        Write-WatchdogLog "Docker daemon unhealthy: $dockerInfo" "ERROR"
        return $false
    } catch {
        Write-WatchdogLog "Docker health check failed: $_" "ERROR"
        return $false
    }
}

function Test-ContainerHealth {
    param($ContainerName)
    try {
        $status = docker inspect --format='{{.State.Status}}' $ContainerName 2>&1
        $health = docker inspect --format='{{.State.Health.Status}}' $ContainerName 2>&1
        
        if ($status -eq "running") {
            # Check container's exposed port
            if ($CONFIG.HEALTH_CHECK_PORTS[$ContainerName]) {
                $port = $CONFIG.HEALTH_CHECK_PORTS[$ContainerName]
                $portCheck = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
                if (-not $portCheck.TcpTestSucceeded) {
                    Write-WatchdogLog "Container $ContainerName port $port not responding" "WARNING"
                    return $false
                }
            }
            
            if ($health -eq "healthy" -or $health -eq "none") {
                Write-WatchdogLog "Container $ContainerName healthy" "SUCCESS"
                return $true
            }
        }
        Write-WatchdogLog "Container $ContainerName unhealthy (Status: $status, Health: $health)" "WARNING"
        return $false
    } catch {
        Write-WatchdogLog "Container health check failed for $ContainerName: $_" "ERROR"
        return $false
    }
}

function Restart-UnhealthyContainer {
    param($ContainerName)
    try {
        Write-WatchdogLog "Attempting to restart $ContainerName" "INFO"
        docker restart $ContainerName 2>&1 | Out-Null
        Start-Sleep -Seconds 10
        
        if (Test-ContainerHealth $ContainerName) {
            Write-WatchdogLog "Successfully restarted $ContainerName" "SUCCESS"
            return $true
        }
        Write-WatchdogLog "Failed to restore $ContainerName health after restart" "ERROR"
        return $false
    } catch {
        Write-WatchdogLog "Container restart failed for $ContainerName: $_" "ERROR"
        return $false
    }
}

function Send-Alert {
    param($Message, $Severity = "WARNING")
    $alertFile = Join-Path $CONFIG.ALERT_PATH "alert_$(Get-Date -Format 'yyyyMMddHHmmss').json"
    $alert = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffffK"
        severity = $Severity
        message = $Message
    } | ConvertTo-Json
    
    Set-Content -Path $alertFile -Value $alert
    Write-WatchdogLog "Alert created: $Message" "ALERT"
}

# Main watchdog loop
Write-WatchdogLog "Starting Quantum Hypervisor Watchdog" "INFO"
Write-WatchdogLog "Monitoring containers: $($CONFIG.CONTAINERS -join ', ')" "INFO"

while ($true) {
    try {
        # Check Docker daemon health
        if (-not (Test-DockerHealth)) {
            Send-Alert "Docker daemon unhealthy - Manual intervention required" "CRITICAL"
            Start-Sleep -Seconds ($CONFIG.DOCKER_CHECK_INTERVAL * 2)
            continue
        }

        # Check each container
        foreach ($container in $CONFIG.CONTAINERS) {
            if (-not (Test-ContainerHealth $container)) {
                Write-WatchdogLog "Unhealthy container detected: $container" "WARNING"
                
                $restartAttempts = 0
                $restored = $false
                
                while ($restartAttempts -lt $CONFIG.MAX_RESTART_ATTEMPTS) {
                    $restartAttempts++
                    Write-WatchdogLog "Restart attempt $restartAttempts for $container" "INFO"
                    
                    if (Restart-UnhealthyContainer $container) {
                        $restored = $true
                        break
                    }
                    
                    Start-Sleep -Seconds 5
                }
                
                if (-not $restored) {
                    Send-Alert "Container $container failed to recover after $($CONFIG.MAX_RESTART_ATTEMPTS) restart attempts" "CRITICAL"
                }
            }
        }
    } catch {
        Write-WatchdogLog "Watchdog error: $_" "ERROR"
        Send-Alert "Watchdog error: $_" "ERROR"
    }
    
    Start-Sleep -Seconds $CONFIG.DOCKER_CHECK_INTERVAL
}
