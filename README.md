# dotfiles

> Ambiente de desenvolvimento completo — setup em um comando.

## Instalação

```bash
git clone git@github.com:Felipeness/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## O que é instalado

### Shell
| Ferramenta | Descrição |
|---|---|
| ZSH | Shell principal |
| Oh My Zsh | Framework de plugins |
| Powerlevel10k | Tema do prompt |
| zsh-autosuggestions | Sugestões baseadas no histórico |
| zsh-syntax-highlighting | Syntax highlight no terminal |
| fzf + fzf-tab | Busca fuzzy com preview no Tab |
| zoxide | `cd` inteligente com histórico |
| bat | `cat` com syntax highlight |
| eza | `ls` com ícones e Git status |

### Terminal
| Ferramenta | Descrição |
|---|---|
| Ghostty | Terminal moderno e rápido |
| Maple Mono NF | Fonte principal (Nerd Font) |
| JetBrains Mono | Fonte fallback |
| Ultra Dark | Tema do terminal |

### Editor
| Ferramenta | Descrição |
|---|---|
| Cursor IDE | Editor principal (fork do VS Code com IA) |
| Tokyo Night | Tema do editor |
| ESLint + Prettier | Linting e formatação |
| GitLens | Git avançado |
| Error Lens | Erros inline |
| Tailwind CSS | IntelliSense |
| Prisma | ORM IntelliSense |
| Thunder Client | Testes de API |

### Linguagens e Runtimes
| Ferramenta | Versão |
|---|---|
| Node.js | v22 |
| Bun | v1.3+ |
| Go | v1.24 |
| Python | v3.12 |
| TypeScript | v5.9 |

### Bancos de Dados
| Ferramenta | Versão |
|---|---|
| PostgreSQL | 16 |
| Redis | 7 |
| MongoDB | 8 |

### DevOps / Infra
| Ferramenta | Descrição |
|---|---|
| Docker + Docker Desktop | Containers |
| kubectl | CLI do Kubernetes |
| Helm | Package manager do K8s |
| k9s | TUI para Kubernetes |
| minikube | Kubernetes local |
| Temporal CLI | Workflow orchestration |

### Ferramentas Go
| Ferramenta | Descrição |
|---|---|
| gopls | Language server |
| dlv | Debugger |
| goimports | Formata imports |
| golangci-lint | Linter |

## Estrutura

```
dotfiles/
├── install.sh          # Script de instalação completo
├── zsh/
│   ├── .zshrc          # Config do ZSH + aliases
│   └── .p10k.zsh       # Config do Powerlevel10k
├── ghostty/
│   └── config          # Config do terminal Ghostty
├── cursor/
│   └── settings.json   # Settings do Cursor IDE
└── git/
    └── .gitconfig      # Config global do Git
```

## Aliases úteis

```zsh
# Navegação
ll    → eza -lah --icons --git
tree  → eza --tree --icons
cd    → zoxide (inteligente)
cat   → bat (com syntax highlight)

# Git
gs    → git status
ga    → git add
gc    → git commit
gp    → git push
gl    → git pull
glog  → git log --oneline --graph --decorate

# Dev
ni    → npm install
bi    → bun install
dev   → bun run dev

# Docker
dps   → docker ps
dcu   → docker compose up -d
dcd   → docker compose down
```

## Atalhos Ghostty

| Atalho | Ação |
|---|---|
| `Ctrl+Shift+D` | Split vertical |
| `Ctrl+Shift+E` | Split horizontal |
| `Ctrl+Shift+H/L` | Navegar esquerda/direita |
| `Ctrl+Shift+K/J` | Navegar cima/baixo |
| `Ctrl+Shift+Z` | Zoom no split atual |
| `Ctrl+Shift+W` | Fechar split |
