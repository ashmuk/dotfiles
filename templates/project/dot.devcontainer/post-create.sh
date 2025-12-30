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

echo "[post-create] Setup complete!"
echo "[post-create] Use 'claude' for standard mode or 'claude-hard' for dangerous mode"
