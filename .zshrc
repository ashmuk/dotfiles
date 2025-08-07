# --------------------------------------------
# PATH 設定
# --------------------------------------------
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/bin:$PATH"

# Homebrew (Intel/macOS 用) 調整
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# --------------------------------------------
# 環境変数
# --------------------------------------------
export EDITOR="mvim"
export LANG=ja_JP.UTF-8

# --------------------------------------------
# ヒストリ設定
# --------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history

# --------------------------------------------
# 補完機能の有効化
# --------------------------------------------
autoload -Uz compinit
compinit

# --------------------------------------------
# 補完表示をメニュー形式に
# --------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# --------------------------------------------
# プロンプト設定（シンプル）
# %n = ユーザ名, %m = ホスト名, %~ = カレントディレクトリ
#PROMPT="%F{green}%n@%m%f:%F{blue}%~%f %# "

# zsh のプロンプト設定（色つき・2行構成）
ZSH_VER=$(zsh --version | head -n1 | awk '{print $2}')
PROMPT="%F{green}bash-${ZSH_VER}-%n %F{yellow}%~%f"

# --------------------------------------------
# エイリアス
# --------------------------------------------
alias ll='ls -lah'
alias gs='git status'
alias ..='cd ..'
alias updatebrew='brew update && brew upgrade && brew cleanup'

# --------------------------------------------
# オプション設定（bashにない zsh 独自）
# --------------------------------------------
setopt autocd             # cd コマンドなしでディレクトリ移動
setopt correct            # コマンドのスペル修正
setopt no_beep            # ビープ音を無効
setopt interactive_comments  # コメントをコマンドラインでも許可

# --------------------------------------------
# Oh My Zsh を使っている場合、下記のラインを .zshrc 側で調整
# --------------------------------------------
#export ZSH="$HOME/.oh-my-zsh"
#ZSH_THEME="robbyrussell"  # テーマ例：agnoster, powerlevel10k, etc
#plugins=(git docker)
#source $ZSH/oh-my-zsh.sh

