#!/bin/bash
# Claude-tmux Event Daemon (Phase 3.0)
# Background process that monitors tmux events and triggers callbacks

set -euo pipefail

# Configuration
EVENT_DIR="/tmp/claude-tmux-events"
STATE_DIR="/tmp/claude-tmux-states"
DAEMON_LOG="/tmp/claude-tmux-daemon.log"
PID_FILE="/tmp/claude-tmux-daemon.pid"
POLL_INTERVAL=0.5  # 500ms for responsive event detection

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_daemon() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DAEMON_LOG"
}

log_info() {
    echo -e "${BLUE}[DAEMON]${NC} $*"
    log_daemon "INFO: $*"
}

log_success() {
    echo -e "${GREEN}[DAEMON]${NC} $*"
    log_daemon "SUCCESS: $*"
}

log_warn() {
    echo -e "${YELLOW}[DAEMON]${NC} $*"
    log_daemon "WARN: $*"
}

log_error() {
    echo -e "${RED}[DAEMON]${NC} $*"
    log_daemon "ERROR: $*"
}

# Initialize event and state directories
init_directories() {
    mkdir -p "$EVENT_DIR" "$STATE_DIR"
    log_info "Initialized directories: $EVENT_DIR, $STATE_DIR"
}

# Check if daemon is already running
is_daemon_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0  # Running
        else
            # Stale PID file
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Check for pane exits
check_pane_exits() {
    local session_name="$1"
    local state_file="$STATE_DIR/${session_name}.state"

    if [ ! -f "$state_file" ]; then
        return
    fi

    # Get current panes from tmux
    local current_panes
    current_panes=$(tmux list-panes -t "$session_name" -F "#{pane_index}" 2>/dev/null || echo "")

    # Get panes from state file
    local state_panes
    state_panes=$(jq -r '.panes[].pane_id' "$state_file" 2>/dev/null || echo "")

    # Find panes that exited (in state but not in tmux)
    for pane_id in $state_panes; do
        if ! echo "$current_panes" | grep -q "^${pane_id}$"; then
            # Pane exited - trigger event
            publish_event "$session_name" "pane-exit" "$pane_id" "Pane exited"
            log_info "Detected pane exit: $session_name pane $pane_id"
        fi
    done
}

# Check for pattern matches in pane output
check_pattern_matches() {
    local session_name="$1"
    local patterns_file="$EVENT_DIR/${session_name}/patterns"

    if [ ! -f "$patterns_file" ]; then
        return
    fi

    # Read registered patterns
    while IFS='|' read -r pane_id pattern callback; do
        [ -z "$pane_id" ] && continue

        # Capture pane output
        local output
        output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p -S -50 2>/dev/null || echo "")

        # Check for pattern match
        if echo "$output" | grep -qE "$pattern"; then
            # Pattern matched - trigger event
            publish_event "$session_name" "pattern-match" "$pane_id" "Pattern: $pattern"
            log_info "Pattern matched: $session_name pane $pane_id pattern '$pattern'"

            # Execute callback if provided
            if [ -n "$callback" ]; then
                eval "$callback" &
                log_info "Executed callback: $callback"
            fi
        fi
    done < "$patterns_file"
}

# Check for pane timeouts
check_timeouts() {
    local session_name="$1"
    local timeouts_file="$EVENT_DIR/${session_name}/timeouts"

    if [ ! -f "$timeouts_file" ]; then
        return
    fi

    local now
    now=$(date +%s)

    # Read registered timeouts
    while IFS='|' read -r pane_id deadline callback; do
        [ -z "$pane_id" ] && continue

        if [ "$now" -ge "$deadline" ]; then
            # Timeout expired - trigger event
            publish_event "$session_name" "timeout" "$pane_id" "Deadline: $deadline"
            log_warn "Timeout expired: $session_name pane $pane_id"

            # Execute callback if provided
            if [ -n "$callback" ]; then
                eval "$callback" &
                log_info "Executed timeout callback: $callback"
            fi

            # Remove this timeout
            sed -i.bak "/^${pane_id}|/d" "$timeouts_file"
        fi
    done < "$timeouts_file"
}

# Publish event to event queue
publish_event() {
    local session_name="$1"
    local event_type="$2"
    local pane_id="$3"
    local message="$4"

    local event_file="$EVENT_DIR/${session_name}/${event_type}.log"
    mkdir -p "$(dirname "$event_file")"

    # Append event in JSON format
    cat >> "$event_file" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session": "$session_name",
  "event_type": "$event_type",
  "pane_id": "$pane_id",
  "message": "$message"
}
EOF

    log_daemon "EVENT: $event_type session=$session_name pane=$pane_id msg=$message"
}

# Main event loop
event_loop() {
    local monitor_session="${1:-*}"  # * = all sessions

    log_info "Event loop started (monitoring: $monitor_session)"
    log_info "Poll interval: ${POLL_INTERVAL}s"

    while true; do
        # Get list of sessions to monitor
        local sessions
        if [ "$monitor_session" = "*" ]; then
            sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")
        else
            sessions="$monitor_session"
        fi

        # Monitor each session
        for session in $sessions; do
            [ -z "$session" ] && continue

            # Check for various events
            check_pane_exits "$session"
            check_pattern_matches "$session"
            check_timeouts "$session"
        done

        sleep "$POLL_INTERVAL"
    done
}

# Daemon start
daemon_start() {
    local session="${1:-*}"

    if is_daemon_running; then
        log_error "Daemon already running (PID: $(cat $PID_FILE))"
        return 1
    fi

    init_directories

    log_info "Starting daemon..."
    log_info "Monitor session: $session"
    log_info "Log file: $DAEMON_LOG"
    log_info "PID file: $PID_FILE"

    # Start daemon in background
    (
        event_loop "$session"
    ) &

    local daemon_pid=$!
    echo "$daemon_pid" > "$PID_FILE"
    sleep 1

    if ps -p "$daemon_pid" > /dev/null 2>&1; then
        log_success "Daemon started successfully (PID: $daemon_pid)"
        return 0
    else
        log_error "Daemon failed to start"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Daemon stop
daemon_stop() {
    if ! is_daemon_running; then
        log_warn "Daemon not running"
        return 1
    fi

    local pid
    pid=$(cat "$PID_FILE")

    log_info "Stopping daemon (PID: $pid)..."
    kill "$pid" 2>/dev/null || true

    # Wait for process to exit
    local count=0
    while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 10 ]; do
        sleep 0.5
        count=$((count + 1))
    done

    if ps -p "$pid" > /dev/null 2>&1; then
        log_warn "Daemon didn't stop gracefully, force killing..."
        kill -9 "$pid" 2>/dev/null || true
    fi

    rm -f "$PID_FILE"
    log_success "Daemon stopped"
}

# Daemon status
daemon_status() {
    if is_daemon_running; then
        local pid
        pid=$(cat "$PID_FILE")
        log_success "Daemon is running (PID: $pid)"

        # Show stats
        echo ""
        echo "Event directory: $EVENT_DIR"
        echo "Log file: $DAEMON_LOG"
        echo "Uptime: $(ps -p "$pid" -o etime= | tr -d ' ')"

        # Count events
        local event_count
        event_count=$(find "$EVENT_DIR" -name "*.log" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
        echo "Total events: $event_count"

        return 0
    else
        log_info "Daemon is not running"
        return 1
    fi
}

# Daemon logs
daemon_logs() {
    local lines="${1:-50}"

    if [ ! -f "$DAEMON_LOG" ]; then
        log_warn "No log file found"
        return 1
    fi

    tail -n "$lines" "$DAEMON_LOG"
}

# Event subscription
event_subscribe() {
    local session_name="$1"
    local event_type="$2"
    local pane_id="${3:-}"
    local pattern="${4:-}"
    local callback="${5:-}"

    mkdir -p "$EVENT_DIR/$session_name"

    case "$event_type" in
        pattern-match)
            if [ -z "$pane_id" ] || [ -z "$pattern" ]; then
                log_error "pattern-match requires pane_id and pattern"
                return 1
            fi

            local patterns_file="$EVENT_DIR/${session_name}/patterns"
            echo "${pane_id}|${pattern}|${callback}" >> "$patterns_file"
            log_success "Subscribed to pattern '$pattern' on pane $pane_id"
            ;;

        timeout)
            if [ -z "$pane_id" ] || [ -z "$pattern" ]; then
                log_error "timeout requires pane_id and deadline (seconds)"
                return 1
            fi

            local deadline=$(($(date +%s) + pattern))
            local timeouts_file="$EVENT_DIR/${session_name}/timeouts"
            echo "${pane_id}|${deadline}|${callback}" >> "$timeouts_file"
            log_success "Set timeout for pane $pane_id (deadline: $deadline)"
            ;;

        pane-exit)
            log_info "pane-exit events are automatic (no subscription needed)"
            ;;

        *)
            log_error "Unknown event type: $event_type"
            return 1
            ;;
    esac
}

# Show usage
show_usage() {
    cat <<EOF
Claude-tmux Event Daemon (Phase 3.0)

Usage: $0 <command> [arguments]

Daemon Lifecycle:
  start [session]         Start event daemon (default: monitor all sessions)
  stop                    Stop event daemon
  status                  Show daemon status
  logs [lines]            Show daemon logs (default: 50 lines)
  restart [session]       Restart daemon

Event Subscription:
  subscribe <session> pattern-match <pane> <pattern> [callback]
  subscribe <session> timeout <pane> <seconds> [callback]

Examples:
  # Start daemon
  $0 start                # Monitor all sessions
  $0 start dev            # Monitor only 'dev' session

  # Check status
  $0 status
  $0 logs 100

  # Subscribe to events
  $0 subscribe dev pattern-match 0 "ERROR" "echo 'Error detected'"
  $0 subscribe dev timeout 1 60 "echo 'Timeout!'"

  # Stop daemon
  $0 stop

EOF
}

# Main command dispatcher
main() {
    local command="${1:-help}"

    case "$command" in
        start)
            daemon_start "${2:-*}"
            ;;
        stop)
            daemon_stop
            ;;
        status)
            daemon_status
            ;;
        logs)
            daemon_logs "${2:-50}"
            ;;
        restart)
            daemon_stop
            sleep 1
            daemon_start "${2:-*}"
            ;;
        subscribe)
            shift
            event_subscribe "$@"
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

# Run main
main "$@"
