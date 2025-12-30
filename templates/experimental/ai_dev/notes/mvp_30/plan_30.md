# Phase 3 Planning: MVP+ 2.0 → MVP+ 3.0
## Claude-tmux Orchestration - Next Generation

**Date:** 2025-10-21
**Current Version:** MVP+ 2.0
**Target Version:** MVP+ 3.0
**Status:** Planning Phase

---

## Executive Summary

After successfully implementing Phase 1 (Lifecycle Management) and Phase 2 (Scalability Enhancements), we now have a production-ready Claude-tmux orchestration system with 23 commands and 996 lines of battle-tested code.

**Phase 3 Goals:**
- Transform from **polling-based** to **event-driven** architecture
- Enable **multi-session** coordination
- Add **real-time streaming** capabilities
- Implement **session persistence**
- Support **interactive control**
- Add **observability & metrics**

---

## Current State Analysis

### What We Have (MVP+ 2.0)

#### Commands Inventory (23 total)

**Session Management (3):**
- ✅ session-create
- ✅ session-list
- ✅ session-kill

**Pane Lifecycle (8):**
- ✅ pane-create
- ✅ pane-kill
- ✅ pane-exec
- ✅ pane-capture
- ✅ pane-is-running
- ✅ pane-wait
- ✅ pane-exec-timeout
- ✅ pane-status

**State & Discovery (6):**
- ✅ state-sync
- ✅ pane-list-json
- ✅ pane-list-detailed
- ✅ pane-find
- ✅ pane-count
- ✅ pane-watch

**Decision Helpers (2):**
- ✅ pane-has-pattern
- ✅ pane-watch-timeout

**Metadata & Layout (4):**
- ✅ pane-metadata-set
- ✅ pane-metadata-get
- ✅ pane-create-with-layout
- (implicit) Multiple layout support

### Code Metrics

```
Total Lines: 996
Functions: 22
Commands: 23
State Files: JSON-based
Output Format: Structured JSON
Dependencies: tmux, jq, bash
```

### Performance Benchmarks (from Phase 2 testing)

| Operation | Time | Efficiency |
|-----------|------|------------|
| Pane Creation | ~0.5s | Excellent |
| Pane Destruction | ~0.2s | Excellent |
| Pattern Detection | ~0.1s | Excellent |
| Command Execution | Instant | Excellent |
| State Sync | ~0.3s | Good |
| Session Cleanup | ~0.5s | Excellent |

### Current Limitations

#### 1. **Polling-Based Architecture** 🔴
- `pane-wait` polls every 1 second
- `pane-watch-timeout` polls continuously
- No event notifications
- CPU waste when idle

#### 2. **Single-Session Focus** 🟡
- All commands operate on one session
- No cross-session coordination
- Can't orchestrate multi-project workflows
- No session groups or hierarchies

#### 3. **No Real-Time Streaming** 🔴
- `pane-capture` only gets historical output
- Miss fast-scrolling output
- No live tail capability
- Polling introduces latency

#### 4. **No Session Persistence** 🟡
- Sessions lost on container restart
- No save/restore capability
- Can't resume long-running workflows
- State files ephemeral

#### 5. **Limited Interactivity** 🟡
- Can only execute new commands
- Can't send Ctrl+C to running process
- No stdin interaction
- Can't pause/resume tasks

#### 6. **No Metrics Collection** 🟢
- No CPU/memory per pane
- No performance tracking
- No resource limit enforcement
- No cost analysis

#### 7. **Manual Cleanup Required** 🟡
- State files in `/tmp` not auto-cleaned
- Old sessions accumulate
- No TTL enforcement
- No garbage collection

---

## Phase 3 Feature Proposals

### Priority Matrix

| Feature | Impact | Effort | Priority | Target MVP |
|---------|--------|--------|----------|-----------|
| Event-Driven Daemon | 🔴 High | 🔴 High | P0 | 3.0 |
| Real-Time Streaming | 🔴 High | 🟡 Med | P0 | 3.0 |
| Multi-Session Coord | 🟡 Med | 🟡 Med | P1 | 3.1 |
| Session Persistence | 🟡 Med | 🔴 High | P1 | 3.1 |
| Interactive Control | 🟢 Low | 🟡 Med | P2 | 3.2 |
| Metrics Collection | 🟡 Med | 🟢 Low | P2 | 3.2 |
| Auto Garbage Collection | 🟢 Low | 🟢 Low | P3 | 3.2 |

---

## Phase 3.0: Event-Driven & Real-Time

**Goal:** Transform from polling to event-driven architecture with real-time capabilities

### 1. Event-Driven Daemon (P0)

#### Architecture

```
┌──────────────────────────────────────┐
│   claude-tmux-daemon.sh              │
│   (Background Process)               │
│                                      │
│   ┌────────────────────────────┐    │
│   │  Event Loop                │    │
│   │  - Monitor tmux events     │    │
│   │  - Watch pane outputs      │    │
│   │  - Trigger callbacks       │    │
│   └────────────────────────────┘    │
│                                      │
│   ┌────────────────────────────┐    │
│   │  Event Queue               │    │
│   │  - FIFO message queue      │    │
│   │  - File-based IPC          │    │
│   └────────────────────────────┘    │
└──────────────────────────────────────┘
            ↓
    Events Published to:
    /tmp/claude-tmux-events/<session>/<event-type>
```

#### New Commands

```bash
# Daemon lifecycle
daemon-start [session]           # Start event daemon
daemon-stop [session]            # Stop daemon gracefully
daemon-status                    # Check daemon status
daemon-logs [tail]              # View daemon logs

# Event subscription
event-subscribe <session> <event> <callback>
# Events: pane-exit, pane-output, pattern-match, timeout

# Example usage
event-subscribe dev pane-exit "pane-kill dev \${pane_id}"
event-subscribe dev pattern-match "echo 'Error detected' >> alerts.log"
```

#### Implementation Details

**Daemon Process:**
```bash
#!/bin/bash
# scripts/claude-tmux-daemon.sh

SESSION="${1:-*}"  # * = monitor all sessions
EVENT_DIR="/tmp/claude-tmux-events"
POLL_INTERVAL=0.5  # 500ms polling (better than 1s)

mkdir -p "$EVENT_DIR"

while true; do
  # Monitor tmux events
  tmux list-sessions -F "#{session_name}" 2>/dev/null | while read session; do
    # Check for pane exits
    check_pane_exits "$session"

    # Check for pattern matches
    check_pattern_matches "$session"

    # Check for timeouts
    check_timeouts "$session"
  done

  sleep $POLL_INTERVAL
done
```

**Benefits:**
- No manual polling in user scripts
- Automatic event notifications
- Callback-based reactions
- Lower CPU usage (single daemon vs multiple polls)

**Effort:** ~200-300 lines
**Testing:** Background daemon, process management, event delivery

---

### 2. Real-Time Streaming (P0)

#### New Commands

```bash
# Stream live output
pane-stream <session> <pane> [filter]
# Continuously prints new output, Ctrl+C to stop

# Tail last N lines and follow
pane-tail <session> <pane> <lines>
# Like `tail -f`, follows new output

# Example
pane-stream dev 0 | grep ERROR  # Live error monitoring
pane-tail dev 1 20              # Follow last 20 lines
```

#### Implementation

```bash
pane_stream() {
  local session_name="$1"
  local pane_id="$2"
  local filter="${3:-cat}"

  local last_output=""

  while true; do
    current_output=$(tmux capture-pane -t "${session_name}:.${pane_id}" -p)

    # Diff to get only new lines
    new_lines=$(diff <(echo "$last_output") <(echo "$current_output") | grep "^>" | sed 's/^> //')

    if [ -n "$new_lines" ]; then
      echo "$new_lines" | $filter
    fi

    last_output="$current_output"
    sleep 0.1  # 100ms polling for real-time feel
  done
}
```

**Benefits:**
- No more missing fast output
- Live monitoring capabilities
- Pipe-able for filtering
- Feels like native tail -f

**Effort:** ~100-150 lines
**Testing:** Output streaming, filtering, termination

---

## Phase 3.1: Multi-Session & Persistence

### 3. Multi-Session Coordination (P1)

#### New Concepts

**Session Groups:**
```bash
# Create session group
group-create <group-name>
group-add <group-name> <session-name>
group-list [group-name]
group-exec <group-name> <command>  # Execute in all sessions
group-kill <group-name>
```

**Cross-Session Queries:**
```bash
# Global queries
sessions-list-all           # All sessions across groups
panes-count-global         # Total panes across all sessions
sessions-find-pattern <pat> # Find sessions with pattern in output
```

**Session Dependencies:**
```bash
# Define dependencies
session-depends <session-a> <session-b>
# session-a won't start until session-b is healthy

# Health checks
session-health <session>
# Returns: healthy, degraded, unhealthy
```

#### Use Cases

**1. Microservices Development:**
```bash
group-create microservices
group-add microservices api-service
group-add microservices db-service
group-add microservices cache-service

# Start all services
group-exec microservices "make run"

# Monitor all
sessions-find-pattern "ERROR"
```

**2. Multi-Project Orchestration:**
```bash
# Project A (frontend)
session-create frontend
pane-exec frontend 0 "npm run dev"

# Project B (backend) - depends on frontend
session-depends backend frontend
session-create backend
pane-exec backend 0 "python app.py"
```

**Effort:** ~250-350 lines
**Testing:** Group management, cross-session ops, dependencies

---

### 4. Session Persistence (P1)

#### New Commands

```bash
# Save session state
session-save <session> [file]
# Saves: pane layout, commands, metadata

# Restore session
session-restore <file>
# Recreates exact session state

# Auto-save
session-autosave <session> <interval>
# Saves every N seconds

# List snapshots
session-snapshots [session]
```

#### State File Format

```json
{
  "session_name": "dev-work",
  "created_at": "2025-10-21T10:00:00Z",
  "layout": "tiled",
  "panes": [
    {
      "pane_id": 0,
      "label": "server",
      "command": "make run",
      "working_dir": "/workspace",
      "metadata": {
        "role": "primary"
      },
      "history": ["ls", "cd /workspace", "make run"]
    }
  ],
  "environment": {
    "PATH": "/usr/local/bin:...",
    "CUSTOM_VAR": "value"
  }
}
```

#### Implementation Strategy

```bash
session_save() {
  local session_name="$1"
  local output_file="${2:-$STATE_DIR/${session_name}.snapshot}"

  # Capture full state
  local layout=$(tmux display-message -p -t "$session_name" '#{window_layout}')
  local panes_data=$(build_panes_snapshot "$session_name")

  # Save to file
  cat > "$output_file" <<EOF
{
  "session_name": "$session_name",
  "saved_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "layout": "$layout",
  "panes": $panes_data
}
EOF
}

session_restore() {
  local snapshot_file="$1"

  # Parse snapshot
  local session_name=$(jq -r '.session_name' "$snapshot_file")

  # Recreate session
  session-create "$session_name"

  # Restore panes
  jq -c '.panes[]' "$snapshot_file" | while read pane; do
    local label=$(echo "$pane" | jq -r '.label')
    local command=$(echo "$pane" | jq -r '.command')

    pane-create "$session_name" "$label"
    pane-exec "$session_name" "$pane_id" "$command"
  done

  # Apply layout
  local layout=$(jq -r '.layout' "$snapshot_file")
  tmux select-layout -t "$session_name" "$layout"
}
```

**Benefits:**
- Survive container restarts
- Share session configs
- Quick project switching
- Disaster recovery

**Effort:** ~200-300 lines
**Testing:** Save/restore cycle, layout preservation, command replay

---

## Phase 3.2: Interactivity & Observability

### 5. Interactive Control (P2)

#### New Commands

```bash
# Send keys to pane
pane-send-keys <session> <pane> <keys>
# Example: pane-send-keys dev 0 "C-c"  # Send Ctrl+C

# Interactive stdin
pane-interact <session> <pane>
# Opens interactive session to pane

# Send signal
pane-signal <session> <pane> <signal>
# Example: pane-signal dev 0 SIGTERM
```

#### Use Cases

**1. Graceful Shutdown:**
```bash
# Send Ctrl+C to stop server gracefully
pane-send-keys dev 0 "C-c"
pane-wait dev 0 10  # Wait for cleanup
pane-kill dev 0     # Force kill if needed
```

**2. Interactive Debugging:**
```bash
# Drop into interactive mode
pane-interact dev 0
# User can type commands, exit with Ctrl+D
```

**Effort:** ~100-150 lines
**Testing:** Key sequences, signal handling, interactive mode

---

### 6. Metrics Collection (P2)

#### New Commands

```bash
# Resource usage
pane-metrics <session> <pane>
# Returns: CPU%, memory, I/O

# Session metrics
session-metrics <session>
# Aggregated metrics for all panes

# Metrics history
metrics-history <session> <pane> [duration]
# Returns time-series data

# Resource limits
pane-set-limit <session> <pane> <cpu|mem> <value>
# Enforce resource limits
```

#### Output Format

```json
{
  "status": "success",
  "pane_id": 0,
  "metrics": {
    "cpu_percent": 15.3,
    "memory_mb": 256,
    "memory_percent": 1.2,
    "io_read_kb": 1024,
    "io_write_kb": 512,
    "uptime_seconds": 3600,
    "thread_count": 4
  },
  "timestamp": "2025-10-21T10:30:00Z"
}
```

#### Implementation

```bash
pane_metrics() {
  local session_name="$1"
  local pane_id="$2"

  # Get PID
  local pid=$(tmux display-message -p -t "${session_name}:.${pane_id}" '#{pane_pid}')

  # Get metrics from /proc or ps
  local cpu=$(ps -p "$pid" -o %cpu= | tr -d ' ')
  local mem=$(ps -p "$pid" -o rss= | tr -d ' ')
  local mem_mb=$((mem / 1024))

  # Calculate uptime
  local start_time=$(ps -p "$pid" -o lstart=)
  local uptime=$(( $(date +%s) - $(date -d "$start_time" +%s) ))

  json_output "success" "pane-metrics" "$session_name" "$pane_id" \
    "{\"cpu_percent\":$cpu,\"memory_mb\":$mem_mb,\"uptime_seconds\":$uptime}"
}
```

**Benefits:**
- Resource monitoring
- Performance analysis
- Cost tracking
- Anomaly detection

**Effort:** ~150-200 lines
**Testing:** Metric accuracy, history collection, limit enforcement

---

### 7. Auto Garbage Collection (P3)

#### New Commands

```bash
# Enable auto-cleanup
gc-enable [ttl-seconds]
# Default: 7200s (2 hours)

# Manual garbage collection
gc-run [force]

# GC status
gc-status
```

#### Cleanup Rules

1. **Idle Sessions (2h)** - Sessions with all panes idle
2. **Orphaned State Files** - State files with no tmux session
3. **Old Event Logs** - Event logs older than 24h
4. **Completed Panes** - Panes marked as completed for >1h

#### Implementation

```bash
gc_run() {
  local force="${1:-false}"
  local ttl="${GC_TTL:-7200}"
  local now=$(date +%s)

  # Find idle sessions
  tmux list-sessions -F "#{session_name}:#{session_created}" | while IFS=: read session created; do
    local age=$((now - created))

    if [ "$age" -gt "$ttl" ]; then
      # Check if all panes idle
      if all_panes_idle "$session"; then
        log_info "GC: Killing idle session $session (age: ${age}s)"
        session-kill "$session"
      fi
    fi
  done

  # Clean orphaned state files
  ls "$STATE_DIR"/*.state 2>/dev/null | while read state_file; do
    local session_name=$(basename "$state_file" .state)
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      log_info "GC: Removing orphaned state file: $state_file"
      rm -f "$state_file"
    fi
  done
}
```

**Benefits:**
- No manual cleanup
- Prevent state file bloat
- Automatic resource reclaim
- Container health

**Effort:** ~100-150 lines
**Testing:** TTL enforcement, orphan detection, safe cleanup

---

## Implementation Roadmap

### Timeline Estimate

| Phase | Features | Duration | Complexity |
|-------|----------|----------|------------|
| **3.0** | Event daemon + Streaming | 3-4 weeks | High |
| **3.1** | Multi-session + Persistence | 2-3 weeks | Medium |
| **3.2** | Interactive + Metrics + GC | 2-3 weeks | Medium |
| **Total** | All Phase 3 features | 7-10 weeks | - |

### Incremental Delivery

#### Sprint 1 (Week 1-2): Event Foundation
- ✅ Daemon architecture design
- ✅ Event queue implementation
- ✅ daemon-start/stop/status commands
- ✅ Basic event subscription
- ✅ Testing framework

#### Sprint 2 (Week 3-4): Real-Time Streaming
- ✅ pane-stream implementation
- ✅ pane-tail implementation
- ✅ Output diff algorithm
- ✅ Integration with daemon
- ✅ Performance testing

#### Sprint 3 (Week 5-6): Multi-Session
- ✅ Session groups
- ✅ Cross-session queries
- ✅ Session dependencies
- ✅ Health checks
- ✅ Integration testing

#### Sprint 4 (Week 7-8): Persistence
- ✅ session-save/restore
- ✅ Snapshot format design
- ✅ Auto-save implementation
- ✅ Migration from MVP 2.0
- ✅ Backup/restore testing

#### Sprint 5 (Week 9-10): Observability
- ✅ Interactive control
- ✅ Metrics collection
- ✅ Auto GC
- ✅ Documentation
- ✅ Final testing

---

## Code Organization

### Proposed Structure

```
scripts/
├── claude-tmux-bridge.sh          # Core (current: 996 lines)
├── claude-tmux-daemon.sh          # NEW: Event daemon (~300 lines)
├── claude-tmux-gc.sh              # NEW: Garbage collector (~150 lines)
├── claude-tmux-metrics.sh         # NEW: Metrics collector (~200 lines)
└── claude-orchestrator-poc.sh     # Existing POC demo

lib/
├── events.sh                      # Event queue library
├── persistence.sh                 # Save/restore library
└── utils.sh                       # Shared utilities

Estimated total: ~2000-2500 lines (2.5x current size)
```

---

## Breaking Changes Assessment

### Phase 3.0 (Event-Driven)

**Breaking:** None (daemon is opt-in)

Existing polling-based commands continue working. Daemon provides **additive** event capabilities.

### Phase 3.1 (Multi-Session)

**Breaking:** Minimal

- Session state files may change format (migration script provided)
- `session-list` output may include group info (backward compatible JSON)

### Phase 3.2 (Metrics)

**Breaking:** None

All new commands, no changes to existing behavior.

### Overall: ~95% Backward Compatible

---

## Risk Analysis

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Daemon stability issues | Medium | High | Extensive testing, restart logic |
| Event queue deadlocks | Low | High | Timeout mechanisms, monitoring |
| State file corruption | Low | Medium | Atomic writes, backups |
| Memory leaks in daemon | Medium | Medium | Resource monitoring, regular restarts |
| Performance degradation | Low | High | Benchmarking, optimization |

### Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Daemon fails to start | Low | High | Health checks, auto-restart |
| Events lost | Low | Medium | Event persistence, retry logic |
| Restore fails | Medium | High | Validation before restore, rollback |
| GC deletes active session | Low | Critical | Conservative TTL, manual override |

---

## Success Criteria

### Phase 3.0
- [ ] Daemon runs stable for 24h+
- [ ] Event delivery < 100ms latency
- [ ] CPU usage < 5% when idle
- [ ] Stream output without missing lines
- [ ] Zero false-positive event triggers

### Phase 3.1
- [ ] Manage 10+ sessions concurrently
- [ ] Save/restore 100% accurate
- [ ] Session dependencies work correctly
- [ ] Group operations execute atomically
- [ ] State migration from 2.0 succeeds

### Phase 3.2
- [ ] Interactive mode responsive (<50ms)
- [ ] Metrics accurate within 5%
- [ ] GC correctly identifies idle sessions
- [ ] No accidental deletions in 1000 GC runs
- [ ] Resource limits enforced

---

## Testing Strategy

### Unit Tests
- Individual command functions
- Event queue operations
- State save/restore logic
- Metrics calculations

### Integration Tests
- Daemon + bridge interaction
- Multi-session workflows
- Persistence across restarts
- End-to-end scenarios

### Performance Tests
- 100 concurrent panes
- 24h daemon stability
- Event throughput benchmarks
- Memory leak detection

### Regression Tests
- All MVP 2.0 demos still work
- Backward compatibility verified
- Migration path tested

---

## Documentation Updates

### New Docs Required

1. **DAEMON_GUIDE.md**
   - Event-driven architecture
   - Daemon lifecycle management
   - Event subscription patterns

2. **MULTI_SESSION_GUIDE.md**
   - Session groups
   - Dependencies
   - Cross-session queries

3. **PERSISTENCE_GUIDE.md**
   - Save/restore workflows
   - Snapshot management
   - Migration guide

4. **OBSERVABILITY_GUIDE.md**
   - Metrics collection
   - Interactive mode
   - Troubleshooting

### Updates to Existing Docs

- **CLAUDE_ORCHESTRATION_GUIDE.md** - Add Phase 3 patterns
- **CLAUDE_TMUX_PROTOCOL.md** - Document new commands
- **MIGRATION_MVP_TO_MVP2.md** - Rename to include 3.0
- **QUICKSTART_DEMO.md** - Add Phase 3 demos

---

## Alternative Approaches Considered

### 1. Native tmux Hooks

**Pros:**
- Built-in tmux feature
- No polling needed
- Lower overhead

**Cons:**
- Limited hook types
- Hard to extend
- Shell integration complex
- Not portable across tmux versions

**Decision:** Use daemon for flexibility

### 2. Unix Domain Sockets for IPC

**Pros:**
- Faster than file-based
- More robust
- Better for high-frequency events

**Cons:**
- More complex implementation
- Harder to debug
- File-based is "good enough" for MVP

**Decision:** File-based for Phase 3.0, sockets for 4.0 if needed

### 3. External Database for State

**Pros:**
- Better query capabilities
- Transactional safety
- Easier multi-session coordination

**Cons:**
- External dependency
- Overkill for current needs
- Adds complexity

**Decision:** Stick with JSON files, revisit if scaling issues

---

## Open Questions

1. **Should daemon be per-session or global?**
   - Leaning global (monitors all sessions)
   - More efficient
   - Simpler management

2. **Event queue size limits?**
   - Default: 1000 events max
   - Circular buffer
   - Configurable

3. **Persistence format versioning?**
   - Include version field
   - Migration scripts for breaking changes
   - Backward read compatibility

4. **Metrics storage duration?**
   - Default: 1 hour in-memory
   - Optional file-based long-term
   - Configurable retention

5. **GC configurability?**
   - Global config file?
   - Per-session metadata?
   - Environment variables?

---

## Conclusion

Phase 3 represents a **major architectural evolution** from a polling-based tool to a fully event-driven orchestration platform. The incremental approach (3.0 → 3.1 → 3.2) allows us to deliver value early while managing complexity.

### Key Innovations

1. **Event-Driven** - Reactive instead of polling
2. **Multi-Session** - Enterprise-scale orchestration
3. **Persistent** - Survive restarts, share configs
4. **Observable** - Metrics, monitoring, control
5. **Intelligent** - Auto-cleanup, health checks

### Expected Impact

- **Performance:** 10x reduction in CPU usage (event-driven)
- **Capability:** 5x more powerful (multi-session + persistence)
- **Reliability:** 2x more stable (health checks + auto-GC)
- **Usability:** 3x easier (real-time + interactive)

### Next Actions

1. ✅ Review this plan with stakeholders
2. ⏳ Create detailed design docs for Phase 3.0
3. ⏳ Set up development environment
4. ⏳ Begin Sprint 1 implementation
5. ⏳ Establish testing framework

---

**Plan Status:** Draft for Review
**Feedback Deadline:** TBD
**Implementation Start:** TBD

---

**Related Documents:**
- `ai_dev/notes/summary_no1.md` - Phase 1 implementation
- `ai_dev/notes/summary_no2.md` - Phase 2 implementation
- `MIGRATION_MVP_TO_MVP2.md` - Current migration guide
- `CLAUDE_ORCHESTRATION_GUIDE.md` - Current usage patterns
