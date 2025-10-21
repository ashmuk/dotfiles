#!/bin/bash
# Setup script for AI Dev Template
# Deploys the template to a target project directory
# Converts 'dot.*' files/directories to '.*' (hidden) in target

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-}"

# Colors (use $'\033' for proper escape sequence interpretation)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Convert dot.* filename to .* (hidden)
convert_dotname() {
  local src="$1"
  local basename
  basename=$(basename "$src")

  if [[ "$basename" == dot.* ]]; then
    # Remove 'dot.' prefix and add '.' prefix
    echo ".${basename#dot.}"
  else
    echo "$basename"
  fi
}

# Usage info
usage() {
  cat <<EOF
${BLUE}AI Dev Template Setup Script${NC}

Usage: $0 <target-directory>

This script deploys the AI Dev template to a target project directory.
Files/directories prefixed with 'dot.' in the template are deployed as
hidden files/directories (with '.' prefix) in the target.

Example:
  $0 /path/to/my-project

What this script does:
  1. Copies all configuration files to target directory
  2. Converts 'dot.*' to '.*' (hidden files/directories)
  3. Creates .env from dot.env.example
  4. Backs up existing files with .backup extension
  5. Sets appropriate file permissions
  6. Provides next steps for setup

Template structure:
  dot.devcontainer/    → .devcontainer/
  dot.github/          → .github/
  dot.vscode/          → .vscode/
  dot.aider.conf.yml   → .aider.conf.yml
  dot.env.example      → .env
  dot.gitignore        → .gitignore
  ... etc ...

EOF
  exit 1
}

# Check arguments
if [ -z "$TARGET_DIR" ]; then
  usage
fi

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

print_header "AI Dev Template Setup"
print_info "Template source: $SCRIPT_DIR"
print_info "Target directory: $TARGET_DIR"
echo ""

# Confirm
read -p "Deploy template to $TARGET_DIR? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_warning "Cancelled by user"
  exit 0
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  print_info "Creating target directory..."
  mkdir -p "$TARGET_DIR"
  print_success "Directory created"
fi

cd "$TARGET_DIR"

# Backup existing files
backup_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    mv "$file" "${file}.backup"
    print_warning "Backed up existing $file to ${file}.backup"
  elif [ -d "$file" ]; then
    mv "$file" "${file}.backup"
    print_warning "Backed up existing $file/ to ${file}.backup/"
  fi
}

print_header "Copying Configuration Files"

# DevContainer files
print_info "Copying dot.devcontainer/ → .devcontainer/..."
backup_if_exists ".devcontainer"
mkdir -p .devcontainer
cp -r "$SCRIPT_DIR/dot.devcontainer/"* .devcontainer/
chmod +x .devcontainer/health-check.sh 2>/dev/null || true
print_success ".devcontainer/ copied"

# GitHub workflows
print_info "Copying dot.github/ → .github/..."
backup_if_exists ".github"
mkdir -p .github/workflows
cp -r "$SCRIPT_DIR/dot.github/workflows/"* .github/workflows/
print_success ".github/workflows/ copied"

# VSCode tasks
print_info "Copying dot.vscode/ → .vscode/..."
backup_if_exists ".vscode"
mkdir -p .vscode
cp "$SCRIPT_DIR/dot.vscode/tasks.json" .vscode/
print_success ".vscode/tasks.json copied"

# Root config files (convert dot.* to .*)
print_info "Copying configuration files..."
for src_file in "$SCRIPT_DIR"/dot.*; do
  # Skip if it's a directory (already handled above)
  if [ -d "$src_file" ]; then
    continue
  fi

  if [ -f "$src_file" ]; then
    target_name=$(convert_dotname "$src_file")

    # Skip .env.example special handling for now
    if [ "$target_name" = ".env.example" ]; then
      continue
    fi

    backup_if_exists "$target_name"
    cp "$src_file" "$target_name"
    print_success "$target_name copied"
  fi
done

# Copy Makefile (doesn't have dot. prefix)
if [ -f "$SCRIPT_DIR/Makefile" ]; then
  backup_if_exists "Makefile"
  cp "$SCRIPT_DIR/Makefile" Makefile
  print_success "Makefile copied"
fi

# Copy requirements.txt (doesn't have dot. prefix)
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
  backup_if_exists "requirements.txt"
  cp "$SCRIPT_DIR/requirements.txt" requirements.txt
  print_success "requirements.txt copied"
fi

# Create .env from dot.env.example
if [ ! -f ".env" ]; then
  if [ -f "$SCRIPT_DIR/dot.env.example" ]; then
    cp "$SCRIPT_DIR/dot.env.example" .env
    print_success ".env created from dot.env.example"
    print_warning "⚠ IMPORTANT: Edit .env and add your API keys!"
  fi
else
  print_info ".env already exists, skipping"
fi

# Copy sample app if app/ doesn't exist
if [ ! -d "app" ]; then
  print_info "Copying sample application..."
  cp -r "$SCRIPT_DIR/app" app/
  print_success "Sample app/ copied"
else
  print_info "app/ directory exists, skipping"
fi

# Copy sample tests if tests/ doesn't exist
if [ ! -d "tests" ]; then
  print_info "Copying sample tests..."
  cp -r "$SCRIPT_DIR/tests" tests/
  print_success "Sample tests/ copied"
else
  print_info "tests/ directory exists, skipping"
fi

# Copy prompts directory if prompts/ doesn't exist
if [ ! -d "prompts" ]; then
  print_info "Copying AI prompts..."
  cp -r "$SCRIPT_DIR/prompts" prompts/
  print_success "Sample prompts/ copied"
else
  print_info "prompts/ directory exists, skipping"
fi

# Copy Claude-tmux documentation
print_info "Copying Claude-tmux documentation..."
if [ -f "$SCRIPT_DIR/CLAUDE_TMUX_PROTOCOL.md" ]; then
  cp "$SCRIPT_DIR/CLAUDE_TMUX_PROTOCOL.md" .
  print_success "CLAUDE_TMUX_PROTOCOL.md copied"
fi
if [ -f "$SCRIPT_DIR/CLAUDE_ORCHESTRATION_GUIDE.md" ]; then
  cp "$SCRIPT_DIR/CLAUDE_ORCHESTRATION_GUIDE.md" .
  print_success "CLAUDE_ORCHESTRATION_GUIDE.md copied"
fi
if [ -f "$SCRIPT_DIR/QUICKSTART_DEMO.md" ]; then
  cp "$SCRIPT_DIR/QUICKSTART_DEMO.md" .
  print_success "QUICKSTART_DEMO.md copied"
fi

# Create scripts directory and copy Claude-tmux scripts
print_info "Copying Claude-tmux orchestration scripts..."
mkdir -p scripts
if [ -f "$SCRIPT_DIR/scripts/claude-tmux-bridge.sh" ]; then
  cp "$SCRIPT_DIR/scripts/claude-tmux-bridge.sh" scripts/
  chmod +x scripts/claude-tmux-bridge.sh
  print_success "claude-tmux-bridge.sh copied"
fi
if [ -f "$SCRIPT_DIR/scripts/claude-orchestrator-poc.sh" ]; then
  cp "$SCRIPT_DIR/scripts/claude-orchestrator-poc.sh" scripts/
  chmod +x scripts/claude-orchestrator-poc.sh
  print_success "claude-orchestrator-poc.sh copied"
fi
print_success "scripts/ directory ready"

# Copy Claude Code settings
print_header "Setting up Claude Code Configuration"
CLAUDE_SETTINGS_SRC="$(dirname "$(dirname "$SCRIPT_DIR")")/config/claude/settings.json"
if [ -f "$CLAUDE_SETTINGS_SRC" ]; then
  print_info "Copying Claude Code settings..."
  mkdir -p .claude
  backup_if_exists ".claude/settings.json"
  cp "$CLAUDE_SETTINGS_SRC" .claude/settings.json
  print_success "Claude Code settings.json copied to .claude/"
else
  print_warning "Claude settings not found at $CLAUDE_SETTINGS_SRC"
  print_info "Skipping Claude settings (optional)"
fi

# Bootstrap agent configuration
print_header "Bootstrapping Agent Configuration"
AGENT_SETUP_SCRIPT="$(dirname "$(dirname "$SCRIPT_DIR")")/agent/setup_agent.sh"
if [ -f "$AGENT_SETUP_SCRIPT" ]; then
  print_info "Running agent setup script..."
  bash "$AGENT_SETUP_SCRIPT" "$TARGET_DIR" || print_warning "Agent setup encountered issues (non-critical)"
  print_success "Agent configuration bootstrapped"
else
  print_warning "Agent setup script not found at $AGENT_SETUP_SCRIPT"
  print_info "Skipping agent bootstrap (optional)"
fi

print_header "Setup Complete!"

cat <<EOF

${GREEN}✓ Template deployed successfully!${NC}

${BLUE}Files deployed:${NC}
  dot.devcontainer/      → .devcontainer/
    └── tmux/tmux.conf   → (symlinked to ~/.tmux.conf in container)
  dot.github/            → .github/
  dot.vscode/            → .vscode/
  dot.aider.conf.yml     → .aider.conf.yml
  dot.ai_dev.yml         → ai_dev.yml
  dot.gitignore          → .gitignore
  dot.pre-commit-config.yaml → .pre-commit-config.yaml
  dot.env.example        → .env
  Makefile               → Makefile
  requirements.txt       → requirements.txt
  app/                   → app/
  tests/                 → tests/
  prompts/               → prompts/
  scripts/               → scripts/ (claude-tmux bridge + POC)
  .claude/settings.json  → Claude Code configuration
  CLAUDE_TMUX_PROTOCOL.md          → Protocol specification
  CLAUDE_ORCHESTRATION_GUIDE.md    → Usage guide
  QUICKSTART_DEMO.md               → Quick demo instructions

${BLUE}Agent configuration (CLAUDE.md, AGENTS.md, .cursor/):${NC}
  Bootstrapped via agent/setup_agent.sh

${BLUE}Next Steps:${NC}

1. ${YELLOW}Configure API Keys:${NC}
   ${BLUE}vim .env${NC}
   Add your ANTHROPIC_API_KEY, OPENAI_API_KEY, and GITHUB_TOKEN

2. ${YELLOW}Open in DevContainer:${NC}
   ${BLUE}code .${NC}  # or cursor .
   Then: Cmd+Shift+P → "Dev Containers: Reopen in Container"

3. ${YELLOW}Inside Container - Verify Environment:${NC}
   ${BLUE}make health-check${NC}

4. ${YELLOW}Install Pre-commit Hooks:${NC}
   ${BLUE}make pre-commit-install${NC}

5. ${YELLOW}Run Tests:${NC}
   ${BLUE}make test${NC}

6. ${YELLOW}Start tmux Session:${NC}
   ${BLUE}tmuxinator start -p ai_dev.yml${NC}

7. ${YELLOW}Test Claude-tmux Orchestration (NEW!):${NC}
   ${BLUE}./scripts/claude-orchestrator-poc.sh${NC}    # Full demo
   ${BLUE}make claude-demo${NC}                       # Quick demo
   See QUICKSTART_DEMO.md for details

8. ${YELLOW}Try AI-Assisted Development:${NC}
   ${BLUE}make aider-plan${NC}
   ${BLUE}make aider-refactor${NC}

9. ${YELLOW}Review Agent Configuration:${NC}
   ${BLUE}cat CLAUDE.md${NC}  # Project-specific AI guidelines
   ${BLUE}cat AGENTS.md${NC}  # Agent collaboration patterns

${BLUE}Documentation:${NC}
  - DevContainer: .devcontainer/devcontainer.json
  - Makefile: See 'make' for all commands
  - VSCode Tasks: Cmd+Shift+P → "Tasks: Run Task"
  - Health Check: make health-check

${YELLOW}Important:${NC}
  - Never commit .env file (already in .gitignore)
  - Review backed up files (*.backup) before deleting
  - Run 'make health-check' to verify environment

${GREEN}Happy AI-driven development! 🚀${NC}

EOF
