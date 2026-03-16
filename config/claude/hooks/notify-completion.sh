#!/bin/bash
# .claude/hooks/notify-completion.sh
# Notification: Sound + popup when Claude completes (cross-platform)

SOUNDS_DIR="${HOME}/.claude/sounds"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
  FALLBACK="/System/Library/Sounds/Hero.aiff"
  osascript -e 'display dialog "Claude Code has completed." with title "Claude Code" buttons {"OK"} default button "OK" with icon note giving up after 60' &
else
  FALLBACK="/usr/share/sounds/freedesktop/stereo/bell.oga"
  if command -v notify-send &>/dev/null; then
    notify-send "Claude Code" "Claude Code has completed."
  fi
fi

"$HOOK_DIR/play-sound.sh" "$SOUNDS_DIR/completion.mp3" "$FALLBACK"

exit 0
