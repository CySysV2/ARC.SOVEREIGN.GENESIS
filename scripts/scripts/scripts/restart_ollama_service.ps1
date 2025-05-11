# Restart Ollama Service with correct paths
$timestamp = '2025-04-03T19:58:17+03:00'
$ollamaPath = "C:\Users\Ivan\AppData\Local\Programs\Ollama"
$ollamaApp = Join-Path $ollamaPath "ollama app.exe"
$shadowRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\lightdash_shadow'

Write-Host "`n=== RESTARTING OLLAMA SERVICE ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Ollama Path: $ollamaPath" -ForegroundColor White

# Stop existing Ollama processes
Write-Host "`nStopping existing Ollama processes..." -ForegroundColor Yellow
Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Stop-Process -Force

# Start Ollama app
Write-Host "`nStarting Ollama app..." -ForegroundColor Yellow
Start-Process -FilePath $ollamaApp -WindowStyle Normal

# Wait for service to initialize
Write-Host "Waiting for Ollama service to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Pull Llama model
Write-Host "`nPulling Llama model..." -ForegroundColor Yellow
& "$ollamaPath\ollama.exe" pull llama2:13b

# Update configuration
$configPath = Join-Path $shadowRoot "config\shadow_config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$config.LLM.OllamaPath = $ollamaPath
$config | ConvertTo-Json -Depth 10 | Out-File $configPath -Force

Write-Host "`n✅ Ollama service restarted successfully" -ForegroundColor Green
Write-Host "Model: llama2:13b" -ForegroundColor White
Write-Host "Endpoint: http://localhost:11434/api" -ForegroundColor White
Write-Host "Configuration updated: $configPath" -ForegroundColor White
