#!/bin/bash
# AI Development Environment Sample Files Bootstrap Script
# This script deploys sample configuration files to a project directory
#
# Usage: Run this script from your project root directory
#   cd /path/to/your/project
#   /path/to/dotfiles/ai_dev/sample/setup_ai_dev_sample.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

echo -e "${BLUE}[INFO]${NC} AI Development Environment Setup"
echo -e "${BLUE}[INFO]${NC} Script location: $SCRIPT_DIR"
echo -e "${BLUE}[INFO]${NC} Project root: $PROJECT_ROOT"
echo ""

# Check if we're in a valid project directory
if [[ "$PROJECT_ROOT" == "$SCRIPT_DIR" ]]; then
    echo -e "${RED}[ERROR]${NC} Please run this script from your project root directory, not from the sample directory itself"
    echo -e "${YELLOW}[USAGE]${NC} cd /path/to/your/project && $0"
    exit 1
fi

# Confirm with user
echo -e "${YELLOW}[CONFIRM]${NC} This will deploy AI development configuration files to:"
echo -e "  ${PROJECT_ROOT}"
echo ""
echo -e "Files to be created:"
echo -e "  - .devcontainer/ (directory with 3 files)"
echo -e "  - .github/workflows/ (directory with CI config)"
echo -e "  - .aider.conf.yml"
echo -e "  - .env (from env.example - requires editing)"
echo -e "  - .gitignore"
echo -e "  - .pre-commit-config.yaml"
echo -e "  - Makefile"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[CANCELLED]${NC} Setup cancelled by user"
    exit 0
fi

# Create backup directory if files exist
BACKUP_DIR=""
if [[ -f ".env" || -f ".gitignore" || -f "Makefile" || -d ".devcontainer" ]]; then
    BACKUP_DIR="${PROJECT_ROOT}/.ai_dev_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${BLUE}[INFO]${NC} Backing up existing files to: $BACKUP_DIR"

    [[ -f ".env" ]] && cp ".env" "$BACKUP_DIR/" && echo -e "  - Backed up .env"
    [[ -f ".gitignore" ]] && cp ".gitignore" "$BACKUP_DIR/" && echo -e "  - Backed up .gitignore"
    [[ -f "Makefile" ]] && cp "Makefile" "$BACKUP_DIR/" && echo -e "  - Backed up Makefile"
    [[ -d ".devcontainer" ]] && cp -r ".devcontainer" "$BACKUP_DIR/" && echo -e "  - Backed up .devcontainer/"
    [[ -f ".aider.conf.yml" ]] && cp ".aider.conf.yml" "$BACKUP_DIR/" && echo -e "  - Backed up .aider.conf.yml"
    [[ -f ".pre-commit-config.yaml" ]] && cp ".pre-commit-config.yaml" "$BACKUP_DIR/" && echo -e "  - Backed up .pre-commit-config.yaml"
    echo ""
fi

# Deploy DevContainer configuration
echo -e "${BLUE}[INFO]${NC} Deploying DevContainer configuration..."
cp -r "$SCRIPT_DIR/devcontainer" "$PROJECT_ROOT/.devcontainer"
echo -e "${GREEN}[✓]${NC} Created .devcontainer/"

# Deploy GitHub Actions workflow
echo -e "${BLUE}[INFO]${NC} Deploying GitHub Actions workflow..."
mkdir -p "$PROJECT_ROOT/.github/workflows"
cp -r "$SCRIPT_DIR/github/workflows/"* "$PROJECT_ROOT/.github/workflows/"
echo -e "${GREEN}[✓]${NC} Created .github/workflows/ci.yml"

# Deploy configuration files
echo -e "${BLUE}[INFO]${NC} Deploying configuration files..."

cp "$SCRIPT_DIR/aider.conf.yml" "$PROJECT_ROOT/.aider.conf.yml"
echo -e "${GREEN}[✓]${NC} Created .aider.conf.yml"

cp "$SCRIPT_DIR/env.example" "$PROJECT_ROOT/.env"
echo -e "${GREEN}[✓]${NC} Created .env (from env.example)"

cp "$SCRIPT_DIR/gitignore" "$PROJECT_ROOT/.gitignore"
echo -e "${GREEN}[✓]${NC} Created .gitignore"

cp "$SCRIPT_DIR/pre-commit-config.yaml" "$PROJECT_ROOT/.pre-commit-config.yaml"
echo -e "${GREEN}[✓]${NC} Created .pre-commit-config.yaml"

cp "$SCRIPT_DIR/Makefile" "$PROJECT_ROOT/Makefile"
echo -e "${GREEN}[✓]${NC} Created Makefile"

# Deploy VSCode tasks (optional but recommended)
if [ -d "$SCRIPT_DIR/vscode" ]; then
  echo -e "${BLUE}[INFO]${NC} Deploying VSCode tasks..."
  mkdir -p "$PROJECT_ROOT/.vscode"
  cp "$SCRIPT_DIR/vscode/tasks.json" "$PROJECT_ROOT/.vscode/tasks.json"
  echo -e "${GREEN}[✓]${NC} Created .vscode/tasks.json"
fi

echo ""
echo -e "${GREEN}[SUCCESS]${NC} AI development environment files deployed successfully!"
echo ""
echo -e "${BLUE}[NEXT STEPS]${NC}"
echo -e "  1. Edit .env file to add your API keys:"
echo -e "     ${YELLOW}vim .env${NC}"
echo -e "     - Add ANTHROPIC_API_KEY"
echo -e "     - Add OPENAI_API_KEY"
echo -e "     - Add GITHUB_TOKEN"
echo ""
echo -e "  2. Open project in DevContainer (VSCode/Cursor):"
echo -e "     ${YELLOW}Cmd+Shift+P${NC} → 'Dev Containers: Reopen in Container'"
echo ""
echo -e "  3. Set up tmux environment on host (if not already done):"
echo -e "     ${YELLOW}make install-tmux${NC} (from dotfiles root)"
echo ""
echo -e "  4. Start AI development session:"
echo -e "     ${YELLOW}tmuxinator start ai-dev${NC}"
echo ""
echo -e "${BLUE}[DOCUMENTATION]${NC}"
echo -e "  - Architecture Guide: $(dirname "$SCRIPT_DIR")/README_ai_dev_arch.md"
echo -e "  - Setup Guide: $(dirname "$SCRIPT_DIR")/README_ai_dev.md"
echo -e "  - Sample Files Info: $SCRIPT_DIR/README_ai_dev_sample.md"
echo ""

if [[ -n "$BACKUP_DIR" ]]; then
    echo -e "${YELLOW}[BACKUP]${NC} Original files backed up to: $BACKUP_DIR"
    echo ""
fi

echo -e "${YELLOW}[IMPORTANT]${NC} Remember to:"
echo -e "  - Never commit .env file to version control"
echo -e "  - Review and customize Makefile targets for your project"
echo -e "  - Adjust .devcontainer/Dockerfile for project-specific dependencies"
echo ""
