@echo off
REM Claude Code Workspace - Windows Terminal
REM Abre 4 paineis prontos para trabalhar com Claude Code

echo Abrindo workspace com 4 paineis...

wt.exe ^
    --title "Claude 1" pwsh -NoExit -Command "Write-Host 'Painel 1 - Digite: claude' -ForegroundColor Green" ^
    ; split-pane --horizontal --title "Claude 3" pwsh -NoExit -Command "Write-Host 'Painel 3 - Digite: claude' -ForegroundColor Green" ^
    ; move-focus up ^
    ; split-pane --vertical --title "Claude 2" pwsh -NoExit -Command "Write-Host 'Painel 2 - Digite: claude' -ForegroundColor Green" ^
    ; move-focus down ^
    ; split-pane --vertical --title "Comandos" pwsh -NoExit -Command "Write-Host 'Painel 4 - Para npm, git, testes' -ForegroundColor Yellow"

echo.
echo Layout:
echo   [Claude 1] ^| [Claude 2]
echo   -----------------------
echo   [Claude 3] ^| [Comandos]
echo.
echo Use Alt+Setas para navegar entre paineis
