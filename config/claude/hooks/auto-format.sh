#!/bin/bash
# .claude/hooks/auto-format.sh
# PostToolUse hook: Auto-format (Prettier + ESLint)

INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path is available
[ -z "$FILE_PATH" ] && exit 0

# Prettier (only if locally installed or configured)
if [ -x "node_modules/.bin/prettier" ]; then
  node_modules/.bin/prettier --write "$FILE_PATH" 2>/dev/null
elif [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
  command -v npx &>/dev/null && npx prettier --write "$FILE_PATH" 2>/dev/null
fi

# ESLint (JS/TS files only)
if [[ "$FILE_PATH" =~ \.(js|jsx|ts|tsx|mjs|cjs)$ ]]; then
  if command -v npx &>/dev/null; then
    npx eslint --fix "$FILE_PATH" 2>/dev/null
  fi
fi

exit 0
