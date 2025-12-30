#!/bin/bash
# post-create.sh - DevContainer post-create setup script
# Called by postCreateCommand in devcontainer.json

set -e

echo "[post-create] Starting post-create setup..."

# Create Python virtual environment
echo "[post-create] Creating Python virtual environment..."
python3 -m venv /home/ashmuk/.venv
source /home/ashmuk/.venv/bin/activate

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
if ! grep -q "source /home/ashmuk/.venv/bin/activate" /home/ashmuk/.zshrc 2>/dev/null; then
    echo "[post-create] Adding venv activation to .zshrc..."
    echo "source /home/ashmuk/.venv/bin/activate" >> /home/ashmuk/.zshrc
fi

# Create symbolic links for global templates in user home directory
echo "[post-create] Creating symlinks for global templates..."

# Ensure directories exist
mkdir -p /home/ashmuk/.claude
mkdir -p /home/ashmuk/.codex

# Link AGENTS_global.md to /home/ashmuk/.codex/AGENTS.md
if [ -f "/workspace/AGENTS_global.md" ]; then
    if [ -L "/home/ashmuk/.codex/AGENTS.md" ] || [ ! -f "/home/ashmuk/.codex/AGENTS.md" ]; then
        ln -sf /workspace/AGENTS_global.md /home/ashmuk/.codex/AGENTS.md
        echo "[post-create] Created symlink: /home/ashmuk/.codex/AGENTS.md → /workspace/AGENTS_global.md"
    else
        echo "[post-create] Warning: /home/ashmuk/.codex/AGENTS.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: /workspace/AGENTS_global.md not found, skipping symlink"
fi

# Link CLAUDE_global.md to /home/ashmuk/.claude/CLAUDE.md
if [ -f "/workspace/CLAUDE_global.md" ]; then
    if [ -L "/home/ashmuk/.claude/CLAUDE.md" ] || [ ! -f "/home/ashmuk/.claude/CLAUDE.md" ]; then
        ln -sf /workspace/CLAUDE_global.md /home/ashmuk/.claude/CLAUDE.md
        echo "[post-create] Created symlink: /home/ashmuk/.claude/CLAUDE.md → /workspace/CLAUDE_global.md"
    else
        echo "[post-create] Warning: /home/ashmuk/.claude/CLAUDE.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: /workspace/CLAUDE_global.md not found, skipping symlink"
fi

echo "[post-create] Setup complete!"
echo "[post-create] Use 'claude' for standard mode or 'claude-hard' for dangerous mode"
