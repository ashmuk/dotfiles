# Vim プラグイン チートシート

## 📝 基本ユーティリティ

### 1. [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot)
- **概要**: 多数のプログラミング言語のシンタックス/インデントをまとめたパック  
- **コマンド例**: 特になし（自動で有効）

---

### 2. [tpope/vim-sensible](https://github.com/tpope/vim-sensible)
- **概要**: 実用的なデフォルト設定集  
- **コマンド例**: 特になし（設定が自動適用）

---

## 🔍 検索・ナビゲーション

### 3. [junegunn/fzf](https://github.com/junegunn/fzf)  
- **概要**: 高速ファジーファインダー（CLI）  
- **例**:  
  ```sh
  fzf
  ```

### 4. [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)  
- **概要**: fzf の Vim フロントエンド  
- **コマンド例**:  
  - `:Files` → ファイル検索  
  - `:Buffers` → バッファ検索  
  - `:Rg <pattern>` → ripgrep 検索  

---

### 5. [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion)  
- **概要**: 高速移動補助、候補にジャンプラベルを表示  
- **キーマップ例**:  
  - `<Leader><Leader>w` → 次の単語にジャンプ  
  - `<Leader><Leader>fX` → 文字 `X` にジャンプ  

---

### 6. [preservim/nerdtree](https://github.com/preservim/nerdtree)  
- **概要**: Vim 内ファイラ  
- **コマンド例**:  
  - `:NERDTreeToggle` → ツリー表示のオン/オフ  

---

## 🎨 見た目・UI

### 7. [altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)  
- **概要**: Solarized カラースキーム  
- **コマンド例**:  
  ```vim
  :colorscheme solarized
  ```

### 8. [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline)  
- **概要**: 軽量ステータスライン/タブライン  
- **設定例**:  
  ```vim
  let g:airline_powerline_fonts = 1
  ```

### 9. [vim-airline/vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)  
- **概要**: airline 用のテーマ集  
- **コマンド例**:  
  ```vim
  let g:airline_theme='solarized'
  ```

---

## ⚙️ 開発補助

### 10. [dense-analysis/ale](https://github.com/dense-analysis/ale)  
- **概要**: 非同期 Lint / 補完フレームワーク  
- **コマンド例**:  
  - `:ALEFix` → 自動修正  
  - `:ALELint` → 手動 lint 実行  

---

### 11. [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)  
- **概要**: Git インターフェース  
- **コマンド例**:  
  - `:Gstatus` → git status  
  - `:Gdiffsplit` → diff 分割  
  - `:Gblame` → blame 表示  

---

### 12. [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)  
- **概要**: Git diff を sign column に表示  
- **キーマップ例**:  
  - `[c` → 前の変更へ移動  
  - `]c` → 次の変更へ移動  

---

### 13. [tpope/vim-commentary](https://github.com/tpope/vim-commentary)  
- **概要**: コメントのトグル  
- **キーマップ例**:  
  - `gc` + motion → コメント化  
  - `gcc` → 行コメント  

---

### 14. [tpope/vim-surround](https://github.com/tpope/vim-surround)  
- **概要**: 囲み文字の追加・変更・削除  
- **キーマップ例**:  
  - `ysiw"` → 単語を `"` で囲む  
  - `cs"'` → `"` を `'` に変更  
  - `ds"` → `"` を削除  

---

### 15. [tpope/vim-repeat](https://github.com/tpope/vim-repeat)  
- **概要**: `.` でカスタムマッピングもリピート可能に  
- **例**: surround/commentary 操作を `.` で繰り返せる

---

### 16. [jiangmiao/auto-pairs](https://github.com/jiangmiao/auto-pairs)  
- **概要**: 括弧やクォートを自動補完  
- **例**: `(` を打つと `)` が自動補完される  

---

### 17. [godlygeek/tabular](https://github.com/godlygeek/tabular)  
- **概要**: 整形・整列補助  
- **コマンド例**:  
  - `:Tabularize /=` → `=` で揃える  

---

## 📌 まとめ

- **tpope 系**: repeat, commentary, surround, sensible, fugitive → Vim 強化の定番  
- **fzf 系**: fzf, fzf.vim → 爆速検索  
- **UI 系**: airline, airline-themes, colors-solarized, gitgutter → 見やすさ改善  
- **補助系**: autopairs, tabular, easymotion, nerdtree → 編集・移動を快適化  
- **Lint/Git**: ale, fugitive, gitgutter → 開発者向けツール群  
