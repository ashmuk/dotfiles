# Tmux Configuration

This directory contains tmux configuration files with cross-platform clipboard integration and user-friendly defaults.

## File Structure

```
config/tmux/
├── setup_tmux.sh       # Installation script for tmux config
├── tmux.conf           # Main tmux configuration file
└── README_tmux.md      # This documentation file
```

## Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles (includes tmux)
make install

# Install only tmux configuration
make install-tmux

# Check status of installed files
make status
```

### Manual Installation
```bash
# Run the setup script
./config/tmux/setup_tmux.sh
```

## Configuration Features

### 🎨 **Display & Interface**
- **256-color support**: Full color terminal support with `xterm-256color`
- **Mouse support**: Click to select panes and windows, scroll through history
- **Large history**: 100,000 lines of scrollback buffer
- **Auto-renaming**: Windows automatically rename based on running command
- **Window renumbering**: Gaps in window numbers are automatically filled

### ⌨️ **Key Bindings**
- **Prefix key**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Pane splitting**:
  - `Prefix + |` for horizontal split (creates vertical panes)
  - `Prefix + -` for vertical split (creates horizontal panes)
- **Config reload**: `Prefix + r` to reload configuration
- **Vi-style navigation**: Vi key bindings in copy mode

### 📋 **Cross-Platform Clipboard Integration**
Environment-aware clipboard support that automatically detects your platform:

- **macOS**: Uses `pbcopy` for seamless integration with system clipboard
- **WSL (Windows Subsystem for Linux)**: Uses `clip.exe` for Windows clipboard access
- **X11/Linux**: Uses `xclip` for X Window System clipboard integration

All clipboard integrations use proper command detection and fallback gracefully if tools are not available.

### 🔧 **Copy Mode**
- **Vi-style keys**: Familiar navigation for vim users
- **Smart copying**: `y` in copy mode automatically copies to system clipboard and exits copy mode
- **Automatic clipboard**: Selected text is automatically copied to system clipboard

## Usage Examples

### Basic Session Management
```bash
# Create new session
tmux new-session -s work

# Attach to existing session
tmux attach -t work

# List sessions
tmux list-sessions
```

### Pane Management
```bash
# Split panes (after pressing Ctrl-a)
|    # Create vertical split (horizontal pane division)
-    # Create horizontal split (vertical pane division)

# Navigate between panes
Ctrl-a + arrow keys    # Move between panes
```

### Copy Mode
```bash
# Enter copy mode
Ctrl-a + [

# In copy mode (vi-style)
h,j,k,l    # Navigate
v          # Start visual selection
y          # Copy selection and exit copy mode
q          # Exit copy mode without copying
```

### Configuration Management
```bash
# Reload configuration
Ctrl-a + r

# Test configuration syntax (before applying)
tmux -f ~/.tmux.conf list-commands
```

## Platform-Specific Features

### macOS
- Integrates with system clipboard via `pbcopy`
- Works seamlessly with Terminal.app and iTerm2
- Supports native macOS scrolling behavior

### Linux/X11
- Uses `xclip` for clipboard integration
- Works with most terminal emulators (gnome-terminal, konsole, xterm)
- Supports X11 selection buffer

### Windows/WSL
- Automatically detects WSL environment via `$WSL_DISTRO_NAME`
- Uses `clip.exe` to integrate with Windows clipboard
- Seamless copy/paste between WSL and Windows applications

## Troubleshooting

### Clipboard Not Working
1. **Check required tools**:
   ```bash
   # macOS
   which pbcopy

   # Linux
   which xclip

   # WSL
   which clip.exe
   ```

2. **Install missing tools**:
   ```bash
   # macOS (usually pre-installed)
   # No action needed

   # Ubuntu/Debian
   sudo apt install xclip

   # CentOS/RHEL
   sudo yum install xclip

   # Arch Linux
   sudo pacman -S xclip
   ```

### Colors Not Working
1. **Check terminal support**:
   ```bash
   echo $TERM
   # Should show: xterm-256color, screen-256color, or similar
   ```

2. **Set terminal type**:
   ```bash
   export TERM=xterm-256color
   ```

### Mouse Not Working
1. **Enable mouse support** (should be automatic):
   ```bash
   # In tmux command mode (Ctrl-a + :)
   set -g mouse on
   ```

## Integration with Other Tools

### Vim Integration
The vim configuration in this dotfiles project includes tmux-aware settings:
- Proper color handling in tmux sessions
- Cursor shape changes work correctly
- Background color clearing for tmux compatibility

### Shell Integration
- Works seamlessly with bash and zsh configurations
- Respects shell aliases and functions
- Maintains environment variables across sessions

## Customization

### Local Overrides
Create `~/.tmux.conf.local` to add personal customizations:
```bash
# Example local customizations
set -g status-position top
set -g status-bg blue

# Source the main config
source-file ~/.tmux.conf
```

### Plugin Management
Consider adding TPM (Tmux Plugin Manager) for additional functionality:
```bash
# Add to tmux.conf
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
```

## Performance Considerations

The configuration is optimized for performance:
- Efficient clipboard detection using conditional commands
- Minimal startup overhead
- Large but reasonable history buffer (100k lines)
- Mouse support without excessive CPU usage

## Security Notes

- Clipboard integration only activates when appropriate tools are detected
- No external network connections or data transmission
- Local-only configuration with standard tmux security model
