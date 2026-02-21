#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "\n${BLUE}==>${RESET} ${BOLD}$1${RESET}"; }
success() { echo -e "  ${GREEN}✔${RESET} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
error()   { echo -e "  ${RED}✘${RESET} $1"; exit 1; }
skip()    { echo -e "  ${CYAN}↩${RESET} $1 (já instalado)"; }

echo -e "
${CYAN}${BOLD}
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
${RESET}
 ${BOLD}by Felipe Coelho${RESET} — https://github.com/Felipeness
"

[[ "$OS" != "Linux" ]] && error "Este script suporta apenas Linux (Ubuntu/Debian)."

# ─── Dependências base ───────────────────────────────────────────────────────
log "Dependências base"
sudo apt-get update -qq
sudo apt-get install -y \
  zsh git curl wget unzip gpg \
  fzf zoxide bat eza \
  build-essential ca-certificates \
  apt-transport-https software-properties-common 2>&1 | grep -E "^Configurando" || true
success "Dependências instaladas"

# ─── ZSH ─────────────────────────────────────────────────────────────────────
log "ZSH"
if [[ "$SHELL" != "$(which zsh)" ]]; then
  sudo chsh -s "$(which zsh)" "$USER"
  success "ZSH definido como shell padrão"
else
  skip "ZSH já é o shell padrão"
fi

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
log "Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "Oh My Zsh instalado"
else
  skip "Oh My Zsh"
fi

# ─── Plugins ZSH ─────────────────────────────────────────────────────────────
log "Plugins ZSH"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A PLUGINS=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
  ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
)

for plugin in "${!PLUGINS[@]}"; do
  if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
    git clone "${PLUGINS[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin" --quiet
    success "Plugin $plugin instalado"
  else
    skip "$plugin"
  fi
done

# ─── Powerlevel10k ───────────────────────────────────────────────────────────
log "Powerlevel10k"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k" --quiet
  success "Powerlevel10k instalado"
else
  skip "Powerlevel10k"
fi

# ─── Fontes ──────────────────────────────────────────────────────────────────
log "Fontes"
FONTS_DIR="$HOME/.local/share/fonts"

if [[ ! -d "$FONTS_DIR/JetBrainsMono" ]]; then
  mkdir -p "$FONTS_DIR/JetBrainsMono"
  curl -fsSL "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" \
    -o /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip "fonts/ttf/*.ttf" -d /tmp/JetBrainsMono/ -q
  cp /tmp/JetBrainsMono/fonts/ttf/*.ttf "$FONTS_DIR/JetBrainsMono/"
  fc-cache -f "$FONTS_DIR"
  success "JetBrains Mono instalada"
else
  skip "JetBrains Mono"
fi

if [[ ! -d "$FONTS_DIR/MapleMono" ]]; then
  warn "Maple Mono NF não encontrada — baixe em: https://github.com/subframe7536/maple-font/releases"
  warn "Extraia em: $FONTS_DIR/MapleMono/ e execute: fc-cache -f $FONTS_DIR"
else
  skip "Maple Mono NF"
fi

# ─── Ghostty ─────────────────────────────────────────────────────────────────
log "Ghostty"
if ! command -v ghostty &>/dev/null; then
  sudo snap install ghostty --classic
  success "Ghostty instalado"
else
  skip "Ghostty $(ghostty --version 2>/dev/null | head -1)"
fi

# ─── Node.js ─────────────────────────────────────────────────────────────────
log "Node.js"
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs 2>&1 | grep "^Configurando" || true
  success "Node.js $(node --version) instalado"
else
  skip "Node.js $(node --version)"
fi

# ─── Bun ─────────────────────────────────────────────────────────────────────
log "Bun"
if [[ ! -f "$HOME/.bun/bin/bun" ]]; then
  curl -fsSL https://bun.sh/install | bash 2>/dev/null
  success "Bun instalado"
else
  skip "Bun $($HOME/.bun/bin/bun --version)"
fi

# ─── npm globals ─────────────────────────────────────────────────────────────
log "Ferramentas npm globais"
npm install -g typescript ts-node eslint prettier 2>/dev/null
success "TypeScript, ts-node, ESLint, Prettier"

# ─── Python ──────────────────────────────────────────────────────────────────
log "Python"
if command -v python3 &>/dev/null; then
  skip "Python $(python3 --version)"
else
  sudo apt-get install -y python3 python3-pip 2>&1 | grep "^Configurando" || true
  success "Python instalado"
fi

# ─── Go ──────────────────────────────────────────────────────────────────────
log "Go"
if [[ ! -d "/usr/local/go" ]]; then
  curl -fsSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o /tmp/go.tar.gz
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  success "Go 1.24.0 instalado"
else
  skip "Go $(/usr/local/go/bin/go version)"
fi

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

log "Ferramentas Go"
go install golang.org/x/tools/gopls@latest 2>/dev/null        && success "gopls"
go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null && success "dlv"
go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null && success "goimports"
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null && success "golangci-lint"

# ─── Docker ──────────────────────────────────────────────────────────────────
log "Docker"
if command -v docker &>/dev/null; then
  skip "Docker $(docker --version)"
else
  warn "Docker não encontrado — instale em: https://docs.docker.com/engine/install/ubuntu/"
fi

# ─── PostgreSQL ──────────────────────────────────────────────────────────────
log "PostgreSQL"
if command -v psql &>/dev/null; then
  skip "PostgreSQL $(psql --version)"
else
  sudo apt-get install -y postgresql postgresql-contrib 2>&1 | grep "^Configurando" || true
  success "PostgreSQL instalado"
fi

# ─── Redis ───────────────────────────────────────────────────────────────────
log "Redis"
if command -v redis-cli &>/dev/null; then
  skip "Redis $(redis-cli --version)"
else
  sudo apt-get install -y redis-server 2>&1 | grep "^Configurando" || true
  sudo systemctl enable --now redis-server 2>/dev/null || true
  success "Redis instalado"
fi

# ─── MongoDB ─────────────────────────────────────────────────────────────────
log "MongoDB"
if command -v mongod &>/dev/null; then
  skip "MongoDB $(mongod --version | head -1)"
else
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc \
    | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
    | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  sudo apt-get update -qq && sudo apt-get install -y mongodb-org 2>&1 | grep "^Configurando" || true
  sudo systemctl enable --now mongod
  success "MongoDB instalado"
fi

# ─── Kubernetes tools ────────────────────────────────────────────────────────
log "kubectl"
if ! command -v kubectl &>/dev/null; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
  sudo apt-get update -qq && sudo apt-get install -y kubectl 2>&1 | grep "^Configurando" || true
  success "kubectl instalado"
else
  skip "kubectl $(kubectl version --client --short 2>/dev/null)"
fi

log "Helm"
if ! command -v helm &>/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>/dev/null
  success "Helm instalado"
else
  skip "Helm $(helm version --short)"
fi

log "k9s"
if ! command -v k9s &>/dev/null; then
  curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz \
    -o /tmp/k9s.tar.gz
  tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
  sudo mv /tmp/k9s /usr/local/bin/
  success "k9s instalado"
else
  skip "k9s"
fi

log "minikube"
if ! command -v minikube &>/dev/null; then
  curl -fsSL https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /tmp/minikube
  sudo install /tmp/minikube /usr/local/bin/minikube
  minikube config set driver docker 2>/dev/null
  minikube config set cpus 2 2>/dev/null
  minikube config set memory 4096 2>/dev/null
  success "minikube instalado"
else
  skip "minikube $(minikube version --short 2>/dev/null)"
fi

# ─── Terraform ───────────────────────────────────────────────────────────────
log "Terraform"
if ! command -v terraform &>/dev/null; then
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update -qq && sudo apt-get install -y terraform 2>&1 | grep "^Configurando" || true
  success "Terraform instalado"
else
  skip "$(terraform version | head -1)"
fi

# ─── Ansible ─────────────────────────────────────────────────────────────────
log "Ansible"
if ! command -v ansible &>/dev/null; then
  sudo apt-get install -y ansible 2>&1 | grep "^Configurando" || true
  success "Ansible instalado"
else
  skip "$(ansible --version | head -1)"
fi

# ─── Temporal CLI ────────────────────────────────────────────────────────────
log "Temporal CLI"
if ! command -v temporal &>/dev/null; then
  curl -fsSL "https://temporal.download/cli/archive/latest?platform=linux&arch=amd64" \
    -o /tmp/temporal.tar.gz
  tar -xzf /tmp/temporal.tar.gz -C /tmp
  sudo mv /tmp/temporal /usr/local/bin/
  success "Temporal CLI instalado"
else
  skip "$(temporal -v 2>&1 | head -1)"
fi

# ─── Cursor extensions ───────────────────────────────────────────────────────
log "Cursor IDE — extensões"
if command -v cursor &>/dev/null; then
  while IFS= read -r ext; do
    [[ "$ext" =~ ^#.*$ || -z "$ext" ]] && continue
    cursor --install-extension "$ext" 2>/dev/null | grep -E "successfully installed|already installed" \
      | sed "s/Extension '${ext}' v.*/  ✔ ${ext}/" || true
  done < "$DOTFILES_DIR/cursor/extensions.txt"
  success "Extensões instaladas"
else
  warn "Cursor IDE não encontrado — instale em: https://cursor.com/downloads"
fi

# ─── Symlinks ────────────────────────────────────────────────────────────────
log "Symlinks"

symlink() {
  local src="$DOTFILES_DIR/$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.bak-$(date +%Y%m%d%H%M%S)"
    warn "Backup: $dst.bak-*"
  fi
  ln -sf "$src" "$dst"
  success "$dst"
}

symlink "zsh/.zshrc"           "$HOME/.zshrc"
symlink "zsh/.p10k.zsh"        "$HOME/.p10k.zsh"
symlink "ghostty/config"       "$HOME/.config/ghostty/config"
symlink "cursor/settings.json" "$HOME/.config/Cursor/User/settings.json"
symlink "git/.gitconfig"       "$HOME/.gitconfig"

# ─── Git config ──────────────────────────────────────────────────────────────
log "Git"
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
if [[ -z "$GIT_NAME" ]]; then
  read -rp "  Nome para o Git: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [[ -z "$GIT_EMAIL" ]]; then
  read -rp "  Email para o Git: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi
success "Git configurado: $GIT_NAME <$GIT_EMAIL>"

# ─── SSH Key ─────────────────────────────────────────────────────────────────
log "SSH"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
  eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
  echo ""
  warn "Chave SSH gerada! Adicione ao GitHub:"
  echo ""
  cat ~/.ssh/id_ed25519.pub
  echo ""
else
  skip "Chave SSH já existe"
fi

# ─── Conclusão ───────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✔  Instalação concluída com sucesso!${RESET}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${CYAN}Próximos passos:${RESET}"
echo -e "  ${BOLD}1.${RESET} Reinicie o terminal: ${CYAN}exec zsh${RESET}"
echo -e "  ${BOLD}2.${RESET} Configure o prompt:  ${CYAN}p10k configure${RESET}"
echo -e "  ${BOLD}3.${RESET} Abra o Cursor IDE e aproveite! 🚀"
echo ""
