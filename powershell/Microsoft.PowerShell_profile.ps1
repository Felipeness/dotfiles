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
