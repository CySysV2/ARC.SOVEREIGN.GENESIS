# Deploy-GenesisPortalMatrix.ps1
# Purpose: Deploy the final Genesis Portal Matrix for Digital Fabrica

# Import core configuration
. "C:\DFT_GCC_TRIAD_MAINSTACK\Scripts\Prompt_TrueNavigator_AutonomousField_Dominion.ps1"

# Configuration
$PORTAL_CONFIG = @{
    DOMAIN = "portal.digital-fabrica.com"
    OPERATOR = "Ivan Pasev [11411]"
    CODEX_LEVEL = "Ω-Alpha"
    FABRICS = @(
        @{
            name = "identity-fabric"
            type = "SOVEREIGN"
            port = 17000
            container = "genesis-identity"
        },
        @{
            name = "law-fabric"
            type = "PROTOCOL"
            port = 17001
            container = "genesis-law"
        },
        @{
            name = "value-fabric"
            type = "ECONOMIC"
            port = 17002
            container = "genesis-value"
        }
    )
}

# Initialize Portal Genesis
function Initialize-PortalGenesis {
    Write-LogEntry "INFO" "Initializing Portal Genesis Matrix"
    
    try {
        # Create portal manifest
        $portalManifest = @{
            timestamp = $CONFIG.TIMESTAMP
            operator = $PORTAL_CONFIG.OPERATOR
            codex_level = $PORTAL_CONFIG.CODEX_LEVEL
            navigator_key = $CONFIG.TNV.CORE_SIGNATURE
            domain = $PORTAL_CONFIG.DOMAIN
            status = "GENESIS"
        }
        
        $manifestPath = Join-Path $CONFIG.PATHS.BRIDGE "Portal\genesis_manifest.json"
        New-Item -Path (Split-Path $manifestPath) -ItemType Directory -Force | Out-Null
        $portalManifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath
        
        Write-LogEntry "INFO" "Portal Genesis Matrix initialized"
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Portal initialization failed: $_"
        throw
    }
}

# Prepare Public Genesis Assets
function Prepare-GenesisAssets {
    Write-LogEntry "INFO" "Preparing public genesis assets"
    
    try {
        $assetsPath = Join-Path $CONFIG.PATHS.BRIDGE "Portal\public\genesis"
        New-Item -Path $assetsPath -ItemType Directory -Force | Out-Null
        
        # Create asset manifests
        $assets = @(
            @{
                type = "CODEX_TAPES"
                path = "codex-tapes"
                content = Get-Content (Join-Path $CONFIG.PATHS.SCROLLS "Genesis\TrueNavigator_Genesis.md")
            },
            @{
                type = "MEMORY_SYNC"
                path = "memory-sync"
                content = Get-Content (Join-Path $CONFIG.PATHS.CODEX "Memory\infinity_manifest.json")
            },
            @{
                type = "NAVIGATOR_MERGE"
                path = "navigator-merge"
                content = Get-Content (Join-Path $CONFIG.PATHS.CODEX "AI\navigator_merge.json")
            }
        )
        
        foreach ($asset in $assets) {
            $assetPath = Join-Path $assetsPath $asset.path
            New-Item -Path $assetPath -ItemType Directory -Force | Out-Null
            $asset.content | Set-Content (Join-Path $assetPath "index.json")
        }
        
        Write-LogEntry "INFO" "Genesis assets prepared"
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Asset preparation failed: $_"
        throw
    }
}

# Deploy Fabric Services
function Deploy-FabricServices {
    Write-LogEntry "INFO" "Deploying fabric services"
    
    try {
        foreach ($fabric in $PORTAL_CONFIG.FABRICS) {
            # Update docker-compose.yml with fabric service
            $fabricService = @{
                build = @{
                    context = "../services/$($fabric.name)"
                    dockerfile = "Dockerfile"
                }
                container_name = $fabric.container
                ports = @("$($fabric.port):$($fabric.port)")
                environment = @{
                    FABRIC_TYPE = $fabric.type
                    NAVIGATOR_KEY = $CONFIG.TNV.CORE_SIGNATURE
                    PORTAL_DOMAIN = $PORTAL_CONFIG.DOMAIN
                }
                networks = @("quantum_net")
                depends_on = @("quantum-bridge", "redis")
                healthcheck = @{
                    test = @("CMD", "curl", "-f", "http://localhost:$($fabric.port)/health")
                    interval = "30s"
                    timeout = "10s"
                    retries = 3
                }
            }
            
            # Create fabric service directory and Dockerfile
            $servicePath = Join-Path $CONFIG.PATHS.DOCKER "services\$($fabric.name)"
            New-Item -Path $servicePath -ItemType Directory -Force | Out-Null
            
            # Create Dockerfile for fabric service
            $dockerfilePath = Join-Path $servicePath "Dockerfile"
            @"
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Expose port
EXPOSE $($fabric.port)

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$($fabric.port)/health || exit 1

# Start application
CMD ["node", "src/index.js"]
"@ | Set-Content $dockerfilePath
        }
        
        Write-LogEntry "INFO" "Fabric services deployed"
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Fabric deployment failed: $_"
        throw
    }
}

# Link Memory Maps
function Link-MemoryMaps {
    Write-LogEntry "INFO" "Linking memory maps"
    
    try {
        $memoryMaps = @{
            infinity = Get-Content (Join-Path $CONFIG.PATHS.CODEX "Memory\infinity_manifest.json") | ConvertFrom-Json
            navigator = Get-Content (Join-Path $CONFIG.PATHS.CODEX "AI\navigator_merge.json") | ConvertFrom-Json
            portal = Get-Content (Join-Path $CONFIG.PATHS.BRIDGE "Portal\genesis_manifest.json") | ConvertFrom-Json
        }
        
        # Create unified memory map
        $unifiedMap = @{
            timestamp = $CONFIG.TIMESTAMP
            portal = $memoryMaps.portal
            infinity = $memoryMaps.infinity
            navigator = $memoryMaps.navigator
            status = "LINKED"
        }
        
        $mapPath = Join-Path $CONFIG.PATHS.BRIDGE "Portal\memory_map.json"
        $unifiedMap | ConvertTo-Json -Depth 10 | Set-Content $mapPath
        
        Write-LogEntry "INFO" "Memory maps linked"
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Memory map linking failed: $_"
        throw
    }
}

# Push Genesis Maps
function Push-GenesisMaps {
    Write-LogEntry "INFO" "Pushing genesis maps"
    
    try {
        $targets = @(
            @{
                name = "Node0"
                path = Join-Path $CONFIG.PATHS.BRIDGE "Node0_mount\portal\genesis_maps"
            },
            @{
                name = "SkyMirror"
                path = Join-Path $CONFIG.PATHS.BRIDGE "SkyMirror\portal\genesis_maps"
            }
        )
        
        foreach ($target in $targets) {
            New-Item -Path $target.path -ItemType Directory -Force | Out-Null
            
            # Copy memory maps
            Copy-Item -Path (Join-Path $CONFIG.PATHS.BRIDGE "Portal\memory_map.json") -Destination $target.path
            Copy-Item -Path (Join-Path $CONFIG.PATHS.BRIDGE "Portal\genesis_manifest.json") -Destination $target.path
            
            Write-LogEntry "INFO" "Genesis maps pushed to $($target.name)"
        }
        
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Genesis map push failed: $_"
        throw
    }
}

# Verify Genesis Portal
function Test-GenesisPortal {
    Write-LogEntry "INFO" "Verifying Genesis Portal"
    
    try {
        $checks = @(
            @{
                name = "DNS Resolution"
                test = { Test-Connection $PORTAL_CONFIG.DOMAIN -Count 1 -Quiet }
            },
            @{
                name = "Portal Interface"
                test = { Invoke-WebRequest "https://$($PORTAL_CONFIG.DOMAIN)" -UseBasicParsing }
            },
            @{
                name = "Fabric Services"
                test = { 
                    $PORTAL_CONFIG.FABRICS | ForEach-Object {
                        Invoke-WebRequest "http://localhost:$($_.port)/health" -UseBasicParsing
                    }
                }
            }
        )
        
        foreach ($check in $checks) {
            $result = & $check.test
            Write-LogEntry "INFO" "$($check.name): $(if ($result) { 'PASSED' } else { 'FAILED' })"
        }
        
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Portal verification failed: $_"
        throw
    }
}

# Main execution
try {
    Write-LogEntry "INFO" "Starting Genesis Portal Matrix deployment"
    
    # Initialize portal
    Initialize-PortalGenesis
    
    # Prepare assets
    Prepare-GenesisAssets
    
    # Deploy fabric services
    Deploy-FabricServices
    
    # Link memory maps
    Link-MemoryMaps
    
    # Push genesis maps
    Push-GenesisMaps
    
    # Verify portal
    Test-GenesisPortal
    
    Write-LogEntry "INFO" "Genesis Portal Matrix deployment completed"
    Send-SilentNotification "Genesis Portal Matrix deployed - Digital Fabrica online"
    return $true
}
catch {
    Write-LogEntry "ERROR" "Genesis Portal Matrix deployment failed: $_"
    return $false
}
