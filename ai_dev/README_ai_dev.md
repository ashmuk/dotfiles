# AI Development Environment - Setup Guide

このガイドでは、`./sample` 配下のサンプル設定ファイルを使用して、AI Agent × DevContainer × tmux 開発環境を構築する手順を説明します。

---

## 📋 目次

1. [概要](#概要)
2. [ファイル配置マップ](#ファイル配置マップ)
3. [セットアップ手順](#セットアップ手順)
4. [ファイル詳細](#ファイル詳細)
5. [トラブルシューティング](#トラブルシューティング)

---

## 概要

この環境では、以下の役割分担で開発を行います:

| 実行場所 | 役割 | 主なツール |
|---------|------|-----------|
| **ホスト (macOS)** | UI/対話、オーケストレーション | Cursor/VSCode, tmux, iTerm2 |
| **コンテナ (DevContainer)** | AI実行、CI/テスト | Aider, SWE-agent, pytest, ruff |

---

## ファイル配置マップ

### 🖥️ ホスト側に配置するファイル

| 設定ファイル | 配置先 | 用途 |
|----------------|--------|------|
| `config/tmux/tmux.conf` | `~/.tmux.conf` | tmux 設定（通常開発とAI開発の両方に対応） |
| `config/tmux/tmuxinator/ai-dev.yml` | `~/.tmuxinator/ai-dev.yml` | AI開発用 tmux セッションテンプレート |

**配置コマンド例:**
```bash
# tmux 設定をホームディレクトリに配置
cp ~/dotfiles/config/tmux/tmux.conf ~/.tmux.conf

# tmuxinator ディレクトリを作成して AI開発テンプレートを配置
mkdir -p ~/.tmuxinator
cp ~/dotfiles/config/tmux/tmuxinator/ai-dev.yml ~/.tmuxinator/
```

**参照元:**
- tmux: `~/.tmux.conf` を起動時に自動読み込み
- tmuxinator: `tmuxinator start ai-dev` 実行時に `~/.tmuxinator/ai-dev.yml` を参照

**AI開発ワークフローでの使用:**
- `tmux.conf` には通常開発とAI開発の両方で使える設定を統合
  - Vimスタイルのペイン移動（Ctrl+hjkl）
  - 256色・true colorサポート
  - ウィンドウ/ペイン番号を1から開始
  - ステータスバーにペイン番号表示
- `tmuxinator/ai-dev.yml` で4ペイン構成を自動起動
  - compose: Docker Compose起動
  - aider: AI リファクタリング
  - test: CI/テスト実行
  - monitor: PR ステータス監視

---

### 🐳 プロジェクトルートに配置するファイル（コンテナと共有）

| サンプルファイル | 配置先 | 主な参照元 |
|----------------|--------|-----------|
| `sample/devcontainer/` | `<project>/.devcontainer/` | VSCode/Cursor (Reopen in Container) |
| `sample/aider.conf.yml` | `<project>/.aider.conf.yml` | Aider (コンテナ内) |
| `sample/Makefile` | `<project>/Makefile` | ホスト/コンテナ両方 |
| `sample/env.example` | `<project>/.env` ※コピー後編集 | docker-compose (環境変数) |
| `sample/gitignore` | `<project>/.gitignore` | Git |
| `sample/pre-commit-config.yaml` | `<project>/.pre-commit-config.yaml` | pre-commit (コンテナ内) |
| `sample/github/workflows/ci.yml` | `<project>/.github/workflows/ci.yml` | GitHub Actions |

**注**: サンプルファイルは先頭のドット `.` を外した状態で保存されています。

**配置方法:**

### 方法1: ブートストラップスクリプト使用（推奨）
```bash
# プロジェクトルートに移動
cd ~/work/your-project

# スクリプトを実行（自動的にドット付きファイル名で展開）
~/dotfiles/ai_dev/sample/setup_ai_dev_sample.sh
```

### 方法2: 手動コピー
```bash
# プロジェクトルートに移動
cd ~/work/your-project

# DevContainer 設定
cp -r ~/dotfiles/ai_dev/sample/devcontainer .devcontainer

# AI/開発ツール設定
cp ~/dotfiles/ai_dev/sample/aider.conf.yml .aider.conf.yml
cp ~/dotfiles/ai_dev/sample/Makefile .
cp ~/dotfiles/ai_dev/sample/gitignore .gitignore
cp ~/dotfiles/ai_dev/sample/pre-commit-config.yaml .pre-commit-config.yaml

# 環境変数（.envは編集が必要）
cp ~/dotfiles/ai_dev/sample/env.example .env

# GitHub Actions
mkdir -p .github/workflows
cp ~/dotfiles/ai_dev/sample/github/workflows/ci.yml .github/workflows/
```

---

### 📂 ディレクトリマッピング

DevContainer 起動時、以下のようにディレクトリがマウントされます:

```
ホスト側                        コンテナ内
~/work/your-project      →     /work (bind-mount, read-write)
  ├── .devcontainer/            ├── .devcontainer/
  ├── .aider.conf.yml           ├── .aider.conf.yml
  ├── Makefile                  ├── Makefile
  ├── .env                      ├── .env (環境変数として読み込み)
  ├── src/                      ├── src/
  └── tests/                    └── tests/
```

**重要ポイント:**
- ホスト側の変更は即座にコンテナ内に反映される（bind-mount）
- コンテナ内で編集したファイルもホスト側で確認・レビュー可能
- `.env` ファイルは docker-compose.yml で環境変数として展開される

---

## セットアップ手順

### ステップ 1: ホスト側の設定

```bash
# tmux 設定をホームディレクトリに配置
cp ~/dotfiles/config/tmux/tmux.conf ~/.tmux.conf

# tmuxinator 設定（AI開発用テンプレート）
mkdir -p ~/.tmuxinator
cp ~/dotfiles/config/tmux/tmuxinator/ai-dev.yml ~/.tmuxinator/

# tmux 設定を再読み込み（既存セッションがある場合）
tmux source-file ~/.tmux.conf
```

### ステップ 2: プロジェクトへの設定ファイル配置

```bash
# プロジェクトディレクトリへ移動
cd ~/work/your-project

# ブートストラップスクリプトを実行（推奨）
~/dotfiles/ai_dev/sample/setup_ai_dev_sample.sh
```

スクリプトは以下を自動的に行います:
- 既存ファイルのバックアップ
- 設定ファイルの配置（適切なドット付きファイル名で）
- `.env` ファイルの作成
- 次のステップの表示

### ステップ 3: 環境変数の設定

```bash
# .env ファイルを編集して API キーを設定
vim .env

# 以下のキーを設定
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...
# GITHUB_TOKEN=ghp_...
```

### ステップ 4: DevContainer で開く

**VSCode/Cursor の場合:**
1. プロジェクトを開く
2. コマンドパレット（Cmd+Shift+P）を開く
3. `Dev Containers: Reopen in Container` を実行

コンテナビルドが完了すると、以下がインストール済みの状態で起動します:
- Python 3.11
- Aider, Ruff, pytest, pre-commit
- GitHub CLI (gh), act
- tmux, zsh

### ステップ 5: tmux セッションの起動（ホスト側）

```bash
# tmuxinator でセッション起動
tmuxinator start ai-dev
```

以下の 4 ペイン構成で起動します:
1. **compose**: `docker compose up`
2. **aider**: `devcontainer exec make aider-refactor`
3. **test**: `devcontainer exec make ci-local`
4. **monitor**: `gh pr status --watch`

---

## ファイル詳細

### ホスト側ファイル

#### `~/.tmux.conf`
**参照元**: tmux（ホスト側で起動時）

```bash
# マウス有効化、Vim キーバインド、ペイン分割設定など
set -g mouse on
setw -g mode-keys vi
```

**カスタマイズポイント:**
- ステータスバーの色（`status-bg`, `status-fg`）
- ペイン移動キーバインド（デフォルト: Ctrl+hjkl）

#### `~/.tmuxinator/ai-dev.yml`
**参照元**: tmuxinator コマンド

```yaml
name: ai-dev
root: ~/work/repo  # プロジェクトパスに変更
windows:
  - name: compose
    panes:
      - docker compose up
```

**カスタマイズポイント:**
- `root`: 自分のプロジェクトパスに変更
- `windows`/`panes`: 必要なペイン構成に調整

---

### プロジェクトルート配置ファイル

#### `.devcontainer/devcontainer.json`
**参照元**: VSCode/Cursor（Reopen in Container 実行時）

```jsonc
{
  "name": "ai-devbox",
  "service": "dev",
  "workspaceFolder": "/work"  // コンテナ内の作業ディレクトリ
}
```

**カスタマイズポイント:**
- `extensions`: プロジェクトに必要な VSCode 拡張を追加
- `runArgs`: セキュリティ設定を調整

#### `.devcontainer/Dockerfile`
**参照元**: docker-compose.yml（ビルド時）

```dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/python:3.11
RUN pip install aider-chat ruff pytest
```

**カスタマイズポイント:**
- ベースイメージのバージョン
- 追加パッケージのインストール

#### `.devcontainer/docker-compose.yml`
**参照元**: devcontainer.json

```yaml
services:
  dev:
    environment:
      - OPENAI_API_KEY      # .env から読み込み
      - ANTHROPIC_API_KEY
    profiles: [default]     # デフォルトプロファイル
  dev-nonet:
    network_mode: "none"    # ネットワーク遮断
    profiles: ["no-net"]
```

**プロファイル切り替え:**
```bash
# デフォルト（LLM API 接続可）
docker compose up

# no-net（オフライン、静的解析のみ）
docker compose --profile no-net up
```

#### `.aider.conf.yml`
**参照元**: Aider（コンテナ内実行時）

```yaml
model: claude-4.5-sonnet
auto_commit: true
```

**カスタマイズポイント:**
- `model`: 使用する LLM モデル
- `ignore`: Aider に渡さないファイル/ディレクトリ

#### `Makefile`
**参照元**: ホスト/コンテナ両方

```makefile
aider-refactor:
	aider --message "src配下をリファクタ" --yes
```

**実行方法:**
```bash
# コンテナ内
make aider-refactor

# ホストから
docker compose exec dev make aider-refactor
# または
devcontainer exec make aider-refactor
```

#### `.env`
**参照元**: docker-compose.yml（環境変数展開）

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
OPENAI_API_KEY=sk-xxxxx
GITHUB_TOKEN=ghp_xxxxx
```

**重要**:
- `.gitignore` に含まれていることを必ず確認
- API キーは定期的にローテーション

#### `.pre-commit-config.yaml`
**参照元**: pre-commit（コンテナ内、git commit 時）

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    hooks:
      - id: ruff
```

**セットアップ:**
```bash
# コンテナ内で実行
pre-commit install
```

#### `.github/workflows/ci.yml`
**参照元**: GitHub Actions（リモート）

```yaml
on:
  pull_request:
    branches: [main]
```

**ローカル実行:**
```bash
# act でローカル再現（コンテナ内）
make ci-local
# または
act pull_request -j check
```

---

## トラブルシューティング

### Q1: tmux 設定が反映されない

```bash
# 設定を再読み込み
tmux source-file ~/.tmux.conf

# または tmux を再起動
tmux kill-server
tmux
```

### Q2: devcontainer で .env が読み込まれない

```bash
# .env ファイルがプロジェクトルートにあるか確認
ls -la .env

# docker-compose.yml で環境変数が定義されているか確認
grep -A 3 "environment:" .devcontainer/docker-compose.yml

# コンテナ再ビルド
docker compose down
docker compose build --no-cache
```

### Q3: Aider が API キーを認識しない

```bash
# コンテナ内で環境変数を確認
echo $ANTHROPIC_API_KEY

# .env ファイルが正しく設定されているか確認（ホスト側）
cat .env | grep ANTHROPIC_API_KEY

# docker-compose を再起動
docker compose restart
```

### Q4: tmuxinator が ai-dev.yml を見つけられない

```bash
# ファイルが正しい場所にあるか確認
ls -l ~/.tmuxinator/ai-dev.yml

# tmuxinator の設定一覧を確認
tmuxinator list

# YAML の文法エラーをチェック
tmuxinator debug ai-dev
```

### Q5: pre-commit フックが動かない

```bash
# コンテナ内で pre-commit をインストール
pre-commit install

# 手動実行してエラーを確認
pre-commit run --all-files
```

### Q6: act（GitHub Actions ローカル実行）が失敗する

```bash
# Docker イメージサイズの問題の場合、medium イメージを使用
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# 特定ジョブのみ実行
act -j check

# ドライラン（実行せず確認のみ）
act -n
```

---

## 参考リソース

- [Architecture Guide](./README_ai_dev_arch.md) - システム全体の設計思想
- [Sample Files](./sample/) - 全設定ファイルのサンプル
- [Aider Documentation](https://aider.chat/)
- [DevContainers Specification](https://containers.dev/)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)

---

**Last Updated**: 2025-10-09
