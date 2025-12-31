#!/bin/bash
# post-start.sh - DevContainer post-start setup script
# Called by postStartCommand in devcontainer.json
# Ensures symlinks for global templates exist in user home directory

set -e

# Ensure directories exist
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.codex"

# Create symbolic links for global templates in user home directory
# Link AGENTS_global.md to ~/.codex/AGENTS.md
if [ -f "/workspace/AGENTS_global.md" ]; then
    if [ -L "$HOME/.codex/AGENTS.md" ] || [ ! -f "$HOME/.codex/AGENTS.md" ]; then
        ln -sf /workspace/AGENTS_global.md "$HOME/.codex/AGENTS.md"
    fi
fi

# Link CLAUDE_global.md to ~/.claude/CLAUDE.md
if [ -f "/workspace/CLAUDE_global.md" ]; then
    if [ -L "$HOME/.claude/CLAUDE.md" ] || [ ! -f "$HOME/.claude/CLAUDE.md" ]; then
        ln -sf /workspace/CLAUDE_global.md "$HOME/.claude/CLAUDE.md"
    fi
fi

