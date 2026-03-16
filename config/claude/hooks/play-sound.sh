#!/bin/bash
# .claude/hooks/play-sound.sh
# Shared helper: play a sound file cross-platform (macOS + Linux)
# Usage: play-sound.sh <sound-file> [fallback-system-sound]

SOUND_FILE="$1"
FALLBACK="$2"

# Resolve the file to play
if [ -n "$SOUND_FILE" ] && [ -f "$SOUND_FILE" ]; then
  TARGET="$SOUND_FILE"
elif [ -n "$FALLBACK" ] && [ -f "$FALLBACK" ]; then
  TARGET="$FALLBACK"
else
  exit 0
fi

if [[ "$(uname)" == "Darwin" ]]; then
  afplay "$TARGET" &
else
  # Linux: try ffplay → mpv → paplay (best-effort cascade)
  if command -v ffplay &>/dev/null; then
    ffplay -nodisp -autoexit "$TARGET" 2>/dev/null &
  elif command -v mpv &>/dev/null; then
    mpv --no-terminal "$TARGET" 2>/dev/null &
  elif command -v paplay &>/dev/null; then
    paplay "$TARGET" 2>/dev/null &
  fi
fi

exit 0
