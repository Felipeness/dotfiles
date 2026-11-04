#!/usr/bin/env node

/**
 * Pipeline Precheck Hook — PreToolUse on Skill
 *
 * Hard enforcement: checks prerequisites before allowing execution skills.
 * - Before subagent-driven-development/executing-plans: requires audit + gate
 * - Before writing-plans: requires the Post-Spec gate when a spec exists
 * - Before brainstorming: requires a constitution when the project already has artifacts
 *
 * Duas correcoes em cima da versao original:
 *
 * 1. O bloqueio era MUDO. Escrevia o motivo em `process.stdout.write` e saia com
 *    exit 2, mas exit 2 so entrega a mensagem pela stderr — no stdout ela e
 *    descartada. Na pratica o bloqueio chegava como "No stderr output", sem razao
 *    nenhuma, e so lendo o fonte deste arquivo dava para descobrir o porque.
 *    Agora usa a forma JSON de decisao, que e a mesma do `pre-pr-gate.js` e chega
 *    com o texto completo.
 *
 * 2. A constitution era procurada SO no cwd da sessao. Trabalho que atravessa repos
 *    (sessao aberta no backend, feature no frontend) era bloqueado por um estado de
 *    repo que nao tinha relacao nenhuma com o que estava sendo feito. Agora aceita
 *    tambem uma constitution no nivel do workspace, que serve de linha de base
 *    compartilhada entre os repos irmaos.
 */

const fs = require('fs');
const path = require('path');

let raw = '';
process.stdin.on('data', (chunk) => (raw += chunk));
process.stdin.on('end', () => {
  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    permite();
  }

  const skillName = input.tool_input?.skill || '';
  const cwd = input.cwd || process.cwd();
  const superDir = path.join(cwd, 'docs', 'superpowers');

  // --- Gate: execution skills require audit + phase-gate ---
  const executionSkills = [
    'superpowers:subagent-driven-development',
    'superpowers:executing-plans',
  ];

  if (executionSkills.includes(skillName)) {
    const plansDir = path.join(superDir, 'plans');
    const auditsDir = path.join(superDir, 'audits');
    const gatesDir = path.join(superDir, 'gates');

    // Only enforce if there are plans (otherwise it's a different workflow)
    if (fs.existsSync(plansDir)) {
      const plans = safeReaddir(plansDir).filter((f) => f.endsWith('.md'));
      if (plans.length > 0) {
        const hasAudit =
          fs.existsSync(auditsDir) &&
          safeReaddir(auditsDir).some((f) => f.endsWith('-audit.md'));

        const hasPlanGate =
          fs.existsSync(gatesDir) &&
          safeReaddir(gatesDir).some((f) => f.includes('-plan-gate'));

        const missing = [];
        if (!hasAudit) missing.push('/pre-implementation-audit');
        if (!hasPlanGate) missing.push('/phase-gate (Post-Plan Gate)');

        if (missing.length > 0) {
          nega(
            'Execucao bloqueada: o pipeline exige estas etapas antes.\n\n' +
              missing.map((m) => `  - ${m}`).join('\n') +
              `\n\nArtefatos esperados em ${superDir}. Rode as etapas acima e tente de novo.`
          );
        }
      }
    }

    permite();
  }

  // --- Gate: brainstorming should check constitution ---
  if (skillName === 'superpowers:brainstorming') {
    if (fs.existsSync(superDir) && !encontraConstitution(cwd)) {
      // If project already has specs or plans, constitution is mandatory (blocking)
      const specsDir = path.join(superDir, 'specs');
      const plansDir = path.join(superDir, 'plans');
      const hasArtifacts =
        (fs.existsSync(specsDir) && safeReaddir(specsDir).some((f) => f.endsWith('.md'))) ||
        (fs.existsSync(plansDir) && safeReaddir(plansDir).some((f) => f.endsWith('.md')));

      if (hasArtifacts) {
        nega(
          'Brainstorming bloqueado: o projeto ja tem specs ou plans, mas nao tem constitution.\n\n' +
            `Procurei em:\n${caminhosDeConstitution(cwd).map((p) => `  - ${p}`).join('\n')}\n\n` +
            'Rode /constitution para definir os principios nao-negociaveis antes de desenhar ' +
            'a proxima feature. Uma constitution no nivel do workspace serve para os repos irmaos.'
        );
      }

      // New project (no artifacts yet) — reminder only, non-blocking
      avisa(
        'Nenhuma constitution encontrada em docs/superpowers/constitution.md. ' +
          'Considere rodar /constitution para definir os principios do projeto. ' +
          'Recomendado, nao bloqueante.'
      );
    }
    permite();
  }

  // --- Gate: writing-plans should have spec gate ---
  if (skillName === 'superpowers:writing-plans') {
    const gatesDir = path.join(superDir, 'gates');
    const specsDir = path.join(superDir, 'specs');

    if (fs.existsSync(specsDir)) {
      const specs = safeReaddir(specsDir).filter((f) => f.endsWith('-design.md'));
      if (specs.length > 0) {
        const hasSpecGate =
          fs.existsSync(gatesDir) &&
          safeReaddir(gatesDir).some((f) => f.includes('-spec-gate'));

        if (!hasSpecGate) {
          nega(
            'Planejamento bloqueado: existe spec mas nao existe Post-Spec Gate.\n\n' +
              `Esperado um arquivo com "-spec-gate" em ${gatesDir}.\n` +
              'Rode /phase-gate para validar a spec antes de planejar.'
          );
        }
      }
    }
    permite();
  }

  permite();
});

/**
 * Constitution do repo corrente ou do workspace que o contem.
 *
 * O fallback de workspace existe porque a sessao fica enraizada num repo e o trabalho
 * frequentemente acontece em outro ao lado. Sem ele, o gate bloqueia por um estado que
 * nao tem relacao com a feature em maos.
 */
function caminhosDeConstitution(cwd) {
  return [
    path.join(cwd, 'docs', 'superpowers', 'constitution.md'),
    path.join(path.dirname(cwd), 'docs', 'superpowers', 'constitution.md'),
  ];
}

function encontraConstitution(cwd) {
  return caminhosDeConstitution(cwd).some((p) => fs.existsSync(p));
}

function emite(obj) {
  process.stdout.write(JSON.stringify(obj));
  process.exit(0);
}

function permite() {
  emite({});
}

function avisa(mensagem) {
  emite({
    systemMessage: `[Pipeline Precheck] ${mensagem}`,
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      additionalContext: `[Pipeline Precheck] ${mensagem}`,
    },
  });
}

function nega(motivo) {
  emite({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: `[Pipeline Precheck] ${motivo}`,
    },
  });
}

function safeReaddir(dir) {
  try {
    return fs.readdirSync(dir);
  } catch {
    return [];
  }
}
