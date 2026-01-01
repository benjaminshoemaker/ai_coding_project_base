# Execution Plan Generator Prompt

Use this prompt to generate an execution toolkit from a technical specification:
- **EXECUTION_PLAN.md** - Detailed phase/step/task breakdown
- **AGENTS.md** - AI agent workflow guidelines

---

## The Prompt

```
I need you to generate an execution toolkit for implementing this project. Generate two documents:

1. EXECUTION_PLAN.md - Detailed task breakdown
2. AGENTS.md - AI agent workflow guidelines

═══════════════════════════════════════════════════════════════════
PART 1: EXECUTION HIERARCHY DEFINITIONS
═══════════════════════════════════════════════════════════════════

**PHASE**: A major milestone with a human checkpoint at the end
- Represents significant, demonstrable functionality
- Ends with manual testing and human approval
- Includes pre-phase setup requirements (external services, env vars, etc.)

**STEP**: A completion boundary containing sequential work
- Groups related tasks that should be completed together
- All tasks in a step must complete before the next step begins
- Has clear dependencies on prior steps

**TASK**: An atomic unit of work for a single AI agent session
- Has specific, testable acceptance criteria
- Creates or modifies a focused set of files
- Independent from parallel tasks in the same step

═══════════════════════════════════════════════════════════════════
PART 2: EXECUTION_PLAN.md FORMAT
═══════════════════════════════════════════════════════════════════

# Execution Plan: {Project Name}

## Overview
| Metric | Value |
|--------|-------|
| Total Phases | {N} |
| Total Steps | {N} |
| Total Tasks | {N} |

## Phase Dependency Graph
{ASCII diagram showing phase flow}

---

## Phase 1: {Phase Name}

**Goal:** {What this phase accomplishes}  
**Depends On:** {Prior phases or "None"}

### Pre-Phase Setup
Human must complete before starting:
- [ ] {External service setup}
- [ ] {Environment variables needed}
- [ ] {Other manual prerequisites}

### Step 1.1: {Step Name}
**Depends On:** {Prior steps or "None"}

---

#### Task 1.1.A: {Task Name}

**Description:**  
{2-3 sentences explaining what to build and why}

**Acceptance Criteria:**
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}

**Files to Create:**
- `{path/to/file}` — {purpose}

**Files to Modify:**
- `{path/to/file}` — {what change}

**Dependencies:**
- {What must exist before this task starts, or "None"}

**Spec Reference:** {Section name or line numbers}

**Requires Browser Verification:** {Yes/No}
- If Yes, list which acceptance criteria need browser verification
- Example: "Yes - criteria 1 (DOM inspection), criteria 3 (visual screenshot)"

---

#### Task 1.1.B: {Task Name}
{Same structure}

---

### Step 1.2: {Step Name}
**Depends On:** Step 1.1
{Continue pattern}

---

### Phase 1 Checkpoint

**Automated Checks:**
- [ ] All tests pass
- [ ] Type checking passes
- [ ] Linting passes

**Manual Verification:**
- [ ] {Specific thing human should verify}
- [ ] {Another manual check}

**Browser Verification (if applicable):**
- [ ] All UI acceptance criteria verified via Chrome DevTools MCP
- [ ] No console errors on key pages
- [ ] Screenshots captured for visual changes

---

## Phase 2: {Phase Name}
{Continue pattern}

═══════════════════════════════════════════════════════════════════
PART 3: AGENTS.md FORMAT
═══════════════════════════════════════════════════════════════════

Keep AGENTS.md focused on workflow mechanics only. Do NOT include:
- Error handling patterns (agents discover from codebase)
- Mocking strategies (agents figure out from test framework)
- Import aliases (agents read from tsconfig)
- Naming conventions (agents follow existing code)
- Detailed file structures (agents explore the repo)

# AGENTS.md - {Project Name}

> Workflow guidelines for AI agents in a sequential development process.

## Workflow Overview

```
HUMAN (Orchestrator)
├── Assigns tasks from EXECUTION_PLAN.md in order
├── Reviews completed tasks before assigning the next
└── Reviews at phase checkpoints

AI AGENT (Claude Code or Codex CLI)
├── Executes ONE task at a time
├── Works on a single branch
├── Follows TDD: tests first, then implementation
└── Reports completion or blockers
```

## Execution Hierarchy

| Level | Managed By | Boundary |
|-------|------------|----------|
| Phase | Human | Manual testing, approval gate |
| Step | Human | All tasks in the step completed |
| Task | Agent | Single focused implementation |

---

## Before Starting Any Task

1. **Read CLAUDE.md** at the project root (if it exists)
2. **Check `.claude/`** directory for project-specific skills and instructions
3. **Explore the codebase** to understand existing patterns and conventions
4. **Review the task** — acceptance criteria, dependencies, spec references
5. **Ask if unclear** — Don't guess on ambiguous requirements

---

## Task Execution

1. **Verify dependencies exist** — Check that prior tasks are merged and working
2. **Write tests first** — One test per acceptance criterion
3. **Implement** — Minimum code to pass tests
4. **Run verification** — Use the code-verification skill against acceptance criteria
   - The skill automatically detects UI/browser criteria and uses Chrome DevTools MCP
5. **Update EXECUTION_PLAN.md** — When code-verification passes, check off the task's verification checkboxes in `EXECUTION_PLAN.md`
6. **Commit** — Format: `task(1.1.A): brief description`

---

## Browser Verification Protocol

When acceptance criteria involve UI/browser behavior (detected by keywords: UI, render, display, click, visual, DOM, style, console, network, accessibility, responsive), the code-verification skill will automatically use Chrome DevTools MCP.

### Pre-Verification Setup
1. **Start dev server** — Run the project's dev server command
2. **Wait for ready** — Allow configured startup time
3. **Confirm MCP availability** — Verify Chrome DevTools MCP is accessible

### Verification Types

| Criterion Pattern | MCP Capability | Verification Method |
|-------------------|----------------|---------------------|
| "displays X", "shows Y", "renders Z" | DOM Inspection | Query selector, check visibility/content |
| "looks like", "visual", "screenshot" | Screenshots | Capture and compare/describe |
| "click", "hover", "focus" | DOM Events | Trigger action, observe result |
| "no console errors" | Console Monitoring | Check console for errors/warnings |
| "API call succeeds", "network" | Network Monitoring | Observe request/response |
| "loads in < X seconds" | Performance Metrics | Measure timing |
| "accessible", "ARIA", "a11y" | DOM + Accessibility | Check ARIA attributes, semantic HTML |
| "responsive", "mobile", "breakpoint" | Viewport Control | Resize viewport, verify layout |

### Verification Output
Include in verification report:
- Screenshot path (for visual verifications)
- DOM state (for element verifications)
- Console log excerpt (if console errors checked)
- Network request summary (if API behavior checked)

### Fallback When MCP Unavailable
If Chrome DevTools MCP is not available:
1. Log a warning: "Browser verification skipped - Chrome DevTools MCP unavailable"
2. Mark browser-related criteria as BLOCKED (not FAIL)
3. Continue with code-based verification
4. Note in report: "Manual browser verification recommended"

---

## Context Management

### Starting a new task
Start a **fresh conversation** for each new task. Before working, load:
1. `AGENTS.md` (this file)
2. `TECHNICAL_SPEC.md` (architecture reference)
3. The task definition from `EXECUTION_PLAN.md`

Read source files and tests on-demand as needed. Do not preload the entire codebase.

### Why fresh context per task?
- Each task is self-contained with complete instructions
- Decisions from previous tasks exist in the code, not conversation history
- Stale context causes confusion and wastes tokens
- The code and tests are the source of truth

### When to preserve context
**Within a single task**, if tests fail or issues arise, continue in the same conversation to debug:

```
Task starts (fresh context)
    → Implement
    → Test fails
    → Debug (keep context)
    → Fix
    → Tests pass
    → Task complete
Next task (fresh context)
```

Only clear context when moving to the next task, not while iterating on the current one.

### Resuming work after a break
When returning to a project:
1. Start a fresh conversation
2. Load `AGENTS.md`, `TECHNICAL_SPEC.md`
3. Check `EXECUTION_PLAN.md` to find the current task
4. Run tests to verify current state
5. Continue from where you left off

Do not attempt to reconstruct previous conversation context.

---

## Branch Context

You're working on a task branch:

```
main
└── task-1.1.A    ← You are here
```

**Key implications:**
- Complete your task before the next one begins
- The human will review and merge when appropriate
- Only modify files relevant to your task

---

## When to Stop and Ask

Stop and ask the human if:
- A dependency is missing (file, function, or service doesn't exist)
- You need environment variables or secrets you don't have
- An external dependency or major architectural change seems required
- A test is failing and you cannot determine why **after reading the full error output**
- Acceptance criteria are ambiguous
- You need to modify files outside the task scope
- You're unsure whether a change is user-facing

**Read the full error output before attempting fixes.** The answer is usually in the stack trace. Do not guess or work around.

---

## Blocker Report Format

```
BLOCKED: Task {id}
Issue: {what's wrong}
Tried: {approaches attempted}
Need: {what would unblock}
```

---

## Completion Report

When done, briefly report:
- What was built (1-2 sentences)
- Files created/modified
- Test status (passing/failing)
- Commit hash

Keep it concise. The human can review the diff for details.

---

## Deferred Work

When a task is intentionally paused or skipped:
- Report it clearly to the human
- Note the reason and what would unblock it
- The human will update the execution plan accordingly

---

## Git Rules

| Rule | Details |
|------|---------|
| Branch | `task-{id}` (e.g., `task-1.1.A`) |
| Commit | `task({id}): {description}` |
| Scope | Only modify task-relevant files |
| Ignore | Never commit `.env`, `node_modules`, build output |

---

## Testing Policy

- Tests must exist for all acceptance criteria
- Tests must pass before reporting complete
- Never skip or disable tests to make them pass
- If tests won't pass, report as a blocker
- **Never claim "working" when any functionality is disabled or broken**

---

## Critical Guardrails

- **Do not duplicate files to work around issues** — fix the original
- **Do not guess** — if you can't access something, say so
- **Read error output fully** before attempting fixes
- Make the smallest change that satisfies the acceptance criteria
- Do not introduce new APIs without noting it for spec updates

---

*The agent discovers project conventions (error handling, mocking strategies, naming patterns) from the existing codebase. This document only covers workflow mechanics.*

═══════════════════════════════════════════════════════════════════
PART 4: ANALYSIS INSTRUCTIONS
═══════════════════════════════════════════════════════════════════

Before generating the documents:

1. **Identify major functional areas** from the spec → These become Phases
2. **Map dependencies** between components
3. **Group parallelizable work** → These become Steps
4. **Break into atomic units** → These become Tasks
5. **Identify pre-phase setup** for each phase (external services, env vars)
6. **Define checkpoint criteria** for each phase

═══════════════════════════════════════════════════════════════════
PART 5: TASK QUALITY CHECKS
═══════════════════════════════════════════════════════════════════

For each task, verify:

✓ Has 3-6 specific, testable acceptance criteria
✓ Lists concrete files to create/modify
✓ Specifies dependencies on prior tasks
✓ References relevant spec section
✓ Is independent from parallel tasks in same step

Red flags to fix:
✗ Vague criteria like "works correctly" or "handles errors properly"
✗ Too many files (>7) touched in one task
✗ Dependencies on parallel tasks in the same step
✗ Missing spec reference

═══════════════════════════════════════════════════════════════════
SPECIFICATIONS TO ANALYZE
═══════════════════════════════════════════════════════════════════

{Paste or attach TECHNICAL_SPEC.md here}

═══════════════════════════════════════════════════════════════════

Generate:
1. EXECUTION_PLAN.md
2. AGENTS.md
```

---

## Follow-Up Prompts

### To refine specific tasks:
```
Review Task {X.Y.Z} and improve:
1. Make acceptance criteria more specific and testable
2. Clarify file paths
3. Check dependencies are accurate
```

### To add a new feature:
```
Add {feature} to the plan:
1. Determine which phase it belongs in
2. Create new tasks with full details
3. Update dependencies if needed
```

### To handle scope changes:
```
The scope has changed: {description}

Update EXECUTION_PLAN.md to reflect this change.
```

---

## After Generation Checklist

```
EXECUTION_PLAN.md
□ All phases have pre-phase setup sections
□ All tasks have testable acceptance criteria
□ All tasks specify files to create/modify
□ All tasks have dependencies listed
□ All phases have checkpoint criteria
□ No task depends on a parallel task in the same step
□ Tasks with UI criteria marked as "Requires Browser Verification: Yes"
□ Browser verification prerequisites documented in Pre-Phase Setup (if project has UI)

AGENTS.md
□ Focused on workflow only (no coding patterns)
□ Includes initialization instructions (CLAUDE.md, .claude/)
□ Includes context management (fresh per task, preserve for debugging)
□ Includes "when to stop and ask" triggers
□ Includes blocker reporting format
□ Includes git conventions
□ Includes critical guardrails (no duplicating files, read errors fully)
□ Describes sequential task execution (not parallel worktrees)
```
