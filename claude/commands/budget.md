---
description: Mostra seu limite e consumo no gateway LLM da Superlógica
allowed-tools: Bash(C:/Users/felip/bin/claude-statusline.exe budget:*)
---
<!-- gerado por claude-statusline; reinstalar sobrescreve, apagar desinstala -->
Budget do usuário no gateway:

!`C:/Users/felip/bin/claude-statusline.exe budget --json`

Apresente em português, sem tabela:
- Quanto já gastou e qual o teto, em reais (spent_brl e limit_brl já vêm em reais; o campo raw traz os valores originais em micro-reais). Diga o percentual (pct).
- Quando a janela reseta (window_end) e qual o período (period).
- Se scope for license, explique que não há teto individual e que os valores são o agregado da licença, não só dele.
- Se base_limit_brl for maior que limit_brl, explique que o teto individual está limitado pelo teto da licença.
- Se exceeded for true, diga que o acesso está bloqueado até a data de reset.
- Se vier stale true, avise que os dados são de fetched_at porque o gateway não respondeu agora.
- Se vier cache_write_error, diga que o consumo está certo mas não deu pra gravar em cache local, e mencione isso rapidamente.
- Se vier error, explique o que falta configurar e aponte a página "Ativando o Claude via LLM Gateway" no Confluence.
