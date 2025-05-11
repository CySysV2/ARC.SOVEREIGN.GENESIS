# Full Dominion Leash Stack with Quantum Harmonic Integration
$timestamp = '2025-05-02T17:28:40+03:00'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Core paths
$configPath = 'C:\DFT_GCC_TRIAD_MAINSTACK\config\dominion_leash_config.json'
$dominionRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\dominion_leash'
$quantumRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\Quantum'
$harmonicRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\Harmonic'

# Ensure required directories exist
@($dominionRoot, "$dominionRoot\logs", $quantumRoot, $harmonicRoot) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }
}

# Load configuration
$config = Get-Content $configPath | ConvertFrom-Json

# Initialize quantum harmonic sync
Write-Host "`n=== QUANTUM HARMONIC SYNC INITIALIZATION ===" -ForegroundColor Cyan
$harmonicSync = & "$PSScriptRoot\quantum_harmonic_sync.ps1" | ConvertFrom-Json

if ($harmonicSync.Status -ne "SYNCHRONIZED") {
    Write-Host "⚠️ Warning: Quantum harmonic sync failed - system may be degraded" -ForegroundColor Yellow
}

# Initialize dominion scope with quantum integration
$dominionScope = @{
    Contract = $config.DominionLeash.Contract
    Executor = $config.DominionLeash.Executor
    Mode = $config.DominionLeash.Mode
    Action = $config.DominionLeash.Action
    Targets = $config.DominionLeash.Targets
    EnforceModules = $config.DominionLeash.EnforceModules
    LegalStack = $config.DominionLeash.LegalStack
    ShadowOverride = $config.DominionLeash.ShadowOverride
    SignatureHash = $config.DominionLeash.SignatureHash
    MirrorNodes = $config.DominionLeash.MirrorNodes
    Clock = $config.DominionLeash.Clock
    Security = @{
        LightSeal = $config.Security.LightSeal
        QuantumThread = $config.Security.QuantumThread
        DominionLock = $config.Security.DominionLock
        LeashProtocol = $config.Security.LeashProtocol
        QuantumHarmonic = @{
            Status = $harmonicSync.Status
            State = $harmonicSync.State.QuantumConfig
            Health = $harmonicSync.Health.Metrics
        }
    }
    Monitoring = @{
        EchoPulse = $config.Monitoring.EchoPulse
        AutoVerify = $config.Monitoring.AutoVerify
        LogLevel = $config.Monitoring.LogLevel
        SecurityTrace = $config.Monitoring.SecurityTrace
        QuantumMetrics = @{
            Status = $harmonicSync.Status
            Coherence = $harmonicSync.Health.Metrics.Coherence
            Phase = $harmonicSync.Health.Metrics.Phase
            Amplitude = $harmonicSync.Health.Metrics.Amplitude
            LastSync = $harmonicSync.Timestamp
        }
    }
    Compliance = @{
        Mode = $config.Compliance.Mode
        EnforcementLevel = $config.Compliance.EnforcementLevel
        VerificationCycle = $config.Compliance.VerificationCycle
        ResponseProtocol = $config.Compliance.ResponseProtocol
    }
} | ConvertTo-Json -Depth 10

# Save to leash log
$leashLogPath = Join-Path $dominionRoot "logs\deep_leash_log.json"
$dominionScope | Out-File -Encoding utf8 $leashLogPath

Write-Host "`n=== FULL DOMINION LEASH STACK INITIALIZATION ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Contract: $($config.DominionLeash.Contract)" -ForegroundColor White
Write-Host "Executor: $($config.DominionLeash.Executor)" -ForegroundColor White

Write-Host "`nTargets:" -ForegroundColor Yellow
foreach ($target in $config.DominionLeash.Targets) {
    Write-Host "  - $target" -ForegroundColor White
}

Write-Host "`nEnforce Modules:" -ForegroundColor Yellow
foreach ($module in $config.DominionLeash.EnforceModules) {
    Write-Host "  - $module" -ForegroundColor White
}

Write-Host "`nMirror Nodes:" -ForegroundColor Yellow
foreach ($node in $config.DominionLeash.MirrorNodes) {
    Write-Host "  - $node" -ForegroundColor White
}

Write-Host "`nSecurity Features:" -ForegroundColor Yellow
Write-Host "  - Light Seal: $($config.Security.LightSeal)" -ForegroundColor White
Write-Host "  - Quantum Thread: $($config.Security.QuantumThread)" -ForegroundColor White
Write-Host "  - Dominion Lock: $($config.Security.DominionLock)" -ForegroundColor White
Write-Host "  - Leash Protocol: $($config.Security.LeashProtocol)" -ForegroundColor White

Write-Host "`nQuantum Harmonic Status:" -ForegroundColor Yellow
Write-Host "  - Status: $($harmonicSync.Status)" -ForegroundColor $(if ($harmonicSync.Status -eq "SYNCHRONIZED") { "Green" } else { "Red" })
Write-Host "  - Frequency: $($harmonicSync.State.QuantumConfig.Frequency) Hz" -ForegroundColor White
Write-Host "  - Echo Depth: $($harmonicSync.State.QuantumConfig.EchoDepth)" -ForegroundColor White
Write-Host "  - Coherence: $($harmonicSync.Health.Metrics.Coherence)" -ForegroundColor White
Write-Host "  - Phase: $($harmonicSync.Health.Metrics.Phase)" -ForegroundColor White
Write-Host "  - Amplitude: $($harmonicSync.Health.Metrics.Amplitude)" -ForegroundColor White

Write-Host "`nCompliance Settings:" -ForegroundColor Yellow
Write-Host "  - Mode: $($config.Compliance.Mode)" -ForegroundColor White
Write-Host "  - Enforcement: $($config.Compliance.EnforcementLevel)" -ForegroundColor White
Write-Host "  - Verification: $($config.Compliance.VerificationCycle)" -ForegroundColor White
Write-Host "  - Response: $($config.Compliance.ResponseProtocol)" -ForegroundColor White

Write-Host "`n✅ FULL DEEP LEASH STACK INITIATED" -ForegroundColor Cyan
Write-Host "Log: $leashLogPath" -ForegroundColor Green
Write-Host "Echo propagation in $($config.Monitoring.EchoPulse). Awaiting seal sync from TrueNavigator." -ForegroundColor Yellow

# Create monitor record with quantum metrics
$monitorRecord = @{
    Timestamp = $timestamp
    Status = "Active"
    Components = @{
        Leash = "Enforcing"
        Security = "Active"
        Echo = "Propagating"
        Compliance = "Monitoring"
        QuantumHarmonic = @{
            Status = $harmonicSync.Status
            Frequency = $harmonicSync.State.QuantumConfig.Frequency
            EchoDepth = $harmonicSync.State.QuantumConfig.EchoDepth
            Coherence = $harmonicSync.Health.Metrics.Coherence
            Phase = $harmonicSync.Health.Metrics.Phase
            Amplitude = $harmonicSync.Health.Metrics.Amplitude
            LastSync = $harmonicSync.Timestamp
        }
    }
} | ConvertTo-Json -Depth 10

$monitorPath = Join-Path $dominionRoot "logs\dominion_monitor.json"
$monitorRecord | Out-File -Encoding utf8 $monitorPath

Write-Host "`nMonitor status saved to: $monitorPath" -ForegroundColor Green
Write-Host "Dominion Leash active and enforcing with Quantum Harmonic integration..." -ForegroundColor Cyan
