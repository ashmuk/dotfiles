---

description: Command - Push changes to remote with safety checks

---

Before pushing, perform these safety checks:

1. Run `git status` to ensure working directory is clean
   - If there are uncommitted changes, ask user if they want to commit first

2. Run `git log origin/$(git branch --show-current)..HEAD --oneline` to show unpushed commits
   - If no commits to push, inform user and stop

3. Run `git branch --show-current` to confirm current branch
   - Warn if pushing to main/master directly

4. Optional pre-push checks (if configured):
   - Run `npm test` or equivalent test command
   - Run `npm run lint` or equivalent lint command
   - Run `npm run typecheck` or equivalent type check

5. If all checks pass, execute:
   - First push: `git push -u origin $(git branch --show-current)`
   - Subsequent: `git push`

6. Report push result and show remote URL for reference

## Safety warnings

- Warn before force push (`--force` or `-f`)
- Warn before pushing to protected branches (main, master, production)
- Show commit count and summary before pushing

## Usage Examples

```bash
# Standard push
> /push

# Push with force (use carefully)
> /push --force

# Push to specific remote
> /push origin

# Push and set upstream
> /push -u origin feature/new-login
```
