#!/bin/bash
# .claude/hooks/security-guard.sh
# PreToolUse hook: Dangerous command blocker

INPUT=$(cat)

# Fail-open with stderr note rather than silently — visibility matters when the guard can't run.
if ! command -v jq >/dev/null 2>&1; then
  echo "security-guard: jq unavailable; failing open" >&2
  exit 0
fi

# Two jq calls preserve real whitespace (tabs/newlines) in the command string.
# Earlier @tsv approach escaped real tabs to literal \t, letting tab-separated commands slip past \s patterns.
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

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
