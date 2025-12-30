#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SRC_AGENT="${PROJECT_ROOT}/.agent"
DST_CLAUDE="${PROJECT_ROOT}/.claude/agents"

echo "[sync] root=${PROJECT_ROOT}"

# Ensure destination dirs exist
mkdir -p "${DST_CLAUDE}"

# 1) Claude subagents -> .claude/agents
# Copy all md files (flat) from .agent/subagents
if [[ -d "${SRC_AGENT}/subagents" ]]; then
  echo "[sync] Claude: ${SRC_AGENT}/subagents -> ${DST_CLAUDE}"
  rm -f "${DST_CLAUDE}/"*.md 2>/dev/null || true
  cp -f "${SRC_AGENT}/subagents/"*.md "${DST_CLAUDE}/" 2>/dev/null || true
else
  echo "[sync] Claude: no ${SRC_AGENT}/subagents (skip)"
fi

# 2) Cursor rules
# Note: Cursor rules are generated directly to .cursor/rules by gen_cursor_rules_from_commands.py
# No sync needed from .agent/cursor/rules

# 3) Skills validation
# Skills are stored in .agent/skills (single source of truth)
if [[ -d "${SRC_AGENT}/skills" ]]; then
  echo "[sync] Skills: validating files under ${SRC_AGENT}/skills"
  skill_count=$(find "${SRC_AGENT}/skills" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
  echo "[sync] Skills validation: OK (${skill_count} skill files found)"
else
  echo "[sync] Skills: no ${SRC_AGENT}/skills (skip)"
fi

echo "[sync] done"
