# Phase 3.1 & 3.2 Implementation Proposal
## Claude-tmux Orchestration - Next Generation

**Date:** 2025-10-22
**Current Version:** MVP+ 3.0 (Event-Driven)
**Target Version:** MVP+ 3.2 (Enterprise-Ready)
**Status:** Proposal for Implementation

---

## Executive Summary

After successful implementation of:
- ✅ **Phase 1** - Enhanced Daemon Lifecycle (80% reduction in orphaning)
- ✅ **Phase 3.0** - Event-Driven Architecture (daemon + real-time streaming)

We now propose implementing **Phase 3.1** (Multi-Session & Persistence) and **Phase 3.2** (Interactivity & Observability) to complete the transformation to an enterprise-ready orchestration platform.

**Current State:**
- 1,126 lines in `claude-tmux-bridge.sh` (25 commands)
- 435 lines in `claude-tmux-daemon.sh` (event system)
- Event-driven architecture operational
- Real-time streaming (pane-stream, pane-tail) working
- Phase 1 cleanup improvements deployed

**Proposed Additions:**
- Multi-session coordination and groups
- Session persistence (save/restore)
- Interactive control (send keys, signals)
- Metrics collection and monitoring
- Auto garbage collection
- Estimated: +800-1000 lines total

---

## Current Capabilities Assessment

### ✅ What We Have (MVP+ 3.0)

#### Session Management (3 commands)
- `session-create` - Create new tmux session
- `session-list` - List all sessions
- `session-kill` - Terminate session

#### Pane Lifecycle (8 commands)
- `pane-create` - Create new pane
- `pane-kill` - Terminate pane
- `pane-exec` - Execute command
- `pane-capture` - Capture output (historical)
- `pane-is-running` - Check if running
- `pane-wait` - Wait for completion
- `pane-exec-timeout` - Execute with timeout
- `pane-status` - Get pane status

#### State & Discovery (6 commands)
- `state-sync` - Sync state files
- `pane-list-json` - List panes as JSON
- `pane-list-detailed` - Detailed pane info
- `pane-find` - Find pane by label
- `pane-count` - Count panes
- `pane-watch` - Watch for pattern

#### Decision Helpers (2 commands)
- `pane-has-pattern` - Check for pattern
- `pane-watch-timeout` - Watch with timeout

#### Metadata & Layout (4 commands)
- `pane-metadata-set` - Set metadata
- `pane-metadata-get` - Get metadata
- `pane-create-with-layout` - Create with layout
- Multiple layout support (tiled, horizontal, vertical)

#### Real-Time Features (2 commands - NEW in 3.0)
- `pane-stream` - Live output streaming
- `pane-tail` - Tail output (like tail -f)

#### Event System (Daemon - NEW in 3.0)
- `daemon start` - Start event daemon
- `daemon stop` - Stop daemon
- `daemon status` - Check status
- `daemon logs` - View logs
- `daemon restart` - Restart daemon
- `event subscribe` - Subscribe to events (pattern-match, timeout)

**Total: 27 commands across 2 scripts (1,561 lines)**

### ❌ What's Missing

Based on the original Phase 3 plan from `plan_30.md`, we still need:

#### Phase 3.1 Gaps
1. **Multi-Session Coordination**
   - No session groups
   - No cross-session queries
   - No session dependencies
   - No health checks

2. **Session Persistence**
   - No save/restore capability
   - Sessions lost on container restart
   - No auto-save functionality
   - No snapshot management

#### Phase 3.2 Gaps
3. **Interactive Control**
   - Can't send Ctrl+C or other keys
   - No interactive stdin
   - No signal handling

4. **Metrics Collection**
   - No CPU/memory tracking
   - No performance metrics
   - No resource limits
   - No cost analysis

5. **Auto Garbage Collection**
   - Manual cleanup still required
   - State files accumulate in /tmp
   - No TTL enforcement
   - No automatic resource reclaim

---

## Phase 3.1: Multi-Session Coordination & Persistence

**Priority:** P1 (High Business Value)
**Timeline:** 2-3 weeks
**Effort:** Medium
**Impact:** Enables enterprise workflows

### Feature 1: Multi-Session Coordination

#### Problem Statement
Currently, each session operates in isolation. There's no way to:
- Group related sessions (e.g., frontend + backend + database)
- Execute commands across multiple sessions
- Define dependencies between sessions
- Monitor health across session groups

#### Proposed Solution

##### New Commands (8 total)

```bash
# Session Groups
group-create <group-name>
group-add <group-name> <session-name>
group-remove <group-name> <session-name>
group-list [group-name]
group-exec <group-name> <command>
group-kill <group-name>

# Cross-Session Queries
sessions-list-all                    # All sessions with metadata
panes-count-global                   # Total panes across all sessions
sessions-find-pattern <pattern>      # Find sessions containing pattern

# Session Dependencies & Health
session-depends <session-a> <session-b>  # A depends on B
session-health <session>                 # Health check
session-wait-healthy <session> [timeout] # Wait for healthy state
```

##### Implementation Details

**State File Format:**
```json
// /tmp/claude-tmux-states/groups.json
{
  "groups": {
    "microservices": {
      "created_at": "2025-10-22T10:00:00Z",
      "sessions": ["api", "database", "cache"],
      "metadata": {
        "owner": "claude",
        "purpose": "dev-environment"
      }
    }
  },
  "dependencies": {
    "api": ["database", "cache"],
    "frontend": ["api"]
  }
}
```

**Health Check Logic:**
```bash
# Health states: healthy, degraded, unhealthy
session_health() {
  local session="$1"

  # Check if session exists
  if ! tmux has-session -t "$session" 2>/dev/null; then
    echo "unhealthy"
    return 1
  fi

  # Check if any pane is running
  local running_panes=$(pane_count "$session")
  if [ "$running_panes" -eq 0 ]; then
    echo "unhealthy"
    return 1
  fi

  # Check for error patterns in any pane
  local error_count=0
  for pane_id in $(get_pane_ids "$session"); do
    if pane_has_pattern "$session" "$pane_id" "ERROR|FATAL|CRASH" 20; then
      ((error_count++))
    fi
  done

  if [ "$error_count" -gt 0 ]; then
    echo "degraded"
    return 0
  fi

  echo "healthy"
  return 0
}
```

##### Use Cases

**Use Case 1: Microservices Development**
```bash
# Create group for microservices
group-create microservices

# Create and add sessions
session-create api-service
session-create db-service
session-create cache-service

group-add microservices api-service
group-add microservices db-service
group-add microservices cache-service

# Define dependencies
session-depends api-service db-service
session-depends api-service cache-service

# Start all services in dependency order
for session in db-service cache-service api-service; do
  session-wait-healthy "$session" 30 || exit 1
  pane-exec "$session" 0 "make run"
done

# Monitor all for errors
sessions-find-pattern "ERROR" | jq -r '.sessions[]'
```

**Use Case 2: Multi-Project Orchestration**
```bash
# Frontend project
session-create frontend
pane-exec frontend 0 "npm run dev"

# Backend project - depends on frontend being healthy
session-depends backend frontend
session-create backend
session-wait-healthy frontend 60
pane-exec backend 0 "python app.py"

# Check overall health
for session in frontend backend; do
  echo "$session: $(session-health $session)"
done
```

##### Testing Strategy
- Unit tests for group operations
- Dependency resolution tests
- Health check accuracy tests
- Circular dependency detection
- Concurrent group operations

##### Code Estimate
- **Functions:** ~10 new functions
- **Lines:** ~300-400 lines
- **Files:** Add to `claude-tmux-bridge.sh` or new `claude-tmux-groups.sh`

---

### Feature 2: Session Persistence

#### Problem Statement
When the container restarts or system reboots:
- All sessions are lost
- No way to restore previous state
- Long-running workflows must be manually recreated
- Configuration sharing is manual

#### Proposed Solution

##### New Commands (6 total)

```bash
# Save/Restore
session-save <session> [file]          # Save session state
session-restore <file>                 # Restore from snapshot
session-autosave <session> <interval>  # Auto-save every N seconds
session-autosave-stop <session>        # Stop auto-save

# Snapshot Management
session-snapshots [session]            # List available snapshots
session-snapshot-delete <file>         # Delete snapshot
```

##### Snapshot File Format

```json
{
  "version": "3.1.0",
  "session_name": "dev-work",
  "saved_at": "2025-10-22T10:30:00Z",
  "layout": {
    "window_layout": "1234,160x48,0,0{80x48,0,0,0,79x48,81,0[79x24,81,0,1,79x23,81,25,2]}"
  },
  "panes": [
    {
      "pane_id": 0,
      "label": "server",
      "working_dir": "/workspace",
      "command": "make run",
      "metadata": {
        "role": "primary",
        "auto_restart": true
      },
      "history": ["ls", "cd /workspace", "make run"],
      "environment": {
        "PATH": "/usr/local/bin:/usr/bin",
        "CUSTOM_VAR": "value"
      }
    },
    {
      "pane_id": 1,
      "label": "tests",
      "working_dir": "/workspace",
      "command": "pytest --watch",
      "metadata": {
        "role": "secondary"
      },
      "history": ["pytest"],
      "environment": {}
    }
  ],
  "metadata": {
    "group": "microservices",
    "tags": ["development", "testing"]
  }
}
```

##### Implementation Details

**Save Function:**
```bash
session_save() {
  local session_name="$1"
  local output_file="${2:-$STATE_DIR/snapshots/${session_name}-$(date +%s).snapshot}"

  # Verify session exists
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    json_output "error" "session-save" "$session_name" "" "Session not found"
    return 1
  fi

  # Create snapshot directory
  mkdir -p "$STATE_DIR/snapshots"

  # Capture layout
  local layout=$(tmux display-message -p -t "$session_name" '#{window_layout}')

  # Build panes array
  local panes_json=$(build_panes_snapshot "$session_name")

  # Get metadata
  local metadata=$(get_session_metadata "$session_name")

  # Write snapshot
  cat > "$output_file" <<EOF
{
  "version": "3.1.0",
  "session_name": "$session_name",
  "saved_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "layout": {
    "window_layout": "$layout"
  },
  "panes": $panes_json,
  "metadata": $metadata
}
EOF

  log_success "Session '$session_name' saved to $output_file"
  json_output "success" "session-save" "$session_name" "" "$output_file"
}

build_panes_snapshot() {
  local session_name="$1"
  local state_file="$STATE_DIR/${session_name}.state"

  # Extract pane information
  local panes=()
  local pane_count=$(tmux list-panes -t "$session_name" | wc -l)

  for i in $(seq 0 $((pane_count - 1))); do
    local label=$(pane_metadata_get "$session_name" "$i" "label" | jq -r '.output')
    local cwd=$(tmux display-message -p -t "${session_name}:.${i}" '#{pane_current_path}')
    local cmd=$(tmux display-message -p -t "${session_name}:.${i}" '#{pane_current_command}')

    # Get full metadata
    local metadata=$(get_pane_full_metadata "$session_name" "$i")

    panes+=($(cat <<PANE_JSON
{
  "pane_id": $i,
  "label": "$label",
  "working_dir": "$cwd",
  "command": "$cmd",
  "metadata": $metadata
}
PANE_JSON
))
  done

  # Combine into JSON array
  echo "${panes[@]}" | jq -s .
}
```

**Restore Function:**
```bash
session_restore() {
  local snapshot_file="$1"

  # Validate snapshot
  if [ ! -f "$snapshot_file" ]; then
    json_output "error" "session-restore" "" "" "Snapshot file not found"
    return 1
  fi

  # Parse snapshot
  local session_name=$(jq -r '.session_name' "$snapshot_file")
  local layout=$(jq -r '.layout.window_layout' "$snapshot_file")

  # Check if session already exists
  if tmux has-session -t "$session_name" 2>/dev/null; then
    log_error "Session '$session_name' already exists"
    json_output "error" "session-restore" "$session_name" "" "Session already exists"
    return 1
  fi

  # Create session
  session_create "$session_name"

  # Restore panes
  jq -c '.panes[]' "$snapshot_file" | while read -r pane; do
    local pane_id=$(echo "$pane" | jq -r '.pane_id')
    local label=$(echo "$pane" | jq -r '.label')
    local command=$(echo "$pane" | jq -r '.command')
    local working_dir=$(echo "$pane" | jq -r '.working_dir')

    # Create pane if not first (first pane already exists)
    if [ "$pane_id" -gt 0 ]; then
      pane_create "$session_name" "$label"
    fi

    # Set working directory
    tmux send-keys -t "${session_name}:.${pane_id}" "cd $working_dir" C-m

    # Execute command if specified
    if [ "$command" != "bash" ] && [ -n "$command" ]; then
      pane_exec "$session_name" "$pane_id" "$command"
    fi

    # Restore metadata
    local metadata=$(echo "$pane" | jq -c '.metadata')
    echo "$metadata" | jq -r 'to_entries[] | "\(.key)=\(.value)"' | while IFS='=' read -r key value; do
      pane_metadata_set "$session_name" "$pane_id" "$key" "$value"
    done
  done

  # Apply layout (if possible)
  if [ -n "$layout" ] && [ "$layout" != "null" ]; then
    tmux select-layout -t "$session_name" "$layout" 2>/dev/null || true
  fi

  log_success "Session '$session_name' restored from $snapshot_file"
  json_output "success" "session-restore" "$session_name" "" "Session restored"
}
```

**Auto-Save Implementation:**
```bash
session_autosave() {
  local session_name="$1"
  local interval="${2:-300}"  # Default 5 minutes

  # Create autosave script
  local autosave_script="/tmp/claude-tmux-autosave-${session_name}.sh"

  cat > "$autosave_script" <<'EOF'
#!/bin/bash
SESSION="$1"
INTERVAL="$2"
BRIDGE="$3"

while true; do
  sleep "$INTERVAL"

  # Check if session still exists
  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    exit 0
  fi

  # Save snapshot
  "$BRIDGE" session-save "$SESSION" "/tmp/claude-tmux-states/snapshots/${SESSION}-autosave.snapshot"
done
EOF

  chmod +x "$autosave_script"

  # Start autosave in background
  nohup "$autosave_script" "$session_name" "$interval" "$0" > /dev/null 2>&1 &
  local autosave_pid=$!

  # Store PID for later termination
  echo "$autosave_pid" > "/tmp/claude-tmux-autosave-${session_name}.pid"

  log_success "Auto-save enabled for '$session_name' (interval: ${interval}s, PID: $autosave_pid)"
  json_output "success" "session-autosave" "$session_name" "" "Auto-save enabled"
}

session_autosave_stop() {
  local session_name="$1"
  local pid_file="/tmp/claude-tmux-autosave-${session_name}.pid"

  if [ -f "$pid_file" ]; then
    local pid=$(cat "$pid_file")
    if ps -p "$pid" > /dev/null 2>/dev/null; then
      kill "$pid"
      rm -f "$pid_file"
      log_success "Auto-save stopped for '$session_name'"
      json_output "success" "session-autosave-stop" "$session_name" "" "Auto-save stopped"
    else
      rm -f "$pid_file"
      log_warn "Auto-save PID not found"
      json_output "error" "session-autosave-stop" "$session_name" "" "Process not found"
      return 1
    fi
  else
    log_error "No auto-save running for '$session_name'"
    json_output "error" "session-autosave-stop" "$session_name" "" "No auto-save running"
    return 1
  fi
}
```

##### Use Cases

**Use Case 1: Development Environment Portability**
```bash
# Developer A creates perfect setup
session-create dev-env
pane-create dev-env editor
pane-create dev-env server
pane-create dev-env logs
pane-exec dev-env 0 "vim src/main.py"
pane-exec dev-env 1 "make run"
pane-exec dev-env 2 "tail -f logs/app.log"

# Save configuration
session-save dev-env /shared/dev-env-template.snapshot

# Developer B restores the setup
session-restore /shared/dev-env-template.snapshot
# Instant perfect setup!
```

**Use Case 2: Long-Running Workflow Recovery**
```bash
# Start long-running data processing
session-create data-pipeline
pane-exec data-pipeline 0 "python process_large_dataset.py"

# Enable auto-save every 5 minutes
session-autosave data-pipeline 300

# Container restarts unexpectedly...
# After restart:
session-restore /tmp/claude-tmux-states/snapshots/data-pipeline-autosave.snapshot
# Resume where we left off!
```

**Use Case 3: Disaster Recovery**
```bash
# Before risky operation
session-save critical-session /backups/critical-before-upgrade.snapshot

# Perform upgrade...
# Something breaks!

# Restore previous state
session-restore /backups/critical-before-upgrade.snapshot
```

##### Testing Strategy
- Save/restore accuracy (100% pane recreation)
- Layout preservation tests
- Metadata persistence tests
- Auto-save reliability (crash scenarios)
- Large session handling (10+ panes)
- Snapshot versioning compatibility

##### Code Estimate
- **Functions:** ~8 new functions
- **Lines:** ~400-500 lines
- **Files:** Add to `claude-tmux-bridge.sh` or new `claude-tmux-persistence.sh`

---

## Phase 3.2: Interactivity & Observability

**Priority:** P2 (Quality of Life)
**Timeline:** 2-3 weeks
**Effort:** Medium
**Impact:** Production-ready platform

### Feature 3: Interactive Control

#### Problem Statement
Currently, we can only execute new commands. We cannot:
- Send Ctrl+C to stop a running process
- Send other key sequences (Ctrl+Z, etc.)
- Interact with stdin of running processes
- Send signals (SIGTERM, SIGKILL, etc.)

#### Proposed Solution

##### New Commands (4 total)

```bash
# Send keys
pane-send-keys <session> <pane> <keys>
# Examples: "C-c" (Ctrl+C), "C-z" (Ctrl+Z), "Enter", "text to type"

# Interactive mode (future)
pane-interact <session> <pane>
# Opens interactive terminal to pane (requires tty)

# Send signal
pane-signal <session> <pane> <signal>
# Examples: SIGTERM, SIGKILL, SIGHUP, SIGINT

# Send stdin
pane-send-stdin <session> <pane> <text>
# Send text to stdin without pressing Enter
```

##### Implementation Details

```bash
pane_send_keys() {
  local session_name="$1"
  local pane_id="$2"
  local keys="$3"

  # Validate session and pane
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    json_output "error" "pane-send-keys" "$session_name" "$pane_id" "Session not found"
    return 1
  fi

  # Send keys to pane
  tmux send-keys -t "${session_name}:.${pane_id}" "$keys"

  log_success "Keys sent to pane $pane_id: $keys"
  json_output "success" "pane-send-keys" "$session_name" "$pane_id" "Keys sent"
}

pane_signal() {
  local session_name="$1"
  local pane_id="$2"
  local signal="$3"

  # Get PID of process in pane
  local pid=$(tmux display-message -p -t "${session_name}:.${pane_id}" '#{pane_pid}')

  if [ -z "$pid" ]; then
    json_output "error" "pane-signal" "$session_name" "$pane_id" "No process found"
    return 1
  fi

  # Send signal
  kill -"$signal" "$pid"

  log_success "Signal $signal sent to pane $pane_id (PID: $pid)"
  json_output "success" "pane-signal" "$session_name" "$pane_id" "Signal sent"
}

pane_send_stdin() {
  local session_name="$1"
  local pane_id="$2"
  local text="$3"

  # Send text without Enter key
  tmux send-keys -t "${session_name}:.${pane_id}" -l "$text"

  log_success "Stdin sent to pane $pane_id"
  json_output "success" "pane-send-stdin" "$session_name" "$pane_id" "Stdin sent"
}
```

##### Use Cases

**Use Case 1: Graceful Server Shutdown**
```bash
# Start server
pane-exec dev 0 "python server.py"
sleep 5

# Stop gracefully with Ctrl+C
pane-send-keys dev 0 "C-c"

# Wait for cleanup
pane-wait dev 0 10

# Force kill if needed
if pane-is-running dev 0; then
  pane-signal dev 0 SIGKILL
fi
```

**Use Case 2: Interactive Debugging**
```bash
# Start Python REPL
pane-exec dev 1 "python"
sleep 1

# Send commands programmatically
pane-send-stdin dev 1 "import sys"
pane-send-keys dev 1 "Enter"
pane-send-stdin dev 1 "print(sys.version)"
pane-send-keys dev 1 "Enter"

# Capture response
pane-capture dev 1 5
```

**Use Case 3: Process Control**
```bash
# Pause process
pane-signal dev 0 SIGSTOP

# Do something else...

# Resume process
pane-signal dev 0 SIGCONT
```

##### Code Estimate
- **Functions:** ~4 new functions
- **Lines:** ~100-150 lines
- **Files:** Add to `claude-tmux-bridge.sh`

---

### Feature 4: Metrics Collection

#### Problem Statement
No visibility into:
- CPU/memory usage per pane
- Performance trends
- Resource limits
- Cost analysis

#### Proposed Solution

##### New Commands (6 total)

```bash
# Resource usage
pane-metrics <session> <pane>
# Returns: CPU%, memory, I/O, uptime

# Session-wide metrics
session-metrics <session>
# Aggregated metrics for all panes

# Metrics history
metrics-history <session> <pane> [duration]
# Returns time-series data (last N seconds)

# Resource limits (enforcement)
pane-set-limit <session> <pane> cpu <percent>
pane-set-limit <session> <pane> memory <mb>
pane-get-limits <session> <pane>
```

##### Output Format

```json
{
  "status": "success",
  "command": "pane-metrics",
  "session": "dev",
  "pane_id": 0,
  "metrics": {
    "cpu_percent": 15.3,
    "memory_mb": 256,
    "memory_percent": 1.2,
    "io_read_kb": 1024,
    "io_write_kb": 512,
    "uptime_seconds": 3600,
    "thread_count": 4,
    "process_count": 1
  },
  "timestamp": "2025-10-22T10:30:00Z"
}
```

##### Implementation Details

```bash
pane_metrics() {
  local session_name="$1"
  local pane_id="$2"

  # Get PID
  local pid=$(tmux display-message -p -t "${session_name}:.${pane_id}" '#{pane_pid}')

  if [ -z "$pid" ] || ! ps -p "$pid" > /dev/null 2>&1; then
    json_output "error" "pane-metrics" "$session_name" "$pane_id" "Process not found"
    return 1
  fi

  # Get CPU and memory from ps
  local cpu=$(ps -p "$pid" -o %cpu= | tr -d ' ')
  local mem_kb=$(ps -p "$pid" -o rss= | tr -d ' ')
  local mem_mb=$((mem_kb / 1024))

  # Get total system memory for percentage
  local total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  local mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_kb / $total_mem_kb) * 100}")

  # Get thread count
  local threads=$(ps -p "$pid" -o nlwp= | tr -d ' ')

  # Calculate uptime
  local start_time=$(ps -p "$pid" -o lstart= | tr -s ' ')
  local start_epoch=$(date -d "$start_time" +%s 2>/dev/null || echo "0")
  local now_epoch=$(date +%s)
  local uptime=$((now_epoch - start_epoch))

  # Get I/O stats (if available)
  local io_read_kb=0
  local io_write_kb=0
  if [ -f "/proc/$pid/io" ]; then
    io_read_kb=$(grep read_bytes /proc/$pid/io | awk '{print int($2/1024)}')
    io_write_kb=$(grep write_bytes /proc/$pid/io | awk '{print int($2/1024)}')
  fi

  # Build metrics JSON
  local metrics=$(cat <<METRICS
{
  "cpu_percent": $cpu,
  "memory_mb": $mem_mb,
  "memory_percent": $mem_percent,
  "io_read_kb": $io_read_kb,
  "io_write_kb": $io_write_kb,
  "uptime_seconds": $uptime,
  "thread_count": $threads,
  "process_count": 1
}
METRICS
)

  json_output "success" "pane-metrics" "$session_name" "$pane_id" "$metrics"
}

session_metrics() {
  local session_name="$1"

  # Get all panes
  local pane_count=$(pane_count "$session_name" | jq -r '.pane_count')

  # Aggregate metrics
  local total_cpu=0
  local total_mem=0
  local total_io_read=0
  local total_io_write=0

  for i in $(seq 0 $((pane_count - 1))); do
    local pane_metrics=$(pane_metrics "$session_name" "$i" 2>/dev/null || echo "{}")

    if [ -n "$pane_metrics" ]; then
      total_cpu=$(echo "$pane_metrics $total_cpu" | jq -s '.[0].metrics.cpu_percent + .[1]')
      total_mem=$(echo "$pane_metrics $total_mem" | jq -s '.[0].metrics.memory_mb + .[1]')
      total_io_read=$(echo "$pane_metrics $total_io_read" | jq -s '.[0].metrics.io_read_kb + .[1]')
      total_io_write=$(echo "$pane_metrics $total_io_write" | jq -s '.[0].metrics.io_write_kb + .[1]')
    fi
  done

  local aggregate=$(cat <<AGGREGATE
{
  "pane_count": $pane_count,
  "total_cpu_percent": $total_cpu,
  "total_memory_mb": $total_mem,
  "total_io_read_kb": $total_io_read,
  "total_io_write_kb": $total_io_write
}
AGGREGATE
)

  json_output "success" "session-metrics" "$session_name" "" "$aggregate"
}

pane_set_limit() {
  local session_name="$1"
  local pane_id="$2"
  local limit_type="$3"
  local limit_value="$4"

  # Store limit in metadata
  case "$limit_type" in
    cpu)
      pane_metadata_set "$session_name" "$pane_id" "limit_cpu_percent" "$limit_value"
      ;;
    memory)
      pane_metadata_set "$session_name" "$pane_id" "limit_memory_mb" "$limit_value"
      ;;
    *)
      json_output "error" "pane-set-limit" "$session_name" "$pane_id" "Unknown limit type: $limit_type"
      return 1
      ;;
  esac

  log_success "Set $limit_type limit to $limit_value for pane $pane_id"
  json_output "success" "pane-set-limit" "$session_name" "$pane_id" "Limit set"

  # Note: Enforcement would require daemon monitoring
  log_warn "Limit enforcement requires daemon support (future feature)"
}
```

##### Use Cases

**Use Case 1: Resource Monitoring**
```bash
# Monitor resource usage
while true; do
  pane-metrics dev 0 | jq -r '.metrics | "CPU: \(.cpu_percent)% MEM: \(.memory_mb)MB"'
  sleep 5
done
```

**Use Case 2: Performance Analysis**
```bash
# Collect baseline
pane-metrics dev 0 > baseline.json

# Run load test
pane-exec dev 1 "ab -n 1000 -c 10 http://localhost:8000/"
pane-wait dev 1

# Compare metrics
pane-metrics dev 0 > under_load.json
diff <(jq '.metrics' baseline.json) <(jq '.metrics' under_load.json)
```

**Use Case 3: Resource Limits**
```bash
# Set limits
pane-set-limit dev 0 cpu 50      # Max 50% CPU
pane-set-limit dev 0 memory 512  # Max 512MB RAM

# Monitor compliance (manual for now)
current_cpu=$(pane-metrics dev 0 | jq -r '.metrics.cpu_percent')
if (( $(echo "$current_cpu > 50" | bc -l) )); then
  echo "WARNING: CPU limit exceeded!"
fi
```

##### Code Estimate
- **Functions:** ~6 new functions
- **Lines:** ~250-300 lines
- **Files:** Add to `claude-tmux-bridge.sh` or new `claude-tmux-metrics.sh`

---

### Feature 5: Auto Garbage Collection

#### Problem Statement
- State files accumulate in `/tmp`
- Old sessions not automatically cleaned
- No TTL enforcement
- Manual cleanup required

#### Proposed Solution

##### New Commands (4 total)

```bash
# GC Control
gc-enable [ttl-seconds]    # Enable auto-cleanup (default: 7200s = 2h)
gc-disable                 # Disable auto-cleanup
gc-run [force]             # Manual garbage collection
gc-status                  # Show GC status and statistics
```

##### Cleanup Rules

1. **Idle Sessions** - Sessions with all panes idle for > TTL
2. **Orphaned State Files** - State files with no corresponding tmux session
3. **Old Event Logs** - Event logs older than 24h
4. **Completed Panes** - Panes marked completed for > 1h
5. **Stale Snapshots** - Auto-save snapshots older than 7 days

##### Implementation Details

```bash
gc_run() {
  local force="${1:-false}"
  local ttl="${GC_TTL:-7200}"  # 2 hours default
  local now=$(date +%s)

  log_info "Running garbage collection (TTL: ${ttl}s)..."

  local cleaned_sessions=0
  local cleaned_files=0
  local cleaned_snapshots=0

  # 1. Clean idle sessions
  if tmux list-sessions 2>/dev/null; then
    tmux list-sessions -F "#{session_name}:#{session_created}" 2>/dev/null | while IFS=: read session created; do
      local age=$((now - created))

      if [ "$age" -gt "$ttl" ]; then
        # Check if all panes are idle
        if all_panes_idle "$session" || [ "$force" = "true" ]; then
          log_info "GC: Killing idle session '$session' (age: ${age}s)"
          session_kill "$session" 2>/dev/null || true
          ((cleaned_sessions++))
        fi
      fi
    done
  fi

  # 2. Clean orphaned state files
  for state_file in "$STATE_DIR"/*.state; do
    [ -f "$state_file" ] || continue

    local session_name=$(basename "$state_file" .state)
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      log_info "GC: Removing orphaned state file: $state_file"
      rm -f "$state_file"
      ((cleaned_files++))
    fi
  done

  # 3. Clean old event logs
  find "$EVENT_DIR" -type f -name "*.log" -mtime +1 -delete 2>/dev/null || true

  # 4. Clean old snapshots (keep last 10 per session, delete > 7 days old)
  for session_dir in "$STATE_DIR/snapshots"/*; do
    [ -d "$session_dir" ] || continue

    # Delete snapshots older than 7 days
    find "$session_dir" -name "*.snapshot" -mtime +7 -delete 2>/dev/null || true

    # Keep only last 10 snapshots
    ls -t "$session_dir"/*.snapshot 2>/dev/null | tail -n +11 | xargs -r rm -f
    ((cleaned_snapshots++))
  done

  # 5. Clean daemon logs (keep last 10000 lines)
  if [ -f "$DAEMON_LOG" ]; then
    local log_lines=$(wc -l < "$DAEMON_LOG")
    if [ "$log_lines" -gt 10000 ]; then
      tail -n 10000 "$DAEMON_LOG" > "$DAEMON_LOG.tmp"
      mv "$DAEMON_LOG.tmp" "$DAEMON_LOG"
    fi
  fi

  log_success "GC complete: $cleaned_sessions sessions, $cleaned_files state files, $cleaned_snapshots snapshot dirs"

  json_output "success" "gc-run" "" "" "Cleaned $cleaned_sessions sessions, $cleaned_files files"
}

all_panes_idle() {
  local session_name="$1"
  local pane_count=$(tmux list-panes -t "$session_name" | wc -l)

  for i in $(seq 0 $((pane_count - 1))); do
    # Check if pane is running a command
    local cmd=$(tmux display-message -p -t "${session_name}:.${i}" '#{pane_current_command}')
    if [ "$cmd" != "bash" ] && [ "$cmd" != "sh" ]; then
      return 1  # Not idle
    fi
  done

  return 0  # All idle
}

gc_enable() {
  local ttl="${1:-7200}"

  # Store GC config
  cat > "$STATE_DIR/gc-config.json" <<EOF
{
  "enabled": true,
  "ttl_seconds": $ttl,
  "enabled_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

  # Schedule GC to run periodically via cron or systemd timer
  # For now, store config and rely on daemon or manual runs

  log_success "GC enabled (TTL: ${ttl}s)"
  json_output "success" "gc-enable" "" "" "GC enabled"
}

gc_status() {
  local config_file="$STATE_DIR/gc-config.json"

  if [ -f "$config_file" ]; then
    local enabled=$(jq -r '.enabled' "$config_file")
    local ttl=$(jq -r '.ttl_seconds' "$config_file")
    local enabled_at=$(jq -r '.enabled_at' "$config_file")

    cat <<STATUS
GC Status: $([ "$enabled" = "true" ] && echo "Enabled" || echo "Disabled")
TTL: ${ttl}s
Enabled at: $enabled_at

State Files: $(ls -1 "$STATE_DIR"/*.state 2>/dev/null | wc -l)
Snapshots: $(find "$STATE_DIR/snapshots" -name "*.snapshot" 2>/dev/null | wc -l)
Event Logs: $(find "$EVENT_DIR" -name "*.log" 2>/dev/null | wc -l)
STATUS
  else
    echo "GC Status: Not configured"
  fi
}
```

##### Integration with Daemon

The daemon can periodically run GC:

```bash
# In claude-tmux-daemon.sh event loop
GC_INTERVAL=3600  # Run GC every hour

while true; do
  # ... existing event monitoring ...

  # Check if it's time for GC
  if [ $(($(date +%s) % GC_INTERVAL)) -eq 0 ]; then
    gc_run
  fi

  sleep $POLL_INTERVAL
done
```

##### Use Cases

**Use Case 1: Automatic Cleanup**
```bash
# Enable GC with 1-hour TTL
gc-enable 3600

# Sessions auto-cleanup after 1 hour of inactivity
# No manual intervention needed
```

**Use Case 2: Manual Cleanup**
```bash
# Check what would be cleaned
gc-status

# Run manual cleanup
gc-run

# Force cleanup everything
gc-run force
```

##### Code Estimate
- **Functions:** ~5 new functions
- **Lines:** ~150-200 lines
- **Files:** Add to `claude-tmux-bridge.sh` or new `claude-tmux-gc.sh`

---

## Implementation Roadmap

### Timeline Overview

| Phase | Features | Duration | Lines | Priority |
|-------|----------|----------|-------|----------|
| **3.1a** | Multi-Session Coordination | 1.5 weeks | ~350 | P1 |
| **3.1b** | Session Persistence | 1.5 weeks | ~450 | P1 |
| **3.2a** | Interactive Control | 1 week | ~150 | P2 |
| **3.2b** | Metrics Collection | 1 week | ~300 | P2 |
| **3.2c** | Auto GC | 1 week | ~150 | P2 |
| **Total** | All features | **6 weeks** | **~1400** | - |

### Sprint Breakdown

#### Sprint 1 (Week 1-2): Multi-Session Coordination

**Week 1: Foundation**
- Design group state file format
- Implement `group-create`, `group-add`, `group-remove`, `group-list`
- Implement `group-exec`, `group-kill`
- Unit tests for group operations

**Week 2: Dependencies & Health**
- Implement dependency tracking
- Implement `session-depends`, `session-wait-healthy`
- Implement `session-health` with error pattern detection
- Integration tests for dependency resolution
- Documentation

**Deliverables:**
- 8 new commands
- ~350 lines of code
- Test suite
- GROUP_COORDINATION.md documentation

---

#### Sprint 2 (Week 3-4): Session Persistence

**Week 3: Save/Restore**
- Design snapshot JSON schema
- Implement `session-save` with full state capture
- Implement `session-restore` with validation
- Implement `session-snapshots`, `session-snapshot-delete`
- Unit tests for save/restore cycle

**Week 4: Auto-Save**
- Implement `session-autosave` background process
- Implement `session-autosave-stop`
- Test auto-save reliability (crash scenarios)
- Test large session handling (10+ panes)
- Documentation

**Deliverables:**
- 6 new commands
- ~450 lines of code
- Test suite
- PERSISTENCE_GUIDE.md documentation
- Migration guide for existing sessions

---

#### Sprint 3 (Week 5): Interactive Control & Metrics

**Week 5a: Interactive Control (3 days)**
- Implement `pane-send-keys`
- Implement `pane-signal`
- Implement `pane-send-stdin`
- Test graceful shutdown scenarios
- Documentation

**Week 5b: Metrics Collection (2 days)**
- Implement `pane-metrics` (CPU, memory, I/O)
- Implement `session-metrics` (aggregation)
- Implement `pane-set-limit`, `pane-get-limits`
- Test metric accuracy
- Documentation

**Deliverables:**
- 7 new commands (4 interactive + 3 metrics)
- ~450 lines of code
- Test suite
- INTERACTIVE_CONTROL.md + METRICS_GUIDE.md

---

#### Sprint 4 (Week 6): Auto GC & Integration

**Week 6a: Auto GC (3 days)**
- Implement `gc-enable`, `gc-disable`, `gc-run`, `gc-status`
- Implement cleanup rules (5 types)
- Integrate GC with daemon
- Test GC safety (no accidental deletions)
- Documentation

**Week 6b: Integration & Polish (2 days)**
- End-to-end integration testing
- Update all documentation
- Performance benchmarking
- Bug fixes and polish
- Release preparation

**Deliverables:**
- 4 new commands
- ~150 lines of code
- Comprehensive test suite
- Updated CLAUDE_ORCHESTRATION_GUIDE.md
- PHASE_3_MIGRATION_GUIDE.md

---

## Code Organization

### Proposed File Structure

```
scripts/
├── claude-tmux-bridge.sh              # Core (current: 1126 lines → ~1900 lines)
│   ├── Session management (existing)
│   ├── Pane lifecycle (existing)
│   ├── State & discovery (existing)
│   ├── Streaming (existing)
│   ├── Multi-session coordination (NEW: ~350 lines)
│   ├── Session persistence (NEW: ~450 lines)
│   ├── Interactive control (NEW: ~150 lines)
│   ├── Metrics collection (NEW: ~300 lines)
│   └── Auto GC (NEW: ~150 lines)
│
├── claude-tmux-daemon.sh              # Event daemon (current: 435 lines → ~500 lines)
│   ├── Event monitoring (existing)
│   ├── Pattern matching (existing)
│   └── GC scheduling (NEW: ~65 lines)
│
└── lib/ (optional - for modularity)
    ├── groups.sh                       # Multi-session functions
    ├── persistence.sh                  # Save/restore functions
    └── metrics.sh                      # Metrics functions

Estimated total: ~2,400 lines (vs. current 1,561)
Growth: +840 lines (+54%)
```

### Alternative: Modular Architecture

If we want to keep files smaller:

```
scripts/
├── claude-tmux-core.sh                # Core commands (600 lines)
├── claude-tmux-groups.sh              # Multi-session (400 lines)
├── claude-tmux-persistence.sh         # Save/restore (500 lines)
├── claude-tmux-metrics.sh             # Metrics (350 lines)
├── claude-tmux-gc.sh                  # GC (200 lines)
├── claude-tmux-daemon.sh              # Daemon (500 lines)
└── claude-tmux                        # Main dispatcher (150 lines)

Total: ~2,700 lines across 7 files
```

**Recommendation:** Start with monolithic (easier), split later if needed.

---

## Breaking Changes Assessment

### Phase 3.1

**Breaking:** Minimal

- State file format updated to v3.1.0 (backward compatible read)
- New `groups.json` file (additive)
- `session-list` output includes group membership (backward compatible JSON)

**Migration Path:**
```bash
# Existing sessions work as-is
# Opt-in to new features:
group-create mygroup
group-add mygroup existing-session
```

### Phase 3.2

**Breaking:** None

All new commands, no changes to existing behavior.

### Overall Compatibility

- **99% Backward Compatible**
- All existing scripts continue working
- New features are opt-in
- State file migration automatic

---

## Risk Analysis

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| State file corruption | Low | High | Atomic writes, backups, validation |
| Dependency cycles | Medium | Medium | Cycle detection algorithm |
| GC deletes active session | Low | Critical | Conservative TTL, dry-run mode |
| Snapshot size growth | Medium | Medium | Compression, cleanup policies |
| Metrics inaccuracy | Low | Low | Validate against `top`/`htop` |

### Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Restore fails | Medium | High | Validation before restore, rollback |
| Auto-save overhead | Low | Medium | Configurable interval, async |
| Group operations race | Low | Medium | File locking, atomic operations |
| Metrics overhead | Low | Low | Sampling rate limits |

---

## Success Criteria

### Phase 3.1

- [ ] **Multi-Session:**
  - Manage 10+ sessions in groups
  - Dependency resolution works correctly
  - Health checks accurate (0 false positives in 100 runs)
  - Group operations atomic

- [ ] **Persistence:**
  - Save/restore 100% accurate (all panes, metadata, layout)
  - Auto-save runs for 24h+ without issues
  - Snapshots < 100KB per session
  - Restore completes in < 5 seconds

### Phase 3.2

- [ ] **Interactive:**
  - Key sequences delivered correctly
  - Signal handling works (SIGTERM, SIGKILL, etc.)
  - Graceful shutdown pattern documented

- [ ] **Metrics:**
  - CPU/memory within 5% of `top`
  - Metrics collection < 50ms latency
  - Session aggregation correct

- [ ] **GC:**
  - No accidental deletions in 1000 runs
  - Identifies idle sessions correctly
  - Cleans orphaned files reliably
  - TTL enforcement accurate

---

## Testing Strategy

### Unit Tests

```bash
# Test framework: Bash + bats (Bash Automated Testing System)

test_group_create() {
  group-create test-group
  assert_file_exists "$STATE_DIR/groups.json"
  assert_json_contains "test-group"
}

test_session_save_restore() {
  session-create test-session
  pane-create test-session pane1
  session-save test-session /tmp/test.snapshot
  session-kill test-session
  session-restore /tmp/test.snapshot
  assert_session_exists test-session
  assert_pane_count test-session 2
}

test_gc_safety() {
  session-create active-session
  pane-exec active-session 0 "sleep 1000"  # Running process
  gc-run
  assert_session_exists active-session  # Should NOT be deleted
}
```

### Integration Tests

```bash
# End-to-end scenarios

test_microservices_workflow() {
  # Create group
  group-create microservices

  # Create sessions with dependencies
  session-create db
  session-create api
  session-depends api db
  group-add microservices db
  group-add microservices api

  # Start services
  pane-exec db 0 "echo 'DB started'"
  sleep 1
  pane-exec api 0 "echo 'API started'"

  # Check health
  assert_equals "healthy" $(session-health db)
  assert_equals "healthy" $(session-health api)

  # Group operations
  group-exec microservices "echo 'broadcast'"
  assert_pane_contains db 0 "broadcast"
  assert_pane_contains api 0 "broadcast"

  # Cleanup
  group-kill microservices
}
```

### Performance Tests

```bash
# Benchmark metrics

test_session_save_performance() {
  # Create session with 10 panes
  session-create perf-test
  for i in {1..10}; do
    pane-create perf-test "pane$i"
  done

  # Benchmark save
  start=$(date +%s%N)
  session-save perf-test /tmp/perf.snapshot
  end=$(date +%s%N)
  duration=$(( (end - start) / 1000000 ))  # Convert to ms

  assert_less_than $duration 1000  # Should complete in < 1s
}

test_metrics_overhead() {
  # Measure metrics collection time
  start=$(date +%s%N)
  for i in {1..100}; do
    pane-metrics test-session 0 > /dev/null
  done
  end=$(date +%s%N)
  avg=$(( (end - start) / 100000000 ))  # Average in ms

  assert_less_than $avg 50  # < 50ms per call
}
```

---

## Documentation Updates

### New Documentation

1. **GROUP_COORDINATION.md** (NEW)
   - Session groups concept
   - Dependency management
   - Health checks
   - Use cases and examples

2. **PERSISTENCE_GUIDE.md** (NEW)
   - Save/restore workflows
   - Snapshot format specification
   - Auto-save setup
   - Migration from MVP 3.0
   - Backup/disaster recovery

3. **INTERACTIVE_CONTROL.md** (NEW)
   - Key sequence reference
   - Signal handling
   - Graceful shutdown patterns
   - Interactive debugging

4. **METRICS_GUIDE.md** (NEW)
   - Available metrics
   - Performance monitoring
   - Resource limits
   - Cost analysis

5. **GC_GUIDE.md** (NEW)
   - GC rules and policies
   - Configuration
   - Manual vs auto cleanup
   - Safety guarantees

### Updated Documentation

1. **CLAUDE_ORCHESTRATION_GUIDE.md**
   - Add Phase 3.1/3.2 patterns
   - Multi-session examples
   - Persistence best practices

2. **CLAUDE_TMUX_PROTOCOL.md**
   - Document 25+ new commands
   - Update architecture diagram
   - Add command reference

3. **QUICKSTART_DEMO.md**
   - Add Phase 3.1/3.2 demos
   - Multi-session example
   - Save/restore example

4. **PHASE_3_MIGRATION_GUIDE.md** (NEW)
   - Upgrading from 3.0 to 3.1
   - State file migration
   - Breaking changes (minimal)
   - Feature adoption guide

---

## Alternative Approaches Considered

### 1. Database for State (vs JSON Files)

**Pros:**
- Better query capabilities
- ACID transactions
- Easier multi-session coordination
- Built-in locking

**Cons:**
- External dependency (SQLite or PostgreSQL)
- Overkill for current scale
- More complex deployment
- Debugging harder

**Decision:** Stick with JSON files for MVP 3.1/3.2, revisit for 4.0 if scaling issues arise.

---

### 2. Native tmux Hooks (vs Daemon)

**Pros:**
- Built-in tmux feature
- No background process
- Lower overhead

**Cons:**
- Limited hook types (only: after-new-session, pane-died, etc.)
- Hard to extend
- Not portable across tmux versions
- No custom event logic

**Decision:** Keep daemon approach for flexibility. Already implemented in 3.0.

---

### 3. Real-time Metrics (vs Polling)

**Pros:**
- More accurate
- Lower latency
- Event-driven

**Cons:**
- Requires eBPF or kernel hooks
- Complex implementation
- Platform-specific

**Decision:** Use polling (`ps`, `/proc`) for MVP 3.2. Good enough for monitoring, simpler implementation.

---

### 4. Separate Binaries (vs Shell Scripts)

**Pros:**
- Better performance
- Type safety (Go, Rust)
- Easier testing
- Better error handling

**Cons:**
- Complete rewrite
- Loss of portability
- Build step required
- Higher barrier to contribution

**Decision:** Continue with bash for MVP 3.1/3.2. Consider Rust/Go rewrite for 4.0 if performance becomes bottleneck.

---

## Open Questions

### 1. Should GC run in daemon or as separate process?

**Option A:** Integrate into daemon
- Pros: Single process, coordinated
- Cons: Daemon restart kills GC

**Option B:** Separate GC daemon
- Pros: Independent lifecycle
- Cons: Two background processes

**Recommendation:** Option A (integrate), with periodic runs every hour.

---

### 2. Snapshot compression?

**Option A:** Plain JSON
- Pros: Human-readable, debuggable
- Cons: Larger files

**Option B:** Compressed JSON (gzip)
- Pros: Smaller files
- Cons: Not human-readable

**Recommendation:** Option A for MVP 3.1, add compression in 3.2 if snapshot sizes > 100KB.

---

### 3. Resource limit enforcement?

**Option A:** Store limits only (metadata)
- Pros: Simple implementation
- Cons: No actual enforcement

**Option B:** Active enforcement (cgroups, ulimit)
- Pros: Real limits
- Cons: Requires root, complex

**Recommendation:** Option A for MVP 3.2. Limits stored but not enforced. Enforcement in 4.0.

---

### 4. Multi-user support?

Currently, all state files in `/tmp` with no user isolation.

**Option A:** Single-user (current)
- Simple, works for development

**Option B:** Multi-user with isolation
- `/tmp/claude-tmux-$USER/...`
- File permissions

**Recommendation:** Option B, easy to implement, better security.

---

## Conclusion

Phase 3.1 and 3.2 will transform the claude-tmux orchestration system from an **event-driven tool** to a **enterprise-ready platform** with:

1. ✅ **Multi-Session Coordination** - Groups, dependencies, health checks
2. ✅ **Session Persistence** - Save/restore, auto-save, disaster recovery
3. ✅ **Interactive Control** - Send keys, signals, stdin
4. ✅ **Metrics Collection** - CPU, memory, I/O monitoring
5. ✅ **Auto Garbage Collection** - Automatic cleanup, resource reclaim

### Key Metrics

| Metric | Current (3.0) | After 3.2 | Delta |
|--------|---------------|-----------|-------|
| Commands | 27 | 52 | +25 (+93%) |
| Lines of Code | 1,561 | ~2,400 | +839 (+54%) |
| Capabilities | Event-driven | Enterprise-ready | +5 major features |
| Sessions | Single-focus | Multi-session | Unlimited groups |
| Persistence | None | Full save/restore | ∞ recovery |
| Observability | Basic | Full metrics | CPU, RAM, I/O |
| Maintenance | Manual | Auto GC | Hands-free |

### Expected Impact

- **Productivity:** 3x faster multi-project workflows (groups + dependencies)
- **Reliability:** 10x better disaster recovery (persistence + auto-save)
- **Observability:** 5x better monitoring (real-time metrics)
- **Maintenance:** 95% less manual cleanup (auto GC)
- **Usability:** 2x more control (interactive features)

### Timeline Summary

- **Total Duration:** 6 weeks
- **Sprint 1 (Weeks 1-2):** Multi-Session Coordination
- **Sprint 2 (Weeks 3-4):** Session Persistence
- **Sprint 3 (Week 5):** Interactive Control + Metrics
- **Sprint 4 (Week 6):** Auto GC + Integration

### Next Actions

1. ✅ Review this proposal with stakeholders
2. ⏳ Approve sprint plan and timeline
3. ⏳ Set up testing framework (bats)
4. ⏳ Begin Sprint 1: Multi-Session Coordination
5. ⏳ Create tracking board for 25 new commands

---

**Proposal Status:** Ready for Review
**Estimated Start Date:** TBD
**Estimated Completion:** 6 weeks from start

---

**Related Documents:**
- `plan_30.md` - Original Phase 3 vision
- `fix_daemon_lifecycle.md` - Daemon lifecycle analysis
- `report_daemon_ph1.md` - Phase 1 completion report
- `CLAUDE_ORCHESTRATION_GUIDE.md` - Current usage guide
- `CLAUDE_TMUX_PROTOCOL.md` - Current protocol spec
