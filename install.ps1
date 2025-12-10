#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de instalação automatizada de ferramentas de desenvolvimento
.DESCRIPTION
    Instala todas as ferramentas CLI, fontes e configurações para ambiente de desenvolvimento
.NOTES
    Autor: Felipe
    Versão: 1.0.0
#>

param(
    [switch]$SkipFonts,
    [switch]$SkipApps,
    [switch]$SkipRust
)

$ErrorActionPreference = "Continue"

# Cores para output
function Write-Step { param($msg) Write-Host "`n[*] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "[-] $msg" -ForegroundColor Red }

Write-Host @"

 ____        _    __ _ _
|  _ \  ___ | |_ / _(_) | ___  ___
| | | |/ _ \| __| |_| | |/ _ \/ __|
| |_| | (_) | |_|  _| | |  __/\__ \
|____/ \___/ \__|_| |_|_|\___||___/

  Instalador de Ambiente de Desenvolvimento

"@ -ForegroundColor Magenta

# ============================================
# 1. FERRAMENTAS CLI VIA WINGET
# ============================================
Write-Step "Instalando ferramentas CLI via winget..."

$wingetPackages = @(
    @{ id = "jdx.mise"; name = "mise-en-place" },
    @{ id = "Starship.Starship"; name = "starship" },
    @{ id = "junegunn.fzf"; name = "fzf" },
    @{ id = "ajeetdsouza.zoxide"; name = "zoxide" },
    @{ id = "ducaale.xh"; name = "xh" },
    @{ id = "Helm.Helm"; name = "helm" },
    @{ id = "buildpacks.pack"; name = "pack" },
    @{ id = "GitHub.cli"; name = "gh" },
    @{ id = "Rustlang.Rustup"; name = "rust" }
)

foreach ($pkg in $wingetPackages) {
    Write-Host "  Instalando $($pkg.name)..." -NoNewline
    $result = winget install $pkg.id --accept-source-agreements --accept-package-agreements --silent 2>&1
    if ($LASTEXITCODE -eq 0 -or $result -match "já instalado") {
        Write-Success " OK"
    } else {
        Write-Warning " Verificar manualmente"
    }
}

# ============================================
# 2. APPS DESKTOP (opcional)
# ============================================
if (-not $SkipApps) {
    Write-Step "Instalando apps desktop..."

    $desktopApps = @(
        @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" },
        @{ id = "Anysphere.Cursor"; name = "Cursor" },
        @{ id = "Postman.Postman"; name = "Postman" },
        @{ id = "Microsoft.VisualStudioCode"; name = "VS Code" }
    )

    foreach ($app in $desktopApps) {
        Write-Host "  Instalando $($app.name)..." -NoNewline
        winget install $app.id --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success " OK"
        } else {
            Write-Warning " Verificar manualmente"
        }
    }
}

# ============================================
# 3. VS BUILD TOOLS + RUST PACKAGES
# ============================================
if (-not $SkipRust) {
    Write-Step "Instalando VS Build Tools (necessário para cargo)..."
    winget install Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --quiet --wait" --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null

    Write-Step "Instalando pacotes Rust via cargo..."

    # Refresh PATH para cargo
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    $cargoPackages = @("tailspin")

    foreach ($pkg in $cargoPackages) {
        Write-Host "  Instalando $pkg..." -NoNewline
        & "$env:USERPROFILE\.cargo\bin\cargo.exe" install $pkg 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success " OK"
        } else {
            Write-Warning " Verificar manualmente"
        }
    }
}

# ============================================
# 4. MISE - FERRAMENTAS GLOBAIS
# ============================================
Write-Step "Configurando ferramentas via mise..."

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$miseTools = @("helmfile", "node@22", "python@3.13")

foreach ($tool in $miseTools) {
    Write-Host "  Instalando $tool..." -NoNewline
    mise use -g $tool 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success " OK"
    } else {
        Write-Warning " Verificar manualmente"
    }
}

# ============================================
# 5. FONTE MAPLE MONO NF
# ============================================
if (-not $SkipFonts) {
    Write-Step "Baixando e instalando Maple Mono NF..."

    $fontUrl = "https://github.com/subframe7536/Maple-font/releases/download/v7.8/MapleMono-NF-unhinted.zip"
    $tempDir = "$env:TEMP\MapleMono"
    $zipFile = "$tempDir\MapleMono-NF.zip"

    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    Invoke-WebRequest -Uri $fontUrl -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

    # Instalar fontes
    $fonts = Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse
    $shellApp = New-Object -ComObject Shell.Application
    $fontsFolder = $shellApp.Namespace(0x14)

    foreach ($font in $fonts) {
        Write-Host "  Instalando $($font.Name)..." -NoNewline
        $fontsFolder.CopyHere($font.FullName, 0x10)
        Write-Success " OK"
    }

    # Cleanup
    Remove-Item -Path $tempDir -Recurse -Force
}

# ============================================
# 6. CONFIGURAR POWERSHELL PROFILE
# ============================================
Write-Step "Configurando PowerShell profile..."

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceProfile = Join-Path $scriptDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $sourceProfile) {
    Copy-Item -Path $sourceProfile -Destination $PROFILE -Force
    Write-Success "Profile copiado para $PROFILE"
} else {
    Write-Warning "Arquivo de profile não encontrado em $sourceProfile"
}

# ============================================
# 7. CONFIGURAR STARSHIP
# ============================================
Write-Step "Configurando Starship..."

$starshipDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $starshipDir)) {
    New-Item -ItemType Directory -Force -Path $starshipDir | Out-Null
}

$sourceStarship = Join-Path $scriptDir "starship\starship.toml"
if (Test-Path $sourceStarship) {
    Copy-Item -Path $sourceStarship -Destination "$starshipDir\starship.toml" -Force
    Write-Success "Starship config copiado"
}

# ============================================
# 8. CONFIGURAR CLAUDE CODE
# ============================================
Write-Step "Configurando Claude Code..."

$claudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
}

$sourceClaudeDir = Join-Path $scriptDir "claude"
if (Test-Path $sourceClaudeDir) {
    # Copiar settings.json
    $sourceSettings = Join-Path $sourceClaudeDir "settings.json"
    if (Test-Path $sourceSettings) {
        Copy-Item -Path $sourceSettings -Destination "$claudeDir\settings.json" -Force
        Write-Success "Claude settings.json copiado"
    }

    # Copiar CLAUDE.md
    $sourceClaude = Join-Path $sourceClaudeDir "CLAUDE.md"
    if (Test-Path $sourceClaude) {
        Copy-Item -Path $sourceClaude -Destination "$claudeDir\CLAUDE.md" -Force
        Write-Success "CLAUDE.md copiado"
    }

    # Copiar CLAUDE-expanded.md
    $sourceClaudeExp = Join-Path $sourceClaudeDir "CLAUDE-expanded.md"
    if (Test-Path $sourceClaudeExp) {
        Copy-Item -Path $sourceClaudeExp -Destination "$claudeDir\CLAUDE-expanded.md" -Force
        Write-Success "CLAUDE-expanded.md copiado"
    }

    # Copiar play-notification.ps1
    $sourceNotification = Join-Path $sourceClaudeDir "play-notification.ps1"
    if (Test-Path $sourceNotification) {
        Copy-Item -Path $sourceNotification -Destination "$claudeDir\play-notification.ps1" -Force
        Write-Success "play-notification.ps1 copiado"
    }

    # Copiar commands
    $sourceCommands = Join-Path $sourceClaudeDir "commands"
    if (Test-Path $sourceCommands) {
        Copy-Item -Path $sourceCommands -Destination "$claudeDir\commands" -Recurse -Force
        Write-Success "Claude commands copiados"
    }

    # Copiar skills
    $sourceSkills = Join-Path $sourceClaudeDir "skills"
    if (Test-Path $sourceSkills) {
        Copy-Item -Path $sourceSkills -Destination "$claudeDir\skills" -Recurse -Force
        Write-Success "Claude skills copiadas"
    }

    # Copiar songs
    $sourceSongs = Join-Path $sourceClaudeDir "songs"
    if (Test-Path $sourceSongs) {
        Copy-Item -Path $sourceSongs -Destination "$claudeDir\songs" -Recurse -Force
        Write-Success "Claude songs copiados"
    }
} else {
    Write-Warning "Pasta claude não encontrada em $sourceClaudeDir"
}

# ============================================
# 9. CONFIGURAR TMUX (WSL)
# ============================================
Write-Step "Configurando Tmux para WSL..."

$sourceTmux = Join-Path $scriptDir "tmux\.tmux.conf"
if (Test-Path $sourceTmux) {
    # Copia para WSL home
    wsl -e bash -c "cp '/mnt/c/Users/$env:USERNAME/dotfiles/tmux/.tmux.conf' ~/.tmux.conf 2>/dev/null"
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tmux config copiado para WSL"
    } else {
        Write-Warning "WSL não disponível ou erro ao copiar"
    }
} else {
    Write-Warning "Arquivo .tmux.conf não encontrado"
}

# ============================================
# 10. COPIAR SCRIPTS DE WORKSPACE
# ============================================
Write-Step "Copiando scripts de workspace..."

$sourceScripts = Join-Path $scriptDir "scripts"
$destScripts = "$env:USERPROFILE\scripts"

if (-not (Test-Path $destScripts)) {
    New-Item -ItemType Directory -Force -Path $destScripts | Out-Null
}

if (Test-Path $sourceScripts) {
    Copy-Item -Path "$sourceScripts\*" -Destination $destScripts -Recurse -Force
    Write-Success "Scripts copiados para $destScripts"

    # Copiar script WSL para home
    wsl -e bash -c "cp '/mnt/c/Users/$env:USERNAME/scripts/claude-workspace.sh' ~/claude-workspace.sh && chmod +x ~/claude-workspace.sh 2>/dev/null"
    if ($LASTEXITCODE -eq 0) {
        Write-Success "claude-workspace.sh copiado para WSL"
    }
}

# ============================================
# 11. CONFIGURAR FONTE NO WINDOWS TERMINAL
# ============================================
Write-Step "Configurando fonte Maple Mono NF no Windows Terminal..."

$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $wtSettingsPath) {
    $wtSettings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json

    # Configurar fonte padrão para todos os perfis
    if (-not $wtSettings.profiles.defaults) {
        $wtSettings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
    }

    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{
        face = "Maple Mono NF"
        size = 12
    } -Force

    $wtSettings | ConvertTo-Json -Depth 100 | Set-Content $wtSettingsPath -Encoding UTF8
    Write-Success "Fonte Maple Mono NF configurada no Windows Terminal"
} else {
    Write-Warning "Windows Terminal settings.json não encontrado"
}

# ============================================
# 12. INSTALAR MCPs DO CLAUDE CODE
# ============================================
Write-Step "Instalando MCPs do Claude Code..."

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    Write-Host "  Instalando Context7 MCP..." -NoNewline
    claude mcp add context7 -- npx -y "@upstash/context7-mcp@latest" 2>&1 | Out-Null
    Write-Success " OK"

    Write-Host "  Instalando Playwright MCP..." -NoNewline
    claude mcp add playwright -- npx "@playwright/mcp@latest" 2>&1 | Out-Null
    Write-Success " OK"
} else {
    Write-Warning "Claude Code CLI não encontrado. Instale com: npm install -g @anthropic-ai/claude-code"
}

# ============================================
# FINALIZAÇÃO
# ============================================
Write-Host @"

============================================
  INSTALAÇÃO CONCLUÍDA!
============================================

Próximos passos:
  1. Reinicie o terminal
  2. Rode 'mise doctor' para verificar a instalação
  3. Execute 'claude-workspace.bat' para abrir 4 painéis

Ferramentas instaladas:
  - mise, starship, fzf, zoxide, xh
  - helm, pack, helmfile
  - docker, gh, cargo
  - tailspin (tspin)

Claude Code configurado:
  - Settings, CLAUDE.md, commands, skills
  - MCPs: Context7, Playwright
  - Hook de notificação (som Duolingo)
  - Scripts: claude-workspace.bat/.sh

Tmux (WSL):
  - Config em ~/.tmux.conf
  - Script ~/claude-workspace.sh

Fonte:
  - Maple Mono NF configurada no Windows Terminal

"@ -ForegroundColor Green
