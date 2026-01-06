#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source: Check both .agent/skills and .agent/codex/skills for flexibility
SRC_SKILLS="${PROJECT_ROOT}/.agent/skills"
SRC_CODEX_SKILLS="${PROJECT_ROOT}/.agent/codex/skills"
DST="${PROJECT_ROOT}/.codex/skills"

# Determine source directory (prefer codex/skills if exists, otherwise skills)
if [[ -d "${SRC_CODEX_SKILLS}" ]]; then
  SRC="${SRC_CODEX_SKILLS}"
  echo "[codex] using source: .agent/codex/skills"
elif [[ -d "${SRC_SKILLS}" ]]; then
  SRC="${SRC_SKILLS}"
  echo "[codex] using source: .agent/skills"
else
  echo "[codex] no source skills dir found (checked .agent/skills and .agent/codex/skills)"
  exit 0
fi

mkdir -p "${DST}"

echo "[codex] syncing: ${SRC} -> ${DST}"
# Copy strategy:
# - If source has subdirectories (codex structure), copy each subdirectory
# - If source has .md files directly (simple structure), copy them as-is
if find "${SRC}" -mindepth 1 -maxdepth 1 -type d | grep -q .; then
  # Source has subdirectories (codex structure with SKILL.md files)
  for d in "${SRC}"/*; do
    [[ -d "${d}" ]] || continue
    name="$(basename "${d}")"
    rm -rf "${DST}/${name}"
    cp -R "${d}" "${DST}/${name}"
    echo "[codex] updated: ${DST}/${name}"
  done
else
  # Source has .md files directly (simple structure)
  # Copy all .md files to destination
  for f in "${SRC}"/*.md; do
    [[ -f "${f}" ]] || continue
    name="$(basename "${f}")"
    cp -f "${f}" "${DST}/${name}"
    echo "[codex] updated: ${DST}/${name}"
  done
fi

echo "[codex] done"
