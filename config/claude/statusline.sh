#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code status line with MCP check

# Read JSON input from stdin
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Claude model 
MODEL=$(get_model_name)

# Cost
COST_RAW=$(get_cost)
COST=$(awk -v cst="$COST_RAW" 'BEGIN {printf "%.2f", cst}')

# Duration (ms -> min)
DUR_MS=$(get_duration)
DURATION=$(awk -v msec="$DUR_MS" 'BEGIN { printf "%.2f", msec / 60000 }')

# Lines added
L_ADDED=$(get_lines_added)

# Lines removed
L_REMOVED=$(get_lines_removed)

# Project directory
target=$(get_project_dir)
if [[ "$target" == $HOME* ]]; then
  PRJ_DIR="~${target#$HOME}"
else
  PRJ_DIR="$target"
fi


# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" 🌿 $BRANCH"
    fi
fi

# Python
if command -v python3 >/dev/null 2>&1; then
  PY=$(python3 --version 2>/dev/null | cut -d' ' -f2)
fi

# Java
if command -v java >/dev/null 2>&1; then
  JAVA_FULL=$(java -version 2>&1 | head -n 1 | sed 's/"//g')
  JAVA=$(echo "$JAVA_FULL" | grep -Eo '[0-9]+(\.[0-9]+)*' | head -n 1)
fi

# Shell
SHELL_NAME=$(basename "$SHELL")

# CI 環境判定
if [ -n "$CI" ]; then
  CI_STATUS="$CI"
else
  CI_STATUS="local"
fi

# Check MCP Servers
MCP_STATUS=""
MCP_CONFIG="$PWD/.mcp.json"

if [ -f "$MCP_CONFIG" ]; then
  # .mcp.json to be checked to extract content 
  SERVER_CMDS=$(jq -r '.servers | to_entries[] | .value.command // empty' "$MCP_CONFIG" 2>/dev/null)

  for CMD in $SERVER_CMDS; do
    if pgrep -f "$CMD" >/dev/null 2>&1; then
      MCP_STATUS+="$(basename "$CMD"):up "
    else
      MCP_STATUS+="$(basename "$CMD"):down "
    fi
  done
else
  MCP_STATUS="no-mcp"
fi

# Status line format
STATUS_LINE="
| ${MODEL:-NA} | \$${COST:-0.0} | ${DURATION} mins | A:${L_ADDED} | R:${L_REMOVED} | 
| ${SHELL_NAME} (${PRJ_DIR}${GIT_BRANCH}) | Py:${PY:-NA} | Java:${JAVA:-NA} | CI:${CI_STATUS} | MCP:${MCP_STATUS}"

# Display statusline
echo "$STATUS_LINE"
