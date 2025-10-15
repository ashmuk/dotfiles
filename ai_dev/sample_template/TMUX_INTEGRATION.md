# tmux Integration Guide

## Overview

The AI Dev Template includes a project-scoped tmux configuration that automatically applies when you open the DevContainer. This provides a consistent terminal multiplexer experience across your entire team.

## Architecture

```
Project Structure:
├── .devcontainer/
│   ├── devcontainer.json     # Creates symlink in postCreateCommand
│   └── tmux/
│       └── tmux.conf         # Project-scoped config (version controlled)
└── .tmuxinator.yml           # Session layout (4-pane development)

Container Setup:
~/.tmux.conf -> /work/.devcontainer/tmux/tmux.conf (symlink)
```

## How It Works

### 1. During Container Creation

```json
// devcontainer.json
{
  "postCreateCommand": "bash -c '... && ln -sf /work/.devcontainer/tmux/tmux.conf /home/vscode/.tmux.conf'"
}
```

**What happens:**
1. Container is created
2. postCreateCommand runs
3. Symlink is created: `~/.tmux.conf` → `/work/.devcontainer/tmux/tmux.conf`
4. tmux automatically uses this config

### 2. Benefits of Project-Scoped Config

| Benefit | Description |
|---------|-------------|
| **Version Controlled** | tmux config stored in git with project |
| **Team Consistency** | Everyone uses same keybindings/settings |
| **No Host Conflicts** | Doesn't interfere with host machine tmux |
| **Per-Project Customization** | Different projects can have different configs |
| **Automatic Application** | No manual setup required |

## Configuration Features

### Custom Keybindings

| Keybinding | Action | Default tmux |
|------------|--------|--------------|
| `Ctrl-a` | Prefix key | `Ctrl-b` |
| `Ctrl-a \|` | Split horizontal | `Ctrl-b %` |
| `Ctrl-a -` | Split vertical | `Ctrl-b "` |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) | `Ctrl-b arrow` |
| `Ctrl-a H/J/K/L` | Resize panes | `Ctrl-b Ctrl-arrow` |

### Quality of Life Features

- ✅ **Mouse support** - Click to switch panes, resize with mouse
- ✅ **256-color support** - Better syntax highlighting
- ✅ **Large history** - 100,000 lines of scrollback
- ✅ **Enhanced status bar** - Shows date, time, window status
- ✅ **Aggressive resize** - Better multi-client behavior

### Status Bar

```
┌─────────────────────────────────────────────────────────────────┐
│ 0:dev* 1:tests- 2:logs                    2025-10-15  13:45:30 │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

### Starting tmux Session

```bash
# Inside container - start tmuxinator session
tmuxinator start -p .tmuxinator.yml

# This creates 4 panes:
# ┌─────────────┬─────────────┐
# │ make run    │ make test   │
# │ (server)    │ (tests)     │
# ├─────────────┼─────────────┤
# │ aider       │ monitor     │
# │ (AI assist) │ (gh pr)     │
# └─────────────┴─────────────┘
```

### Manual tmux Commands

```bash
# Start new tmux session
tmux new-session -s mysession

# List sessions
tmux ls

# Attach to session
tmux attach -t mysession

# Detach from session
Ctrl-a d

# Kill session
tmux kill-session -t mysession
```

### Window Management

```bash
# Create new window
Ctrl-a c

# Switch windows
Ctrl-a 0-9    # Jump to window number
Ctrl-a n      # Next window
Ctrl-a p      # Previous window

# Rename window
Ctrl-a ,
```

### Pane Management

```bash
# Split panes
Ctrl-a |      # Horizontal split
Ctrl-a -      # Vertical split

# Navigate panes
Ctrl-a h      # Go left
Ctrl-a j      # Go down
Ctrl-a k      # Go up
Ctrl-a l      # Go right

# Resize panes
Ctrl-a H      # Resize left
Ctrl-a J      # Resize down
Ctrl-a K      # Resize up
Ctrl-a L      # Resize right

# Close pane
Ctrl-d        # or type 'exit'
```

## Customization

### Modifying tmux Config

```bash
# Edit project-scoped config
vim .devcontainer/tmux/tmux.conf

# Reload config (inside tmux)
Ctrl-a :source-file ~/.tmux.conf
# Or:
tmux source-file ~/.tmux.conf
```

### Common Customizations

#### Change Prefix Key to Ctrl-b (default)
```bash
# In .devcontainer/tmux/tmux.conf
unbind C-a
set -g prefix C-b
bind C-b send-prefix
```

#### Add Copy Mode Vim Keybindings
```bash
# Add to .devcontainer/tmux/tmux.conf
setw -g mode-keys vi
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-selection-and-cancel
```

#### Change Status Bar Colors
```bash
# Add to .devcontainer/tmux/tmux.conf
set -g status-style 'bg=colour235 fg=colour2'
```

## Troubleshooting

### tmux config not applied

**Check symlink:**
```bash
ls -la ~/.tmux.conf
# Should show: /home/vscode/.tmux.conf -> /work/.devcontainer/tmux/tmux.conf
```

**Recreate symlink:**
```bash
ln -sf /work/.devcontainer/tmux/tmux.conf ~/.tmux.conf
```

### Keybindings not working

**Reload config:**
```bash
tmux source-file ~/.tmux.conf
```

**Or restart tmux:**
```bash
tmux kill-server
tmux
```

### Mouse not working

**Check config:**
```bash
grep "mouse" ~/.tmux.conf
# Should show: set -g mouse on
```

**Enable in running session:**
```bash
Ctrl-a :set -g mouse on
```

## Integration with tmuxinator

The `.tmuxinator.yml` file defines the default session layout:

```yaml
name: ai-dev
root: .
windows:
  - dev:
      layout: tiled
      panes:
        - make run
        - make test
        - make aider-refactor
        - echo "Monitor: use 'gh pr status --watch' after pushing"
```

**Customize layout:**
- `tiled` - 4 equal panes
- `main-horizontal` - Large pane on top
- `main-vertical` - Large pane on left
- `even-horizontal` - Horizontal split
- `even-vertical` - Vertical split

## Comparison with Host tmux

| Aspect | Host tmux | Container tmux |
|--------|-----------|----------------|
| Config location | `~/.tmux.conf` on host | `.devcontainer/tmux/tmux.conf` |
| Version control | Not in project git | ✅ In project git |
| Team sharing | Manual sync | ✅ Automatic |
| Per-project | Need separate configs | ✅ Automatic |
| Conflicts | Can interfere | ✅ Isolated |

## Advanced Usage

### Running Commands in Background

```bash
# Start server in background
tmux new-session -d -s server 'make run'

# Start tests in background
tmux new-session -d -s tests 'make test'

# View background sessions
tmux ls

# Attach to session
tmux attach -t server
```

### Scripting tmux

```bash
# Create custom session
tmux new-session -d -s work
tmux send-keys -t work 'cd /work' C-m
tmux split-window -t work -h
tmux send-keys -t work 'make run' C-m
tmux split-window -t work -v
tmux send-keys -t work 'make test' C-m
tmux attach -t work
```

## Future Enhancements

Planned features (from sample_adv vision):

- [ ] AI-controlled pane creation via markers
- [ ] Dynamic layout based on task type
- [ ] Status bar integration with AI task manager
- [ ] Automated session save/restore
- [ ] Real-time collaboration features

## References

- [tmux Documentation](https://github.com/tmux/tmux/wiki)
- [tmuxinator Guide](https://github.com/tmuxinator/tmuxinator)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)

---

**Integration completed:** 2025-10-15  
**Based on:** sample_adv tmux configuration  
**Applied to:** ai_dev/sample_template/
