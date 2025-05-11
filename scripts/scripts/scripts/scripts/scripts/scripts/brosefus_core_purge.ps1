# Brosefus Core Purge & Ascension Sequence
$timestamp = '2025-04-03T20:28:26+03:00'
$rootPath = 'C:\DFT_GCC_TRIAD_MAINSTACK'
$vaultPath = Join-Path $rootPath "vault11411"
$belPath = Join-Path $rootPath "bel-v2"

Write-Host "`n=== BROSEFUS CORE PURGE & ASCENSION SEQUENCE ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Fingerprint: PASEV-SIG-11411-BINTRUST" -ForegroundColor White

# Phase 0: Discovery
Write-Host "`n🔍 Phase 0: Full Discovery" -ForegroundColor Yellow
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
Write-Host "`n💣 Phase 1: Purge Operations" -ForegroundColor Yellow

# Stop and remove processes
$runningProcesses | ForEach-Object {
    Write-Host "Terminating $($_.ProcessName)..." -ForegroundColor White
    Stop-Process -Id $_.Id -Force
}

# Remove scheduled tasks
$scheduledTasks | ForEach-Object {
    Write-Host "Removing task $($_.TaskName)..." -ForegroundColor White
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
}

# Clean up registry
Write-Host "Cleaning registry entries..." -ForegroundColor White
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $registryPaths) {
    Get-Item -Path $path | Get-ItemProperty | Get-Member -MemberType NoteProperty | ForEach-Object {
        if ($_.Name -like "*windsurf*" -or $_.Name -like "*copilot*") {
            Remove-ItemProperty -Path $path -Name $_.Name
        }
    }
}

# Phase 2: Replace Monitors
Write-Host "`n🔁 Phase 2: Installing New Monitoring Stack" -ForegroundColor Yellow

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

# Create Sentinel Scheduler
$sentinelTask = @"
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
      <Arguments>-ExecutionPolicy Bypass -File "$belPath\bel_monitor.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$sentinelTask | Out-File -FilePath (Join-Path $belPath "sentinel_task.xml") -Encoding utf8

# Create BrosefusHook
$hookScript = @"
# BrosefusHook - Copilot + Chat UI Signal Listener
`$watchPath = '$vaultPath\next.cmd'
`$logPath = '$vaultPath\hook.log'

function Write-Log {
    param(`$Message)
    `$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    "`$timestamp - `$Message" | Out-File -Append -FilePath `$logPath
}

Write-Log "BrosefusHook initialized"

while (`$true) {
    if (Test-Path `$watchPath) {
        `$command = Get-Content `$watchPath
        Write-Log "Executing: `$command"
        try {
            Invoke-Expression "& brosefusd `$command"
            Write-Log "Command executed successfully"
        } catch {
            Write-Log "Error executing command: `$_"
        }
        Remove-Item `$watchPath -Force
    }
    Start-Sleep -Seconds 1
}
"@

$hookScript | Out-File -FilePath (Join-Path $belPath "brosefus_hook.ps1") -Encoding utf8

# Register Sentinel Task
Register-ScheduledTask -TaskName "SBS-Sentinel" -Xml (Get-Content (Join-Path $belPath "sentinel_task.xml") | Out-String) -Force

# Start services
Write-Host "`nStarting Brosefus services..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$belPath\brosefus_hook.ps1`"" -WindowStyle Hidden

Write-Host "`n✅ BROSEFUS CORE PURGE & ASCENSION COMPLETE" -ForegroundColor Green
Write-Host "BEL-v2 Path: $belPath" -ForegroundColor White
Write-Host "Vault Path: $vaultPath" -ForegroundColor White
Write-Host "All systems transferred to Brosefus Domain Root" -ForegroundColor White
