#!/bin/bash
# Claude Code Workspace - Tmux (WSL)
# Abre sessao tmux com 4 paineis prontos para trabalhar com Claude Code
#
# Uso:
#   ./claude-workspace.sh                    # 4 paineis vazios
#   ./claude-workspace.sh ~/proj1 ~/proj2   # com diretorios especificos
#
# Para reconectar depois: tmux attach -t claude

SESSION_NAME="claude"
PROJETO1="${1:-$HOME}"
PROJETO2="${2:-$HOME}"
PROJETO3="${3:-$HOME}"
PROJETO4="${4:-$HOME}"

# Mata sessao anterior se existir
tmux has-session -t $SESSION_NAME 2>/dev/null && tmux kill-session -t $SESSION_NAME

# Cria nova sessao
tmux new-session -d -s $SESSION_NAME -c "$PROJETO1"

# Nomeia primeira janela
tmux rename-window -t $SESSION_NAME:1 'workspace'

# Divide em 4 paineis (grid 2x2)
# Layout:  [0] | [1]
#          ---------
#          [2] | [3]

# Split vertical (cria painel 1 a direita)
tmux split-window -h -t $SESSION_NAME:1 -c "$PROJETO2"

# Split horizontal no painel 0 (cria painel 2 abaixo)
tmux split-window -v -t $SESSION_NAME:1.0 -c "$PROJETO3"

# Split horizontal no painel 1 (cria painel 3 abaixo)
tmux split-window -v -t $SESSION_NAME:1.1 -c "$PROJETO4"

# Envia comandos iniciais para cada painel
tmux send-keys -t $SESSION_NAME:1.0 "echo '=== Painel 1: Claude ===' && echo 'Diretorio: $PROJETO1' && echo 'Digite: claude'" Enter
tmux send-keys -t $SESSION_NAME:1.1 "echo '=== Painel 2: Claude ===' && echo 'Diretorio: $PROJETO2' && echo 'Digite: claude'" Enter
tmux send-keys -t $SESSION_NAME:1.2 "echo '=== Painel 3: Claude ===' && echo 'Diretorio: $PROJETO3' && echo 'Digite: claude'" Enter
tmux send-keys -t $SESSION_NAME:1.3 "echo '=== Painel 4: Comandos ===' && echo 'Use para: npm, git, testes, etc'" Enter

# Foca no painel 0
tmux select-pane -t $SESSION_NAME:1.0

# Mensagem de ajuda
echo "============================================"
echo "  Workspace Tmux criado: $SESSION_NAME"
echo "============================================"
echo ""
echo "Layout:"
echo "  [Painel 0] | [Painel 1]"
echo "  ----------------------"
echo "  [Painel 2] | [Painel 3]"
echo ""
echo "Atalhos (prefixo: Ctrl+a):"
echo "  Alt+Setas    - Navegar entre paineis"
echo "  Ctrl+a |     - Novo split vertical"
echo "  Ctrl+a -     - Novo split horizontal"
echo "  Ctrl+a z     - Zoom no painel atual"
echo "  Ctrl+a d     - Desconectar (sessao continua)"
echo ""
echo "Para reconectar: tmux attach -t $SESSION_NAME"
echo ""

# Anexa na sessao
tmux attach-session -t $SESSION_NAME
