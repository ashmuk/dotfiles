# Basic Setup Test Prompt

## Objective
Verify that the AI Dev Template environment is correctly set up and all basic tools are functional.

## Instructions for AI Assistant

Please perform the following validation steps in order:

### 1. Environment Verification
```bash
# Check we're in the container
make health-check
```

Expected output: All checks should pass (✓ PASS) except for optional items.

### 2. Python Environment Check
```bash
# Verify venv is active
echo $VIRTUAL_ENV
which python
python --version
```

Expected: Should show `/home/vscode/.venv` and Python 3.11+

### 3. Tool Availability
```bash
# Check installed tools
aider --version
pytest --version
ruff --version
tmux -V
tmuxinator version
```

Expected: All commands should return version information without errors.

### 4. Run Sample Application
```bash
# Start the FastAPI server (background)
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
sleep 2

# Test health endpoint
curl http://localhost:8000/health

# Stop the server
pkill -f uvicorn
```

Expected: Should return `{"status":"healthy","service":"ai-dev-sample"}`

### 5. Run Tests
```bash
# Execute test suite
make test
```

Expected: All tests should pass with coverage report.

### 6. Lint Check
```bash
# Check code quality
make lint
```

Expected: No errors (warnings are acceptable).

## Success Criteria

✅ All commands execute without errors
✅ Health check passes
✅ Tests pass with coverage
✅ Application starts and responds correctly
✅ Lint checks pass

## Estimated Time
2-3 minutes

## Next Steps
If all checks pass, proceed to `02_ai_workflow.md` for AI-assisted development testing.
