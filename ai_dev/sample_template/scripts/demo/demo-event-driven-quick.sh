#!/usr/bin/env bash
# Quick event-driven demo - shows dynamic pane spawning in ~20 seconds
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$SCRIPT_DIR/claude-tmux-bridge.sh"
DAEMON="$SCRIPT_DIR/claude-tmux-daemon.sh"
SESSION="event-demo"

# Enhanced cleanup function with daemon lifecycle management
cleanup() {
    # Kill this session
    $BRIDGE session-kill "$SESSION" 2>/dev/null || true

    # Check if any other tmux sessions exist
    local other_sessions=0
    if tmux list-sessions 2>/dev/null | grep -v "^${SESSION}:" > /dev/null 2>&1; then
        other_sessions=$(tmux list-sessions 2>/dev/null | grep -v "^${SESSION}:" | wc -l)
    fi

    if [ "$other_sessions" -eq 0 ]; then
        # We're the last session, stop daemon to prevent orphaning
        if $DAEMON status 2>/dev/null | grep -q "Daemon is running"; then
            echo "No other sessions running, stopping daemon..."
            $DAEMON stop > /dev/null 2>&1 || true
        fi
    fi
}
trap cleanup EXIT

echo "🎬 Event-Driven Pane Orchestration Demo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initial cleanup of old session
$BRIDGE session-kill "$SESSION" 2>/dev/null || true

# Create session
echo "Creating session '$SESSION'..."
$BRIDGE session-create "$SESSION" >/dev/null 2>&1

# Create base panes
echo "Creating 3 base panes (orchestrator, monitor, logger)..."
$BRIDGE pane-create "$SESSION" "orchestrator" >/dev/null 2>&1
$BRIDGE pane-create "$SESSION" "monitor" >/dev/null 2>&1
$BRIDGE pane-create "$SESSION" "logger" >/dev/null 2>&1

# Start orchestrator
$BRIDGE pane-exec "$SESSION" 0 "
echo '🎯 ORCHESTRATOR: Starting...';
sleep 2;
echo 'Stage 1: ANALYSIS';
echo 'TRIGGER:ANALYSIS';
sleep 3;
echo 'Stage 2: BUILD';
echo 'TRIGGER:BUILD';
sleep 3;
echo 'Stage 3: DEPLOY';
echo 'TRIGGER:DEPLOY';
sleep 3;
echo '✅ Complete!'
" >/dev/null 2>&1

# Start monitor
$BRIDGE pane-exec "$SESSION" 1 "while true; do echo \"📊 Monitor: \$RANDOM tasks | \$(date +%H:%M:%S)\"; sleep 2; done" >/dev/null 2>&1

# Start logger
$BRIDGE pane-exec "$SESSION" 2 "while true; do echo \"📝 Log: Ready | \$(date +%H:%M:%S)\"; sleep 3; done" >/dev/null 2>&1

echo "✓ Base panes running"
echo ""
sleep 3

# Wait for ANALYSIS trigger
echo "Waiting for ANALYSIS trigger..."
for i in {1..20}; do
    if $BRIDGE pane-capture "$SESSION" 0 50 2>/dev/null | grep -q "TRIGGER:ANALYSIS"; then
        echo "✓ Event detected: ANALYSIS"
        break
    fi
    sleep 0.5
done

# Spawn analysis workers
echo "Spawning 2 analysis workers..."
$BRIDGE pane-create "$SESSION" "linter" >/dev/null 2>&1
linter_id=$($BRIDGE pane-find "$SESSION" "linter" 2>/dev/null | jq -r ".pane_id")
$BRIDGE pane-exec "$SESSION" "$linter_id" "echo '🔍 LINTER: Analyzing...'; sleep 2; echo '✅ Done'" >/dev/null 2>&1

$BRIDGE pane-create "$SESSION" "types" >/dev/null 2>&1
types_id=$($BRIDGE pane-find "$SESSION" "types" 2>/dev/null | jq -r ".pane_id")
$BRIDGE pane-exec "$SESSION" "$types_id" "echo '🔬 TYPES: Checking...'; sleep 2; echo '✅ Done'" >/dev/null 2>&1

echo "✓ Analysis workers spawned (panes: $linter_id, $types_id)"
echo ""
sleep 4

# Wait for BUILD trigger
echo "Waiting for BUILD trigger..."
for i in {1..20}; do
    if $BRIDGE pane-capture "$SESSION" 0 50 2>/dev/null | grep -q "TRIGGER:BUILD"; then
        echo "✓ Event detected: BUILD"
        break
    fi
    sleep 0.5
done

# Close analysis workers
echo "Closing analysis workers..."
$BRIDGE pane-kill "$SESSION" "$linter_id" >/dev/null 2>&1
$BRIDGE pane-kill "$SESSION" "$types_id" >/dev/null 2>&1
sleep 0.5

# Spawn build worker
echo "Spawning build worker..."
$BRIDGE pane-create "$SESSION" "compiler" >/dev/null 2>&1
compiler_id=$($BRIDGE pane-find "$SESSION" "compiler" 2>/dev/null | jq -r ".pane_id")
$BRIDGE pane-exec "$SESSION" "$compiler_id" "echo '⚙️ COMPILER: Building...'; sleep 2; echo '✅ Done'" >/dev/null 2>&1
echo "✓ Build worker spawned (pane: $compiler_id)"
echo ""
sleep 4

# Wait for DEPLOY trigger
echo "Waiting for DEPLOY trigger..."
for i in {1..20}; do
    if $BRIDGE pane-capture "$SESSION" 0 50 2>/dev/null | grep -q "TRIGGER:DEPLOY"; then
        echo "✓ Event detected: DEPLOY"
        break
    fi
    sleep 0.5
done

# Close build worker
echo "Closing build worker..."
$BRIDGE pane-kill "$SESSION" "$compiler_id" >/dev/null 2>&1
sleep 0.5

# Spawn deploy worker
echo "Spawning deploy worker..."
$BRIDGE pane-create "$SESSION" "deployer" >/dev/null 2>&1
deployer_id=$($BRIDGE pane-find "$SESSION" "deployer" 2>/dev/null | jq -r ".pane_id")
$BRIDGE pane-exec "$SESSION" "$deployer_id" "echo '🚀 DEPLOYER: Deploying...'; sleep 2; echo '✅ Done'" >/dev/null 2>&1
echo "✓ Deploy worker spawned (pane: $deployer_id)"
echo ""
sleep 3

# Final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Demo Complete!"
echo ""
echo "Summary:"
echo "  • Started with 3 base panes"
echo "  • Detected 3 triggers (ANALYSIS, BUILD, DEPLOY)"
echo "  • Spawned 5 workers dynamically"
echo "  • Closed 3 workers when done"
echo "  • Peak: 6 panes | Final: 4 panes"
echo ""
echo "Session '$SESSION' is still running."
echo "Attach with: tmux attach -t $SESSION"
echo ""
echo "Press Enter to cleanup..."
read

# Cleanup will be handled by the EXIT trap
echo "✓ Cleanup complete"
