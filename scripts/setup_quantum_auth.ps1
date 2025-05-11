# Setup script for quantum bridge authentication
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("PRODUCTION", "STAGING", "DEVELOPMENT")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$Epoch
)

$ErrorActionPreference = "Stop"

# Configuration
$CONFIG = @{
    CERT_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\certs"
    KEY_PATH = "C:\DFT_GCC_TRIAD_MAINSTACK\keys"
    QUANTUM_CONFIG = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\Docker\quantum-bridge\config\quantum.json"
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$Level] $Message"
    
    $color = switch ($Level) {
        'INFO' { 'White' }
        'WARNING' { 'Yellow' }
        'ERROR' { 'Red' }
        'SUCCESS' { 'Green' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
}

function Initialize-QuantumAuth {
    try {
        # Create necessary directories
        @($CONFIG.CERT_PATH, $CONFIG.KEY_PATH) | ForEach-Object {
            if (-not (Test-Path $_)) {
                New-Item -ItemType Directory -Path $_ -Force | Out-Null
                Write-Log "Created directory: $_" -Level SUCCESS
            }
        }
        
        Write-Log "Generating quantum-safe certificates..." -Level INFO
        
        # Generate self-signed certificate
        $cert = New-SelfSignedCertificate -DnsName @(
            "quantum-bridge.digital-fabrica.com",
            "*.cy-systems.com",
            "*.yellowchain.net",
            "*.cy-sys.org",
            "*.yellowchain.org",
            "*.citizen.solar"
        ) -CertStoreLocation "Cert:\LocalMachine\My" `
           -KeyAlgorithm RSA `
           -KeyLength 4096 `
           -KeyExportPolicy Exportable `
           -NotAfter (Get-Date).AddYears(1) `
           -Subject "CN=quantum-bridge.digital-fabrica.com, O=Digital Fabrica, OU=Quantum Bridge"
        
        Write-Log "Generated self-signed certificate" -Level SUCCESS
        
        # Export certificate and private key
        $certPassword = ConvertTo-SecureString -String "QuantumBridge2025!" -Force -AsPlainText
        $certPath = Join-Path $CONFIG.CERT_PATH "quantum_bridge.pfx"
        Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $certPassword | Out-Null
        Write-Log "Exported certificate with private key" -Level SUCCESS
        
        # Export public certificate
        $publicCertPath = Join-Path $CONFIG.CERT_PATH "quantum_bridge.cer"
        Export-Certificate -Cert $cert -FilePath $publicCertPath -Type CERT | Out-Null
        Write-Log "Exported public certificate" -Level SUCCESS
        
        # Update quantum bridge configuration
        $quantumConfig = Get-Content $CONFIG.QUANTUM_CONFIG | ConvertFrom-Json
        
        # Create PSCustomObject for certificates
        $certConfig = [PSCustomObject]@{
            pfx_path = $certPath
            public_cert = $publicCertPath
            thumbprint = $cert.Thumbprint
        }
        
        # Update the authentication section
        $quantumConfig.security.authentication | Add-Member -MemberType NoteProperty -Name 'certificates' -Value $certConfig -Force
        
        # Save the updated config
        $quantumConfig | ConvertTo-Json -Depth 10 | Out-File $CONFIG.QUANTUM_CONFIG -Encoding utf8
        Write-Log "Updated quantum bridge configuration" -Level SUCCESS
        
        Write-Log "Quantum authentication setup complete" -Level SUCCESS
        return $true
    } catch {
        Write-Log "Error setting up quantum authentication: $_" -Level ERROR
        return $false
    }
}

# Execute setup
try {
    Write-Log "Starting quantum authentication setup for environment: $Environment" -Level INFO
    Write-Log "Epoch: $Epoch" -Level INFO
    
    $success = Initialize-QuantumAuth
    if ($success) {
        Write-Log "Quantum authentication setup completed successfully" -Level SUCCESS
        exit 0
    } else {
        Write-Log "Quantum authentication setup failed" -Level ERROR
        exit 1
    }
} catch {
    Write-Log "Fatal error: $_" -Level ERROR
    exit 1
}
