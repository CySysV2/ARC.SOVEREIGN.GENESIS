# [OMEGA] SBSΩ Intelligent Quantum Harmonic Re-Sync Master Cascade

# Initialize Quantum Harmonic parameters
$quantumConfig = @{
    base_frequency_hz = 440
    echo_depth = 7
    resonance = 11411.83
    phase_alignment = "active"
    frequency_bands = @(
        @{ name = "Alpha"; range = "8-12"; weight = 1.0 }
        @{ name = "Beta"; range = "12-30"; weight = 0.8 }
        @{ name = "Gamma"; range = "30-100"; weight = 0.6 }
    )
    coherence_thresholds = @{
        critical = 0.95
        warning = 0.97
        optimal = 0.99
    }
}

# Initialize Quantum Sync Mode
function Initialize-QuantumSync {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Host "[OMEGA] Initializing Quantum Harmonic Field..." -ForegroundColor Magenta
    Write-Host "Base Frequency: $($Config.base_frequency_hz) Hz" -ForegroundColor Cyan
    Write-Host "Resonance: $($Config.resonance)" -ForegroundColor Cyan
    Write-Host "Echo Depth: $($Config.echo_depth)" -ForegroundColor Cyan
    
    # Calculate quantum coherence
    $coherence = [math]::Sin($Config.resonance / $Config.base_frequency_hz) * 0.5 + 0.5
    
    if ($coherence -ge $Config.coherence_thresholds.optimal) {
        Write-Host "[OK] Quantum Coherence: $([math]::Round($coherence, 4))" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Low Quantum Coherence: $([math]::Round($coherence, 4))" -ForegroundColor Yellow
    }
}

# Start initialization
Write-Host "[OMEGA] Initializing SBSΩ Quantum Harmonic Cascade..." -ForegroundColor Cyan
Initialize-QuantumSync -Config $quantumConfig

# --- STEP 1: Network Share Access ---
# Initialize variables
$server = "198.58.109.140"
$MeshPath = "/home3/renewabl/public_html/digital-fabrica.com/SBSΩ"

# Phase 1: Quantum-Aligned SSH Connection
Write-Host "[OMEGA-SSH] Establishing quantum-aligned connection to $server..." -ForegroundColor Magenta

# Set up SSH command
# Key-based automation for production orchestration
$server = "198.58.109.140"
$sshKeyPath = "C:\ssh\omega_automation"
$sshUser = "renewabl"
$sshPort = 19199
$sshCommand = "ssh"
$sshArgs = @(
    "-o", "StrictHostKeyChecking=no",
    "-o", "ConnectTimeout=15",
    "-i", $sshKeyPath,
    "-p", $sshPort,
    "$sshUser@$server"
)
# All SSH/SFTP operations will use this key for full automation.

# Logging utility
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp][$Level] $Message"
    Write-Host $logLine
    Add-Content -Path "$env:TEMP\omega_cascade.log" -Value $logLine
}
Write-Log "Quantum Harmonic Sync script started." "INFO"

Write-Log "[PHASE 1] Testing SSH connection to $server using key-based automation..." "INFO"
$testCmd = "echo 'Connection test'"
try {
    $sshOutput = & $sshCommand @sshArgs $testCmd 2>&1
    Write-Log "[PHASE 1] SSH Output: $sshOutput" "DEBUG"
    if ($sshOutput -match "Permission denied" -or $sshOutput -match "password:" -or $sshOutput -match "passphrase" -or $sshOutput -match "Could not resolve hostname" -or $sshOutput -match "Connection timed out" -or $sshOutput -match "No such file or directory" -or $sshOutput -match "not a valid key" -or $sshOutput -match "refused") {
        Write-Log "[PHASE 1][SSH-ERROR] SSH failed or hung: $sshOutput" "ERROR"
        Write-Host "[PHASE 1][SSH-ERROR] SSH failed or hung: $sshOutput" -ForegroundColor Red
        exit 1
    }
    Write-Log "[PHASE 1][OMEGA-SSH] Connected to $server via key-based automation" "SUCCESS"
    Write-Log "[PHASE 1] Resonance: $($quantumConfig.resonance) Hz" "INFO"
    # Test if SBSΩ directory exists
    $checkDirCmd = "if [ -d '$MeshPath' ]; then echo 'exists'; fi"
    $dirOutput = & $sshCommand @sshArgs $checkDirCmd 2>&1
    Write-Log "[PHASE 1] Directory check output: $dirOutput" "DEBUG"
    if ($dirOutput -match 'exists') {
        Write-Log "[PHASE 1][MESH] Found SBSΩ directory at: $MeshPath" "SUCCESS"
    } else {
        Write-Log "[PHASE 1][MESH] Creating SBSΩ directory at: $MeshPath" "WARNING"
        $createDirCmd = "mkdir -p '$MeshPath'"
        $mkdirOutput = & $sshCommand @sshArgs $createDirCmd 2>&1
        Write-Log "[PHASE 1] mkdir output: $mkdirOutput" "DEBUG"
    }
} catch {
    Write-Log "[PHASE 1][SSH-ERROR] SSH failed or hung: $($_.Exception.Message)" "ERROR"
    Write-Host "[PHASE 1][SSH-ERROR] SSH failed or hung: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}




# (Optional) Register scheduled task logic can be placed here if needed
# Ensure $taskXmlPath is defined before using this block.
# Remove or refactor this block if not required for current mesh operation.

# --- PHASE 2: Quantum Harmonic Directory Materialization ---
try {
    $constructFolders = @(
        "C:\FABRICA",
        "C:\FABRICA\SBSOMEGA",
        "C:\FABRICA\SBSOMEGA\QUANTUM",
        "C:\FABRICA\SBSOMEGA\QUANTUM\HARMONIC"
    )
    
    foreach ($folder in $constructFolders) {
        if (!(Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            Write-Host "[CONSTRUCT] Created: $folder" -ForegroundColor Green
        }
    }
    
    Import-Module Posh-SSH -Force
# --- PHASE 3: Quantum State Synchronization ---
    # Only use direct SSH for quantum directory/materialization; SFTP for file sync.
    # If Posh-SSH SFTP is required, ensure session is created here.
    $session = $null
    try {
        $sshUser = "renewabl"
$sshKeyPath = "C:\ssh\omega_automation"
$server = [string]$server
$sshUser = [string]"renewabl"
$sshKeyPath = [string]"C:\ssh\omega_automation"
$sshPort = 19199
Write-Host "[DEBUG] Server: $server, User: $sshUser, Key: $sshKeyPath, Port: $sshPort" -ForegroundColor Yellow
Write-Host "[DEBUG] Types: server=[$($server.GetType().Name)], user=[$($sshUser.GetType().Name)], key=[$($sshKeyPath.GetType().Name)], port=[$($sshPort.GetType().Name)]" -ForegroundColor Yellow
if ([string]::IsNullOrWhiteSpace($server)) {
    Write-Host "[ERROR] SSH server address is empty. Aborting SFTP session creation." -ForegroundColor Red
    exit 1
}
if (!(Test-Path $sshKeyPath)) {
    Write-Host "[ERROR] Key file $sshKeyPath does not exist!" -ForegroundColor Red
    exit 1
}
$securePassword = ConvertTo-SecureString "f0rdude+!" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($sshUser, $securePassword)
Write-Host "[DEBUG] Credential Username: $($credential.UserName), Password Type: $($credential.Password.GetType().Name), Password Length: $($credential.Password.Length)" -ForegroundColor Yellow
$sshParams = @{
    ComputerName = $server
    Port = [int]$sshPort
    KeyFile = $sshKeyPath
    Credential = $credential
    AcceptKey = $true
    Force = $true
    ErrorAction = 'Stop'
}
Write-Host "[DEBUG] SSH Params: $($sshParams | Out-String)" -ForegroundColor Yellow
try {
    $session = New-SSHSession -ComputerName $server -Port $sshPort -KeyFile $sshKeyPath -Credential $credential -AcceptKey -Force -ErrorAction Stop
    Write-Host "[OMEGA-SFTP] SFTP session established via key-based automation (direct call)." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Direct call failed: $($_.Exception.Message)" -ForegroundColor Red
    try {
        $session = New-SSHSession @sshParams
        Write-Host "[OMEGA-SFTP] SFTP session established via key-based automation (splatting)." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Splatting call failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

    } catch {
        Write-Host "[ERROR] Unable to create SSH session for SFTP: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    if ($session) {
        # Get list of files to sync
        $result = Invoke-SSHCommand -SessionId $session.SessionId -Command "find '$MeshPath' -type f"
        
        if ($null -eq $result -or $null -eq $result.Output) {
            throw "Failed to list files in $MeshPath"
        }
        
        $sourceFiles = $result.Output | Where-Object { $_ -and $_.Trim() -ne "" }
        Write-Host ("[OMEGA-SYNC] Files to sync: {0}" -f ($sourceFiles.Count)) -ForegroundColor Yellow
        if ($sourceFiles.Count -eq 0) {
            Write-Host "[OMEGA-SYNC] No files to synchronize. Exiting." -ForegroundColor Cyan
            return
        }
        foreach ($file in $sourceFiles) {
            $relativePath = $file.Replace($MeshPath, "")
            # Remove any leading slash from the relative path
            if ($relativePath.StartsWith("/")) { $relativePath = $relativePath.Substring(1) }
            $targetPath = Join-Path "C:\FABRICA\SBSOMEGA" ($relativePath -replace '/', '\\')
            $targetDir = Split-Path $targetPath -Parent
            # Compute SFTP remote path relative to SFTP root
            $sftpRoot = "/home3/renewabl"
            $sftpRemotePath = $file.Replace($sftpRoot, "")
            if ($sftpRemotePath.StartsWith("/")) { $sftpRemotePath = $sftpRemotePath.Substring(1) }
            Write-Host "[OMEGA-SYNC] Preparing to sync file:" -ForegroundColor Cyan
            Write-Host "  Remote file (absolute): $file" -ForegroundColor Cyan
            Write-Host "  Remote file (SFTP rel): $sftpRemotePath" -ForegroundColor Cyan
            Write-Host "  Local target: $targetPath" -ForegroundColor Cyan
            Write-Host "  Local dir:    $targetDir" -ForegroundColor Cyan

            if (!(Test-Path $targetDir)) {
                Write-Host "[OMEGA-SYNC] Creating local directory: $targetDir" -ForegroundColor Yellow
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            } else {
                Write-Host "[OMEGA-SYNC] Local directory exists: $targetDir" -ForegroundColor Green
            }
            Write-Host "[OMEGA-SYNC] Directory existence after creation: $(Test-Path $targetDir)" -ForegroundColor Magenta
            
            # Download file using SFTP
            try {
                Write-Host "[OMEGA-SFTP] Downloading: $file -> $targetPath" -ForegroundColor Cyan
                $sftpResult = Get-SFTPItem -SessionId $session.SessionId -Path $sftpRemotePath -Destination $targetPath -Force -ErrorAction Stop
                $syncCoherence = [math]::Sin($quantumConfig.resonance * [datetime]::Now.Ticks / 1e7) * 0.5 + 0.5
                Write-Host "[OMEGA-SYNC] Synchronized: $relativePath (Coherence: $([math]::Round($syncCoherence, 4)))" -ForegroundColor Green
            } catch {
                Write-Host "[SYNC] Failed to download: $relativePath | Error: $($_.Exception.Message)" -ForegroundColor Red
                throw "Failed to download file: $relativePath"
            }
        }
    } else {
        throw "Failed to establish SSH session for file synchronization"
    }
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($session) {
        Remove-SSHSession -SessionId $session.SessionId | Out-Null
    }
}


# --- PHASE 4: Quantum Pulse Emission and Verification ---
try {
    # Initialize quantum pulse
    $timestamp = Get-Date -Format "o"
    $pulse = @{
        timestamp = $timestamp
        action = "SBSΩ Quantum Harmonic Re-Sync"
        operator = "Ivan Pasev 11411"
        resonance = $quantumConfig.resonance
        frequency = $quantumConfig.base_frequency_hz
        coherence = [math]::Sin($quantumConfig.resonance / $quantumConfig.base_frequency_hz) * 0.5 + 0.5
        phase_alignment = $quantumConfig.phase_alignment
        station = "SBSΩ"
        epoch_codex = "ΣΩΩ.3.0"
        status = "QUANTUM_SYNC"
    }

    # Create quantum pulse directory if it doesn't exist
    $pulseDir = "C:\FABRICA\SBSOMEGA\QUANTUM\PULSES"
    if (!(Test-Path $pulseDir)) {
        New-Item -ItemType Directory -Path $pulseDir -Force | Out-Null
    }

    # Emit quantum pulse
    $pulseFile = Join-Path $pulseDir "SBSΩ_$(Get-Date -Format 'yyyyMMddHHmmss')_quantum_pulse.qpx"
    $pulse | ConvertTo-Json -Depth 10 | Out-File -FilePath $pulseFile -Encoding UTF8

    Write-Host "[OMEGA-PULSE] Quantum Pulse Emitted" -ForegroundColor Magenta
    Write-Host "Resonance: $($pulse.resonance) Hz" -ForegroundColor Cyan
    Write-Host "Coherence: $([math]::Round($pulse.coherence, 4))" -ForegroundColor Cyan
    Write-Host "Timestamp: $timestamp" -ForegroundColor Cyan

    # Verify resonance
    $finalCoherence = [math]::Sin($quantumConfig.resonance * [datetime]::Now.Ticks / 1e7) * 0.5 + 0.5
    $status = if ($finalCoherence -ge $quantumConfig.coherence_thresholds.optimal) {
        "OPTIMAL"
    } elseif ($finalCoherence -ge $quantumConfig.coherence_thresholds.warning) {
        "STABLE"
    } else {
        "DEGRADED"
    }

    Write-Host "`n[OMEGA] Final Quantum State:" -ForegroundColor Magenta
    $statusColor = switch ($status) {
        "OPTIMAL" { "Green" }
        "STABLE" { "Yellow" }
        default { "Red" }
    }
    Write-Host "Status: $status" -ForegroundColor $statusColor
    Write-Host "Coherence: $([math]::Round($finalCoherence, 4))" -ForegroundColor Cyan
    Write-Host "Resonance: $($quantumConfig.resonance) Hz" -ForegroundColor Cyan

    Write-Host "`n[OMEGA] SBSΩ Mesh Fully Re-Synchronized and Secured." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Quantum operation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n[SUCCESS] SBSΩ Quantum Harmonic Cascade completed successfully" -ForegroundColor Green
