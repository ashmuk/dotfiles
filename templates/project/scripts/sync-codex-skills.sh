#!/usr/bin/env bash
set -euo pipefail

DEST="${1:-}"
if [[ -z "${DEST}" ]]; then
  echo "Usage: sync-codex-skills.sh <DEST_DIR>"
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${ROOT}/.agent/codex/skills"

if [[ ! -d "${SRC}" ]]; then
  echo "[codex] no source skills dir: ${SRC}"
  exit 0
fi

mkdir -p "${DEST}"

echo "[codex] syncing: ${SRC} -> ${DEST}"
# Mirror copy: remove only the entries we manage (subdirs under SRC)
# Strategy: copy directory tree; do not wipe DEST entirely (safer).
for d in "${SRC}"/*; do
  [[ -d "${d}" ]] || continue
  name="$(basename "${d}")"
  rm -rf "${DEST}/${name}"
  cp -R "${d}" "${DEST}/${name}"
  echo "[codex] updated: ${DEST}/${name}"
done

echo "[codex] done"
