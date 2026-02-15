# Feature Execution Plan Generator Prompt

Use this prompt to generate an execution plan for implementing a **new feature** in an **existing project**:
- **EXECUTION_PLAN.md** - Detailed phase/step/task breakdown for the feature
- **AGENTS.md additions** - Suggested workflow additions if the feature requires capabilities not in your current AGENTS.md

This prompt requires your existing `AGENTS.md` file as input to ensure compatibility and identify any workflow gaps.

---

## The Prompt

```
I need you to generate an execution plan for implementing a new feature in my existing project.

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

Verification Types:
- TEST — Verified by running a test (name or file path)
- CODE — Verified by code inspection or file existence
- LINT — Verified by lint command
- TYPE — Verified by typecheck command
- BUILD — Verified by build command
- SECURITY — Verified by security scan
- BROWSER:DOM | VISUAL | NETWORK | CONSOLE | PERFORMANCE | ACCESSIBILITY — Verified via MCP
- MANUAL — Requires human judgment; include a reason. USE SPARINGLY.
  Before tagging MANUAL, read `~/.claude/skills/auto-verify/PATTERNS.md` and walk
  through the MANUAL Decision Tree. Only subjective UX/brand/tone judgment is
  truly manual. File checks, API calls, DOM selectors, grep, tests — all automated.
  Most tasks should have ZERO manual criteria.

# Execution Plan: {Feature Name}

## Overview
| Metric | Value |
|--------|-------|
| Feature | {Feature name} |
| Target Project | {Project name} |
| Total Phases | {N} |
| Total Steps | {N} |
| Total Tasks | {N} |

## Integration Points
| Existing Component | Integration Type | Notes |
|--------------------|------------------|-------|
| {component} | {extends/modifies/uses} | {brief note} |

## Phase Dependency Graph
{ASCII diagram showing phase flow}

---

## Phase 1: {Phase Name}

**Goal:** {What this phase accomplishes}  
**Depends On:** {Prior phases or "None"}

### Pre-Phase Setup
Human must complete before starting:
- [ ] {External service setup}
  - Verify: `{command}`
- [ ] {Environment variables needed}
  - Verify: `{command}`
- [ ] {Other manual prerequisites}
  - Verify: `{command}`

### Step 1.1: {Step Name}
**Depends On:** {Prior steps or "None"}

---

#### Task 1.1.A: {Task Name}

**Description:**  
{2-3 sentences explaining what to build and why, including how it integrates with existing code}

**Acceptance Criteria:**
- [ ] (TEST) {Specific, testable criterion}
  - Verify: {test name or file path}
- [ ] (CODE) {Specific, testable criterion}
  - Verify: {file, export, or command to check}
- [ ] (BROWSER:DOM) {Specific, testable criterion}
  - Verify: {route}, {selector}, {expected state}

Manual criteria (only if automation is not feasible):
- [ ] (MANUAL) {Specific, testable criterion}
  - Reason: {why human review is required}

**Files to Create:**
- `{path/to/file}` — {purpose}

**Files to Modify:**
- `{path/to/existing/file}` — {what change and why}

**Existing Code to Reference:**
- `{path/to/file}` — {what patterns/interfaces to follow}

**Dependencies:**
- {What must exist before this task starts, or "None"}

**Spec Reference:** {Section name from feature spec}

**Browser Verification:**
- Criteria IDs: {list acceptance criteria marked BROWSER:*}
- Notes: {routes or pages to visit}

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
- [ ] All tests pass (including existing tests)
- [ ] Type checking passes
- [ ] Linting passes

**Regression Verification:**
- [ ] Existing functionality still works
- [ ] No breaking changes to public APIs

**Human Required:**
- [ ] {Specific thing human should verify}
  - Reason: {why human review is required}
- [ ] {Another manual check}
  - Reason: {why human review is required}

**Browser Verification (if applicable):**
- [ ] All UI acceptance criteria verified via browser MCP tools
- [ ] No console errors on key pages
- [ ] Screenshots captured for visual changes

---

## Phase 2: {Phase Name}
{Continue pattern}

═══════════════════════════════════════════════════════════════════
PART 3: ANALYSIS INSTRUCTIONS
═══════════════════════════════════════════════════════════════════

Before generating the execution plan:

1. **Review existing AGENTS.md**
   - Understand the current workflow (task execution steps, context management)
   - Note what verification methods are defined (testing policy, manual checks)
   - Identify any gaps: Does the feature need workflow elements not currently defined?
   - Common gaps to check for:
     - Browser/UI verification workflows
     - Regression testing requirements
     - Database migration procedures
     - External service integration patterns

2. **Understand the existing project**
   - Review the project structure and architecture
   - Identify relevant existing patterns (error handling, state management, API design)
   - Note testing conventions and frameworks in use
   - Understand the deployment model

3. **Map integration points**
   - Which existing files need modification?
   - Which existing components will the feature interact with?
   - Are there shared utilities, hooks, or services to reuse?
   - What interfaces or types already exist that apply?

4. **Identify risks and dependencies**
   - Could this feature break existing functionality?
   - Are there migration concerns (database, config, etc.)?
   - Does this require new external services or dependencies?

5. **Plan the phases**
   - Phase 1 is typically foundation/infrastructure for the feature
   - Middle phases build core functionality incrementally
   - Final phase handles polish, edge cases, and cleanup

6. **Ensure backward compatibility**
   - Existing tests must continue to pass
   - Public APIs should not break (or require migration path)
   - Consider feature flags if incremental rollout is needed

═══════════════════════════════════════════════════════════════════
PART 4: TASK QUALITY CHECKS
═══════════════════════════════════════════════════════════════════

For each task, verify:

✓ Has 3-6 specific, testable acceptance criteria
✓ Every acceptance criterion includes a verification type
✓ Every acceptance criterion includes a verification method
✓ Manual criteria include a reason and are minimal
✓ Lists concrete files to create/modify
✓ References existing code to follow as patterns
✓ Specifies dependencies on prior tasks
✓ References relevant feature spec section
✓ Is independent from parallel tasks in same step
✓ Considers impact on existing functionality

Red flags to fix:
✗ Vague criteria like "works correctly" or "handles errors properly"
✗ Criterion missing verification type or method
✗ MANUAL used for anything that can be checked by file existence, grep, curl, DOM selector, or test
✗ MANUAL used without a reason
✗ More than 1-2 MANUAL criteria per task (most tasks should have ZERO)
✗ Too many files (>7) touched in one task
✗ Dependencies on parallel tasks in the same step
✗ Missing spec reference
✗ No consideration of existing code patterns
✗ Changes to existing files without clear rationale

═══════════════════════════════════════════════════════════════════
PART 5: FEATURE-SPECIFIC CONSIDERATIONS
═══════════════════════════════════════════════════════════════════

When planning feature work, explicitly address:

**Data Layer Changes**
- New database tables/columns needed?
- Migrations required?
- Changes to existing data models?

**API Changes**
- New endpoints?
- Modifications to existing endpoints?
- Versioning considerations?

**UI Changes**
- New components?
- Modifications to existing components?
- Routing changes?

**Testing Strategy**
- Unit tests for new code
- Integration tests for feature flows
- Regression tests for modified existing code

**Rollback Plan**
- Can the feature be disabled without deployment?
- Are database changes reversible?

═══════════════════════════════════════════════════════════════════
INPUTS
═══════════════════════════════════════════════════════════════════

## Existing AGENTS.md (Required)

{Paste or attach your current AGENTS.md file. This is required to:}
- Ensure the execution plan uses compatible workflow patterns
- Identify gaps that need new workflow additions
- Maintain consistency with your established conventions

---

## Current Project Context

{Provide one or more of the following:}

### Option A: Key Files
- Project structure (tree output or key directories)
- README.md or project documentation
- Relevant existing code files the feature will interact with

### Option B: Summary Description
If you can't provide files, describe:
- Tech stack (language, framework, database, etc.)
- Architecture pattern (monolith, microservices, etc.)
- Key components the feature will touch
- Testing approach (Jest, Pytest, etc.)

---

## Feature Specification Documents (Required)

{Paste or attach both documents from the previous workflow steps:}

### FEATURE_SPEC.md
- What the feature does (user-facing behavior)
- Target users and core user experience
- Integration points with existing functionality
- Scope boundaries

### FEATURE_TECHNICAL_SPEC.md
- Technical requirements and constraints
- Data model changes and migration strategy
- API contracts (new and modified endpoints)
- Files to create and modify
- Regression risk assessment

═══════════════════════════════════════════════════════════════════
PART 6: AGENTS_ADDITIONS.md FORMAT
═══════════════════════════════════════════════════════════════════

AGENTS.md contains **workflow and process instructions** for AI agents—HOW to work.
It does NOT contain feature-specific business logic, domain rules, or implementation details—WHAT to build.

### What Belongs in AGENTS.md (and additions)
- Workflow procedures (how to run tests, migrations, deployments)
- Process policies (commit formats, branch strategies, verification steps)
- Tool usage patterns (MCP tools, CLI commands, dev server setup)
- Quality standards (testing policy, error handling conventions)

### What Does NOT Belong in AGENTS.md
- Business logic ("price threshold is ±5%", "filter by MLS area")
- Domain-specific rules (these belong in specs)
- Feature-specific commit examples (commit FORMAT is ok, specific commits are not)
- Acceptance criteria details (these belong in EXECUTION_PLAN.md)
- Implementation details for this specific feature

---

### When NO Additions Are Needed

If the existing AGENTS.md already covers all required workflows, output:

```markdown
# AGENTS_ADDITIONS.md

No additions required. The existing AGENTS.md covers all workflows needed for this feature:
- [x] {workflow 1}
- [x] {workflow 2}
- ...
```

Do NOT add "feature context notes" or "testing notes" as filler—this is noise that doesn't belong in AGENTS.md.

---

### When Additions ARE Needed

If the feature requires workflow elements not present in the existing AGENTS.md,
output suggested additions in this format:

```markdown
# AGENTS_ADDITIONS.md

## Additions Required

### {Section Name}

**Why needed:** {One sentence explaining the workflow gap}

**Content to add:**
\`\`\`markdown
{Actual content to merge into AGENTS.md}
\`\`\`

**Where to add:** {After which existing section}
```

---

### Common Workflow Additions

Only add these if they're MISSING from the existing AGENTS.md:

**Git Branch Strategy** — If not already defined in AGENTS.md
```
## Git Conventions

### Branch Strategy

Create one branch per **phase** (not per step or task):

git checkout -b phase-{N}
# Example: git checkout -b phase-1

**Branch lifecycle:**
1. Create branch from main/develop before starting first task in phase
2. Commit after each task completion (all tasks sequential on same branch)
3. Do not push until human reviews at checkpoint
4. Create PR for review at phase checkpoint
5. Merge after checkpoint approval

### Commit Format

task({id}): {description}
# Example: task(1.2.A): Add user authentication endpoint

### Branch and Commit Structure

| Item | Format | Example |
|------|--------|---------|
| Phase branch | `phase-{N}` | `phase-1` |
| Commit | `task({id}): {description}` | `task(1.2.A): Add login form` |

Steps are logical groupings within the branch—not separate branches.
```

**Code Verification Workflow** — Recommended for all features
```
## Verification

After implementing each task, verify all acceptance criteria are met.
Use verification metadata from EXECUTION_PLAN.md. If it is missing, infer and
add the metadata to EXECUTION_PLAN.md before proceeding. If ambiguous, ask the
human to confirm the verification method.

### Primary: Code Verification Skill (Claude Code)

If using Claude Code with the code-verification skill available:

Use /code-verification to verify this task against its acceptance criteria

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
```

**Checkbox Update Format** — If not already defined in AGENTS.md
```
## Progress Tracking

When completing acceptance criteria, update EXECUTION_PLAN.md checkboxes:

# Before
- [ ] User can log in with email and password

# After
- [x] User can log in with email and password
```

**Browser Verification Workflow** — If feature has UI acceptance criteria
```
## Browser Verification

For acceptance criteria marked `BROWSER:*`:
1. Start dev server if not running
2. Navigate to relevant pages
3. Verify each UI acceptance criterion using `Verify:` metadata
4. Check browser console for errors
5. Capture screenshots for visual changes
```

**Regression Testing Policy** — If feature modifies existing functionality
```
## Regression Testing

When modifying existing code:
- Run full test suite, not just new tests
- Verify existing functionality still works
- Document any intentional behavior changes
```

**Test Quality Standards** — Recommended if AGENTS.md lacks testing guidance
```
## Test Quality Standards

### Test Structure
Use the AAA pattern for all tests:
1. **Arrange** — Set up test data and preconditions
2. **Act** — Execute the code under test
3. **Assert** — Verify the expected outcome

### Test Naming
Use descriptive names: `should {expected behavior} when {condition}`

### What to Test
- Happy path (valid inputs → expected outputs)
- Edge cases (empty, null, boundary values)
- Error cases (invalid inputs → appropriate errors)

### What NOT to Test
- Private implementation details
- Framework/library code
- Trivial getters/setters without logic
```

**Mocking Policy** — If feature involves external dependencies
```
## Mocking Policy

### What to Mock
| Dependency Type | Mock Strategy |
|-----------------|---------------|
| External APIs | Mock HTTP client or use MSW/nock |
| Database | Use test database or in-memory alternative |
| File system | Use temp directories, clean up after test |
| Time/dates | Use fixed timestamps |

### What NOT to Mock
- The code under test itself
- Pure functions with no side effects

### Mock Hygiene
- Reset mocks between tests
- Prefer dependency injection over global mocks
- Mock at the boundary, not deep in the call stack
```

**Database Migration Workflow** — If feature includes schema changes
```
## Database Migrations

For tasks involving database changes:
1. Write migration before implementation code
2. Test migration up AND down
3. Verify existing data is preserved
4. Document rollback procedure
```

**Follow-Up Items Workflow** — Always include this section
```
## Follow-Up Items (TODOS.md)

During development, you will discover items outside current task scope: refactoring opportunities, edge cases, documentation needs, technical debt, etc.

**When you identify a follow-up item:**

1. **Prompt the human to start TODOS.md** if it doesn't exist:
   I've identified a follow-up item: {description}
   Should I create TODOS.md to track this and future items?

2. **Add items to TODOS.md** with context:
   ## TODO: {Brief title}
   - **Source:** Task {id} or {file:line}
   - **Description:** {What needs to be done}
   - **Priority:** {Suggested: High/Medium/Low}
   - **Added:** {Date}

3. **Prompt for prioritization** when the list grows or at phase checkpoints:
   TODOS.md now has {N} items. Would you like to:
   - Review and prioritize them?
   - Add any to the current phase?
   - Defer to a future phase?

Do not silently ignore discovered issues. Do not scope-creep by fixing them without approval. Track them in TODOS.md and let the human decide.
```

═══════════════════════════════════════════════════════════════════

Generate:
1. EXECUTION_PLAN.md
2. Suggested AGENTS.md additions (if needed)

Note: The execution plan references FEATURE_SPEC.md and FEATURE_TECHNICAL_SPEC.md
(your feature specification documents) instead of PRODUCT_SPEC.md and TECHNICAL_SPEC.md
for context management purposes.
```

---

## Follow-Up Prompts

### To refine specific tasks:
```
Review Task {X.Y.Z} and improve:
1. Make acceptance criteria more specific and testable
2. Clarify which existing files need modification
3. Identify patterns from existing code to follow
4. Check dependencies are accurate
```

### To handle discovered complexity:
```
While exploring the codebase, I found {discovery}.

Update the execution plan to account for this:
1. Adjust affected tasks
2. Add new tasks if needed
3. Update dependencies
```

### To add incremental scope:
```
We need to also support {additional requirement}.

Update EXECUTION_PLAN.md to include this:
1. Determine which phase it belongs in
2. Create new tasks or modify existing ones
3. Update dependencies
```

### To handle breaking changes:
```
This feature requires breaking changes to {component}.

Add a migration phase that:
1. Documents the breaking change
2. Provides migration path for existing code
3. Updates affected tests
```

---

## After Generation Checklist

```
EXECUTION_PLAN.md
□ Integration points with existing code clearly identified
□ All tasks reference existing code patterns to follow
□ All tasks have testable acceptance criteria
□ All acceptance criteria include verification types and methods
□ Manual criteria include reasons (if present)
□ All tasks specify files to create/modify
□ All tasks have dependencies listed
□ All phases have checkpoint criteria including regression checks
□ No task depends on a parallel task in the same step
□ Tasks with UI criteria marked as `BROWSER:*`
□ Existing test suites accounted for in checkpoints
□ Rollback/feature flag considerations documented (if applicable)

AGENTS_ADDITIONS.md Quality
□ Contains ONLY workflow/process additions (not business logic or domain rules)
□ If no gaps found, outputs minimal "No additions required" format
□ Does NOT include feature-specific commit examples
□ Does NOT include acceptance criteria details (those are in EXECUTION_PLAN.md)
□ Does NOT include implementation details or domain knowledge

AGENTS.md Compatibility (check for gaps)
□ All verification methods in EXECUTION_PLAN.md are defined in AGENTS.md
□ If browser verification is used, AGENTS.md has browser verification workflow
□ If regression checks are needed, AGENTS.md has regression testing policy
□ If migrations are needed, AGENTS.md has database migration workflow
□ If external dependencies involved, AGENTS.md has mocking policy
□ If testing guidance sparse, suggest Test Quality Standards addition
□ Suggested additions provided ONLY for actual workflow gaps identified
```

---

## Example: Adding User Notifications Feature

Here's a condensed example of how a feature execution plan might look:

```markdown
# Execution Plan: User Notifications

## Overview
| Metric | Value |
|--------|-------|
| Feature | Real-time user notifications |
| Target Project | MyApp |
| Total Phases | 3 |
| Total Steps | 7 |
| Total Tasks | 15 |

## Integration Points
| Existing Component | Integration Type | Notes |
|--------------------|------------------|-------|
| `src/lib/api.ts` | extends | Add notification endpoints |
| `src/hooks/useAuth.ts` | uses | Get current user for subscriptions |
| `src/components/Layout.tsx` | modifies | Add notification bell to header |
| `src/lib/db/schema.ts` | extends | Add notifications table |

## Phase Dependency Graph
┌─────────────────┐
│ Phase 1:        │
│ Data Layer      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Phase 2:        │
│ API & Backend   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Phase 3:        │
│ UI & Real-time  │
└─────────────────┘

---

## Phase 1: Data Layer

**Goal:** Establish database schema and data access patterns for notifications
**Depends On:** None

### Pre-Phase Setup
- [ ] Confirm database migration tooling is working
  - Verify: `{migration command} --help`
- [ ] Review existing schema patterns in `src/lib/db/`
  - Verify: `rg "CREATE TABLE users" src/lib/db/migrations/001_users.sql`

### Step 1.1: Schema & Migrations

#### Task 1.1.A: Create Notifications Table

**Description:**  
Add a notifications table following existing schema patterns. This table stores 
user notifications with support for read/unread status and different notification types.

**Acceptance Criteria:**
- [ ] (CODE) Migration creates `notifications` table with columns: id, user_id, type, title, body, read, created_at
  - Verify: `src/lib/db/migrations/003_notifications.sql` includes column definitions
- [ ] (CODE) Foreign key constraint links to existing users table
  - Verify: migration file includes `FOREIGN KEY (user_id) REFERENCES users(id)`
- [ ] (CODE) Index exists on user_id + created_at for efficient queries
  - Verify: migration file includes `CREATE INDEX` on `(user_id, created_at)`
- [ ] (TEST) Migration runs successfully (up and down)
  - Verify: test `should run migrations up and down`

**Files to Create:**
- `src/lib/db/migrations/003_notifications.sql` — migration file

**Files to Modify:**
- `src/lib/db/schema.ts` — add Notification type

**Existing Code to Reference:**
- `src/lib/db/migrations/001_users.sql` — follow migration patterns
- `src/lib/db/schema.ts` — follow type definition patterns

**Dependencies:** None

**Spec Reference:** Feature Spec > Data Model

**Browser Verification:**
- Criteria IDs: None
- Notes: N/A

...
```
