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

log()     { echo -e "${BLUE}==>${RESET} ${BOLD}$1${RESET}"; }
success() { echo -e "${GREEN}✔${RESET} $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
error()   { echo -e "${RED}✘${RESET} $1"; exit 1; }

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

if [[ "$OS" != "Linux" ]]; then
  error "Este script suporta apenas Linux."
fi

# ─── Dependências base ───────────────────────────────────────────────────────
log "Instalando dependências base..."
sudo apt-get update -qq
sudo apt-get install -y \
  zsh git curl wget unzip \
  fzf zoxide bat eza \
  build-essential 2>&1 | grep -E "^Configurando|^Instalando" || true
success "Dependências instaladas"

# ─── ZSH como shell padrão ───────────────────────────────────────────────────
log "Configurando ZSH como shell padrão..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
  sudo chsh -s "$(which zsh)" "$USER"
  success "ZSH definido como shell padrão"
else
  success "ZSH já é o shell padrão"
fi

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
log "Instalando Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "Oh My Zsh instalado"
else
  success "Oh My Zsh já instalado"
fi

# ─── Plugins ZSH ─────────────────────────────────────────────────────────────
log "Instalando plugins do ZSH..."
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
    success "Plugin $plugin já instalado"
  fi
done

# ─── Powerlevel10k ───────────────────────────────────────────────────────────
log "Instalando Powerlevel10k..."
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k" --quiet
  success "Powerlevel10k instalado"
else
  success "Powerlevel10k já instalado"
fi

# ─── Fontes ──────────────────────────────────────────────────────────────────
log "Instalando JetBrains Mono..."
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
  success "JetBrains Mono já instalada"
fi

# ─── Go ──────────────────────────────────────────────────────────────────────
log "Instalando Go..."
if [[ ! -d "/usr/local/go" ]]; then
  curl -fsSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o /tmp/go.tar.gz
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  success "Go 1.24.0 instalado"
else
  success "Go já instalado: $(/usr/local/go/bin/go version)"
fi

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

log "Instalando ferramentas Go..."
go install golang.org/x/tools/gopls@latest 2>/dev/null
go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null
go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null
success "Ferramentas Go instaladas"

# ─── Bun ─────────────────────────────────────────────────────────────────────
log "Instalando Bun..."
if [[ ! -f "$HOME/.bun/bin/bun" ]]; then
  curl -fsSL https://bun.sh/install | bash 2>/dev/null
  success "Bun instalado"
else
  success "Bun já instalado: $($HOME/.bun/bin/bun --version)"
fi

# ─── Node.js ─────────────────────────────────────────────────────────────────
log "Verificando Node.js..."
if command -v node &>/dev/null; then
  success "Node.js já instalado: $(node --version)"
else
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs 2>&1 | grep "^Configurando" || true
  success "Node.js instalado: $(node --version)"
fi

# ─── Docker ──────────────────────────────────────────────────────────────────
log "Verificando Docker..."
if command -v docker &>/dev/null; then
  success "Docker já instalado: $(docker --version)"
else
  warn "Docker não encontrado — instale manualmente: https://docs.docker.com/engine/install/ubuntu/"
fi

# ─── kubectl + helm + k9s + minikube ─────────────────────────────────────────
log "Instalando ferramentas Kubernetes..."

if ! command -v kubectl &>/dev/null; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
  sudo apt-get update -qq && sudo apt-get install -y kubectl 2>&1 | grep "^Configurando" || true
  success "kubectl instalado"
else
  success "kubectl já instalado: $(kubectl version --client --short 2>/dev/null)"
fi

if ! command -v helm &>/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>/dev/null
  success "Helm instalado"
else
  success "Helm já instalado: $(helm version --short)"
fi

if ! command -v k9s &>/dev/null; then
  curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz \
    -o /tmp/k9s.tar.gz
  tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
  sudo mv /tmp/k9s /usr/local/bin/
  success "k9s instalado"
else
  success "k9s já instalado: $(k9s version --short 2>/dev/null | head -1)"
fi

if ! command -v minikube &>/dev/null; then
  curl -fsSL https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /tmp/minikube
  sudo install /tmp/minikube /usr/local/bin/minikube
  minikube config set driver docker 2>/dev/null
  minikube config set cpus 2 2>/dev/null
  minikube config set memory 4096 2>/dev/null
  success "minikube instalado"
else
  success "minikube já instalado: $(minikube version --short 2>/dev/null)"
fi

# ─── Temporal CLI ────────────────────────────────────────────────────────────
log "Instalando Temporal CLI..."
if ! command -v temporal &>/dev/null; then
  curl -fsSL "https://temporal.download/cli/archive/latest?platform=linux&arch=amd64" \
    -o /tmp/temporal.tar.gz
  tar -xzf /tmp/temporal.tar.gz -C /tmp
  sudo mv /tmp/temporal /usr/local/bin/
  success "Temporal CLI instalado"
else
  success "Temporal CLI já instalado: $(temporal -v 2>&1 | head -1)"
fi

# ─── Symlinks ────────────────────────────────────────────────────────────────
log "Criando symlinks das configurações..."

symlink() {
  local src="$DOTFILES_DIR/$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.backup-$(date +%Y%m%d%H%M%S)"
    warn "Backup criado: $dst.backup-*"
  fi
  ln -sf "$src" "$dst"
  success "Linked: $dst → $src"
}

symlink "zsh/.zshrc"              "$HOME/.zshrc"
symlink "zsh/.p10k.zsh"           "$HOME/.p10k.zsh"
symlink "ghostty/config"          "$HOME/.config/ghostty/config"
symlink "cursor/settings.json"    "$HOME/.config/Cursor/User/settings.json"
symlink "git/.gitconfig"          "$HOME/.gitconfig"

# ─── npm globals ─────────────────────────────────────────────────────────────
log "Instalando ferramentas npm globais..."
npm install -g typescript ts-node eslint prettier 2>/dev/null
success "TypeScript, ts-node, ESLint, Prettier instalados"

# ─── Conclusão ───────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✔ Instalação concluída!${RESET}"
echo ""
echo -e "  ${CYAN}Próximos passos:${RESET}"
echo -e "  1. Reinicie o terminal ou execute: ${BOLD}exec zsh${RESET}"
echo -e "  2. Configure o Powerlevel10k:      ${BOLD}p10k configure${RESET}"
echo -e "  3. Abra o Cursor IDE e aproveite!"
echo ""
