---
description: Command - Stage changes and commit with generated message
---

Review the current git status and staged/unstaged changes:

1. Run `git status` to see the current state
2. Run `git diff` to see unstaged changes
3. Run `git diff --cached` to see already staged changes

Then:

1. Stage the appropriate files using `git add`:
   - If specific files were mentioned: `git add <files>`
   - If no files specified: ask user what to stage, or use `git add -p` for interactive staging

2. Generate a commit message following conventional commits format:
   - Follow RULES.md (if present in this project)
    Otherwise,
   - Type: feat|fix|docs|style|refactor|test|chore
   - Scope: optional, module or component affected
   - Description: imperative mood, lowercase, no period
   - Body: optional, explain what and why

3. Show the proposed commit message and ask for confirmation

4. Execute `git commit -m "<message>"` (or with body: `git commit -m "<title>" -m "<body>"`)

## Example commit message format

```
feat(auth): add OAuth2 login support

- Implement Google OAuth2 provider
- Add session management for OAuth tokens
- Update user model with provider field
```

## Usage Examples

```bash
# Stage all and commit
> /commit

# Stage specific files
> /commit src/auth.ts src/types.ts

# With hint for commit type
> /commit fix the login bug
```
