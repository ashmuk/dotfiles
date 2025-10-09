# AI Development Environment - Sample Configuration Files

このディレクトリには、[AI Agent × DevContainer × tmux Architecture](../README_ai_dev_arch.md) ドキュメントで説明されている自律実行開発環境を構築するためのサンプル設定ファイルが含まれています。

## 📁 ディレクトリ構造

```
sample/
├── .devcontainer/
│   ├── devcontainer.json    # VSCode/Cursor DevContainer 設定
│   ├── Dockerfile            # コンテナイメージ定義
│   └── docker-compose.yml    # サービス定義（default/no-net プロファイル）
├── .github/
│   └── workflows/
│       └── ci.yml            # GitHub Actions CI ワークフロー
├── tmuxinator/
│   └── ai-dev.yml            # tmux セッションテンプレート
├── .aider.conf.yml           # Aider 設定
├── .env.example              # 環境変数テンプレート
├── .gitignore                # Git 除外設定
├── .pre-commit-config.yaml   # Pre-commit フック設定
├── .tmux.conf                # tmux 設定
├── Makefile                  # タスク実行コマンド集
└── README.md                 # このファイル
```

## 🚀 クイックスタート

### 1. サンプルファイルをプロジェクトにコピー

```bash
# プロジェクトルートで実行
cp -r /path/to/dotfiles/ai_dev/sample/.devcontainer .
cp /path/to/dotfiles/ai_dev/sample/.aider.conf.yml .
cp /path/to/dotfiles/ai_dev/sample/.gitignore .
cp /path/to/dotfiles/ai_dev/sample/.pre-commit-config.yaml .
cp /path/to/dotfiles/ai_dev/sample/Makefile .
cp /path/to/dotfiles/ai_dev/sample/.env.example .env
```

### 2. 環境変数を設定

```bash
# .env ファイルを編集して API キーを設定
vim .env
```

### 3. DevContainer で開く

VSCode/Cursor で `Reopen in Container` を実行

### 4. tmux セッションを開始（ホスト側）

```bash
# ホストHOMEに tmux 設定をコピー
cp /path/to/dotfiles/ai_dev/sample/.tmux.conf ~/.tmux.conf

# tmuxinator 設定をコピー
mkdir -p ~/.tmuxinator
cp /path/to/dotfiles/ai_dev/sample/tmuxinator/ai-dev.yml ~/.tmuxinator/

# セッション開始
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

#### `.tmux.conf`
- マウスサポート有効
- Vim スタイルのペイン移動（Ctrl+hjkl）
- 256 色サポート

#### `tmuxinator/ai-dev.yml`
- 4 ウィンドウ構成:
  1. compose: Docker Compose 起動
  2. aider: AI リファクタリング実行
  3. test: CI/テスト実行
  4. monitor: PR ステータス監視

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
`~/.tmuxinator/ai-dev.yml` を編集してペイン構成をカスタマイズ

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
