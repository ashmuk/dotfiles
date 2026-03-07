#!/bin/bash
# Load project-level .env into Claude Code session via CLAUDE_ENV_FILE.
# Runs on SessionStart — sources .env from the current working directory
# (project root), making project-specific secrets available to Bash tool.
if [ -n "$CLAUDE_ENV_FILE" ] && [ -f ".env" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    # Validate KEY=VALUE format (skip lines without =)
    key="${line%%=*}"
    [ "$key" = "$line" ] && continue
    value="${line#*=}"
    # Trim whitespace from key
    key="$(echo "$key" | xargs)"
    # Strip surrounding quotes from value
    value="${value#\"}" ; value="${value%\"}"
    value="${value#\'}" ; value="${value%\'}"
    # Single-quote value to prevent shell expansion (escape embedded single quotes)
    printf "export %s='%s'\n" "$key" "${value//\'/\'\\\'\'}" >> "$CLAUDE_ENV_FILE"
  done < .env
fi
exit 0
