══════════════════════════════════════════════════════════════════════════════
PART 3B: GREENFIELD PLAN AGENTS.md FORMAT
══════════════════════════════════════════════════════════════════════════════

Keep this file focused on work executed from `plans/greenfield/`.

# AGENTS.md

Scoped execution guidance for the initial greenfield build.

Base project rules live in `../../AGENTS.md`.

## Scope

- Run greenfield execution commands from this directory: `plans/greenfield/`
- This file applies only to the initial project build tracked by `EXECUTION_PLAN.md`
- Feature work belongs in `features/<name>/`

## Required Context

Before starting a task, read:
1. `../../AGENTS.md`
2. `PRODUCT_SPEC.md`
3. `TECHNICAL_SPEC.md`
4. `EXECUTION_PLAN.md`
5. `../../LEARNINGS.md` if it exists

## Task Loop

1. Start fresh for each new task.
2. Read the task definition and its acceptance criteria from `EXECUTION_PLAN.md`.
3. Confirm prior dependencies are complete.
4. Add or update tests for the acceptance criteria when behavior changes.
5. Implement the minimum change needed to satisfy the task.
6. Verify using the metadata in `EXECUTION_PLAN.md` and `.claude/verification-config.json`.
7. Update completed checkboxes in `EXECUTION_PLAN.md`.
8. Commit after verification passes using `task({id}): {description} [REQ-XXX]`.

## Verification

- All acceptance criteria must be satisfied before a task is complete.
- Run configured test, typecheck, lint, and build commands when available.
- If an acceptance criterion uses browser or manual verification, follow the
  execution and checkpoint skills for that verification type.
- If verification metadata is missing, add it before proceeding.

## When To Stop And Ask

Stop and ask the human if:
- a dependency, file, or service is missing
- secrets or environment variables are required
- requirements conflict or are ambiguous
- verification keeps failing and the cause is not clear
- the task appears to require out-of-scope architectural changes

## Blocker Report

Use this format when blocked:

```text
BLOCKED: Task {id}
Issue: {what is wrong}
Tried: {what you attempted}
Need: {what would unblock}
Type: user-action | dependency | external-service | unclear-requirements
```
