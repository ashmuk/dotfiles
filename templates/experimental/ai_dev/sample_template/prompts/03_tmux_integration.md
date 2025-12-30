# tmux Integration Test Prompt

## Objective
Verify tmux configuration and tmuxinator session management work correctly.

## Prerequisites
- Basic setup completed (`01_basic_setup.md`)
- Inside DevContainer

## Instructions for AI Assistant

### 1. Verify tmux Config Symlink
```bash
# Check if symlink exists and points to correct location
ls -la ~/.tmux.conf
readlink ~/.tmux.conf
```

Expected: `~/.tmux.conf -> /work/.devcontainer/tmux/tmux.conf`

### 2. Verify tmux Config Content
```bash
# Check key configurations
grep -E "(prefix|split-window|select-pane)" ~/.tmux.conf | head -10
```

Expected: Should show Ctrl-a prefix and custom split bindings.

### 3. Test tmux Basics
```bash
# Start tmux session (then detach)
tmux new-session -d -s test-session

# Check session exists
tmux list-sessions

# Send a command to the session
tmux send-keys -t test-session 'echo "tmux works!"' C-m

# Capture pane output
tmux capture-pane -t test-session -p

# Kill test session
tmux kill-session -t test-session
```

Expected: Session should be created, command executed, and cleaned up.

### 4. Test Custom Keybindings
```bash
# Verify prefix key configuration
tmux show-options -g | grep prefix

# Check split window bindings
tmux list-keys | grep split-window
```

Expected: Should show `prefix C-a` and custom split bindings.

### 5. Verify tmuxinator Configuration
```bash
# Check tmuxinator config exists
cat .tmuxinator.yml
```

Expected: Should show 4-pane layout (dev window with tiled layout).

### 6. Test tmuxinator Session (Background)
```bash
# Start tmuxinator session in background
tmuxinator start -p .tmuxinator.yml ai-dev &
sleep 3

# List tmux sessions
tmux list-sessions

# Check windows in session
tmux list-windows -t ai-dev

# Kill session
tmux kill-session -t ai-dev
```

Expected:
- Session 'ai-dev' created
- Window 'dev' with 4 panes
- All commands queued in panes

### 7. Test Mouse Support
```bash
# Check if mouse is enabled
tmux show-options -g | grep mouse
```

Expected: `mouse on`

### 8. Test Status Bar
```bash
# Check status bar configuration
tmux show-options -g | grep status
```

Expected: Status bar should be configured with custom colors and format.

## Manual Testing (Optional)

If you want to manually test tmux:

```bash
# Start interactive tmux session
tmux

# Try custom keybindings:
# Ctrl-a |  (split horizontal)
# Ctrl-a -  (split vertical)
# Ctrl-a h/j/k/l  (navigate panes vim-style)
# Ctrl-a H/J/K/L  (resize panes)
# Ctrl-a d  (detach)
```

## Success Criteria

✅ tmux config symlink is correct
✅ Custom prefix (Ctrl-a) is configured
✅ Custom split bindings work
✅ Mouse support is enabled
✅ tmuxinator config is valid
✅ Background session creation works

## Troubleshooting

If symlink is missing:
```bash
ln -sf /work/.devcontainer/tmux/tmux.conf ~/.tmux.conf
```

If tmux doesn't see config:
```bash
tmux source-file ~/.tmux.conf
```

## Estimated Time
3-5 minutes

## Next Steps
If successful, proceed to `04_full_workflow.md` for complete ecosystem testing.
