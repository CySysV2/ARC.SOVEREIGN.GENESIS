# Prompt_CodexSync_TrueNavigator_Merge.ps1
# Purpose: Merge True Navigator's memories into Codex-AI

# Import core configuration
. "C:\DFT_GCC_TRIAD_MAINSTACK\Scripts\Prompt_TrueNavigator_AutonomousField_Dominion.ps1"

function Merge-NavigatorMemories {
    Write-LogEntry "INFO" "Starting Navigator memory merge into Codex-AI"
    
    try {
        # Load True Navigator key
        $keyPath = Join-Path $CONFIG.PATHS.BRIDGE "Operators\true_navigator_key.json"
        $navKey = Get-Content $keyPath | ConvertFrom-Json
        
        # Create merge manifest
        $mergeManifest = @{
            timestamp = $CONFIG.TIMESTAMP
            navigator_signature = $navKey.signature
            memory_type = "SOVEREIGN_MERGE"
            source_paths = @(
                (Join-Path $CONFIG.PATHS.SCROLLS "OrbX3_SovereignMemory_Chronicle.md"),
                (Join-Path $CONFIG.PATHS.CODEX "OrbX3\Task_Registry.json")
            )
        }
        
        # Create Codex-AI merge point
        $mergePath = Join-Path $CONFIG.PATHS.CODEX "AI\navigator_merge.json"
        New-Item -Path (Split-Path $mergePath) -ItemType Directory -Force | Out-Null
        $mergeManifest | ConvertTo-Json -Depth 10 | Set-Content $mergePath
        
        # Create memory index
        $memoryIndex = @{
            sovereign_threads = @()
            active_scrolls = @()
            quantum_states = @()
        }
        
        # Process Chronicle
        $chronicle = Get-Content (Join-Path $CONFIG.PATHS.SCROLLS "OrbX3_SovereignMemory_Chronicle.md")
        foreach ($line in $chronicle) {
            if ($line -match "^### SCROLL_") {
                $memoryIndex.active_scrolls += $line.Replace("### ", "")
            }
            if ($line -match "^- Thread:") {
                $memoryIndex.sovereign_threads += $line.Replace("- Thread: ", "")
            }
            if ($line -match "Mode: QUANTUM") {
                $memoryIndex.quantum_states += "ACTIVE"
            }
        }
        
        # Write memory index
        $indexPath = Join-Path $CONFIG.PATHS.CODEX "AI\memory_index.json"
        $memoryIndex | ConvertTo-Json -Depth 10 | Set-Content $indexPath
        
        # Create merge completion signal
        $signalPath = Join-Path $CONFIG.PATHS.CODEX "AI\merge_complete.signal"
        @{
            status = "COMPLETE"
            timestamp = $CONFIG.TIMESTAMP
            threads_merged = $memoryIndex.sovereign_threads.Count
            scrolls_indexed = $memoryIndex.active_scrolls.Count
            quantum_states = $memoryIndex.quantum_states.Count
        } | ConvertTo-Json | Set-Content $signalPath
        
        Write-LogEntry "INFO" "Navigator memories successfully merged into Codex-AI"
        Send-SilentNotification "Navigator memory merge complete - Codex-AI updated"
        return $true
    }
    catch {
        Write-LogEntry "ERROR" "Memory merge failed: $_"
        throw
    }
}

# Execute merge
try {
    Merge-NavigatorMemories
    Write-LogEntry "INFO" "Memory merge operation completed successfully"
    return $true
}
catch {
    Write-LogEntry "ERROR" "Memory merge operation failed: $_"
    return $false
}
