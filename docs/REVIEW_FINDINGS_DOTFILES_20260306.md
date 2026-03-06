# Review Findings: Dotfiles Project (excluding templates/)

**Date:** 2026-03-06
**Scope:** All files except `templates/` directory
**Reviewers:** 3x my-reviewer agents (infrastructure, docs/AI, build system)
**Prior reviews referenced:** `docs/PROJECT_REVIEW_REPORT.md`, `docs/REVIEW_FINDINGS_HARNESS_TEMPLATE_20260306.md`

---

## Overall Rating: 7.5 / 10

| Dimension | Infrastructure | Docs/AI | Build System | Combined |
|-----------|:-:|:-:|:-:|:-:|
| **Robustness** | 7 | 7 | 6 | 6.5 |
| **Safety** | 7 | 8 | 7 | 7 |
| **Quality** | 7 | 7 | 7 | 7 |
| **Coherence** | 6 | 6 | 7 | 6.5 |
| **Overall** | **7** | **7** | **7** | **7.5** |

**Top-line**: Core dotfiles infrastructure is solid with excellent cross-platform support. Main issues are (1) documentation drift from reality, (2) inconsistent script patterns in vim setup, and (3) several Makefile/config bugs that cause silent failures.

---

## MUST-FIX (5 findings)

| # | File | Issue |
|---|------|-------|
| M1 | `.claude/agents/`, `.cursor/rules/` | **Missing my-designer agent symlinks.** CLAUDE.md, AGENTS.md, and ADR-20260306 all reference my-designer, but no symlinks exist in `.claude/agents/` or `.cursor/rules/`. |
| M2 | `Makefile:165,177,886+` | **`$(PLATFORM)` variable never defined.** Used in `_check_fonts`, `install-fonts`, `install-vim-plug`, `check-fonts` targets. All platform conditionals silently fall through to wrong branch (e.g., Linux font install runs on macOS). |
| M3 | `CLAUDE.md:29-36,68-75` | **Documents nonexistent make targets.** `make sync`, `sync-check`, `sync-verify`, `check-env`, `init`, `setup-hooks`, `fetch-from-upstream` do not exist in this repo's Makefile. DevContainer commands also inapplicable. These are template boilerplate. |
| M4 | `windows/Microsoft.PowerShell_profile.ps1:65-74` | **PowerShell git aliases broken.** `Set-Alias -Name gs -Value git status` is invalid -- `Set-Alias` only accepts a single command, not command+args. All 10 git aliases silently fail. Need function definitions instead. |
| M5 | `git/gitconfig.common:155` | **Git wip alias `$(date)` not shell-expanded.** Simple git aliases don't invoke shell, so commit message is literally `WIP: $(date)`. Needs `!git commit -am "WIP: $(date)"` prefix. |

## SHOULD-FIX (21 findings)

### Scripts: Consistency (8)

| # | File | Issue |
|---|------|-------|
| S1 | `vim/setup_vimrc.sh:7` | Uses `set -e` without `-u` or `-o pipefail` |
| S2 | `shell/setup_shell.sh:5` | Same: `set -e` only |
| S3 | `config/tmux/setup_tmux.sh:5` | Same |
| S4 | `config/claude/setup_claude.sh:5` | Same |
| S5 | `config/btop/setup_btop.sh:5` | Same |
| S6 | `config/ghostty/setup_ghostty.sh:5` | Same |
| S7 | `config/{tmux,claude,btop,ghostty}/setup_*.sh` | Use `ln -sf` directly instead of `create_symlink_safe` from lib/common.sh (breaks Cygwin, skips backup) |
| S8 | `vim/setup_vimrc.sh:27-41,99-106` | Shadows `lib/common.sh` functions (`print_*`, `detect_platform`) with local versions. Local `detect_platform` lacks WSL detection. Naming inconsistency (`print_info` vs `print_status`). |

### Scripts: Safety (2)

| # | File | Issue |
|---|------|-------|
| S9 | `vim/setup_vimrc.sh:336` | `rm -rf "$vim_dir"` deletes `~/.vim` without verifying backup succeeded. If backup loop skips files, user data lost. |
| S10 | `vim/setup_vimrc.sh:21-24` | Sources `lib/common.sh` with soft fallback but then calls functions (`create_symlink_safe`, `detect_platform`) that are only defined in common.sh. Incomplete fallback path. |

### Build System (5)

| # | File | Issue |
|---|------|-------|
| S11 | `Makefile:135` | `exa` is deprecated; replaced by `eza`. Modern tools check reports false "not found". |
| S12 | `Makefile:760` | `update` target does `git pull origin main` unconditionally. On non-main branches, this merges main into current branch unexpectedly. |
| S13 | `Makefile:846` | `test-syntax` doesn't exclude `vim/vimfiles/plugged/` (vendored plugins). `test-shellcheck` already excludes it. |
| S14 | `Makefile:273` | `install` umbrella target excludes `install-agent`. |
| S15 | `windows/setup_windows.ps1:148-152` | References nonexistent `Microsoft.PowerShell_profile_host.ps1`. Warns and skips gracefully, but intent unfulfilled. |

### Documentation Drift (6)

| # | File | Issue |
|---|------|-------|
| S16 | `README.md` | Missing 6 install targets: `install-tmux`, `install-claude`, `install-btop`, `install-ghostty`, `install-vscode`, `install-global-templates` |
| S17 | `docs/ARCHITECTURE.md:82-84` | Directory structure omits `config/ghostty/` and `config/cursor/` |
| S18 | `docs/ARCHITECTURE.md:92-94` | `windows/` structure shows nonexistent `powershell/` and `scoop/` subdirectories |
| S19 | `docs/ARCHITECTURE.md:73-75` | `git/` file names wrong: shows `gitconfig`/`gitignore_global` instead of `gitconfig.common`/`gitignore.common`/`gitattributes.common` |
| S20 | `docs/ARCHITECTURE.md:320,328` | Agent table missing my-designer; Skills table missing `/cc-test` and `/cc-remediate` |
| S21 | `.cursor/rules/00_general.md:30` | Stale reference to `ADR/` directory -- should be `docs/decisions/` |

### Git Config (2 -- grouped into S1-S8 or standalone)

| # | File | Issue |
|---|------|-------|
| S22 | `.gitignore:127` | `lib/` pattern (from Python boilerplate) blocks new files in `lib/`. Existing `lib/common.sh` is tracked but new additions would be silently excluded. |
| S23 | `.gitignore:276` | `*.generated` in `.gitignore` but 5 `.generated` files are tracked. Contradictory -- strategy unclear. |

## SUGGESTION (12 findings)

| # | File | Issue |
|---|------|-------|
| G1 | `config/claude/settings.json:125` | `afplay` sound hook is macOS-only; fails on Linux/WSL |
| G2 | `config/claude/settings.json:66` | Fork bomb deny entry is Base64-obfuscated -- confusing for auditors |
| G3 | `shell/shell.common:204` | `DOTFILES_DIR` fallback assumes `$HOME/dotfiles` |
| G4 | `shell/shell.common:272-282` | `eval "set -- $config_files"` could inject if overridden in local config |
| G5 | `lib/common.sh:588` | `setup_error_handling` trap captures var name, not value -- `temp_files` out of scope when trap fires |
| G6 | `Makefile:7` | `DOTFILES_DIR := $(shell pwd)` fragile with `make -C` |
| G7 | `vim/setup_vimrc.sh` | Japanese comments throughout; all other scripts use English |
| G8 | `docs/PROJECT_REVIEW_REPORT.md:1` | Placeholder date "2025-01-XX" never filled in |
| G9 | `docs/README_development_workflow.md:143` | Stale link to `templates/ai_dev/` (now under `experimental/`) |
| G10 | `RULES.md:7-8` | Cursor-specific frontmatter (`alwaysApply: true`) visible to all agents |
| G11 | `windows/Microsoft.PowerShell_profile.ps1:233` | Git branch detection uses `Test-Path .git` -- misses subdirectories of repos |
| G12 | `git/setup_git.sh:5-6` | Has `set -e` + `set -o pipefail` but missing `-u` -- only setup script with pipefail |

---

## Prior Review Findings Status

| Finding (from PROJECT_REVIEW_REPORT.md) | Status |
|------------------------------------------|--------|
| CLAUDE.md references CLAUDE.full.md | **FIXED** |
| README.md missing install targets | **STILL OPEN** (S16) |
| AI dev directory integration unclear | **PARTIALLY ADDRESSED** (README:301-318 added) |
| CLAUDE.md has placeholder sections | **FIXED** |
| No architecture overview | **FIXED** (docs/ARCHITECTURE.md created, but has staleness -- S17-S20) |
| Missing testing documentation | **STILL OPEN** |
| vim/setup_vimrc.sh divergent patterns | **STILL OPEN** (S8, S9, S10) |
| git/setup_git.sh custom color functions | **FIXED** (uses common.sh now) |
| Generated files strategy unclear | **STILL OPEN** (S23) |
| Japanese comments in vim setup | **STILL OPEN** (G7) |

---

## Key Strengths

- **lib/common.sh** is well-structured with comprehensive cross-platform utilities, backup support, and symlink safety
- **Agent coordination** (analyst/architect/designer/builder/reviewer) is clean with good separation
- **All .claude/ symlinks** (agents, skills, commands) resolve to valid targets (except missing my-designer)
- **ADR practice** established with 5 decision records in `docs/decisions/`
- **Makefile** has excellent prerequisite checking with platform-specific install suggestions
- **No .DS_Store files tracked** in git (clean)
- **No secrets or credentials** found in any tracked files

## Recommended Priority

1. **M1-M5**: Fix the 5 MUST-FIX items first (broken functionality)
2. **S8-S10**: Standardize vim setup script (safety concern with rm -rf)
3. **M3 + S16-S21**: Fix documentation drift as a batch
4. **S1-S7**: Standardize all setup scripts (consistency pass)
5. **S11-S15, S22-S23**: Build system and gitignore cleanup

---

**Report End**
