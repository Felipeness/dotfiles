# Powerlevel10k instant prompt — deve ficar no topo
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  node
  npm
  docker
  docker-compose
  sudo
  extract
  colored-man-pages
  history-substring-search
  dirhistory
  copypath
  common-aliases
  fzf
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# PATH local
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="cursor --wait"

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Aliases — navegação
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias ..="cd .."
alias ...="cd ../.."

# Aliases — git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"

# Aliases — dev
alias ni="npm install"
alias bi="bun install"
alias dev="bun run dev"
alias build="bun run build"

# Aliases — docker
alias dps="docker ps"
alias dcu="docker compose up -d"
alias dcd="docker compose down"

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=dark"
export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# zoxide (substitui cd com inteligência)
eval "$(zoxide init zsh)"
alias cd="z"

# bat (substitui cat com syntax highlight)
alias cat="bat --paging=never"

# eza (substitui ls com ícones e cores)
alias ll="eza -lah --icons --git --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias ls="eza --icons --group-directories-first"
alias tree="eza --tree --icons"

# history-substring-search — setas para cima/baixo buscam no histórico
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Load p10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
