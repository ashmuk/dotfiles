#!/bin/bash
# DevContainer Post-Create Setup Script
# Runs after the container is created to set up the development environment
#
# Exit codes: 0 = success, 1 = failure

set -e

# Colors for output (use $'\033' for proper escape sequence interpretation)
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  DevContainer Post-Create Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Create Python virtual environment
echo -e "${BLUE}[1/5]${NC} Creating Python virtual environment..."
if [ -d "/home/ashmuk/.venv" ]; then
    echo -e "${YELLOW}  → Virtual environment already exists, skipping${NC}"
else
    python3 -m venv /home/ashmuk/.venv
    echo -e "${GREEN}  ✓ Virtual environment created at /home/ashmuk/.venv${NC}"
fi

# Step 2: Upgrade pip
echo ""
echo -e "${BLUE}[2/5]${NC} Upgrading pip..."
/home/ashmuk/.venv/bin/pip install -U pip --quiet
echo -e "${GREEN}  ✓ Pip upgraded${NC}"

# Step 3: Install Python packages from requirements.txt
echo ""
echo -e "${BLUE}[3/5]${NC} Installing Python packages..."
if [ -f "/workspace/requirements.txt" ]; then
    echo -e "  → This may take 2-5 minutes on first run..."
    echo -e "  → Installing packages (showing progress):"
    echo ""
    /home/ashmuk/.venv/bin/pip install -r /workspace/requirements.txt --progress-bar on
    echo ""
    echo -e "${GREEN}  ✓ Packages installed from requirements.txt${NC}"
else
    echo -e "${YELLOW}  ⚠ requirements.txt not found, skipping package installation${NC}"
fi

# Step 4: Set up tmux configuration
echo ""
echo -e "${BLUE}[4/5]${NC} Setting up tmux configuration..."
if [ -f "/workspace/.devcontainer/tmux/tmux.conf" ]; then
    ln -sf /workspace/.devcontainer/tmux/tmux.conf /home/ashmuk/.tmux.conf
    echo -e "${GREEN}  ✓ tmux configuration symlinked${NC}"
else
    echo -e "${YELLOW}  ⚠ tmux.conf not found, skipping${NC}"
fi

# Step 5: Enable vi mode in bash
echo ""
echo -e "${BLUE}[5/5]${NC} Enabling vi mode in bash..."
if ! grep -q "set -o vi" /home/ashmuk/.bashrc; then
    echo "" >> /home/ashmuk/.bashrc
    echo "# Enable vi mode for command line editing" >> /home/ashmuk/.bashrc
    echo "set -o vi" >> /home/ashmuk/.bashrc
    echo -e "${GREEN}  ✓ vi mode enabled in .bashrc${NC}"
else
    echo -e "${YELLOW}  → vi mode already enabled, skipping${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BLUE}Next steps:${NC}"
echo -e "    • Run ${GREEN}source /home/ashmuk/.venv/bin/activate${NC} to activate the venv"
echo -e "    • Run ${GREEN}make health-check${NC} to verify the environment"
echo -e "    • Run ${GREEN}tmuxinator start -p ai_dev.yml${NC} to launch the development session"
echo ""

exit 0
