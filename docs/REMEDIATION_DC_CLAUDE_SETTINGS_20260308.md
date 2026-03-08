# Remediation Report — DevContainer Personal Claude Settings

## Summary
- Review source: cc-review of DevContainer `~/.claude` reconstruction (devcontainer.json + post-start.sh)
- Iterations: 1 of 3 max
- Status: RESOLVED
- Commit: `74dbe37` on `main`

## Problem Statement
Host `~/.claude/` contains symlinks pointing to absolute paths outside `~/.claude/` (e.g., `CLAUDE.md -> /Users/hmukai/dotfiles/...`). When bind-mounted into a container, these symlinks dangle because their targets don't exist inside the container. The previous approach used a named Docker volume, which didn't carry host settings at all.

## Solution: Three-Layer Reconstruction
Replaced the single named volume with a three-layer system inside `post-start.sh`:

1. **Layer 1 — Writable state** (`~/.claude-state/` volume): Directories and files Claude Code writes to at runtime (logs, cache, projects, credentials, etc.). Symlinked into `~/.claude/`.
2. **Layer 2 — Host personal settings** (`~/.claude-host/` read-only bind mount): User's CLAUDE.md, settings.json, plugins, hooks. Copied (not symlinked) so Claude Code can modify them in-container.
3. **Layer 3 — Project overrides** (`/workspace/.claude/`): Project-level statusline and settings that always take precedence.

A new `initializeCommand` in `devcontainer.json` resolves host symlinks into `/tmp/claude-host-resolved/` before the container starts, using `rsync -aL` with `cp -rL` fallback.

## Findings Resolution

| # | Finding | Severity | Status | Notes |
|---|---------|----------|--------|-------|
| 1 | Host symlinks dangle inside container — `cp`/`ln` fails, `set -e` aborts | MUST-FIX | FIXED | Added `initializeCommand` with `rsync -aL` to resolve symlinks pre-mount |
| 2 | Missing `~/.claude` on host breaks container creation | MUST-FIX | FIXED | `initializeCommand` creates staging dir with `|| true` fallback |
| 3 | `touch` creates empty files; Claude Code expects `{}` for JSON | SHOULD-FIX | FIXED | JSON state files initialized with `{}`, non-JSON with `touch` |
| 4 | macOS `afplay` hooks fail silently on Linux containers | SHOULD-FIX | FIXED | Generate `settings.local.json` with terminal bell (`printf '\a'`) |
| 5 | Named volume doesn't carry host settings into container | SHOULD-FIX | FIXED | Replaced with read-only bind mount of resolved host dir |

## Files Changed

| File | Change |
|------|--------|
| `templates/project/dot.devcontainer/devcontainer.json` | Added `initializeCommand`; replaced named volume with read-only bind mount + state volume |
| `templates/project/dot.devcontainer/post-start.sh` | Full rewrite: three-layer `~/.claude/` reconstruction |
| `shell/aliases.common` | Added DevContainer convenience aliases (dc-up, dc-down, dc-rebuild, etc.) |

## Verification Checklist
- [ ] Container creation with host `~/.claude/` containing symlinks
- [ ] Container creation without `~/.claude/` on host (first-time/CI)
- [ ] `~/.claude/` reconstruction: `ls -la ~/.claude/` shows correct symlinks and copies
- [ ] Claude Code starts and reads settings/plugins/hooks
- [ ] Terminal bell (`printf '\a'`) reaches host terminal from container
- [ ] Idempotency: run `post-start.sh` twice without errors
