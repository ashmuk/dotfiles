---

description: Command - Merge branches with safety checks and conflict detection

---

## Pre-merge Checks

1. Run `git status` to ensure working directory is clean
   - If uncommitted changes exist, stop and ask user to commit or stash first

2. Get current branch: `git branch --show-current`

3. Determine source branch:
   - If user specified a branch: use that
   - If no branch specified: ask user which branch to merge

4. Verify source branch exists:
   `git rev-parse --verify <source-branch>`

5. Fetch latest from remote (if tracking exists):
   `git fetch origin <source-branch> --dry-run`
   - Inform user if remote has newer commits

## Safety Checks

1. **Protected branch warning:** If current branch is `main` or `master`:
   - Show prominent warning: "You are merging into a protected branch (main/master)"
   - Require explicit confirmation before proceeding
   - Suggest using PR workflow instead if merging from a feature branch

2. Show merge preview:
   - Commits to be merged: `git log HEAD..<source-branch> --oneline`
   - Diff summary: `git diff HEAD...<source-branch> --stat`
   - Commit count

3. Check for potential conflicts (working tree must be clean from step 1):
   `git merge --no-commit --no-ff <source-branch>` then `git merge --abort`
   - If conflicts detected, show conflicting files and ask how to proceed

## Execute Merge

1. Show merge summary and ask for confirmation

2. Execute merge based on strategy:
   - Default: `git merge --no-ff <source-branch>`
   - With `--squash`: `git merge --squash <source-branch>` (then prompt for commit message)
   - With `--ff-only`: `git merge --ff-only <source-branch>`

3. If merge succeeds:
   - Show result: `git log --oneline -1`
   - Show updated branch status

4. If merge fails (conflicts):
   - List conflicting files: `git diff --name-only --diff-filter=U`
   - Advise user to resolve conflicts manually
   - Do NOT auto-abort — let user decide

## Usage Examples

```bash
# Merge develop into current branch
> /cc-merge develop

# Merge with squash
> /cc-merge feature/auth --squash

# Fast-forward only
> /cc-merge develop --ff-only

# On main branch — will trigger safety warning
> /cc-merge develop
```
