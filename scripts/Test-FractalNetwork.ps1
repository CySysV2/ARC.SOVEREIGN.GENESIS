$hostname = $env:COMPUTERNAME
$logPath = "C:\DFT_GCC_TRIAD_MAINSTACK\vaults\logs\fractal_net_diag_$hostname.log"
New-Item -ItemType Directory -Force -Path (Split-Path $logPath) | Out-Null
"`n================= FRACTAL NETWORK DIAGNOSTICS [$hostname] =================" | Out-File $logPath

"`n[SYSTEM] System Information:" | Out-File $logPath -Append
systeminfo | Out-File $logPath -Append

"`n[NET] Network Interface Info:" | Out-File $logPath -Append
ipconfig /all | Out-File $logPath -Append

"`n[ROUTE] Route to Google DNS (8.8.8.8):" | Out-File $logPath -Append
tracert 8.8.8.8 | Out-File $logPath -Append

"`n[DNS] DNS Resolution Tests:" | Out-File $logPath -Append
nslookup google.com | Out-File $logPath -Append
nslookup github.com | Out-File $logPath -Append
nslookup openai.com | Out-File $logPath -Append
nslookup huggingface.co | Out-File $logPath -Append

"`n[PING] Connectivity Tests:" | Out-File $logPath -Append
ping -n 3 8.8.8.8 | Out-File $logPath -Append
ping -n 3 github.com | Out-File $logPath -Append
ping -n 3 huggingface.co | Out-File $logPath -Append

"`n[SOCKETS] Active Sockets (Port 443):" | Out-File $logPath -Append
netstat -ano | findstr :443 | Out-File $logPath -Append

"`n[TLS] TLS Handshake Test (curl to GPT relay):" | Out-File $logPath -Append
curl.exe -v https://35.223.238.178 2>&1 | Out-File $logPath -Append

"`n[LOCAL] Local Network Check:" | Out-File $logPath -Append
ping -n 3 192.168.1.1 | Out-File $logPath -Append
arp -a | Out-File $logPath -Append

"`n[COMPLETE] Log saved to: $logPath" | Out-File $logPath -Append
Write-Host "`n[SUCCESS] [$hostname] Fractal Network Diagnostics Complete. Log: $logPath"
