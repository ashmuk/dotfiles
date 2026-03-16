# Review Findings: Claude Code Hooks Implementation

**Date**: 2026-03-16
**File**: `docs/claude/claude-hooks-requirements.md`
**Reviewer**: my-reviewer (cc-review)

## Summary

| Severity | Count | Remediated |
|----------|-------|------------|
| MUST-FIX | 2 | 2 |
| SHOULD-FIX | 7 | 7 |
| SUGGESTION | 5 | 4 |

## MUST-FIX (all remediated)

| # | Finding | Fix Applied |
|---|---------|-------------|
| 1 | `MultiEdit` is not a valid Claude Code tool name | Removed from both PostToolUse and PreToolUse matchers → `Write\|Edit` |
| 2 | `master` branch unprotected in force-push patterns | Changed to `(main\|master)` in both `--force` and `-f` patterns |

## SHOULD-FIX (all remediated)

| # | Finding | Fix Applied |
|---|---------|-------------|
| 3 | Bypass-prone patterns (`rm -rf /` extra spaces, case-sensitive SQL) | Used `\brm\s+-rf\s+/` regex; separated SQL patterns with `-i` flag |
| 4 | `git reset --hard` overly broad | Added inline comment documenting trade-off |
| 5 | Incomplete change detection in maybe-simplify.sh | Changed `git diff --name-only HEAD` → `git status --porcelain` |
| 6 | Locale-dependent Japanese grep | Added `export LANG=en_US.UTF-8` before keyword matching |
| 7 | macOS-only notify.sh, no platform guard | Added `[[ "$(uname)" == "Darwin" ]] \|\| exit 0` |
| 8 | Dialog stacking in notify.sh | Added `giving up after 60` to auto-dismiss |
| 9 | npx cost on every edit | Added local prettier check (`node_modules/.bin/prettier`) before falling back to npx with config guard |

## SUGGESTION (4 of 5 remediated)

| # | Finding | Fix Applied |
|---|---------|-------------|
| 10 | Fork bomb pattern limited | Added inline comment documenting limitation |
| 11 | `echo \| jq` unsafe for embedded newlines | Changed to `printf '%s' \| jq` in all 4 hooks |
| 12 | `^id_rsa` matches `id_rsa.pub` (false positive) | Changed to `^id_rsa$\|^id_ed25519$` |
| 13 | grep lacks `-i` for keywords | Not applied — keywords are pre-lowercased via `tr`, `-i` is unnecessary |
| 14 | Inconsistent empty `matcher` fields | Removed `matcher` from UserPromptSubmit and Notification entries |
