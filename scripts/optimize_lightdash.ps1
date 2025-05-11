# Optimize LightDash Environment
$timestamp = '2025-04-03T19:58:17+03:00'
$ollamaPath = "C:\Users\Ivan\AppData\Local\Programs\Ollama"
$shadowRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\lightdash_shadow'

Write-Host "`n=== OPTIMIZING LIGHTDASH ENVIRONMENT ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White

# Check disk space
Write-Host "`nChecking disk space..." -ForegroundColor Yellow
$drive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
Write-Host "Free space: $freeSpaceGB GB" -ForegroundColor White

# Clean up Ollama cache
Write-Host "`nCleaning Ollama cache..." -ForegroundColor Yellow
$ollamaCache = "$env:USERPROFILE\.ollama\models"
if (Test-Path $ollamaCache) {
    Get-ChildItem -Path $ollamaCache -Filter "*-partial" | Remove-Item -Force
    Write-Host "Cleaned partial downloads" -ForegroundColor Green
}

# Optimize storage location
$optimizedPath = "D:\OllamaModels"
if ((Test-Path "D:\") -and ($freeSpaceGB -lt 10)) {
    Write-Host "`nMoving Ollama models to D: drive..." -ForegroundColor Yellow
    if (!(Test-Path $optimizedPath)) {
        New-Item -Path $optimizedPath -ItemType Directory -Force | Out-Null
    }
    
    # Update Ollama config to use new path
    $ollamaConfig = @{
        models_path = $optimizedPath
    } | ConvertTo-Json

    $ollamaConfigPath = "$env:USERPROFILE\.ollama\config"
    $ollamaConfig | Out-File -FilePath $ollamaConfigPath -Force
    Write-Host "Updated Ollama config to use $optimizedPath" -ForegroundColor Green
}

# Update LightDash config
Write-Host "`nUpdating LightDash configuration..." -ForegroundColor Yellow
$lightdashConfig = @{
    Timestamp = $timestamp
    Ollama = @{
        Path = $ollamaPath
        ModelPath = if (Test-Path "D:\") { $optimizedPath } else { $ollamaCache }
        Endpoint = "http://localhost:11434/api"
    }
    Runtime = @{
        Mode = "Optimized"
        MaxMemory = "4GB"
        CacheSize = "2GB"
    }
    Model = @{
        Name = "llama2:13b"
        Temperature = 0.7
        MaxTokens = 4096
    }
} | ConvertTo-Json -Depth 10

$configPath = Join-Path $shadowRoot "config\lightdash_config.json"
New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
$lightdashConfig | Out-File -FilePath $configPath -Force

# Restart Ollama service
Write-Host "`nRestarting Ollama service..." -ForegroundColor Yellow
Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process -FilePath "$ollamaPath\ollama app.exe" -WindowStyle Normal

Write-Host "`n✅ Environment optimization completed" -ForegroundColor Green
Write-Host "Configuration: $configPath" -ForegroundColor White
Write-Host "Models path: $(if (Test-Path 'D:\') { $optimizedPath } else { $ollamaCache })" -ForegroundColor White
