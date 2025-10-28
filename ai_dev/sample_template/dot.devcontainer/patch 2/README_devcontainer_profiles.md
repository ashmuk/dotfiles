# DevContainer Profiles (By Tech Stack / Persona)

This repository supports **persona/stack-based profiles** via the `DEV_PROFILE` env var.
Profiles determine which language toolchains are installed by `/workspace/.devcontainer/post-create.sh`.

## Available profiles
- `web` — Web app stack (Node/TS + Python for APIs + Java detection).  
- `native` — Native apps (C/C++ + Rust + Java detection).  
- `ai` — AI/DS (Python, Jupyter-ready if you add it, and AI CLIs).  
- `microservice` — Backend/API (Python + Node + Java detection).  
- `embedded` — Embedded/system (C/C++ + Rust).  
- `fullstack` — Everything (default).

## How to select a profile
### A) devcontainer.json
```jsonc
{
  "containerEnv": {
    "DEV_PROFILE": "web" // web | native | ai | microservice | embedded | fullstack
  }
}
```

### B) docker compose
```yaml
services:
  devcontainer:
    environment:
      DEV_PROFILE: web
```

## AI CLIs (Claude / OpenAI / Gemini)
- Installed via `pipx` and exposed as simple wrappers:
  - `ai-claude` (needs `ANTHROPIC_API_KEY`)
  - `ai-openai` (needs `OPENAI_API_KEY`)
  - `ai-gemini` (needs `GOOGLE_API_KEY`)

Example:
```bash
echo "List 3 risk areas for our API" | ai-claude
echo "Suggest REST endpoint names" | ai-openai
echo "Write a curl OAuth example" | ai-gemini
```

## Java version capture
The post-create script detects Java safely and extracts the version:
```
openjdk 21.0.6 2025-01-21 LTS
# => version: 21.0.6
```

## Files
- `devcontainer.profiles.patched.json` — devcontainer additions (Node LTS feature, extensions, `DEV_PROFILE` default).
- `post-create.profiles.sh` — functionized installers + profile routing + AI CLIs.
- `compose.profiles.patched.yml` — example of wiring `DEV_PROFILE` via Compose.