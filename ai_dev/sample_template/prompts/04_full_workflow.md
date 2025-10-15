# Full Ecosystem Workflow Test Prompt

## Objective
Comprehensive end-to-end test of the entire AI Dev Template ecosystem, simulating a real development workflow.

## Prerequisites
- All previous tests passed (01, 02, 03)
- API key configured (optional but recommended)
- Inside DevContainer

## Instructions for AI Assistant

This prompt simulates a complete development cycle: setup → develop → test → CI → commit.

### Phase 1: Environment Setup (2 min)

```bash
# 1. Full health check
echo "=== Phase 1: Health Check ==="
make health-check

# 2. Clean slate
make clean

# 3. Verify all tools
echo "Python: $(python --version)"
echo "Aider: $(aider --version 2>&1 | head -1)"
echo "tmux: $(tmux -V)"
echo "pytest: $(pytest --version | head -1)"
echo "ruff: $(ruff --version)"
```

### Phase 2: Parallel Development with tmux (3 min)

```bash
# Start tmuxinator session in background
echo "=== Phase 2: Starting tmux Session ==="
tmuxinator start -p .tmuxinator.yml &
sleep 5

# Check session status
tmux list-sessions
tmux list-windows -t ai-dev
tmux list-panes -t ai-dev:dev -a

# Send commands to specific panes
echo "=== Sending commands to panes ==="

# Pane 0: Run server
tmux send-keys -t ai-dev:dev.0 'echo "Server pane ready"' C-m

# Pane 1: Run tests
tmux send-keys -t ai-dev:dev.1 'echo "Test pane ready"' C-m

# Pane 2: Aider pane
tmux send-keys -t ai-dev:dev.2 'echo "AI pane ready"' C-m

# Pane 3: Monitor pane
tmux send-keys -t ai-dev:dev.3 'echo "Monitor pane ready"' C-m

sleep 2

# Capture output from each pane
echo "=== Pane outputs ==="
for i in 0 1 2 3; do
  echo "--- Pane $i ---"
  tmux capture-pane -t ai-dev:dev.$i -p | tail -5
done
```

### Phase 3: Application Development (3 min)

```bash
echo "=== Phase 3: Application Test ==="

# Start application in pane 0
tmux send-keys -t ai-dev:dev.0 'make run &' C-m
sleep 3

# Test health endpoint
curl http://localhost:8000/health || echo "Server starting..."
sleep 2
curl http://localhost:8000/health

# Test root endpoint
curl http://localhost:8000/

# Stop server
pkill -f uvicorn
```

### Phase 4: AI-Assisted Development (3 min, requires API key)

```bash
echo "=== Phase 4: AI Development ==="

# Check if API key is configured
if [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$OPENAI_API_KEY" ]; then
  echo "API key found - testing AI features"

  # Generate test plan (in pane 2)
  tmux send-keys -t ai-dev:dev.2 'make aider-plan' C-m

  echo "Waiting for aider to complete..."
  sleep 10

  # Check if test plan was created
  if [ -f "tests/TESTPLAN.md" ]; then
    echo "✓ Test plan created"
    cat tests/TESTPLAN.md
  else
    echo "⚠ Test plan not created (may need more time)"
  fi
else
  echo "⚠ No API key - skipping AI tasks"
fi
```

### Phase 5: Testing & Quality (2 min)

```bash
echo "=== Phase 5: Quality Checks ==="

# Run tests in pane 1
tmux send-keys -t ai-dev:dev.1 'make test' C-m
sleep 5

# Capture test output
echo "=== Test Results ==="
tmux capture-pane -t ai-dev:dev.1 -p | tail -20

# Run linting
echo "=== Lint Results ==="
make lint

# Run formatting check
echo "=== Format Check ==="
make format
```

### Phase 6: Pre-commit Hooks (2 min)

```bash
echo "=== Phase 6: Pre-commit Hooks ==="

# Install hooks
make pre-commit-install

# Run all hooks
make pre-commit-run || echo "Some hooks may fail on first run"
```

### Phase 7: Local CI (3 min, optional)

```bash
echo "=== Phase 7: Local CI ==="

# Check if act is available
if command -v act &> /dev/null; then
  echo "Running local CI with act..."
  make ci-local || echo "CI may fail without Docker socket"
else
  echo "⚠ act not available - skipping local CI"
fi
```

### Phase 8: Cleanup & Summary (1 min)

```bash
echo "=== Phase 8: Cleanup ==="

# Stop all processes
pkill -f uvicorn 2>/dev/null || true
pkill -f pytest 2>/dev/null || true

# Kill tmux session
tmux kill-session -t ai-dev 2>/dev/null || true

# Clean build artifacts
make clean

# Final status
echo "=== Final Status ==="
git status
```

## Success Criteria

### Must Pass ✅
- ✅ Health check passes
- ✅ tmux session starts with 4 panes
- ✅ Application starts and responds
- ✅ Tests execute successfully
- ✅ Linting completes
- ✅ Pre-commit hooks install

### Optional (with API key) ⭐
- ⭐ Aider generates test plan
- ⭐ AI-assisted refactoring works
- ⭐ Local CI runs successfully

## Expected Output Summary

```
Phase 1: ✅ Environment verified
Phase 2: ✅ tmux session with 4 panes active
Phase 3: ✅ Application responds on port 8000
Phase 4: ⭐ AI features (requires API key)
Phase 5: ✅ Tests pass, lint succeeds
Phase 6: ✅ Pre-commit hooks installed
Phase 7: ⭐ Local CI (requires act)
Phase 8: ✅ Clean exit
```

## Troubleshooting

### tmux session won't start
```bash
# Check if tmuxinator is installed
which tmuxinator

# Check config syntax
tmuxinator debug ai-dev
```

### Server won't start
```bash
# Check if port is in use
lsof -i :8000

# Kill existing process
pkill -f uvicorn
```

### Tests fail
```bash
# Check dependencies
pip list | grep -E "(pytest|fastapi|httpx)"

# Reinstall if needed
make setup
```

### API key not working
```bash
# Verify key is set
env | grep API_KEY

# Check .env file
cat .env | grep API_KEY
```

## Estimated Time

- **Without API key:** ~15 minutes
- **With API key:** ~20 minutes
- **With full CI:** ~25 minutes

## Validation Checklist

After running this prompt, verify:

- [ ] Health check: All tools installed
- [ ] tmux: 4-pane session created
- [ ] Application: Responds on /health and /
- [ ] Tests: All pass with coverage
- [ ] Linting: No errors
- [ ] Pre-commit: Hooks installed
- [ ] (Optional) AI: Test plan generated
- [ ] (Optional) CI: Local run successful
- [ ] Cleanup: No orphaned processes

## Next Steps

If this comprehensive test passes:

1. ✅ **Template is fully functional**
2. 🚀 **Ready for real project development**
3. 📚 **Review documentation for advanced features**
4. 🔧 **Customize for your project needs**

If any phase fails:

1. Review specific phase documentation
2. Check health-check.sh output
3. Verify .env configuration
4. Consult TROUBLESHOOTING section in README.md

## Notes

This prompt tests the entire ecosystem in a realistic scenario:
- Parallel development with tmux
- AI-assisted coding with Aider
- Continuous testing
- Quality gates with pre-commit
- Local CI/CD simulation

It should complete successfully on a properly configured DevContainer with minimal prerequisites.
