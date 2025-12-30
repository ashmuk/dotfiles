
# DevContainer Patches (AI CLIs + Polyglot stacks)

- `devcontainer.patched.json`: adds Node feature (LTS) and VS Code extensions for C/C++ & Rust, ESLint/Prettier. Keeps existing `postCreateCommand` and chains `post-create.sh` if missing.
- `post-create.patched.sh`: adds DEV_PROFILE switching and installers for C/C++, Rust, Node, Python, **AI CLIs** (Claude / OpenAI / Gemini) via `pipx`. Also creates wrappers: `ai-claude`, `ai-openai`, `ai-gemini`.
- `rust-toolchain.toml`, `.pre-commit-config.yaml`, `Makefile`: baseline for fmt/lint/test and AI smoke checks.

> Env vars to set (in devcontainer or GitHub Actions secrets):
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GOOGLE_API_KEY`
- Optional model selectors: `CLAUDE_MODEL`, `OPENAI_MODEL`, `GEMINI_MODEL`
