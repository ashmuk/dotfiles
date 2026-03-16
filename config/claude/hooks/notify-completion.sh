#!/bin/bash
# .claude/hooks/notify-completion.sh
# Notification: Play completion sound when session stops (cross-platform)
# Skips sound if maybe-simplify.sh would block (≥5 files changed)

# SG-1: Don't play "done" sound if simplifier will block the session.
# Check for maybe-simplify.sh's sentinel instead of re-running git status.
SENTINEL="/tmp/.claude-simplify-guard-${PPID}"
if [ -f "$SENTINEL" ]; then
  exit 0
fi

SOUNDS_DIR="${HOME}/.claude/sounds"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
  FALLBACK="/System/Library/Sounds/Hero.aiff"
else
  FALLBACK="/usr/share/sounds/freedesktop/stereo/bell.oga"
fi

"$HOOK_DIR/play-sound.sh" "$SOUNDS_DIR/completion.mp3" "$FALLBACK"

exit 0
