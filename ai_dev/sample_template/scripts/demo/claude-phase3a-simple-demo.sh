#!/usr/bin/env bash
# claude-phase3a-simple-demo.sh
# Simplified dynamic event-driven demo - robust pane management
# Session: demo-phase3a
# Duration: ~25 seconds

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$SCRIPT_DIR/claude-tmux-bridge.sh"
DAEMON="$SCRIPT_DIR/claude-tmux-daemon.sh"
SESSION="demo-phase3a"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() { echo -e "${BOLD}[DEMO]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${CYAN}ℹ${NC} $1"; }
step() { echo ""; echo -e "${BOLD}${MAGENTA}━━━ $1 ━━━${NC}"; }

# Enhanced cleanup function with daemon lifecycle management
cleanup() {
    log "Cleaning up..."

    # Kill this session
    "$BRIDGE" session-kill "$SESSION" 2>/dev/null || true

    # Clean up temp scripts
    rm -f /tmp/*-${SESSION}.sh 2>/dev/null || true

    # Check if any other tmux sessions exist
    local other_sessions=0
    if tmux list-sessions 2>/dev/null | grep -v "^${SESSION}:" > /dev/null 2>&1; then
        other_sessions=$(tmux list-sessions 2>/dev/null | grep -v "^${SESSION}:" | wc -l)
    fi

    if [ "$other_sessions" -eq 0 ]; then
        # We're the last session, stop daemon to prevent orphaning
        if "$DAEMON" status 2>/dev/null | grep -q "Daemon is running"; then
            log "No other sessions running, stopping daemon..."
            "$DAEMON" stop > /dev/null 2>&1 || true
        fi
    else
        log "Other sessions exist ($other_sessions), keeping daemon running"
    fi
}
trap cleanup EXIT

main() {
    clear
    echo -e "${BOLD}${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║       EVENT-DRIVEN PANE ORCHESTRATION - SIMPLE DEMO          ║
║           Dynamic spawning & lifecycle management            ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    info "Session: ${BOLD}$SESSION${NC} | Max panes: ${BOLD}9${NC} | Duration: ${BOLD}~25s${NC}"
    echo ""

    # Ensure daemon running
    step "Starting Event Daemon"
    if "$DAEMON" status 2>/dev/null | grep -q "Daemon is running"; then
        success "Daemon already running"
    else
        # Start daemon, handle "already running" error gracefully
        set +e
        daemon_output=$("$DAEMON" start 2>&1)
        daemon_exit=$?
        set -e

        if [ $daemon_exit -eq 0 ] || echo "$daemon_output" | grep -q "already running"; then
            success "Daemon started"
        else
            echo "$daemon_output" >&2
            warning "Daemon start failed, but continuing..."
        fi
    fi
    sleep 1

    # Create session
    step "Creating Session"
    cleanup  # Kill old session
    "$BRIDGE" session-create "$SESSION" > /dev/null
    success "Session '$SESSION' created"
    sleep 1

    # Create persistent panes (labels help us find them later)
    step "Creating Base Panes (1-3)"

    # Orchestrator pane
    cat > /tmp/orchestrator-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🎯 ORCHESTRATOR: Starting pipeline..."
sleep 2
echo "📋 Stage 1: Analysis"
echo "TRIGGER: ANALYSIS"
sleep 3
echo "📋 Stage 2: Build"
echo "TRIGGER: BUILD"
sleep 3
echo "📋 Stage 3: Test"
echo "TRIGGER: TEST"
sleep 3
echo "📋 Stage 4: Deploy"
echo "TRIGGER: DEPLOY"
sleep 4
echo "✅ Pipeline complete!"
SCRIPT
    chmod +x /tmp/orchestrator-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "orchestrator" > /dev/null
    "$BRIDGE" pane-exec "$SESSION" 0 "/tmp/orchestrator-${SESSION}.sh" > /dev/null
    success "Pane orchestrator: coordinates workflow"

    # Monitor pane
    cat > /tmp/monitor-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "📊 MONITOR: Dashboard active..."
while true; do
    sleep 2
    echo "📊 Status: Active | Tasks: $RANDOM | $(date +%H:%M:%S)"
done
SCRIPT
    chmod +x /tmp/monitor-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "monitor" > /dev/null
    "$BRIDGE" pane-exec "$SESSION" 1 "/tmp/monitor-${SESSION}.sh" > /dev/null
    success "Pane monitor: tracks system state"

    # Logger pane
    "$BRIDGE" pane-create "$SESSION" "logger" > /dev/null
    "$BRIDGE" pane-exec "$SESSION" 2 "while true; do echo \"📝 LOG [$(date +%H:%M:%S)]: Listening...\"; sleep 3; done" > /dev/null
    success "Pane logger: collects events"

    echo ""
    info "Current panes: ${BOLD}3${NC} (orchestrator, monitor, logger)"
    sleep 2

    # STAGE 1: Analysis
    step "Stage 1: Analysis (spawning workers 4-5)"
    info "Waiting for TRIGGER: ANALYSIS..."

    timeout=20
    while [ $timeout -gt 0 ]; do
        if "$BRIDGE" pane-capture "$SESSION" 0 50 | grep -q "TRIGGER: ANALYSIS"; then
            success "Event detected!"
            break
        fi
        sleep 0.5
        ((timeout--))
    done

    # Spawn analysis workers
    cat > /tmp/linter-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🔍 LINTER: Scanning..."
for i in {1..4}; do echo "  ├─ file_$i.py OK"; sleep 0.5; done
echo "✅ LINTER: Complete"
SCRIPT
    chmod +x /tmp/linter-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "linter" > /dev/null
    "$BRIDGE" pane-exec "$SESSION" 3 "/tmp/linter-${SESSION}.sh" > /dev/null
    success "Worker: linter spawned"

    cat > /tmp/types-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🔬 TYPE-CHECK: Validating..."
for i in {1..5}; do echo "  ├─ module_$i valid"; sleep 0.4; done
echo "✅ TYPE-CHECK: Complete"
SCRIPT
    chmod +x /tmp/types-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "type-check" > /dev/null
    "$BRIDGE" pane-exec "$SESSION" 4 "/tmp/types-${SESSION}.sh" > /dev/null
    success "Worker: type-checker spawned"

    echo ""
    info "Current panes: ${BOLD}5${NC} (base + 2 analysis workers)"
    sleep 3

    # STAGE 2: Build
    step "Stage 2: Build (replacing workers)"
    info "Waiting for TRIGGER: BUILD..."

    timeout=20
    while [ $timeout -gt 0 ]; do
        if "$BRIDGE" pane-capture "$SESSION" 0 50 | grep -q "TRIGGER: BUILD"; then
            success "Event detected!"
            break
        fi
        sleep 0.5
        ((timeout--))
    done

    # Close old workers using label lookup
    info "Closing analysis workers..."
    set +e
    linter_id=$("$BRIDGE" pane-find "$SESSION" "linter" 2>/dev/null | jq -r '.pane_id' 2>/dev/null)
    types_id=$("$BRIDGE" pane-find "$SESSION" "type-check" 2>/dev/null | jq -r '.pane_id' 2>/dev/null)
    set -e

    [ -n "$linter_id" ] && [ "$linter_id" != "null" ] && "$BRIDGE" pane-kill "$SESSION" "$linter_id" > /dev/null 2>&1 || true
    [ -n "$types_id" ] && [ "$types_id" != "null" ] && "$BRIDGE" pane-kill "$SESSION" "$types_id" > /dev/null 2>&1 || true
    success "Old workers closed"

    sleep 0.5  # Let tmux renumber panes

    # Spawn build workers
    cat > /tmp/build-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "⚙️  COMPILER: Building..."
for i in {1..5}; do echo "  ├─ Compiling [$((i*20))%]"; sleep 0.5; done
echo "✅ COMPILER: Build successful"
SCRIPT
    chmod +x /tmp/build-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "compiler" > /dev/null
    sleep 0.3  # Let state sync
    # Find the newly created pane ID by label
    compiler_id=$("$BRIDGE" pane-find "$SESSION" "compiler" 2>/dev/null | jq -r '.pane_id')
    if [ -n "$compiler_id" ] && [ "$compiler_id" != "null" ]; then
        "$BRIDGE" pane-exec "$SESSION" "$compiler_id" "/tmp/build-${SESSION}.sh" > /dev/null
        success "Worker: compiler spawned"
    else
        # Fallback: find the highest pane ID
        compiler_id=$("$BRIDGE" pane-list-json "$SESSION" 2>/dev/null | jq -r '.panes[-1]' || echo "3")
        "$BRIDGE" pane-exec "$SESSION" "$compiler_id" "/tmp/build-${SESSION}.sh" > /dev/null
        success "Worker: compiler spawned (fallback ID: $compiler_id)"
    fi

    echo ""
    info "Current panes: ${BOLD}4${NC} (base + 1 build worker)"
    sleep 3

    # STAGE 3: Test
    step "Stage 3: Test (adding test workers)"
    info "Waiting for TRIGGER: TEST..."

    timeout=20
    while [ $timeout -gt 0 ]; do
        if "$BRIDGE" pane-capture "$SESSION" 0 50 | grep -q "TRIGGER: TEST"; then
            success "Event detected!"
            break
        fi
        sleep 0.5
        ((timeout--))
    done

    # Add test workers (keep compiler running)
    cat > /tmp/test-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🧪 TESTS: Running suite..."
for i in {1..4}; do echo "  ├─ test_$i PASSED"; sleep 0.5; done
echo "✅ TESTS: All passed"
SCRIPT
    chmod +x /tmp/test-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "test-runner" > /dev/null
    sleep 0.3
    test_id=$("$BRIDGE" pane-find "$SESSION" "test-runner" 2>/dev/null | jq -r '.pane_id')
    if [ -n "$test_id" ] && [ "$test_id" != "null" ]; then
        "$BRIDGE" pane-exec "$SESSION" "$test_id" "/tmp/test-${SESSION}.sh" > /dev/null
        success "Worker: test-runner spawned"
    fi

    cat > /tmp/security-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🔒 SECURITY: Scanning..."
echo "  ├─ Checking CVEs..."
sleep 1
echo "  ├─ Analyzing dependencies..."
sleep 1
echo "✅ SECURITY: No vulnerabilities"
SCRIPT
    chmod +x /tmp/security-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "security" > /dev/null
    sleep 0.3
    security_id=$("$BRIDGE" pane-find "$SESSION" "security" 2>/dev/null | jq -r '.pane_id')
    if [ -n "$security_id" ] && [ "$security_id" != "null" ]; then
        "$BRIDGE" pane-exec "$SESSION" "$security_id" "/tmp/security-${SESSION}.sh" > /dev/null
        success "Worker: security scanner spawned"
    fi

    echo ""
    info "Current panes: ${BOLD}6${NC} (base + 3 test/security workers)"
    sleep 3

    # STAGE 4: Deploy
    step "Stage 4: Deploy (final stage)"
    info "Waiting for TRIGGER: DEPLOY..."

    timeout=20
    while [ $timeout -gt 0 ]; do
        if "$BRIDGE" pane-capture "$SESSION" 0 50 | grep -q "TRIGGER: DEPLOY"; then
            success "Event detected!"
            break
        fi
        sleep 0.5
        ((timeout--))
    done

    # Close test workers
    info "Closing test workers..."
    set +e
    for label in compiler test-runner security; do
        pane_id=$("$BRIDGE" pane-find "$SESSION" "$label" 2>/dev/null | jq -r '.pane_id' 2>/dev/null)
        [ -n "$pane_id" ] && [ "$pane_id" != "null" ] && "$BRIDGE" pane-kill "$SESSION" "$pane_id" > /dev/null 2>&1 || true
    done
    set -e
    success "Test workers closed"

    sleep 0.5  # Let tmux renumber panes

    # Spawn deployer
    cat > /tmp/deploy-${SESSION}.sh << 'SCRIPT'
#!/bin/bash
echo "🚀 DEPLOYER: Deploying..."
echo "  ├─ Building container..."
sleep 1
echo "  ├─ Pushing to registry..."
sleep 1
echo "  ├─ Rolling out..."
sleep 1
echo "✅ DEPLOYER: Deployment complete!"
SCRIPT
    chmod +x /tmp/deploy-${SESSION}.sh
    "$BRIDGE" pane-create "$SESSION" "deployer" > /dev/null
    sleep 0.3
    deployer_id=$("$BRIDGE" pane-find "$SESSION" "deployer" 2>/dev/null | jq -r '.pane_id')
    if [ -n "$deployer_id" ] && [ "$deployer_id" != "null" ]; then
        "$BRIDGE" pane-exec "$SESSION" "$deployer_id" "/tmp/deploy-${SESSION}.sh" > /dev/null
        success "Worker: deployer spawned"
    fi

    echo ""
    info "Current panes: ${BOLD}4${NC} (base + deployer)"
    sleep 4

    # Final summary
    step "Pipeline Complete!"

    pane_count=$("$BRIDGE" pane-count "$SESSION" | jq -r '.count')
    echo ""
    success "Final pane count: ${BOLD}$pane_count${NC}"
    echo ""

    "$BRIDGE" pane-list-detailed "$SESSION" | jq -r '.panes[] | "  • Pane \(.pane_id): \(.label // "unlabeled")"'

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║            🎉 EVENT-DRIVEN DEMO COMPLETE! 🎉                 ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}What happened:${NC}"
    echo "  1. Started with 3 base panes (orchestrator, monitor, logger)"
    echo "  2. Orchestrator emitted triggers (ANALYSIS, BUILD, TEST, DEPLOY)"
    echo "  3. Demo detected triggers and spawned/closed workers dynamically"
    echo "  4. Peak: 6 panes | Final: 4 panes | Max ever: 9 possible"
    echo ""
    echo -e "  ${CYAN}Event detection:${NC} Pattern matching on orchestrator output"
    echo -e "  ${CYAN}Worker lifecycle:${NC} Spawn → Execute → Close when done"
    echo -e "  ${CYAN}Resource mgmt:${NC} Never exceeded 6 simultaneous panes"
    echo ""
    info "Session still running: ${BOLD}tmux attach -t $SESSION${NC}"
    info "View daemon logs: ${BOLD}$DAEMON logs 50${NC}"
    echo ""

    read -p "Press Enter to cleanup and exit (or Ctrl+C to keep session)..."
}

main "$@"
