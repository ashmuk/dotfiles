# Review Findings: `.template-sync-ignore` Implementation

**Date:** 2026-03-07
**Reviewer:** my-reviewer agent
**Scope:** `.template-sync-ignore` mechanism in `scripts/boilerplate/fetch-from-upstream.sh`

## Findings

| # | File:Line | Issue | Severity |
|---|-----------|-------|----------|
| 1 | `scripts/boilerplate/fetch-from-upstream.sh:123` | Empty array expansion crashes bash 3.2 under `set -u` (`"${SYNC_IGNORE_PATHS[@]}"` and `"${DIR_EXCLUDE_FLAGS[@]}"`) | MUST-FIX |
| 2 | `scripts/boilerplate/fetch-from-upstream.sh:532` | No check for `rsync` availability; script fails mid-operation if rsync is missing | MUST-FIX |
| 3 | `scripts/boilerplate/fetch-from-upstream.sh:137` | `diff -x` and `rsync --exclude` match by filename at all directory levels, not anchored to top level | SHOULD-FIX |
| 4 | `scripts/boilerplate/fetch-from-upstream.sh:131` | `DIR_EXCLUDE_FLAGS` global mutable array clobbered by `preview_directory_changes` | SHOULD-FIX |
| 5 | `scripts/boilerplate/fetch-from-upstream.sh:869` | `sync_claude_config_file()` not protected by `is_sync_ignored` | SHOULD-FIX |
| 6 | `scripts/boilerplate/fetch-from-upstream.sh:625` | Stale `DIR_EXCLUDE_FLAGS` possible if `preview_directory_changes` called without `dir_prefix` | SUGGESTION |
| 7 | `scripts/boilerplate/fetch-from-upstream.sh:456-549` | ~80% code duplication across three directory sync functions | SUGGESTION |
| 8 | `scripts/boilerplate/fetch-from-upstream.sh:112` | Whitespace-only line detection misses tabs (`${line// }` only removes spaces) | SUGGESTION |

## Recommendations

### MUST-FIX 1: Bash 3.2 empty array
Guard all array iterations with `[[ ${#arr[@]} -eq 0 ]]` checks, or use `${arr[@]+"${arr[@]}"}` safe expansion idiom.

### MUST-FIX 2: rsync availability
Add `command -v rsync` check before invocation. Fall back to `rm -rf` + `cp -R` with a warning that ignored files will NOT be preserved.

### SHOULD-FIX 3: Filename vs path matching
Use `rsync --exclude "/filename"` (leading `/` anchors to transfer root). For `diff -x`, accept the limitation and document it, or switch to `rsync --dry-run` for comparison.

### SHOULD-FIX 4: Global mutable array
Callers should snapshot `DIR_EXCLUDE_FLAGS` into local arrays before calling functions that may clobber it.

### SHOULD-FIX 5: sync_claude_config_file protection
Add `is_sync_ignored` check at top of `sync_claude_config_file()`.

## Status

**Verdict:** All MUST-FIX and SHOULD-FIX findings RESOLVED. See REMEDIATION_TEMPLATE_SYNC_IGNORE_20260307.md for details.
