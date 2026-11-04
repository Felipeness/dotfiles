---
name: ux-persona-design
description: Use before any frontend design work — maps user persona, journey, edge cases, design principles, and color system before touching code. Prevents generic AI-generated UIs.
---

# UX Persona-Driven Design

Before writing ANY frontend code, go through this checklist. Generic UIs happen when you skip the thinking.

## Checklist

1. **Define the persona** — one at a time, answer each:
2. **Map the journey** — step by step what they expect
3. **List edge cases** — everything that can go wrong
4. **Define design principles** — specific to this audience
5. **Choose aesthetic direction** — not "clean and modern" but a CONCEPT
6. **Define color system** — with reasoning for each choice
7. **Research references** — what do competitors look like?
8. **Only THEN code**

## 1. Persona Template

```
Nome: [Nome fictício, idade, profissão]
Experiência tech: [1-10, onde 1 = só usa WhatsApp, 10 = desenvolvedor]
Ferramentas diárias: [o que usa todo dia — Word, email, sistema X]
O que quer: [em UMA frase, na linguagem dele]
O que tem medo: [o que o faria desistir do produto]
Contexto de uso: [onde, quando, em que dispositivo]
Paciência para aprender: [baixa/média/alta]
```

## 2. User Journey Mapping

Para cada ação principal do usuário, mapeie:

```
Passo | O que ele espera | O que ele vê | Sentimento desejado
------|------------------|-------------|--------------------
1     | ...              | ...         | Confiança
2     | ...              | ...         | Clareza
...   | ...              | ...         | Satisfação
```

Regras:
- Máximo 7 passos até o resultado principal
- Cada passo tem UMA ação óbvia (não menus complexos)
- O usuário nunca deve pensar "e agora?"
- Feedback visual em cada transição

## 3. Edge Cases Table

Mapeie TODOS os cenários onde algo pode dar errado:

```
| Situação | O que acontece hoje | O que deveria acontecer |
|----------|-------------------|----------------------|
| ...      | ...               | Mensagem amigável + ação |
```

Categorias obrigatórias:
- **Input inválido** (formato errado, vazio, muito grande)
- **Rede** (internet cai, timeout, servidor fora)
- **Estado** (fecha aba, volta depois, sessão expira)
- **Duplicação** (clica duas vezes, submete de novo)
- **Sucesso inesperado** (tudo OK, resultado vazio)
- **Permissão** (não autorizado, plano expirado)

## 4. Design Principles (específicos por audiência)

Para cada público, escolha 5-6 princípios. Exemplos:

**Profissionais não-tech (advogados, médicos, contadores):**
- Progressividade — revelar informação gradualmente
- Linguagem do domínio — usar termos da profissão, não técnicos
- Confiança visual — fontes sóbrias, cores profissionais, disclaimers
- Legibilidade — contraste alto, line-height generoso
- Ação óbvia — sempre claro qual é o próximo passo
- Feedback constante — nunca tela "parada" sem explicação

**Desenvolvedores / power users:**
- Densidade informacional — mais dados por pixel
- Atalhos de teclado — ctrl+k, shortcuts
- Customização — temas, layouts, preferências
- Log/debug visível — mostrar o que está acontecendo
- Batch operations — selecionar múltiplos, ações em massa

**Consumidores finais (apps B2C):**
- Gamificação sutil — progress, achievements
- Social proof — "X pessoas usaram hoje"
- Onboarding guiado — tutorial interativo
- Emotividade — cores vibrantes, micro-animações
- Simplicidade radical — 1 botão, 1 ação

## 5. Aesthetic Direction

NÃO use termos genéricos ("clean", "modern", "minimal"). Use um CONCEITO:

Exemplos:
- "Escritório à Noite" — dark surfaces, warm amber, authority
- "Consultório Clínico" — white, mint, precision, calm
- "Redação de Jornal" — editorial, typography-first, dense
- "Cockpit de Aviação" — dark, data-dense, neon accents
- "Galeria de Arte" — white space, dramatic typography, serif
- "Oficina Mecânica" — industrial, bold, high contrast

O conceito guia TODAS as decisões (cor, fonte, espaçamento, iconografia).

## 6. Color System

Definir com razão para cada cor:

```
Background:  #XXX — [por que esse tom? que sensação cria?]
Surface:     #XXX — [como se distingue do background?]
Accent:      #XXX — [que emoção? que ação associa?]
Text:        #XXX — [legibilidade no background escolhido]
Semantic:    success/warning/danger — [seguir convenção ou customizar?]
```

Restrições:
- Máximo 5-8 cores no sistema
- Contrast ratio mínimo 4.5:1 para texto (WCAG AA)
- Accent color usado em no máximo 10% da superfície
- Sempre definir hover, active, e disabled variants

## 7. Research References

Antes de definir o design:
- Buscar 3-5 produtos do mesmo domínio
- Identificar patterns comuns (o que funciona)
- Identificar oportunidades (o que ninguém faz)
- Screenshot ou descrever os layouts

## 8. Implementation Handoff

Só depois dos passos 1-7, definir:
- Design tokens (CSS variables)
- Component library (quais componentes)
- Font stack (display + body + mono)
- Icon set (lucide, heroicons, custom)
- Animation style (sutil? bold? nenhuma?)
- Breakpoints (mobile-first? desktop-first?)

## Anti-patterns (NUNCA fazer)

- Começar pelo código sem definir a persona
- Usar cores sem justificativa ("azul porque é bonito")
- Copiar um template sem adaptar ao público
- Ignorar edge cases ("depois a gente trata")
- Design "clean and modern" sem conceito (= genérico)
- Mesma UI para advogado e para developer
- Adicionar features sem pensar no fluxo do usuário
- Esquecer feedback states (loading, empty, error, success)
