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
