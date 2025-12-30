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

# 3) Codex skills
# For now: keep them in-repo under .agent/codex/skills (single source)
# Optionally validate presence of SKILL.md
if [[ -d "${SRC_AGENT}/codex/skills" ]]; then
  echo "[sync] Codex skills: validating SKILL.md files under ${SRC_AGENT}/codex/skills"
  missing=0
  while IFS= read -r -d '' dir; do
    if [[ ! -f "${dir}/SKILL.md" ]]; then
      echo "[warn] missing SKILL.md in: ${dir}"
      missing=1
    fi
  done < <(find "${SRC_AGENT}/codex/skills" -mindepth 1 -maxdepth 2 -type d -print0)

  if [[ "${missing}" -eq 1 ]]; then
    echo "[sync] Codex skills validation: WARN (missing SKILL.md)"
  else
    echo "[sync] Codex skills validation: OK"
  fi
else
  echo "[sync] Codex skills: no ${SRC_AGENT}/codex/skills (skip)"
fi

echo "[sync] done"
