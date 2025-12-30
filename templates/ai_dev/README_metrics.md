# Aider API Usage Metrics

API使用量とコストを追跡・監視するためのメトリクスシステム。

---

## 概要

このメトリクスシステムは、Aider を使用した AI 開発セッションの以下の情報を自動的に収集・分析します：

- **トークン使用量**: 入力/出力トークン数
- **API コスト**: モデル別の実際のコスト（USD）
- **セッション時間**: 開始から終了までの時間
- **コード変更**: コミット数、変更ファイル数
- **モデル使用状況**: 使用した LLM モデルの種類

---

## 構成ファイル

| ファイル | 用途 | 配置場所 |
|---------|------|---------|
| `bin/aider-with-metrics` | Aider ラッパースクリプト（メトリクス収集） | `~/dotfiles/bin/` |
| `bin/aider-metrics` | メトリクス表示・分析ツール | `~/dotfiles/bin/` |
| `.metrics/aider_usage.jsonl` | メトリクスデータ（JSONL形式） | プロジェクトルート |

---

## 使い方

### 1. セットアップ

メトリクス収集スクリプトは `~/dotfiles/bin/` に配置されています。PATH に追加されていることを確認してください。

```bash
# PATH の確認
echo $PATH | grep -q "$HOME/dotfiles/bin" && echo "OK" || echo "Add to PATH"

# ~/.zshrc または ~/.bashrc に追加（必要な場合）
export PATH="$HOME/dotfiles/bin:$PATH"
```

### 2. Aider の実行（メトリクス付き）

通常の `aider` コマンドの代わりに `aider-with-metrics` を使用：

```bash
# 対話モード
aider-with-metrics

# 非対話モード（バッチ実行）
aider-with-metrics --message "リファクタリング" --yes

# モデル指定
aider-with-metrics --model claude-4.5-sonnet
```

または、Makefile 経由で実行（自動的にメトリクス収集）：

```bash
make aider-plan       # 計画作成（メトリクス付き）
make aider-refactor   # リファクタリング（メトリクス付き）
```

### 3. メトリクスの表示

```bash
# サマリー表示（デフォルト）
make metrics
# または
aider-metrics summary

# 今日の使用量
make metrics-today
# または
aider-metrics today

# 今週の使用量
aider-metrics week

# リアルタイム監視（5秒ごとに更新）
make metrics-watch
# または
aider-metrics watch
```

### 4. メトリクスのエクスポート

```bash
# CSV ファイルにエクスポート
make metrics-export
# または
aider-metrics export

# 出力先: .metrics/aider_usage.csv
```

---

## メトリクス項目

### 収集されるデータ

各セッションで以下のデータが `.metrics/aider_usage.jsonl` に記録されます：

```json
{
  "timestamp": "2025-10-10T12:34:56Z",
  "session_id": "20251010_123456_12345",
  "model": "claude-4.5-sonnet",
  "duration_seconds": 300,
  "input_tokens": 1500,
  "output_tokens": 800,
  "total_tokens": 2300,
  "cost_usd": 0.0165,
  "commits": 2,
  "files_modified": 5,
  "exit_code": 0
}
```

### 表示される統計

`aider-metrics summary` で表示される統計：

- **Total Sessions**: 総セッション数
- **Total Duration**: 総実行時間（秒、時間分表示）
- **Total Tokens**: 総トークン数（入力/出力/合計）
- **Total Cost**: 総コスト（USD）
- **Average Cost/Session**: セッションあたりの平均コスト
- **Total Commits**: 総コミット数
- **Total Files Modified**: 総変更ファイル数
- **Models Used**: 使用したモデルのリスト
- **Recent Sessions**: 最近の5セッション

---

## tmuxinator 統合

AI 開発テンプレート（`ai-dev.yml`）には、メトリクス監視用のペインが自動的に含まれます：

```bash
# tmuxinator で AI 開発セッション起動
tmuxinator start ai-dev
```

**ペイン構成**:
- **Window 2 (aider)**: Aider 実行ペイン（メトリクス収集有効）
- **Window 4 (monitor)**: メトリクス監視ペイン（10秒ごとに自動更新）

---

## コスト計算

### サポートされるモデルと価格（1M トークンあたり）

| モデル | 入力 | 出力 |
|--------|------|------|
| claude-4.5-sonnet | $3.00 | $15.00 |
| claude-3-5-sonnet-20241022 | $3.00 | $15.00 |
| gpt-4-turbo | $10.00 | $30.00 |
| gpt-4o | $5.00 | $15.00 |
| gpt-3.5-turbo | $0.50 | $1.50 |

**価格の更新方法**:

`bin/aider-with-metrics` の以下の部分を編集：

```bash
declare -A INPUT_PRICES=(
    ["model-name"]="price_per_1m_tokens"
)

declare -A OUTPUT_PRICES=(
    ["model-name"]="price_per_1m_tokens"
)
```

---

## 環境変数

### aider-with-metrics

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `METRICS_DIR` | メトリクス保存ディレクトリ | `./.metrics` |
| `AIDER_MODEL` | 使用するモデル名 | `claude-4.5-sonnet` |

### aider-metrics

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `METRICS_DIR` | メトリクス読み込みディレクトリ | `./.metrics` |

---

## トラブルシューティング

### "No metrics file found"

メトリクスファイルがまだ作成されていません：

```bash
# 初回実行
aider-with-metrics --message "test" --yes
```

### "jq is required"

`jq` がインストールされていません：

```bash
# macOS
brew install jq

# DevContainer 内
apt-get update && apt-get install -y jq
```

### メトリクスが記録されない

1. `aider-with-metrics` を使用していることを確認
2. `.metrics/` ディレクトリの書き込み権限を確認
3. Aider の出力にトークン情報が含まれているか確認

```bash
# デバッグモード
aider-with-metrics --message "test" --yes --verbose
```

### コストが正確でない

1. モデル名が正しいか確認（`--model` オプション）
2. 価格表が最新か確認（`bin/aider-with-metrics` 内の `INPUT_PRICES`/`OUTPUT_PRICES`）
3. Aider のバージョンが最新か確認

---

## 高度な使用例

### プロジェクト別メトリクス

```bash
# プロジェクトごとにメトリクスディレクトリを分ける
export METRICS_DIR=~/metrics/project-a
aider-with-metrics

export METRICS_DIR=~/metrics/project-b
aider-with-metrics
```

### CI/CD での使用

```bash
# 非対話モードでメトリクス収集
aider-with-metrics --message "自動リファクタリング" --yes

# メトリクスを確認
if [ -f .metrics/aider_usage.jsonl ]; then
  # コスト上限チェック（例: $1.00）
  TOTAL_COST=$(aider-metrics summary | grep "Total Cost" | awk '{print $3}' | tr -d '$')
  if (( $(echo "$TOTAL_COST > 1.0" | bc -l) )); then
    echo "Warning: Cost exceeded $1.00"
  fi
fi
```

### 週次レポート

```bash
# cron で週次レポートをメール送信
0 9 * * 1 cd /path/to/project && aider-metrics week | mail -s "Weekly Aider Usage" team@example.com
```

---

## 参考リソース

- [Aider 公式ドキュメント](https://aider.chat/)
- [Anthropic API Pricing](https://www.anthropic.com/pricing)
- [OpenAI API Pricing](https://openai.com/pricing)

---

**Last Updated**: 2025-10-10
