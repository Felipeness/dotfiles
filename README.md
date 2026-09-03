# Dotfiles

Configuracoes e scripts para setup rapido de ambiente de desenvolvimento Windows.

**Ultima atualizacao:** Abril 2026

## Quick Start

```powershell
# 1. Clone o repositorio
git clone https://github.com/Felipeness/dotfiles.git $HOME\dotfiles

# 2. Execute o instalador (como Admin)
Set-ExecutionPolicy Bypass -Scope Process -Force
& $HOME\dotfiles\install.ps1
```

## O que e instalado

### Ferramentas CLI (via winget)

| Ferramenta | Descricao | Comando |
|------------|-----------|---------|
| [mise](https://mise.jdx.dev/) | Gerenciador de versoes | `mise` |
| [starship](https://starship.rs/) | Prompt customizado | `starship` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `fzf` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd | `z` |
| [xh](https://github.com/ducaale/xh) | HTTP client | `xh` |
| [Helm](https://helm.sh/) | K8s package manager | `helm` |
| [pack](https://buildpacks.io/) | Buildpacks CLI | `pack` |
| [GitHub CLI](https://cli.github.com/) | GitHub na CLI | `gh` |

### Ferramentas via Mise

| Ferramenta | Descricao |
|------------|-----------|
| helmfile | Orquestracao Helm |
| node | Node.js 22 |
| python | Python 3.13 |

### Ferramentas via Cargo (Rust)

| Ferramenta | Descricao | Comando |
|------------|-----------|---------|
| [tailspin](https://github.com/bensadeh/tailspin) | Visualizador de logs | `tspin` |

### Apps Desktop

| App | Descricao |
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
├── install.ps1              # Script principal de instalacao
├── .mise.toml               # Config global do mise
├── .gitignore
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1
├── bash/
│   └── .bashrc              # Git Bash config (GIT_OPTIONAL_LOCKS, aliases)
├── git/
│   └── .gitconfig           # Git config (fsmonitor, rerere, rebase, aliases)
├── starship/
│   └── starship.toml        # Minimal config (5 modules vs 20+)
├── terminal/
│   └── settings.json        # Windows Terminal (Atlas engine, dark theme)
├── claude/
│   ├── settings.json        # Full hooks, plugins, env
│   ├── settings.local.json.template  # Permissions template
│   ├── mcp-servers.json.template     # MCP server config template
│   ├── CLAUDE.md            # Testing, caching, escape hatches, meta-rule
│   ├── hooks/               # 13 hook scripts
│   │   ├── pre-bash-guard.js         # Unified: dangerous commands + commit validation
│   │   ├── validate-branch-name.js   # Branch naming convention
│   │   ├── validate-pr-body.js       # PR body: Jira link + no defensive text
│   │   ├── lint-after-edit.sh        # Auto-lint on file edit (Biome/ESLint)
│   │   ├── aws-profile-check.js      # AWS profile warning
│   │   ├── typecheck-after-edit.sh   # TS typecheck (incremental)
│   │   ├── mirror-pr-reminder.js     # Mirror PR for dual-branch repos
│   │   ├── ralph-stop-hook.js        # Ralph Loop management
│   │   ├── teammate-idle-check.js    # Agent Teams idle check
│   │   ├── task-created-validate.js  # Task creation validation
│   │   ├── task-completed-verify.js  # Task completion verification
│   │   ├── post-compact-context.sh   # Context re-injection after compact
│   │   └── cleanup-temp-files.sh     # Session cleanup
│   ├── commands/             # 11 slash commands
│   ├── skills/               # 27+ skills
│   │   ├── typescript/       # 452 lines (was 41)
│   │   ├── react/            # 170 lines (was 36)
│   │   ├── nestjs/           # 300 lines
│   │   ├── code-quality/     # 539 lines
│   │   ├── functional-programming/
│   │   ├── architecture-patterns/
│   │   ├── holonomic-systems/
│   │   └── ... (20+ more)
│   └── songs/
│       └── duolingo-correct.mp3
├── tmux/
│   └── .tmux.conf
├── dota/
│   ├── README.md            # Onde restaurar
│   ├── gamestate_integration/  # GSI cfgs (Dota Plus, Overwolf, Logitech, analyzer)
│   └── keybinds/            # Atalhos de tecla + settings (dotakeys, user_keys, user_convars)
└── scripts/
    ├── claude-workspace.bat
    └── claude-workspace.sh
```

## Uso do Script

```powershell
# Instalacao completa
.\install.ps1

# Pular instalacao de fontes
.\install.ps1 -SkipFonts

# Pular apps desktop
.\install.ps1 -SkipApps

# Pular ferramentas Rust
.\install.ps1 -SkipRust

# Combinar flags
.\install.ps1 -SkipFonts -SkipApps
```

## Claude Code

O instalador configura automaticamente o Claude Code com settings, hooks, skills, commands, MCPs e plugins.

### Hooks (13)

| Hook | Tipo | Descricao |
|------|------|-----------|
| `pre-bash-guard.js` | PreToolUse (Bash) | Bloqueia comandos destrutivos (rm -rf, git push --force) e valida commits |
| `validate-branch-name.js` | PreToolUse (Bash) | Valida naming convention de branches (type/TICKET-desc) |
| `validate-pr-body.js` | PreToolUse (Bash) | Exige link Jira no PR body, bloqueia texto defensivo |
| `lint-after-edit.sh` | PostToolUse (Edit/Write) | Auto-lint com Biome/ESLint apos editar arquivo |
| `aws-profile-check.js` | PreToolUse (Bash) | Alerta ao usar AWS sem profile explicitamente definido |
| `typecheck-after-edit.sh` | PostToolUse (Edit/Write) | Typecheck incremental TypeScript apos editar .ts/.tsx |
| `mirror-pr-reminder.js` | PostToolUse (Bash) | Lembra de criar PR espelho em repos com master+develop |
| `ralph-stop-hook.js` | Stop | Gerencia parada segura de Ralph Loops |
| `teammate-idle-check.js` | PreToolUse | Detecta agentes idle em Agent Teams |
| `task-created-validate.js` | PostToolUse | Valida criacao de tasks em Agent Teams |
| `task-completed-verify.js` | PostToolUse | Verifica completude de tasks finalizadas |
| `post-compact-context.sh` | Notification | Re-injeta contexto critico apos /compact |
| `cleanup-temp-files.sh` | Stop | Limpa arquivos temporarios da sessao |

### Plugins (12)

| Plugin | Status | Descricao |
|--------|--------|-----------|
| `hookify` | Habilitado | Criacao de hooks via regras declarativas |
| `commit-commands` | Habilitado | Commit, push, PR em um comando |
| `pr-review-toolkit` | Habilitado | Review de PRs com agentes especializados |
| `claude-md-management` | Habilitado | Audit e melhoria de CLAUDE.md |
| `feature-dev` | Habilitado | Desenvolvimento guiado de features |
| `superpowers` | Habilitado | Brainstorming, TDD, debugging, planning |
| `claude-code-setup` | Habilitado | Recomendacao de automacoes |
| `frontend-design` | Habilitado | Interfaces com alta qualidade visual |
| `update-config` | Habilitado | Configuracao de settings.json |
| `keybindings-help` | Habilitado | Customizacao de atalhos |
| `simplify` | Habilitado | Review de qualidade e reuso |
| `loop` | Habilitado | Execucao recorrente de tarefas |

### Skills (27+ categorizados)

**Linguagem:**

| Skill | Linhas | Descricao |
|-------|--------|-----------|
| `typescript` | 452 | TS/JS standards, type-safety, patterns |
| `react` | 170 | React/Next.js, Server Components, hooks |
| `nestjs` | 300 | Controllers, services, modules, guards |
| `go` | -- | Go idiomatico, concorrencia, error handling |

**Qualidade:**

| Skill | Descricao |
|-------|-----------|
| `code-quality` | CUPID/SOLID/DRY/KISS/YAGNI (539 linhas) |
| `functional-programming` | Pure functions, ROP, CQS, imutabilidade |
| `ultrathink-review` | Audit profundo com analise defensiva |
| `refactoring` | Metodologia segura de refatoracao |

**Arquitetura:**

| Skill | Descricao |
|-------|-----------|
| `architecture-patterns` | Holonomic, CQRS, Saga, Circuit Breaker |
| `holonomic-systems` | SCS, Janus Effect, holarchy |
| `api-design` | REST type-safe, webhooks, idempotencia |
| `planning` | Decisoes de arquitetura e tecnologia |

**Operacoes:**

| Skill | Descricao |
|-------|-----------|
| `observability` | Logging, tracing, metricas, alertas |
| `debugging` | Investigacao estruturada com MCP tools |

**Ralph Loops (autonomos):**

| Skill | Descricao |
|-------|-----------|
| `ralph-implement` | Card Jira -> implementacao com TDD |
| `ralph-review` | Review e fix automatico de PRs |
| `ralph-refactor` | Refatoracao incremental com testes |
| `ralph-test` | TDD loop: testes primeiro |
| `ralph-debug` | Bug report -> fix -> regression test |
| `ralph-perf` | Benchmark -> otimizacao -> re-benchmark |
| `ralph-migrate` | Migracoes incrementais com rollback |
| `ralph-docs` | Documentacao com analise de gaps |
| `ralph-cancel` | Parada segura de loops |

**Comunicacao:**

| Skill | Descricao |
|-------|-----------|
| `code-review-comments` | Tom humano para reviews |
| `mirror-pr` | PR espelho master->develop |

**Design:**

| Skill | Descricao |
|-------|-----------|
| `figma-to-code` | Pipeline pixel-perfect Figma |
| `figma-code-connect` | Mapeamento Figma <-> componentes |

### Commands (11)

| Comando | Descricao |
|---------|-----------|
| `/new-feat [desc]` | Cria branch + desenvolve feature |
| `/review` | Revisa codigo (type safety, OWASP, a11y) |
| `/open-pr [titulo]` | Cria PR com summary e test plan |
| `/review-staged` | Review de changes staged |
| `/investigate` | Descoberta sistematica antes de planejar |
| `/investigate-batch` | Investigacao batched |
| `/trim` | Reduz PR description em 70% |
| `/fix` | Lint, formatacao, pre-commit |
| `/readme` | Gera README com Mermaid, badges, tabelas |
| `/verify` | Validacao completa antes de commit |
| `/fp-audit` | Audit de violacoes de programacao funcional |

### MCPs (7)

| MCP | Descricao |
|-----|-----------|
| Context7 | Docs atualizadas de libs (React, Next.js, Prisma, etc.) |
| DeepWiki | Wiki profunda de repositorios open-source |
| Playwright | Automacao de browser, testes E2E, medicao visual |
| Atlassian | Integracao Jira/Confluence (issues, boards, sprints) |
| Gmail | Leitura e rascunhos de email |
| Google Calendar | Agenda e eventos |
| Chrome | Automacao de browser via chrome-in-chrome |

### Variaveis de Ambiente

| Variavel | Valor | Descricao |
|----------|-------|-----------|
| `CLAUDE_CODE_NO_FLICKER` | `1` | Desabilita flicker no output |
| `AGENT_TEAMS` | `true` | Habilita Agent Teams |
| `MAX_MCP_OUTPUT_TOKENS` | `50000` | Limite de tokens para output de MCPs |

## Git (.gitconfig)

Configuracao otimizada para performance e workflow.

### Performance

| Config | Descricao |
|--------|-----------|
| `core.fsmonitor = true` | Monitora filesystem para git status 2-5x mais rapido |
| `feature.manyFiles = true` | Otimizacoes para repos grandes |

### Workflow

| Config | Descricao |
|--------|-----------|
| `rerere.enabled = true` | Auto-resolve conflitos repetidos (REuse REcorded REsolution) |
| `pull.rebase = true` | Rebase ao inves de merge commit no pull |
| `push.autoSetupRemote = true` | Push automatico configura tracking |
| `merge.conflictstyle = zdiff3` | Mostra base comum em conflitos (3-way diff) |
| `diff.algorithm = histogram` | Algoritmo de diff mais preciso |

### Aliases

| Alias | Comando | Descricao |
|-------|---------|-----------|
| `git sw` | `switch` | Trocar branch |
| `git swc` | `switch -c` | Criar e trocar branch |
| `git lg` | `log --oneline --graph` | Log compacto com grafo |
| `git gone` | Limpa branches locais deletadas no remote | Cleanup |
| `git uncommit` | `reset --soft HEAD~1` | Desfaz ultimo commit mantendo changes |
| `git fixup` | `commit --fixup` | Commit fixup para rebase --autosquash |

## Bash (.bashrc)

Configuracao para Git Bash no Windows.

### Variaveis

| Variavel | Valor | Descricao |
|----------|-------|-----------|
| `GIT_OPTIONAL_LOCKS` | `0` | Evita locks opcionais (melhor para IDEs e editores) |

### Aliases Holonomic

Aliases para fluxo de trabalho com projetos Holonomic/Superlogica.

## Windows Terminal

Configuracao otimizada para desenvolvimento.

| Config | Valor | Descricao |
|--------|-------|-----------|
| `useAtlasEngine` | `true` | Engine de renderizacao GPU-accelerated |
| `theme` | `dark` | Tema escuro (era legacyDark) |
| `padding` | `"8"` | Padding interno do terminal |
| `bellStyle` | `"taskbar"` | Notificacao de bell na taskbar |

## Starship

Config minimalista -- apenas 5 modulos habilitados (era 20+).

| Modulo | Descricao |
|--------|-----------|
| `directory` | Diretorio atual (truncado) |
| `git_branch` + `git_status` | Branch e status do git |
| `nodejs` | Versao do Node.js |
| `golang` | Versao do Go |
| `python` | Versao do Python |
| `cmd_duration` | Duracao do ultimo comando |

Todos os outros runtimes (Ruby, PHP, Java, Lua, Elixir, etc.) foram desabilitados para reduzir latencia do prompt.

## Tmux (WSL)

Configuracao otimizada para uso com Claude Code.

### Atalhos

| Atalho | Acao |
|--------|------|
| `Ctrl+a` | Prefixo (em vez de Ctrl+b) |
| `Ctrl+a \|` | Split vertical |
| `Ctrl+a -` | Split horizontal |
| `Alt+Setas` | Navegar entre paineis |
| `Ctrl+a z` | Zoom no painel atual |
| `Ctrl+a d` | Desconectar (sessao continua) |
| `Ctrl+a r` | Recarregar config |

### Scripts de Workspace

```bash
# Windows Terminal - abre 4 paineis
claude-workspace.bat

# WSL/Tmux - abre 4 paineis
~/claude-workspace.sh

# Com projetos especificos
~/claude-workspace.sh ~/proj1 ~/proj2 ~/proj3 ~/proj4

# Reconectar sessao tmux
tmux attach -t claude
```

## Aliases Configurados

| Alias | Comando |
|-------|---------|
| `g` | git |
| `k` | kubectl |
| `h` | helm |
| `d` | docker |
| `http` | xh |

## Funcoes Uteis

| Funcao | Descricao |
|--------|-----------|
| `gs` | git status |
| `gl` | git log (ultimos 20) |
| `dps` | docker ps formatado |
| `aliases` | Lista todos os aliases |

## Apos a Instalacao

1. **Reinicie o terminal**

2. **Verifique as instalacoes:**
   ```powershell
   mise doctor
   starship --version
   claude --version
   git config --list --global
   ```

3. **Teste o workspace:**
   ```powershell
   # Windows
   .\scripts\claude-workspace.bat

   # WSL
   ~/claude-workspace.sh
   ```

## Atualizando

```powershell
# Atualizar todas as ferramentas winget
winget upgrade --all

# Atualizar ferramentas mise
mise upgrade

# Atualizar pacotes cargo
cargo install-update -a

# Re-aplicar dotfiles
& $HOME\dotfiles\install.ps1
```

## Links Uteis

- [mise Documentation](https://mise.jdx.dev/)
- [Starship Presets](https://starship.rs/presets/)
- [Maple Font](https://github.com/subframe7536/Maple-font)
- [Claude Code Guide](https://docs.anthropic.com/en/docs/claude-code)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
