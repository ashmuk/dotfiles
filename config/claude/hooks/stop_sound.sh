#!/bin/bash
# .claude/hooks/stop_sound.sh
# Stop hook: Play completion sound (cross-platform)
# Skips sound if maybe-simplify.sh would block (≥5 files changed)

# SG-1: Don't play "done" sound if simplifier will block the session
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGED" -ge 5 ]; then
  exit 0
fi

SOUNDS_DIR="${HOME}/.claude/sounds"

if [[ "$(uname)" == "Darwin" ]]; then
  if [[ -f "$SOUNDS_DIR/completion.mp3" ]]; then
    afplay "$SOUNDS_DIR/completion.mp3" &
  else
    afplay /System/Library/Sounds/Hero.aiff &
  fi
  exit 0
fi

# Linux fallback (best-effort)
if [[ -f "$SOUNDS_DIR/completion.mp3" ]]; then
  if command -v ffplay &>/dev/null; then
    ffplay -nodisp -autoexit "$SOUNDS_DIR/completion.mp3" 2>/dev/null &
  elif command -v mpv &>/dev/null; then
    mpv --no-terminal "$SOUNDS_DIR/completion.mp3" 2>/dev/null &
  fi
elif command -v paplay &>/dev/null; then
  paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null &
fi

exit 0
