---
name: phase-gate
description: Formal quality checklists between pipeline phases (brainstorming→plans, plans→execution). Auto-invoked after spec and plan writes. Validates automatically where possible, blocks on critical failures.
---

# Phase Gate

Formal quality checklist between pipeline phases. Generated automatically, validated automatically, blocks if critical items fail.

## When Triggered

- After brainstorming writes a spec (via hook reminder)
- After writing-plans writes a plan (via hook reminder)
- Manually via `/phase-gate`

## Process

### 1. Detect Phase

Look for the most recent artifacts:
- Spec exists, no plan → **Post-Spec Gate** (brainstorming → writing-plans)
- Plan exists → **Post-Plan Gate** (writing-plans → execution)

If both exist and user didn't specify, ask which gate to run.

### 2. Load Artifacts

- Read the relevant spec/plan file
- Read constitution if it exists
- Read any existing gate reports to avoid re-running

### 3. Run the appropriate gate

---

## Post-Spec Gate (brainstorming → writing-plans)

Validate the spec is ready for technical planning.

### Checklist

**Content Quality** (auto-validated)
- [ ] No implementation details — scan for framework names, DB names, language specifics, infra terms (React, NestJS, PostgreSQL, TypeScript, Kubernetes, Lambda, S3, etc.)
- [ ] All mandatory sections completed (User Scenarios, Requirements, Success Criteria)
- [ ] No empty/placeholder sections

**Requirement Quality** (auto-validated)
- [ ] All requirements are testable — each has a verb + measurable outcome
- [ ] Success criteria are technology-agnostic — no framework/DB/language mentions
- [ ] Success criteria are measurable — contain numbers, percentages, time units
- [ ] No `[NEEDS CLARIFICATION]` or `[TBD]` or `[TODO]` markers remain

**Clarification Coverage** (auto-validated — scan for presence of each category)
- [ ] Functional Scope covered: goals, out-of-scope, user roles mentioned
- [ ] Domain & Data covered: entities, relationships mentioned (if data feature)
- [ ] Interaction & UX covered: user journeys, error states mentioned (if UI feature)
- [ ] Non-Functional covered: performance, security, observability mentioned

**Constitution Alignment** (auto-validated if constitution exists)
- [ ] Spec doesn't mention technologies forbidden by constitution
- [ ] Quality priorities from constitution reflected in success criteria

**Readiness** (requires human judgment)
- [ ] User has reviewed and approved the spec

### Validation Logic

For each auto-validated item:
1. Read the spec content
2. Apply the check (regex scan, section existence, keyword match)
3. Mark ✅ PASS or ❌ FAIL with specific evidence

**Technology leak detection** — scan spec for these patterns:
```
/\b(React|Next\.?js|Vue|Angular|Svelte|NestJS|Express|FastAPI|Django|Flask|Spring|Rails)\b/i
/\b(PostgreSQL|MySQL|MongoDB|Redis|DynamoDB|Firestore|SQLite|Prisma|Drizzle|Kysely)\b/i
/\b(TypeScript|JavaScript|Python|Go|Rust|Java|Kotlin|Swift|C#)\b/i
/\b(Kubernetes|Docker|Lambda|S3|EC2|CloudFront|Terraform|Helm|Vercel|Netlify)\b/i
/\b(REST|GraphQL|gRPC|tRPC|WebSocket|SSE)\b/i
/\b(JWT|OAuth2?|OIDC|Auth0|Cognito)\b/i
```

If matches found → FAIL "Implementation detail leaked: [match] on line [N]. Rephrase in user-facing terms."

---

## Post-Plan Gate (writing-plans → execution)

Validate the plan is ready for implementation.

### Checklist

**Plan Completeness** (auto-validated)
- [ ] Every task has exact file paths (scan for `Create:`, `Modify:`, `Test:` in tasks)
- [ ] Every task has code blocks (no empty implementation steps)
- [ ] No placeholders — scan for: `TBD`, `TODO`, `implement later`, `fill in`, `similar to Task`, `add appropriate`, `handle edge cases`
- [ ] TDD structure present — tasks contain test → verify fail → implement → verify pass pattern

**Architecture Quality** (requires judgment)
- [ ] Tech decisions have documented rationale
- [ ] File structure defined with responsibilities
- [ ] No unnecessary abstraction (YAGNI)

**Constitution Compliance** (auto-validated if constitution exists)
- [ ] No forbidden patterns used (match plan tech against constitution forbidden list)
- [ ] Tech constraints respected (match plan stack against constitution requirements)
- [ ] Quality priorities reflected in task ordering

**Cross-Artifact Consistency** (auto-validated)
- [ ] No orphan requirements — every spec requirement mentioned in at least one task description
- [ ] No phantom tasks — every task references a spec requirement or is infrastructure/setup
- [ ] Success criteria have verification — each criterion maps to a test or validation step

**Execution Readiness** (requires judgment)
- [ ] Worktree strategy decided
- [ ] Execution mode chosen (subagent vs inline)
- [ ] All unknowns resolved

### Validation Logic

For placeholder detection, scan plan for:
```
/\b(TBD|TODO|FIXME|HACK|XXX)\b/
/implement later|fill in|details later/i
/similar to Task \d+/i
/add (appropriate|necessary|proper) (error handling|validation|logging)/i
/handle (edge cases|errors|exceptions)/i  (without specific code following)
```

For cross-artifact consistency, extract:
- Spec requirement IDs/descriptions → search plan text for matches
- Plan task descriptions → search spec text for backing requirement

---

## Gate Decision

### Scoring

- **PASS**: All auto-validated items pass + human items confirmed
- **WARN**: Only non-critical failures (architecture quality, YAGNI)
- **BLOCK**: Any critical failure:
  - Post-Spec: technology leaks, missing mandatory sections, unresolved clarifications
  - Post-Plan: placeholders, orphan requirements, constitution violations

### Behavior

- **PASS** → "Gate passed. Proceeding to [next phase]."
- **WARN** → Show warnings. "These are non-critical. Proceed or fix?" Wait for user.
- **BLOCK** → "Gate BLOCKED on [N] critical items:" + list each with evidence. "Fix and re-run /phase-gate." Do NOT proceed.

## Save Checklist

Save completed checklist to:
- Post-Spec: `docs/superpowers/gates/YYYY-MM-DD-<feature>-spec-gate.md`
- Post-Plan: `docs/superpowers/gates/YYYY-MM-DD-<feature>-plan-gate.md`

## Rules

- Always save the gate report even if PASS — it's an audit trail
- Be specific in failures — quote the offending text, give line context
- Technology leak detection is intentionally aggressive. Better to flag a false positive than miss a real leak
- Constitution compliance is skipped silently if no constitution exists (don't block on missing constitution)
- Re-running a gate overwrites the previous report for the same feature/phase
