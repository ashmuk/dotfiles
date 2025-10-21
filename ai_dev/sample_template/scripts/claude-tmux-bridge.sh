#!/bin/bash
# Claude-tmux Bridge Script (MVP)
# Enables Claude Code to orchestrate tmux sessions dynamically

set -euo pipefail

# Configuration
STATE_DIR="/tmp/claude-tmux-states"
MAX_PANES=10
SESSION_TIMEOUT=7200  # 2 hours in seconds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# JSON output helper
json_output() {
    local status="$1"
    local command="$2"
    local session="${3:-}"
    local pane_id="${4:-}"
    local output="${5:-}"

    cat <<EOF
{
  "status": "$status",
  "command": "$command",
  "session": "$session",
  "pane_id": "$pane_id",
  "output": $(echo "$output" | jq -Rs .),
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# Initialize state directory
init_state_dir() {
    mkdir -p "$STATE_DIR"
}

# Session management
session_create() {
    local session_name="$1"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' already exists"
        json_output "error" "session-create" "$session_name" "" "Session already exists"
        return 1
    fi

    tmux new-session -d -s "$session_name"

    # Initialize state file
    cat > "$STATE_DIR/${session_name}.state" <<EOF
{
  "session_name": "$session_name",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "panes": [
    {
      "pane_id": 0,
      "label": "main",
      "command": "",
      "status": "idle"
    }
  ]
}
EOF

    log_success "Session '$session_name' created"
    json_output "success" "session-create" "$session_name" "0" "Session created with initial pane"
}

session_list() {
    if ! tmux list-sessions &>/dev/null; then
        log_warn "No tmux sessions running"
        json_output "success" "session-list" "" "" "No sessions"
        return 0
    fi

    local sessions
    sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")

    log_info "Active sessions:"
    echo "$sessions" | while read -r session; do
        echo "  - $session"
    done

    json_output "success" "session-list" "" "" "$sessions"
}

session_kill() {
    local session_name="$1"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "session-kill" "$session_name" "" "Session not found"
        return 1
    fi

    tmux kill-session -t "$session_name"
    rm -f "$STATE_DIR/${session_name}.state"

    log_success "Session '$session_name' killed"
    json_output "success" "session-kill" "$session_name" "" "Session terminated"
}

# Pane management
pane_create() {
    local session_name="$1"
    local label="${2:-pane}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-create" "$session_name" "" "Session not found"
        return 1
    fi

    # Count existing panes
    local pane_count
    pane_count=$(tmux list-panes -t "$session_name" | wc -l)

    if [ "$pane_count" -ge "$MAX_PANES" ]; then
        log_error "Maximum panes ($MAX_PANES) reached"
        json_output "error" "pane-create" "$session_name" "" "Max panes reached"
        return 1
    fi

    # Create new pane (alternate between horizontal and vertical splits)
    if [ $((pane_count % 2)) -eq 0 ]; then
        tmux split-window -t "$session_name" -h
    else
        tmux split-window -t "$session_name" -v
    fi

    # Get the new pane ID
    local new_pane_id
    new_pane_id=$(tmux list-panes -t "$session_name" -F "#{pane_index}" | tail -1)

    # Balance the layout for better visibility
    tmux select-layout -t "$session_name" tiled

    log_success "Pane $new_pane_id created in session '$session_name' (label: $label)"
    json_output "success" "pane-create" "$session_name" "$new_pane_id" "Pane created with label: $label"
}

pane_exec() {
    local session_name="$1"
    local pane_id="$2"
    local command="$3"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-exec" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Verify pane exists
    if ! tmux list-panes -t "$session_name" -F "#{pane_index}" | grep -q "^${pane_id}$"; then
        log_error "Pane $pane_id not found in session '$session_name'"
        json_output "error" "pane-exec" "$session_name" "$pane_id" "Pane not found"
        return 1
    fi

    # Send command to pane (use .pane_index format to target specific pane)
    tmux send-keys -t "${session_name}:.${pane_id}" "$command" C-m

    log_success "Command sent to pane $pane_id in session '$session_name'"
    json_output "success" "pane-exec" "$session_name" "$pane_id" "Command: $command"
}

pane_capture() {
    local session_name="$1"
    local pane_id="$2"
    local lines="${3:-20}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-capture" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Capture pane output (use .pane_index format)
    local output
    output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p -S "-${lines}" 2>/dev/null || echo "")

    log_info "Captured $lines lines from pane $pane_id"
    json_output "success" "pane-capture" "$session_name" "$pane_id" "$output"
}

pane_watch() {
    local session_name="$1"
    local pane_id="$2"
    local pattern="$3"
    local lines="${4:-50}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-watch" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Capture and search for pattern (use .pane_index format)
    local output
    output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p -S "-${lines}" 2>/dev/null || echo "")

    local matches
    matches=$(echo "$output" | grep -E "$pattern" || echo "")

    if [ -n "$matches" ]; then
        log_success "Pattern '$pattern' found in pane $pane_id"
        json_output "success" "pane-watch" "$session_name" "$pane_id" "$matches"
    else
        log_info "Pattern '$pattern' not found in pane $pane_id"
        json_output "success" "pane-watch" "$session_name" "$pane_id" ""
    fi
}

pane_status() {
    local session_name="$1"
    local pane_id="$2"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-status" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Get pane information
    local pane_info
    pane_info=$(tmux list-panes -t "$session_name" -F "#{pane_index}:#{pane_current_command}:#{pane_pid}" | grep "^${pane_id}:")

    if [ -z "$pane_info" ]; then
        log_error "Pane $pane_id not found"
        json_output "error" "pane-status" "$session_name" "$pane_id" "Pane not found"
        return 1
    fi

    log_info "Pane status: $pane_info"
    json_output "success" "pane-status" "$session_name" "$pane_id" "$pane_info"
}

# Help/Usage
show_usage() {
    cat <<EOF
Claude-tmux Bridge Script (MVP)

Usage: $0 <command> [arguments]

Commands:
  session-create <name>              Create new tmux session
  session-list                       List all active sessions
  session-kill <name>                Kill tmux session

  pane-create <session> [label]      Create new pane in session
  pane-exec <session> <pane> <cmd>   Execute command in pane
  pane-capture <session> <pane> [n]  Capture last n lines from pane
  pane-watch <session> <pane> <pat>  Watch pane for pattern
  pane-status <session> <pane>       Get pane status

Examples:
  $0 session-create dev-session
  $0 pane-create dev-session server
  $0 pane-exec dev-session 0 "make run"
  $0 pane-capture dev-session 0 50
  $0 pane-watch dev-session 1 "PASSED|FAILED"
  $0 session-kill dev-session

EOF
}

# Main command dispatcher
main() {
    init_state_dir

    local command="${1:-}"

    case "$command" in
        session-create)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            session_create "$2"
            ;;
        session-list)
            session_list
            ;;
        session-kill)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            session_kill "$2"
            ;;
        pane-create)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            pane_create "$2" "${3:-pane}"
            ;;
        pane-exec)
            [ $# -lt 4 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_exec "$2" "$3" "$4"
            ;;
        pane-capture)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_capture "$2" "$3" "${4:-20}"
            ;;
        pane-watch)
            [ $# -lt 4 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_watch "$2" "$3" "$4" "${5:-50}"
            ;;
        pane-status)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_status "$2" "$3"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
