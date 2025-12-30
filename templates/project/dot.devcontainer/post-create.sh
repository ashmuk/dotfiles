#!/bin/bash
# post-create.sh - DevContainer post-create setup script
# Called by postCreateCommand in devcontainer.json

set -e

echo "[post-create] Starting post-create setup..."

# Create Python virtual environment
echo "[post-create] Creating Python virtual environment..."
python3 -m venv /home/developer/.venv
source /home/developer/.venv/bin/activate

# Upgrade pip
echo "[post-create] Upgrading pip..."
pip install --upgrade pip

# Install Stage 1 dependencies (Playwright for Wix scraping)
echo "[post-create] Installing Python dependencies..."
pip install playwright beautifulsoup4 requests aiohttp pillow

# Install Playwright browsers (chromium only for faster install)
echo "[post-create] Installing Playwright browsers..."
playwright install chromium

# Create migration directories if they don't exist
echo "[post-create] Ensuring migration directories exist..."
mkdir -p /workspace/migration/{analytics,assets_legacy,concept,decisions}

# Add venv activation to .zshrc if not already present
if ! grep -q "source /home/developer/.venv/bin/activate" /home/developer/.zshrc 2>/dev/null; then
    echo "[post-create] Adding venv activation to .zshrc..."
    echo "source /home/developer/.venv/bin/activate" >> /home/developer/.zshrc
fi

# Create symbolic links for global templates in user home directory
echo "[post-create] Creating symlinks for global templates..."

# Ensure directories exist
mkdir -p /home/developer/.claude
mkdir -p /home/developer/.codex

# Link AGENTS_global.md to /home/developer/.codex/AGENTS.md
if [ -f "/workspace/AGENTS_global.md" ]; then
    if [ -L "/home/developer/.codex/AGENTS.md" ] || [ ! -f "/home/developer/.codex/AGENTS.md" ]; then
        ln -sf /workspace/AGENTS_global.md /home/developer/.codex/AGENTS.md
        echo "[post-create] Created symlink: /home/developer/.codex/AGENTS.md → /workspace/AGENTS_global.md"
    else
        echo "[post-create] Warning: /home/developer/.codex/AGENTS.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: /workspace/AGENTS_global.md not found, skipping symlink"
fi

# Link CLAUDE_global.md to /home/developer/.claude/CLAUDE.md
if [ -f "/workspace/CLAUDE_global.md" ]; then
    if [ -L "/home/developer/.claude/CLAUDE.md" ] || [ ! -f "/home/developer/.claude/CLAUDE.md" ]; then
        ln -sf /workspace/CLAUDE_global.md /home/developer/.claude/CLAUDE.md
        echo "[post-create] Created symlink: /home/developer/.claude/CLAUDE.md → /workspace/CLAUDE_global.md"
    else
        echo "[post-create] Warning: /home/developer/.claude/CLAUDE.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: /workspace/CLAUDE_global.md not found, skipping symlink"
fi

echo "[post-create] Setup complete!"
echo "[post-create] Use 'claude' for standard mode or 'claude-hard' for dangerous mode"
