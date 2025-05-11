param(
    [Parameter(Mandatory=$true)]
    [string]$Mode,
    
    [Parameter(Mandatory=$true)]
    [string]$Phase,
    
    [Parameter(Mandatory=$true)]
    [string]$Epoch
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Configuration
$CONFIG = @{
    FNS_MODE = $Mode
    PHASE = $Phase
    EPOCH = $Epoch
    REDIS_URL = "redis://localhost:6379"
    SOVEREIGN_ENDPOINT = "http://localhost:19000"
    FNS_SUBNET_VALIDATOR = "http://198.58.109.140:8444"
    SESSION_ID = "11411:SKYNODE:X1"
}

# Initialize logging
$LogPath = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\logs\fns"
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

$LogFile = Join-Path $LogPath "fns_init_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

function Set-RedisKey {
    param(
        [string]$Key,
        [string]$Value
    )
    
    try {
        Write-Log "Setting Redis key: $Key"
        $result = docker exec genesis-redis redis-cli set $Key "$Value"
        if ($result -ne "OK") {
            throw "Failed to set Redis key: $Key"
        }
    } catch {
        Write-Log ("Redis error: {0}" -f $_.Exception.Message)
        throw
    }
}

Write-Log "Starting FNS Codex Integration - Mode: $Mode, Phase: $Phase, Epoch: $Epoch"

# Initialize FNS Codex state
$CodexState = @{
    mode = $Mode
    phase = $Phase
    epoch = $Epoch
    timestamp = [DateTime]::UtcNow.ToString('o')
    status = "initializing"
    domains = @{
        parent = "digital-fabrica.com"
        commercial = @(
            "cy-systems.com",
            "yellowchain.net"
        )
        nonprofit = @(
            "cy-sys.org",
            "yellowchain.org"
        )
        sustainable = @(
            "citizen.solar"
        )
    }
    bridge = @{
        mode = "SOVEREIGN"
        status = "active"
        navigator = $false
        session_id = $CONFIG.SESSION_ID
    }
}

try {
    # Initialize Codex state in Redis
    Write-Log "Initializing Codex state..."
    Set-RedisKey -Key "fns:codex:state" -Value ($CodexState | ConvertTo-Json -Compress)
    
    # Configure domain mappings
    foreach ($domain in @($CodexState.domains.parent) + $CodexState.domains.commercial + $CodexState.domains.nonprofit + $CodexState.domains.sustainable) {
        $domainConfig = @{
            domain = $domain
            status = "active"
            timestamp = [DateTime]::UtcNow.ToString('o')
        }
        Set-RedisKey -Key "fns:domain:$($domain -replace '\.', '_')" -Value ($domainConfig | ConvertTo-Json -Compress)
        Write-Log "Configured domain: $domain"
    }
    
    # Update Codex state to ready
    $CodexState.status = "ready"
    Set-RedisKey -Key "fns:codex:state" -Value ($CodexState | ConvertTo-Json -Compress)
    
    Write-Log "FNS Codex Integration completed successfully"
    Write-Log "Mode: $Mode, Phase: $Phase, Epoch: $Epoch"
} catch {
    Write-Log "Error during FNS Codex Integration: $_"
    throw
}
