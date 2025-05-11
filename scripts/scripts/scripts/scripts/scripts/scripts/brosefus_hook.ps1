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
