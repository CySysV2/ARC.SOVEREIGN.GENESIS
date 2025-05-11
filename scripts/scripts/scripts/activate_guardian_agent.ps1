# Guardian Sovereign Mesh Agent Activation
# Generated: 2025-04-29T15:05:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "GuardianSovereignMesh"

# Import required modules
. "C:\FABRICA\scripts\quantum_system_manager.ps1"

# Configuration
$config = @{
    LogPath   = "C:\FABRICA\logs\guardian_mesh.log"
    AgentPath = "C:\FABRICA\agents\guardian_sovereign_mesh.ps1"
    MeshNodes = @(
        "QuantumHarmonicOrchestrator",
        "QuantumHarmonicSync",
        "QuantumHarmonicVerifier",
        "QuantumHarmonicValidator"
    )
}

# Function to activate mesh node
function Activate-MeshNode {
    param (
        [string]$NodeName
    )
    
    try {
        Write-Host "Activating mesh node: ${NodeName}"
        
        # Verify node is running
        $process = Get-Process | Where-Object { $_.ProcessName -like "*${NodeName}*" } -ErrorAction SilentlyContinue
        
        if ($process) {
            # Connect to mesh network
            $meshConfig = @{
                NodeName      = $NodeName
                MeshNetwork   = "FABRICA_Quantum_Mesh"
                SecurityLevel = "Sovereign"
            }
            
            # Initialize mesh connection
            $connection = Initialize-QuantumServices -ServiceName $NodeName -ServicePath $config.AgentPath
            
            if ($connection) {
                Write-Host "Successfully activated mesh node: ${NodeName}"
                return $true
            }
            else {
                Write-Host "Failed to activate mesh node: ${NodeName}" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Mesh node not running: ${NodeName}" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Error activating mesh node ${NodeName}: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main process
try {
    Write-Host "Starting Guardian Sovereign Mesh Activation"
    
    # Verify agent exists
    if (-not (Test-Path $config.AgentPath)) {
        Write-Host "Guardian Sovereign Mesh Agent not found at: $($config.AgentPath)" -ForegroundColor Red
        exit 1
    }
    
    # Activate mesh nodes
    $successCount = 0
    foreach ($node in $config.MeshNodes) {
        if (Activate-MeshNode -NodeName $node) {
            $successCount++
        }
    }
    
    if ($successCount -eq $config.MeshNodes.Count) {
        Write-Host "`nAll mesh nodes activated successfully" -ForegroundColor Green
    }
    else {
        Write-Host "`nSome mesh nodes failed to activate" -ForegroundColor Yellow
    }
    
    # Start mesh monitoring
    Write-Host "`nStarting Mesh Monitoring..."
    & "C:\FABRICA\scripts\quantum_harmonic_monitor.ps1"
}
catch {
    Write-Host "Guardian Sovereign Mesh Activation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 