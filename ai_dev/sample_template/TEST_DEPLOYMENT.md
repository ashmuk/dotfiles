# Test Deployment Instructions

## Quick Deploy to Your Sandbox Project

### 1. Create/Choose Your Test Project

```bash
# Option A: Create a new sandbox project
mkdir -p ~/sandbox/claude-tmux-test
cd ~/sandbox/claude-tmux-test
git init

# Option B: Use existing project
cd /path/to/your-existing-project
```

### 2. Deploy the Template

```bash
# From anywhere, run:
~/dotfiles/ai_dev/sample_template/setup_template.sh ~/sandbox/claude-tmux-test

# Or if you're already in target directory:
~/dotfiles/ai_dev/sample_template/setup_template.sh .
```

**What this does:**
- ✅ Copies all template files to your target
- ✅ Converts `dot.*` files to hidden `.` files
- ✅ Creates `.env` from example
- ✅ Backs up any existing files (`.backup`)
- ✅ Copies Claude-tmux scripts and docs
- ✅ Sets proper permissions

### 3. Test Claude-tmux Orchestration (No DevContainer Needed!)

```bash
cd ~/sandbox/claude-tmux-test

# Quick test (10 seconds)
make claude-demo

# Full POC demo (30 seconds)
./scripts/claude-orchestrator-poc.sh

# Manual test
./scripts/claude-tmux-bridge.sh session-create my-test
./scripts/claude-tmux-bridge.sh pane-create my-test server
./scripts/claude-tmux-bridge.sh pane-exec my-test 0 "echo 'Hello from Claude!'"
sleep 1
./scripts/claude-tmux-bridge.sh pane-capture my-test 0 10
./scripts/claude-tmux-bridge.sh session-kill my-test
```

### 4. View Live tmux Session

While a demo is running, open a new terminal:

```bash
# List active sessions
tmux ls

# Attach to demo
tmux attach -t demo-session
# or
tmux attach -t claude-poc

# Navigate panes inside tmux:
# Ctrl+a h/j/k/l  - Move between panes
# Ctrl+a d        - Detach (leave running)
```

### 5. Cleanup Test

```bash
# Kill any running sessions
tmux ls | cut -d: -f1 | xargs -I {} tmux kill-session -t {}

# Remove test deployment (if needed)
cd ~/sandbox/claude-tmux-test
rm -rf .devcontainer .github .vscode scripts/
rm -f .aider* .ai_dev* .gitignore .pre-commit* .env Makefile
rm -rf app tests prompts
rm -f CLAUDE_* QUICKSTART_DEMO.md
```

---

## Deployment to Existing Project

If you want to add Claude-tmux to an existing project:

```bash
# Deploy to your project
~/dotfiles/ai_dev/sample_template/setup_template.sh /path/to/your-project

# Review what was backed up
ls -la /path/to/your-project/*.backup

# Test the integration
cd /path/to/your-project
make claude-demo
```

**The script will:**
- ✅ Backup existing files before overwriting
- ✅ Skip copying `app/`, `tests/`, `prompts/` if they exist
- ✅ Preserve your existing `.env` file
- ✅ Only add new capabilities without disrupting existing code

---

## What Gets Deployed

```
your-project/
├── .devcontainer/           # DevContainer config (full stack)
├── .github/workflows/       # CI/CD workflows
├── .vscode/                 # VSCode tasks
├── scripts/                 # ⭐ NEW: Claude-tmux scripts
│   ├── claude-tmux-bridge.sh
│   └── claude-orchestrator-poc.sh
├── .aider.conf.yml          # Aider configuration
├── .ai_dev.yml              # tmuxinator layout
├── .gitignore               # Comprehensive ignores
├── .pre-commit-config.yaml  # Pre-commit hooks
├── .env                     # Environment variables (from example)
├── Makefile                 # ⭐ UPDATED: Added claude-* commands
├── requirements.txt         # Python dependencies
├── CLAUDE_TMUX_PROTOCOL.md          # ⭐ NEW: Protocol spec
├── CLAUDE_ORCHESTRATION_GUIDE.md    # ⭐ NEW: Usage guide
├── QUICKSTART_DEMO.md               # ⭐ NEW: Demo instructions
├── app/                     # Sample FastAPI app (if not exists)
├── tests/                   # Sample tests (if not exists)
└── prompts/                 # AI prompts (if not exists)
```

---

## Testing Without DevContainer

Good news! **Claude-tmux works outside DevContainer too!**

Just need:
```bash
# Install tmux if not already
brew install tmux  # macOS
# or
apt-get install tmux  # Linux

# Install jq (for JSON parsing)
brew install jq  # macOS
# or
apt-get install jq  # Linux
```

Then run demos immediately:
```bash
cd your-project
make claude-demo
```

---

## Full DevContainer Test (Optional)

If you want to test the complete DevContainer environment:

```bash
cd ~/sandbox/claude-tmux-test

# Edit .env and add API keys
vim .env

# Open in Cursor/VSCode
cursor .  # or: code .

# Reopen in Container
# Cmd+Shift+P → "Dev Containers: Reopen in Container"

# Inside container:
make health-check
make claude-demo
./scripts/claude-orchestrator-poc.sh
```

---

## Troubleshooting

### "setup_template.sh: command not found"
```bash
# Make it executable
chmod +x ~/dotfiles/ai_dev/sample_template/setup_template.sh
```

### "Permission denied" when running scripts
```bash
# Fix permissions
chmod +x scripts/*.sh
```

### Want to start fresh?
```bash
# Remove .backup files after verifying deployment
rm -f *.backup
rm -rf .devcontainer.backup .github.backup
```

---

## Next Steps After Deployment

1. **Read the docs:**
   - `QUICKSTART_DEMO.md` - Quick demos
   - `CLAUDE_ORCHESTRATION_GUIDE.md` - Usage patterns
   - `CLAUDE_TMUX_PROTOCOL.md` - API reference

2. **Try the demos:**
   - `make claude-demo` - Simplest
   - `./scripts/claude-orchestrator-poc.sh` - Full workflow

3. **Integrate into workflow:**
   - Use Claude Code to orchestrate development
   - Let Claude create/monitor tmux panes dynamically
   - Build custom orchestration scripts

4. **Customize:**
   - Modify `Makefile` with your own commands
   - Create new orchestration scripts in `scripts/`
   - Adjust tmux layouts in `.ai_dev.yml`

---

**Happy testing! 🚀**
