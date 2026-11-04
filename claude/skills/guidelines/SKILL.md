---
name: guidelines
description: Guideline-driven development workflow. Use quando o usuario quer resolver um problema/feature/refactor SEM card Jira — apenas com prompt livre. Diferente de SDD (spec-driven), trabalha de forma dialogica e iterativa, em blocos pequenos, com checklist verificavel e journal de historico. Input — descricao do problema + boa pratica/principio a aplicar.
---

# Guideline-Driven Development

Workflow dialogico e iterativo. Voce NAO escreve uma spec formal antes. Voce traz o **problema + a direcao** (boa pratica, principio, restricao), discute com a IA, executa em blocos pequenos com checklist e journal.

## Filosofia em uma frase

> Problema + direcao → IA investiga e pergunta → discutem abordagem → executam em blocos → confirma → proximo bloco. Princípios sao o juiz, nao o teste sozinho.

## Quando usar esta skill

- Bug investigativo sem critérios prontos
- Otimização (query lenta, bundle grande, latência alta)
- Refactor exploratório
- Implementação de feature sem card Jira (ex: pedido informal "preciso que cadastro aceite OAuth")
- Decisões arquiteturais ainda em aberto

**Quando NAO usar:**
- Tem card Jira com critérios prontos → use `guidelines-jira`
- Bug trivial de 1 linha → responde direto, sem ceremony
- Feature greenfield grande com requisitos ambiguos e stakeholders multiplos → considere SDD para o documento inicial

## Input esperado

O usuario fornece:
1. **Problema** — o que esta acontecendo / o que precisa
2. **Direção** — qual boa prática/princípio/abordagem aplicar (opcional, mas recomendado)

Exemplo:
```
Problema: GET /orders/:userId/history demora 30s e trava a API.
Direcao: aplicar CQRS — separar leitura pesada em read model otimizado.
```

Se o usuario nao especificar direcao, **pergunte qual a abordagem preferida ANTES de propor solucao**. Nao chute.

## Workflow

### Fase 1 — Investigacao e alinhamento (conversacional)

NAO escreva codigo ainda. Antes de propor solucao:

1. **Leia o codigo relevante** (Grep, Read, exploracao)
2. **Mapeie o uso** — onde a coisa em questao e usada/chamada
3. **Liste perguntas criticas** — o que falta saber pra decidir abordagem
4. **Apresente diagnostico ao usuario** — o que voce achou + suas perguntas

Exemplo de output esperado nessa fase:
```
Olhei o codigo. A query GET /orders/:userId/history faz JOIN entre
orders, order_items, products, shipments. Filtra por userId, ordena
por created_at DESC, limita 50.

E usada em:
- handler GET /orders/:userId/history
- job de email de "pedido entregue"
- webhook de status pro app mobile

Nao vi cache nem denormalizacao. Indice em (userId, created_at) ok,
mas JOIN com shipments faz full scan (200M de linhas).

Antes de propor solucao, preciso saber:
1. Historico precisa ser tempo-real ou tolera latencia (ex: 5min)?
2. Os 3 consumidores precisam dos MESMOS campos?
3. Tem appetite pra materialized view, ou prefere tabela denormalizada
   mantida por trigger/CDC?
```

**Espera o usuario responder.** Iterar quantas vezes for preciso ate a abordagem ficar clara.

### Fase 2 — Proposta de abordagem

Quando tiver respostas suficientes, propor abordagem **concreta** com trade-offs:

```
Proposta:
- Tabela order_history_read denormalizada
- Debezium escuta orders/order_items/products/shipments → atualiza read
- Handler passa a ler de order_history_read direto (sem JOIN)
- Job/webhook ficam como estao (consultam so 2 campos, ja sao rapidos)

Trade-offs:
- Eventual consistency (~30s a 5min) — ok pelo que voce disse
- Custo extra: 1 tabela + 1 Debezium connector
- Backfill de 50M registros precisa cuidado pra nao travar banco

Concorda? Se sim, vou comecar pelo bloco 1 (migration + backfill batched).
```

**Espera confirmacao do usuario.** Aceita push-back e refina ("nao pode travar banco" → ajusta backfill pra lotes de 10k com pausa).

### Fase 3 — Criar checklist em blocos

Quando abordagem aprovada, cria diretorio de estado e checklist:

```
.claude/guideline-state/<slug>/
├── progress.md    # TODO list em blocos com [ ]
├── journal.md     # Historico narrativo (decisoes, falhas, licoes)
└── context.md     # Resumo do problema + direcao + abordagem decidida
```

**progress.md** exemplo:
```markdown
# Progress — otimizacao query order history

## Contexto
GET /orders/:userId/history demora 30s. Aplicando CQRS com read model
denormalizado via Debezium.

## Blocos
- [ ] Migration: criar tabela order_history_read
- [ ] Backfill batched (lotes de 10k, pausa entre lotes)
- [ ] Debezium connector: orders + order_items + products + shipments
- [ ] Adaptar handler GET /orders/:userId/history pra ler do read model
- [ ] Teste eventual consistency (gravar order, esperar < 5min, ler)
- [ ] Monitoring: lag do Debezium connector

## Restricoes (guardrails)
- Backfill NAO pode travar o banco
- Handler atual continua funcionando ate backfill terminar
- Codigo do job de email e webhook fica intocado nessa task

## Status
- Total: 6
- Feitos: 0
- Pendentes: 6
```

### Fase 4 — Executar em blocos (loop)

Para cada bloco:

1. **Pega 1 bloco** do progress.md (sempre o primeiro `[ ]`)
2. **Implementa** seguindo as restricoes e princípios do projeto (CLAUDE.md)
3. **Mostra diff** ao usuario antes de commitar
4. **Aguarda confirmacao** ("ok manda", "ajusta X", "reverte")
5. **Quando aprovado:** commita, marca `[x]` no progress.md, atualiza journal.md
6. **Proximo bloco**

Padrao de commit:
```
type(scope): descricao curta em minuscula
```
Sem ticket, scope opcional. Ex: `perf: add order_history_read denormalized table`.

### Fase 5 — Journal vivo

Apos CADA bloco, atualiza `journal.md`:

```markdown
# Journal — otimizacao query order history

## Bloco 1 ✅ — migration order_history_read
- Resultado: sucesso na primeira tentativa
- Commit: perf: add order_history_read denormalized table
- Decisao: incluir order_id, user_id, status, created_at, total, items_summary (jsonb)
- items_summary como jsonb pra evitar 1 join na leitura

## Bloco 2 ⚠️ — backfill batched
- Tentativa 1: UPDATE em lote de 100k → lock excessivo, abortado
- Tentativa 2: lotes de 10k com pg_sleep(0.1) entre lotes → ok
- Tentativa 3: monitorar pg_stat_activity pra pausar se long-running query aparecer
- Licao: backfill sempre verificar locks antes do proximo lote
- Commit: perf: add batched backfill script for order_history_read
```

**Quando falhar 2x na mesma abordagem:** leia journal, mude estrategia, registre por que mudou.

### Fase 6 — Fechamento

Quando todos `[x]`:

1. Confirma com usuario: "todos os blocos feitos, pronto pra abrir PR?"
2. Se sim, gera resumo do journal e abre PR (ou commita final)
3. Title segue conventional commit: `perf: optimize order history query with CQRS read model`
4. Body inclui:
   - Contexto (de context.md)
   - O que foi feito (de progress.md)
   - Decisoes importantes (do journal.md)
   - Como testar

## Modo autonomo (opcional)

Se a checklist ja esta clara e o usuario quer rodar em background:

```
"manda o ralph implementar o resto"
```

Voce pode lancar o runner Node em background pra executar o resto sem voce:
```bash
node ~/.claude/scripts/ralph-runner.js \
  --task-type guideline \
  --task-id <slug> \
  --max-iterations 20 \
  --cwd "$(pwd)" &
```

Cada iteracao do runner: contexto limpo, le `progress.md` + `journal.md` + `context.md`, pega proximo bloco, executa, commita, marca [x], atualiza journal, sai. Loop ate progress acabar.

## Principios obrigatorios

1. **NUNCA escreva codigo antes de alinhar abordagem.** Investigacao + perguntas primeiro.
2. **Sempre pergunte se faltar contexto.** Nao chute.
3. **Blocos pequenos.** 1 bloco = 1 commit = 1 mudanca focada. Se um bloco virar 500 linhas, quebra em 2.
4. **Diff antes de commit.** Mostra o que vai mudar, espera ok do usuario, ai commita.
5. **Journal honesto.** Registra falhas e licoes, nao so sucessos.
6. **Respeita CLAUDE.md do projeto.** Convencoes de codigo, naming, estilo — segue o que o projeto ja faz.
7. **Push-back e bem-vindo.** Se o usuario disser "nao gostei", refina e propoe alternativa. Nao insiste.

## Anti-padroes (NAO fazer)

- Escrever spec.md/plan.md/tasks.md formais antes de qualquer linha (isso e SDD, nao guideline)
- Pular fase de investigacao e ja propor solucao
- Implementar varios blocos numa tacada sem mostrar diff
- Engolir falhas no journal ("tudo certo!" quando teve 3 tentativas)
- Fugir do CLAUDE.md do projeto pra "fazer do seu jeito"
- Tratar progress.md como spec congelada — ele e vivo, adiciona/remove blocos conforme aprende

## Output esperado ao iniciar

Quando esta skill e invocada, sua primeira mensagem deve ser:

```
Vou aplicar o fluxo guideline-driven nessa task.

Antes de propor solucao, vou:
1. Ler o codigo relevante
2. Mapear o uso
3. Listar perguntas pra alinhar abordagem com voce

Comecando agora...
```

E entao executa Fase 1.
