# remediate_gospel_cascade_step1_domain_init.ps1
# Purpose: Remediated Gospel Cascade Step 1 - Domain Initialization with enhanced logging and artifact referencing.

$ErrorActionPreference = 'Stop'

# --- Configuration ---
$WorkspaceRoot = "C:\\DFT_GCC_TRIAD_MAINSTACK\\ARC.SOVEREIGN.GENESIS" # Assuming script is run from workspace root or this path is correctly set
$Epoch = $env:CASCADE_EPOCH
if (-not $Epoch) {
    $Epoch = "SO4" # Default if not set externally
    Write-Warning "CASCADE_EPOCH environment variable not set. Defaulting to '$Epoch'."
}

$RegistryPath = Join-Path $WorkspaceRoot "02_deployment\\registry.json"
$ManifestContentPath = Join-Path $WorkspaceRoot "02_deployment\\manifest_content.json"
$ManifestCidPath = Join-Path $WorkspaceRoot "02_deployment\\manifest.cid"
$EpochSigPath = Join-Path $WorkspaceRoot "02_deployment\\epoch.sig"

$LogDir = Join-Path $WorkspaceRoot "logs\\epoch_logs\\$Epoch"
$DomainSyncLogPath = Join-Path $LogDir "domain_sync.log"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Host "Created log directory: $LogDir"
}

# --- Helper Function for Structured Logging ---
function Write-DomainSyncLog {
    param(
        [string]$Domain,
        [string]$Service,
        [string]$Action,
        [string]$Details,
        [string]$Status
    )
    $logEntry = @{
        Timestamp = (Get-Date -Format o)
        Epoch     = $Script:Epoch
        Domain    = $Domain
        Service   = $Service
        Action    = $Action
        Details   = $Details
        Status    = $Status
    }
    $logJson = $logEntry | ConvertTo-Json -Compress
    Add-Content -Path $Script:DomainSyncLogPath -Value $logJson
}

# --- Main Logic ---

# 1. Load Registry and Manifest Content
Write-Host "Loading registry from $RegistryPath..."
if (-not (Test-Path $RegistryPath)) { Write-Error "Registry file not found: $RegistryPath"; exit 1 }
$Registry = Get-Content $RegistryPath | ConvertFrom-Json

Write-Host "Loading manifest content from $ManifestContentPath..."
if (-not (Test-Path $ManifestContentPath)) { Write-Error "Manifest content file not found: $ManifestContentPath"; exit 1 }
$ManifestContent = Get-Content $ManifestContentPath | ConvertFrom-Json

Write-Host "Preparing for domain initialization for Epoch $Epoch."
Add-Content -Path $DomainSyncLogPath -Value "--- Starting Domain Sync for Epoch $Epoch at $(Get-Date -Format o) ---"

# 2. Domain Initialization Loop
foreach ($domainEntry in $Registry.domains.PSObject.Properties) {
    $domainName = $domainEntry.Name
    $domainConfig = $domainEntry.Value

    Write-Host "Processing domain: $domainName"
    Write-DomainSyncLog -Domain $domainName -Service "N/A" -Action "StartInitialization" -Details "Status: $($domainConfig.status)" -Status "INFO"

    if ($domainConfig.status -ne "active") {
        Write-Warning "Domain $domainName is not active (status: $($domainConfig.status)). Skipping service deployment."
        Write-DomainSyncLog -Domain $domainName -Service "N/A" -Action "SkipDeployment" -Details "Domain status is $($domainConfig.status)" -Status "WARN"
        continue
    }

    if ($null -eq $domainConfig.services) {
        Write-Warning "No services defined for active domain: $domainName. Skipping service deployment."
        Write-DomainSyncLog -Domain $domainName -Service "N/A" -Action "SkipDeployment" -Details "No services defined in registry." -Status "WARN"
        continue
    }

    foreach ($serviceEntry in $domainConfig.services.PSObject.Properties) {
        $serviceName = $serviceEntry.Name
        $serviceConfig = $serviceEntry.Value
        $imageName = $serviceConfig.image

        Write-Host "  Processing service: $serviceName for $domainName (Image: $imageName)"

        # Find component details from manifest (simplified match by docker_image name)
        $componentManifest = $ManifestContent.components | Where-Object { $_.docker_image -eq $imageName } | Select-Object -First 1

        if ($componentManifest) {
            Write-DomainSyncLog -Domain $domainName -Service $serviceName -Action "SimulateDockerPull" -Details "Pulling image $($componentManifest.docker_image) (Version: $($componentManifest.version), Checksum: $($componentManifest.checksum))" -Status "SIMULATED_SUCCESS"
            Write-Host "    SIMULATED: docker pull $($componentManifest.docker_image)"

            Write-DomainSyncLog -Domain $domainName -Service $serviceName -Action "SimulateDockerRun" -Details "Running image $($componentManifest.docker_image) with config (Port: $($serviceConfig.port))" -Status "SIMULATED_SUCCESS"
            Write-Host "    SIMULATED: docker run -d -p $($serviceConfig.port):$($serviceConfig.port) --name $($domainName)_$($serviceName) $($componentManifest.docker_image)"
        } else {
            # Handle generic images not in manifest (e.g. nginx, apache from registry)
            if ($imageName -match ":") { # Basic check if it's an image with a tag
                 Write-DomainSyncLog -Domain $domainName -Service $serviceName -Action "SimulateDockerPull" -Details "Pulling generic image $imageName" -Status "SIMULATED_SUCCESS"
                 Write-Host "    SIMULATED: docker pull $imageName"
                 Write-DomainSyncLog -Domain $domainName -Service $serviceName -Action "SimulateDockerRun" -Details "Running generic image $imageName with config (Port: $($serviceConfig.port))" -Status "SIMULATED_SUCCESS"
                 Write-Host "    SIMULATED: docker run -d -p $($serviceConfig.port):$($serviceConfig.port) --name $($domainName)_$($serviceName) $imageName"
            } else {
                Write-Warning "    Image $imageName for service $serviceName on domain $domainName not found in manifest and does not look like a full image reference. Skipping."
                Write-DomainSyncLog -Domain $domainName -Service $serviceName -Action "SimulateDockerPull" -Details "Image $imageName not found in manifest and not a generic image." -Status "SIMULATED_FAILURE"
            }
        }
    }
    Write-DomainSyncLog -Domain $domainName -Service "N/A" -Action "EndInitialization" -Details "Successfully processed." -Status "INFO"
}

# 3. Copy Key Artifacts to Log Directory
Write-Host "Copying key artifacts to $LogDir..."
$artifactsToCopy = @(
    $RegistryPath,
    $ManifestContentPath,
    $ManifestCidPath,
    $EpochSigPath
)

foreach ($artifact in $artifactsToCopy) {
    if (Test-Path $artifact) {
        Copy-Item -Path $artifact -Destination $LogDir -Force
        Write-Host "  Copied $(Split-Path $artifact -Leaf) to $LogDir"
        Write-DomainSyncLog -Domain "GLOBAL" -Service "ArtifactSync" -Action "CopyArtifact" -Details "Copied $(Split-Path $artifact -Leaf) to log directory." -Status "SUCCESS"
    } else {
        Write-Warning "  Artifact not found, cannot copy: $artifact"
        Write-DomainSyncLog -Domain "GLOBAL" -Service "ArtifactSync" -Action "CopyArtifact" -Details "Artifact not found: $(Split-Path $artifact -Leaf)." -Status "FAILURE"
    }
}

Add-Content -Path $DomainSyncLogPath -Value "--- Completed Domain Sync for Epoch $Epoch at $(Get-Date -Format o) ---"
Write-Host "Remediated Gospel Cascade Step 1 Domain Initialization complete. Review logs at $DomainSyncLogPath" 