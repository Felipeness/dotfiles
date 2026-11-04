---
name: pre-implementation-audit
description: Cross-artifact consistency analysis between spec, plan, and tasks. Read-only — reports gaps and inconsistencies. Runs automatically between writing-plans and execution. Blocks execution if critical inconsistencies found.
disallowed-tools: Edit, Write, NotebookEdit
---

# Pre-Implementation Audit

Systematically cross-reference spec, plan, and constitution before spending tokens on implementation. Find inconsistencies BEFORE they become bugs or wasted work.

**This is a read-only analysis.** It reports problems but does not fix them.

## When Triggered

- Automatically after writing-plans completes (via hook)
- Manually via `/pre-implementation-audit`

## Process

### 1. Locate Artifacts

Find the latest versions:
- **Spec**: `docs/superpowers/specs/*-design.md` (most recent by date prefix)
- **Plan**: `docs/superpowers/plans/*.md` (most recent by date prefix)
- **Constitution**: `docs/superpowers/constitution.md` (if exists)

If spec or plan is missing → abort with: "Missing [artifact]. Run [brainstorming|writing-plans] first."

### 2. Forward Traceability (Spec → Plan)

For each requirement/user story/success criterion in the spec, verify:

| Check | How | Severity |
|-------|-----|----------|
| Every requirement has corresponding task(s) in plan | Match by keyword/intent | CRITICAL if missing |
| Every success criterion has a verification mechanism | Check for test/validation task | CRITICAL if missing |
| Every user story maps to plan tasks | Trace story → tasks | CRITICAL if missing |
| Scope boundaries respected (no scope creep) | Plan tasks within spec scope | WARN if exceeded |

### 3. Reverse Traceability (Plan → Spec)

For each task in the plan, verify:

| Check | How | Severity |
|-------|-----|----------|
| Every task traces to a spec requirement | Match back to spec | WARN if phantom |
| No "gold plating" (features not in spec) | Compare plan scope vs spec scope | WARN |
| Tech decisions don't contradict spec constraints | Cross-reference | CRITICAL if contradiction |

### 4. Constitution Compliance

If constitution exists, for each principle:

| Check | How | Severity |
|-------|-----|----------|
| Spec doesn't violate principles | Read principle, check spec | Per violation policy |
| Plan doesn't use forbidden patterns | Check against forbidden list | Per violation policy |
| Quality priorities reflected | Top 3 attributes in plan | WARN if missing |
| Tech constraints respected | Check plan tech stack | CRITICAL if violated |

### 5. Clarification Taxonomy Coverage

Verify the spec covers all categories. Mark each as **Covered / Partial / Missing**:

| Category | Subcategories to check |
|----------|----------------------|
| **Functional Scope** | Core goals, explicit out-of-scope, user roles/personas |
| **Domain & Data** | Entities, relationships, identity/uniqueness, lifecycle/state transitions, scale assumptions |
| **Interaction & UX** | Critical user journeys, error/empty/loading states, accessibility |
| **Non-Functional** | Performance targets, scalability, reliability/availability, observability, security/privacy, compliance |

Missing Functional Scope items → CRITICAL
Missing Non-Functional security/compliance → CRITICAL
Other missing items → WARN

### 6. Internal Consistency

| Check | How | Severity |
|-------|-----|----------|
| Plan file structure matches task file paths | Cross-reference | WARN |
| Type/function names consistent across tasks | Scan for naming conflicts | WARN |
| Dependencies between tasks are acyclic | Trace dependency chain | CRITICAL if cycle |
| TDD steps present for each task | Check test → fail → implement → pass pattern | WARN |

### 7. Generate Report

```markdown
# Pre-Implementation Audit Report

**Spec**: [filename] | **Plan**: [filename] | **Date**: [DATE]
**Constitution**: [filename or "N/A"]

## Summary

| Metric | Count |
|--------|-------|
| Spec requirements | N |
| Plan tasks | N |
| Forward coverage (req → task) | N/N (X%) |
| Reverse traceability (task → req) | N/N (X%) |
| Constitution violations | N |

## Forward Traceability (Spec → Plan)

| Spec Item | Plan Task(s) | Status |
|-----------|-------------|--------|
| FR-001: [desc] | Task 1, Task 3 | ✅ Covered |
| FR-002: [desc] | — | ❌ MISSING |
| SC-001: [desc] | Task 7 | ✅ Covered |

## Reverse Traceability (Plan → Spec)

| Plan Task | Spec Item | Status |
|-----------|-----------|--------|
| Task 5: [desc] | — | ⚠️ Phantom (no spec backing) |

## Clarification Coverage

| Category | Status | Gap |
|----------|--------|-----|
| Functional Scope | ✅ Covered | — |
| Domain & Data | ⚠️ Partial | State transitions undefined |
| Non-Functional | ⚠️ Partial | No observability targets |

## Constitution Compliance

| Principle | Status | Detail |
|-----------|--------|--------|
| I. [name] | ✅ | — |
| II. [name] | ❌ VIOLATION | [what violates + violation policy] |

## Verdict: [PASS | WARN | BLOCK]

### Critical Issues (must fix)
1. [Issue + what to fix]

### Warnings (recommended to fix)
1. [Issue + suggestion]
```

### 8. Save Report

Save to `docs/superpowers/audits/YYYY-MM-DD-<feature>-audit.md`

### 9. Gate Decision

- **PASS** (0 critical) → "Audit passed. Clear to proceed to execution."
- **WARN** (0 critical, N warnings) → Show warnings. Ask: "Proceed with these warnings, or fix first?"
- **BLOCK** (N critical) → "Audit BLOCKED. Fix these issues before execution:" + list. Do NOT proceed.

## What Counts as Critical?

- Spec requirement with no plan task → CRITICAL
- Success criterion with no verification → CRITICAL
- Constitution violation with BLOCK policy → CRITICAL
- Missing Functional Scope coverage → CRITICAL
- Missing security/compliance coverage → CRITICAL
- Dependency cycle in tasks → CRITICAL

Everything else → WARN

## Rules

- This is READ-ONLY. Never modify spec, plan, or constitution during audit
- Report ALL findings, not just critical ones
- Be specific — quote the spec requirement and the missing task, don't just say "incomplete"
- If constitution doesn't exist, skip constitution checks (don't block on missing constitution)
- Audit the LATEST versions of artifacts (most recent date prefix)
