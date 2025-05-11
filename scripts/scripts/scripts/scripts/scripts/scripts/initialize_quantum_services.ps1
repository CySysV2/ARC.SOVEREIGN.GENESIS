# Initialize Quantum Services
# Generated: 2024-03-19
# Commander: Ivan Pasev 11411

# Service configurations
$services = @(
    @{
        Name        = "quantum_harmonic_monitor"
        DisplayName = "Quantum Harmonic Monitor Service"
        Description = "Monitors quantum harmonic synchronization and stability"
        BinaryPath  = "C:\FABRICA\bin\quantum_harmonic_monitor.exe"
        StartType   = "Automatic"
    },
    @{
        Name        = "quantum_sync_service"
        DisplayName = "Quantum Sync Service"
        Description = "Manages quantum synchronization processes"
        BinaryPath  = "C:\FABRICA\bin\quantum_sync_service.exe"
        StartType   = "Automatic"
    },
    @{
        Name        = "quantum_monitor_service"
        DisplayName = "Quantum Monitor Service"
        Description = "Monitors quantum state and metrics"
        BinaryPath  = "C:\FABRICA\bin\quantum_monitor_service.exe"
        StartType   = "Automatic"
    }
)

# Create service binaries directory
$binPath = "C:\FABRICA\bin"
if (-not (Test-Path $binPath)) {
    New-Item -ItemType Directory -Force -Path $binPath | Out-Null
    Write-Host "Created directory: $binPath"
}

# Create service placeholder executables
foreach ($service in $services) {
    $servicePath = $service.BinaryPath
    if (-not (Test-Path $servicePath)) {
        # Create a service wrapper script
        $wrapperScript = @"
# Quantum Service Wrapper
# Generated: 2024-03-19
# Commander: Ivan Pasev 11411

`$scriptPath = Join-Path `$PSScriptRoot "quantum_service_template.ps1"
`$serviceName = "$($service.Name)"

# Start the service script
& `$scriptPath -ServiceName `$serviceName
"@
        $wrapperScript | Out-File -FilePath $servicePath -Encoding UTF8
        Write-Host "Created service wrapper: $servicePath"
    }
}

# Register and start services
foreach ($service in $services) {
    try {
        $existingService = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
        
        if ($existingService) {
            Write-Host "Service $($service.Name) already exists"
            if ($existingService.Status -ne "Running") {
                Start-Service -Name $service.Name
                Write-Host "Started service: $($service.Name)"
            }
        }
        else {
            # Create new service
            New-Service -Name $service.Name `
                -DisplayName $service.DisplayName `
                -Description $service.Description `
                -BinaryPathName "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($service.BinaryPath)`"" `
                -StartupType $service.StartType
            
            Write-Host "Created service: $($service.Name)"
            Start-Service -Name $service.Name
            Write-Host "Started service: $($service.Name)"
        }
    }
    catch {
        Write-Error "Failed to initialize service $($service.Name): $_"
        continue
    }
}

Write-Host "Quantum services initialization completed" 