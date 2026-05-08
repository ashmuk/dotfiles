#!/bin/bash
# .claude/hooks/policy-guard.sh
# PreToolUse hook: User-policy command blocker
#
# Distinct from security-guard.sh: this enforces user-defined policy
# (no `terraform apply/destroy`, no `git push` to main/master) rather than
# objectively-dangerous shell. Bypass with POLICY_GUARD_BYPASS=1.
#
# Design: docs/designs/policy-guard.md
# NOTE: Regex-based blocking is best-effort, not a sandbox — same caveat
# as security-guard.sh. Encoded/aliased/indirect commands can slip through.

INPUT=$(cat)

# Fail-open with stderr note rather than silently — visibility matters more than enforcement
# in the missing-tool case, since silent fail-open is the exact drift this hook was built to prevent.
if ! command -v jq >/dev/null 2>&1; then
  echo "policy-guard: jq unavailable; failing open" >&2
  exit 0
fi

# Two jq calls preserve real whitespace (tabs/newlines) in the command string.
# Avoids @tsv's escape-to-literal-\t behavior that let tab-separated commands slip through.
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

[ "$TOOL" != "Bash" ] && exit 0
[ "${POLICY_GUARD_BYPASS:-}" = "1" ] && exit 0
[ -z "$COMMAND" ] && exit 0

TF_PATTERN='\bterraform\s+(apply|destroy)\b'
GP_PATTERN='\bgit\s+push\b.*(^|[[:space:]:+"'\''])(main|master)([[:space:]:^~"'\'']|$)'

if printf '%s' "$COMMAND" | grep -qE -- "$TF_PATTERN"; then
  echo "Blocked by policy-guard: terraform apply/destroy. Set POLICY_GUARD_BYPASS=1 to override." >&2
  exit 2
fi

if printf '%s' "$COMMAND" | grep -qE -- "$GP_PATTERN"; then
  echo "Blocked by policy-guard: git push to main/master. Set POLICY_GUARD_BYPASS=1 to override." >&2
  exit 2
fi

exit 0
