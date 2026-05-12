═══════════════════════════════════════════════════════════════════
PART 6: FEATURE-LOCAL AGENTS.md FORMAT
═══════════════════════════════════════════════════════════════════

This file is scoped to `features/<name>/`. Durable project-wide rules belong in
the root `AGENTS.md`. This file adds only the local context and any genuinely new
workflow needed for this feature.

### Litmus Test (apply to EVERY proposed addition)

> "Would this addition be useful for a DIFFERENT feature in a DIFFERENT project?"

- **YES** → It might be a legitimate workflow addition
- **NO** → It is feature-specific knowledge and does NOT belong here

### What Belongs in This File

- Which files agents must read when working from `features/<name>/`
- Scoped execution reminders for this feature directory
- Feature-specific workflow additions that are truly new to the project

### What Does NOT Belong in This File

- Business logic or domain rules
- Acceptance criteria details from `EXECUTION_PLAN.md`
- Component or architecture notes about this specific feature
- Feature summaries that duplicate `FEATURE_SPEC.md` or `FEATURE_TECHNICAL_SPEC.md`
- Durable project-wide policies that belong in the root `AGENTS.md`

### Output Format

Always output a complete `AGENTS.md` for the feature directory in this format:

```markdown
# AGENTS.md

Scoped execution guidance for this feature.

Base project rules live in `../../AGENTS.md`.

## Scope

- Run feature execution commands from this directory.
- This file applies only to work tracked by this directory's `EXECUTION_PLAN.md`.

## Required Context

Before starting a task, read:
1. `../../AGENTS.md`
2. `../../plans/PLAN_STATUS.md` and confirm this feature is active, or that the
   user explicitly directed work in this planned feature
3. `FEATURE_SPEC.md`
4. `FEATURE_TECHNICAL_SPEC.md`
5. `FLOW_VERIFICATION_PLAN.md` if it exists
6. `EXECUTION_PLAN.md`
7. `../../LEARNINGS.md` if it exists

## Task Loop

1. Start fresh for each new task.
2. Read the task definition and acceptance criteria from `EXECUTION_PLAN.md`.
3. Confirm dependencies and relevant existing-code patterns.
4. Default to TDD for behavior changes: add or update a failing automated test first, then implement the minimum fix and refactor with tests green.
5. Implement the minimum change needed.
6. Verify using the metadata in `EXECUTION_PLAN.md` and `.claude/verification-config.json`.
7. Update completed checkboxes in `EXECUTION_PLAN.md`.
8. Commit after verification passes using `task({id}): {description} [REQ-XXX]`.

## Regression Expectations

- When touching existing code, run the relevant regression checks, not just new tests.
- Reuse existing project patterns before introducing new ones.
- Follow instruction/config safety rules from `../../AGENTS.md` when editing
  `AGENTS.md`, `CLAUDE.md`, `.claude/rules/**`, `.claude/settings*.json`, or
  `.mcp.json`.
- Before asking for manual verification, try to verify directly using this order:
  1. repo-native verification scripts/tests
  2. local CLI tools
  3. direct API or SDK calls
  4. MCP tools
  5. browser automation or Computer Use
  If blocked, record attempted tools/commands, outcomes, and the next viable
  option before declaring a human-only blocker.

## Feature-Specific Workflow Additions

- No additional feature-specific workflow rules are required beyond `../../AGENTS.md`.
```

Only replace the final section when the feature genuinely introduces a new
workflow category that is not already covered in the root `AGENTS.md`.
