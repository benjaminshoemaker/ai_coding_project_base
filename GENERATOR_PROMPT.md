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

══════════════════════════════════════════════════════════════════════════════
PART 1: CORE CONCEPTS
══════════════════════════════════════════════════════════════════════════════

EXECUTION HIERARCHY

┌─────────┬────────────────────────────────────────────────────────────────┐
│ Level   │ Definition                                                     │
├─────────┼────────────────────────────────────────────────────────────────┤
│ PHASE   │ Major milestone ending with human checkpoint                   │
│         │ - Represents demonstrable functionality                        │
│         │ - Requires manual testing and approval before proceeding       │
│         │ - Includes pre-phase setup (env vars, external services)       │
├─────────┼────────────────────────────────────────────────────────────────┤
│ STEP    │ Ordered group of related tasks                                 │
│         │ - All tasks in a step complete before next step begins         │
│         │ - Tasks within a step may run in parallel                      │
├─────────┼────────────────────────────────────────────────────────────────┤
│ TASK    │ Atomic unit of work for a single agent session                 │
│         │ - Has specific, testable acceptance criteria                   │
│         │ - Creates or modifies a focused set of files                   │
│         │ - Independent from parallel tasks in same step                 │
└─────────┴────────────────────────────────────────────────────────────────┘

DOCUMENT RESPONSIBILITIES

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
PART 2: EXECUTION_PLAN.md FORMAT
══════════════════════════════════════════════════════════════════════════════

Verification Types:
- TEST — Verified by running a test (name or file path)
- CODE — Verified by code inspection or file existence
- LINT — Verified by lint command
- TYPE — Verified by typecheck command
- BUILD — Verified by build command
- SECURITY — Verified by security scan
- BROWSER:DOM | VISUAL | NETWORK | CONSOLE | PERFORMANCE | ACCESSIBILITY — Verified via MCP
- MANUAL — Requires human judgment that BLOCKS downstream work; include a reason. USE SPARINGLY.
  Before tagging MANUAL, read `~/.claude/skills/auto-verify/PATTERNS.md` and walk
  through the MANUAL Decision Tree. Only subjective UX/brand/tone judgment is
  truly manual. File checks, API calls, DOM selectors, grep, tests — all automated.
  Most tasks should have ZERO manual criteria.
- MANUAL:DEFER — Requires human judgment but has NO downstream dependency.
  Deferred items accumulate and are reviewed when a blocker occurs or at project end.
  Examples: visual polish, copy tone, color choices, "feels intuitive".
  USE SPARINGLY — prefer automated verification. Most subjective items are DEFER.

IMPORTANT: Every non-MANUAL/non-MANUAL:DEFER criterion MUST include a machine-verifiable `Verify:` line.

# Execution Plan: {Project Name}

## Overview

| Metric | Value |
|--------|-------|
| Phases | {N} |
| Steps  | {N} |
| Tasks  | {N} |

## Phase Flow

```
Phase 1: {Name}
    ↓
Phase 2: {Name}
    ↓
...
```

---

## Phase 1: {Phase Name}

**Goal:** {What this phase accomplishes}

### Pre-Phase Setup

Human must complete before agents begin:

- [ ] {Environment variable or secret}
  - Verify: `{command}`
- [ ] {External service setup}
  - Verify: `{command}`
- [ ] {Other prerequisite}
  - Verify: `{command}`

---

### Step 1.1: {Step Name}

#### Task 1.1.A: {Task Name}

**What:** {1-2 sentence description}

**Requirement:** {REQ-XXX from PRODUCT_SPEC.md, or "None" if no direct mapping}

**Acceptance Criteria:**
- [ ] (TEST) {Specific, testable criterion}
  - Verify: `{test command or test name}`
- [ ] (CODE) {Specific, testable criterion}
  - Verify: `{command to check file/export exists}`
- [ ] (BROWSER:DOM) {Specific, testable criterion}
  - Verify: route=`{route}`, selector=`{selector}`, expect=`{state}`

Manual criteria (ONLY for true UX judgment — use sparingly):
- [ ] (MANUAL) {Specific criterion requiring human judgment — blocks downstream}
  - Reason: {why automation cannot verify this}
- [ ] (MANUAL:DEFER) {Subjective criterion with no downstream dependency}
  - Reason: {why human review is needed but doesn't block}

**Files:**
- Create: `{path}` — {purpose}
- Modify: `{path}` — {what change}

**Depends On:** {Prior task IDs, or "None"}

**Spec Reference:** {Section name from technical spec}

---

#### Task 1.1.B: {Task Name}
{Same structure}

---

### Step 1.2: {Step Name}
{Continue pattern}

---

### Phase 1 Checkpoint

**Automated:**
- [ ] All tests pass
- [ ] Type checking passes
- [ ] Linting passes

**Human Required:**
- [ ] {What human should verify}
  - Reason: {why human review is required}
- [ ] {Another manual check}
  - Reason: {why human review is required}

---

## Phase 2: {Phase Name}
{Continue pattern}

Read the local file `AGENTS_TEMPLATE.md` and use its contents as the AGENTS.md template (do not paraphrase or summarize — use the template verbatim, filling in project-specific values).

══════════════════════════════════════════════════════════════════════════════
PART 3: GENERATION INSTRUCTIONS
══════════════════════════════════════════════════════════════════════════════

Before generating:

1. **Identify phases** — Major functional areas from the spec become phases
2. **Map dependencies** — What must exist before each component can be built
3. **Group into steps** — Related tasks that should complete together
4. **Break into tasks** — Atomic units with 3-6 testable acceptance criteria each
5. **Identify setup** — External services, env vars, manual prerequisites per phase
6. **Define checkpoints** — What demonstrates each phase is complete

Task quality checks:
✓ 3-6 specific, testable acceptance criteria
✓ Every acceptance criterion includes a verification type
✓ Every non-MANUAL/non-MANUAL:DEFER criterion has a `Verify:` line with executable command
✓ MANUAL criteria are rare (< 10% of total) with clear reasons
✓ Concrete files to create/modify (not vague)
✓ Dependencies explicitly listed
✓ References spec section
✓ Independent from parallel tasks in same step
✓ Requirement field links to REQ-XXX from PRODUCT_SPEC.md (or "None" for infrastructure tasks)

Red flags to fix:
✗ Vague criteria like "works correctly" or "handles errors properly"
✗ Non-MANUAL criterion missing `Verify:` command
✗ MANUAL used for anything checkable by file existence, grep, curl, DOM selector, or test
✗ MANUAL criteria without a reason
✗ More than 1-2 MANUAL criteria per task (most tasks should have ZERO)
✗ Too many files (>7) in one task
✗ Dependencies on parallel tasks
✗ Missing spec reference

══════════════════════════════════════════════════════════════════════════════
SPECIFICATION DOCUMENTS
══════════════════════════════════════════════════════════════════════════════

## PRODUCT_SPEC.md

{Paste or attach PRODUCT_SPEC.md here — provides product context: problem, users, MVP scope}

## TECHNICAL_SPEC.md

{Paste or attach TECHNICAL_SPEC.md here — provides technical details: architecture, data models, APIs}

══════════════════════════════════════════════════════════════════════════════

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
- [ ] All phases have pre-phase setup sections (with `Verify:` commands)
- [ ] All tasks have 3-6 testable acceptance criteria
- [ ] All non-MANUAL/non-MANUAL:DEFER criteria have `Verify:` lines with executable commands
- [ ] MANUAL criteria are rare (< 10%) with clear reasons
- [ ] All tasks specify files to create/modify
- [ ] All tasks have dependencies listed
- [ ] All phases have checkpoint criteria
- [ ] No task depends on a parallel task in the same step

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
