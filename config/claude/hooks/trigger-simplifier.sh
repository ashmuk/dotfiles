#!/bin/bash
# .claude/hooks/trigger-simplifier.sh
# UserPromptSubmit hook: Auto-inject code-simplifier on keyword detection

INPUT=$(cat)
export LANG=en_US.UTF-8
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

# Trigger keywords (English and Japanese)
KEYWORDS=("simplify" "clean up" "cleanup" "refactor" "readable" "整理" "シンプル" "きれいに" "リファクタ")

for kw in "${KEYWORDS[@]}"; do
  if printf '%s' "$PROMPT" | grep -qF "$kw"; then
    jq -n '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "Use the code-simplifier agent for this task."}}'
    exit 0
  fi
done

exit 0
