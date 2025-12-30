# Quick Start Demo - Claude-tmux Orchestration

## 🚀 Fastest Way to See It in Action

### Option 1: Run the Full POC Demo (Recommended)

Open iTerm2 and run:

```bash
cd ~/dotfiles/templates/ai_dev/sample_template
./scripts/claude-orchestrator-poc.sh
```

**What you'll see:**
1. Claude creates a session called `claude-poc`
2. Dynamically spawns 4 panes (server, tests, logs, monitor)
3. Executes parallel commands in each pane
4. Monitors outputs automatically
5. Detects "test failure" and spawns aider pane to fix it
6. All happening automatically!

**Duration:** ~30 seconds

**To view the live tmux session:**
```bash
# In another terminal while POC is running:
tmux attach -t claude-poc
```

Press `Ctrl+C` to exit and auto-cleanup.

---

### Option 2: Run the Makefile Demo (Simpler)

```bash
cd ~/dotfiles/templates/ai_dev/sample_template
make claude-demo
```

**What you'll see:**
- Creates session `demo-session`
- Creates 3 panes with labels
- Executes echo commands in each
- Captures and displays outputs
- Shows session list

**Duration:** ~10 seconds

**To view the session:**
```bash
tmux attach -t demo-session
```

**To cleanup:**
```bash
make claude-session-kill SESSION=demo-session
```

---

### Option 3: Manual Step-by-Step (Educational)

```bash
cd ~/dotfiles/templates/ai_dev/sample_template

# 1. Create a session
./scripts/claude-tmux-bridge.sh session-create my-demo

# 2. Create additional panes
./scripts/claude-tmux-bridge.sh pane-create my-demo tests
./scripts/claude-tmux-bridge.sh pane-create my-demo logs

# 3. Execute commands in panes
./scripts/claude-tmux-bridge.sh pane-exec my-demo 0 "echo 'Running server...'; sleep 2; echo 'Server ready on :8000'"
./scripts/claude-tmux-bridge.sh pane-exec my-demo 1 "echo 'Running tests...'; sleep 1; echo 'PASSED: 5 tests'"
./scripts/claude-tmux-bridge.sh pane-exec my-demo 2 "echo 'Monitoring logs...'"

# 4. Wait for commands to execute
sleep 3

# 5. Capture outputs
./scripts/claude-tmux-bridge.sh pane-capture my-demo 0 10
./scripts/claude-tmux-bridge.sh pane-capture my-demo 1 10

# 6. View the live session
tmux attach -t my-demo

# 7. Detach from session (inside tmux)
# Press: Ctrl+a then d

# 8. Kill session when done
./scripts/claude-tmux-bridge.sh session-kill my-demo
```

---

## 🎬 What Each Demo Shows

### POC Demo (`claude-orchestrator-poc.sh`)
**Demonstrates:**
- ✅ Intelligent task analysis (simulated Claude reasoning)
- ✅ Dynamic pane creation based on requirements
- ✅ Parallel command execution
- ✅ Real-time output monitoring
- ✅ Failure detection
- ✅ Automatic reaction (spawning aider to fix)

**Best for:** Seeing the complete vision in action

---

### Makefile Demo (`make claude-demo`)
**Demonstrates:**
- ✅ Simple Make integration
- ✅ Session/pane management
- ✅ Command execution
- ✅ Output capture
- ✅ JSON response format

**Best for:** Quick verification that everything works

---

### Manual Demo (step-by-step)
**Demonstrates:**
- ✅ Individual bridge commands
- ✅ How Claude would call each function
- ✅ JSON output format
- ✅ Session lifecycle

**Best for:** Understanding the low-level API

---

## 📺 Expected Output Examples

### POC Demo Output:
```
[Claude POC] Starting Claude-controlled tmux orchestration POC

[Claude POC] PHASE 1: Analyzing task requirements...
[Claude POC] Task: Run server and tests in parallel, monitor for failures
[Claude POC] Decision: Need 3 panes - server, tests, monitor

[Claude POC] PHASE 2: Creating tmux session 'claude-poc'...
[SUCCESS] Session created

[Claude POC] PHASE 3: Creating panes based on task requirements...
[Claude POC]   Creating pane for: server
[Claude POC]   Creating pane for: tests
[Claude POC]   Creating pane for: monitor
[SUCCESS] All panes created (4 total including initial)

[Claude POC] PHASE 4: Executing commands in parallel...
[Claude POC]   Pane 0: Starting simulated server...
[Claude POC]   Pane 1: Running simulated tests...
[Claude POC]   Pane 2: Starting monitor...
[SUCCESS] All commands dispatched

[Claude POC] PHASE 5: Monitoring outputs (Claude analyzing results)...
[Claude POC] Checking server status...
[SUCCESS] ✓ Server is running
[Claude POC] Checking test results...
[Claude POC] ⚠ Tests have failures detected!

[Claude POC] PHASE 6: Claude decision - tests failed, spawning aider...
[Claude POC]   Creating pane for: aider
[Claude POC]   Pane 3: Starting AI-assisted debugging...
[SUCCESS] Aider engaged for automatic fixing
[SUCCESS] ✓ Aider has applied fixes

[Claude POC] PHASE 7: Final session summary...
[INFO] Active sessions:
  - claude-poc

[SUCCESS] === POC Complete ===

What happened:
  1. Claude analyzed task requirements
  2. Dynamically created 4 panes based on needs
  3. Executed parallel commands (server + tests + monitor)
  4. Monitored outputs automatically
  5. Detected test failure in real-time
  6. Intelligently spawned aider pane to fix issues
  7. All without human intervention
```

---

## 🔍 Viewing the Live Session

While any demo is running, open a new terminal and run:

```bash
tmux attach -t <session-name>
```

You'll see:
```
┌─────────────────────┬─────────────────────┐
│ Pane 0: Server      │ Pane 1: Tests       │
│ Server ready :8000  │ PASSED: 5 tests     │
│                     │                     │
├─────────────────────┼─────────────────────┤
│ Pane 2: Logs        │ Pane 3: Aider       │
│ Monitoring logs...  │ Fix applied         │
│                     │                     │
└─────────────────────┴─────────────────────┘
```

**tmux Navigation:**
- `Ctrl+a h/j/k/l` - Move between panes (vim style)
- `Ctrl+a d` - Detach (leave session running)
- `Ctrl+d` - Exit current pane

---

## 🧹 Cleanup

### Kill specific session:
```bash
./scripts/claude-tmux-bridge.sh session-kill <session-name>
# or
make claude-session-kill SESSION=<session-name>
```

### List all sessions:
```bash
./scripts/claude-tmux-bridge.sh session-list
# or
tmux ls
```

### Kill all Claude sessions:
```bash
tmux ls | grep claude | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

---

## 💡 Tips

1. **Run in iTerm2 tabs:**
   - Tab 1: Run the demo
   - Tab 2: Attach to view live session
   - Tab 3: Monitor with `tmux ls`

2. **Slow down the POC demo:**
   Edit `scripts/claude-orchestrator-poc.sh` and increase `sleep` values

3. **See JSON output:**
   All commands return JSON - pipe to `jq` for pretty printing:
   ```bash
   ./scripts/claude-tmux-bridge.sh session-create test | jq
   ```

4. **Keep sessions running:**
   Sessions persist even after detaching - great for background tasks

---

## ❓ Troubleshooting

### "tmux: command not found"
```bash
brew install tmux
```

### "Permission denied: claude-tmux-bridge.sh"
```bash
chmod +x scripts/*.sh
```

### "Session already exists"
```bash
# Kill the old one first
./scripts/claude-tmux-bridge.sh session-kill <name>
```

### Want to see what Claude sees?
```bash
# Capture output and parse JSON
./scripts/claude-tmux-bridge.sh pane-capture my-demo 0 | jq -r '.output'
```

---

## 🎯 Next Steps

After seeing the demo:
1. Read `CLAUDE_ORCHESTRATION_GUIDE.md` for real usage scenarios
2. Review `CLAUDE_TMUX_PROTOCOL.md` for API details
3. Try creating your own orchestration scripts
4. Integrate into your DevContainer workflow

---

**Enjoy the demo! 🎉**
