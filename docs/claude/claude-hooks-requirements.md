# Claude Code Hooks Implementation Requirements

Implementation specification for 6 hooks.

| # | Hook Name | Event | Purpose |
|---|---|---|---|
| 1 | `auto-format.sh` | PostToolUse | Auto-format after file edits |
| 2 | `security-guard.sh` | PreToolUse | Block dangerous commands |
| 3 | `file-guard.sh` | PreToolUse | Warn on writes to sensitive files |
| 4 | `maybe-simplify.sh` | Stop | Prompt code-simplifier when many files changed |
| 5 | `trigger-simplifier.sh` | UserPromptSubmit | Inject code-simplifier on keyword detection |
| 6 | `notify.sh` | Notification | Sound + popup dialog notification |

---

## Prerequisites

- `jq` command must be installed
- Project root must be under git version control (used by hook 4 for change detection)
- Hooks 4 and 5 require the `code-simplifier` plugin to be installed:
  ```bash
  claude plugin install code-simplifier
  # Or from within a session:
  /plugin marketplace update claude-plugins-official
  /plugin install code-simplifier
  ```
  Restart the session after installation to activate.

---

## File Structure

```
.claude/
├── settings.json
└── hooks/
    ├── auto-format.sh         # 1 PostToolUse: Auto-format
    ├── security-guard.sh      # 2 PreToolUse:  Dangerous command blocker
    ├── file-guard.sh          # 3 PreToolUse:  Sensitive file protection
    ├── maybe-simplify.sh      # 4 Stop:        code-simplifier prompt
    ├── trigger-simplifier.sh  # 5 UserPromptSubmit: Keyword injection
    └── notify.sh              # 6 Notification: Sound + dialog notification
```

---

## Implementation 1: `.claude/hooks/auto-format.sh`

**Purpose**: Automatically run Prettier and ESLint after file edits or creation.

```bash
#!/bin/bash
# .claude/hooks/auto-format.sh
# PostToolUse hook: Auto-format (Prettier + ESLint)

FILE_PATH=$(jq -r '.tool_input.file_path // empty')

# Skip if no file path is available
[ -z "$FILE_PATH" ] && exit 0

# Prettier
if command -v npx &>/dev/null; then
  npx prettier --write "$FILE_PATH" 2>/dev/null
fi

# ESLint (JS/TS files only)
if echo "$FILE_PATH" | grep -qE '\.(js|jsx|ts|tsx|mjs|cjs)$'; then
  if command -v npx &>/dev/null; then
    npx eslint --fix "$FILE_PATH" 2>/dev/null
  fi
fi

exit 0
```

**Behavior**:
- Always exits 0 (non-blocking)
- Runs Prettier first, then ESLint
- ESLint only targets JS/TS files

---

## Implementation 2: `.claude/hooks/security-guard.sh`

**Purpose**: Detect and block dangerous Bash commands.

```bash
#!/bin/bash
# .claude/hooks/security-guard.sh
# PreToolUse hook: Dangerous command blocker

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Skip non-Bash tools
[ "$TOOL" != "Bash" ] && exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Blocked patterns
DANGEROUS_PATTERNS=(
  'rm -rf /'
  'rm -rf \*'
  'sudo rm'
  'git push --force.*main'
  'git push -f.*main'
  'git reset --hard'
  'chmod 777'
  'DROP TABLE'
  ':\(\)\{.*\|.*&\}'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "Blocked dangerous command: $pattern" >&2
    exit 2
  fi
done

exit 0
```

**Behavior**:
- On match: exit 2 (block); the reason on stderr is sent to Claude
- Non-Bash tools are skipped

---

## Implementation 3: `.claude/hooks/file-guard.sh`

**Purpose**: Inject a warning context before writes to `.env`, private keys, and certificate files (does not block).

```bash
#!/bin/bash
# .claude/hooks/file-guard.sh
# PreToolUse hook: Warn on writes to sensitive files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

FILENAME=$(basename "$FILE_PATH")

# Sensitive file patterns
if echo "$FILENAME" | grep -qiE '^\.env$|^\.env\.|\.pem$|\.key$|^id_rsa|credentials\.json$|secrets\.json$'; then
  jq -n --arg warn "Warning: You are about to edit a sensitive file ($FILENAME). Verify this change is truly necessary. Do not commit secrets or tokens in plaintext." \
    '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": $warn}}'
fi

exit 0
```

**Behavior**:
- Always exits 0 (non-blocking)
- Uses `additionalContext` for soft guidance to Claude
- Targets: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`, `credentials.json`, `secrets.json`

---

## Implementation 4: `.claude/hooks/maybe-simplify.sh`

**Purpose**: Check the number of changed files via git at session end; if 5 or more files were changed, prompt the user to run code-simplifier.

```bash
#!/bin/bash
# .claude/hooks/maybe-simplify.sh
# Stop hook: Prompt code-simplifier when many files are changed

INPUT=$(cat)

# Infinite loop prevention: skip if the Stop hook has already fired once
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi

# Check the number of recently changed files in git
CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')

# Only suggest simplifier if 5 or more files were changed
if [ "$CHANGED" -ge 5 ]; then
  jq -n --arg reason "${CHANGED} files modified in this session. Please run the code-simplifier agent before finishing: 'Use code-simplifier on recently modified files'" \
    '{"decision": "block", "reason": $reason}'
  exit 0
fi

exit 0
```

**Behavior**:
- Changed files < 5: skip
- Changed files >= 5: `decision: block` prompts Claude to run the simplifier
- If `stop_hook_active=true`: unconditional skip (infinite loop prevention)

---

## Implementation 5: `.claude/hooks/trigger-simplifier.sh`

**Purpose**: When the prompt contains specific keywords, inject `additionalContext` instructing Claude to use the `code-simplifier` agent.

```bash
#!/bin/bash
# .claude/hooks/trigger-simplifier.sh
# UserPromptSubmit hook: Auto-inject code-simplifier on keyword detection

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

# Trigger keywords (English and Japanese)
KEYWORDS=("simplify" "clean up" "cleanup" "refactor" "readable" "整理" "シンプル" "きれいに" "リファクタ")

for kw in "${KEYWORDS[@]}"; do
  if echo "$PROMPT" | grep -q "$kw"; then
    jq -n '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "Use the code-simplifier agent for this task."}}'
    exit 0
  fi
done

exit 0
```

**Behavior**:
- Keyword found: inject code-simplifier instruction into `additionalContext`
- No keyword: skip

---

## Implementation 6: `.claude/hooks/notify.sh`

**Purpose**: When Claude sends a notification (awaiting permission, idle), play a sound effect (afplay) and show a popup dialog (display dialog) in parallel. The dialog remains visible until OK is pressed, ensuring the user notices.

```bash
#!/bin/bash
# .claude/hooks/notify.sh
# Notification hook: Sound effect + popup dialog (parallel execution)

# Play sound effect in the background (simultaneous with dialog)
afplay /System/Library/Sounds/Glass.aiff &

# Popup dialog (stays until OK is pressed)
osascript -e 'display dialog "Claude Code needs your attention." with title "Claude Code" buttons {"OK"} default button "OK" with icon caution'

exit 0
```

**Behavior**:
- `afplay ... &` launches the sound in the background, playing simultaneously with the dialog
- `display dialog` shows a modal dialog in the center of the screen
- The dialog remains until the OK button is pressed (partially blocks other app interactions)
- `with icon caution` displays a warning icon

**Alternative sounds** (under `/System/Library/Sounds/`):

| Filename | Impression |
|---|---|
| `Glass.aiff` | Light and clear (recommended default) |
| `Hero.aiff` | Bright and prominent |
| `Ping.aiff` | Simple and short |
| `Submarine.aiff` | Low and calm |
| `Tink.aiff` | Small and subtle |

> **Note**: `display dialog` runs in the foreground, so the hook script itself does not exit until the dialog is dismissed. Since Notification hooks are non-blocking, this does not affect Claude's operation, but be aware that the script process persists until the dialog is closed.

---

## `.claude/settings.json` Configuration

If an existing `hooks` section exists, merge into it (do not overwrite).

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-format.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/security-guard.sh"
          }
        ]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/file-guard.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/maybe-simplify.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/trigger-simplifier.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/notify.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Setup Steps

```bash
# 1. Create hooks directory
mkdir -p .claude/hooks

# 2. Create each script file with the contents above (6 files)

# 3. Grant execute permissions to all scripts
chmod +x .claude/hooks/*.sh

# 4. Add hooks configuration to settings.json (merge with existing settings)

# 5. Restart Claude Code to apply the settings
```

---

## Verification

| Scenario | Expected Behavior |
|---|---|
| Claude edits a file | Prettier / ESLint run automatically |
| Attempts to run `rm -rf /` | Blocked; reason is communicated to Claude |
| Attempts to run `git push --force main` | Same as above |
| Attempts to edit a `.env` file | Warning context is injected (no block) |
| Attempts to edit `id_rsa` | Same as above |
| Session ends with 4 or fewer changed files | Stop hook skips |
| Session ends with 5 or more changed files | Blocks and prompts code-simplifier execution |
| Stop fires with `stop_hook_active=true` | Unconditional skip (infinite loop prevention) |
| Prompt contains "refactor" | code-simplifier instruction is injected |
| Prompt contains "整理して" (Japanese: "clean up") | Same as above |
| Normal prompt without keywords | Nothing happens |
| Claude is awaiting permission or idle | Glass.aiff plays and a popup dialog appears |
| OK button is pressed on the dialog | Dialog closes and the script exits |

---

## Customization Points

- **Change formatter**: Replace `npx prettier` in `auto-format.sh` with `black` (Python), etc.
- **Add blocked patterns**: Append to the `DANGEROUS_PATTERNS` array in `security-guard.sh`
- **Add protected files**: Extend the grep pattern in `file-guard.sh`
- **Change simplifier threshold**: Adjust the number in `[ "$CHANGED" -ge 5 ]` in `maybe-simplify.sh`
- **Add keywords**: Append to the `KEYWORDS` array in `trigger-simplifier.sh`
- **Change sound**: Replace `Glass.aiff` in `notify.sh` with another system sound
- **Change dialog message**: Edit the `display dialog` text in `notify.sh`
- **Change scope**: Place `settings.json` at `~/.claude/settings.json` to apply across all projects
