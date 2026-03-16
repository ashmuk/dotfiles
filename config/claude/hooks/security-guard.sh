#!/bin/bash
# .claude/hooks/security-guard.sh
# PreToolUse hook: Dangerous command blocker

INPUT=$(cat)

# Parse tool name and command in a single jq call
read -r TOOL COMMAND < <(printf '%s' "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv')

# Skip non-Bash tools
[ "$TOOL" != "Bash" ] && exit 0

# Blocked patterns (combined into single alternation for efficiency on the hot path)
# NOTE: Regex-based blocking is inherently bypassable (encoding, aliasing, multi-line
# splitting, variable indirection, etc.). This is a best-effort guardrail, not a sandbox.
DANGEROUS_PATTERN='\brm\s+-rf\s+/|\brm\s+-rf\s+\*|sudo rm|git push --force.*(main|master)|git push -f.*(main|master)|git push\s+\S+\s+(main|master)\s+--force|--force-with-lease.*(main|master)|git reset --hard|chmod 777|:\(\)\{.*\|.*&\}|bash\s+-c|\beval\b'

# Case-insensitive SQL pattern
SQL_PATTERN='DROP TABLE'

if printf '%s' "$COMMAND" | grep -qE -- "$DANGEROUS_PATTERN"; then
  # Identify which pattern matched for the error message
  for p in '\brm\s+-rf\s+/' '\brm\s+-rf\s+\*' 'sudo rm' \
           'git push --force.*(main|master)' 'git push -f.*(main|master)' \
           'git push\s+\S+\s+(main|master)\s+--force' '--force-with-lease.*(main|master)' \
           'git reset --hard' 'chmod 777' ':\(\)\{.*\|.*&\}' 'bash\s+-c' '\beval\b'; do
    if printf '%s' "$COMMAND" | grep -qE -- "$p"; then
      echo "Blocked dangerous command: $p" >&2
      break
    fi
  done
  exit 2
fi

if printf '%s' "$COMMAND" | grep -qiE -- "$SQL_PATTERN"; then
  echo "Blocked dangerous command: $SQL_PATTERN" >&2
  exit 2
fi

exit 0
