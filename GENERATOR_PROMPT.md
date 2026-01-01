# Execution Toolkit Generator

Generate an execution toolkit from a technical specification. This prompt produces two documents with distinct purposes:

- **EXECUTION_PLAN.md** — What to build (tasks, acceptance criteria, dependencies)
- **AGENTS.md** — How to work (workflow rules, guardrails, verification protocol)

---

## The Prompt

```
I need you to generate an execution toolkit from the attached technical specification.

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
- [ ] {External service setup}
- [ ] {Other prerequisite}

---

### Step 1.1: {Step Name}

#### Task 1.1.A: {Task Name}

**What:** {1-2 sentence description}

**Acceptance Criteria:**
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}

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

**Manual Verification:**
- [ ] {What human should verify}
- [ ] {Another manual check}

---

## Phase 2: {Phase Name}
{Continue pattern}

══════════════════════════════════════════════════════════════════════════════
PART 3: AGENTS.md FORMAT
══════════════════════════════════════════════════════════════════════════════

# AGENTS.md

Workflow guidelines for AI agents executing tasks from EXECUTION_PLAN.md.

---

## Project Context

**Tech Stack:** {language, runtime, framework, test runner, package manager}

**Dev Server:** `{command}` → `{url}` (wait {N}s for startup)

---

## Workflow

```
HUMAN (Orchestrator)
├── Completes pre-phase setup
├── Assigns tasks from EXECUTION_PLAN.md
├── Reviews completed work
└── Approves phase checkpoints

AGENT (Executor)
├── Executes one task at a time
├── Follows TDD: tests first, then implementation
├── Runs verification against acceptance criteria
└── Reports completion or blockers
```

---

## Task Execution

1. **Load context** — Read AGENTS.md, TECHNICAL_SPEC.md, and your task from EXECUTION_PLAN.md
2. **Check CLAUDE.md** — Read project root CLAUDE.md if it exists
3. **Verify dependencies** — Confirm prior tasks are complete
4. **Write tests first** — One test per acceptance criterion
5. **Implement** — Minimum code to pass tests
6. **Verify** — Run all tests, confirm acceptance criteria met
7. **Update progress** — Check off completed acceptance criteria in EXECUTION_PLAN.md
8. **Commit** — Format: `task(1.1.A): brief description`

---

## Context Management

**Start fresh for each task.** Do not carry conversation history between tasks.

Before starting any task, load:
1. AGENTS.md (this file)
2. TECHNICAL_SPEC.md
3. Your task definition from EXECUTION_PLAN.md

**Preserve context while debugging.** If tests fail within a task, continue in the same conversation until resolved.

```
Task N starts (fresh)
    → Write tests
    → Implement
    → Tests fail → Debug (keep context) → Fix
    → Tests pass
    → Task complete
Task N+1 starts (fresh)
```

---

## Testing Policy

- Tests must exist for every acceptance criterion
- All tests must pass before reporting complete
- Never skip or disable tests to make them pass
- Never claim "working" when functionality is broken
- Read full error output before attempting fixes

---

## When to Stop and Ask

Stop and ask the human if:
- A dependency is missing (file, function, service doesn't exist)
- You need environment variables or secrets
- Acceptance criteria are ambiguous
- A test fails and you cannot determine why after reading full error output
- You need to modify files outside your task scope

**Blocker format:**
```
BLOCKED: Task {id}
Issue: {what's wrong}
Tried: {what you attempted}
Need: {what would unblock}
```

---

## Completion Report

When done:
- What was built (1-2 sentences)
- Files created/modified
- Test status
- Commit hash

---

## Git Conventions

| Item | Format |
|------|--------|
| Branch | `task-{id}` |
| Commit | `task({id}): {description}` |

---

## Guardrails

- Make the smallest change that satisfies acceptance criteria
- Do not duplicate files to work around issues — fix the original
- Do not guess — if you can't access something, say so
- Do not introduce new APIs without flagging for spec updates
- Read error output fully before attempting fixes

---

## Follow-Up Items (TODOS.md)

During development, you will discover items that need attention but are outside the current task scope: refactoring opportunities, edge cases to handle later, documentation needs, technical debt, etc.

**When you identify a follow-up item:**

1. **Prompt the human to start TODOS.md** if it doesn't exist:
   ```
   I've identified a follow-up item: {description}

   Should I create TODOS.md to track this and future items?
   ```

2. **Add items to TODOS.md** with context:
   ```markdown
   ## TODO: {Brief title}
   - **Source:** Task {id} or {file:line}
   - **Description:** {What needs to be done}
   - **Priority:** {Suggested: High/Medium/Low}
   - **Added:** {Date}
   ```

3. **Prompt for prioritization** when the list grows or at phase checkpoints:
   ```
   TODOS.md now has {N} items. Would you like to:
   - Review and prioritize them?
   - Add any to the current phase?
   - Defer to a future phase?
   ```

**Do not** silently ignore discovered issues. **Do not** scope-creep by fixing them without approval. Track them in TODOS.md and let the human decide when to address them.

══════════════════════════════════════════════════════════════════════════════
PART 4: GENERATION INSTRUCTIONS
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
✓ Concrete files to create/modify (not vague)
✓ Dependencies explicitly listed
✓ References spec section
✓ Independent from parallel tasks in same step

Red flags to fix:
✗ Vague criteria like "works correctly"
✗ Too many files (>7) in one task
✗ Dependencies on parallel tasks
✗ Missing spec reference

══════════════════════════════════════════════════════════════════════════════
SPECIFICATION
══════════════════════════════════════════════════════════════════════════════

{Paste or attach TECHNICAL_SPEC.md here}

══════════════════════════════════════════════════════════════════════════════

Generate:
1. EXECUTION_PLAN.md
2. AGENTS.md
```

---

## Follow-Up Prompts

### Refine a specific task
```
Review Task {X.Y.Z} and improve:
1. Make acceptance criteria more specific and testable
2. Clarify file paths
3. Verify dependencies are accurate
```

### Add a feature
```
Add {feature} to the execution plan:
1. Determine which phase it belongs in
2. Create tasks with full details
3. Update dependencies
```

### Handle scope change
```
Scope change: {description}

Update EXECUTION_PLAN.md to reflect this.
```

---

## Post-Generation Checklist

**EXECUTION_PLAN.md**
- [ ] All phases have pre-phase setup sections
- [ ] All tasks have 3-6 testable acceptance criteria
- [ ] All tasks specify files to create/modify
- [ ] All tasks have dependencies listed
- [ ] All phases have checkpoint criteria
- [ ] No task depends on a parallel task in the same step

**AGENTS.md**
- [ ] Project context filled in (tech stack, dev server)
- [ ] Workflow section present
- [ ] Context management section present
- [ ] Testing policy present
- [ ] "When to stop" triggers present
- [ ] Git conventions present
- [ ] Guardrails present
