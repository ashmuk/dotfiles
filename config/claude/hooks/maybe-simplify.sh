#!/bin/bash
# .claude/hooks/maybe-simplify.sh
# Stop hook: Prompt code-simplifier when many files are changed

# Consume stdin (hook protocol requires it)
cat > /dev/null

# Infinite loop prevention: use a filesystem sentinel keyed to the parent Claude process.
# After the first block, subsequent Stop invocations within 5 minutes are allowed through
# so the session can actually end.
SENTINEL="/tmp/.claude-simplify-guard-${PPID}"

if [ -f "$SENTINEL" ]; then
  # Check if sentinel is recent (< 5 min)
  if [ "$(uname)" = "Darwin" ]; then
    AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
  else
    AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
  fi
  if [ "$AGE" -lt 300 ]; then
    exit 0
  fi
  rm -f "$SENTINEL"
fi

# Check the number of changed files (staged, unstaged, and untracked)
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Only suggest simplifier if 5 or more files were changed
if [ "$CHANGED" -ge 5 ]; then
  touch "$SENTINEL"
  jq -n --arg reason "${CHANGED} files modified in this session. Please run the code-simplifier agent before finishing: 'Use code-simplifier on recently modified files'" \
    '{"decision": "block", "reason": $reason}'
  exit 0
fi

exit 0
