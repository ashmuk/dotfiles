
# README_devcontainer_modules.md

> **Scope**: This template organizes a polyglot **Cursor DevContainer** around Python/Java *plus* JavaScript/TypeScript, C/C++, and Rust.  
> It fits your workflow: **`devcontainer.json`** as the source of truth, and language packages installed by **`post-create.sh`** (driven by `requirements.txt`, `package.json`, `Cargo.toml`, etc.).

---

## 1) How to organize: one container vs. purpose‑specific containers

### Option A — **One polyglot container** (recommended for your AI/automation workflow)
- **Pros**: Single place to maintain, all agents/tools work in the same shell, zero context switching, easiest for Cursor/Claude/Aider to orchestrate end‑to‑end tasks.
- **Cons**: Image is bigger; upgrades touch more moving parts.

**When to choose**: If your projects frequently span Python ⇄ Java ⇄ JS ⇄ Rust ⇄ C/C++ in a single repo or a monorepo, and you rely on AI agents to automate across stacks.

### Option B — **Purpose‑specific envs** (per‑service or per‑repo)
- **Pros**: Smaller images, faster cold start, fewer toolchain conflicts. Easy to pin toolchains (e.g., `rust-toolchain.toml`, `sdkman`, `asdf`) per project.
- **Cons**: More maintenance; devs/agents must juggle multiple containers.

**When to choose**: If your services are strongly isolated (e.g., Rust microservice here, Spring Boot there) and rarely cross‑call during dev.

> **My view**: Keep your current **polyglot base** as default, and introduce **lean profiles** (JS‑only, Rust‑only) for edge cases. See §6 “Profiles/variants”.

---

## 2) Modules to add for JavaScript/TypeScript, C/C++, Rust

Below are **toolchains**, **LSPs**, **formatters/linters**, **debuggers**, and **test tools** that “just work” in Cursor and CI.

### 2.1 JavaScript / TypeScript
- **Toolchain/PM**: Node.js LTS, `corepack enable` (enables `yarn`/`pnpm`), or explicitly install `pnpm`.
- **LSP**: TypeScript built‑in (ships with VS Code); add ESLint plugin.
- **Format/Lint**: `prettier`, `eslint` (+ `@typescript-eslint/parser` & plugin).
- **Testing**: `vitest` or `jest`; E2E: `playwright` (headless; CI‑friendly).
- **API/Docs**: `openapi-typescript`, `redocly` (optional).

```bash
# post-create.sh (extract)
# --- JS/TS ---
npm -g i npm@latest
corepack enable || true          # enables Yarn/Pnpm shims
npm -g i pnpm                    # if you prefer explicit pnpm
# project-local (if package.json present)
if [ -f package.json ]; then
  npm i --save-dev typescript ts-node     eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin     prettier eslint-config-prettier eslint-plugin-prettier     vitest @vitest/coverage-v8
fi
```

> Add an `.eslintrc.cjs` and `.prettierrc` in the repo root; wire `format`/`lint` scripts in `package.json`.

### 2.2 C/C++
- **Toolchain**: `build-essential` (gcc/g++/make), `cmake`, `ninja-build` (fast), `pkg-config`.
- **LSP**: `clangd` (recommended) or `ccls`.
- **Debug**: `gdb` or `lldb`; recommend VS Code `C/C++` & `CodeLLDB` extensions.
- **Format**: `clang-format`; **Lint**: `clang-tidy`.

```bash
# post-create.sh (extract)
# --- C/C++ ---
sudo apt-get update
sudo apt-get install -y --no-install-recommends   build-essential cmake ninja-build pkg-config   clang clangd clang-format clang-tidy gdb lldb
```

### 2.3 Rust
- **Toolchain manager**: `rustup` (installs `rustc`, `cargo`).
- **Components**: `rustfmt`, `clippy`, `rust-src`.
- **LSP**: `rust-analyzer`.
- **Debug**: `lldb` + `CodeLLDB` extension.
- **Project pinning**: `rust-toolchain.toml` (channel & components).

```bash
# post-create.sh (extract)
# --- Rust ---
curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"
rustup component add rustfmt clippy rust-src
cargo install cargo-edit cargo-audit cargo-outdated
```

Example `rust-toolchain.toml` to pin versions:
```toml
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy", "rust-src"]
profile = "minimal"
```

---

## 3) devcontainer.json — minimal additions

*Keep your current base; add language features + VS Code extensions.*

```jsonc
// devcontainer.json (additions)
{
  "features": {
    // Keep your Python/Java; add:
    "ghcr.io/devcontainers/features/node:1": { "version": "lts" }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        // C/C++ & Rust
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools",
        "vadimcn.vscode-lldb",
        "rust-lang.rust-analyzer",
        // JS/TS
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ]
    }
  }
}
```

> For C/C++ toolchain packages we use `post-create.sh` (APT). If you prefer a fully reproducible image, move those into the `Dockerfile` layer to cache compilers.

---

## 4) `post-create.sh` — orchestrating language installers

A robust pattern that fits your workflow (`requirements.txt` for Python, plus per‑language installers):

```bash
#!/usr/bin/env bash
set -euo pipefail

# 0) Common CLI
sudo apt-get update
sudo apt-get install -y --no-install-recommends   zsh fzf bat ripgrep jq yq tree   build-essential cmake ninja-build pkg-config   clang clangd clang-format clang-tidy gdb lldb

# 1) Python
if [ -f requirements.txt ]; then
  python3 -m venv ~/.venv
  source ~/.venv/bin/activate
  pip install --upgrade pip wheel
  pip install -r requirements.txt
fi

# 2) JS/TS
if [ -f package.json ]; then
  corepack enable || true
  npm -g i npm@latest pnpm
  npm i
fi

# 3) Rust
if ! command -v cargo >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
fi
~/.cargo/bin/rustup component add rustfmt clippy rust-src || true

# 4) Java (example, if needed here)
# sdkman or apt-based openjdk. You already manage Java; keep as-is.

echo "[post-create] Language setup completed."
```

---

## 5) Lint/Format/Test — unified commands

Use `make` or `just` to unify language commands across stacks:

```Makefile
# Makefile
.PHONY: fmt lint test

fmt:
	black . || true
	ruff --fix . || true
	prettier -w . || true
	clang-format -i $(shell git ls-files '*.[ch]' '*.[ch]pp' '*.cc' '*.hh') || true
	cargo fmt || true

lint:
	ruff . || true
	eslint . || true
	clang-tidy $(shell git ls-files '*.[ch]' '*.[ch]pp' '*.cc' '*.hh') || true
	cargo clippy --all-targets --all-features || true

test:
	pytest -q || true
	pnpm -s vitest run || npm test --silent || true
	cargo test --all --quiet || true
```

> Swap `black/ruff/prettier/eslint/clang-*` with your exact stack; `just` can replace `make` if preferred.

---

## 6) Profiles / variants（軽量化と再現性）

Keep **one default polyglot image** and add **compose profiles** for lean specializations:

- `default`: everything enabled (Python/Java/JS/Rust/C++), for AI‑assisted full‑stack work.
- `js`: only Node/TS; skip Rust/C++ installs in `post-create.sh` behind a flag.
- `sys`: Rust + C/C++ only; skip Node/TS and heavy Python data libs.

**Example switch via env flag** in `post-create.sh`:

```bash
# honor DEV_PROFILE=[default|js|sys]
PROFILE="${DEV_PROFILE:-default}"
if [ "$PROFILE" = "js" ]; then
  SKIP_RUST=1; SKIP_CPP=1
elif [ "$PROFILE" = "sys" ]; then
  SKIP_NODE=1; SKIP_PYDATA=1
fi
```

Then condition package blocks on these flags.

---

## 7) Language‑specific caches & mounts

- Mount `~/.cache`, Node pnpm/yarn cache, Cargo registry to speed rebuilds:
  - `~/.cache`
  - `~/.pnpm-store` or `~/.cache/yarn`
  - `~/.cargo/registry`, `~/.cargo/git`

> Add devcontainer `"mounts"` entries or named volumes accordingly.

---

## 8) Quality gates before CI

- `pre-commit` hooks: unify `ruff`, `black`, `prettier`, `eslint`, `clang-format`.
- `task: lint`, `task: test` in CI (GitHub Actions). Agents can call the same Make/Just tasks.

Example `.pre-commit-config.yaml` (extract):
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.8
    hooks: [{ id: ruff }, { id: ruff-format }]
  - repo: https://github.com/psf/black
    rev: 24.8.0
    hooks: [{ id: black }]
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v4.0.0-alpha.8
    hooks: [{ id: prettier }]
```

---

## 9) TL;DR 推奨結論

- **管理方針**: 現行の **単一ポリグロット DevContainer** を“既定”（AIエージェント最適）にし、必要時のみ **軽量プロファイル** を切り替え。  
- **導入モジュール**:  
  - **JS/TS**: Node LTS + ESLint + Prettier + Vitest/Playwright  
  - **C/C++**: build-essential + cmake/ninja + clangd + clang-format/tidy + gdb/lldb  
  - **Rust**: rustup + rustfmt/clippy + rust-analyzer + CodeLLDB  
- **実装**: 主要バイナリは `Dockerfile` または `post-create.sh` に整理。Pythonは `requirements.txt`、JSは `package.json`、Rustは `Cargo.toml`／`rust-toolchain.toml`で管理。  
- **統一運用**: `make`/`just` と `pre-commit` で **fmt/lint/test** を共通化。

---

### Starter file checklist
- `requirements.txt` (Python)
- `package.json` (+ `.eslintrc.*`, `.prettierrc*`)
- `Cargo.toml` + `rust-toolchain.toml` (Rust)
- `CMakeLists.txt` / `Makefile` (C/C++)
- `.pre-commit-config.yaml`
- `Makefile` or `justfile`
- `.vscode/launch.json` for debugging (LLDB/GDB/Jest/Vitest)
