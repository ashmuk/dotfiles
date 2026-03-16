#!/bin/bash
# .claude/hooks/notify-attention.sh
# Notification: Sound + popup when Claude needs attention (cross-platform)

SOUNDS_DIR="${HOME}/.claude/sounds"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
  FALLBACK="/System/Library/Sounds/Glass.aiff"
  osascript -e 'display dialog "Claude Code needs your attention." with title "Claude Code" buttons {"OK"} default button "OK" with icon caution giving up after 60' &
else
  FALLBACK="/usr/share/sounds/freedesktop/stereo/bell.oga"
  # Linux notification (best-effort)
  if command -v notify-send &>/dev/null; then
    notify-send --urgency=critical "Claude Code" "Claude Code needs your attention."
  fi
fi

"$HOOK_DIR/play-sound.sh" "$SOUNDS_DIR/notification.mp3" "$FALLBACK"

exit 0
