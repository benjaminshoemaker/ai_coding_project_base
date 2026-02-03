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
- MANUAL — Requires human judgment; include a reason (use sparingly)

IMPORTANT: Every non-MANUAL criterion MUST include a machine-verifiable `Verify:` line.
MANUAL should only be used for true UX judgment (looks good, feels right, user experience).

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
- [ ] (MANUAL) {Specific criterion requiring human judgment}
  - Reason: {why automation cannot verify this}

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

══════════════════════════════════════════════════════════════════════════════
PART 3: AGENTS.md FORMAT
══════════════════════════════════════════════════════════════════════════════

**SIZE CONSTRAINT: Keep AGENTS.md under 150 lines.**

Research shows frontier LLMs follow ~150 instructions consistently. Beyond this,
instruction-following degrades. If you need more rules:
- Put the core workflow in AGENTS.md (≤150 lines)
- Put context-specific rules in subdirectory `.claude/CLAUDE.md` files
- Don't include code style guidelines (use linters via hooks instead)

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
├── Reviews and approves at phase checkpoints

AGENT (Executor)
├── Executes one task at a time
├── Works in git branch
├── Follows TDD: tests first, then implementation
├── Runs verification against acceptance criteria
└── Reports completion or blockers
```

---

## Task Execution

1. **Load context** — Read AGENTS.md, your spec documents, and your task from EXECUTION_PLAN.md
2. **Check CLAUDE.md** — Read project root CLAUDE.md if it exists
3. **Create branch** — If first task in phase, create branch: `git checkout -b phase-{N}`
4. **Verify dependencies** — Confirm prior tasks are complete
5. **Write tests first** — One test per acceptance criterion
6. **Implement** — Minimum code to pass tests
7. **Verify** — Use code-verification skill (see Verification section below)
8. **Update progress** — Check off completed criteria in EXECUTION_PLAN.md (see checkbox format below)
9. **Commit** — Format: `task(1.1.A): brief description`

### Checkbox Format

When updating EXECUTION_PLAN.md, change unchecked boxes to checked:

```markdown
# Before
- [ ] User can log in with email and password

# After
- [x] User can log in with email and password
```

---

## Context Management

**Start fresh for each task.** Do not carry conversation history between tasks.

Before starting any task, load:
1. AGENTS.md (this file)
2. Specification documents:
   - Greenfield projects: PRODUCT_SPEC.md and TECHNICAL_SPEC.md
   - Feature work: FEATURE_SPEC.md and FEATURE_TECHNICAL_SPEC.md
3. Your task definition from EXECUTION_PLAN.md

**Preserve context while debugging.** If tests fail within a task, continue in the same conversation until resolved.

```
Task N starts (fresh)
    → Write tests
    → Implement
    → Tests fail → Debug (keep context) → Fix
    → Tests pass
    → Verify (code-verification skill or manual checklist)
    → Update checkboxes in EXECUTION_PLAN.md
    → Task complete
Task N+1 starts (fresh)
```

### Context Hygiene

Context pollution degrades response quality. Follow these rules:

1. **Compact BEFORE steps, not during them** — If context is below 40% remaining, run `/compact` before starting the next command (e.g., before `/phase-start`, `/phase-checkpoint`). This ensures full command instructions are in context during execution.
2. **Never let compaction occur mid-command** — A summary tells you WHAT was happening but not HOW. If compacted mid-command, you lose procedural instructions and must re-read the command file.
3. **Never exceed 60% context capacity** — If responses become repetitive or confused, context is polluted
4. **Separate concerns by phase:**
   - Research (read-only exploration)
   - Plan (design approach)
   - Implement (write code)
   - Validate (verify acceptance criteria)
5. **When in doubt, start fresh** — A clean context with reloaded documents beats a polluted one

---

## Testing Policy

- Tests must exist for every acceptance criterion
- All tests must pass before reporting complete
- Never skip or disable tests to make them pass
- Never claim "working" when functionality is broken
- Read full error output before attempting fixes

---

## Test Quality Standards

### Test Structure

Use the **AAA pattern** for all tests:
1. **Arrange** — Set up test data and preconditions
2. **Act** — Execute the code under test
3. **Assert** — Verify the expected outcome

```
// Example structure
test('should return user when valid ID provided', () => {
  // Arrange
  const userId = 'user-123';
  const mockUser = { id: userId, name: 'Test User' };
  mockDatabase.users.set(userId, mockUser);

  // Act
  const result = getUser(userId);

  // Assert
  expect(result).toEqual(mockUser);
});
```

### Test Naming

Use descriptive names that explain the expected behavior:
- Format: `should {expected behavior} when {condition}`
- Examples:
  - `should return empty array when no items exist`
  - `should throw ValidationError when email is invalid`
  - `should redirect to login when session expires`

### What to Test

| Category | Examples |
|----------|----------|
| **Happy path** | Valid inputs produce expected outputs |
| **Edge cases** | Empty inputs, boundary values, null/undefined |
| **Error cases** | Invalid inputs produce appropriate errors |
| **State changes** | Before/after mutations are correct |

### What NOT to Test

- Private/internal implementation details
- Framework or library code
- Trivial getters/setters without logic
- Code you don't own

### Test Independence

- Each test must be independent — no shared mutable state
- Tests must pass when run individually or in any order
- Use `beforeEach`/`afterEach` for setup and cleanup

---

## Mocking Policy

### What to Mock

| Dependency Type | Mock Strategy |
|-----------------|---------------|
| External APIs | Mock HTTP client or use MSW/nock |
| Database | Use test database or in-memory alternative |
| File system | Use temp directories, clean up after test |
| Time/dates | Use fixed timestamps (`jest.useFakeTimers()`, `freezegun`) |
| Random values | Use seeded generators or fixed values |
| Environment variables | Set in test setup, restore after |

### What NOT to Mock

- The code under test itself
- Pure functions with no side effects
- Data structures and types
- Simple utility functions

### Mock Hygiene

- Reset mocks between tests (`jest.clearAllMocks()`, `vi.clearAllMocks()`)
- Prefer dependency injection over global mocks
- Mock at the boundary, not deep in the call stack
- Verify mock interactions when behavior matters

### Integration Tests

For tests that need real external services:
- Mark as integration tests (separate test command or file pattern)
- Skip gracefully when credentials unavailable
- Use dedicated test accounts/environments
- Clean up test data after runs

---

## Verification

After implementing each task, verify all acceptance criteria are met.
Use verification metadata from EXECUTION_PLAN.md. If it is missing, infer and
add the metadata to EXECUTION_PLAN.md before proceeding. If ambiguous, ask the
human to confirm the verification method.

### Primary: Code Verification Skill (Claude Code)

If using Claude Code with the code-verification skill available:

```
Use /code-verification to verify this task against its acceptance criteria
```

The skill will:
- Parse each acceptance criterion
- Spawn sub-agents to verify each one
- Attempt fixes (up to 5 times) for failures
- Generate a verification report

### Fallback: Manual Verification Checklist

If the code-verification skill is not available, manually verify:

1. **Run tests** — Use the configured test command
2. **Type check** — Use the configured typecheck command (if applicable)
3. **Lint** — Use the configured lint command (if applicable)
4. **Manual check** — For each acceptance criterion:
   - Read the criterion
   - Verify it is met (inspect code, run app, check output)
   - If not met, fix and re-verify
5. **Document** — Note verification status in completion report

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
Type: user-action | dependency | external-service | unclear-requirements
```

**Also update `.claude/phase-state.json`** with the blocker:
```json
{
  "tasks": {
    "{id}": {
      "status": "BLOCKED",
      "blocker": "{what's wrong}",
      "blocker_type": "{type}",
      "since": "{ISO timestamp}"
    }
  }
}
```

This ensures the orchestrator can detect blockers without parsing conversation history.

---

## Completion Report

When done:
- What was built (1-2 sentences)
- Files created/modified
- Test status
- Commit hash

---

## Git Conventions

### Branch Strategy

Create one branch per **phase** (not per step or task):

```
git checkout -b phase-{N}
# Example: git checkout -b phase-1
```

**Branch lifecycle:**
1. Create branch from main/develop before starting first task in phase
2. Commit after each task completion (all tasks sequential on same branch)
3. Do not push until human reviews at checkpoint
4. Create PR for review at phase checkpoint
5. Merge after checkpoint approval

### Commit Format

```
task({id}): {description} [REQ-XXX]
# Example: task(1.2.A): Add user authentication endpoint [REQ-002]
```

**Requirement traceability:** If the task has a `Requirement:` field with a REQ-ID, include it in brackets at the end of the commit message. If the task has no REQ-ID (e.g., infrastructure or tooling tasks), omit the brackets.

```
# With requirement ID:
task(1.2.A): Add user authentication endpoint [REQ-002]

# Without requirement ID (tooling/infrastructure):
task(1.1.A): Set up project scaffolding
```

### Creating Pull Requests

Use the `/create-pr` skill instead of manual PR creation:

```
/create-pr
```

This ensures:
- `.workstream/verify.sh` runs before PR creation (typecheck, lint, test, build)
- Consistent PR title and body formatting
- Optional cross-model review via Codex CLI

If verification fails, fix the issues before creating the PR.

### Branch and Commit Structure

| Item | Format | Example |
|------|--------|---------|
| Phase branch | `phase-{N}` | `phase-1` |
| Commit | `task({id}): {description}` | `task(1.2.A): Add login form` |

Steps are logical groupings within the branch—not separate branches.

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
✓ Every acceptance criterion includes a verification type
✓ Every non-MANUAL criterion has a `Verify:` line with executable command
✓ MANUAL criteria are rare (< 10% of total) with clear reasons
✓ Concrete files to create/modify (not vague)
✓ Dependencies explicitly listed
✓ References spec section
✓ Independent from parallel tasks in same step
✓ Requirement field links to REQ-XXX from PRODUCT_SPEC.md (or "None" for infrastructure tasks)

Red flags to fix:
✗ Vague criteria like "works correctly"
✗ Non-MANUAL criterion missing `Verify:` command
✗ MANUAL used when automation is possible (prefer BROWSER: types)
✗ MANUAL criteria without a reason
✗ Too many MANUAL criteria (> 2 per task)
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

## Post-Generation Checklist

**EXECUTION_PLAN.md**
- [ ] All phases have pre-phase setup sections (with `Verify:` commands)
- [ ] All tasks have 3-6 testable acceptance criteria
- [ ] All non-MANUAL criteria have `Verify:` lines with executable commands
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
