# Dotfiles

Configurações e scripts para setup rápido de ambiente de desenvolvimento Windows.

## Quick Start

```powershell
# 1. Clone o repositório
git clone https://github.com/Felipeness/dotfiles.git $HOME\dotfiles

# 2. Execute o instalador (como Admin)
Set-ExecutionPolicy Bypass -Scope Process -Force
& $HOME\dotfiles\install.ps1
```

## O que é instalado

### Ferramentas CLI (via winget)

| Ferramenta | Descrição | Comando |
|------------|-----------|---------|
| [mise](https://mise.jdx.dev/) | Gerenciador de versões | `mise` |
| [starship](https://starship.rs/) | Prompt customizado | `starship` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `fzf` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd | `z` |
| [xh](https://github.com/ducaale/xh) | HTTP client | `xh` |
| [Helm](https://helm.sh/) | K8s package manager | `helm` |
| [pack](https://buildpacks.io/) | Buildpacks CLI | `pack` |
| [GitHub CLI](https://cli.github.com/) | GitHub na CLI | `gh` |

### Ferramentas via Mise

| Ferramenta | Descrição |
|------------|-----------|
| helmfile | Orquestração Helm |
| node | Node.js 22 |
| python | Python 3.13 |

### Ferramentas via Cargo (Rust)

| Ferramenta | Descrição | Comando |
|------------|-----------|---------|
| [tailspin](https://github.com/bensadeh/tailspin) | Visualizador de logs | `tspin` |

### Apps Desktop

| App | Descrição |
|-----|-----------|
| Docker Desktop | Containers |
| Cursor | IDE |
| Postman | API testing |
| VS Code | Editor |

### Fonte

- **Maple Mono NF** - Nerd Font para desenvolvimento (configurada automaticamente no Windows Terminal)

## Estrutura

```
dotfiles/
├── install.ps1              # Script principal de instalação
├── .mise.toml               # Config global do mise
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1
├── starship/
│   └── starship.toml
├── claude/                  # Configurações do Claude Code
│   ├── settings.json
│   ├── CLAUDE.md
│   ├── CLAUDE-expanded.md
│   ├── play-notification.ps1
│   ├── commands/
│   │   ├── new-feat.md
│   │   ├── review.md
│   │   └── open-pr.md
│   ├── skills/
│   │   ├── coding-guidelines/
│   │   ├── copywriting/
│   │   ├── planning/
│   │   ├── review-changes/
│   │   └── writing/
│   └── songs/
│       └── duolingo-correct.mp3
├── tmux/
│   └── .tmux.conf           # Config do Tmux para WSL
├── scripts/
│   ├── claude-workspace.bat # Abre 4 painéis no Windows Terminal
│   └── claude-workspace.sh  # Abre 4 painéis no Tmux (WSL)
└── README.md
```

## Uso do Script

```powershell
# Instalação completa
.\install.ps1

# Pular instalação de fontes
.\install.ps1 -SkipFonts

# Pular apps desktop
.\install.ps1 -SkipApps

# Pular ferramentas Rust
.\install.ps1 -SkipRust

# Combinar flags
.\install.ps1 -SkipFonts -SkipApps
```

## Claude Code

O instalador configura automaticamente o Claude Code com:

### Settings
- `alwaysThinkingEnabled: true`
- `includeLineNumbers: true`
- `autoSave: true`
- Hook de notificação (som Duolingo ao completar tarefas)

### Slash Commands

| Comando | Descrição |
|---------|-----------|
| `/new-feat [desc]` | Cria branch + desenvolve feature |
| `/review` | Revisa código (type safety, OWASP, a11y) |
| `/open-pr [título]` | Cria PR com summary e test plan |

### Skills

| Skill | Descrição |
|-------|-----------|
| `coding-guidelines` | Padrões TypeScript/React |
| `planning` | Arquitetura e decisões |
| `review-changes` | Code review |
| `writing` | Documentação e commits |
| `copywriting` | Marketing e sales copy |

### MCPs Instalados

| MCP | Descrição |
|-----|-----------|
| Context7 | Busca docs atualizadas de libs |
| Playwright | Automação de browser/testes E2E |

## Tmux (WSL)

Configuração otimizada para uso com Claude Code.

### Atalhos

| Atalho | Ação |
|--------|------|
| `Ctrl+a` | Prefixo (em vez de Ctrl+b) |
| `Ctrl+a \|` | Split vertical |
| `Ctrl+a -` | Split horizontal |
| `Alt+Setas` | Navegar entre painéis |
| `Ctrl+a z` | Zoom no painel atual |
| `Ctrl+a d` | Desconectar (sessão continua) |
| `Ctrl+a r` | Recarregar config |

### Scripts de Workspace

```bash
# Windows Terminal - abre 4 painéis
claude-workspace.bat

# WSL/Tmux - abre 4 painéis
~/claude-workspace.sh

# Com projetos específicos
~/claude-workspace.sh ~/proj1 ~/proj2 ~/proj3 ~/proj4

# Reconectar sessão tmux
tmux attach -t claude
```

## Após a Instalação

1. **Reinicie o terminal**

2. **Verifique as instalações:**
   ```powershell
   mise doctor
   starship --version
   claude --version
   ```

3. **Teste o workspace:**
   ```powershell
   # Windows
   .\scripts\claude-workspace.bat

   # WSL
   ~/claude-workspace.sh
   ```

## Aliases Configurados

| Alias | Comando |
|-------|---------|
| `g` | git |
| `k` | kubectl |
| `h` | helm |
| `d` | docker |
| `http` | xh |

## Funções Úteis

| Função | Descrição |
|--------|-----------|
| `gs` | git status |
| `gl` | git log (últimos 20) |
| `dps` | docker ps formatado |
| `aliases` | Lista todos os aliases |

## Atualizando

```powershell
# Atualizar todas as ferramentas winget
winget upgrade --all

# Atualizar ferramentas mise
mise upgrade

# Atualizar pacotes cargo
cargo install-update -a
```

## Links Úteis

- [mise Documentation](https://mise.jdx.dev/)
- [Starship Presets](https://starship.rs/presets/)
- [Maple Font](https://github.com/subframe7536/Maple-font)
- [Claude Code Guide](https://docs.anthropic.com/en/docs/claude-code)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
