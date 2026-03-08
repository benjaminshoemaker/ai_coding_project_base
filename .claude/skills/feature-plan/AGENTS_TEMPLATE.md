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
2. `FEATURE_SPEC.md`
3. `FEATURE_TECHNICAL_SPEC.md`
4. `EXECUTION_PLAN.md`
5. `../../LEARNINGS.md` if it exists

## Task Loop

1. Start fresh for each new task.
2. Read the task definition and acceptance criteria from `EXECUTION_PLAN.md`.
3. Confirm dependencies and relevant existing-code patterns.
4. Add or update tests when behavior changes.
5. Implement the minimum change needed.
6. Verify using the metadata in `EXECUTION_PLAN.md` and `.claude/verification-config.json`.
7. Update completed checkboxes in `EXECUTION_PLAN.md`.
8. Commit after verification passes using `task({id}): {description} [REQ-XXX]`.

## Regression Expectations

- When touching existing code, run the relevant regression checks, not just new tests.
- Reuse existing project patterns before introducing new ones.

## Feature-Specific Workflow Additions

- No additional feature-specific workflow rules are required beyond `../../AGENTS.md`.
```

Only replace the final section when the feature genuinely introduces a new
workflow category that is not already covered in the root `AGENTS.md`.
