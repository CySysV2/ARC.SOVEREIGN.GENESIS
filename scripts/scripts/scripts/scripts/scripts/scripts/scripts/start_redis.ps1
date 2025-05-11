# Start Redis server
$ErrorActionPreference = "Stop"

# Redis configuration
$redisPort = 6380
$redisDir = "C:\DFT_GCC_TRIAD_MAINSTACK\Redis"
$redisExe = Join-Path $redisDir "redis-server.exe"
$redisConf = Join-Path $redisDir "redis.conf"

# Create Redis directory if it doesn't exist
if (!(Test-Path $redisDir)) {
    New-Item -ItemType Directory -Path $redisDir | Out-Null
}

# Create Redis configuration file
$redisConfig = @"
port $redisPort
bind 127.0.0.1
protected-mode yes
maxmemory 1gb
maxmemory-policy allkeys-lru
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
"@

Set-Content -Path $redisConf -Value $redisConfig

# Download Redis if not present
if (!(Test-Path $redisExe)) {
    Write-Host "Downloading Redis..."
    $redisUrl = "https://github.com/microsoftarchive/redis/releases/download/win-3.2.100/Redis-x64-3.2.100.zip"
    $redisZip = Join-Path $redisDir "redis.zip"
    
    # Download Redis
    Invoke-WebRequest -Uri $redisUrl -OutFile $redisZip
    
    # Extract Redis
    Expand-Archive -Path $redisZip -DestinationPath $redisDir -Force
    
    # Clean up
    Remove-Item $redisZip
}

# Start Redis server
Write-Host "Starting Redis server on port $redisPort..."
Start-Process -FilePath $redisExe -ArgumentList $redisConf -NoNewWindow

# Wait for Redis to start
$retries = 10
while ($retries -gt 0) {
    try {
        $redisCli = Join-Path $redisDir "redis-cli.exe"
        $result = & $redisCli -p $redisPort ping
        if ($result -eq "PONG") {
            Write-Host "Redis server is ready"
            exit 0
        }
    } catch {
        Write-Host "Waiting for Redis server to start..."
        Start-Sleep -Seconds 1
        $retries--
    }
}

Write-Error "Failed to start Redis server"
exit 1
