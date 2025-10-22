# Daemon Lifecycle Management - Improvement Proposals

## Current Architecture Issues

### Problem 1: Orphaned Daemon Processes
**Issue:** Daemon continues running after all demo sessions complete.

**Current Behavior:**
```bash
./scripts/demo-event-driven-quick.sh
# Demo completes, session killed, but daemon still running
ps aux | grep daemon  # ← Still shows daemon process
```

**Impact:**
- Wastes system resources
- Potential memory leaks over time
- Confusing for users who think cleanup is complete

---

### Problem 2: No Auto-Cleanup on Demo Exit
**Issue:** Cleanup trap in demos only kills tmux session, not daemon.

**Current Code:**
```bash
cleanup() {
    "$BRIDGE" session-kill "$SESSION" 2>/dev/null || true
    # ← Missing: daemon cleanup!
}
trap cleanup EXIT
```

---

### Problem 3: Shared Global Daemon
**Issue:** Single daemon monitors all sessions - can't isolate demos.

**Problems:**
- Multiple demos interfere with each other
- Can't run isolated test environments
- Daemon state persists across demos

---

## Proposed Solutions

### Solution 1: Session-Scoped Daemon (RECOMMENDED)

**Concept:** Each tmux session gets its own daemon that auto-terminates with the session.

**Implementation:**

```bash
# New function in claude-tmux-bridge.sh
session_create_with_daemon() {
    local session_name="$1"

    # Create session
    tmux new-session -d -s "$session_name"

    # Start session-scoped daemon
    DAEMON_SESSION="$session_name" "$DAEMON" start-scoped

    # Store daemon PID in session metadata
    local daemon_pid=$(cat "/tmp/claude-tmux-daemon-${session_name}.pid")

    # Create cleanup pane (hidden) that kills daemon on session exit
    tmux split-window -t "$session_name" -d \
        "trap 'kill $daemon_pid 2>/dev/null' EXIT; sleep infinity"

    json_output "success" "session-create-with-daemon" "$session_name" "0"
}
```

**Benefits:**
- ✅ Daemon auto-stops when session exits
- ✅ Isolated per-session monitoring
- ✅ No orphaned processes
- ✅ Zero manual cleanup needed

---

### Solution 2: Reference Counting

**Concept:** Daemon tracks active sessions and auto-stops when count reaches zero.

**Implementation:**

```bash
# In claude-tmux-daemon.sh
register_session() {
    local session="$1"
    echo "$session" >> "$STATE_DIR/active-sessions.txt"
    sort -u "$STATE_DIR/active-sessions.txt" -o "$STATE_DIR/active-sessions.txt"
}

unregister_session() {
    local session="$1"
    grep -v "^${session}$" "$STATE_DIR/active-sessions.txt" > "$STATE_DIR/active-sessions.txt.tmp"
    mv "$STATE_DIR/active-sessions.txt.tmp" "$STATE_DIR/active-sessions.txt"

    # Auto-stop if no sessions remain
    if [ ! -s "$STATE_DIR/active-sessions.txt" ]; then
        log_info "No active sessions, stopping daemon..."
        daemon_stop
    fi
}

# In event loop
event_loop() {
    while true; do
        # Check if any registered sessions still exist
        while read -r session; do
            if ! tmux has-session -t "$session" 2>/dev/null; then
                unregister_session "$session"
            fi
        done < "$STATE_DIR/active-sessions.txt"

        # ... existing event monitoring ...
    done
}
```

**Benefits:**
- ✅ Daemon auto-stops when idle
- ✅ Works with existing session commands
- ✅ Backward compatible

**Drawbacks:**
- ⚠️ Polling overhead to check session existence
- ⚠️ Race conditions if sessions created/destroyed rapidly

---

### Solution 3: Daemon Auto-Timeout

**Concept:** Daemon auto-stops after N seconds of inactivity.

**Implementation:**

```bash
# In claude-tmux-daemon.sh
IDLE_TIMEOUT=300  # 5 minutes
last_activity=$(date +%s)

event_loop() {
    while true; do
        current_time=$(date +%s)
        idle_duration=$((current_time - last_activity))

        # Check for events
        events_found=false

        for session in $(tmux list-sessions -F "#{session_name}" 2>/dev/null); do
            # ... check events ...
            if [ "$event_occurred" = true ]; then
                events_found=true
                last_activity=$current_time
            fi
        done

        # Auto-stop if idle too long
        if [ $idle_duration -gt $IDLE_TIMEOUT ]; then
            log_info "Idle timeout ($IDLE_TIMEOUT seconds), stopping daemon..."
            daemon_stop
            exit 0
        fi

        sleep "$POLL_INTERVAL"
    done
}
```

**Benefits:**
- ✅ Simple to implement
- ✅ Prevents indefinite orphans
- ✅ Configurable timeout

**Drawbacks:**
- ⚠️ May stop during long-running demos
- ⚠️ Arbitrary timeout value

---

### Solution 4: Enhanced Cleanup Trap

**Concept:** Make demo scripts smarter about daemon cleanup.

**Implementation:**

```bash
# In demo scripts
cleanup() {
    log "Cleaning up demo session..."

    # Kill session
    "$BRIDGE" session-kill "$SESSION" 2>/dev/null || true

    # Check if any OTHER sessions exist
    other_sessions=$(tmux list-sessions 2>/dev/null | grep -v "$SESSION" | wc -l)

    if [ "$other_sessions" -eq 0 ]; then
        # We're the last session, stop daemon
        log "No other sessions, stopping daemon..."
        "$DAEMON" stop
    else
        log "Other sessions exist, keeping daemon running"
    fi

    # Cleanup temp files
    rm -f /tmp/*-${SESSION}.sh 2>/dev/null || true
}
trap cleanup EXIT
```

**Benefits:**
- ✅ Works with existing architecture
- ✅ No daemon changes needed
- ✅ Minimal code changes

**Drawbacks:**
- ⚠️ Still requires demo script cooperation
- ⚠️ Race conditions with concurrent demos

---

## Recommended Implementation Strategy

### Phase 1: Quick Fix (Immediate)
Implement **Solution 4: Enhanced Cleanup Trap** in demo scripts.

**Changes Required:**
- Update `claude-phase3a-simple-demo.sh` cleanup function
- Update `demo-event-driven-quick.sh` cleanup function
- Add session counting logic

**Effort:** Low (30 minutes)

---

### Phase 2: Reference Counting (Short-term)
Implement **Solution 2: Reference Counting** in daemon.

**Changes Required:**
- Add session registration to `session-create`
- Add auto-stop logic to event loop
- Maintain active session list

**Effort:** Medium (2-3 hours)

---

### Phase 3: Session-Scoped Daemons (Long-term)
Implement **Solution 1: Session-Scoped Daemon** for full isolation.

**Changes Required:**
- Refactor daemon to support per-session instances
- Update PID file naming (per-session)
- Add session-specific event directories
- Create cleanup pane mechanism

**Effort:** High (1 day)

---

## Additional Improvements

### 1. Daemon Health Monitoring

```bash
# Check daemon is actually working
daemon_health_check() {
    local max_age=10  # seconds
    local log_file="/tmp/claude-tmux-daemon.log"

    if [ -f "$log_file" ]; then
        local log_age=$(($(date +%s) - $(stat -f %m "$log_file" 2>/dev/null || stat -c %Y "$log_file")))
        if [ $log_age -gt $max_age ]; then
            log_error "Daemon appears hung (log not updated in ${log_age}s)"
            return 1
        fi
    fi
    return 0
}
```

### 2. Graceful Shutdown Improvements

```bash
# Current: 5 second timeout then kill -9
# Better: Progressive shutdown with cleanup hooks

daemon_stop() {
    # ... existing code ...

    # Give daemon chance to flush events
    kill -TERM "$pid"

    for i in {1..10}; do
        if ! kill -0 "$pid" 2>/dev/null; then
            log_success "Daemon stopped gracefully"
            return 0
        fi
        sleep 0.5
    done

    # Still alive, send cleanup signal
    kill -INT "$pid" 2>/dev/null
    sleep 1

    # Last resort
    kill -9 "$pid" 2>/dev/null
    log_warning "Daemon force killed"
}
```

### 3. Zombie Process Prevention

```bash
# In daemon start
daemon_start() {
    # ... existing code ...

    # Detach and prevent zombies
    (
        # Close file descriptors
        exec 1>/dev/null 2>&1 <&-

        # Double fork to prevent zombies
        (
            event_loop
        ) &

        exit 0
    ) &
}
```

### 4. Session Cleanup Hook

```bash
# Add to tmux session on creation
session_create() {
    # ... existing code ...

    # Register cleanup hook
    tmux set-hook -t "$session_name" session-closed \
        "run-shell '$DAEMON unregister-session $session_name'"
}
```

This uses tmux's built-in hooks to auto-unregister sessions!

---

## Testing Strategy

### Test Cases for Lifecycle Management

```bash
# Test 1: Single session cleanup
./scripts/demo-event-driven-quick.sh
# Expected: Daemon stops automatically

# Test 2: Multiple sessions
./scripts/demo-event-driven-quick.sh &
./scripts/claude-phase3a-simple-demo.sh &
# Kill one session
# Expected: Daemon still running
# Kill last session
# Expected: Daemon stops

# Test 3: Crash handling
./scripts/demo-event-driven-quick.sh
# Kill demo script with Ctrl+C
# Expected: Session and daemon both cleaned up

# Test 4: Zombie prevention
for i in {1..10}; do
    ./scripts/demo-event-driven-quick.sh &
done
# Expected: No zombie processes
ps aux | grep '<defunct>'  # Should be empty

# Test 5: Resource leak check
for i in {1..100}; do
    ./scripts/demo-event-driven-quick.sh
done
# Expected: No PID file, no processes, no file descriptor leaks
lsof | grep claude-tmux | wc -l  # Should be 0
```

---

## Implementation Priority

| Solution | Priority | Effort | Impact | Recommendation |
|----------|----------|--------|--------|----------------|
| Enhanced Cleanup Trap | HIGH | Low | Medium | ✅ Implement now |
| Reference Counting | MEDIUM | Medium | High | ✅ Phase 2 |
| Auto-Timeout | LOW | Low | Low | Optional |
| Session-Scoped Daemon | LOW | High | High | Future enhancement |

---

## Conclusion

**Immediate Action (Phase 1):**
Implement enhanced cleanup trap in demo scripts to check for other sessions before stopping daemon.

**Next Steps (Phase 2):**
Add reference counting to daemon for automatic lifecycle management.

**Long-term (Phase 3):**
Consider session-scoped daemons for complete isolation and zero-config cleanup.

---

**Would you like me to implement Phase 1 (Enhanced Cleanup Trap) right now?** This would ensure no orphaned daemons after demos complete.
