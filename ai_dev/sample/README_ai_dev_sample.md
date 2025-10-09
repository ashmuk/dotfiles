# AI Development Environment - Sample Configuration Files

このディレクトリには、[AI Agent × DevContainer × tmux Architecture](../README_ai_dev_arch.md) ドキュメントで説明されている自律実行開発環境を構築するためのサンプル設定ファイルが含まれています。

**重要**: このディレクトリ内のファイルは、先頭のドット `.` を外した状態で保存されています。`setup_ai_dev_sample.sh` スクリプトを使用してプロジェクトに配置すると、適切なファイル名（先頭にドット付き）で展開されます。

## 📁 ディレクトリ構造

```
sample/
├── devcontainer/              # DevContainer設定（プロジェクトでは .devcontainer/）
│   ├── devcontainer.json      # VSCode/Cursor DevContainer 設定
│   ├── Dockerfile             # コンテナイメージ定義
│   └── docker-compose.yml     # サービス定義（default/no-net プロファイル）
├── github/                    # GitHub Actions設定（プロジェクトでは .github/）
│   └── workflows/
│       └── ci.yml             # GitHub Actions CI ワークフロー
├── aider.conf.yml             # Aider 設定（プロジェクトでは .aider.conf.yml）
├── env.example                # 環境変数テンプレート（プロジェクトでは .env）
├── gitignore                  # Git 除外設定（プロジェクトでは .gitignore）
├── pre-commit-config.yaml     # Pre-commit フック設定（プロジェクトでは .pre-commit-config.yaml）
├── Makefile                   # タスク実行コマンド集
├── setup_ai_dev_sample.sh     # 配置用ブートストラップスクリプト
└── README_ai_dev_sample.md    # このファイル
```

**注**: tmux 関連ファイル（`.tmux.conf`, `tmuxinator/ai-dev.yml`）は `~/dotfiles/config/tmux/` に配置されています。

## 🚀 クイックスタート

### 方法1: ブートストラップスクリプトを使用（推奨）

```bash
# プロジェクトルートに移動
cd /path/to/your/project

# ブートストラップスクリプトを実行
~/dotfiles/ai_dev/sample/setup_ai_dev_sample.sh
```

このスクリプトは以下を自動的に行います:
- すべての設定ファイルを適切なファイル名（先頭にドット付き）でコピー
- 既存ファイルのバックアップ
- `.env` ファイルの作成（`env.example` から）
- 次のステップの表示

### 方法2: 手動コピー

```bash
# プロジェクトルートで実行
cd /path/to/your/project

# DevContainer設定
cp -r ~/dotfiles/ai_dev/sample/devcontainer .devcontainer

# AI/開発ツール設定
cp ~/dotfiles/ai_dev/sample/aider.conf.yml .aider.conf.yml
cp ~/dotfiles/ai_dev/sample/Makefile .
cp ~/dotfiles/ai_dev/sample/gitignore .gitignore
cp ~/dotfiles/ai_dev/sample/pre-commit-config.yaml .pre-commit-config.yaml

# 環境変数
cp ~/dotfiles/ai_dev/sample/env.example .env

# GitHub Actions
mkdir -p .github/workflows
cp ~/dotfiles/ai_dev/sample/github/workflows/ci.yml .github/workflows/
```

### 次のステップ

1. **環境変数を設定**:
   ```bash
   vim .env
   # ANTHROPIC_API_KEY, OPENAI_API_KEY, GITHUB_TOKEN を設定
   ```

2. **DevContainerで開く**:
   - VSCode/Cursorで `Cmd+Shift+P` → `Dev Containers: Reopen in Container`

3. **tmux環境をセットアップ（ホスト側、初回のみ）**:
   ```bash
   # dotfilesルートから
   make install-tmux
   ```

4. **tmuxセッションを開始**:
   ```bash
   tmuxinator start ai-dev
   ```

## 📋 各ファイルの説明

### DevContainer 関連

#### `.devcontainer/devcontainer.json`
- VSCode/Cursor の DevContainer 設定
- 推奨拡張機能の自動インストール
- セキュリティオプション（capability dropping）

#### `.devcontainer/Dockerfile`
- Python 3.11 ベース
- Aider, Ruff, pytest などのツールをプリインストール
- GitHub CLI (gh), act, tmux を含む

#### `.devcontainer/docker-compose.yml`
- `default` プロファイル: 通常の開発環境（LLM API 接続可）
- `no-net` プロファイル: ネットワーク遮断環境（オフライン作業用）

### AI ツール設定

#### `.aider.conf.yml`
- 使用モデル: `claude-4.5-sonnet`
- 自動コミット有効
- 除外ディレクトリ設定

#### `Makefile`
- `make setup`: ツールインストール
- `make aider-plan`: 設計プラン作成
- `make aider-refactor`: コードリファクタリング
- `make ci-local`: ローカル CI 実行（act 使用）
- `make swe-fix`: Issue 自動修正（SWE-agent）

### tmux 設定

tmux 関連の設定ファイルは `~/dotfiles/config/tmux/` に配置されています:

- **`config/tmux/tmux.conf`**: tmux設定（通常開発とAI開発両方で使用）
  - マウスサポート、Vimスタイルのペイン移動、256色サポート
- **`config/tmux/tmuxinator/ai-dev.yml`**: AI開発用4ペイン構成テンプレート
  - compose, aider, test, monitor

配置方法: `make install-tmux` (dotfilesルートから実行)

### 品質管理

#### `.pre-commit-config.yaml`
- Ruff: Python linter + formatter
- Black: Python formatter
- ShellCheck: シェルスクリプト検証
- markdownlint: Markdown 整形
- 各種セキュリティチェック

#### `.github/workflows/ci.yml`
- Pull Request / Push 時に自動実行
- Lint, Format, Test, Security Scan
- Coverage レポート生成

### その他

#### `.env.example`
- API キーのテンプレート
- **重要**: `.env` にコピーして実際のキーを設定

#### `.gitignore`
- `.env` ファイル（シークレット保護）
- Python キャッシュ、ログファイル等

## 🔧 カスタマイズ

### モデル変更
`.aider.conf.yml` と `Makefile` の `model` パラメータを変更:
```yaml
model: claude-4.5-sonnet  # または gpt-4, gemini-pro など
```

### プロファイル切り替え
```bash
# no-net プロファイルで起動（外部 API 接続なし）
docker compose --profile no-net up
```

### tmux レイアウト変更
`~/.tmuxinator/ai-dev.yml` を編集してペイン構成をカスタマイズ（詳細は `config/tmux/README_tmux.md` 参照）

## 📚 参考ドキュメント

- [AI Agent × DevContainer × tmux Architecture](../README_ai_dev_arch.md)
- [Aider 公式ドキュメント](https://aider.chat/)
- [DevContainers 公式ドキュメント](https://containers.dev/)

## ⚠️ 注意事項

1. **`.env` ファイルは絶対にコミットしない**
2. **API キーは定期的にローテーションする**
3. **no-net プロファイルでは LLM API が使用不可**
4. **コンテナは非 root ユーザー（vscode）で実行される**

## 🤝 貢献

改善案や追加設定例があれば、Issue または Pull Request でお知らせください。
