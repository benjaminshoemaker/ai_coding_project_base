# Execution Toolkit Generator

Generate an execution toolkit from product and technical specifications. This prompt produces two documents with distinct purposes:

- **EXECUTION_PLAN.md** — What to build (tasks, acceptance criteria, dependencies)
- **AGENTS.md** — How to work (workflow rules, guardrails, verification protocol)

---

## The Prompt

```
I need you to generate an execution toolkit from the attached specifications (PRODUCT_SPEC.md and TECHNICAL_SPEC.md).

Generate two documents:
1. EXECUTION_PLAN.md — Task breakdown with acceptance criteria
2. AGENTS.md — Workflow guidelines for AI agents

Read `~/.claude/skills/shared/EXECUTION_PLAN_FORMAT.md` for the execution hierarchy definitions,
verification types, EXECUTION_PLAN.md template structure, task quality checks, red flags, and
post-generation checklist. Use those definitions verbatim — do not redefine or paraphrase them.

Before assigning any (MANUAL) or (MANUAL:DEFER) tag to an acceptance criterion or checkpoint item,
read `~/.claude/skills/auto-verify/PATTERNS.md` and walk through the MANUAL Decision Tree (steps 1-9).
Only assign MANUAL if you reach step 9 (subjective judgment). If any earlier step matches, use the
automated verification type instead.

══════════════════════════════════════════════════════════════════════════════
DOCUMENT RESPONSIBILITIES
══════════════════════════════════════════════════════════════════════════════

EXECUTION_PLAN.md owns:
- Task definitions and acceptance criteria
- File create/modify lists
- Dependencies between tasks
- Spec references
- Pre-phase setup requirements
- Phase checkpoint criteria

AGENTS.md owns:
- Workflow mechanics (how agents pick up and complete tasks)
- TDD policy and testing requirements
- Context management between tasks
- Guardrails and "when to stop" triggers
- Verification protocol
- Git conventions
- Minimal project context (tech stack, dev server only)

AGENTS.md does NOT include:
- Error handling patterns (agents discover from codebase)
- Mocking strategies (agents infer from test framework)
- Naming conventions (agents follow existing code)
- Detailed file structures (agents explore the repo)

══════════════════════════════════════════════════════════════════════════════
GENERATION INSTRUCTIONS
══════════════════════════════════════════════════════════════════════════════

Before generating:

1. **Identify phases** — Major functional areas from the spec become phases
2. **Map dependencies** — What must exist before each component can be built
3. **Group into steps** — Related tasks that should complete together
4. **Break into tasks** — Atomic units with 3-6 testable acceptance criteria each
5. **Identify setup** — External services, env vars, manual prerequisites per phase
6. **Define checkpoints** — What demonstrates each phase is complete

Additional greenfield task quality check:
✓ Requirement field links to REQ-XXX from PRODUCT_SPEC.md (or "None" for infrastructure tasks)

══════════════════════════════════════════════════════════════════════════════
SPECIFICATION DOCUMENTS
══════════════════════════════════════════════════════════════════════════════

## PRODUCT_SPEC.md

{Paste or attach PRODUCT_SPEC.md here — provides product context: problem, users, MVP scope}

## TECHNICAL_SPEC.md

{Paste or attach TECHNICAL_SPEC.md here — provides technical details: architecture, data models, APIs}

══════════════════════════════════════════════════════════════════════════════

Read `.claude/skills/generate-plan/AGENTS_TEMPLATE.md` and use its contents as the AGENTS.md template (do not paraphrase or summarize — use the template verbatim, filling in project-specific values).

Generate:
1. EXECUTION_PLAN.md
2. AGENTS.md
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Contradictions between PRODUCT_SPEC.md and TECHNICAL_SPEC.md | Stop and list the contradictions. Ask the user to resolve before continuing. |
| Specs insufficient for task generation (missing scope, unclear requirements) | List what's missing. Ask the user to update the upstream spec before continuing. |
| Referenced file not found | Report the missing file path and skip dependent generation steps. |

---

## Post-Generation Checklist

**EXECUTION_PLAN.md**
(Run the checklist from EXECUTION_PLAN_FORMAT.md, then also check:)
- [ ] Requirement fields link to REQ-XXX from PRODUCT_SPEC.md where applicable

**AGENTS.md**
- [ ] Project context filled in (tech stack, dev server)
- [ ] Workflow section present
- [ ] Context management section present
- [ ] Testing policy present
- [ ] Test quality standards present (AAA pattern, naming, what to test)
- [ ] Mocking policy present (what to mock, mock hygiene)
- [ ] "When to stop" triggers present
- [ ] Git conventions present (including `/create-pr` for PRs)
- [ ] Guardrails present
