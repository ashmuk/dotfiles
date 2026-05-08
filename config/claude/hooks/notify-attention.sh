#!/bin/bash
# .claude/hooks/notify-attention.sh
# Sound notification (cross-platform) + non-modal Linux toast.
# macOS popup omitted to avoid stealing focus mid-task.

SOUNDS_DIR="${HOME}/.claude/sounds"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
  FALLBACK="/System/Library/Sounds/Glass.aiff"
else
  FALLBACK="/usr/share/sounds/freedesktop/stereo/bell.oga"
  # Linux notification (best-effort)
  if command -v notify-send &>/dev/null; then
    notify-send --urgency=critical "Claude Code" "Claude Code needs your attention."
  fi
fi

"$HOOK_DIR/play-sound.sh" "$SOUNDS_DIR/notification.mp3" "$FALLBACK"

exit 0
