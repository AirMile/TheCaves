#!/bin/bash
# Simple Godot cleanup script for testing

echo "🔍 Simple Godot Process Cleanup"
echo ""

echo "Listing all Godot processes:"
tasklist.exe | grep -i Godot

echo ""
echo "Getting process details:"
powershell.exe -Command "Get-Process -Name '*Godot*' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output \"\$(\$_.Id) - \$(\$_.ProcessName) - \$(\$_.StartTime)\" }"

echo ""
read -p "Which PIDs should be terminated (space-separated, or 'all' for everything except the first one)? " -r PIDS_TO_KILL

if [[ "$PIDS_TO_KILL" == "all" ]]; then
    # Get all PIDs except the first (oldest) one
    ALL_PIDS=($(powershell.exe -Command "Get-Process -Name '*Godot*' -ErrorAction SilentlyContinue | Sort-Object StartTime | ForEach-Object { Write-Output \$_.Id }"))
    if [ ${#ALL_PIDS[@]} -gt 1 ]; then
        PIDS_TO_KILL="${ALL_PIDS[@]:1}"  # Skip first PID
        echo "Will terminate PIDs: $PIDS_TO_KILL (preserving ${ALL_PIDS[0]})"
    else
        echo "Only one process found, nothing to terminate."
        exit 0
    fi
fi

if [[ -n "$PIDS_TO_KILL" && "$PIDS_TO_KILL" != "all" ]]; then
    echo "Terminating PIDs: $PIDS_TO_KILL"
    for pid in $PIDS_TO_KILL; do
        echo "Killing PID: $pid"
        taskkill.exe /F /PID "$pid" 2>/dev/null
    done
    
    echo ""
    echo "Cleanup completed!"
    echo "Remaining Godot processes:"
    tasklist.exe | grep -i Godot
else
    echo "No PIDs specified for termination."
fi