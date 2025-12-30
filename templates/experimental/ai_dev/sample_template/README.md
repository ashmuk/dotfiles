# AI Dev Template

A production-ready template for AI-driven development combining:
- **DevContainer** (isolated, reproducible environment)
- **Claude Code / Aider** (AI-assisted coding)
- **tmuxinator** (parallel task orchestration)
- **GitHub Actions** (automated CI/CD)

## 🌟 Features

### ✅ Working Foundation (based on ai_dev_test)
- **Virtual environment isolation** - No package conflicts
- **Tested DevContainer setup** - Proven to work with Cursor/VSCode
- **Security-first** - Capability dropping, non-root user
- **Resource management** - CPU/memory limits

### 📦 Comprehensive Tooling (from sample/)
- **Health checks** - Verify environment integrity
- **Pre-commit hooks** - Code quality automation
- **VSCode tasks** - One-click common operations
- **GitHub Actions CI** - Automated testing & security scans
- **Makefile** - Consistent command interface

### 🔮 Future-Ready (sample_adv vision)
- Architecture prepared for AI task orchestration
- tmux integration for parallel workflows
- Extensible to Claude-controlled automation

## 🚀 Quick Start

### 1. Deploy Template to Your Project

```bash
# From dotfiles directory
~/dotfiles/templates/ai_dev/sample_template/setup_template.sh /path/to/your-project
```

### 2. Configure Environment

```bash
cd /path/to/your-project
vim .env  # Add your API keys
```

### 3. Open in DevContainer

```bash
# Open in Cursor or VSCode
cursor .  # or: code .

# Then: Cmd+Shift+P → "Dev Containers: Reopen in Container"
```

### 4. Verify Setup (inside container)

```bash
make health-check
```

## 📋 Template Structure

**In the template (visible in Finder/Explorer):**
```
sample_template/
├── dot.devcontainer/       # → Deployed as .devcontainer/
│   ├── Dockerfile
│   ├── compose.yml
│   ├── devcontainer.json
│   ├── health-check.sh
│   └── tmux/
│       └── tmux.conf       # Project-scoped tmux config
├── dot.github/             # → Deployed as .github/
│   └── workflows/
│       └── ci.yml
├── dot.vscode/             # → Deployed as .vscode/
│   └── tasks.json
├── app/                    # Sample FastAPI application
├── tests/                  # Sample tests
├── scripts/                # Empty scripts directory
├── dot.aider.conf.yml      # → Deployed as .aider.conf.yml
├── dot.tmuxinator.yml      # → Deployed as .tmuxinator.yml
├── dot.env.example         # → Deployed as .env
├── dot.gitignore           # → Deployed as .gitignore
├── dot.pre-commit-config.yaml # → Deployed as .pre-commit-config.yaml
├── docs/                   # Documentation directory
│   ├── ARCHITECTURE.md     # Design documentation
│   ├── CLAUDE_ORCHESTRATION_GUIDE.md  # Claude-tmux orchestration
│   ├── CLAUDE_TMUX_PROTOCOL.md        # Protocol specification
│   ├── MIGRATION_MVP_TO_MVP2.md       # Migration guide
│   ├── QUICKSTART_DEMO.md             # Quick demo
│   ├── SETUP_DEPLOYMENT_GUIDE.md      # Setup guide
│   ├── TEMPLATE_NAMING.md             # Naming conventions
│   ├── TEST_DEPLOYMENT.md             # Test deployment
│   ├── TMUX_INTEGRATION.md            # tmux documentation
│   └── USAGE.md                       # Usage guide
├── Makefile                # Deployed as-is
├── setup_template.sh       # Deployment script
└── README.md               # This file
```

**After deployment (hidden dot-files):**
```
your-project/
├── .devcontainer/          # DevContainer configuration
│   ├── Dockerfile          # arm64-optimized container image
│   ├── compose.yml         # Docker Compose (default + no-net profiles)
│   ├── devcontainer.json   # VSCode/Cursor integration
│   ├── health-check.sh     # Environment verification
│   └── tmux/
│       └── tmux.conf       # tmux config (symlinked to ~/.tmux.conf)
├── .github/
│   └── workflows/
│       └── ci.yml          # CI: lint, test, security scan
├── .vscode/
│   └── tasks.json          # Quick-access tasks (Cmd+Shift+B)
├── app/                    # Sample FastAPI application
│   ├── __init__.py
│   └── main.py             # Health check + root endpoints
├── tests/                  # Sample tests
│   ├── __init__.py
│   └── test_health.py      # API tests with TestClient
├── scripts/                # Custom scripts directory
├── .aider.conf.yml         # Aider AI configuration
├── .tmuxinator.yml         # tmux session layout (4 panes)
├── .env                    # Created from dot.env.example (git-ignored)
├── .gitignore              # Comprehensive ignore patterns
├── .pre-commit-config.yaml # Pre-commit hooks
├── Makefile                # Task automation
└── README.md               # This file
```

> **Note:** Files prefixed with `dot.` in the template are automatically converted to hidden `.` files during deployment by `setup_template.sh`.

## 🔧 Key Components

### DevContainer Configuration

**Why it works (lessons from ai_dev_test):**

```json
// .devcontainer/devcontainer.json
{
  "postCreateCommand": "python3 -m venv /home/vscode/.venv && /home/vscode/.venv/bin/pip install -U pip fastapi uvicorn pytest ruff httpx aider-chat coverage pre-commit",
  "postStartCommand": "echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bashrc"
}
```

**Critical success factors:**
1. ✅ Virtual environment (prevents package conflicts)
2. ✅ postStartCommand (auto-activates venv in shell)
3. ✅ Specific service names (easier debugging)
4. ✅ Security options (capability dropping, non-root)

### Docker Compose Profiles

```bash
# Default: Full network access (LLM APIs available)
docker compose up

# No-net: Isolated environment (offline testing)
docker compose --profile no-net up
```

### Makefile Commands

```bash
make setup           # Install dependencies
make run             # Start FastAPI server
make test            # Run pytest with coverage
make lint            # Run ruff linter
make format          # Auto-format code
make clean           # Remove build artifacts

# AI Development
make aider-plan      # Generate test plan with AI
make aider-refactor  # AI-assisted refactoring

# CI/CD
make ci-local        # Run GitHub Actions locally (act)
make health-check    # Verify environment
make pre-commit-install  # Install git hooks
make pre-commit-run      # Run all hooks
```

### VSCode Tasks (Cmd+Shift+P → "Tasks: Run Task")

- **Aider: Plan Development** - AI test plan generation
- **Aider: Auto-Refactor** - AI code refactoring
- **CI: Run Local Tests** - GitHub Actions via act
- **Test: Run All Tests** - pytest execution
- **Lint: Check Code Quality** - ruff with problem matcher
- **Format: Auto-Format Code** - ruff format
- **Health Check: Verify Environment** - Full diagnostics
- **Pre-commit: Run All Hooks** - Quality checks

### tmux Integration

**Configuration:**
- Project-scoped tmux config: `.devcontainer/tmux/tmux.conf`
- Automatically symlinked to `~/.tmux.conf` in container
- Custom keybindings: Ctrl-a prefix, vim-style navigation
- Enhanced status bar with timestamps
- Mouse support enabled

**Usage:**
```bash
# Start 4-pane development session
tmuxinator start -p .tmuxinator.yml

# Panes:
# 1. make run          - Server with hot reload
# 2. make test         - Continuous testing
# 3. make aider-refactor - AI coding assistant
# 4. gh pr status      - PR monitoring

# Custom keybindings (from tmux.conf):
# Ctrl-a |    - Split horizontally
# Ctrl-a -    - Split vertically
# Ctrl-a h/j/k/l - Navigate panes (vim-style)
# Ctrl-a H/J/K/L - Resize panes
```

## 🧪 Typical Workflow

### 1. Local Development

```bash
# In container
make run              # Terminal 1: Start server
make test             # Terminal 2: Run tests
make aider-refactor   # Terminal 3: AI assistance
```

### 2. AI-Assisted Feature Development

```bash
# Generate development plan
make aider-plan
# Review: tests/TESTPLAN.md

# Implement with AI
make aider-refactor
# Aider will:
# - Read existing code
# - Propose changes
# - Run tests
# - Auto-commit if tests pass
```

### 3. Quality Assurance

```bash
# Run all checks
make lint
make format
make test
make pre-commit-run

# Local CI simulation
make ci-local
```

### 4. Verification

```bash
# Comprehensive health check
make health-check

# Checks:
# ✓ Container environment
# ✓ Virtual environment
# ✓ Tool availability (git, python3, tmux, aider, etc.)
# ✓ Environment variables (API keys)
# ✓ Project files
# ✓ Git configuration
# ✓ Network connectivity
```

## 🔐 Security Best Practices

1. **Never commit .env** - Already in .gitignore
2. **API key rotation** - Regularly update keys
3. **Capability dropping** - Container runs with minimal privileges
4. **Non-root user** - vscode user (non-privileged)
5. **Secret detection** - Pre-commit hook checks for private keys
6. **Security scanning** - GitHub Actions runs Bandit

## 📊 Comparison with Other Templates

| Feature | sample_mini | sample | sample_adv | **sample_template** |
|---------|-------------|--------|------------|---------------------|
| DevContainer | Basic | Template | Missing | ✅ **Working** |
| Virtual env | ❌ No | ❌ No | N/A | ✅ **Yes** |
| Health check | ❌ No | ✅ Yes | ❌ No | ✅ **Yes** |
| VSCode tasks | ❌ No | ✅ Yes | ❌ No | ✅ **Yes** |
| Pre-commit | ❌ No | ✅ Yes | ❌ No | ✅ **Yes** |
| CI/CD | Basic | Full | ❌ No | ✅ **Full** |
| tmux | Basic | Basic | Advanced | ✅ **Basic** |
| AI orchestration | ❌ No | ❌ No | ✅ Vision | 🚧 **Planned** |
| Status | Reference | Template | Architecture | ✅ **Production** |

## 🛣 Roadmap to sample_adv Vision

### Phase 1: Stable Foundation ✅ (Current)
- Working DevContainer with venv
- Comprehensive tooling
- Health checks & CI/CD

### Phase 2: Enhanced Automation (Next)
- Integrate `ai_task_manager.sh` from sample_adv
- Claude-controlled tmux windows
- Marker-based task queueing
- AI-driven parallel execution

### Phase 3: Full Autonomy (Future)
- Self-organizing development sessions
- AI decides pane layout dynamically
- Continuous feedback loops
- RAG-based rule enforcement

## 🐛 Troubleshooting

### DevContainer fails to build

```bash
# Check Docker resources
docker system df

# Clean and rebuild
docker compose -f .devcontainer/compose.yml down -v
docker compose -f .devcontainer/compose.yml build --no-cache
```

### Tools not found in container

```bash
# Check virtual environment
which python3
source /home/vscode/.venv/bin/activate

# Reinstall
make setup
```

### API keys not working

```bash
# Verify environment variables
env | grep API_KEY

# Check .env file
cat .env

# Reload container
# Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

### tmuxinator not starting

```bash
# Check installation
which tmuxinator

# Verify config
tmuxinator doctor

# Test manually
tmux new-session -s test
```

## 📚 Documentation

- [DevContainer Docs](https://containers.dev/)
- [Aider Documentation](https://aider.chat/)
- [tmuxinator Guide](https://github.com/tmuxinator/tmuxinator)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Pre-commit Hooks](https://pre-commit.com/)

## 🎯 Design Principles

1. **Proven patterns first** - Based on working ai_dev_test
2. **Virtual environment isolation** - No global package conflicts
3. **Comprehensive tooling** - All developer needs covered
4. **Security by default** - Minimal privileges, secret detection
5. **Progressive enhancement** - Start simple, scale to automation
6. **Documentation-driven** - Clear README, inline comments
7. **Fail-fast verification** - Health checks catch issues early

## 🤝 Contributing

Improvements welcome! Key areas:

- Additional language support (Node.js, Go, Rust)
- More pre-commit hooks
- Enhanced tmux automation
- AI task orchestration integration
- Metrics and observability

## 📄 License

MIT License - Reuse freely for your projects.

---

**Generated by AI Dev Template v1.0**
Based on proven patterns from ai_dev_test + comprehensive features from sample/
