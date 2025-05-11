Param(
  [string[]]$scan_paths = @("C:\", "Q:\"),
  [int]$depth_limit = 6,
  [string[]]$include_extensions = @("*.ps1", "*.json", "*.yaml", "*.agx", "*.md", "*.ipfs", "*.canister"),
  [string]$output_registry = "vaults/SBSΩ/project_index_ΣΩΩ.yaml"
)

$ErrorActionPreference = 'Stop'

# === Quantum Harmonic Logging & Paths ===
$logDir = "logs/SBSΩ"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "project_indexing.log"

Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Starting canonical project asset indexing."

$results = @()
foreach ($root in $scan_paths) {
    foreach ($ext in $include_extensions) {
        try {
            $files = Get-ChildItem -Path $root -Recurse -Depth $depth_limit -Include $ext -File -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                $entry = [PSCustomObject]@{
                    path = $file.FullName
                    name = $file.Name
                    extension = $file.Extension
                    size = $file.Length
                    created = $file.CreationTimeUtc.ToString('o')
                    modified = $file.LastWriteTimeUtc.ToString('o')
                }
                $results += $entry
            }
        } catch {
            Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] ERROR: $_ while scanning $root for $ext"
        }
    }
}

# Export as YAML (if powershell-yaml module is available), else as JSON
try {
    Import-Module powershell-yaml -ErrorAction Stop
    $results | ConvertTo-Yaml | Set-Content -Path $output_registry
    Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Exported project index as YAML: $output_registry"
} catch {
    $jsonPath = [System.IO.Path]::ChangeExtension($output_registry, ".json")
    $results | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath
    Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Exported project index as JSON: $jsonPath (YAML module not found)"
}

Add-Content -Path $logFile -Value "[$((Get-Date -Format o))] Project asset indexing complete. Quantum harmonic mode active."
