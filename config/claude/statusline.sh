#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code status line with MCP check

# Git ブランチ
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")

# Python バージョン
PY=$(python3 --version 2>/dev/null | cut -d' ' -f2)

# Java バージョン（1行目のみ）
JAVA=$(java -version 2>&1 | head -n 1 | sed 's/"//g')

# シェル
SHELL_NAME=$(basename "$SHELL")

# CI 環境判定
if [ -n "$CI" ]; then
  CI_STATUS="CI:$CI"
else
  CI_STATUS="local"
fi

# === MCP サーバー確認 ===
MCP_STATUS=""
MCP_CONFIG="$PWD/.mcp.json"

if [ -f "$MCP_CONFIG" ]; then
  # .mcp.json 内のコマンドを抽出して存在チェック
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

# 出力
echo "[${BRANCH}] | Py:${PY:-NA} | ${JAVA:-Java NA} | Sh:${SHELL_NAME} | ${CI_STATUS} | MCP:${MCP_STATUS}"
