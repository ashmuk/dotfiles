#!/bin/bash
# .claude/hooks/notify.sh
# Notification hook: Sound + popup (cross-platform)

SOUNDS_DIR="${HOME}/.claude/sounds"

if [[ "$(uname)" == "Darwin" ]]; then
  if [[ -f "$SOUNDS_DIR/notification.mp3" ]]; then
    afplay "$SOUNDS_DIR/notification.mp3" &
  else
    afplay /System/Library/Sounds/Glass.aiff &
  fi
  osascript -e 'display dialog "Claude Code needs your attention." with title "Claude Code" buttons {"OK"} default button "OK" with icon caution giving up after 60'
  exit 0
fi

# Linux fallback (best-effort)
if command -v notify-send &>/dev/null; then
  notify-send --urgency=critical "Claude Code" "Claude Code needs your attention."
fi
if [[ -f "$SOUNDS_DIR/notification.mp3" ]]; then
  if command -v ffplay &>/dev/null; then
    ffplay -nodisp -autoexit "$SOUNDS_DIR/notification.mp3" 2>/dev/null &
  elif command -v mpv &>/dev/null; then
    mpv --no-terminal "$SOUNDS_DIR/notification.mp3" 2>/dev/null &
  fi
elif command -v paplay &>/dev/null; then
  paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null &
fi

exit 0
