⏺ DevContainer Build Test Results

  ✅ What Succeeded

  1. Docker build: Image built successfully (container-ai-dev-template)
  2. Container start: Launched with proper user (vscode) and working dir (/work)
  3. Python venv creation: Virtual environment created at /home/vscode/.venv
  4. Package installation: All 142 packages installed (aider-chat, fastapi, pytest, ruff, etc.)

  ❌ Critical Issues Found

  1. postCreateCommand Takes 2-5 Minutes (.devcontainer/devcontainer.json:30)

  Root cause: aider-chat alone installs 140+ dependencies including:
  - Heavy ML libraries (scipy, numpy, tokenizers)
  - Multiple API clients (openai, google-generativeai, litellm)
  - Audio processing (sounddevice, soundfile, pydub)

  Evidence from test:
  Package count: 142 packages installed
  Size impact: ~500MB+ in dependencies

  Why it's slow:
  - No visual progress indicator during pip install
  - Downloads from PyPI over network
  - Compiles some packages from source (scipy, numpy on ARM64)
  - Single monolithic command blocks until complete

  2. postStartCommand Doesn't Execute (.devcontainer/devcontainer.json:31)

  The .bashrc activation line was never added:
  # Expected:
  source /home/vscode/.venv/bin/activate

  # Actual:
  (not found in .bashrc)

  Result: Tools like aider, pytest, ruff not in PATH for interactive shells.

  3. tmux Symlink Missing

  The last step of postCreateCommand never ran:
  ln -sf /work/.devcontainer/tmux/tmux.conf /home/vscode/.tmux.conf

  This suggests the command times out or gets interrupted by VSCode/devcontainer lifecycle.

  4. Health Check Script Hangs (.devcontainer/health-check.sh:262-265)

  The script freezes during network connectivity checks:
  ping -c 1 -W 2 "8.8.8.8" >/dev/null 2>&1
  ping -c 1 -W 2 "api.anthropic.com" >/dev/null 2>&1

  Possible causes:
  - Container network restrictions
  - dev-nonet profile interference
  - Docker networking issues

  Identified Root Causes

  Cause #1: Monolithic postCreateCommand

  180-character bash one-liner with multiple operations (.devcontainer/devcontainer.json:30):
  bash -c 'python3 -m venv /home/vscode/.venv && /home/vscode/.venv/bin/pip install -U pip fastapi uvicorn pytest ruff httpx aider-chat
   coverage pre-commit && ln -sf /work/.devcontainer/tmux/tmux.conf /home/vscode/.tmux.conf'

  Issues:
  - No error handling (if pip install hangs, symlink never runs)
  - No progress visibility
  - Hard to debug failures
  - Blocks VSCode container startup for 2-5 minutes

  Cause #2: No Pip Caching Strategy

  While .cache is mounted (.devcontainer/devcontainer.json:28), rebuilding containers still downloads all packages. Need
  requirements.txt for:
  - Deterministic versions
  - Faster rebuilds with layer caching
  - Easier dependency auditing

  Cause #3: Heavy Development Dependencies

  aider-chat includes unnecessary production dependencies:
  - Audio processing (sounddevice, pydub)
  - Multiple LLM providers (when you might only use one)
  - ML libraries (scipy, numpy)

  Consider splitting into:
  - requirements-minimal.txt (fastapi, ruff, pytest only)
  - requirements-ai.txt (aider-chat and AI tools)

  Recommendations (Priority Order)

  1. URGENT: Split postCreateCommand into script

  Create .devcontainer/post-create.sh:
  #!/bin/bash
  set -e

  echo "Creating Python virtual environment..."
  python3 -m venv /home/vscode/.venv

  echo "Installing Python packages..."
  /home/vscode/.venv/bin/pip install -U pip -q
  /home/vscode/.venv/bin/pip install -r /work/requirements.txt -q

  echo "Setting up tmux configuration..."
  ln -sf /work/.devcontainer/tmux/tmux.conf /home/vscode/.tmux.conf

  echo "✓ Setup complete!"

  Update devcontainer.json:
  "postCreateCommand": "bash /work/.devcontainer/post-create.sh"

  2. Create requirements.txt

  Extract dependencies with pinned versions for reproducibility.

  3. Fix postStartCommand

  Current (.devcontainer/devcontainer.json:31):
  "postStartCommand": "echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bashrc"

  This appends on EVERY container start. Should be:
  "postStartCommand": "grep -q '/home/vscode/.venv/bin/activate' /home/vscode/.bashrc || echo 'source /home/vscode/.venv/bin/activate'
  >> /home/vscode/.bashrc"

  4. Fix health-check.sh ping commands

  Add timeout protection (.devcontainer/health-check.sh:255):
  if timeout 3 ping -c 1 -W 2 "$host" >/dev/null 2>&1; then

  5. Consider lazy-loading aider

  Only install when needed, not during container build:
  aider-install:
      /home/vscode/.venv/bin/pip install aider-chat

  Build Success Assessment

  On ARM64 (Apple Silicon): ✅ Builds and runs (tested successfully)
  On x86_64 (Intel/AMD): ❌ Will fail due to hardcoded --platform=linux/arm64

  Usability: ⚠️ Functional but slow (2-5 min startup, tools not in PATH)

