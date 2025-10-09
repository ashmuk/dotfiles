# AI Agent × DevContainer × tmux Architecture

本書は、AIエージェント（Aider/SWE-agent 等）を **DevContainer** 内で安全に実行し、ホスト側の **Cursor/ClaudeCode** を UI として活用しつつ、**tmux** で並行タスクをオーケストレーションするための構成と運用の要点をまとめたものです。

---

## 1. 全体像（System Architecture）

```mermaid
flowchart TD
    subgraph macOS_Host["🖥️ macOS Host"]
        subgraph UI["UI / Interactive Layer"]
            Cursor["Cursor / ClaudeCode\n(IDE + 対話補助)"]
            JetBrains["JetBrains / VS Code\n(レビュー/編集)"]
        end
        subgraph Term["Terminal / Orchestrator"]
            iTerm2["iTerm2 / zsh / tmux\n(並行タスク制御)"]
        end
        Repo[("Project Folder\n~/work/repo")]
    end

    subgraph DevC["🐳 Docker DevContainer\n(非root・権限/ネットワーク制御)"]
        subgraph Agent["AI Execution Layer"]
            Aider["Aider (CLI)\n→ Claude/GPT API 呼出"]
            SWE["SWE-agent\n→ Issue→Fix→PR 自動"]
        end
        subgraph CI["CI / Test / QA"]
            Lint["Ruff / ESLint / Prettier"]
            Test["pytest / jest"]
            Act["act (GH Actions ローカル再現)"]
        end
        Git["git commit / hooks / push"]
        WorkDir(("/work (bind-mount)"))
    end

    subgraph Cloud["☁️ External Cloud / API"]
        Claude["Anthropic Claude / OpenAI GPT (LLM)"]
        GitHub["GitHub (Remote Repo / PR / Actions)"]
    end

    Cursor --- Repo
    JetBrains --- Repo
    Repo == bind-mount RW ==> WorkDir
    iTerm2 -->|devcontainer exec / docker compose| DevC
    Aider --> Claude
    SWE --> Claude
    Lint --> Git
    Test --> Git
    Act --> GitHub
    Git --> GitHub
```

---

### 1.2 役割分担

| レイヤー  | 主ツール                   | 置き場所             | 主な役割                    |
| ----- | ---------------------- | ---------------- | ----------------------- |
| UI/対話 | Cursor, ClaudeCode     | **ホスト**          | 設計・レビュー・プロンプト入力         |
| 自動実行  | **Aider**, SWE-agent   | **DevContainer** | ワンショット/バッチの自動修正・コミット・PR |
| LLM   | Claude/GPT             | クラウド             | 実際の推論処理（API 呼び出し）       |
| CI/検証 | ruff/pytest/eslint/act | DevContainer     | 自動検証・事前チェック             |
| 並行実行  | **tmux**               | **ホスト（推奨）**      | 複数ペインで AI/テスト/ログを同時進行   |

---

## 2. 運用フロー（Operational Workflows）

### 2.1 基本的な運用例

```bash
make setup
make aider-plan
make aider-refactor
make ci-local
ISSUE_URL="https://github.com/you/repo/issues/123" make swe-fix
```

---

### 2.2 データフロー（Sequence Diagram）

```mermaid
sequenceDiagram
    autonumber
    participant U as User (Cursor/ClaudeCode)
    participant TM as tmux/iTerm2 (Host)
    participant DC as DevContainer (/work)
    participant AI as Aider/SWE-agent (in DC)
    participant LLM as Claude/GPT API (Cloud)
    participant GIT as Git (Local repo @ /work)
    participant GH as GitHub (Remote)
    participant CI as GitHub Actions

    U->>TM: make aider-refactor
    TM->>DC: devcontainer exec
    DC->>AI: AI ジョブ起動
    AI->>LLM: モデル呼び出し
    LLM-->>AI: 生成結果
    AI->>GIT: commit
    AI->>CI: act (ローカルCI)
    AI->>GH: push / PR
    GH-->>CI: Workflow 起動
    CI-->>GH: 状態更新
    GH-->>U: PR通知
```

---

## 3. PR 自動化ワークフロー

### 3.1 PR 作成から Merge までのフロー

```mermaid
sequenceDiagram
    autonumber
    participant Dev as AI (Aider/SWE-agent)
    participant GH as GitHub
    participant CI as GitHub Actions
    participant Reviewer as Reviewer (You)

    Dev->>GH: ブランチ push & PR 作成
    GH-->>CI: lint/test/sast チェック
    alt PASS
        GH-->>Reviewer: Ready for review
        Reviewer->>GH: Approve & Merge
    else FAIL
        GH-->>Dev: Failure Log
        Dev->>GH: 修正 push
    end
```

---

### 3.2 自動化の利点

- **一貫性**: AI が統一されたコーディング規約でコード生成
- **速度**: 人手による修正待ちを削減
- **品質**: CI/CD による自動検証で早期にバグを検出
- **トレーサビリティ**: Issue → Commit → PR → Merge の履歴が明確

---

## 4. DevContainer 環境の詳細

### 4.1 Reopen in Container の効用

- **ツールチェーン統一**: Linter/Debugger/Language Server をコンテナ側に固定
- **環境一致**: ローカル開発環境と CI 環境を完全に一致させる
- **セキュリティ**: 非 root ユーザーでの実行、ネットワーク制御が可能
- **ポータビリティ**: チーム全体で同じ開発環境を共有

### 4.2 ネットワーク遮断プロファイル（no-net）

```mermaid
flowchart TD
    A([Start]) --> B{Profile}
    B -->|default| C[LLM API 呼び出し可\n npm/pip 可\n gh/CI 実行可]
    C --> D[AIタスク実行\n(Aider / SWE-agent)]
    D --> E[ファイル変更・commit]
    E --> F[push / PR]

    B -->|no-net| X{LLM 必須?}
    X -->|Yes| X1[外部API不可 → 失敗/スキップ]
    X1 --> X2[代替: ローカルLLM / キャッシュ / ドライラン]
    X -->|No| Y[静的解析/テスト/ビルド]
    Y --> Z[成果物は /work に保存]

    style X1 fill:#FDE2E1,stroke:#C62828
    style Y fill:#E0F2F1,stroke:#00695C
```

**用途例**:

- **セキュリティ強化**: 機密プロジェクトで外部 API 接続を禁止
- **オフライン作業**: ネットワーク接続がない環境でのテスト・ビルド
- **コスト削減**: LLM API を使わない静的解析のみ実行

---

## 5. Mermaid 図の活用

### 5.1 推奨 VSCode 拡張機能

- `bierner.markdown-mermaid` - Markdown プレビュー内での表示
- `vstirbu.vscode-mermaid-preview` - 専用プレビューウィンドウ
- `shd101wyy.markdown-preview-enhanced` - 高機能プレビュー

### 5.2 画像出力（CLI）

```bash
# mermaid-cli のインストール
npm i -g @mermaid-js/mermaid-cli

# PNG/SVG 出力
mmdc -i diagram.mmd -o diagram.png
mmdc -i diagram.mmd -o diagram.svg
```

---

## 6. ベストプラクティス

### 6.1 開発フロー

1. **計画**: `make aider-plan` で設計方針を AI と対話
2. **実装**: `make aider-refactor` で段階的に実装
3. **検証**: `make ci-local` でローカルテスト実行
4. **レビュー**: Cursor/ClaudeCode で差分確認
5. **統合**: PR 作成 → CI 通過 → Merge

### 6.2 セキュリティ

- **最小権限**: DevContainer は非 root で実行
- **ネットワーク制御**: no-net プロファイルで外部通信制限
- **秘密情報管理**: `.env` ファイルや環境変数を活用、コミット禁止
- **コード監査**: `act` でローカル再現して SAST/DAST を事前実行

### 6.3 並行タスク管理（tmux）

```bash
# tmux セッション作成
tmux new -s dev

# ペイン分割例
# - ペイン 1: Aider 実行
# - ペイン 2: テスト監視 (pytest --watch)
# - ペイン 3: ログ監視 (tail -f logs/*.log)
# - ペイン 4: git status 確認

# セッション一覧
tmux ls

# セッションにアタッチ
tmux attach -t dev
```

---

## 7. まとめ

この構成により、以下が実現されます：

- **安全性**: DevContainer による隔離環境での AI 実行
- **生産性**: tmux による複数タスクの並行実行とモニタリング
- **一貫性**: CI/CD とローカル環境の完全一致
- **柔軟性**: ホスト側の UI ツール（Cursor/ClaudeCode）との統合
- **自動化**: Issue → Fix → PR → Merge の完全自動化

### 参考リソース

- [DevContainers 公式ドキュメント](https://containers.dev/)
- [Aider 公式ドキュメント](https://aider.chat/)
- [tmux チートシート](https://tmuxcheatsheet.com/)
- [Mermaid 公式サイト](https://mermaid.js.org/)

---

**Last Updated**: 2025-10-09
