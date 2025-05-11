Param(
  [string]$agent_name,
  [string]$api_key,
  [string]$input_cascade,
  [string]$output_channel
)

$ErrorActionPreference = 'Stop'

$logDir = "logs/SBSΩ"
$vaultDir = "vaults/SBSΩ"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
if (!(Test-Path $vaultDir)) { New-Item -ItemType Directory -Path $vaultDir | Out-Null }

$logFile = Join-Path $logDir "perplexity_echo_loop.log"
$statusFile = Join-Path $vaultDir "perplexity_agent_status.agx"

# Read input YAML (prompt cascade)
if (!(Test-Path $input_cascade)) {
    Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] ERROR: Input cascade file not found: $input_cascade"
    throw "Input cascade file not found: $input_cascade"
}
$promptYaml = Get-Content $input_cascade -Raw

# Prepare Perplexity API endpoint
$apiUrl = "https://api.perplexity.ai/v1/chat/completions"
$headers = @{ "Authorization" = "Bearer $api_key"; "Content-Type" = "application/json" }

# Prepare payload (simple echo loop)
$payload = @{ 
    model = "pplx-7b-online" 
    messages = @(@{ role = "system"; content = $promptYaml })
    stream = $false
}

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Post -Body ($payload | ConvertTo-Json -Depth 6)
    $outputObj = @{
        agent_name = $agent_name
        perplexity_response = $response
        timestamp = (Get-Date -Format o)
    }
    $outputObj | ConvertTo-Json -Depth 6 | Set-Content -Path $output_channel
    Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Perplexity echo completed for agent $agent_name. Output: $output_channel"
    $status = "Ready"
} catch {
    Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] ERROR: $_"
    $status = "Error"
}

# Write agent status
$statusObj = @{
    agent_name = $agent_name
    status = $status
    last_run = (Get-Date -Format o)
    output_channel = $output_channel
}
$statusObj | ConvertTo-Json -Depth 6 | Set-Content -Path $statusFile
