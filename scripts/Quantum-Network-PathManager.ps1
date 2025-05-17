# Quantum-Network-PathManager.ps1
# Manages quantum network paths and synchronization between nodes
using namespace System.Collections.Generic

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ROOT_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK"
$LOG_PATH = "$ROOT_PATH\Logs\Network_PathManager_$TIMESTAMP.log"

# Initialize logging
New-Item -ItemType Directory -Force -Path (Split-Path $LOG_PATH) | Out-Null

function Write-QuantumLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logMessage = "[$timestamp][$Level] $Message"
    Add-Content -Path $LOG_PATH -Value $logMessage
    Write-Host $logMessage -ForegroundColor $(switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "INFO"  { "Cyan" }
        default { "White" }
    })
}

# Network configuration
$NETWORK_CONFIG = @{
    Nodes = @(
        @{
            Name = "Node0"
            NetworkPath = "\\Node0\DFT_GCC_TRIAD_MAINSTACK"
            LocalMount = "C:\DFT_GCC_TRIAD_MAINSTACK\Node0_mount"
            IpfsPath = "C:\DFT_GCC_TRIAD_MAINSTACK\IPFS_TEMP_SYNC\Node0"
            Required = $true
        },
        @{
            Name = "C-Station"
            NetworkPath = "\\C-STATION\DFT_GCC_TRIAD_MAINSTACK"
            LocalMount = "C:\DFT_GCC_TRIAD_MAINSTACK\C-STATION_mount"
            IpfsPath = "C:\DFT_GCC_TRIAD_MAINSTACK\IPFS_TEMP_SYNC\C-Station"
            Required = $true
        }
    )
    SyncPaths = @(
        "Quantum",
        "Harmonic",
        "Bridge",
        "state_sync",
        "logs"
    )
}

# Create all required directories
foreach ($node in $NETWORK_CONFIG.Nodes) {
    @($node.LocalMount, $node.IpfsPath) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-QuantumLog "Created directory: $_"
        }
    }
    
    # Create sync subdirectories
    foreach ($syncPath in $NETWORK_CONFIG.SyncPaths) {
        @("$($node.LocalMount)\$syncPath", "$($node.IpfsPath)\$syncPath") | ForEach-Object {
            if (!(Test-Path $_)) {
                New-Item -ItemType Directory -Path $_ -Force | Out-Null
                Write-QuantumLog "Created sync directory: $_"
            }
        }
    }
}

# Test network connectivity
function Test-NodeConnectivity {
    param([string]$NodePath)
    
    try {
        if (Test-Path $NodePath) {
            # Try to write a test file
            $testFile = Join-Path $NodePath "test_$TIMESTAMP.txt"
            Set-Content -Path $testFile -Value "Network test at $TIMESTAMP" -ErrorAction Stop
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            return $true
        }
    }
    catch {
        Write-QuantumLog "Connectivity test failed for ${NodePath}: $($_.Exception.Message)" -Level "WARN"
    }
    return $false
}

# Initialize network paths
function Initialize-NetworkPaths {
    Write-QuantumLog "🔄 Initializing network paths..."
    
    foreach ($node in $NETWORK_CONFIG.Nodes) {
        # Test network connectivity
        $networkAvailable = Test-NodeConnectivity $node.NetworkPath
        
        if ($networkAvailable) {
            Write-QuantumLog "✅ Direct network path available for $($node.Name)"
            
            # Create required directories on network path
            foreach ($syncPath in $NETWORK_CONFIG.SyncPaths) {
                $targetPath = Join-Path $node.NetworkPath $syncPath
                if (!(Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                    Write-QuantumLog "Created network directory: $targetPath"
                }
            }
        }
        else {
            Write-QuantumLog "⚠️ Using local mount for $($node.Name)" -Level "WARN"
            
            # Initialize local mount structure
            foreach ($syncPath in $NETWORK_CONFIG.SyncPaths) {
                $targetPath = Join-Path $node.LocalMount $syncPath
                if (!(Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                    Write-QuantumLog "Created local mount directory: $targetPath"
                }
            }
        }
    }
}

# Sync quantum state
function Sync-QuantumState {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$NodeName
    )
    
    Write-QuantumLog "🔄 Syncing quantum state for $NodeName..."
    
    foreach ($syncPath in $NETWORK_CONFIG.SyncPaths) {
        $source = Join-Path $SourcePath $syncPath
        $target = Join-Path $TargetPath $syncPath
        
        if (Test-Path $source) {
            try {
                # Create target directory if it doesn't exist
                if (!(Test-Path $target)) {
                    New-Item -ItemType Directory -Path $target -Force | Out-Null
                }
                
                # Copy files
                Copy-Item "$source\*" $target -Recurse -Force
                Write-QuantumLog "✅ Synced ${syncPath} for ${NodeName}"
            }
            catch {
                Write-QuantumLog "❌ Failed to sync ${syncPath} for ${NodeName}: $($_.Exception.Message)" -Level "ERROR"
                throw $_
            }
        }
    }
}

# IPFS fallback sync
function Sync-ViaIpfs {
    param([string]$NodeName)
    
    Write-QuantumLog "📦 Performing IPFS fallback sync for $NodeName..."
    $node = $NETWORK_CONFIG.Nodes | Where-Object { $_.Name -eq $NodeName }
    
    if (!$node) {
        throw "Node configuration not found for $NodeName"
    }
    
    $snapshot = @{
        timestamp = $TIMESTAMP
        node = $NodeName
        sync_paths = @{}
    }
    
    foreach ($syncPath in $NETWORK_CONFIG.SyncPaths) {
        $sourcePath = Join-Path $ROOT_PATH $syncPath
        if (Test-Path $sourcePath) {
            $snapshot.sync_paths[$syncPath] = Get-ChildItem $sourcePath -Recurse |
                Select-Object FullName, Length, LastWriteTime
        }
    }
    
    $snapshotPath = Join-Path $node.IpfsPath "snapshot_$TIMESTAMP.json"
    $snapshot | ConvertTo-Json -Depth 10 | Set-Content $snapshotPath
    Write-QuantumLog "✅ Created IPFS snapshot for $NodeName"
}

# Main execution
try {
    Write-QuantumLog "🚀 Starting Quantum Network Path Manager..."
    
    # Initialize network paths
    Initialize-NetworkPaths
    
    foreach ($node in $NETWORK_CONFIG.Nodes) {
        # Try direct network path first
        if (Test-NodeConnectivity $node.NetworkPath) {
            Sync-QuantumState -SourcePath $ROOT_PATH -TargetPath $node.NetworkPath -NodeName $node.Name
        }
        # Try local mount
        elseif (Test-Path $node.LocalMount) {
            Sync-QuantumState -SourcePath $ROOT_PATH -TargetPath $node.LocalMount -NodeName $node.Name
            Write-QuantumLog "✅ Synced to local mount for $($node.Name)"
        }
        # Fall back to IPFS
        else {
            Sync-ViaIpfs -NodeName $node.Name
            Write-QuantumLog "✅ Created IPFS snapshot for $($node.Name)"
        }
    }
    
    Write-QuantumLog "✨ Network path management complete"
}
catch {
    Write-QuantumLog "Critical error: $($_.Exception.Message)" -Level "ERROR"
    throw $_
}
finally {
    Write-QuantumLog "📝 Logs written to: $LOG_PATH"
}
