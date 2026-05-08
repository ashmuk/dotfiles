#!/bin/bash
# .claude/hooks/notify-completion.sh
# Sound notification (cross-platform) + non-modal Linux toast.
# macOS popup omitted to avoid stealing focus mid-task.

SOUNDS_DIR="${HOME}/.claude/sounds"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
  FALLBACK="/System/Library/Sounds/Hero.aiff"
else
  FALLBACK="/usr/share/sounds/freedesktop/stereo/bell.oga"
  if command -v notify-send &>/dev/null; then
    notify-send "Claude Code" "Claude Code has completed."
  fi
fi

"$HOOK_DIR/play-sound.sh" "$SOUNDS_DIR/completion.mp3" "$FALLBACK"

exit 0
