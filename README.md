# dotfiles

> Ambiente de desenvolvimento completo — setup em um comando.

```bash
git clone git@github.com:Felipeness/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

---

## Stack

### Shell & Terminal
| Ferramenta | Descrição |
|---|---|
| **Ghostty** | Terminal moderno e rápido |
| **ZSH** | Shell principal |
| **Oh My Zsh** | Framework de plugins |
| **Powerlevel10k** | Tema do prompt |
| **Maple Mono NF** | Fonte principal (Nerd Font) |
| **JetBrains Mono** | Fonte fallback |
| **Ultra Dark** | Tema do terminal |

### Plugins ZSH
| Plugin | Descrição |
|---|---|
| zsh-autosuggestions | Sugestões baseadas no histórico |
| zsh-syntax-highlighting | Syntax highlight no terminal |
| fzf + fzf-tab | Busca fuzzy com preview no Tab |
| zoxide | `cd` inteligente |
| bat | `cat` com syntax highlight |
| eza | `ls` com ícones e Git status |
| history-substring-search | Setas ↑↓ buscam no histórico |
| sudo | `ESC ESC` adiciona sudo |
| extract | `x arquivo` extrai qualquer formato |
| colored-man-pages | `man` colorido |

### Editor
| Ferramenta | Descrição |
|---|---|
| **Cursor IDE** | Editor principal (VS Code + IA) |
| **Tokyo Night** | Tema principal |
| **Dracula / Dracula At Night** | Temas alternativos |
| ESLint + Prettier | Linting e formatação |
| GitLens | Git avançado inline |
| Error Lens | Erros inline no código |
| Thunder Client | Testes de API |
| Tailwind CSS | IntelliSense |
| Prisma | ORM IntelliSense |

### Linguagens & Runtimes
| Ferramenta | Versão |
|---|---|
| Node.js | v22 |
| Bun | v1.3+ |
| Go | v1.24 |
| Python | v3.12 |
| TypeScript | v5.9 |

### Ferramentas Go
| Ferramenta | Descrição |
|---|---|
| gopls | Language server |
| dlv | Debugger |
| goimports | Formata imports |
| golangci-lint | Linter |

### Bancos de Dados
| Ferramenta | Versão |
|---|---|
| PostgreSQL | 16 |
| Redis | 7 |
| MongoDB | 8 |

### DevOps & Infra
| Ferramenta | Descrição |
|---|---|
| Docker + Docker Desktop | Containers |
| kubectl v1.32 | CLI do Kubernetes |
| Helm v3 | Package manager K8s |
| k9s | TUI para Kubernetes |
| minikube | Kubernetes local |
| Terraform v1.14 | Infrastructure as Code |
| Ansible | Automação de configuração |
| Temporal CLI | Workflow orchestration |

---

## Estrutura

```
dotfiles/
├── install.sh              # Script completo e idempotente
├── zsh/
│   ├── .zshrc              # Config ZSH + aliases + plugins
│   └── .p10k.zsh           # Config Powerlevel10k
├── ghostty/
│   └── config              # Config Ghostty
├── cursor/
│   ├── settings.json       # Settings Cursor IDE
│   └── extensions.txt      # Lista de extensões
└── git/
    └── .gitconfig          # Config global Git
```

---

## Aliases

```zsh
# Navegação
ll      → eza -lah --icons --git
ls      → eza --icons
tree    → eza --tree --icons
cat     → bat (syntax highlight)
cd      → zoxide (inteligente)
..      → cd ..
...     → cd ../..

# Git
gs      → git status
ga      → git add
gc      → git commit
gp      → git push
gl      → git pull
glog    → git log --oneline --graph --decorate

# Dev
ni      → npm install
bi      → bun install
dev     → bun run dev
build   → bun run build

# Docker
dps     → docker ps
dcu     → docker compose up -d
dcd     → docker compose down
```

## Atalhos Ghostty

| Atalho | Ação |
|---|---|
| `Ctrl+Shift+D` | Split vertical |
| `Ctrl+Shift+E` | Split horizontal |
| `Ctrl+Shift+H` / `L` | Navegar esquerda / direita |
| `Ctrl+Shift+K` / `J` | Navegar cima / baixo |
| `Ctrl+Shift+Z` | Zoom no split atual |
| `Ctrl+Shift+W` | Fechar split |

## ZSH shortcuts

| Atalho | Ação |
|---|---|
| `ESC ESC` | Adiciona `sudo` ao comando anterior |
| `Ctrl+T` | Busca fuzzy de arquivos |
| `Tab` | Autocomplete com preview (fzf-tab) |
| `↑` / `↓` | Busca no histórico pelo que foi digitado |
| `Alt+←` / `→` | Navega histórico de diretórios |
| `x arquivo` | Extrai qualquer arquivo compactado |
