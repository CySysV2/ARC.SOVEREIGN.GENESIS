# LightDash Minimal Configuration
$timestamp = '2025-04-03T19:58:17+03:00'
$ollamaPath = "C:\Users\Ivan\AppData\Local\Programs\Ollama"
$shadowRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\lightdash_shadow'

Write-Host "`n=== LIGHTDASH MINIMAL MODE ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White

# Emergency cleanup
Write-Host "`nPerforming emergency cleanup..." -ForegroundColor Yellow

# Clean Windows temp
Write-Host "Cleaning Windows temp..." -ForegroundColor White
Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Ollama partials
Write-Host "Cleaning Ollama artifacts..." -ForegroundColor White
$ollamaCache = "$env:USERPROFILE\.ollama"
Get-ChildItem -Path $ollamaCache -Recurse -Filter "*-partial" | Remove-Item -Force -ErrorAction SilentlyContinue

# Switch to minimal model
Write-Host "`nSwitching to minimal configuration..." -ForegroundColor Yellow
$minimalConfig = @{
    Timestamp = $timestamp
    Ollama = @{
        Path = $ollamaPath
        ModelPath = "$env:USERPROFILE\.ollama\models"
        Endpoint = "http://localhost:11434/api"
    }
    Runtime = @{
        Mode = "Minimal"
        MaxMemory = "1GB"
        CacheSize = "512MB"
        Model = "llama2:7b-chat" # Smaller model
    }
    Security = @{
        LightSeal = $true
        QuantumThread = $true
        MinimalMode = $true
    }
} | ConvertTo-Json -Depth 10

$configPath = Join-Path $shadowRoot "config\lightdash_minimal.json"
New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
$minimalConfig | Out-File -FilePath $configPath -Force

# Restart Ollama in minimal mode
Write-Host "`nRestarting Ollama in minimal mode..." -ForegroundColor Yellow
Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process -FilePath "$ollamaPath\ollama app.exe" -WindowStyle Normal -ArgumentList "--memory-limit 1024"

Write-Host "`n✅ Minimal mode activated" -ForegroundColor Green
Write-Host "Using lightweight model: llama2:7b-chat" -ForegroundColor White
Write-Host "Memory limit: 1GB" -ForegroundColor White
Write-Host "Configuration: $configPath" -ForegroundColor White

# Create status file
$status = @{
    Timestamp = $timestamp
    Mode = "Minimal"
    Status = "Active"
    Model = "llama2:7b-chat"
    MemoryLimit = "1GB"
} | ConvertTo-Json

$statusPath = Join-Path $shadowRoot "status\minimal_mode.json"
New-Item -Path (Split-Path $statusPath) -ItemType Directory -Force | Out-Null
$status | Out-File -FilePath $statusPath -Force

Write-Host "`nStatus file: $statusPath" -ForegroundColor White
