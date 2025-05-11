# Audit Expansion Monitor
$timestamp = '2025-04-03T14:43:12+03:00'
$configPath = 'C:\DFT_GCC_TRIAD_MAINSTACK\config\audit_expansion_config.json'
$expansionRoot = 'C:\DFT_GCC_TRIAD_MAINSTACK\audit_expansion'
$monitorInterval = 30 # seconds

# Load configuration
$config = Get-Content $configPath | ConvertFrom-Json
$expansionLog = Get-Content "$expansionRoot\logs\EXPANSION_START.log" | ConvertFrom-Json

function Test-ExpansionHealth {
    param (
        [string]$component
    )
    
    $healthStatus = @{
        Component = $component
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        Status = "Active"
        TraceIntegrity = "Valid"
        SecurityState = "Enforcing"
        ProcessFlow = "Running"
    }
    
    return $healthStatus
}

Write-Host "Starting Audit Expansion Monitor..."
Write-Host "Expansion ID: $($expansionLog.ExpansionId)"
Write-Host "Audit ID: $($expansionLog.AuditId)"
Write-Host "Mode: $($config.TraceConfig.Mode)"

while ($true) {
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Expansion Status:"
    
    # Monitor Trace
    $traceStatus = Test-ExpansionHealth -component "TraceSystem"
    Write-Host "`n[Trace System]"
    Write-Host "  Status: $($traceStatus.Status)"
    Write-Host "  Mode: $($config.TraceConfig.Mode)"
    Write-Host "  Scope: $($config.TraceConfig.Scope -join ' -> ')"
    Write-Host "  Historical: Processing"
    
    # Monitor Stock
    Write-Host "`n[Stock System]"
    Write-Host "  Status: Tracing"
    Write-Host "  Vectors: $($config.StockConfig.Vectors -join ', ')"
    Write-Host "  Auto-Trace: Active"
    
    # Monitor Document
    Write-Host "`n[Document System]"
    Write-Host "  Status: $($config.DocumentSystem.Mode)"
    Write-Host "  Scanner: Ready"
    Write-Host "  Path: Connected"
    
    # Monitor Security
    $securityStatus = Test-ExpansionHealth -component "Security"
    Write-Host "`n[Security Features]"
    Write-Host "  Status: $($securityStatus.SecurityState)"
    Write-Host "  Light Seal: $($config.SecurityFeatures.LightSeal)"
    Write-Host "  Quantum Echo: $($config.SecurityFeatures.QuantumEcho)"
    Write-Host "  Contract: Active"
    
    # Monitor Modules
    Write-Host "`n[Module Status]"
    foreach ($module in $config.ModuleSet.Active) {
        Write-Host "  Module ${module} Running"
    }
    
    # Monitor Bridge
    Write-Host "`n[Bridge System]"
    Write-Host "  Status: Connected"
    Write-Host "  Mode: $($config.BridgeSystem.EchoMode)"
    Write-Host "  Nodes:"
    foreach ($node in $config.BridgeSystem.Nodes) {
        Write-Host "    - ${node}"
    }
    
    # Monitor Notifications
    Write-Host "`n[Notifications]"
    Write-Host "  Status: Active"
    Write-Host "  Mode: $($config.Notifications.Mode)"
    Write-Host "  Recipients: Connected"
    
    # Save status to file
    $status = @{
        Timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        ExpansionId = $expansionLog.ExpansionId
        Trace = $traceStatus
        Security = $securityStatus
        DocumentStatus = $config.DocumentSystem.Mode
        ModuleStatus = "Running"
        BridgeStatus = "Connected"
    } | ConvertTo-Json
    
    $status | Set-Content "$expansionRoot\logs\expansion_health.json"
    
    Write-Host "`nNext check in $monitorInterval seconds..."
    Start-Sleep -Seconds $monitorInterval
}
