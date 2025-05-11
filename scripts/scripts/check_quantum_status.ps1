# Quantum Status Check
# Generated: 2025-04-29T14:15:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "QuantumStatusCheck"

# Import required modules
. "C:\FABRICA\scripts\quantum_harmonic_sync.ps1"

# Configuration paths
$configPath = "C:\FABRICA\quantum_sync_mode.json"
$logPath = "C:\FABRICA\logs\quantum_status.log"

# Function to get service status
function Get-QuantumServiceStatus {
    param (
        [string]$ServiceName
    )
    
    try {
        $process = Get-Process | Where-Object { $_.ProcessName -like "*${ServiceName}*" } -ErrorAction SilentlyContinue
        
        if ($process) {
            $cpu = try { $process.CPU } catch { 0 }
            $memory = try { [math]::Round($process.WorkingSet64 / 1MB, 2) } catch { 0 }
            $threads = try { $process.Threads.Count } catch { 0 }
            $startTime = try { $process.StartTime } catch { $null }
            
            return @{
                Status = "Running"
                CPU = $cpu
                Memory = $memory
                Threads = $threads
                StartTime = $startTime
                IsSynchronized = Test-HarmonicAlignment -ServiceName $ServiceName
            }
        }
        else {
            return @{
                Status = "Stopped"
                CPU = 0
                Memory = 0
                Threads = 0
                StartTime = $null
                IsSynchronized = $false
            }
        }
    }
    catch {
        return @{
            Status = "Error"
            CPU = 0
            Memory = 0
            Threads = 0
            StartTime = $null
            IsSynchronized = $false
            Error = $_.Exception.Message
        }
    }
}

# Function to display service status
function Show-QuantumServiceStatus {
    param (
        [string]$ServiceName,
        [hashtable]$Status
    )
    
    Write-Host "`nService: ${ServiceName}"
    Write-Host "-------------------"
    Write-Host "Status: $($Status.Status)"
    Write-Host "CPU Usage: $($Status.CPU)%"
    Write-Host "Memory Usage: $($Status.Memory) MB"
    Write-Host "Threads: $($Status.Threads)"
    if ($Status.StartTime) {
        Write-Host "Start Time: $($Status.StartTime)"
    }
    Write-Host "Synchronized: $($Status.IsSynchronized)"
    
    if ($Status.Error) {
        Write-Host "Error: $($Status.Error)" -ForegroundColor Red
    }
}

# Main status check process
try {
    Write-Host "`nQuantum Service Status Report"
    
    # Get system services
    $systemState = Get-SystemServices
    
    if (-not $systemState -or -not $systemState.QuantumServices) {
        Write-Host "No quantum services found in system state" -ForegroundColor Yellow
        exit 0
    }
    
    # Check each service
    foreach ($service in $systemState.QuantumServices.GetEnumerator()) {
        $serviceName = $service.Value.Name
        $status = Get-QuantumServiceStatus -ServiceName $serviceName
        Show-QuantumServiceStatus -ServiceName $serviceName -Status $status
    }
    
    # Show recent log entries
    Write-Host "`nRecent Log Entries:"
    if (Test-Path $logPath) {
        Get-Content $logPath -Tail 10 -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host $_
        }
    }
    else {
        Write-Host "No log file found at: $logPath" -ForegroundColor Yellow
    }
    
    Write-Host "`nStatus check complete. For detailed metrics, see: $configPath"
}
catch {
    Write-Host "Error checking quantum service status: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 