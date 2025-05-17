[CmdletBinding()] # Still good for parameter binding
param(
    [Parameter(Mandatory=$true, HelpMessage="Starting block for the voting cycle.")]
    [ValidateNotNullOrEmpty()]
    [int]$StartBlock,

    [Parameter(Mandatory=$true, HelpMessage="Ending block for the voting cycle.")]
    [ValidateNotNullOrEmpty()]
    [int]$EndBlock,

    [Parameter(Mandatory=$true, HelpMessage="Quorum percentage (e.g., 0.4 for 40%).")]
    [ValidateRange(0.01, 1.0)]
    [double]$Quorum
)

$ErrorActionPreference = 'Stop'

Function Write-Log {
    param($Message, $Level = "INFO")
    # Get-Date format for consistency, and ensure level is part of the string
    Write-Host ("[{0}] {1} - {2}" -f $Level, (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $Message)
}

Write-Log "vote_init.ps1 script started."
Write-Log "Working Directory (PWD): $($PWD.Path)"
Write-Log "Script Invocation MyCommand Path: $($MyInvocation.MyCommand.Path)" # Path used to call script
Write-Log "Script Resolved Path (PSScriptRoot): $PSScriptRoot" # Directory of the script file
Write-Log "Parameters: StartBlock=$StartBlock, EndBlock=$EndBlock, Quorum=$Quorum"

if ($StartBlock -ge $EndBlock) {
    Write-Log "StartBlock ($StartBlock) must be less than EndBlock ($EndBlock)." -Level "ERROR"
    exit 1
}

Write-Log "[QUANTUM_SYNC] Voting cycle activated for blocks $StartBlock-$EndBlock (Quorum: $($Quorum*100)%)."
Write-Log "[FNS_LEDGER] Syncing with CivicDash..."

# Path to status JSON file, relative to the Current Working Directory (which is ARC.SOVEREIGN.GENESIS)
$statusFileRelativePath = "web-projects/digital-fabrica.com/src/pages/dao/vote-status.json"
$statusFileFullPath = Join-Path $PWD.Path $statusFileRelativePath
# Resolve to get a canonical path
$statusFileFullPath = Resolve-Path -Path $statusFileFullPath -ErrorAction SilentlyContinue
if (-not $statusFileFullPath) { # If path doesn't exist yet, Join-Path is fine for constructing it
    $statusFileFullPath = Join-Path $PWD.Path $statusFileRelativePath
}

Write-Log "Target status file determined as: $statusFileFullPath"

$statusDir = Split-Path -Path $statusFileFullPath
if (-not (Test-Path $statusDir)) {
    Write-Log "Directory '$statusDir' for status file does not exist. Creating..."
    New-Item -ItemType Directory -Path $statusDir -Force | Out-Null
    Write-Log "Directory '$statusDir' created successfully."
} else {
    Write-Log "Directory '$statusDir' already exists."
}

$statusData = @{
    startBlock        = $StartBlock
    endBlock          = $EndBlock
    quorum            = $Quorum
    currentBlock      = $StartBlock
    status            = "INIT"
    lastUpdated       = (Get-Date -Format "o") # ISO 8601
    sourceScript      = $MyInvocation.MyCommand.Definition # Or .Path
    executionHost     = $env:COMPUTERNAME
    executionTimestamp = (Get-Date -Format "o")
}

Write-Log "Attempting to write status data to $statusFileFullPath"
try {
    $statusDataJson = $statusData | ConvertTo-Json -Depth 5
    $statusDataJson | Out-File -FilePath $statusFileFullPath -Encoding utf8 -Force
    Write-Log "[CODEX_MODULATION] Vote tracker data written to $statusFileFullPath"

    Write-Log "Verifying content of ${statusFileFullPath}:"
    $fileContent = Get-Content -Path $statusFileFullPath -Raw -ErrorAction SilentlyContinue
    if ($fileContent) {
        Write-Log "[VERIFY_CONTENT_START]"
        Write-Host $fileContent # Output raw content for easy parsing by calling system
        Write-Log "[VERIFY_CONTENT_END]"
        if ($fileContent.Trim().Length -gt 0) {
             Write-Log "Verification: File is not empty and contains data."
        } else {
             Write-Log "Verification: File is empty or whitespace." -Level "WARNING"
        }
    } else {
        Write-Log "Verification: Failed to read file content or file is empty." -Level "ERROR"
    }

} catch {
    Write-Log "Failed to write JSON to '${statusFileFullPath}'. Error: $($_.Exception.Message)" -Level "ERROR"
    Write-Log "Exception details: $($_.ToString())" -Level "ERROR"
    exit 1
}

Write-Log "vote_init.ps1 script finished successfully." 