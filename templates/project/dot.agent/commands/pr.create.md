---

description: Command - Create a pull request with generated title and description

---

## Prerequisites Check

1. Verify GitHub CLI is installed: `gh --version`
   - If not installed, inform user: `brew install gh` or see https://cli.github.com/
2. Verify authentication: `gh auth status`
   - If not authenticated, run: `gh auth login`

## Gather Information

1. Get current branch: `git branch --show-current`
   - If on main/master, stop and ask user to checkout a develop or feature branch

2. Get default branch: `gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'`
   - This will be the target (base) branch for the PR
   - Typically main or master (production branch)
   - Main use case for this slash command is creating a PR from develop to main/master

3. Ensure all commits are pushed: `git log origin/$(git branch --show-current)..HEAD --oneline`
   - If unpushed commits exist, ask user if they want to push first

4. Get commit history for this branch:
   ```
   git log origin/<default-branch>..HEAD --pretty=format:"%s%n%b"
   ```

5. Get diff summary:
   ```
   git diff origin/<default-branch>..HEAD --stat
   ```

## Generate PR Content

Based on the commits and diff, generate content:
- Use .github/PULL_REQUEST_TEMPLATE.md (if present)

Otherwise, follow this below

### Title
- Follow format: `<type>: <description>` or match branch name pattern
- Keep under 72 characters
- Use imperative mood

### Description
Use this template:

```markdown
## Summary
<Brief description of what this PR does>

## Changes
<Bullet list of main changes>

## Testing
<How the changes were tested>

## Related Issues
<Link to related issues: Fixes #123, Relates to #456>
```

## Create PR

1. Show generated title and description to user
2. Ask for confirmation or edits
3. Execute:
   ```bash
   gh pr create --title "<title>" --body "<description>" --base <default-branch>
   ```

4. Additional options if requested:
   - `--draft` for draft PR
   - `--reviewer <users>` to request reviewers
   - `--assignee @me` to self-assign
   - `--label <labels>` to add labels

5. Show PR URL after creation

## Usage Examples

```bash
# Create PR with auto-generated content
> /pr.create

# Create as draft
> /pr.create --draft

# Create with reviewers
> /pr.create --reviewer @teammate1,@teammate2

# Create with labels
> /pr.create --label bug,urgent

# Specify base branch
> /pr.create --base develop
```
