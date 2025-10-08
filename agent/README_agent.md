# Agent-Based Development Guide

> **Purpose**: Guide for using `CLAUDE.md` (overall policy) + `AGENTS.md` (agent definitions) + `.codex/mcp.yaml` (tool definitions) for multi-agent development workflows with Claude Code.

> **See also**: [README_cursor.md](./README_cursor.md) for Cursor AI-specific configuration templates.

---

## Overview

This guide provides a template for organizing agent-based development using:
- **CLAUDE.md**: Project-wide policies and principles
- **AGENTS.md**: Role definitions for specialized agents
- **codex/config.json**: Codex runtime configuration (Copy this and paste in <project root> directory as .codex)
- **codex/mcp.yaml**: MCP tool declarations (Copy this and paste in <project root> directory as .codex)
- **mcp/**: Tool definitions (JSON Schema and OpenAPI)
- **prompts/**: Shared prompt templates (used by Codex; Cursor has its own copy in `cursor/prompts/`)

```text
agent/
├─ README_agent.md          # This file (Claude Code / Codex guide)
├─ README_cursor.md         # Cursor AI-specific guide (see this for Cursor setup)
├─ CLAUDE.md                # Project-wide policies and principles
├─ AGENTS.md                # Role definitions for specialied agents
├─ prompts/                 # Shared prompts for Codex (referenced by codex/config.json)
│  └─ refactor.md           # Direction how to refactor
│
├─ codex/                   # Place this folder in <project root> directory as `.codex`
│  ├─ config.json           # Codex/IDE integration config for execution (models, context...)
│  └─ mcp.yaml              # MCP tool usage declare ()OpenAPI/JSON Schema/commands)
│
├─ cursor/                  # Place this folder in <project root> directory as `.cursor`
│  ├─ prompts/              # Cursor-specific prompts (isolated copy for Cursor)
│  │  └─ refactor.md        # Direction how to refactor (same content as ../prompts/refactor.md)
│  ├─ rules/                # Rules how to assist by Cursor
│  │  └─ 00_general.md      # Generic directions
│  └─ settings.json         # Minimal setting at project level
│
└─ mcp/
   ├─ tools/
   │  └─ echo.json          # JSON-Schema tool (ex. echo)
   └─ openapi/
      └─ demo.yaml          # OpenAPI tools sample (ex. /ping)
```

### Key Benefits

- **Clear separation**: Project policy (CLAUDE.md) vs. agent roles (AGENTS.md) vs. tool capabilities (MCP)
- **Structured collaboration**: Planner → Coder → Reviewer workflow
- **Consistent execution**: Well-defined roles, responsibilities, and available tools

---

## CLAUDE.md Template (Project Policy)

```markdown
# CLAUDE.md — Project Policy

## Purpose
- Define the primary objectives and scope of the repository
- Example: Building a web application with API integration, focusing on reliability (testing/monitoring/reproducibility)

## Style & Priorities
1. Type safety and principle of least privilege
2. Documentation-first approach (ADR/README updates are mandatory)
3. Security linting and dependency vulnerability checks enforced in CI

## Tech Preference
- Languages: TypeScript / Python
- Frontend: Next.js (App Router)
- Server: FastAPI or Next.js API Routes
- Database: PostgreSQL (Prisma or SQLAlchemy)

## Definition of Done
- Lint/Typecheck/Unit tests/Minimal E2E tests all passing
- README and CHANGELOG updated
- Security considerations verified (secrets/keys/PII)

## Non-Goals
- Avoid excessive dependency on vendor-specific features
```

---

## AGENTS.md Template (Agent Role Definitions)

```markdown
# AGENTS.md — Multi-Agent Roles

## Planner
- **Role**: Break down objectives into structured plans with dependencies
- **Style**: Structured, concise, verifiable
- **Output**: Task table with owner/estimate/acceptance criteria

## Coder
- **Role**: Implement Planner's instructions while adhering to tests, types, and linting standards
- **Style**: Small commits, readable PRs with clear diffs
- **Output**: Working code + minimal documentation updates

## Reviewer
- **Role**: Verify security, readability, and design consistency
- **Style**: Evidence-based review comments with suggested fixes
- **Output**: Feedback labeled as `nit/blocker/suggestion`

## Toolsmith (Optional)
- **Role**: Add MCP tools, design schemas, maintain OpenAPI definitions
- **Output**: Update `mcp.yaml`/`tools/*` and add usage examples to README

## Operator (Optional)
- **Role**: Maintain local/CI execution procedures, environment variable/secret injection processes
- **Output**: Update bootstrap scripts and environment templates

## MCP Usage Policy
- Tool invocations must specify **purpose, input, and output**
- Sensitive data managed via `.env`, never committed
```

---

## .codex/config.json (Codex Runtime Configuration)

```json
{
  "model": "anthropic/claude-4.5-sonnet",
  "fallbackModels": ["openai/gpt-5"],
  "maxTokens": 4000,
  "contextFiles": [
    "CLAUDE.md",
    "AGENTS.md",
    "prompts/refactor.md"
  ],
  "enableMCP": true,
  "mcpConfigPath": ".codex/mcp.yaml",
  "allowWrite": true,
  "codeStyle": {
    "typescriptPreferred": true,
    "testsRequired": true
  }
}
```

> **Note**: Adjust model IDs according to your environment.

---

## .codex/mcp.yaml (MCP Tool Declaration)

```yaml
version: 1
name: codex-tools

# JSON-Schema based function tools
commands:
  - name: echo
    description: Echo back the provided text.
    schema: ./../mcp/tools/echo.json

# OpenAPI based HTTP tools
openapi:
  - name: demo-api
    description: Simple demo API (ping endpoint)
    spec: ./../mcp/openapi/demo.yaml
```

---

## mcp/tools/echo.json (JSON Schema Tool Example)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "echo",
  "type": "object",
  "properties": {
    "text": { "type": "string", "description": "text to echo back" }
  },
  "required": ["text"]
}
```

---

## mcp/openapi/demo.yaml (OpenAPI Tool Example)

```yaml
openapi: 3.0.3
info:
  title: Demo API
  version: 1.0.0
paths:
  /ping:
    get:
      summary: Health check
      responses:
        '200':
          description: pong
          content:
            application/json:
              schema:
                type: object
                properties:
                  ok:
                    type: boolean
                    example: true
```

---

## Usage Workflow

1. **CLAUDE.md**: Define project-wide **principles and policies**
2. **AGENTS.md**: Define **specific roles** and handoff formats
3. **.codex/mcp.yaml**: Declare **available tools** (JSON Schema and OpenAPI)
4. **mcp/tools/*** and **mcp/openapi/***: Implement tool definitions
5. **.codex/config.json**: Configure model and context files
6. Execute workflow: **Planner → Coder → Reviewer** sequence with MCP tools

### Tips for Success

- **Policy (CLAUDE.md)**: Project-level principles that rarely change
- **Roles (AGENTS.md)**: Concrete agent personas - Planner→Coder→Reviewer is the fundamental flow
- **Tools (MCP)**: Define available capabilities and provide usage examples in AGENTS.md
- **Tool definitions**: Keep JSON Schema tools simple and focused; use OpenAPI for HTTP-based services
- Specify which MCP tools each agent can use in AGENTS.md for stable behavior

---

## Best Practices

### For CLAUDE.md
- Keep policies technology-agnostic where possible
- Define clear success criteria (Definition of Done)
- Explicitly state what's out of scope (Non-Goals)

### For AGENTS.md
- Define clear handoff points between agents
- Specify output format for each role
- Include optional roles for specialized needs
- Document tool usage policies if using MCP
- Optionally specify which MCP tools each agent role can access

### For MCP Tools
- **Purpose, Input, Output**: Always document these three elements
- **JSON Schema tools**: For simple function-like operations
- **OpenAPI tools**: For HTTP API integrations
- **Security**: Never commit secrets; use `.env` for sensitive data
- **Testing**: Verify tool definitions work before adding to workflows

### Agent Collaboration
- Planner creates the roadmap (may use MCP tools for research)
- Coder implements incrementally (uses MCP tools as needed)
- Reviewer ensures quality and security
- Toolsmith maintains and extends MCP tool catalog
- Iterate as needed based on feedback

---

## Example Execution Flow

1. **User Request** → Planner analyzes and creates structured plan
2. **Plan** → Coder implements in small, testable increments (using MCP tools)
3. **Implementation** → Reviewer checks for issues and suggests improvements
4. **Feedback** → Coder addresses review comments
5. **Tool needs identified** → Toolsmith adds new MCP tools to `.codex/mcp.yaml`
6. **Approval** → Merge and document

---

## MCP Tool Development

### Adding a New JSON Schema Tool

1. Create tool definition in `mcp/tools/your-tool.json`
2. Add entry to `.codex/mcp.yaml` under `commands`
3. Document usage in AGENTS.md or README
4. Test the tool works as expected

### Adding a New OpenAPI Tool

1. Create OpenAPI spec in `mcp/openapi/your-api.yaml`
2. Add entry to `.codex/mcp.yaml` under `openapi`
3. Document authentication and usage patterns
4. Test endpoints and error handling

---

## Customization

This template is a starting point. Adapt it to your project by:
- Adjusting tech preferences in CLAUDE.md
- Adding/removing agent roles in AGENTS.md
- Creating custom MCP tools for project-specific needs
- Defining project-specific policies and standards
- Creating custom workflows beyond Planner→Coder→Reviewer

Remember: The goal is clear communication, consistent execution, and powerful tool integration across all agents.
