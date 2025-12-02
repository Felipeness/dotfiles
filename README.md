# Dotfiles

Configurações e scripts para setup rápido de ambiente de desenvolvimento Windows.

## Quick Start

```powershell
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/dotfiles.git $HOME\dotfiles

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

- **Maple Mono NF** - Nerd Font para desenvolvimento

## Estrutura

```
dotfiles/
├── install.ps1              # Script principal de instalação
├── .mise.toml               # Config global do mise
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1
├── starship/
│   └── starship.toml
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

## Após a Instalação

1. **Reinicie o terminal**

2. **Configure a fonte no Windows Terminal:**
   - Settings → Profiles → Defaults → Appearance → Font face → `Maple Mono NF`

3. **Verifique as instalações:**
   ```powershell
   mise doctor
   starship --version
   fzf --version
   zoxide --version
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
- [Dracula Theme](https://draculatheme.com/)
- [Maple Font](https://github.com/subframe7536/Maple-font)
