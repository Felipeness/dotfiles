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
# FINALIZAÇÃO
# ============================================
Write-Host @"

============================================
  INSTALAÇÃO CONCLUÍDA!
============================================

Próximos passos:
  1. Reinicie o terminal
  2. Configure a fonte 'Maple Mono NF' no seu terminal
  3. Rode 'mise doctor' para verificar a instalação

Ferramentas instaladas:
  - mise, starship, fzf, zoxide, xh
  - helm, pack, helmfile
  - docker, gh, cargo
  - tailspin (tspin)

"@ -ForegroundColor Green
