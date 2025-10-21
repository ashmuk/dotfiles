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

    # Update state file with new pane
    state_sync "$session_name" >/dev/null 2>&1

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

# NEW: Kill individual pane
pane_kill() {
    local session_name="$1"
    local pane_id="$2"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-kill" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Verify pane exists
    if ! tmux list-panes -t "$session_name" -F "#{pane_index}" | grep -q "^${pane_id}$"; then
        log_error "Pane $pane_id not found in session '$session_name'"
        json_output "error" "pane-kill" "$session_name" "$pane_id" "Pane not found"
        return 1
    fi

    # Kill the pane
    tmux kill-pane -t "${session_name}:.${pane_id}"

    log_success "Pane $pane_id killed in session '$session_name'"
    json_output "success" "pane-kill" "$session_name" "$pane_id" "Pane terminated"
}

# NEW: Check if pane process is still running
pane_is_running() {
    local session_name="$1"
    local pane_id="$2"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-is-running" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Get pane PID and command
    local pane_info
    pane_info=$(tmux list-panes -t "$session_name" -F "#{pane_index}:#{pane_pid}:#{pane_current_command}" | grep "^${pane_id}:")

    if [ -z "$pane_info" ]; then
        log_error "Pane $pane_id not found"
        json_output "error" "pane-is-running" "$session_name" "$pane_id" "Pane not found"
        return 1
    fi

    local pid
    pid=$(echo "$pane_info" | cut -d: -f2)
    local cmd
    cmd=$(echo "$pane_info" | cut -d: -f3)

    # Check if shell is idle (zsh/bash) or running actual command
    if [ "$cmd" = "zsh" ] || [ "$cmd" = "bash" ] || [ "$cmd" = "sh" ]; then
        # Shell is idle, command completed
        log_info "Pane $pane_id is idle (shell prompt)"
        json_output "success" "pane-is-running" "$session_name" "$pane_id" "false"
        return 1
    else
        # Command still running
        log_info "Pane $pane_id is running: $cmd (PID: $pid)"
        json_output "success" "pane-is-running" "$session_name" "$pane_id" "true"
        return 0
    fi
}

# NEW: Wait for pane to complete (with optional timeout)
pane_wait() {
    local session_name="$1"
    local pane_id="$2"
    local timeout="${3:-0}"  # 0 = no timeout

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-wait" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    local elapsed=0
    local check_interval=1

    log_info "Waiting for pane $pane_id to complete (timeout: ${timeout}s)..."

    while true; do
        # Check if pane is still running
        if ! pane_is_running "$session_name" "$pane_id" >/dev/null 2>&1; then
            log_success "Pane $pane_id completed after ${elapsed}s"
            json_output "success" "pane-wait" "$session_name" "$pane_id" "Pane completed after ${elapsed}s"
            return 0
        fi

        # Check timeout
        if [ "$timeout" -gt 0 ] && [ "$elapsed" -ge "$timeout" ]; then
            log_warn "Pane $pane_id still running after ${timeout}s timeout"
            json_output "error" "pane-wait" "$session_name" "$pane_id" "Timeout after ${timeout}s"
            return 1
        fi

        sleep "$check_interval"
        elapsed=$((elapsed + check_interval))
    done
}

# NEW: List all panes with metadata as JSON
pane_list_json() {
    local session_name="$1"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-list-json" "$session_name" "" "Session not found"
        return 1
    fi

    # Get all panes with their info
    local panes_json="["
    local first=true

    while IFS=: read -r pane_idx pane_pid pane_cmd pane_width pane_height; do
        if [ "$first" = true ]; then
            first=false
        else
            panes_json+=","
        fi

        # Determine if running
        local is_running="false"
        if [ "$pane_cmd" != "zsh" ] && [ "$pane_cmd" != "bash" ] && [ "$pane_cmd" != "sh" ]; then
            is_running="true"
        fi

        panes_json+=$(cat <<EOF

    {
      "pane_id": $pane_idx,
      "pid": $pane_pid,
      "command": "$pane_cmd",
      "is_running": $is_running,
      "width": $pane_width,
      "height": $pane_height
    }
EOF
)
    done < <(tmux list-panes -t "$session_name" -F "#{pane_index}:#{pane_pid}:#{pane_current_command}:#{pane_width}:#{pane_height}")

    panes_json+=$'\n  ]'

    log_info "Listed panes for session '$session_name'"
    cat <<EOF
{
  "status": "success",
  "command": "pane-list-json",
  "session": "$session_name",
  "pane_id": "",
  "output": $panes_json,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# NEW: Find pane by label (from state file)
pane_find() {
    local session_name="$1"
    local label="$2"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-find" "$session_name" "" "Session not found"
        return 1
    fi

    local state_file="$STATE_DIR/${session_name}.state"
    if [ ! -f "$state_file" ]; then
        log_error "State file not found for session '$session_name'"
        json_output "error" "pane-find" "$session_name" "" "State file not found"
        return 1
    fi

    # Search for pane by label in state file
    local pane_id
    pane_id=$(jq -r ".panes[] | select(.label == \"$label\") | .pane_id" "$state_file" 2>/dev/null || echo "")

    if [ -z "$pane_id" ] || [ "$pane_id" = "null" ]; then
        log_error "Pane with label '$label' not found"
        json_output "error" "pane-find" "$session_name" "" "Label not found: $label"
        return 1
    fi

    log_success "Found pane with label '$label': pane_id=$pane_id"
    json_output "success" "pane-find" "$session_name" "$pane_id" "Label: $label"
}

# NEW: Count active panes
pane_count() {
    local session_name="$1"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-count" "$session_name" "" "Session not found"
        return 1
    fi

    local count
    count=$(tmux list-panes -t "$session_name" | wc -l)

    log_info "Session '$session_name' has $count panes"
    json_output "success" "pane-count" "$session_name" "" "$count"
}

# NEW: Check if pane output matches pattern (returns exit code for scripting)
pane_has_pattern() {
    local session_name="$1"
    local pane_id="$2"
    local pattern="$3"
    local lines="${4:-50}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        return 1
    fi

    # Capture and search for pattern
    local output
    output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p -S "-${lines}" 2>/dev/null || echo "")

    if echo "$output" | grep -qE "$pattern"; then
        json_output "success" "pane-has-pattern" "$session_name" "$pane_id" "true" >&2
        return 0
    else
        json_output "success" "pane-has-pattern" "$session_name" "$pane_id" "false" >&2
        return 1
    fi
}

# NEW: Update state file with current pane info
state_sync() {
    local session_name="$1"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "state-sync" "$session_name" "" "Session not found"
        return 1
    fi

    local state_file="$STATE_DIR/${session_name}.state"

    # Create empty state file if it doesn't exist
    if [ ! -f "$state_file" ]; then
        echo '{"session_name":"'$session_name'","created_at":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","panes":[]}' > "$state_file"
    fi

    # Save existing state to temp file for merging
    local old_state_file="${state_file}.old"
    cp "$state_file" "$old_state_file" 2>/dev/null || true

    # Build panes array from current tmux state
    local panes_json="["
    local first=true

    while IFS=: read -r pane_idx pane_pid pane_cmd; do
        if [ "$first" = true ]; then
            first=false
        else
            panes_json+=","
        fi

        # Determine status
        local status="running"
        if [ "$pane_cmd" = "zsh" ] || [ "$pane_cmd" = "bash" ] || [ "$pane_cmd" = "sh" ]; then
            status="idle"
        fi

        # Try to get label and metadata from old state
        local label="pane-$pane_idx"
        local metadata="{}"
        if [ -f "$old_state_file" ]; then
            label=$(jq -r ".panes[] | select(.pane_id == $pane_idx) | .label // \"pane-$pane_idx\"" "$old_state_file" 2>/dev/null || echo "pane-$pane_idx")
            metadata=$(jq -c ".panes[] | select(.pane_id == $pane_idx) | .metadata // {}" "$old_state_file" 2>/dev/null || echo "{}")
        fi

        panes_json+=$(cat <<EOF

    {
      "pane_id": $pane_idx,
      "label": "$label",
      "command": "$pane_cmd",
      "status": "$status",
      "pid": $pane_pid,
      "metadata": $metadata
    }
EOF
)
    done < <(tmux list-panes -t "$session_name" -F "#{pane_index}:#{pane_pid}:#{pane_current_command}")

    panes_json+=$'\n  ]'

    # Write new state file
    cat > "$state_file" <<EOF
{
  "session_name": "$session_name",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "panes": $panes_json
}
EOF

    rm -f "$old_state_file"

    log_success "State synchronized for session '$session_name'"
    json_output "success" "state-sync" "$session_name" "" "State updated"
}

# PHASE 2: Execute command with timeout
pane_exec_timeout() {
    local session_name="$1"
    local pane_id="$2"
    local timeout="$3"
    local command="$4"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-exec-timeout" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    # Execute command
    pane_exec "$session_name" "$pane_id" "$command" >/dev/null 2>&1

    # Wait with timeout
    if pane_wait "$session_name" "$pane_id" "$timeout" >/dev/null 2>&1; then
        log_success "Command completed within ${timeout}s timeout"
        json_output "success" "pane-exec-timeout" "$session_name" "$pane_id" "Completed in time"
        return 0
    else
        log_error "Command exceeded ${timeout}s timeout"
        json_output "error" "pane-exec-timeout" "$session_name" "$pane_id" "Timeout exceeded"
        return 1
    fi
}

# PHASE 2: Watch with timeout
pane_watch_timeout() {
    local session_name="$1"
    local pane_id="$2"
    local pattern="$3"
    local timeout="$4"
    local lines="${5:-50}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-watch-timeout" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    local elapsed=0
    local check_interval=1

    log_info "Watching for pattern '$pattern' (timeout: ${timeout}s)..."

    while [ "$elapsed" -lt "$timeout" ]; do
        # Check for pattern
        if pane_has_pattern "$session_name" "$pane_id" "$pattern" "$lines" >/dev/null 2>&1; then
            local output
            output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p -S "-${lines}" 2>/dev/null | grep -E "$pattern" || echo "")
            log_success "Pattern found after ${elapsed}s"
            json_output "success" "pane-watch-timeout" "$session_name" "$pane_id" "$output"
            return 0
        fi

        sleep "$check_interval"
        elapsed=$((elapsed + check_interval))
    done

    log_error "Pattern not found within ${timeout}s"
    json_output "error" "pane-watch-timeout" "$session_name" "$pane_id" "Timeout: pattern not found"
    return 1
}

# PHASE 2: Set pane metadata
pane_metadata_set() {
    local session_name="$1"
    local pane_id="$2"
    local key="$3"
    local value="$4"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-metadata-set" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    local state_file="$STATE_DIR/${session_name}.state"
    if [ ! -f "$state_file" ]; then
        log_error "State file not found"
        json_output "error" "pane-metadata-set" "$session_name" "$pane_id" "State file not found"
        return 1
    fi

    # Update metadata using jq
    local temp_file="${state_file}.tmp"
    jq --arg pid "$pane_id" --arg key "$key" --arg value "$value" \
        '(.panes[] | select(.pane_id == ($pid | tonumber)) | .metadata[$key]) = $value' \
        "$state_file" > "$temp_file" && mv "$temp_file" "$state_file"

    log_success "Metadata set: $key=$value for pane $pane_id"
    json_output "success" "pane-metadata-set" "$session_name" "$pane_id" "Set $key=$value"
}

# PHASE 2: Get pane metadata
pane_metadata_get() {
    local session_name="$1"
    local pane_id="$2"
    local key="$3"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-metadata-get" "$session_name" "$pane_id" "Session not found"
        return 1
    fi

    local state_file="$STATE_DIR/${session_name}.state"
    if [ ! -f "$state_file" ]; then
        log_error "State file not found"
        json_output "error" "pane-metadata-get" "$session_name" "$pane_id" "State file not found"
        return 1
    fi

    # Get metadata value
    local value
    value=$(jq -r --arg pid "$pane_id" --arg key "$key" \
        '.panes[] | select(.pane_id == ($pid | tonumber)) | .metadata[$key] // "null"' \
        "$state_file" 2>/dev/null)

    if [ "$value" = "null" ] || [ -z "$value" ]; then
        log_warn "Metadata key '$key' not found for pane $pane_id"
        json_output "error" "pane-metadata-get" "$session_name" "$pane_id" "Key not found: $key"
        return 1
    fi

    log_info "Metadata: $key=$value"
    json_output "success" "pane-metadata-get" "$session_name" "$pane_id" "$value"
}

# PHASE 2: List panes with detailed info including labels
pane_list_detailed() {
    local session_name="$1"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-list-detailed" "$session_name" "" "Session not found"
        return 1
    fi

    local state_file="$STATE_DIR/${session_name}.state"

    # Build detailed JSON by merging tmux and state data
    local panes_json="["
    local first=true

    while IFS=: read -r pane_idx pane_pid pane_cmd pane_width pane_height; do
        if [ "$first" = true ]; then
            first=false
        else
            panes_json+=","
        fi

        local is_running="false"
        if [ "$pane_cmd" != "zsh" ] && [ "$pane_cmd" != "bash" ] && [ "$pane_cmd" != "sh" ]; then
            is_running="true"
        fi

        # Get label and metadata from state file
        local label="pane-$pane_idx"
        local metadata="{}"
        if [ -f "$state_file" ]; then
            label=$(jq -r ".panes[] | select(.pane_id == $pane_idx) | .label // \"pane-$pane_idx\"" "$state_file" 2>/dev/null)
            metadata=$(jq -c ".panes[] | select(.pane_id == $pane_idx) | .metadata // {}" "$state_file" 2>/dev/null)
        fi

        panes_json+=$(cat <<EOF

    {
      "pane_id": $pane_idx,
      "label": "$label",
      "pid": $pane_pid,
      "command": "$pane_cmd",
      "is_running": $is_running,
      "width": $pane_width,
      "height": $pane_height,
      "metadata": $metadata
    }
EOF
)
    done < <(tmux list-panes -t "$session_name" -F "#{pane_index}:#{pane_pid}:#{pane_current_command}:#{pane_width}:#{pane_height}")

    panes_json+=$'\n  ]'

    log_info "Listed detailed panes for session '$session_name'"
    cat <<EOF
{
  "status": "success",
  "command": "pane-list-detailed",
  "session": "$session_name",
  "pane_id": "",
  "output": $panes_json,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# PHASE 2: Create pane with custom layout
pane_create_with_layout() {
    local session_name="$1"
    local label="${2:-pane}"
    local layout="${3:-tiled}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        json_output "error" "pane-create-with-layout" "$session_name" "" "Session not found"
        return 1
    fi

    # Count existing panes
    local pane_count
    pane_count=$(tmux list-panes -t "$session_name" | wc -l)

    if [ "$pane_count" -ge "$MAX_PANES" ]; then
        log_error "Maximum panes ($MAX_PANES) reached"
        json_output "error" "pane-create-with-layout" "$session_name" "" "Max panes reached"
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

    # Apply the requested layout
    case "$layout" in
        tiled|even-horizontal|even-vertical|main-horizontal|main-vertical)
            tmux select-layout -t "$session_name" "$layout"
            ;;
        *)
            log_warn "Unknown layout '$layout', using tiled"
            tmux select-layout -t "$session_name" tiled
            ;;
    esac

    # Update state file with new pane
    state_sync "$session_name" >/dev/null 2>&1

    log_success "Pane $new_pane_id created with layout '$layout' (label: $label)"
    json_output "success" "pane-create-with-layout" "$session_name" "$new_pane_id" "Pane created with $layout layout"
}

# Help/Usage
show_usage() {
    cat <<EOF
Claude-tmux Bridge Script (MVP+)

Usage: $0 <command> [arguments]

Session Commands:
  session-create <name>              Create new tmux session
  session-list                       List all active sessions
  session-kill <name>                Kill tmux session

Pane Management:
  pane-create <session> [label]      Create new pane in session
  pane-exec <session> <pane> <cmd>   Execute command in pane
  pane-kill <session> <pane>         Kill individual pane
  pane-capture <session> <pane> [n]  Capture last n lines from pane
  pane-watch <session> <pane> <pat>  Watch pane for pattern
  pane-status <session> <pane>       Get pane status

Pane Lifecycle & State:
  pane-is-running <session> <pane>   Check if pane process is active
  pane-wait <session> <pane> [timeout] Wait for pane to complete
  pane-list-json <session>           List all panes as JSON
  pane-find <session> <label>        Find pane ID by label
  pane-count <session>               Count active panes

Decision Helpers:
  pane-has-pattern <session> <pane> <pattern> [lines]  Check pattern (exit code)
  state-sync <session>               Sync state file with tmux

Phase 2 - Advanced Features:
  pane-exec-timeout <session> <pane> <timeout> <cmd>   Execute with timeout
  pane-watch-timeout <session> <pane> <pattern> <timeout> [lines]  Watch with deadline
  pane-metadata-set <session> <pane> <key> <value>     Set custom metadata
  pane-metadata-get <session> <pane> <key>             Get metadata value
  pane-list-detailed <session>       List panes with labels & metadata
  pane-create-with-layout <session> [label] [layout]   Create with custom layout
    Layouts: tiled, main-horizontal, main-vertical, even-horizontal, even-vertical

Examples:
  # Basic workflow
  $0 session-create dev
  $0 pane-create dev server
  $0 pane-exec dev 0 "npm run dev"

  # Check if task completed
  $0 pane-is-running dev 0 && echo "Still running"

  # Wait for completion with timeout
  $0 pane-wait dev 0 30  # Wait max 30 seconds

  # Query state
  $0 pane-count dev
  $0 pane-list-json dev | jq .

  # Find and kill pane
  $0 pane-find dev server  # Returns pane_id
  $0 pane-kill dev 0

  # Conditional execution
  if $0 pane-has-pattern dev 0 "ERROR"; then
    echo "Error detected!"
  fi

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
        pane-kill)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_kill "$2" "$3"
            ;;
        pane-is-running)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_is_running "$2" "$3"
            ;;
        pane-wait)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_wait "$2" "$3" "${4:-0}"
            ;;
        pane-list-json)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            pane_list_json "$2"
            ;;
        pane-find)
            [ $# -lt 3 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_find "$2" "$3"
            ;;
        pane-count)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            pane_count "$2"
            ;;
        pane-has-pattern)
            [ $# -lt 4 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_has_pattern "$2" "$3" "$4" "${5:-50}"
            ;;
        state-sync)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            state_sync "$2"
            ;;
        pane-exec-timeout)
            [ $# -lt 5 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_exec_timeout "$2" "$3" "$4" "$5"
            ;;
        pane-watch-timeout)
            [ $# -lt 5 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_watch_timeout "$2" "$3" "$4" "$5" "${6:-50}"
            ;;
        pane-metadata-set)
            [ $# -lt 5 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_metadata_set "$2" "$3" "$4" "$5"
            ;;
        pane-metadata-get)
            [ $# -lt 4 ] && { log_error "Missing arguments"; show_usage; exit 1; }
            pane_metadata_get "$2" "$3" "$4"
            ;;
        pane-list-detailed)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            pane_list_detailed "$2"
            ;;
        pane-create-with-layout)
            [ $# -lt 2 ] && { log_error "Missing session name"; show_usage; exit 1; }
            pane_create_with_layout "$2" "${3:-pane}" "${4:-tiled}"
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
