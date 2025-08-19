# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# 基本的なzshの設定は下記ファイルにて管理・実行する
source $HOME/.zshrc_first

# Added by Mukai
# Enable plugins installed by homebrew ... -> This is not really necessary as installed by git clone instead
# See the installation in the folder: $HOME/.oh-my-zsh/custom/plugins
#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
# Added by Mukai
plugins=(
  git
  z
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# ------------------------------------------------------------------------------
# Added by Mukai
# ------------------------------------------------------------------------------
# zsh のプロンプト設定（色つき・2行構成）
ZSH_VER=$(zsh --version | head -n1 | awk '{print $2}')
PROMPT_BASE="%F{cyan}zsh-${ZSH_VER}-%n %F{green}%~%f"$'\n'"%# "
PROMPT="%F{green}[INSERT]%f $PROMPT_BASE"

# vi モードを有効にする
bindkey -v

# プロンプトに vi モードのインジケータを表示（オプション）
function zle-keymap-select {
  case $KEYMAP in
    vicmd) PROMPT="%F{red}[NORMAL]%f $PROMPT_BASE" ;;
    main|viins) PROMPT="%F{green}[INSERT]%f $PROMPT_BASE" ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select

# ~/.zshrc の末尾に追記（例：bash ログアウト後にも、ちゃんとzsh向け設定に戻す）
# 実際には、.bashrc の最後尾に同処理をexitコマンドにtrapしている
if [[ -f "$HOME/etc/mintty-colors-solarized/sol.light" ]]; then
  source "$HOME/etc/mintty-colors-solarized/sol.light"
fi

# Git aliases
# 基本コマンド
alias g='git'
alias gs='git status' # git status --short is defined by Oh!MyZsh instead
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'

# ブランチ関連
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'

# ログとdiff
alias gl='git log'
alias glo='git log --oneline'
alias gd='git diff'
alias gds='git diff --staged'

# リモート関連
alias gr='git remote'
alias grv='git remote -v'

# その他便利なもの
alias gst='git stash'
alias gstp='git stash pop'
alias grh='git reset HEAD'
alias grhh='git reset --hard HEAD'

# 複合コマンド
alias gacp='git add . && git commit -m'
alias gpom='git push origin main'
alias gplom='git pull origin main'

# ログを見やすく
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

# ブランチ切り替えを簡単に
alias gmain='git checkout main'
alias gdev='git checkout develop'

# For pushd, popd and dirs
alias pu='pushd'
alias pd='popd'
alias ds='dirs -v'
