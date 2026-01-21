# Dotfiles Project - Windows 11 MintTY/Cygwin Compatibility Review

**Date**: 2026-01-21
**Reviewer**: Claude Code
**Project**: `/Users/hmukai/dotfiles`
**Scope**: Windows 11 with MintTY/Cygwin environment consistency

---

## Executive Summary

| Aspect | Status | Grade |
|--------|--------|-------|
| **Cygwin Detection** | Works but lacks granularity | B |
| **MintTY Support** | Files exist, not auto-configured | C+ |
| **Symlink Handling** | Will fail without admin privileges | D |
| **Path Translation** | Partial - missing /cygdrive/c | B- |
| **Git Configuration** | Wrong defaults for Cygwin | C |

**Overall Cygwin/MintTY Grade: C+**

The project has good MSYS2/WSL support but Cygwin-specific handling is incomplete. MintTY color themes exist but aren't automatically applied.

---

## Critical Issues (3)

### 1. Symlink Creation Fails on Cygwin Without Admin
**Severity**: CRITICAL
**Files**: `shell/setup_shell.sh:39`, `git/setup_git.sh:92`, `vim/setup_vimrc.sh:320`
**Issue**: `ln -sf` requires admin privileges or Developer Mode on Windows/Cygwin
**Impact**: Fresh install fails silently, configs not linked
**Fix**: Add symlink capability detection; fallback to file copy

### 2. Git core.ignorecase Wrong for Cygwin
**Severity**: CRITICAL
**File**: `git/gitconfig.common:19`
**Current**: `ignorecase = false`
**Issue**: NTFS is case-insensitive; this causes checkout failures and merge conflicts
**Fix**: Detect Cygwin in `git/setup_git.sh` and set `core.ignorecase = true`

### 3. Git core.filemode Wrong for Cygwin
**Severity**: CRITICAL
**File**: `git/gitconfig.common:17`
**Current**: `filemode = true`
**Issue**: NTFS doesn't preserve Unix permissions; causes spurious diffs
**Fix**: Detect Cygwin and set `core.filemode = false`

---

## High Severity Issues (4)

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | `lib/common.sh` | No `/cygdrive/c` path format support | Add Cygwin path detection |
| 2 | `shell/shell.common:555-584` | `readlink -f` not available on Cygwin | Use `cygpath` fallback |
| 3 | `shell/shell.zsh:158-161` | MintTY colors sourced only if file exists in ~/etc | Auto-copy during setup |
| 4 | `Makefile:94,107` | `sed -i` without platform detection | Create cross-platform sed wrapper |

---

## Medium Severity Issues (7)

| # | File | Line | Issue |
|---|------|------|-------|
| 1 | `lib/common.sh` | 50-62 | MSYS2 and Cygwin treated identically |
| 2 | `shell/shell.common` | 90 | grep brace expansion may fail |
| 3 | `shell/shell.common` | 677-698 | `find -type l` unreliable on NTFS |
| 4 | `Makefile` | 278+ | `chmod +x` ineffective on NTFS |
| 5 | `shell/shell.zsh` | 74,86 | `/tmp` on Cygwin has permission quirks |
| 6 | `git/gitconfig.common` | 15 | `autocrlf = input` may need docs for Cygwin |
| 7 | - | - | No MintTY terminal detection ($TERM_PROGRAM) |

---

## Current State Analysis

### What Works Well
- `$OSTYPE == cygwin*` detection exists in `lib/common.sh`
- `detect_windows_env()` function distinguishes cygwin from msys
- `cygpath` usage in `shell/shell.common:490` for path conversion
- MintTY color themes exist in `etc/mintty-colors-solarized/`
- Vim excludes Cygwin from clipboard (`vimrc.terminal:115`)
- Windows gvim path candidates include `/c/` format

### What's Missing
- No automatic symlink fallback to copy
- No Cygwin-specific git configuration
- MintTY colors not auto-installed
- No `/cygdrive/c/` path format (older Cygwin style)
- No MintTY terminal detection for auto-theming
- No documentation for Cygwin prerequisites

---

## Recommended Fixes

### Phase 1: Critical (Symlinks & Git)

**1.1 Add symlink fallback in `lib/common.sh`**
```bash
create_symlink_safe() {
    local source="$1" target="$2"
    if [[ "$OSTYPE" == cygwin* ]]; then
        # Test if symlinks work
        if ln -sf /dev/null /tmp/.symlink_test 2>/dev/null; then
            rm -f /tmp/.symlink_test
            ln -sf "$source" "$target"
        else
            # Fallback: copy file
            cp -f "$source" "$target"
            echo "[WARN] Symlinks unavailable, copied instead: $target"
        fi
    else
        ln -sf "$source" "$target"
    fi
}
```

**1.2 Add Cygwin git config in `git/setup_git.sh`**
```bash
if [[ "$OSTYPE" == cygwin* ]]; then
    git config --global core.ignorecase true
    git config --global core.filemode false
fi
```

### Phase 2: High Priority (Paths & MintTY)

**2.1 Add `/cygdrive/c` path support in shell.common gvim()**

**2.2 Add cygpath fallback for readlink**
```bash
resolve_path() {
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -a "$1"
    elif command -v realpath >/dev/null 2>&1; then
        realpath "$1"
    else
        readlink -f "$1" 2>/dev/null || echo "$1"
    fi
}
```

**2.3 Auto-install MintTY colors in shell setup**
- Copy `.minttyrc.dark` to `~/.minttyrc` during Cygwin install
- Source `sol.dark` in shell initialization

**2.4 Create sed_inplace() wrapper**
```bash
sed_inplace() {
    if [[ "$OSTYPE" == darwin* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}
```

### Phase 3: Documentation

**3.1 Add CYGWIN.md or section in REQUIREMENTS.md**
- Cygwin package prerequisites
- Developer Mode requirement for symlinks
- Line ending expectations
- Known limitations

---

## Verification Plan

1. **Fresh Cygwin Install Test**
   ```bash
   # In Cygwin terminal (MintTY)
   git clone <repo> ~/dotfiles
   cd ~/dotfiles && make install
   ```

2. **Check symlink/copy behavior**
   ```bash
   ls -la ~/.bashrc ~/.zshrc ~/.vimrc
   ```

3. **Verify git config**
   ```bash
   git config --global --get core.ignorecase  # should be true
   git config --global --get core.filemode    # should be false
   ```

4. **Verify MintTY colors**
   - Check `~/.minttyrc` exists
   - Terminal should show Solarized colors

5. **Test gvim launch**
   ```bash
   gvim ~/.bashrc  # Should launch Windows gvim
   ```

---

## Files to Modify

| File | Changes |
|------|---------|
| `lib/common.sh` | Add `create_symlink_safe()`, `resolve_path()`, `sed_inplace()` |
| `git/setup_git.sh` | Add Cygwin-specific git config |
| `shell/setup_shell.sh` | Use `create_symlink_safe()`, install MintTY config |
| `vim/setup_vimrc.sh` | Use `create_symlink_safe()` |
| `shell/shell.common` | Add `/cygdrive/c` paths, use `resolve_path()` |
| `REQUIREMENTS.md` | Add Cygwin section |

---

## Summary

This dotfiles project has solid cross-platform foundations but needs targeted fixes for Cygwin/MintTY:

1. **Symlinks** - Add fallback to copy when ln fails
2. **Git config** - Auto-set ignorecase/filemode for Cygwin
3. **MintTY** - Auto-install color theme
4. **Paths** - Support all Cygwin path formats
5. **Documentation** - Add Cygwin setup guide

After these fixes, `make install` should work seamlessly on Windows 11 with Cygwin/MintTY.

---

*Report generated by Claude Code*
