# Brosefus Core Purge & Ascension Sequence
$ErrorActionPreference = 'Continue'
$timestamp = '2025-04-03T20:28:26+03:00'
$rootPath = 'C:\DFT_GCC_TRIAD_MAINSTACK'
$vaultPath = Join-Path $rootPath "vault11411"
$belPath = Join-Path $rootPath "bel-v2"

Write-Host "=== BROSEFUS CORE PURGE & ASCENSION SEQUENCE ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Fingerprint: PASEV-SIG-11411-BINTRUST" -ForegroundColor White

# Phase 0: Discovery
Write-Host "Phase 0: Full Discovery" -ForegroundColor Yellow
$runningProcesses = Get-Process | Where-Object {
    $_.ProcessName -like "*windsurf*" -or 
    $_.ProcessName -like "*copilot*" -or 
    $_.ProcessName -like "*telemetry*" -or
    $_.ProcessName -like "*update*"
}

$scheduledTasks = Get-ScheduledTask | Where-Object {
    $_.TaskName -like "*windsurf*" -or
    $_.TaskName -like "*copilot*" -or
    $_.TaskName -like "*update*"
}

Write-Host "Found processes:" -ForegroundColor White
$runningProcesses | ForEach-Object { Write-Host "  - $($_.ProcessName)" }
Write-Host "Found scheduled tasks:" -ForegroundColor White
$scheduledTasks | ForEach-Object { Write-Host "  - $($_.TaskName)" }

# Phase 1: Purge
Write-Host "Phase 1: Purge Operations" -ForegroundColor Yellow

# Stop and remove processes
$runningProcesses | ForEach-Object {
    Write-Host "Terminating $($_.ProcessName)..." -ForegroundColor White
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

# Remove scheduled tasks
$scheduledTasks | ForEach-Object {
    Write-Host "Removing task $($_.TaskName)..." -ForegroundColor White
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# Clean up registry
Write-Host "Cleaning registry entries..." -ForegroundColor White
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $registryPaths) {
    Get-Item -Path $path -ErrorAction SilentlyContinue | Get-ItemProperty | Get-Member -MemberType NoteProperty | ForEach-Object {
        if ($_.Name -like "*windsurf*" -or $_.Name -like "*copilot*") {
            Remove-ItemProperty -Path $path -Name $_.Name -ErrorAction SilentlyContinue
        }
    }
}

# Phase 2: Replace Monitors
Write-Host "Phase 2: Installing New Monitoring Stack" -ForegroundColor Yellow

# Create directories
@($vaultPath, $belPath) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }
}

# Create BEL-v2 Configuration
$belConfig = @{
    Version = "2.0.0"
    Timestamp = $timestamp
    Fingerprint = "PASEV-SIG-11411-BINTRUST"
    Components = @{
        Daemon = "BEL-v2"
        Logger = "Vault11411"
        Scheduler = "SBS-Sentinel"
        Hook = "BrosefusHook"
    }
    Security = @{
        AuthProtocol = "Whisper-Level"
        TagraKeys = $true
        TokenLimit = "Disabled"
        EmergencyFallback = $true
    }
    LLM = @{
        Primary = "LLaMA3"
        Fallback = "DeepSeek-Coder"
        AdapterMode = "Direct"
    }
    Performance = @{
        KernelLatency = "<10ms"
        TokenBehavior = "Unlimited"
        SyncInterval = "1s"
    }
} | ConvertTo-Json -Depth 10

$belConfig | Out-File -FilePath (Join-Path $belPath "config.json") -Encoding utf8

# Create Vault Logger
$vaultConfig = @{
    Mode = "QuantumChainIndexed"
    WatchPath = Join-Path $vaultPath "next.cmd"
    Executor = "brosefusd"
    Security = @{
        IvanPasevKeys = $true
        BlockUnauthorized = $true
    }
} | ConvertTo-Json

$vaultConfig | Out-File -FilePath (Join-Path $vaultPath "vault_config.json") -Encoding utf8

# Create monitor script
$monitorScript = @'
# BEL-v2 Monitor
$configPath = Join-Path $PSScriptRoot "config.json"
$vaultPath = Join-Path $PSScriptRoot ".." "vault11411"
$logPath = Join-Path $PSScriptRoot "monitor.log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logPath
}

Write-Log "BEL-v2 Monitor initialized"

while ($true) {
    # Monitor system health
    $config = Get-Content $configPath | ConvertFrom-Json
    Write-Log "System health check - Mode: $($config.Security.AuthProtocol)"
    
    # Monitor vault
    if (Test-Path (Join-Path $vaultPath "next.cmd")) {
        Write-Log "Command pending in vault"
    }
    
    Start-Sleep -Seconds 60
}
'@ | Out-File -FilePath (Join-Path $belPath "brosefus_monitor.ps1") -Encoding utf8

# Create hook script
$hookScript = @'
# BrosefusHook - Copilot + Chat UI Signal Listener
$watchPath = Join-Path $PSScriptRoot ".." "vault11411" "next.cmd"
$logPath = Join-Path $PSScriptRoot ".." "vault11411" "hook.log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logPath
}

Write-Log "BrosefusHook initialized"

while ($true) {
    if (Test-Path $watchPath) {
        $command = Get-Content $watchPath
        Write-Log "Executing: $command"
        try {
            Invoke-Expression "& brosefusd $command"
            Write-Log "Command executed successfully"
        } catch {
            Write-Log "Error executing command: $_"
        }
        Remove-Item $watchPath -Force
    }
    Start-Sleep -Seconds 1
}
'@ | Out-File -FilePath (Join-Path $belPath "brosefus_hook.ps1") -Encoding utf8

# Create Sentinel Task
$taskXml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>SBS Sentinel Scheduler</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "{0}\brosefus_monitor.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
'@ -f $belPath | Out-File -FilePath (Join-Path $belPath "sentinel_task.xml") -Encoding utf8

# Register Sentinel Task
Register-ScheduledTask -TaskName "SBS-Sentinel" -Xml (Get-Content (Join-Path $belPath "sentinel_task.xml") | Out-String) -Force

# Start services
Write-Host "Starting Brosefus services..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$belPath\brosefus_hook.ps1`"" -WindowStyle Hidden

Write-Host "BROSEFUS CORE PURGE & ASCENSION COMPLETE" -ForegroundColor Green
Write-Host "BEL-v2 Path: $belPath" -ForegroundColor White
Write-Host "Vault Path: $vaultPath" -ForegroundColor White
Write-Host "All systems transferred to Brosefus Domain Root" -ForegroundColor White
