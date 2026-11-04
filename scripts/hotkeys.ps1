# Atalhos globais (Menu Iniciar): Ctrl+Alt+T = terminal, Ctrl+Alt+N = Neovim.
# Os dois abrem como admin via "elevate" nos perfis do Windows Terminal.
$shell = New-Object -ComObject WScript.Shell
$programs = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$wt = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"

$hotkeys = @(
    @{ Name = "Terminal-Hotkey"; Args = "";            Key = "Ctrl+Alt+T" },
    @{ Name = "Neovim-Hotkey";   Args = "-p Neovim";   Key = "Ctrl+Alt+N" }
)

foreach ($h in $hotkeys) {
    $lnk = $shell.CreateShortcut("$programs\$($h.Name).lnk")
    $lnk.TargetPath = $wt
    $lnk.Arguments = $h.Args
    $lnk.Hotkey = $h.Key
    $lnk.Save()
    Write-Host "[+] $($h.Key) -> wt.exe $($h.Args)" -ForegroundColor Green
}
