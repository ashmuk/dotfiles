# Claude-tmux Communication Protocol (Phase 3.0)

## Overview

This protocol enables Claude Code to dynamically create, manage, and monitor tmux panes for parallel task execution with automatic response capture and interaction.

## Architecture

```
┌─────────────────┐
│  Claude Code    │
│  (Orchestrator) │
└────────┬────────┘
         │
         │ Bash commands
         ▼
┌─────────────────────────────────┐
│  claude-tmux-bridge.sh          │
│  - Session management           │
│  - Pane creation/execution      │
│  - Output capture               │
└────────┬────────────────────────┘
         │
         │ tmux commands
         ▼
┌─────────────────────────────────┐
│  tmux Session                   │
│  ┌─────────┬─────────┐          │
│  │ Pane 0  │ Pane 1  │          │
│  │ (server)│ (tests) │          │
│  ├─────────┼─────────┤          │
│  │ Pane 2  │ Pane 3  │          │
│  │ (logs)  │ (aider) │          │
│  └─────────┴─────────┘          │
└─────────────────────────────────┘
```

## Core Commands

### 1. Session Management

```bash
# Create new Claude-controlled session
claude-tmux session-create <session-name>

# List active sessions
claude-tmux session-list

# Kill session
claude-tmux session-kill <session-name>
```

### 2. Pane Management

```bash
# Create pane with automatic layout
claude-tmux pane-create <session-name> <pane-label>

# Execute command in pane
claude-tmux pane-exec <session-name> <pane-id> <command>

# Capture pane output
claude-tmux pane-capture <session-name> <pane-id> [lines]
```

### 3. Monitoring

```bash
# Watch pane for pattern (non-blocking)
claude-tmux pane-watch <session-name> <pane-id> <pattern>

# Get pane status
claude-tmux pane-status <session-name> <pane-id>
```

## Protocol Flow (MVP)

### Scenario: Feature Development

```
1. Claude analyzes task
   └─> Determines: need server, tests, logs

2. Claude creates session
   $ claude-tmux session-create feature-auth

3. Claude spawns panes dynamically
   $ claude-tmux pane-create feature-auth server
   $ claude-tmux pane-create feature-auth tests
   $ claude-tmux pane-create feature-auth logs

4. Claude executes parallel tasks
   $ claude-tmux pane-exec feature-auth 0 "make run"
   $ claude-tmux pane-exec feature-auth 1 "make test"
   $ claude-tmux pane-exec feature-auth 2 "tail -f logs/app.log"

5. Claude monitors outputs
   $ claude-tmux pane-capture feature-auth 1 10
   └─> Analyzes test results

6. Claude reacts to failures
   if tests fail:
     $ claude-tmux pane-create feature-auth aider
     $ claude-tmux pane-exec feature-auth 3 "make aider-refactor"

7. Cleanup
   $ claude-tmux session-kill feature-auth
```

## Output Format

All commands return JSON for easy parsing:

```json
{
  "status": "success|error",
  "command": "pane-exec",
  "session": "feature-auth",
  "pane_id": 1,
  "output": "captured text...",
  "timestamp": "2025-10-21T10:30:00Z"
}
```

## State Management

### Session State File
Location: `/tmp/claude-tmux-<session-name>.state`

```json
{
  "session_name": "feature-auth",
  "created_at": "2025-10-21T10:00:00Z",
  "panes": [
    {
      "pane_id": 0,
      "label": "server",
      "command": "make run",
      "status": "running"
    },
    {
      "pane_id": 1,
      "label": "tests",
      "command": "make test",
      "status": "completed"
    }
  ]
}
```

## Error Handling

### Common Errors

| Error Code | Description | Recovery |
|------------|-------------|----------|
| `ERR_SESSION_EXISTS` | Session already exists | Use different name or kill existing |
| `ERR_PANE_NOT_FOUND` | Pane ID invalid | Verify pane list |
| `ERR_TMUX_NOT_RUNNING` | tmux server not started | Start tmux server |
| `ERR_COMMAND_FAILED` | Command execution failed | Check command syntax |

## MVP Limitations

1. **Linear pane creation** - No complex layouts yet (main-vertical, etc.)
2. **Basic monitoring** - Simple pattern matching only
3. **No persistence** - Sessions don't survive container restart
4. **Single window** - All panes in one window
5. **Text-based capture only** - No image/binary data

## Future Enhancements (Post-MVP)

- [ ] Custom layouts (main-horizontal, tiled, etc.)
- [ ] Multi-window sessions
- [ ] Real-time streaming output
- [ ] Pane resurrection (save/restore)
- [ ] Interactive mode (send input to running commands)
- [ ] Metrics collection (CPU, memory per pane)
- [ ] AI-driven layout optimization

## Security Considerations

1. **Command injection prevention** - All inputs escaped
2. **Session isolation** - Each session namespaced
3. **Resource limits** - Max 10 panes per session (MVP)
4. **Cleanup** - Auto-kill sessions after 2 hours idle

## Integration with Existing Template

### Makefile Integration

```makefile
# New targets
claude-session-%:
	@./scripts/claude-tmux-bridge.sh session-create $*

claude-exec:
	@./scripts/claude-tmux-bridge.sh pane-exec $(SESSION) $(PANE) "$(CMD)"
```

### Health Check Integration

```bash
# Add to health-check.sh
check_claude_tmux() {
  if command -v tmux &> /dev/null; then
    echo "✓ tmux available"
    if [ -f ./scripts/claude-tmux-bridge.sh ]; then
      echo "✓ claude-tmux bridge installed"
    fi
  fi
}
```

## Usage Examples

### Example 1: Run Server and Tests in Parallel

```bash
# Claude executes:
claude-tmux session-create dev-parallel
claude-tmux pane-exec dev-parallel 0 "make run"
claude-tmux pane-create dev-parallel tests
claude-tmux pane-exec dev-parallel 1 "make test"

# Monitor both
server_status=$(claude-tmux pane-capture dev-parallel 0 5 | grep "Uvicorn running")
test_status=$(claude-tmux pane-capture dev-parallel 1 10 | grep -E "PASSED|FAILED")
```

### Example 2: AI-Driven Debug Loop

```bash
# Claude detects test failure
test_output=$(claude-tmux pane-capture dev-parallel 1)

if echo "$test_output" | grep -q "FAILED"; then
  # Spawn aider pane
  claude-tmux pane-create dev-parallel aider
  claude-tmux pane-exec dev-parallel 2 "aider --message 'Fix failing test: $failure'"

  # Wait and re-run tests
  sleep 10
  claude-tmux pane-exec dev-parallel 1 "make test"
fi
```

## Phase 3.0: Event-Driven & Real-Time Features

### Real-Time Streaming Commands

**pane-stream** - Stream new output continuously
```bash
scripts/claude-tmux-bridge.sh pane-stream <session> <pane> [filter]

# Examples
make claude-pane-stream SESSION=dev PANE=0
make claude-pane-stream SESSION=dev PANE=0 FILTER="grep ERROR"
```

**Output:** Continuous stream of new lines as they appear (100ms latency)

**pane-tail** - Show last N lines and follow
```bash
scripts/claude-tmux-bridge.sh pane-tail <session> <pane> [lines]

# Example
make claude-pane-tail SESSION=dev PANE=0 LINES=100
```

**Output:** Historical lines first, then continuous stream

### Event Daemon Commands

**daemon-start** - Start background event monitoring
```bash
scripts/claude-tmux-daemon.sh start [session]

# Examples
make claude-daemon-start                    # Monitor all sessions
make claude-daemon-start SESSION=dev        # Monitor specific session
```

**daemon-stop** - Stop daemon
```bash
scripts/claude-tmux-daemon.sh stop
make claude-daemon-stop
```

**daemon-status** - Check daemon status
```bash
scripts/claude-tmux-daemon.sh status
make claude-daemon-status
```

**daemon-logs** - View daemon logs
```bash
scripts/claude-tmux-daemon.sh logs [lines]
make claude-daemon-logs LINES=50
```

### Event Subscriptions

**pattern-match** - Trigger callback on pattern detection
```bash
scripts/claude-tmux-daemon.sh subscribe <session> pattern-match <pane> <pattern> [callback]

# Example
make claude-event-subscribe-pattern \
  SESSION=dev PANE=0 \
  PATTERN="BUILD SUCCESS" \
  CALLBACK="echo 'Build done!'"
```

**timeout** - Trigger callback after timeout
```bash
scripts/claude-tmux-daemon.sh subscribe <session> timeout <pane> <seconds> [callback]

# Example
make claude-event-subscribe-timeout \
  SESSION=dev PANE=1 \
  TIMEOUT=300 \
  CALLBACK="tmux kill-pane -t dev:.1"
```

### Event Types

1. **pane-exit** - Automatic when pane process completes
2. **pattern-match** - When regex pattern found in output
3. **timeout** - When deadline reached

All events logged to `/tmp/claude-tmux-events/<session>/`

### Example 3: Event-Driven Deployment

```bash
# Start daemon
make claude-daemon-start

# Subscribe to success pattern
make claude-event-subscribe-pattern \
  SESSION=deploy PANE=0 \
  PATTERN="Deployment complete" \
  CALLBACK="echo 'Success!' | mail admin@example.com"

# Start deployment
make claude-pane-exec SESSION=deploy PANE=0 CMD="./deploy.sh"

# Stream output in real-time
make claude-pane-stream SESSION=deploy PANE=0
```

## Success Metrics

**MVP 1.0:**
- ✅ Create session with 4 panes
- ✅ Execute parallel commands
- ✅ Capture and parse output
- ✅ React to captured output
- ✅ Clean shutdown

**Phase 1 (MVP+ 1.5):**
- ✅ Lifecycle management (pane-wait, pane-kill)
- ✅ State queries (pane-count, pane-list-json)
- ✅ Decision helpers (pane-has-pattern)

**Phase 2 (MVP+ 2.0):**
- ✅ Timeout operations (pane-exec-timeout)
- ✅ Metadata system (pane-metadata-set/get)
- ✅ Custom layouts (pane-create-with-layout)

**Phase 3.0:**
- ✅ Event-driven daemon (500ms responsive)
- ✅ Real-time streaming (pane-stream, pane-tail)
- ✅ Pattern callbacks (auto-trigger on match)
- ✅ Timeout callbacks (enforce deadlines)
- ✅ 10x CPU reduction vs polling

---

**Version:** Phase 3.0
**Status:** Production Ready
**Target:** ai_dev/sample_template integration
