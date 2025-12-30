#!/bin/bash
# post-start.sh - DevContainer post-start setup script
# Called by postStartCommand in devcontainer.json
# Ensures symlinks for global templates exist in user home directory

set -e

# Ensure directories exist
mkdir -p /home/ashmuk/.claude
mkdir -p /home/ashmuk/.codex

# Create symbolic links for global templates in user home directory
# Link AGENTS_global.md to /home/ashmuk/.codex/AGENTS.md
if [ -f "/workspace/AGENTS_global.md" ]; then
    if [ -L "/home/ashmuk/.codex/AGENTS.md" ] || [ ! -f "/home/ashmuk/.codex/AGENTS.md" ]; then
        ln -sf /workspace/AGENTS_global.md /home/ashmuk/.codex/AGENTS.md
    fi
fi

# Link CLAUDE_global.md to /home/ashmuk/.claude/CLAUDE.md
if [ -f "/workspace/CLAUDE_global.md" ]; then
    if [ -L "/home/ashmuk/.claude/CLAUDE.md" ] || [ ! -f "/home/ashmuk/.claude/CLAUDE.md" ]; then
        ln -sf /workspace/CLAUDE_global.md /home/ashmuk/.claude/CLAUDE.md
    fi
fi

