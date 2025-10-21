#!/bin/bash
# Claude Orchestrator Proof-of-Concept
# Demonstrates Claude dynamically creating tmux panes and reacting to outputs

set -euo pipefail

BRIDGE="./scripts/claude-tmux-bridge.sh"
SESSION="claude-poc"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[Claude POC]${NC} $*"
}

success() {
    echo -e "${GREEN}[Claude POC]${NC} $*"
}

# Cleanup on exit
cleanup() {
    log "Cleaning up session..."
    $BRIDGE session-kill $SESSION 2>/dev/null || true
}
trap cleanup EXIT

# Main orchestration flow
main() {
    log "Starting Claude-controlled tmux orchestration POC"
    echo ""

    # ========================================================================
    # PHASE 1: Task Analysis (simulated Claude reasoning)
    # ========================================================================
    log "PHASE 1: Analyzing task requirements..."
    log "Task: Run server and tests in parallel, monitor for failures"
    log "Decision: Need 3 panes - server, tests, monitor"
    sleep 1
    echo ""

    # ========================================================================
    # PHASE 2: Session Creation
    # ========================================================================
    log "PHASE 2: Creating tmux session '$SESSION'..."
    $BRIDGE session-create $SESSION > /dev/null 2>&1
    success "Session created"
    sleep 1
    echo ""

    # ========================================================================
    # PHASE 3: Dynamic Pane Creation
    # ========================================================================
    log "PHASE 3: Creating panes based on task requirements..."

    log "  Creating pane for: server"
    $BRIDGE pane-create $SESSION server > /dev/null 2>&1
    sleep 0.5

    log "  Creating pane for: tests"
    $BRIDGE pane-create $SESSION tests > /dev/null 2>&1
    sleep 0.5

    log "  Creating pane for: monitor"
    $BRIDGE pane-create $SESSION monitor > /dev/null 2>&1
    success "All panes created (4 total including initial)"
    sleep 1
    echo ""

    # ========================================================================
    # PHASE 4: Parallel Execution
    # ========================================================================
    log "PHASE 4: Executing commands in parallel..."

    log "  Pane 0: Starting simulated server..."
    $BRIDGE pane-exec $SESSION 0 "echo 'Server starting...'; sleep 2; echo 'Uvicorn running on http://0.0.0.0:8000'; while true; do echo 'Request received'; sleep 3; done" > /dev/null 2>&1

    log "  Pane 1: Running simulated tests..."
    $BRIDGE pane-exec $SESSION 1 "echo 'Running tests...'; sleep 1; echo 'test_health.py::test_health PASSED'; sleep 1; echo 'test_main.py::test_create FAILED'; echo '5 passed, 1 failed'" > /dev/null 2>&1

    log "  Pane 2: Starting monitor..."
    $BRIDGE pane-exec $SESSION 2 "echo 'Monitor active'; echo 'Watching for failures...'" > /dev/null 2>&1

    success "All commands dispatched"
    sleep 3
    echo ""

    # ========================================================================
    # PHASE 5: Output Monitoring & Analysis
    # ========================================================================
    log "PHASE 5: Monitoring outputs (Claude analyzing results)..."
    echo ""

    log "Checking server status..."
    server_output=$($BRIDGE pane-capture $SESSION 0 10 2>/dev/null | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//')
    if echo "$server_output" | grep -q "Uvicorn running"; then
        success "✓ Server is running"
    else
        log "⚠ Server not detected"
    fi
    sleep 1

    log "Checking test results..."
    test_output=$($BRIDGE pane-capture $SESSION 1 10 2>/dev/null | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//')
    if echo "$test_output" | grep -q "FAILED"; then
        log "⚠ Tests have failures detected!"
        sleep 1
        echo ""

        # ========================================================================
        # PHASE 6: Intelligent Reaction (Claude decides next action)
        # ========================================================================
        log "PHASE 6: Claude decision - tests failed, spawning aider..."

        log "  Creating pane for: aider"
        $BRIDGE pane-create $SESSION aider > /dev/null 2>&1

        log "  Pane 3: Starting AI-assisted debugging..."
        $BRIDGE pane-exec $SESSION 3 "echo 'Aider analyzing failures...'; sleep 2; echo 'Proposed fix: Update test_create assertion'; echo 'Fix applied'; echo 'Re-running tests...'" > /dev/null 2>&1

        success "Aider engaged for automatic fixing"
        sleep 4
        echo ""

        # Re-check after fix
        log "Re-checking aider pane output..."
        aider_output=$($BRIDGE pane-capture $SESSION 3 10 2>/dev/null | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//')
        if echo "$aider_output" | grep -q "Fix applied"; then
            success "✓ Aider has applied fixes"
        fi
    else
        success "✓ All tests passed"
    fi
    sleep 1
    echo ""

    # ========================================================================
    # PHASE 7: Session Summary
    # ========================================================================
    log "PHASE 7: Final session summary..."
    $BRIDGE session-list 2>/dev/null | grep -A 10 "Active sessions" || true
    echo ""

    success "=== POC Complete ==="
    echo ""
    echo "What happened:"
    echo "  1. Claude analyzed task requirements"
    echo "  2. Dynamically created 4 panes based on needs"
    echo "  3. Executed parallel commands (server + tests + monitor)"
    echo "  4. Monitored outputs automatically"
    echo "  5. Detected test failure in real-time"
    echo "  6. Intelligently spawned aider pane to fix issues"
    echo "  7. All without human intervention"
    echo ""
    echo "To view the live session:"
    echo "  tmux attach -t $SESSION"
    echo ""
    echo "To kill the session:"
    echo "  make claude-session-kill SESSION=$SESSION"
    echo ""
    echo "Press Ctrl+C to exit and cleanup, or wait 30s for auto-cleanup..."
    sleep 30
}

main "$@"
