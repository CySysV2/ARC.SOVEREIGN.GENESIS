param(
    [Parameter(Mandatory=$false)]
    [int]$MonitorDurationMinutes = 60,
    
    [Parameter(Mandatory=$false)]
    [switch]$ContinuousMode,
    
    [Parameter(Mandatory=$false)]
    [string]$AlertWebhook
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Enhanced Configuration
$CONFIG = @{
    REDIS_URL = "redis://localhost:6379"
    LOG_DIR = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\logs\quantum"
    METRICS_DIR = "C:\DFT_GCC_TRIAD_MAINSTACK\SBS\metrics"
    
    # Enhanced thresholds with warning and critical levels
    THRESHOLDS = @{
        RESONANCE = @{
            WARNING = 0.95
            CRITICAL = 0.90
            OPTIMAL = 0.98
        }
        COHERENCE = @{
            WARNING = 0.93
            CRITICAL = 0.88
            OPTIMAL = 0.97
        }
        QUANTUM_ECHO = @{
            WARNING = 0.90
            CRITICAL = 0.85
            OPTIMAL = 0.95
        }
        STABILITY = @{
            WARNING = 0.92
            CRITICAL = 0.87
            OPTIMAL = 0.96
        }
        ENTROPY = @{
            WARNING = 0.15
            CRITICAL = 0.25
            OPTIMAL = 0.10
        }
        FIELD_STRENGTH = @{
            WARNING = 0.88
            CRITICAL = 0.82
            OPTIMAL = 0.93
        }
    }
    
    # Monitoring intervals
    CHECK_INTERVAL_SECONDS = 30
    METRIC_RETENTION_DAYS = 7
    ALERT_COOLDOWN_MINUTES = 15
    
    # Recovery settings
    MAX_AUTO_RECOVERY_ATTEMPTS = 3
    RECOVERY_COOLDOWN_MINUTES = 30
}

# Initialize logging
$LogPath = $CONFIG.LOG_DIR
$MetricsPath = $CONFIG.METRICS_DIR

foreach ($path in @($LogPath, $MetricsPath)) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

$LogFile = Join-Path $LogPath "quantum_stability_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$MetricsFile = Join-Path $MetricsPath "stability_metrics_$(Get-Date -Format 'yyyyMMdd').csv"

# Initialize metrics file with headers if it doesn't exist
if (-not (Test-Path $MetricsFile)) {
    "Timestamp,Resonance,Coherence,QuantumEcho,StabilityScore,EntropyLevel,FieldStrength,HarmonicConvergence,Status" | 
    Out-File -FilePath $MetricsFile -Encoding utf8
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Color = switch ($Level) {
        'INFO' { 'White' }
        'WARNING' { 'Yellow' }
        'ERROR' { 'Red' }
        'SUCCESS' { 'Green' }
    }
    
    $LogMessage = "[$Timestamp][$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage -ForegroundColor $Color
}

function Get-RedisKey {
    param([string]$Key)
    
    try {
        $value = docker exec redis redis-cli get $Key
        return $value
    } catch {
        Write-Log ("Redis error getting key {0}: {1}" -f $Key, $_.Exception.Message) -Level ERROR
        throw
    }
}

function Write-MetricsToFile {
    param($Metrics)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $status = if ($Metrics.Status.Stable) { "STABLE" } else { "UNSTABLE" }
    
    "$timestamp,$($Metrics.Resonance),$($Metrics.Coherence),$($Metrics.QuantumEcho),$($Metrics.StabilityScore),$($Metrics.EntropyLevel),$($Metrics.FieldStrength),$($Metrics.HarmonicConvergence),$status" |
    Add-Content -Path $MetricsFile
}

function Send-Alert {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('warning', 'critical', 'info')]
        [string]$Severity = 'warning'
    )
    
    if ($AlertWebhook) {
        try {
            $body = @{
                title = $Title
                message = $Message
                severity = $Severity
                timestamp = Get-Date -Format "o"
                source = "Quantum Stability Monitor"
            } | ConvertTo-Json
            
            Invoke-RestMethod -Uri $AlertWebhook -Method Post -Body $body -ContentType 'application/json'
        } catch {
            Write-Log "Failed to send alert: $_" -Level ERROR
        }
    }
}

function Test-MetricThreshold {
    param(
        [string]$MetricName,
        [double]$Value
    )
    
    $threshold = $CONFIG.THRESHOLDS[$MetricName]
    if (-not $threshold) {
        throw "Unknown metric: $MetricName"
    }
    
    if ($Value -lt $threshold.CRITICAL) {
        return @{ Status = "CRITICAL"; Color = "Red" }
    } elseif ($Value -lt $threshold.WARNING) {
        return @{ Status = "WARNING"; Color = "Yellow" }
    } elseif ($Value -ge $threshold.OPTIMAL) {
        return @{ Status = "OPTIMAL"; Color = "Green" }
    } else {
        return @{ Status = "NORMAL"; Color = "White" }
    }
}

function Test-QuantumStability {
    try {
        # Get current metrics
        $metrics = Get-RedisKey "quantum:bridge:metrics" | ConvertFrom-Json
        
        if (-not $metrics) {
            Write-Log "WARNING: No metrics found, requesting new measurement..." -Level WARNING
            return @{ Stable = $false; Metrics = $null }
        }
        
        # Calculate age of metrics
        $lastUpdate = [DateTime]::Parse($metrics.lastCorrection)
        $age = (Get-Date) - $lastUpdate
        
        if ($age.TotalMinutes -gt 5) {
            Write-Log "WARNING: Metrics are stale (${age.TotalMinutes:N1} minutes old)" -Level WARNING
            return @{ Stable = $false; Metrics = $null }
        }
        
        # Enhanced stability analysis
        $stabilityResults = @{
            Resonance = Test-MetricThreshold "RESONANCE" $metrics.baseResonance
            Coherence = Test-MetricThreshold "COHERENCE" $metrics.baseCoherence
            QuantumEcho = Test-MetricThreshold "QUANTUM_ECHO" $metrics.quantumEcho
            Stability = Test-MetricThreshold "STABILITY" $metrics.stabilityScore
            Entropy = Test-MetricThreshold "ENTROPY" $metrics.diagnostics.entropyLevel
            FieldStrength = Test-MetricThreshold "FIELD_STRENGTH" $metrics.fieldStrength
        }
        
        # Prepare detailed metrics report
        $metricsReport = @{
            Resonance = $metrics.baseResonance
            Coherence = $metrics.baseCoherence
            QuantumEcho = $metrics.quantumEcho
            StabilityScore = $metrics.stabilityScore
            EntropyLevel = $metrics.diagnostics.entropyLevel
            FieldStrength = $metrics.fieldStrength
            HarmonicConvergence = $metrics.diagnostics.harmonicConvergence
            Status = @{
                Stable = $true
                CriticalCount = 0
                WarningCount = 0
                OptimalCount = 0
            }
        }
        
        # Analyze results
        foreach ($result in $stabilityResults.Values) {
            switch ($result.Status) {
                "CRITICAL" { 
                    $metricsReport.Status.Stable = $false
                    $metricsReport.Status.CriticalCount++
                }
                "WARNING" { $metricsReport.Status.WarningCount++ }
                "OPTIMAL" { $metricsReport.Status.OptimalCount++ }
            }
        }
        
        # Log detailed status
        $statusEmoji = if ($metricsReport.Status.Stable) { "✅" } else { "⚠️" }
        Write-Log "$statusEmoji System Status:" -Level $(if ($metricsReport.Status.Stable) { "SUCCESS" } else { "WARNING" })
        Write-Log ("  Resonance: {0:N4} [{1}]" -f $metrics.baseResonance, $stabilityResults.Resonance.Status) -Level $stabilityResults.Resonance.Color
        Write-Log ("  Coherence: {0:N4} [{1}]" -f $metrics.baseCoherence, $stabilityResults.Coherence.Status) -Level $stabilityResults.Coherence.Color
        Write-Log ("  Quantum Echo: {0:N4} [{1}]" -f $metrics.quantumEcho, $stabilityResults.QuantumEcho.Status) -Level $stabilityResults.QuantumEcho.Color
        Write-Log ("  Field Strength: {0:N4} [{1}]" -f $metrics.fieldStrength, $stabilityResults.FieldStrength.Status) -Level $stabilityResults.FieldStrength.Color
        Write-Log ("  Entropy Level: {0:N4} [{1}]" -f $metrics.diagnostics.entropyLevel, $stabilityResults.Entropy.Status) -Level $stabilityResults.Entropy.Color
        Write-Log ("  Harmonic Convergence: {0:N4}" -f $metrics.diagnostics.harmonicConvergence)
        
        # Write metrics to file
        Write-MetricsToFile $metricsReport
        
        # Send alerts if needed
        if ($metricsReport.Status.CriticalCount -gt 0) {
            Send-Alert -Title "CRITICAL: Quantum Stability Issues Detected" `
                      -Message "Critical thresholds exceeded: $($metricsReport.Status.CriticalCount) metrics" `
                      -Severity "critical"
        } elseif ($metricsReport.Status.WarningCount -gt 0) {
            Send-Alert -Title "WARNING: Quantum Stability Degrading" `
                      -Message "Warning thresholds exceeded: $($metricsReport.Status.WarningCount) metrics" `
                      -Severity "warning"
        }
        
        return $metricsReport
    } catch {
        Write-Log "ERROR: Failed to check quantum stability: $_" -Level ERROR
        return @{ Stable = $false; Metrics = $null }
    }
}

function Start-StabilityMonitor {
    Write-Log "Starting Enhanced Quantum Stability Monitor..."
    Write-Log "Mode: $(if ($ContinuousMode) { 'Continuous' } else { "$MonitorDurationMinutes minutes" })"
    
    $startTime = Get-Date
    $endTime = $startTime.AddMinutes($MonitorDurationMinutes)
    $lastRecoveryAttempt = $null
    $recoveryAttempts = 0
    
    while ($true) {
        $currentTime = Get-Date
        
        # Check if monitoring duration has elapsed (unless in continuous mode)
        if (-not $ContinuousMode -and $currentTime -gt $endTime) {
            Write-Log "Monitoring duration completed"
            break
        }
        
        # Check stability
        $status = Test-QuantumStability
        
        if (-not $status.Status.Stable) {
            # Check if we can attempt recovery
            $canAttemptRecovery = $true
            
            if ($lastRecoveryAttempt) {
                $timeSinceLastRecovery = ($currentTime - $lastRecoveryAttempt).TotalMinutes
                if ($timeSinceLastRecovery -lt $CONFIG.RECOVERY_COOLDOWN_MINUTES) {
                    $canAttemptRecovery = $false
                    Write-Log "Recovery cooldown in effect. Minutes remaining: $($CONFIG.RECOVERY_COOLDOWN_MINUTES - $timeSinceLastRecovery)" -Level WARNING
                }
            }
            
            if ($recoveryAttempts -ge $CONFIG.MAX_AUTO_RECOVERY_ATTEMPTS) {
                $canAttemptRecovery = $false
                Write-Log "Maximum recovery attempts reached. Manual intervention required." -Level ERROR
                Send-Alert -Title "CRITICAL: Quantum Stability Recovery Failed" `
                          -Message "Maximum recovery attempts reached. Manual intervention required." `
                          -Severity "critical"
            }
            
            if ($canAttemptRecovery) {
                Write-Log "Triggering quantum harmonic sync to restore stability..." -Level WARNING
                $recoveryAttempts++
                $lastRecoveryAttempt = $currentTime
                
                try {
                    & "$PSScriptRoot\quantum_harmonic_sync.ps1" -Mode PRODUCTION -Phase QH -Epoch "ΣΩΩ.3.0"
                } catch {
                    Write-Log "Recovery attempt failed: $_" -Level ERROR
                }
            }
        } else {
            # Reset recovery attempts on stable state
            $recoveryAttempts = 0
        }
        
        # Wait for next check
        Start-Sleep -Seconds $CONFIG.CHECK_INTERVAL_SECONDS
    }
}

try {
    Start-StabilityMonitor
} catch {
    Write-Log "Fatal error in stability monitor: $_" -Level ERROR
    Send-Alert -Title "CRITICAL: Quantum Stability Monitor Failed" `
              -Message $_.Exception.Message `
              -Severity "critical"
    throw
}
