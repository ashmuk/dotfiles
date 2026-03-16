#!/bin/bash
# .claude/hooks/security-guard.sh
# PreToolUse hook: Dangerous command blocker

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')

# Skip non-Bash tools
[ "$TOOL" != "Bash" ] && exit 0

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# Blocked patterns
DANGEROUS_PATTERNS=(
  '\brm\s+-rf\s+/'
  '\brm\s+-rf\s+\*'
  'sudo rm'
  'git push --force.*(main|master)'
  'git push -f.*(main|master)'
  'git reset --hard'       # Broad: also blocks safe usage on feature branches (trade-off for safety)
  'chmod 777'
  ':\(\)\{.*\|.*&\}'      # Fork bomb — only matches :() naming; renamed variants bypass
)

# Case-insensitive SQL patterns
SQL_PATTERNS=(
  'DROP TABLE'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "Blocked dangerous command: $pattern" >&2
    exit 2
  fi
done

for pattern in "${SQL_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qiE "$pattern"; then
    echo "Blocked dangerous command: $pattern" >&2
    exit 2
  fi
done

exit 0
