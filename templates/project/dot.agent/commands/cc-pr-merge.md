---

description: Command - Sync local branches after PR merges on GitHub

---

## Prerequisites

1. Verify GitHub CLI: `gh --version`
   - If not installed, inform user: `brew install gh`
2. Verify authentication: `gh auth status`
3. Run `git status` to ensure working directory is clean
   - If uncommitted changes exist, stop and ask user to commit or stash first

## Detect Merged PRs

1. Fetch latest from remote: `git fetch --prune`

2. Get recently merged PRs:
   `gh pr list --state merged --limit 10 --json number,title,headRefName,baseRefName,mergedAt --jq 'sort_by(.mergedAt) | reverse'`

3. Show merged PRs summary:
   - PR number, title, source branch -> target branch, merged date
   - Highlight PRs whose local branches still exist

4. If user specified a PR number: focus on that PR
   If no argument: show the list and let user choose, or sync all

## Sync Local Branches

1. Identify target branches that received merges (typically `main` or `develop`)

2. For each target branch that has new merged PRs:
   - If currently on that branch: `git pull`
   - If on a different branch: `git fetch origin <branch>:<branch>` (fast-forward update)
   - If fast-forward fails: inform user and suggest checking out the branch manually

3. Show sync result:
   - Commits pulled: `git log --oneline <old-HEAD>..<new-HEAD>`
   - Current branch status

## Branch Cleanup

1. Detect local branches whose PRs are merged:
   `gh pr list --state merged --json headRefName --jq '.[].headRefName'`
   Cross-reference with local branches: `git branch --list`

2. For each merged branch found locally:
   - Show: branch name, associated PR number/title
   - Ask user to confirm deletion (batch or individual)

3. Delete confirmed branches: `git branch -d <branch>`
   - Use `-d` (safe delete), not `-D`
   - If delete fails (unmerged warning), inform user and skip

## Usage Examples

```bash
# Sync local after PR merges and clean up branches
> /cc-pr-merge

# Sync a specific PR
> /cc-pr-merge #42

# Skip cleanup, just sync
> /cc-pr-merge --no-cleanup
```
