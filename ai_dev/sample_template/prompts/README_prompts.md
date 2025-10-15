# Test Prompts for AI Dev Template

This directory contains test prompts designed to validate the AI Dev Template ecosystem. These prompts can be used by AI assistants (Claude Code, Aider, etc.) to systematically verify that all components are working correctly.

## Purpose

These prompts serve multiple purposes:

1. **Validation** - Verify template deployment was successful
2. **Documentation** - Show how to use each component
3. **Training** - Help new team members understand the workflow
4. **Regression Testing** - Ensure changes don't break existing functionality
5. **Demonstration** - Show the template's capabilities to stakeholders

## Available Prompts

### Progressive Testing Approach

The prompts are numbered and designed to be executed in order, building from basic to comprehensive:

| Prompt | Focus | Duration | Prerequisites |
|--------|-------|----------|---------------|
| **01_basic_setup.md** | Environment validation | 2-3 min | DevContainer running |
| **02_ai_workflow.md** | Aider integration | 1-5 min | Basic setup + API key (optional) |
| **03_tmux_integration.md** | tmux configuration | 3-5 min | Basic setup |
| **04_full_workflow.md** | Complete ecosystem | 15-25 min | All previous tests |

### Detailed Descriptions

#### 01_basic_setup.md
**Objective:** Verify core environment is functional

**Tests:**
- Health check execution
- Virtual environment activation
- Tool availability (aider, pytest, ruff, tmux)
- Sample application startup
- Test suite execution
- Code quality checks

**When to use:**
- First time using the template
- After container rebuild
- Quick sanity check
- Before starting work

**Success criteria:**
- All tools respond with version info
- Application starts and responds
- Tests pass with coverage
- No lint errors

---

#### 02_ai_workflow.md
**Objective:** Validate AI-assisted development setup

**Tests:**
- API key configuration
- Aider availability and configuration
- Git integration
- (Optional) Simple AI code generation task

**When to use:**
- After basic setup passes
- Before using AI features
- To verify API keys
- Testing Aider configuration

**Success criteria:**
- Aider runs without errors
- Configuration is valid
- Git integration works
- (Optional) AI task completes

**Note:** This prompt works without API keys (skips AI tasks) or with keys (tests full functionality).

---

#### 03_tmux_integration.md
**Objective:** Verify tmux configuration and tmuxinator

**Tests:**
- tmux config symlink
- Custom keybindings (Ctrl-a, vim-style)
- Mouse support
- tmuxinator session creation
- 4-pane layout
- Status bar configuration

**When to use:**
- After basic setup passes
- Before using tmux workflows
- To understand tmux customization
- Testing parallel development setup

**Success criteria:**
- Symlink points to project config
- Custom bindings work
- Sessions create successfully
- 4 panes configured correctly

---

#### 04_full_workflow.md
**Objective:** Comprehensive end-to-end ecosystem test

**Tests:**
- Complete environment setup
- Parallel tmux session with 4 panes
- Application development cycle
- AI-assisted development (with API key)
- Testing and quality gates
- Pre-commit hooks
- Local CI execution
- Cleanup and verification

**When to use:**
- Final validation before production use
- Demonstrating full capabilities
- Regression testing after changes
- Training new developers
- Benchmarking the ecosystem

**Success criteria:**
- All 8 phases complete successfully
- No orphaned processes
- All tools work in parallel
- Clean exit state

**Duration:**
- Without API key: ~15 minutes
- With API key: ~20 minutes
- With full CI: ~25 minutes

## Usage Patterns

### Pattern 1: Quick Validation
```bash
# Inside DevContainer
# Just test basic functionality
aider prompts/01_basic_setup.md
```

### Pattern 2: Pre-Work Checklist
```bash
# Run basic checks before starting development
make health-check
# Review: prompts/01_basic_setup.md
```

### Pattern 3: New Developer Onboarding
```bash
# Step-by-step introduction
# Day 1: Basic setup
aider prompts/01_basic_setup.md

# Day 1: AI tools
aider prompts/02_ai_workflow.md

# Day 2: tmux workflow
aider prompts/03_tmux_integration.md

# Day 3: Full workflow
aider prompts/04_full_workflow.md
```

### Pattern 4: Automated Testing
```bash
# Run all prompts in sequence (scripted)
for prompt in prompts/*.md; do
  echo "Testing: $prompt"
  # Execute commands from prompt
  # (requires parsing script)
done
```

### Pattern 5: Regression Testing
```bash
# After template changes
# Run full workflow to ensure nothing broke
aider prompts/04_full_workflow.md
```

## How to Use These Prompts

### With Aider
```bash
# Inside container
aider --message "Follow the instructions in prompts/01_basic_setup.md" --yes
```

### With Claude Code
1. Open the prompt file
2. Copy the instructions
3. Paste into Claude Code
4. Review and execute suggested commands

### Manual Execution
1. Open prompt file
2. Copy each command block
3. Execute in terminal
4. Verify expected output

### Automated Script (Advanced)
```bash
# Create a test runner script
cat > run_prompts.sh << 'EOF'
#!/bin/bash
for prompt in prompts/0*.md; do
  echo "=== Running: $prompt ==="
  # Parse and execute commands
  # (implementation left as exercise)
done
EOF
chmod +x run_prompts.sh
./run_prompts.sh
```

## Expected Results

### All Tests Pass ✅
If all prompts execute successfully:
- ✅ Template is fully functional
- ✅ Ready for production use
- ✅ All documentation is accurate
- ✅ Safe to customize for your project

### Partial Failures ⚠️
If some tests fail:
- Review specific prompt's troubleshooting section
- Check health-check.sh output
- Verify .env configuration
- Consult main README.md

### Complete Failure ❌
If most tests fail:
- Container may not be properly built
- Rebuild container: `Cmd+Shift+P` → "Rebuild Container"
- Check Dockerfile for errors
- Verify base image is accessible

## Customizing Prompts

You can create custom prompts for your project:

### Template for New Prompt
```markdown
# [Your Feature] Test Prompt

## Objective
[What are you testing?]

## Prerequisites
[What must be true before running?]

## Instructions for AI Assistant

### 1. [Step Name]
\```bash
# Commands here
\```

Expected: [What should happen]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Estimated Time
X minutes
```

### Example Custom Prompts
- `05_database_integration.md` - Test DB connections
- `06_api_endpoints.md` - Test all REST endpoints
- `07_performance.md` - Load testing
- `08_security.md` - Security scan

## Integration with CI/CD

These prompts can be adapted for automated CI/CD:

```yaml
# .github/workflows/validate-template.yml
name: Validate Template
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run basic setup validation
        run: |
          # Parse and execute 01_basic_setup.md commands
```

## Troubleshooting

### Prompt execution hangs
**Cause:** Waiting for interactive input
**Fix:** Use `--yes` flag with aider or provide inputs

### Commands not found
**Cause:** Not in container or venv not activated
**Fix:**
```bash
# Activate venv
source /home/vscode/.venv/bin/activate

# Or rebuild container
```

### API key errors
**Cause:** Keys not configured
**Fix:**
```bash
# Edit .env
vim .env
# Add: ANTHROPIC_API_KEY=your_key

# Reload container
```

### tmux errors
**Cause:** Symlink not created
**Fix:**
```bash
ln -sf /work/.devcontainer/tmux/tmux.conf ~/.tmux.conf
```

## Maintenance

### Updating Prompts

When you modify the template:

1. Update relevant prompts
2. Test all prompts in sequence
3. Update expected outputs
4. Commit prompt changes with template changes

### Version History

Track major prompt updates:

- **v1.0** (2025-10-15) - Initial prompt suite
  - 4 progressive validation prompts
  - Covers basic to comprehensive testing
  - ~1,400 lines of test instructions

## Related Documentation

- [README.md](../README.md) - Template overview
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Design decisions
- [USAGE.md](../USAGE.md) - Detailed usage guide
- [TMUX_INTEGRATION.md](../TMUX_INTEGRATION.md) - tmux documentation

## Contributing

To add new test prompts:

1. Follow the numbering scheme (`0X_name.md`)
2. Include clear success criteria
3. Provide troubleshooting section
4. Test prompt execution
5. Update this README

## Summary

These test prompts provide a systematic way to validate the AI Dev Template:

- **Progressive complexity** - Start simple, build to comprehensive
- **Self-documenting** - Each prompt teaches while testing
- **Flexible execution** - Manual, AI-assisted, or automated
- **Clear criteria** - Know when tests pass or fail
- **Comprehensive coverage** - Tests all major components

Use them to ensure your development environment is ready for productive AI-assisted development! 🚀
