---
name: constitution
description: Create or validate per-project constitution (non-negotiable principles). Auto-invoked before brainstorming when no constitution exists. Defines architectural and domain constraints that brainstorming, writing-plans, and pre-implementation-audit check against.
---

# Project Constitution

Create or update a per-project governance document with non-negotiable principles that all design and implementation must comply with.

Unlike CLAUDE.md (global coding standards), a constitution is **project-specific**: "this project never has more than 3 services", "every feature must work offline", "we never use ORMs here."

## When Triggered

- Automatically before brainstorming (via hook reminder) if no constitution exists
- Manually via `/constitution` to create or update

## Process

### If no constitution exists

1. **Scan project context** — read README, CLAUDE.md, package.json/pyproject.toml, existing architecture, config files, infra definitions
2. **Ask 5-7 focused questions** (one at a time, multiple choice when possible):

   **Architectural constraints:**
   - What are the hard structural limits? (max services, monolith vs distributed, monorepo vs polyrepo)
   - What is the deployment model? (serverless, containers, VMs, edge)
   
   **Technology decisions:**
   - What technologies are non-negotiable vs flexible? (language, DB, framework)
   - What patterns are explicitly forbidden? (ORMs, microservices, SPAs, etc.)
   
   **Quality priorities:**
   - Rank quality attributes: performance, security, DX, reliability, observability, cost (top 3 wins)
   
   **Domain constraints:**
   - What compliance/regulatory constraints exist? (LGPD, PCI-DSS, SOC2, none)
   - What are the operational non-negotiables? (uptime SLA, latency budget, data residency)

3. **Generate constitution** following the template below
4. **Save to** `docs/superpowers/constitution.md`
5. **Commit**: `chore: add project constitution`

### If constitution exists

1. **Load and display** current constitution summary
2. **Ask** what needs to change and why
3. **Update** with amendment entry (date + what changed + rationale)
4. **Commit**: `chore: amend project constitution`

## Constitution Template

```markdown
# [Project Name] Constitution

**Version**: 1.0 | **Created**: [DATE] | **Last Amended**: [DATE]

## Core Principles

### I. [Principle Name]
[Description — 1-2 sentences max]

**Rationale**: [Why this principle exists — the incident, constraint, or decision that birthed it]
**Violation policy**: BLOCK | WARN | JUSTIFY
<!-- BLOCK = never proceed, WARN = proceed with explicit acknowledgment, JUSTIFY = proceed if justification documented in plan -->

### II. [Principle Name]
...

(3-7 principles. More than 7 means the project scope is too broad or principles are too granular.)

## Forbidden Patterns

| Pattern | Why Forbidden | Exception |
|---------|--------------|-----------|
| [Pattern] | [Concrete reason] | [When it's OK, or "none"] |

## Quality Attribute Priorities

1. **[First]** — [Why this wins when trade-offs force a choice]
2. **[Second]** — [Why]
3. **[Third]** — [Why]

(Only top 3. Everything else is "nice to have.")

## Technology Constraints

| Area | Decision | Status | Rationale |
|------|----------|--------|-----------|
| Language | [e.g., TypeScript] | Non-negotiable | [Why] |
| Database | [e.g., PostgreSQL] | Non-negotiable | [Why] |
| Framework | [e.g., NestJS] | Flexible | [Current choice + why] |

## Operational Boundaries

- **Max services/packages**: [N]
- **Latency budget**: [e.g., p95 < 200ms]
- **Uptime SLA**: [e.g., 99.9%]
- **Data residency**: [e.g., BR only, or N/A]

## Amendment Log

| Date | Change | Rationale | Author |
|------|--------|-----------|--------|
| [DATE] | Initial constitution | Project kickoff | [Name] |
```

## Integration Points

This document is consumed by:
- **brainstorming** — spec self-review checks spec doesn't violate principles
- **writing-plans** — plan self-review checks tech decisions against constraints
- **pre-implementation-audit** — cross-references all artifacts against constitution
- **phase-gate** — constitution compliance is a checklist item in both gates

## Rules

- Constitution is non-negotiable within its scope. If a principle needs to change, amend the constitution explicitly — don't silently ignore it
- Keep it short. A constitution that nobody reads is worse than no constitution
- Principles must have rationale. "No ORMs" without why is just dogma
- Violation policy must be explicit per principle. Not everything is a hard block
- Review constitution when project direction changes significantly
