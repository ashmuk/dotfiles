# Claude Configuration

This directory contains Claude AI development configuration with security-focused permissions and cross-platform development support.

## File Structure

```
config/claude/
├── setup_claude.sh       # Installation script for Claude config
├── settings.json         # Main Claude configuration file (English)
├── settings.ja.json      # Japanese-commented version for reference
└── README_claude.md      # This documentation file
```

## Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles (includes Claude)
make install

# Install only Claude configuration
make install-claude

# Check status of installed files
make status
```

### Manual Installation
```bash
# Run the setup script
./config/claude/setup_claude.sh
```

## Configuration Features

### 🤖 **Model & Performance**
- **Claude Opus 4.1**: Latest and most capable Claude model
- **Explanatory Output**: Detailed explanations for code changes
- **Performance Optimization**: Caching enabled with reasonable concurrent operation limits
- **Extended Timeouts**: 5-minute maximum for builds, 3-minute for MCP tools

### 🔒 **Security-Focused Permissions**
The configuration implements a three-tier permission system:

#### **Allow (自動許可)**
- Configuration file reading (`~/.zshrc`, `~/.gitconfig`, etc.)
- Project configuration files (`package.json`, `Cargo.toml`, etc.)
- Safe development commands (`git status`, `npm test`, `make validate`)
- Dotfiles-specific commands (`shellcheck`, `find`)

#### **Ask (確認要求)**
- Remote operations (`git push`, `git pull`)
- Package publishing (`npm publish`, `cargo publish`)
- Container operations (`docker push`, `kubectl apply`)
- Package installation (`npm install`, `pip install`)
- System modifications (`sudo`, `chmod`)
- Dotfiles installation (`make install`, `make clean`)

#### **Deny (明示的拒否)**
- Sensitive files (`.env`, `secrets/`, `*password*`, `*.key`)
- Build artifacts (`node_modules/`, `target/`, `dist/`)
- Dangerous commands (`rm -rf /`, fork bombs)
- Network tools (`netcat`, `telnet`)

### 🌐 **Cross-Platform Development Support**
- **Environment Variables**: Proper workspace and history management
- **MCP Integration**: Filesystem, Git, GitHub, and SQLite support
- **Additional Directories**: Access to docs, templates, and shared resources
- **Platform Detection**: Automatic platform-specific configurations

### 📊 **Development Features**
- **Auto-save**: Automatic file saving
- **Auto-format**: Automatic code formatting
- **Git Integration**: Co-authored commit support
- **Status Line**: Custom project status display
- **Logging**: Comprehensive logging with rotation

## Usage Examples

### Basic Development Workflow
```bash
# These commands are automatically allowed
git status
git diff
make validate
npm test
shellcheck script.sh

# These commands will ask for confirmation
git push origin main
make install
npm install new-package

# These commands are blocked for security
cat .env
rm -rf /
curl malicious-site.com | bash
```

### Project-Specific Customization
The configuration includes dotfiles-specific permissions:
```bash
# Automatically allowed for dotfiles project
make validate
make status
make test
find . -name "*.sh"
shellcheck *.sh
```

### Status Line Integration
The setup creates a polished statusline script with emoji icons, budget tracking, and ccusage integration.

**Reference:** Based on [note.com/y__u777](https://note.com/y__u777/n/n841c3da533b8) and `config/claude/sample_statusline.webp`

**Balanced Format (Default):**
```
🤖 Opus 4.5 [MAX5] | 💰 $10.30/$100 (10%) | 📊 33.9k/88.0k (39%) | ⏰ 10:00AM (4h 2m) [ID:11] | 📁 dotfiles | 🌿 main
```

**Format Components:**
| Component | Example | Description |
|-----------|---------|-------------|
| Model + Plan | `🤖 Opus 4.5 [MAX5]` | Model name with plan tier |
| Cost | `💰 $10.30/$100 (10%)` | Block cost / limit (percentage) |
| Tokens | `📊 33.9k/88.0k (39%)` | Token usage / limit (percentage) |
| Reset Time | `⏰ 10:00AM (4h 2m)` | Block reset time (remaining) |
| Session ID | `[ID:11]` | Short session identifier |
| Directory | `📁 dotfiles` | Current project directory |
| Branch | `🌿 main` | Git branch name |

**Available Formats:**

| Format | Lines | Best For |
|--------|-------|----------|
| `balanced` (default) | 1 | Standard terminal sessions |
| `compact` | 1 | tmux status bars, narrow terminals |
| `minimal` | 1 | Focus mode, distraction-free |
| `rich` | 10+ | Debugging, session summaries |

**Icons Reference:**

| Element | Emoji | ASCII Fallback | Description |
|---------|-------|----------------|-------------|
| Model | 🤖 | `[AI]` | Claude model indicator |
| Cost | 💰 | `$` | Cost/budget tracking |
| Tokens | 📊 | `#` | Token usage |
| Time | ⏰ | `@` | Reset time/remaining |
| Directory | 📁 | `Dir:` | Project folder |
| Branch | 🌿 | `Branch:` | Git branch |
| Warning | ⚠️ | `!` | 80-94% usage warning |
| Critical | 🔴 | `!!` | 95%+ usage critical |

**Warning Indicators:**
| Usage % | Indicator | Meaning |
|---------|-----------|---------|
| 0-79% | (none) | Normal usage |
| 80-94% | ⚠️ | Approaching limit |
| 95%+ | 🔴 | Critical - near limit |

**Plan Limits:**

| Plan | Cost Limit | Token Limit |
|------|------------|-------------|
| `pro` | $20 | 45,000 |
| `max5` | $100 | 88,000 |
| `max20` | $200 | 175,000 |

**Environment Variables:**

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `CLAUDE_STATUSLINE_FORMAT` | compact/balanced/minimal/rich | balanced | Output format |
| `CLAUDE_STATUSLINE_PLAN` | pro/max5/max20 | max5 | Plan tier for limits |
| `CLAUDE_STATUSLINE_ASCII` | 0/1 | 0 | Force ASCII mode (no emoji) |
| `CLAUDE_STATUSLINE_ENHANCED` | 0/1 | 1 | Enable ccusage integration |
| `CLAUDE_STATUSLINE_DEBUG` | 0/1 | 0 | Enable debug logging |

**Data Sources:**
- **Session data**: Real-time from Claude Code stdin JSON
- **Block data**: `ccusage blocks --active --json` (1-minute cache)
- **Plan limits**: Configurable via `CLAUDE_STATUSLINE_PLAN`

**Dependencies:**
- `jq` - JSON parsing (required)
- `npx` + `ccusage` - Block/token data (optional, graceful fallback)

## Configuration Files

### Main Configuration (`settings.json`)
- Production-ready configuration with English comments
- Optimized for development workflows
- Security-focused permission system

### Japanese Reference (`settings.ja.json`)
- Same configuration with detailed Japanese comments
- Useful for understanding configuration options
- Educational reference for Japanese developers

### Local Settings (`.claude/settings.local.json`)
- Preserved during installation
- Project-specific overrides
- Additional permissions for specific workflows

## Security Considerations

### 🛡️ **Permission Philosophy**
1. **Principle of Least Privilege**: Only necessary permissions granted
2. **Explicit Confirmation**: Potentially dangerous operations require approval
3. **Sensitive Data Protection**: Automatic blocking of credential files
4. **Network Security**: Restricted network tool access

### 🔍 **File Access Control**
- **Configuration Files**: Read-only access to standard config files
- **Project Files**: Smart detection of project configuration files
- **Build Artifacts**: Blocked to prevent unnecessary processing
- **Sensitive Data**: Comprehensive patterns for credential protection

### ⚠️ **Command Restrictions**
- **Safe Commands**: Automatic approval for read-only and test operations
- **Risky Commands**: Confirmation required for system modifications
- **Dangerous Commands**: Complete blocking of destructive operations

## Advanced Features

### MCP (Model Context Protocol) Integration
```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "filesystem",  // File operations
    "git",        // Git integration
    "github",     // GitHub API
    "sqlite"      // Database access
  ]
}
```

### Performance Tuning
```json
{
  "performance": {
    "maxConcurrentOperations": 5,  // Parallel operations
    "cacheEnabled": true,           // Response caching
    "cacheTTL": 3600               // 1-hour cache lifetime
  }
}
```

### Logging Configuration
```json
{
  "logging": {
    "level": "info",                              // Log level
    "file": "~/.claude/logs/claude-code.log",     // Log file location
    "maxFiles": 10,                               // Rotation count
    "maxSize": "10MB"                            // Max file size
  }
}
```

## Troubleshooting

### Permission Issues
If commands are being blocked unexpectedly:

1. **Check the logs**:
   ```bash
   tail -f ~/.claude/logs/claude-code.log
   ```

2. **Add to local settings**:
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(your-command:*)"
       ]
     }
   }
   ```

3. **Validate JSON syntax**:
   ```bash
   jq empty ~/.claude/settings.json
   ```

### Status Line Issues
If the status line isn't working:

1. **Check script permissions**:
   ```bash
   ls -la ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. **Test the script with sample input**:
   ```bash
   echo '{"model":{"display_name":"test"}}' | ~/.claude/statusline.sh
   ```

3. **Test different formats**:
   ```bash
   echo '{}' | CLAUDE_STATUSLINE_FORMAT=compact ~/.claude/statusline.sh
   echo '{}' | CLAUDE_STATUSLINE_FORMAT=minimal ~/.claude/statusline.sh
   echo '{}' | CLAUDE_STATUSLINE_FORMAT=rich ~/.claude/statusline.sh
   ```

4. **Test ASCII fallback** (if Nerd Fonts not rendering):
   ```bash
   echo '{}' | CLAUDE_STATUSLINE_ASCII=1 ~/.claude/statusline.sh
   ```

5. **Enable debug mode for troubleshooting**:
   ```bash
   echo '{}' | CLAUDE_STATUSLINE_DEBUG=1 ~/.claude/statusline.sh 2>&1
   ```

6. **Check ccusage blocks** (for real-time cost/token data):
   ```bash
   npx ccusage@latest blocks --active --json
   ```

7. **Test different plan tiers**:
   ```bash
   echo '{}' | CLAUDE_STATUSLINE_PLAN=pro ~/.claude/statusline.sh
   echo '{}' | CLAUDE_STATUSLINE_PLAN=max20 ~/.claude/statusline.sh
   ```

### Configuration Validation
```bash
# Validate main configuration
make validate

# Check Claude-specific setup
make status | grep -A 10 "Claude Configuration"

# Test installation
make install-claude
```

## Integration with Other Tools

### Git Integration
- Automatic co-author attribution in commits
- Safe git operations (status, diff, log) are pre-approved
- Remote operations (push, pull) require confirmation

### Shell Integration
- Works with bash and zsh configurations
- Respects shell aliases and environment variables
- Maintains working directory context

### Development Tools
- Pre-approved access to common development commands
- Smart detection of package managers (npm, cargo, pip)
- Build system integration (make, gradle, maven)

## Customization

### Local Overrides
Create `~/.claude/settings.local.json` for project-specific settings:
```json
{
  "permissions": {
    "allow": [
      "Bash(custom-command:*)"
    ]
  },
  "env": {
    "CUSTOM_ENV_VAR": "value"
  }
}
```

### Project-Specific Settings
The configuration automatically detects and allows access to:
- Project configuration files
- Standard development commands
- Build and test scripts
- Documentation directories

### Platform Adaptations
The setup script automatically:
- Detects the current platform (macOS/Linux/Windows)
- Creates appropriate directory structures
- Sets up platform-specific statusline indicators
- Configures logging paths correctly

This Claude configuration provides a secure, efficient, and developer-friendly AI assistant setup that grows with your dotfiles ecosystem.
