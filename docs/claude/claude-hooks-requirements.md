# Claude Code Hooks 実装要件

6つのHookをまとめた実装仕様です。

| # | Hook名 | イベント | 役割 |
|---|---|---|---|
| ① | `auto-format.sh` | PostToolUse | ファイル編集後に自動フォーマット |
| ② | `security-guard.sh` | PreToolUse | 危険コマンドをブロック |
| ③ | `file-guard.sh` | PreToolUse | センシティブファイルへの書き込みを警告 |
| ④ | `maybe-simplify.sh` | Stop | 変更多数時に code-simplifier を促す |
| ⑤ | `trigger-simplifier.sh` | UserPromptSubmit | キーワード検知で code-simplifier を注入 |
| ⑥ | `notify.sh` | Notification | 音 + ポップアップダイアログで通知 |

---

## 前提条件

- `jq` コマンドがインストール済みであること
- プロジェクトルートが git 管理下にあること（④の条件チェックに使用）
- ④⑤を使う場合は `code-simplifier` プラグインがインストール済みであること
  ```bash
  claude plugin install code-simplifier
  # またはセッション内で:
  /plugin marketplace update claude-plugins-official
  /plugin install code-simplifier
  ```
  インストール後、セッションを再起動して有効化すること

---

## ファイル構成

```
.claude/
├── settings.json
└── hooks/
    ├── auto-format.sh         # ① PostToolUse: 自動フォーマット
    ├── security-guard.sh      # ② PreToolUse:  危険コマンドブロック
    ├── file-guard.sh          # ③ PreToolUse:  センシティブファイル保護
    ├── maybe-simplify.sh      # ④ Stop:        code-simplifier 促進
    ├── trigger-simplifier.sh  # ⑤ UserPromptSubmit: キーワード注入
    └── notify.sh              # ⑥ Notification: 音 + ダイアログ通知
```

---

## 実装① `.claude/hooks/auto-format.sh`

**役割**: ファイル編集・作成後に Prettier と ESLint を自動実行する。

```bash
#!/bin/bash
# .claude/hooks/auto-format.sh
# PostToolUse hook: 自動フォーマット（Prettier + ESLint）

FILE_PATH=$(jq -r '.tool_input.file_path // empty')

# ファイルパスが取れない場合はスルー
[ -z "$FILE_PATH" ] && exit 0

# Prettier
if command -v npx &>/dev/null; then
  npx prettier --write "$FILE_PATH" 2>/dev/null
fi

# ESLint（JS/TS系のみ）
if echo "$FILE_PATH" | grep -qE '\.(js|jsx|ts|tsx|mjs|cjs)$'; then
  if command -v npx &>/dev/null; then
    npx eslint --fix "$FILE_PATH" 2>/dev/null
  fi
fi

exit 0
```

**動作**:
- 常に exit 0（ブロックしない）
- Prettier → ESLint の順で実行
- ESLint は JS/TS 系ファイルのみ対象

---

## 実装② `.claude/hooks/security-guard.sh`

**役割**: 危険なBashコマンドを検知してブロックする。

```bash
#!/bin/bash
# .claude/hooks/security-guard.sh
# PreToolUse hook: 危険コマンドブロック

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Bash ツール以外はスルー
[ "$TOOL" != "Bash" ] && exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# ブロック対象パターン
DANGEROUS_PATTERNS=(
  'rm -rf /'
  'rm -rf \*'
  'sudo rm'
  'git push --force.*main'
  'git push -f.*main'
  'git reset --hard'
  'chmod 777'
  'DROP TABLE'
  ':\(\)\{.*\|.*&\}'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "🚫 危険なコマンドをブロックしました: $pattern" >&2
    exit 2
  fi
done

exit 0
```

**動作**:
- マッチした場合 exit 2（ブロック）、stderr の理由が Claude に送られる
- Bash 以外のツールはスルー

---

## 実装③ `.claude/hooks/file-guard.sh`

**役割**: `.env`・秘密鍵・証明書ファイルへの書き込み前に警告コンテキストを注入する（ブロックはしない）。

```bash
#!/bin/bash
# .claude/hooks/file-guard.sh
# PreToolUse hook: センシティブファイルへの書き込みを警告

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

FILENAME=$(basename "$FILE_PATH")

# センシティブファイルパターン
if echo "$FILENAME" | grep -qiE '^\.env$|^\.env\.|\.pem$|\.key$|^id_rsa|credentials\.json$|secrets\.json$'; then
  jq -n --arg warn "⚠️ センシティブファイル ($FILENAME) を編集しようとしています。本当に必要な変更か確認してください。シークレット・トークン類を平文でコミットしないよう注意。" \
    '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": $warn}}'
fi

exit 0
```

**動作**:
- 常に exit 0（ブロックしない）
- `additionalContext` で Claude に注意を促すソフトな制御
- 対象: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`, `credentials.json`, `secrets.json`

---

## 実装④ `.claude/hooks/maybe-simplify.sh`

**役割**: セッション終了時に git の変更ファイル数を確認し、5ファイル以上の変更があれば code-simplifier の実行を促す。

```bash
#!/bin/bash
# .claude/hooks/maybe-simplify.sh
# Stop hook: 変更ファイル数が多い場合に code-simplifier を促す

INPUT=$(cat)

# 無限ループ防止: すでに Stop hook が一度発火していたらスルー
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi

# 直近の git 変更ファイル数を確認
CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')

# 5ファイル以上変更があった場合のみ simplifier を提案してブロック
if [ "$CHANGED" -ge 5 ]; then
  jq -n --arg reason "${CHANGED} files modified in this session. Please run the code-simplifier agent before finishing: 'Use code-simplifier on recently modified files'" \
    '{"decision": "block", "reason": $reason}'
  exit 0
fi

exit 0
```

**動作**:
- 変更ファイル数 < 5 → スルー
- 変更ファイル数 ≥ 5 → `decision: block` で Claude に simplifier 実行を促す
- `stop_hook_active=true` の場合は無条件スルー（無限ループ防止）

---

## 実装⑤ `.claude/hooks/trigger-simplifier.sh`

**役割**: プロンプトに特定のキーワードが含まれる場合、`code-simplifier` エージェントを使うよう `additionalContext` を注入する。

```bash
#!/bin/bash
# .claude/hooks/trigger-simplifier.sh
# UserPromptSubmit hook: キーワード検知で code-simplifier を自動注入

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

# トリガーキーワード（英語・日本語）
KEYWORDS=("simplify" "clean up" "cleanup" "refactor" "readable" "整理" "シンプル" "きれいに" "リファクタ")

for kw in "${KEYWORDS[@]}"; do
  if echo "$PROMPT" | grep -q "$kw"; then
    jq -n '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "Use the code-simplifier agent for this task."}}'
    exit 0
  fi
done

exit 0
```

**動作**:
- キーワードあり → `additionalContext` に code-simplifier 指示を注入
- キーワードなし → スルー

---

## 実装⑥ `.claude/hooks/notify.sh`

**役割**: Claude が通知を送るタイミング（許可待ち・アイドル）に、効果音（afplay）とポップアップダイアログ（display dialog）を並列で出す。ダイアログは OK を押すまで消えないため、確実に気づける。

```bash
#!/bin/bash
# .claude/hooks/notify.sh
# Notification hook: 効果音 + ポップアップダイアログ（並列実行）

# 効果音をバックグラウンドで再生（ダイアログと同時に鳴らす）
afplay /System/Library/Sounds/Glass.aiff &

# ポップアップダイアログ（OK を押すまで消えない）
osascript -e 'display dialog "Claude Code needs your attention." with title "Claude Code" buttons {"OK"} default button "OK" with icon caution'

exit 0
```

**動作**:
- `afplay ... &` でサウンドをバックグラウンド起動 → ダイアログと同時に音が鳴る
- `display dialog` で画面中央にモーダルダイアログを表示
- OK ボタンを押すまでダイアログは消えない（他のアプリ操作も一部ブロック）
- `with icon caution` で警告アイコン（⚠️）を表示

**サウンドの変更候補** (`/System/Library/Sounds/` 以下):

| ファイル名 | 印象 |
|---|---|
| `Glass.aiff` | 軽快・クリア（デフォルト推奨） |
| `Hero.aiff` | 明るく目立つ |
| `Ping.aiff` | シンプルで短い |
| `Submarine.aiff` | 低めで落ち着いた |
| `Tink.aiff` | 小さく控えめ |

> **注意**: `display dialog` はフォアグラウンドで実行されるため、Hook スクリプト自体がダイアログを閉じるまで終了しない。Notification hook は非ブロッキングのため Claude の動作には影響しないが、ダイアログを閉じないとスクリプトプロセスが残り続ける点に注意。

---

## `.claude/settings.json` への追記

既存の `hooks` セクションがある場合はマージすること（上書き厳禁）。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-format.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/security-guard.sh"
          }
        ]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/file-guard.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/maybe-simplify.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/trigger-simplifier.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/notify.sh"
          }
        ]
      }
    ]
  }
}
```

---

## セットアップ手順

```bash
# 1. hooks ディレクトリ作成
mkdir -p .claude/hooks

# 2. 各スクリプトファイルを上記の内容で作成（6ファイル）

# 3. 実行権限を一括付与
chmod +x .claude/hooks/*.sh

# 4. settings.json に hooks 設定を追記（既存設定とマージ）

# 5. Claude Code を再起動して設定を反映
```

---

## 動作確認

| シナリオ | 期待する挙動 |
|---|---|
| Claude がファイルを編集 | Prettier / ESLint が自動実行される |
| `rm -rf /` を実行しようとする | ブロックされ、理由が Claude に伝わる |
| `git push --force main` を実行しようとする | 同上 |
| `.env` ファイルを編集しようとする | 警告コンテキストが注入される（ブロックなし） |
| `id_rsa` を編集しようとする | 同上 |
| 変更ファイル 4 以下でセッション終了 | Stop hook がスルー |
| 変更ファイル 5 以上でセッション終了 | code-simplifier の実行を促してブロック |
| `stop_hook_active=true` の状態で Stop | 無条件スルー（無限ループ防止） |
| プロンプトに "refactor" を含む | code-simplifier 指示が注入される |
| プロンプトに「整理して」を含む | 同上 |
| キーワードなしの通常プロンプト | 何も起こらない |
| Claude が許可待ち・アイドルになる | Glass.aiff が鳴り、ポップアップダイアログが表示される |
| ダイアログの OK を押す | ダイアログが閉じ、スクリプトが終了する |

---

## 調整ポイント

- **フォーマッタ変更**: `auto-format.sh` の `npx prettier` を `black`（Python）等に差し替え可能
- **ブロック対象追加**: `security-guard.sh` の `DANGEROUS_PATTERNS` 配列に追加
- **保護対象追加**: `file-guard.sh` の grep パターンを拡張
- **simplifier 閾値変更**: `maybe-simplify.sh` の `[ "$CHANGED" -ge 5 ]` の数値を調整
- **キーワード追加**: `trigger-simplifier.sh` の `KEYWORDS` 配列に追加
- **サウンド変更**: `notify.sh` の `Glass.aiff` を別のシステムサウンドに差し替え可能
- **ダイアログメッセージ変更**: `notify.sh` の `display dialog` の文言を自由に編集可能
- **スコープ変更**: `settings.json` を `~/.claude/settings.json` に置くと全プロジェクトに適用
