#!/usr/bin/env node
/**
 * PreToolUse / Skill + Edit|Write — garante que as skills obrigatorias foram
 * invocadas ANTES de tocar em codigo.
 *
 * O `skills-obrigatorias.js` vive em UserPromptSubmit, que so injeta texto no prompt:
 * e lembrete, nao porteiro. O `guard-skills-dispatch.js` so cobre despacho de agente.
 * Resultado: implementacao direta passava sem nenhuma skill, que foi exatamente o que
 * aconteceu na tela de login do React (code-quality invocada so na revisao, depois da
 * PR aberta).
 *
 * Este hook fecha esse buraco com dois papeis no mesmo arquivo:
 *   - em `Skill`, anota qual skill foi invocada nesta sessao
 *   - em `Edit|Write`, nega a edicao de arquivo de codigo enquanto faltar alguma
 *
 * O custo e uma invocacao por sessao. Depois disso a marca persiste e ninguem e
 * incomodado de novo.
 */
const fs = require('fs')
const path = require('path')
const os = require('os')

const RAIZ_ESTADO = path.join(os.homedir(), '.claude', '.state', 'skills-por-sessao')
const VALIDADE_MS = 7 * 24 * 60 * 60 * 1000

/**
 * Grupos de skills exigidos por extensao. Cada grupo e um "pelo menos uma destas":
 * `.tsx` aceita `typescript` ou `react`, porque as duas cobrem o arquivo.
 */
const EXIGENCIAS = {
  '.ts': [['code-quality'], ['typescript']],
  '.mts': [['code-quality'], ['typescript']],
  '.cts': [['code-quality'], ['typescript']],
  '.js': [['code-quality'], ['typescript']],
  '.mjs': [['code-quality'], ['typescript']],
  '.cjs': [['code-quality'], ['typescript']],
  '.tsx': [['code-quality'], ['typescript', 'react']],
  '.jsx': [['code-quality'], ['typescript', 'react']],
  '.go': [['code-quality'], ['go']],
}

/**
 * Fora do gate de proposito: mexer no proprio ferramental (hooks, settings, skills)
 * nao e implementar feature, e travar isso criaria um ciclo — o hook impediria a
 * propria correcao do hook.
 */
function eMetaTrabalho(arquivo) {
  const normalizado = arquivo.replace(/\\/g, '/')
  return normalizado.includes('/.claude/')
}

function arquivoDeEstado(sessao) {
  return path.join(RAIZ_ESTADO, `${String(sessao || 'sem-sessao').replace(/[^\w-]/g, '')}.json`)
}

function leSkills(sessao) {
  try {
    return new Set(JSON.parse(fs.readFileSync(arquivoDeEstado(sessao), 'utf8')).skills || [])
  } catch {
    return new Set()
  }
}

function anotaSkill(sessao, skill) {
  try {
    fs.mkdirSync(RAIZ_ESTADO, { recursive: true })
    const skills = leSkills(sessao)
    skills.add(skill)
    fs.writeFileSync(arquivoDeEstado(sessao), JSON.stringify({ skills: [...skills] }))
    limpaAntigos()
  } catch {
    // Estado e otimizacao, nao verdade: falhar aqui nao pode derrubar a sessao.
    // O custo de perder a marca e uma invocacao a mais da skill.
  }
}

function limpaAntigos() {
  try {
    const limite = Date.now() - VALIDADE_MS
    for (const nome of fs.readdirSync(RAIZ_ESTADO)) {
      const alvo = path.join(RAIZ_ESTADO, nome)
      if (fs.statSync(alvo).mtimeMs < limite) fs.unlinkSync(alvo)
    }
  } catch {
    // idem
  }
}

function saida(obj) {
  process.stdout.write(JSON.stringify(obj))
  process.exit(0)
}

function nega(motivo) {
  saida({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: motivo,
    },
  })
}

let bruto = ''
process.stdin.on('data', (c) => (bruto += c))
process.stdin.on('end', () => {
  let evento
  try {
    evento = JSON.parse(bruto)
  } catch {
    saida({})
  }

  const ferramenta = evento?.tool_name || ''
  const sessao = evento?.session_id

  if (ferramenta === 'Skill') {
    const skill = String(evento?.tool_input?.skill || '')
    // Plugins vem como `plugin:skill`; o que interessa e o nome final.
    if (skill) anotaSkill(sessao, skill.split(':').pop())
    saida({})
  }

  if (ferramenta !== 'Edit' && ferramenta !== 'Write') saida({})

  const arquivo = String(evento?.tool_input?.file_path || '')
  if (!arquivo || eMetaTrabalho(arquivo)) saida({})

  const grupos = EXIGENCIAS[path.extname(arquivo).toLowerCase()]
  if (!grupos) saida({})

  const invocadas = leSkills(sessao)
  const faltando = grupos.filter((grupo) => !grupo.some((s) => invocadas.has(s)))
  if (faltando.length === 0) saida({})

  const lista = faltando.map((grupo) => grupo.join(' ou ')).join(', ')
  nega(
    `Edicao de codigo sem as skills obrigatorias desta sessao. Falta: ${lista}.\n\n` +
      `Invoque com a ferramenta Skill antes de editar ${path.basename(arquivo)}. ` +
      `E uma vez por sessao: depois disso a marca persiste e este gate nao incomoda mais.\n\n` +
      `O CLAUDE.md define o minimo universal para codigo como code-quality + a skill da ` +
      `linguagem. Este hook existe porque o lembrete em UserPromptSubmit nao bloqueia nada, ` +
      `e implementacao direta passava sem nenhuma skill.`,
  )
})
