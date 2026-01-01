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
- [ ] {Environment variables needed}
- [ ] {Other manual prerequisites}

### Step 1.1: {Step Name}
**Depends On:** {Prior steps or "None"}

---

#### Task 1.1.A: {Task Name}

**Description:**  
{2-3 sentences explaining what to build and why, including how it integrates with existing code}

**Acceptance Criteria:**
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}

**Files to Create:**
- `{path/to/file}` — {purpose}

**Files to Modify:**
- `{path/to/existing/file}` — {what change and why}

**Existing Code to Reference:**
- `{path/to/file}` — {what patterns/interfaces to follow}

**Dependencies:**
- {What must exist before this task starts, or "None"}

**Spec Reference:** {Section name from feature spec}

**Requires Browser Verification:** {Yes/No}
- If Yes, list which acceptance criteria need browser verification

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
✓ Lists concrete files to create/modify
✓ References existing code to follow as patterns
✓ Specifies dependencies on prior tasks
✓ References relevant feature spec section
✓ Is independent from parallel tasks in same step
✓ Considers impact on existing functionality

Red flags to fix:
✗ Vague criteria like "works correctly" or "handles errors properly"
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

## Feature Specification

{Paste or attach your feature spec here. This should include:}
- What the feature does (user-facing behavior)
- Technical requirements and constraints
- Acceptance criteria for the feature as a whole
- Any wireframes, API contracts, or data models

═══════════════════════════════════════════════════════════════════
PART 6: AGENTS.md ADDITIONS FORMAT
═══════════════════════════════════════════════════════════════════

If the feature requires workflow elements not present in the existing AGENTS.md,
output suggested additions in this format:

## Suggested AGENTS.md Additions

### Reason for additions
{Brief explanation of why these additions are needed for this feature}

### New sections to add

#### {Section Name}
```
{Content to add to AGENTS.md}
```

**Where to add:** {After which existing section}

---

Common additions to consider:

**Browser Verification Workflow** — If feature has UI acceptance criteria
```
## Browser Verification

For tasks marked "Requires Browser Verification: Yes":
1. Start dev server if not running
2. Navigate to relevant pages
3. Verify each UI acceptance criterion visually
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

Note: The execution plan references FEATURE_SPEC.md (your feature specification)
instead of TECHNICAL_SPEC.md for context management purposes.
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
□ All tasks specify files to create/modify
□ All tasks have dependencies listed
□ All phases have checkpoint criteria including regression checks
□ No task depends on a parallel task in the same step
□ Tasks with UI criteria marked as "Requires Browser Verification: Yes"
□ Existing test suites accounted for in checkpoints
□ Rollback/feature flag considerations documented (if applicable)

AGENTS.md Compatibility
□ All verification methods in EXECUTION_PLAN.md are defined in AGENTS.md
□ If browser verification is used, AGENTS.md has browser verification workflow
□ If regression checks are needed, AGENTS.md has regression testing policy
□ If migrations are needed, AGENTS.md has database migration workflow
□ Suggested additions provided for any workflow gaps identified
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
- [ ] Review existing schema patterns in `src/lib/db/`

### Step 1.1: Schema & Migrations

#### Task 1.1.A: Create Notifications Table

**Description:**  
Add a notifications table following existing schema patterns. This table stores 
user notifications with support for read/unread status and different notification types.

**Acceptance Criteria:**
- [ ] Migration creates `notifications` table with columns: id, user_id, type, title, body, read, created_at
- [ ] Foreign key constraint links to existing users table
- [ ] Index exists on user_id + created_at for efficient queries
- [ ] Migration runs successfully (up and down)

**Files to Create:**
- `src/lib/db/migrations/003_notifications.sql` — migration file

**Files to Modify:**
- `src/lib/db/schema.ts` — add Notification type

**Existing Code to Reference:**
- `src/lib/db/migrations/001_users.sql` — follow migration patterns
- `src/lib/db/schema.ts` — follow type definition patterns

**Dependencies:** None

**Spec Reference:** Feature Spec > Data Model

**Requires Browser Verification:** No

...
```
