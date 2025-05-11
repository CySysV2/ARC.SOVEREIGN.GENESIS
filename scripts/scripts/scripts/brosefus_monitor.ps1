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
