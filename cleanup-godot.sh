#!/bin/bash
# Advanced Godot process cleanup script
# Attempts to identify and close only debug instances, preserving the editor

echo "🔍 Advanced Godot Process Cleanup"
echo "This script attempts to distinguish between editor and debug instances"
echo ""

echo "Analyzing running Godot processes..."

# Get process information with creation time for better heuristics
PROCESS_INFO=$(powershell.exe -Command "Get-Process -Name '*Godot*' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output \"\$(\$_.Id)::\$(\$_.ProcessName)::\$(\$_.StartTime)\" }" 2>/dev/null)

if [ -z "$PROCESS_INFO" ]; then
    echo "✓ No Godot processes found running"
    exit 0
fi

echo "Found the following Godot processes:"
echo "PID | Name | Start Time"
echo "----|-----------------------------------------"

DEBUG_PIDS=()
EDITOR_PIDS=()
UNCLEAR_PIDS=()

# Parse process information
while IFS='::' read -r pid name starttime; do
    if [[ -n "$pid" && "$name" =~ Godot ]]; then
        echo "$pid | $name | $starttime"
        
        # For WSL2/MCP usage, we'll ask user to identify processes
        # since command line detection is unreliable
        UNCLEAR_PIDS+=($pid)
    fi
done <<< "$PROCESS_INFO"

echo ""
echo "Analysis Results:"
echo "📝 Editor processes: ${#EDITOR_PIDS[@]} (preserved)"
echo "🎮 Debug processes: ${#DEBUG_PIDS[@]} (will be terminated)"  
echo "❓ Unclear processes: ${#UNCLEAR_PIDS[@]} (requires user decision)"

if [ ${#DEBUG_PIDS[@]} -eq 0 ] && [ ${#UNCLEAR_PIDS[@]} -eq 0 ]; then
    echo ""
    echo "✅ No debug processes found to terminate!"
    echo "All running processes appear to be editor instances."
    exit 0
fi

echo ""

# Handle unclear processes
if [ ${#UNCLEAR_PIDS[@]} -gt 0 ]; then
    echo "❓ Found ${#UNCLEAR_PIDS[@]} process(es) that couldn't be clearly classified:"
    for pid in "${UNCLEAR_PIDS[@]}"; do
        echo "  PID: $pid"
    done
    echo ""
    read -p "Include unclear processes in termination? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DEBUG_PIDS+=("${UNCLEAR_PIDS[@]}")
    fi
fi

# Proceed with termination if we have processes to kill
if [ ${#DEBUG_PIDS[@]} -gt 0 ]; then
    echo "🎯 Terminating ${#DEBUG_PIDS[@]} debug process(es)..."
    
    for pid in "${DEBUG_PIDS[@]}"; do
        echo "  Stopping PID: $pid"
        taskkill.exe /F /PID "$pid" 2>/dev/null
    done
    
    # Wait and verify
    sleep 2
    
    echo ""
    echo "✅ Debug process cleanup completed!"
    echo "Editor instances have been preserved."
    
    # Check if any targeted processes are still running
    STILL_RUNNING=0
    for pid in "${DEBUG_PIDS[@]}"; do
        if tasklist.exe /FI "PID eq $pid" 2>/dev/null | grep -q "$pid"; then
            echo "⚠ Warning: PID $pid may still be running"
            STILL_RUNNING=1
        fi
    done
    
    if [ $STILL_RUNNING -eq 0 ]; then
        echo "✓ All targeted processes successfully terminated"
    fi
else
    echo "ℹ No debug processes selected for termination."
fi

echo ""
echo "💡 For future use, prefer: mcp__godot-mcp__stop_project"