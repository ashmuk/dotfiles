#!/bin/bash
# DevContainer Post-Create Setup Script
# Runs after the container is created to set up the development environment
#
# Exit codes: 0 = success, 1 = failure

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  DevContainer Post-Create Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Create Python virtual environment
echo -e "${BLUE}[1/4]${NC} Creating Python virtual environment..."
if [ -d "/home/vscode/.venv" ]; then
    echo -e "${YELLOW}  → Virtual environment already exists, skipping${NC}"
else
    python3 -m venv /home/vscode/.venv
    echo -e "${GREEN}  ✓ Virtual environment created at /home/vscode/.venv${NC}"
fi

# Step 2: Upgrade pip
echo ""
echo -e "${BLUE}[2/4]${NC} Upgrading pip..."
/home/vscode/.venv/bin/pip install -U pip --quiet
echo -e "${GREEN}  ✓ Pip upgraded${NC}"

# Step 3: Install Python packages from requirements.txt
echo ""
echo -e "${BLUE}[3/4]${NC} Installing Python packages..."
if [ -f "/work/requirements.txt" ]; then
    echo -e "  → This may take 2-5 minutes on first run..."
    echo -e "  → Installing packages (showing progress):"
    echo ""
    /home/vscode/.venv/bin/pip install -r /work/requirements.txt --progress-bar on
    echo ""
    echo -e "${GREEN}  ✓ Packages installed from requirements.txt${NC}"
else
    echo -e "${YELLOW}  ⚠ requirements.txt not found, skipping package installation${NC}"
fi

# Step 4: Set up tmux configuration
echo ""
echo -e "${BLUE}[4/4]${NC} Setting up tmux configuration..."
if [ -f "/work/.devcontainer/tmux/tmux.conf" ]; then
    ln -sf /work/.devcontainer/tmux/tmux.conf /home/vscode/.tmux.conf
    echo -e "${GREEN}  ✓ tmux configuration symlinked${NC}"
else
    echo -e "${YELLOW}  ⚠ tmux.conf not found, skipping${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BLUE}Next steps:${NC}"
echo -e "    • Run ${GREEN}source /home/vscode/.venv/bin/activate${NC} to activate the venv"
echo -e "    • Run ${GREEN}make health-check${NC} to verify the environment"
echo -e "    • Run ${GREEN}tmuxinator start -p ai_dev.yml${NC} to launch the development session"
echo ""

exit 0
