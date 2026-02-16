# Execution Plan Format Reference

Shared definitions used by both `/feature-plan` (feature in existing project) and
`/generate-plan` (greenfield project). Both generators MUST read this file and use
its definitions verbatim.

---

## Execution Hierarchy

| Level | Definition |
|-------|------------|
| **PHASE** | Major milestone ending with human checkpoint. Represents demonstrable functionality. Requires manual testing and approval before proceeding. Includes pre-phase setup (env vars, external services). |
| **STEP** | Ordered group of related tasks. All tasks in a step complete before next step begins. Tasks within a step may run in parallel. |
| **TASK** | Atomic unit of work for a single agent session. Has specific, testable acceptance criteria. Creates or modifies a focused set of files. Independent from parallel tasks in same step. |

---

## Verification Types

- **TEST** — Verified by running a test (name or file path)
- **CODE** — Verified by code inspection or file existence
- **LINT** — Verified by lint command
- **TYPE** — Verified by typecheck command
- **BUILD** — Verified by build command
- **SECURITY** — Verified by security scan
- **BROWSER:DOM | VISUAL | NETWORK | CONSOLE | PERFORMANCE | ACCESSIBILITY** — Verified via MCP
- **MANUAL** — Requires human judgment that BLOCKS downstream work; include a reason. USE SPARINGLY.
  Before tagging MANUAL, read `~/.claude/skills/auto-verify/PATTERNS.md` and walk
  through the MANUAL Decision Tree. Only subjective UX/brand/tone judgment is
  truly manual. File checks, API calls, DOM selectors, grep, tests — all automated.
  Most tasks should have ZERO manual criteria.
- **MANUAL:DEFER** — Requires human judgment but has NO downstream dependency.
  Deferred items accumulate and are reviewed when a blocker occurs or at project end.
  Examples: visual polish, copy tone, color choices, "feels intuitive".
  USE SPARINGLY — prefer automated verification. Most subjective items are DEFER.

**IMPORTANT:** Every non-MANUAL/non-MANUAL:DEFER criterion MUST include a
machine-verifiable `Verify:` line.

---

## EXECUTION_PLAN.md Template

```markdown
# Execution Plan: {Project or Feature Name}

## Overview

| Metric | Value |
|--------|-------|
| Feature | {Name} |
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

**Requirement:** {REQ-XXX from spec, or "None" if no direct mapping}

**Acceptance Criteria:**
- [ ] (TEST) {Specific, testable criterion}
  - Verify: `{test command or test name}`
- [ ] (CODE) {Specific, testable criterion}
  - Verify: `{command to check file/export exists}`
- [ ] (BROWSER:DOM) {Specific, testable criterion}
  - Verify: route=`{route}`, selector=`{selector}`, expect=`{state}`

Manual criteria (ONLY after walking through ~/.claude/skills/auto-verify/PATTERNS.md
decision tree steps 1-9. If ANY step 1-8 matches, use that automated type instead.
Only step 9 — subjective UX/brand/tone judgment — qualifies as MANUAL):
- [ ] (MANUAL) {Specific criterion requiring subjective judgment — blocks downstream}
  - Reason: {why no automated tool can verify this}
- [ ] (MANUAL:DEFER) {Subjective criterion with no downstream dependency}
  - Reason: {why human review is needed but doesn't block}

**Files to Create:**
- `{path/to/file}` — {purpose}

**Files to Modify:**
- `{path/to/existing/file}` — {what change and why}

**Existing Code to Reference:**
- `{path/to/file}` — {what patterns/interfaces to follow}

**Dependencies:**
- {What must exist before this task starts, or "None"}

**Spec Reference:** {Section name from spec}

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
{OMIT this section entirely if no items require subjective human judgment.
Most phases should have ZERO human-required checkpoint items.
Only include items that CANNOT be verified by tests, typechecks, linting,
code inspection, DOM selectors, curl, or grep. Walk through the MANUAL
Decision Tree in auto-verify/PATTERNS.md for each proposed item.}

- [ ] (MANUAL) {Specific thing requiring subjective judgment — e.g., "visual design matches brand"}
  - Reason: {why no automated tool can verify this}

{WRONG — do NOT put these in Human Required:
- "Review component API for consistency" → CODE: grep prop types and compare
- "Verify props match existing patterns" → CODE: diff interfaces
- "Check error handling is appropriate" → TEST: write a test
- "Review data model design" → CODE: inspect schema file
These are all automatable. Tag them CODE or TEST instead.}

**Browser Verification (if applicable):**
- [ ] All UI acceptance criteria verified via browser MCP tools
- [ ] No console errors on key pages
- [ ] Screenshots captured for visual changes

---

## Phase 2: {Phase Name}
{Continue pattern}
```

---

## Task Quality Checks

For each task, verify:

✓ Has 3-6 specific, testable acceptance criteria
✓ Every acceptance criterion includes a verification type
✓ Every non-MANUAL/non-MANUAL:DEFER criterion has a `Verify:` line with executable command
✓ Manual criteria include a reason and are minimal (< 10% of total)
✓ Lists concrete files to create/modify (not vague)
✓ References existing code to follow as patterns
✓ Specifies dependencies on prior tasks
✓ References relevant spec section
✓ Is independent from parallel tasks in same step
✓ Considers impact on existing functionality

### Red Flags to Fix

✗ Vague criteria like "works correctly" or "handles errors properly"
✗ Non-MANUAL criterion missing `Verify:` command
✗ MANUAL used for anything that can be checked by file existence, grep, curl, DOM selector, or test
✗ MANUAL used without a reason
✗ More than 1-2 MANUAL criteria per task (most tasks should have ZERO)
✗ Too many files (>7) touched in one task
✗ Dependencies on parallel tasks in the same step
✗ Missing spec reference
✗ No consideration of existing code patterns
✗ Changes to existing files without clear rationale

### Phase Checkpoint Red Flags

✗ "Human Required" section present when all items are automatable
✗ "Review X API/interface" in Human Required (compare interfaces via CODE, not human review)
✗ "Review X for consistency with Y" in Human Required (pattern-matching is CODE, not human)
✗ "Verify error handling" in Human Required (write a TEST)
✗ Any checkpoint item that can be expressed as "check that X exists / has attribute Y / contains Z"
✗ Most phases should have NO Human Required items — omit the section entirely if empty

---

## Post-Generation Checklist (EXECUTION_PLAN.md)

```
□ All phases have pre-phase setup sections (with Verify: commands)
□ All tasks have 3-6 testable acceptance criteria
□ All acceptance criteria include verification types and methods
□ All non-MANUAL criteria have Verify: lines with executable commands
□ Manual criteria include reasons (if present) and are rare (< 10%)
□ All tasks specify files to create/modify
□ All tasks have dependencies listed
□ All phases have checkpoint criteria including regression checks
□ Phase checkpoints have NO "Human Required" items unless truly subjective (walk decision tree for each)
□ "Review X API/interface for consistency" is NOT human-required — it's CODE (grep + compare)
□ No task depends on a parallel task in the same step
□ Tasks with UI criteria marked as BROWSER:*
□ Existing test suites accounted for in checkpoints
□ Rollback/feature flag considerations documented (if applicable)
□ Integration points with existing code clearly identified
□ All tasks reference existing code patterns to follow
```
