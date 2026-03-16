#!/bin/bash
# .claude/hooks/maybe-simplify.sh
# Stop hook: Prompt code-simplifier when many files are changed

INPUT=$(cat)

# Infinite loop prevention: skip if the Stop hook has already fired once
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi

# Check the number of changed files (staged, unstaged, and untracked)
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Only suggest simplifier if 5 or more files were changed
if [ "$CHANGED" -ge 5 ]; then
  jq -n --arg reason "${CHANGED} files modified in this session. Please run the code-simplifier agent before finishing: 'Use code-simplifier on recently modified files'" \
    '{"decision": "block", "reason": $reason}'
  exit 0
fi

exit 0
