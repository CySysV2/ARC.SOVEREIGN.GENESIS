# Quantum Process Manager
# Generated: 2025-04-29T17:00:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumProcessManager"

# Import required modules
. "C:\FABRICA\scripts\quantum_system_manager.ps1"

# Configuration
$config = @{
    MaxProcesses = 10
    ProcessTimeout = 30  # seconds
    CheckInterval = 5    # seconds
    LogPath = "C:\FABRICA\logs\process_manager.log"
}

# Function to get current process count
function Get-CurrentProcessCount {
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*Quantum*" -or $_.ProcessName -like "*FABRICA*" }
    return $processes.Count
}

# Function to check process health
function Test-ProcessHealth {
    param (
        [System.Diagnostics.Process]$Process
    )
    
    try {
        if (-not $Process.HasExited) {
            $cpu = try { $Process.CPU } catch { 0 }
            $memory = try { $Process.WorkingSet64 / 1MB } catch { 0 }
            
            if ($cpu -gt 80 -or $memory -gt 1000) {
                Write-Host "Process $($Process.Id) is using excessive resources (CPU: ${cpu}%, Memory: ${memory}MB)" -ForegroundColor Yellow
                return $false
            }
            return $true
        }
        return $false
    }
    catch {
        Write-Host "Error checking process health: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to start service with process management
function Start-ManagedService {
    param (
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    try {
        # Check current process count
        $currentCount = Get-CurrentProcessCount
        if ($currentCount -ge $config.MaxProcesses) {
            Write-Host "Maximum process limit reached ($($config.MaxProcesses)). Waiting for available slot..." -ForegroundColor Yellow
            Start-Sleep -Seconds $config.CheckInterval
            return $false
        }
        
        # Start service
        $process = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ServicePath`"" -PassThru
        
        # Wait for process to initialize
        $startTime = Get-Date
        while (-not $process.HasExited -and ((Get-Date) - $startTime).TotalSeconds -lt $config.ProcessTimeout) {
            if (Test-ProcessHealth -Process $process) {
                Write-Host "Service ${ServiceName} started successfully (PID: $($process.Id))" -ForegroundColor Green
                return $true
            }
            Start-Sleep -Seconds 1
        }
        
        if (-not $process.HasExited) {
            Write-Host "Service ${ServiceName} initialization timeout" -ForegroundColor Yellow
            Stop-Process -Id $process.Id -Force
        }
        return $false
    }
    catch {
        Write-Host "Error starting service ${ServiceName}: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to monitor and manage processes
function Monitor-Processes {
    while ($true) {
        try {
            $processes = Get-Process | Where-Object { $_.ProcessName -like "*Quantum*" -or $_.ProcessName -like "*FABRICA*" }
            
            foreach ($process in $processes) {
                if (-not (Test-ProcessHealth -Process $process)) {
                    Write-Host "Terminating unhealthy process $($process.Id)" -ForegroundColor Red
                    Stop-Process -Id $process.Id -Force
                }
            }
            
            Start-Sleep -Seconds $config.CheckInterval
        }
        catch {
            Write-Host "Error in process monitoring: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Main process management
try {
    Write-Host "Starting Quantum Process Manager"
    
    # Start process monitoring in background
    $monitorJob = Start-Job -ScriptBlock { & "C:\FABRICA\scripts\quantum_process_manager.ps1" -MonitorOnly }
    
    # Get system services
    $systemState = Get-SystemServices
    
    # Start services with process management
    foreach ($service in $systemState.QuantumServices.GetEnumerator()) {
        $serviceName = $service.Value.Name
        $servicePath = $service.Value.Path
        
        if (Test-Path $servicePath) {
            $success = Start-ManagedService -ServiceName $serviceName -ServicePath $servicePath
            if (-not $success) {
                Write-Host "Failed to start ${ServiceName}" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Service path not found: ${servicePath}" -ForegroundColor Red
        }
    }
    
    # Keep the script running to maintain process management
    while ($true) {
        Start-Sleep -Seconds $config.CheckInterval
    }
}
catch {
    Write-Host "Quantum Process Manager failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if ($monitorJob) {
        Stop-Job -Job $monitorJob
        Remove-Job -Job $monitorJob
    }
} 