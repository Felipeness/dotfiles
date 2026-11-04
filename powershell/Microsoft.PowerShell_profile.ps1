# PowerShell Profile - Configuração de ferramentas de desenvolvimento
# Gerado automaticamente

# ========================================
# Mise-en-place (gerenciador de versões)
# ========================================
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

# ========================================
# Starship (prompt customizado)
# ========================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ========================================
# Zoxide (smart cd)
# ========================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ========================================
# FZF (fuzzy finder)
# ========================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
}

# ========================================
# Aliases úteis
# ========================================
Set-Alias -Name g -Value git
Set-Alias -Name k -Value kubectl
Set-Alias -Name h -Value helm
Set-Alias -Name d -Value docker

# Alias para xh (http client)
if (Get-Command xh -ErrorAction SilentlyContinue) {
    Set-Alias -Name http -Value xh
}

# ========================================
# Funções úteis
# ========================================

# Listar todos os aliases
function aliases { Get-Alias | Format-Table -AutoSize }

# Git status rápido
function gs { git status }

# Git log bonito
function gl { git log --oneline --graph --decorate -20 }

# Docker ps formatado
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }

# ========================================
# RTK (Rust Token Killer) toggle
# ========================================
# Uso: rtk-toggle on | off | status
# Edita ~/.claude/settings.json substituindo o comando do hook PreToolUse.
# - on  : "rtk hook claude" (filtragem ativa)
# - off : "cmd /c exit 0"  (passthrough silencioso)
function rtk-toggle {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateSet('on','off','status','')]
        [string]$Action = 'status'
    )

    $settingsPath = Join-Path $env:USERPROFILE '.claude\settings.json'
    if (-not (Test-Path $settingsPath)) {
        Write-Host "rtk: settings.json nao encontrado em $settingsPath" -ForegroundColor Red
        return
    }

    $content  = Get-Content $settingsPath -Raw
    $enabled  = $content -match '"command":\s*"rtk hook claude"'
    $disabled = $content -match '"command":\s*"cmd /c exit 0"'

    switch ($Action) {
        'status' {
            if     ($enabled)  { Write-Host "rtk: ON  (filtrando comandos)" -ForegroundColor Green }
            elseif ($disabled) { Write-Host "rtk: OFF (passthrough)"        -ForegroundColor Yellow }
            else { Write-Host "rtk: nao instalado (rode: rtk init -g --auto-patch)" -ForegroundColor Red }
        }
        'on' {
            if ($enabled) { Write-Host "rtk: ja esta ON" -ForegroundColor Green; return }
            if (-not $disabled) {
                Write-Host "rtk: hook nao encontrado. Rode: rtk init -g --auto-patch" -ForegroundColor Red
                return
            }
            $new = $content -replace '"command":\s*"cmd /c exit 0"', '"command": "rtk hook claude"'
            Set-Content -Path $settingsPath -Value $new -NoNewline -Encoding UTF8
            Write-Host "rtk: ON. Reinicie o Claude Code para aplicar." -ForegroundColor Green
        }
        'off' {
            if ($disabled) { Write-Host "rtk: ja esta OFF" -ForegroundColor Yellow; return }
            if (-not $enabled) {
                Write-Host "rtk: hook nao encontrado em settings.json" -ForegroundColor Red
                return
            }
            $new = $content -replace '"command":\s*"rtk hook claude"', '"command": "cmd /c exit 0"'
            Set-Content -Path $settingsPath -Value $new -NoNewline -Encoding UTF8
            Write-Host "rtk: OFF (passthrough). Reinicie o Claude Code para aplicar." -ForegroundColor Yellow
        }
    }
}
