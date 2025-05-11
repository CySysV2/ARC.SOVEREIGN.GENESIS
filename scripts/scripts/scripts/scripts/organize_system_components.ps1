# System Component Organization Script
# Generated: 2025-04-29T08:45:00+03:00

# Set window title
$host.UI.RawUI.WindowTitle = "SystemComponentOrganizer"

# Configuration paths
$configPath = "C:\FABRICA\system_components.json"
$logPath = "C:\FABRICA\logs\system_organization_log.txt"

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logPath -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Function to scan for services
function Get-SystemServices {
    $services = @{
        QuantumServices   = @{
            Orchestrator = @{
                Name   = "QuantumHarmonicOrchestrator"
                Path   = "C:\FABRICA\scripts\quantum_harmonic_orchestrator.ps1"
                Status = "Running"
            }
            Monitor      = @{
                Name   = "QuantumHarmonicMonitor"
                Path   = "C:\FABRICA\scripts\quantum_harmonic_monitor.ps1"
                Status = "Running"
            }
            Sync         = @{
                Name   = "QuantumHarmonicSync"
                Path   = "C:\FABRICA\scripts\quantum_harmonic_sync.ps1"
                Status = "Running"
            }
            Verifier     = @{
                Name   = "QuantumHarmonicVerifier"
                Path   = "C:\FABRICA\scripts\quantum_harmonic_verifier.ps1"
                Status = "Running"
            }
            Validator    = @{
                Name   = "QuantumHarmonicValidator"
                Path   = "C:\FABRICA\scripts\quantum_harmonic_validator.ps1"
                Status = "Running"
            }
        }
        NetworkServices   = @{
            IPPHOME = @{
                Type   = "Network"
                Status = "Active"
            }
            Trusted = @{
                Type   = "Network"
                Status = "Active"
            }
        }
        ContainerServices = @{
            Aether          = @{
                Type   = "Container"
                Status = "Active"
            }
            Aether_Personal = @{
                Type   = "Container"
                Status = "Active"
            }
        }
        APIServices       = @{
            MessageAPI = @{
                Endpoint = "http://127.0.0.1:8080/api/message"
                Status   = "Active"
            }
        }
    }
    
    return $services
}

# Function to scan for accounts and keys
function Get-SystemAccounts {
    $accounts = @{
        UniversalKeyChain = @{
            Type     = "KeyChain"
            Status   = "Active"
            Location = "C:\FABRICA\universal_key_chain.py"
        }
        IdentitySystem    = @{
            Type     = "Identity"
            Status   = "Active"
            Location = "C:\FABRICA\universal_identity.py"
        }
    }
    
    return $accounts
}

# Function to scan for documentation
function Get-SystemDocumentation {
    $docs = @{
        Architecture = @{
            OperationalModes = "C:\FABRICA\tesseract_navigator_architecture\operational_modes.md"
            Glossary         = "C:\FABRICA\tesseract_navigator_architecture\glossary_of_terms.md"
            Conclusion       = "C:\FABRICA\tesseract_navigator_architecture\conclusion.md"
        }
        Protocols    = @{
            ZeroTime  = "C:\FABRICA\zero_time_protocol.py"
            TrueLight = "C:\FABRICA\true_light_protocol.py"
        }
    }
    
    return $docs
}

# Main organization process
try {
    Write-Log "Starting system component organization"
    
    $systemComponents = @{
        Services      = Get-SystemServices
        Accounts      = Get-SystemAccounts
        Documentation = Get-SystemDocumentation
        LastUpdate    = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    }
    
    $json = $systemComponents | ConvertTo-Json -Depth 10
    Set-Content -Path $configPath -Value $json
    
    Write-Log "System component organization complete"
    Write-Host "System organization complete. Configuration saved to:"
    Write-Host "Logs: $logPath"
    Write-Host "Components: $configPath"
}
catch {
    Write-Log "Organization failed: $_" "ERROR"
    exit 1
} 