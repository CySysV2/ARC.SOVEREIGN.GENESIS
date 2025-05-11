param(
    [Parameter(Mandatory=$true)]
    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Configuration
$CONFIG = @{
    IPFS_API = "http://localhost:5001"
    REDIS_URL = "redis://localhost:6379"
    REPORT_DIR = "C:\FABRICA\reports"
}

# Initialize logging
$LogPath = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\logs\ipfs"
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

$LogFile = Join-Path $LogPath "ipfs_push_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

function Get-RedisKey {
    param([string]$Key)
    
    try {
        $value = docker exec genesis-redis redis-cli get $Key
        return $value
    } catch {
        Write-Log ("Redis error getting key {0}: {1}" -f $Key, $_.Exception.Message)
        throw
    }
}

function Initialize-IPFS {
    Write-Log "Checking IPFS daemon..."
    $ipfsContainer = docker ps -q -f name=ipfs
    if (-not $ipfsContainer) {
        Write-Log "Starting IPFS container..."
        docker run -d --name ipfs -v C:\FABRICA\reports:/reports -p 4001:4001 -p 5001:5001 -p 8080:8080 ipfs/kubo:latest
        Write-Log "Waiting for IPFS daemon to initialize..."
        Start-Sleep -Seconds 15
        
        try {
            docker exec ipfs ipfs init
            Start-Sleep -Seconds 5
        } catch {
            Write-Log ("IPFS init error: {0}" -f $_.Exception.Message)
        }
    }
}

function Push-ToIPFS {
    param([string]$FilePath)
    
    $maxRetries = 3
    $retryCount = 0
    $ipfsHash = $null
    $fileName = Split-Path $FilePath -Leaf
    
    do {
        try {
            $ipfsHash = docker exec ipfs ipfs add -Q "/reports/$fileName"
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Log "Retrying IPFS push (attempt $($retryCount + 1) of $maxRetries)..."
                Start-Sleep -Seconds 5
            }
        }
    } while (-not $ipfsHash -and $retryCount -lt $maxRetries)
    
    if (-not $ipfsHash) {
        throw "Failed to get IPFS hash after $maxRetries attempts"
    }
    
    return $ipfsHash
}

try {
    Write-Log "Starting Codex Stack IPFS Push - ReportPath: $ReportPath"
    
    # Create reports directory if it doesn't exist
    if (-not (Test-Path $CONFIG.REPORT_DIR)) {
        Write-Log "Creating reports directory..."
        New-Item -ItemType Directory -Path $CONFIG.REPORT_DIR -Force | Out-Null
    }
    
    # Generate Codex Stack snapshot
    Write-Log "Generating Codex Stack snapshot..."
    $snapshot = @{
        timestamp = [DateTime]::UtcNow.ToString('o')
        codex_state = Get-RedisKey "fns:codex:state" | ConvertFrom-Json
        bridge_state = Get-RedisKey "quantum:bridge:state" | ConvertFrom-Json
        domains = @{}
    }
    
    # Get domain states
    $domains = @(
        "digital-fabrica.com",
        "cy-systems.com",
        "yellowchain.net",
        "cy-sys.org",
        "yellowchain.org",
        "citizen.solar"
    )
    
    foreach ($domain in $domains) {
        $domainKey = "fns:domain:$($domain -replace '\.', '_')"
        $domainState = Get-RedisKey $domainKey
        if ($domainState) {
            $snapshot.domains[$domain] = $domainState | ConvertFrom-Json
        }
    }
    
    # Save snapshot to file
    $snapshotFile = Join-Path $CONFIG.REPORT_DIR "codex_stack_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $snapshot | ConvertTo-Json -Depth 10 | Set-Content $snapshotFile
    Write-Log "Snapshot saved to: $snapshotFile"
    
    # Initialize IPFS and push snapshot
    Initialize-IPFS
    $ipfsHash = Push-ToIPFS -FilePath $snapshotFile
    
    Write-Log "Codex Stack snapshot pushed to IPFS successfully"
    Write-Log "IPFS Hash: $ipfsHash"
    Write-Log "Snapshot File: $snapshotFile"
} catch {
    Write-Log "Error during IPFS push: $_"
    throw
}
