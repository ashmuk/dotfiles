#!/bin/bash
# .claude/hooks/file-guard.sh
# PreToolUse hook: Warn on writes to sensitive files

INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

FILENAME=$(basename "$FILE_PATH")

# Sensitive file patterns
if echo "$FILENAME" | grep -qiE '^\.env$|^\.env\.|\.pem$|\.key$|^id_rsa$|^id_ed25519$|credentials\.json$|secrets\.json$'; then
  jq -n --arg warn "Warning: You are about to edit a sensitive file ($FILENAME). Verify this change is truly necessary. Do not commit secrets or tokens in plaintext." \
    '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": $warn}}'
fi

exit 0
