# AI-Assisted Workflow Test Prompt

## Objective
Test Aider integration and AI-assisted development workflow in the template.

## Prerequisites
- Basic setup validation completed (`01_basic_setup.md`)
- Environment variables set in `.env` (ANTHROPIC_API_KEY or OPENAI_API_KEY)

## Instructions for AI Assistant

### 1. Verify API Keys
```bash
# Check if API keys are configured
env | grep -E "(ANTHROPIC|OPENAI)_API_KEY" | sed 's/=.*/=***/'
```

Expected: At least one API key should be set.

If not set:
```bash
# Edit .env file
vim .env
# Add: ANTHROPIC_API_KEY=your_key_here
```

### 2. Test Aider Configuration
```bash
# Check Aider config
cat .aider.conf.yml
```

Expected: Should show model configuration (claude-sonnet-4-5-20250514)

### 3. Generate Test Plan (Dry Run)
```bash
# Test aider with --help to verify it works
aider --help | head -20
```

Expected: Aider help text should display without errors.

### 4. Simple AI Task (Optional - requires API key)
If API key is configured, test a simple task:

```bash
# Create a simple task file
cat > /tmp/test_task.md << 'EOF'
Task: Add a simple utility function to calculate the square of a number.
File: app/utils.py (create if doesn't exist)
Function: square(n: int) -> int
EOF

# Run aider in --yes mode with a simple task
aider --message "Create app/utils.py with a function 'square(n: int) -> int' that returns n*n. Add a docstring." --yes app/utils.py || echo "Aider requires API key - skipping"
```

Expected:
- If API key present: Function should be created
- If no API key: Error message is expected and acceptable

### 5. Test Aider Features (No API Call)
```bash
# Test aider's local features
aider --list-models | head -10 || echo "API key required for model listing"
```

### 6. Verify Git Integration
```bash
# Check git status
git status

# Aider should respect .gitignore
cat .gitignore | grep -E "(\.env|\.cache|__pycache__|\.venv)"
```

Expected: .env and cache directories are ignored.

## Success Criteria

✅ Aider is installed and accessible
✅ Configuration file is present and valid
✅ Git integration works
✅ (Optional) Simple AI task completes if API key present

## Notes

- This test can be run without an API key (will skip AI tasks)
- With API key: tests actual AI code generation
- Without API key: validates environment setup only

## Estimated Time
- Without API key: 1 minute
- With API key: 3-5 minutes

## Next Steps
If successful, proceed to `03_tmux_integration.md` for tmux testing.
