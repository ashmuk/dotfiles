# Tmux Configuration

This directory contains tmux configuration files with cross-platform clipboard integration and user-friendly defaults.

## File Structure

```
config/tmux/
├── setup_tmux.sh       # Installation script for tmux config and tmuxinator templates
├── tmux.conf           # Main tmux configuration file
├── tmuxinator/         # Tmuxinator session templates
│   └── ai-dev.yml      # AI development session template (4-pane layout)
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

### Tmuxinator Session Templates

Tmuxinator provides pre-configured session templates for different workflows. The setup script automatically deploys templates to `~/.tmuxinator/`.

**Installation:**
```bash
# Install tmuxinator (Ruby gem required)
gem install tmuxinator

# Or via package manager
brew install tmuxinator  # macOS
apt install tmuxinator   # Ubuntu/Debian
```

**General Usage:**
```bash
# Start a session
tmuxinator start <template-name>

# Start with environment variables
PROJECT_ROOT=/path/to/project tmuxinator start web-dev

# Edit a template
tmuxinator edit <template-name>

# List available templates
tmuxinator list
```

---

#### 1. AI Development (ai-dev.yml)

**Enhanced** AI-assisted development with auto-detection and logging.

**Features:**
- Auto-detects project type (Python/Node.js/Go/Rust)
- Configurable AI model and container command
- Project-specific test commands
- Real-time log monitoring (app logs + container logs)
- PR status tracking

**Environment Variables:**
- `PROJECT_ROOT` - Project directory (default: ~/work/repo)
- `PROJECT_TYPE` - python|node|go|rust (auto-detected)
- `AIDER_MODEL` - AI model (default: claude-4.5-sonnet)
- `CONTAINER_CMD` - devcontainer|docker (default: devcontainer)

**Windows:**
1. **compose** - Docker Compose services (auto-detects compose files)
2. **aider** - AI assistant + planning pane
3. **test** - CI/tests + test watch mode
4. **monitor** - PR status + Git status
5. **logs** - App logs + Container logs

```bash
# Start with custom settings
PROJECT_ROOT=~/projects/myapp AIDER_MODEL=gpt-4 tmuxinator start ai-dev
```

---

#### 2. Web Development (web-dev.yml)

Full-stack web development with frontend, backend, and database.

**Features:**
- Auto-detects frontend frameworks (Vite, Next.js, etc.)
- Auto-detects backend frameworks (FastAPI, Express, etc.)
- Database service management via Docker Compose
- Resource monitoring (htop, docker ps)
- API testing workspace

**Environment Variables:**
- `PROJECT_ROOT` - Project directory (default: current directory)
- `FRONTEND_DIR` - Frontend subdirectory (default: frontend)
- `BACKEND_DIR` - Backend subdirectory (default: backend)
- `DB_COMPOSE` - Docker compose file (default: docker-compose.yml)

**Windows:**
1. **frontend** - Dev server + logs/tests
2. **backend** - API server + console
3. **database** - Docker Compose database services
4. **tools** - Git + build + API testing
5. **monitor** - System resources + containers

```bash
FRONTEND_DIR=web BACKEND_DIR=api tmuxinator start web-dev
```

---

#### 3. Data Science (data-science.yml)

Data analysis and machine learning workflows.

**Features:**
- Jupyter Lab/Notebook auto-start
- IPython REPL with helpful commands
- MLflow and TensorBoard integration
- GPU monitoring (if available)
- Virtual environment auto-activation

**Environment Variables:**
- `PROJECT_ROOT` - Project directory (default: current directory)
- `NOTEBOOK_PORT` - Jupyter port (default: 8888)
- `DATA_DIR` - Data directory (default: data)

**Windows:**
1. **jupyter** - Jupyter Lab/Notebook + IPython REPL
2. **analysis** - Scripts + data exploration
3. **visualization** - Streamlit/Dash/Panel servers
4. **data** - Database + ETL pipeline
5. **experiment** - MLflow + TensorBoard
6. **monitor** - GPU + system resources

```bash
NOTEBOOK_PORT=9999 tmuxinator start data-science
```

---

#### 4. Debugging (debug.yml)

Comprehensive debugging environment for multiple languages.

**Features:**
- Auto-detects debugger for Node.js/Python/Go/Rust
- Log file monitoring (app + error logs)
- Network traffic monitoring
- CPU and memory profiling
- Breakpoint management

**Environment Variables:**
- `PROJECT_ROOT` - Project directory (default: current directory)
- `DEBUG_PORT` - Debugger port (language-specific defaults)
- `APP_COMMAND` - Application start command

**Windows:**
1. **application** - App in debug mode + debugger REPL
2. **logs** - Application logs + error logs
3. **network** - Network monitor + HTTP traffic
4. **profiler** - CPU + memory + process monitor
5. **database** - Database inspector
6. **breakpoints** - Breakpoint manager

```bash
APP_COMMAND="python -m debugpy --listen 5678 main.py" tmuxinator start debug
```

---

#### 5. General Development (dev.yml)

Basic 4-pane development layout (replicates the `td` alias behavior).

**Features:**
- System monitoring (htop/top)
- Process watcher (custom top script)
- Directory listing
- Main workspace

**Environment Variables:**
- `SESSION_NAME` - Session name (default: dev)
- `PROJECT_ROOT` - Project directory (default: ~)

**Pane Layout:**
1. **Monitor** - htop system monitor
2. **Process Watch** - Custom process watcher (~/dotfiles/bin/tmux_pane_top.sh)
3. **Files** - Directory listing
4. **Workspace** - Main workspace (focused)

```bash
# Start with default name 'dev'
tmuxinator start dev

# Start with custom session name
SESSION_NAME=myproject tmuxinator start dev

# Start in specific directory
PROJECT_ROOT=~/projects/myapp tmuxinator start dev
```

**Note:** This template replicates the behavior of the `td` alias from `shell/aliases.common`. The tmuxinator version is more flexible with environment variables and easier to customize.

---

### Template Customization

All templates support local customization:

1. **Copy to home directory** (done automatically by `make install-tmux`):
   ```bash
   cp ~/dotfiles/config/tmux/tmuxinator/*.yml ~/.tmuxinator/
   ```

2. **Edit templates:**
   ```bash
   tmuxinator edit ai-dev
   ```

3. **Create project-specific templates:**
   ```bash
   # Copy and modify
   cp ~/.tmuxinator/web-dev.yml ~/.tmuxinator/myproject.yml
   tmuxinator edit myproject
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
