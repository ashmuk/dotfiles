# Dotfiles Architecture

This document describes the system architecture, design patterns, and data flows of the dotfiles repository.

**Last Updated**: 2026-01-21
**Version**: v2.4

---

## Table of Contents

1. [Overview](#overview)
2. [Directory Structure](#directory-structure)
3. [Shell Configuration System](#shell-configuration-system)
4. [Platform Detection](#platform-detection)
5. [Shared Utilities (lib/common.sh)](#shared-utilities)
6. [AI Tool Integration](#ai-tool-integration)
7. [Build System (Makefile)](#build-system)
8. [Configuration Generation vs Symlinks](#configuration-generation-vs-symlinks)
9. [Templates System](#templates-system)
10. [Data Flow Diagrams](#data-flow-diagrams)
11. [Key Architectural Patterns](#key-architectural-patterns)

---

## Overview

The dotfiles repository is a **cross-platform configuration management system** supporting:

| Platform | Status | Key Consideration |
|----------|--------|-------------------|
| macOS (Intel/ARM) | Full | BSD tools, Homebrew paths |
| Linux (Debian/Ubuntu/Arch) | Full | GNU tools standard |
| WSL1/WSL2 | Full | Path translation via wslpath |
| Cygwin/MintTY | Good | Symlink fallback to copy |
| MSYS2/Git Bash | Good | `/c/` path format |
| Windows Native | Good | PowerShell integration |

### Design Principles

1. **Single Source of Truth** - One configuration, multiple platforms
2. **Composable Modules** - Small, focused components combined at build time
3. **Defensive Programming** - Validate inputs, handle errors, create backups
4. **Progressive Enhancement** - Core functionality works everywhere, advanced features where supported
5. **AI-First Workflow** - Native integration with Claude Code, Cursor IDE, and Codex

---

## Directory Structure

```
dotfiles/
├── shell/                    # Shell environment (bash/zsh)
│   ├── shell.common          # Universal settings (~695 lines)
│   ├── shell.bash            # Bash-specific (~50 lines)
│   ├── shell.zsh             # Zsh-specific (~300 lines)
│   ├── shell.ohmy.zsh        # Oh-My-Zsh integration (~150 lines)
│   ├── aliases.common        # Universal aliases (~200 lines)
│   ├── aliases.shell         # Shell-specific aliases
│   ├── performance.sh        # Lazy-loading framework
│   ├── profile/              # Login shell profiles
│   └── setup_shell.sh        # Installation script
│
├── vim/                      # Vim configuration
│   ├── vimrc.common          # Shared vim settings
│   ├── vimrc.terminal        # Terminal-specific
│   ├── vimrc.gui             # GUI-specific (gVim/MacVim)
│   ├── vimrc.idea            # IdeaVim settings
│   ├── vimfiles/             # Plugins and runtime
│   └── setup_vimrc.sh        # Installation script
│
├── git/                      # Git configuration
│   ├── gitconfig             # Global git settings
│   ├── gitignore_global      # Global ignore patterns
│   └── setup_git.sh          # Installation script
│
├── lib/                      # Shared libraries
│   └── common.sh             # Core utilities (~590 lines)
│
├── config/                   # Application configs
│   ├── tmux/                 # Tmux configuration
│   ├── claude/               # Claude statusline/tools
│   ├── btop/                 # System monitor
│   └── vscode/               # VS Code settings
│
├── templates/                # Project templates
│   ├── project/              # Main project template
│   │   └── dot.agent/        # AI config source of truth
│   ├── global/               # User-level configs
│   └── experimental/         # Legacy/research templates
│
├── windows/                  # Windows-specific
│   ├── powershell/           # PowerShell profiles
│   └── scoop/                # Scoop package lists
│
├── .claude/                  # Claude Code configs (direct, not synced)
├── .cursor/                  # Cursor IDE configs (direct, not synced)
│
├── Makefile                  # Build automation
├── *rc.generated             # Generated config files
└── *.md                      # Documentation
```

---

## Shell Configuration System

### Modular Composition

The shell system uses a **composable, modular design** where small focused modules are combined into unified configuration files:

```
Generation Pipeline:
┌─────────────────┐     ┌──────────────┐     ┌───────────────────┐
│  shell.common   │ ──► │              │     │ bashrc.generated  │
└─────────────────┘     │  Makefile    │ ──► └───────────────────┘
┌─────────────────┐     │  (concat)    │     ┌───────────────────┐
│  shell.bash     │ ──► │              │ ──► │ zshrc.generated   │
└─────────────────┘     └──────────────┘     └───────────────────┘
┌─────────────────┐
│  shell.zsh      │ ──────────────────────►
└─────────────────┘
┌─────────────────┐
│ shell.ohmy.zsh  │ ──────────────────────►
└─────────────────┘
```

**Composition Rules:**
- `bashrc.generated` = `shell.common` + `shell.bash`
- `zshrc.generated` = `shell.common` + `shell.zsh` + `shell.ohmy.zsh` (conditional)

### Module Responsibilities

| Module | Purpose | Key Contents |
|--------|---------|--------------|
| `shell.common` | Universal base | PATH, history, env vars, tool detection, functions |
| `shell.bash` | Bash-specific | Bash options, completion settings |
| `shell.zsh` | Zsh-specific | Zsh options, plugins, key bindings |
| `shell.ohmy.zsh` | Oh-My-Zsh | Themes, plugins, custom settings (macOS only) |
| `aliases.common` | Universal aliases | Git, directory, file operation shortcuts |
| `performance.sh` | Lazy-loading | Command timing, deferred initialization |

### User Customization

Four-tiered local configuration search (in priority order):
1. `$HOME/.dotfiles-local` (highest priority)
2. `$HOME/.config/dotfiles/local`
3. `$DOTFILES_DIR/shell/local`
4. `$HOME/.dotfiles/shell/local`

Example customization:
```bash
# ~/.dotfiles-local
export MY_CUSTOM_VAR="value"
alias myalias="custom command"
```

---

## Platform Detection

### Detection Hierarchy

```bash
Platform Detection Flow:
┌─────────────────────────────────────────────────────────────┐
│                         $OSTYPE                              │
└─────────────────────────────────────────────────────────────┘
         │
         ├── darwin*     ──► macOS (Intel or Apple Silicon)
         │
         ├── linux*      ──► Check /proc/version for WSL
         │                   ├── "microsoft" found ──► WSL
         │                   └── Not found ──► Native Linux
         │
         ├── cygwin*     ──► Cygwin/MintTY
         │
         ├── msys*       ──► MSYS2/Git Bash
         │
         └── (other)     ──► Unknown/Fallback
```

### Path Format Handling

| Environment | Path Format | Conversion Tool |
|-------------|-------------|-----------------|
| Unix/macOS | `/home/user/file` | None needed |
| WSL | `/mnt/c/Users/...` | `wslpath` |
| Cygwin | `/cygdrive/c/Users/...` | `cygpath` |
| MSYS2 | `/c/Users/...` | Native or `cygpath` |

### Tool Detection Strategy

Dynamic resolution with fallback chain (using grep as example):

```
1. Check ggrep (GNU grep via Homebrew on macOS)
       │
       ▼ (not found)
2. Check /usr/local/bin/grep (manual GNU install)
       │
       ▼ (not found)
3. Check /opt/homebrew/bin/grep (Apple Silicon)
       │
       ▼ (not found)
4. Use system grep (BSD on macOS, GNU on Linux)
```

---

## Shared Utilities

### lib/common.sh Overview

The 590+ line shared library provides foundational functions for all setup scripts:

```
lib/common.sh
├── Output Functions
│   ├── print_status()      # Blue [INFO]
│   ├── print_success()     # Green [SUCCESS]
│   ├── print_warning()     # Yellow [WARNING]
│   └── print_error()       # Red [ERROR]
│
├── Platform Detection
│   ├── detect_platform()        # Returns: mac, linux, wsl, win, unknown
│   ├── detect_windows_env()     # Granular Windows detection
│   ├── test_symlink_support()   # Admin/Developer Mode check
│   └── resolve_path()           # Cross-platform path resolution
│
├── Backup & Safety
│   ├── create_backup_dir()      # Timestamped backups
│   ├── backup_file()            # Individual file backup
│   └── backup_directory()       # Directory backup
│
├── Symlink Operations
│   ├── create_symlink()         # Standard symlink
│   ├── create_symlink_safe()    # Fallback to copy if needed
│   └── sed_inplace()            # BSD/GNU sed compatibility
│
├── File Generation
│   ├── concatenate_files()              # Multi-file merge
│   ├── concatenate_files_with_shebang() # Shebang-first merge
│   └── ensure_directory()               # Safe directory creation
│
└── Error Handling
    ├── setup_error_handling()   # Trap-based cleanup
    └── cleanup_on_error()       # Temp file cleanup
```

### Usage in Setup Scripts

```bash
#!/bin/bash
set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Now use functions
print_status "Starting installation..."
PLATFORM=$(detect_platform)
create_backup_dir
create_symlink_safe "$source" "$target"
print_success "Done!"
```

---

## AI Tool Integration

> **Scope Note**: The `.agent/` sync system documented below applies to **projects created from `templates/project/`**. This dotfiles repo itself manages AI configs (`.claude/`, `.cursor/`) directly without the sync workflow.

### Centralized Source of Truth (for templated projects)

In templated projects, the `.agent/` directory serves as the master configuration that propagates to three AI platforms:

```
.agent/ (SOURCE)                    Target Outputs
├── subagents/
│   ├── analyst.md          ──►    .claude/agents/analyst.md (symlink)
│   ├── architect.md        ──►    .cursor/rules/agents/architect.md (symlink)
│   ├── builder.md          ──►    .codex/AGENTS.override.md (generated)
│   └── reviewer.md
│
├── commands/
│   ├── commit.md           ──►    .claude/commands/commit.md (symlink)
│   ├── push.md
│   └── pr.create.md
│
├── skills/
│   ├── define.md           ──►    .claude/skills/define/SKILL.md
│   ├── design.md           ──►    .cursor/rules/skills/design/RULE.md
│   ├── implement.md        ──►    .codex/skills/implement/SKILL.md
│   └── review.md
│
└── mcp/servers/
    └── *.json              ──►    Claude Code MCP configuration
```

### Sync Commands

```bash
make sync              # Full sync (all three platforms)
make sync-claude       # Claude Code only
make sync-cursor       # Cursor IDE only
make sync-codex        # Codex only
make sync-verify       # Sync + verification
```

### Agent Types

| Agent | Role | Use Cases |
|-------|------|-----------|
| **analyst** | System analysis | Task breakdown, risk identification, planning |
| **architect** | Design decisions | Tech choices, trade-offs, ADR creation |
| **builder** | Implementation | Code, scripts, infrastructure, CI/CD |
| **reviewer** | Validation | Code review, security audits, pre-merge checks |

### Workflow Skills

| Skill | Purpose | Triggers |
|-------|---------|----------|
| `/define` | Requirements gathering | Explore agents |
| `/design` | Architecture planning | Plan agents |
| `/implement` | Code generation | General-purpose agents |
| `/review` | Validation | Reviewer agents |
| `/adr` | Decision documentation | Architect agent |

---

## Build System

### Makefile Target Layers

```
Layer 1: Installation
├── make install              # All components
├── make install-shell        # Shell only
├── make install-vim          # Vim only
├── make install-git          # Git only
└── make install-windows      # Windows configs

Layer 2: Validation
├── make check-prereqs        # Tool availability
├── make validate             # Config validation
├── make test                 # Full test suite
├── make test-syntax          # Shell syntax
├── make test-shellcheck      # Static analysis
└── make test-compat          # Platform compatibility

Layer 3: Validation (continued)
└── make check-env            # Environment check

Note: `make sync` commands are available in projects created from `templates/project/`, not in this dotfiles repo.

Layer 4: WSL/Windows Bridge
├── make setup-wsl-bridge     # WSL → Windows
└── make setup-windows-bridge # Windows → WSL

Layer 5: Maintenance
├── make status               # Show status
├── make backup               # Manual backup
├── make clean                # Uninstall
└── make update               # Git pull
```

### Prerequisite Validation Flow

```
make check-prereqs
     │
     ├── Essential Tools (required)
     │   └── git, make, bash, grep, sed, awk
     │
     ├── Version Checks
     │   ├── Bash 4.0+ (associative arrays)
     │   ├── Git 2.23+ (git restore)
     │   └── Make 3.81+ (features)
     │
     ├── Core Tools (recommended)
     │   └── vim, zsh, curl, tar, find, tmux
     │
     ├── Modern Tools (optional)
     │   └── rg, fd, bat, fzf, exa
     │
     └── Dev Tools (optional)
         └── shellcheck, jq, yq, tree, htop
```

---

## Configuration Generation vs Symlinks

### Generation Strategy

Generated files contain platform detection logic, eliminating the need for OS-specific variants:

```vim
" vimrc.generated example
let s:dotfiles_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Source common settings
if filereadable(s:dotfiles_dir . '/vim/vimrc.common')
  execute 'source ' . s:dotfiles_dir . '/vim/vimrc.common'
endif

" Platform-specific
if has('win32')
  set directory=$HOME/vimfiles/tmp
else
  set directory=$HOME/.vim/tmp
endif
```

### Symlink Installation

```
Home Directory                        Dotfiles Repository
~/.bashrc          ────────►         bashrc.generated
~/.zshrc           ────────►         zshrc.generated
~/.vimrc           ────────►         vimrc.generated
~/.gvimrc          ────────►         gvimrc.generated
~/.bash_profile    ────────►         shell/profile/bash_profile
~/.tmux.conf       ────────►         config/tmux/tmux.conf
```

### Cross-Platform Symlink Safety

```bash
create_symlink_safe() {
    if test_symlink_support; then
        ln -s "$source" "$target"     # Symlink (preferred)
    else
        cp -r "$source" "$target"     # Copy (fallback)
    fi
}
```

---

## Templates System

### Template Hierarchy

```
templates/
├── project/                  # Main project template (recommended)
│   ├── dot.agent/            # AI config source of truth
│   ├── dot.devcontainer/     # Dev environment
│   ├── dot.github/           # CI/CD workflows
│   ├── scripts/              # Utility scripts
│   └── Makefile              # Project automation
│
├── global/                   # User-level configuration
│   ├── AGENTS_global.md      # Global agent patterns
│   └── CLAUDE_global.md      # Global AI guidelines
│
└── experimental/             # Legacy/research
    ├── agent/                # Old agent templates
    └── ai_dev/               # AI dev experiments
```

### Template Deployment Flow

```
templates/project/
       │
       ▼ (setup_project.sh)
new-project/
       │
       ▼ (make init)
Interactive wizard (choose template type, project name)
       │
       ▼ (make sync)
Syncs .agent/ → .claude/, .cursor/, .codex/
       │
       ▼
Ready for AI-assisted development
```

---

## Data Flow Diagrams

### Installation Flow

```
User: make install
       │
       ▼
Makefile: check-prereqs
       │ (validate tools)
       ▼
┌──────────────────────────────────────────────────────────┐
│                    Parallel Installation                  │
├─────────────────┬─────────────────┬─────────────────────┤
│  install-shell  │   install-vim   │    install-git      │
│       │         │        │        │         │           │
│       ▼         │        ▼        │         ▼           │
│ setup_shell.sh  │ setup_vimrc.sh  │   setup_git.sh      │
│       │         │        │        │         │           │
│       ▼         │        ▼        │         ▼           │
│ bashrc.generated│ vimrc.generated │    gitconfig        │
│ zshrc.generated │ gvimrc.generated│                     │
└─────────────────┴─────────────────┴─────────────────────┘
       │
       ▼
Symlinks created in $HOME
       │
       ▼
Success!
```

### Runtime Loading Flow

```
User opens terminal
       │
       ▼
~/.bashrc (symlink)
       │
       ▼
bashrc.generated
       │
       ├──► PATH setup
       ├──► Platform detection (OSTYPE)
       ├──► Tool detection (grep, du)
       ├──► Source: aliases.common
       ├──► Source: aliases.shell
       ├──► Source: performance.sh
       └──► Source: ~/.dotfiles-local (user customization)
       │
       ▼
Shell ready with all functions and aliases
```

---

## Key Architectural Patterns

### 1. Defensive Programming

Every script includes safety measures:

```bash
set -e                      # Exit on error
set -o pipefail             # Catch pipe failures
trap cleanup ERR            # Error cleanup

# Validate environment
[[ -z "$HOME" ]] && { echo "HOME not set"; exit 1; }

# Validate files before use
[[ -f "$file" ]] || { echo "File not found"; exit 1; }
```

### 2. Layered Fallbacks

Tool resolution with graceful degradation:

```bash
# Priority chain for GNU grep on macOS
if command -v ggrep &>/dev/null; then
    grep_cmd="ggrep"
elif [[ -x "/opt/homebrew/bin/grep" ]]; then
    grep_cmd="/opt/homebrew/bin/grep"
elif [[ -x "/usr/local/bin/grep" ]]; then
    grep_cmd="/usr/local/bin/grep"
else
    grep_cmd="grep"  # System default
fi
```

### 3. Cross-Platform Abstraction

Platform-specific logic encapsulated in functions:

```bash
# Instead of scattered if/else
case "$(detect_platform)" in
    mac)    handle_mac_specifics ;;
    linux)  handle_linux_specifics ;;
    wsl)    handle_wsl_specifics ;;
    *)      handle_generic ;;
esac
```

### 4. Composable Configuration

Small, focused modules combined at build time:

```bash
# Build universal config from focused modules
concatenate_files \
    "shell/shell.common" \
    "shell/shell.bash" \
    > "bashrc.generated"
```

### 5. Safe Symlinks with Fallback

Automatic degradation when symlinks unavailable:

```bash
create_symlink_safe() {
    local source="$1" target="$2"

    if test_symlink_support; then
        ln -sf "$source" "$target"
    else
        print_warning "Symlinks not supported, copying instead"
        cp -r "$source" "$target"
    fi
}
```

### 6. Dynamic Path Resolution

Runtime path detection across environments:

```bash
resolve_path() {
    local path="$1"

    case "$OSTYPE" in
        cygwin*)  cygpath -a "$path" ;;
        msys*)    cygpath -a "$path" 2>/dev/null || echo "$path" ;;
        *)        realpath "$path" 2>/dev/null || readlink -f "$path" 2>/dev/null || echo "$path" ;;
    esac
}
```

---

## Summary

The dotfiles architecture achieves cross-platform compatibility through:

1. **Modularity** - Small, focused configuration modules
2. **Generation** - Platform-aware files built at install time
3. **Abstraction** - Shared utilities hide platform differences
4. **Fallbacks** - Graceful degradation when features unavailable
5. **Validation** - Comprehensive prerequisite and syntax checking
6. **AI Integration** - Centralized agent config with multi-tool sync

This design supports six platforms (macOS, Linux, WSL, Cygwin, MSYS2, Windows) while maintaining a single source of truth for all configurations.
