#!/usr/bin/env bash
set -euo pipefail

# ========= Functions =========
_setup_common() {
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends zsh fzf bat ripgrep jq yq tree curl ca-certificates
}

_setup_python() {
  if [ -f requirements.txt ]; then
    python3 -m venv ~/.venv
    . ~/.venv/bin/activate
    pip install --upgrade pip wheel
    pip install -r requirements.txt
  fi
}

_setup_node() {
  corepack enable || true
  npm -g i npm@latest pnpm || true
  if [ -f package.json ]; then
    npm i || pnpm i || true
  fi
}

_setup_cpp() {
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build pkg-config \
    clang clangd clang-format clang-tidy gdb lldb
}

_setup_rust() {
  if ! command -v cargo >/dev/null 2>&1; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
  rustup component add rustfmt clippy rust-src || true
  cargo install cargo-edit cargo-audit cargo-outdated || true
}

_java_detect() {
  if command -v java >/dev/null 2>&1; then
    JAVA_FULL=$(java -version 2>&1 | head -n 1 | sed 's/"//g')
    JAVA_VER=$(echo "$JAVA_FULL" | grep -Eo '[0-9]+(\.[0-9]+)*' | head -n 1)
    echo "[post-create] Java detected: $JAVA_FULL"
    echo "[post-create] Java version: $JAVA_VER"
  else
    echo "[post-create] Java not found. Skipping version check."
  fi
}

_setup_ai_clis() {
  # Claude / OpenAI / Gemini CLIs via pipx
  if command -v pipx >/dev/null 2>&1; then
    :
  else
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"
  fi
  pipx install anthropic --quiet || true
  pipx install openai --quiet || true
  pipx install google-generativeai --quiet || true

  sudo mkdir -p /usr/local/bin || true

  cat >/tmp/ai-claude <<'EOS'
#!/usr/bin/env bash
python3 - <<'PY'
import os, sys, anthropic
client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
prompt = sys.stdin.read().strip() or "Hello"
msg = client.messages.create(model=os.environ.get("CLAUDE_MODEL","claude-3-7-sonnet-20250219"),
                             max_tokens=1024,
                             messages=[{"role":"user","content":prompt}])
print(msg.content[0].text if msg.content else "")
PY
EOS
  sudo mv /tmp/ai-claude /usr/local/bin/ai-claude && sudo chmod +x /usr/local/bin/ai-claude

  cat >/tmp/ai-openai <<'EOS'
#!/usr/bin/env bash
MODEL="${1:-${OPENAI_MODEL:-gpt-4.1-mini}}"
python3 - <<'PY'
import os, sys
from openai import OpenAI
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
prompt = sys.stdin.read().strip() or "Hello"
model = os.environ.get("OPENAI_MODEL", os.environ.get("MODEL","gpt-4.1-mini"))
resp = client.chat.completions.create(model=model, messages=[{"role":"user","content":prompt}])
print(resp.choices[0].message.content)
PY
EOS
  sudo mv /tmp/ai-openai /usr/local/bin/ai-openai && sudo chmod +x /usr/local/bin/ai-openai

  cat >/tmp/ai-gemini <<'EOS'
#!/usr/bin/env bash
python3 - <<'PY'
import os, sys, google.generativeai as genai
genai.configure(api_key=os.environ.get("GOOGLE_API_KEY"))
model = genai.GenerativeModel(os.environ.get("GEMINI_MODEL","gemini-2.0-flash"))
prompt = sys.stdin.read().strip() or "Hello"
resp = model.generate_content(prompt)
print(getattr(resp,"text", resp))
PY
EOS
  sudo mv /tmp/ai-gemini /usr/local/bin/ai-gemini && sudo chmod +x /usr/local/bin/ai-gemini
}

# ========= Profile routing =========
PROFILE="${DEV_PROFILE:-fullstack}"
echo "[post-create] DEV_PROFILE=$PROFILE"

_setup_common

case "$PROFILE" in
  web)
    _setup_python
    _setup_node
    _java_detect
    _setup_ai_clis
    ;;
  native)
    _setup_cpp
    _setup_rust
    _java_detect
    _setup_ai_clis
    ;;
  ai)
    _setup_python
    _setup_ai_clis
    ;;
  microservice)
    _setup_python
    _setup_node
    _java_detect
    _setup_ai_clis
    ;;
  embedded)
    _setup_cpp
    _setup_rust
    _setup_ai_clis
    ;;
  fullstack|*)
    _setup_python
    _setup_node
    _setup_cpp
    _setup_rust
    _java_detect
    _setup_ai_clis
    ;;
esac

echo "[post-create] Completed for profile: $PROFILE"