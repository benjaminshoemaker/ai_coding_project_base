══════════════════════════════════════════════════════════════════════════════
PART 3A: ROOT AGENTS.md FORMAT
══════════════════════════════════════════════════════════════════════════════

**SIZE CONSTRAINT: Keep root AGENTS.md under 100 lines.**

This file is the durable, project-wide instruction set. Execution-specific detail
belongs in scoped directories such as `plans/greenfield/` or `features/<name>/`.

# AGENTS.md

Workflow guidelines for AI agents working in this project.

## Instruction Hierarchy

- This file is the project-wide baseline.
- Greenfield execution guidance lives in `plans/greenfield/AGENTS.md`.
- Feature execution guidance lives in `features/<name>/AGENTS.md`.
- When working in a scoped directory, follow this file first, then the local
  `AGENTS.md` or `CLAUDE.md` in that directory.

## Project Context

**Tech Stack:** {language, runtime, framework, test runner, package manager}

**Dev Server:** `{command}` → `{url}` (wait {N}s for startup)

## Core Workflow

1. Load the nearest scoped instructions for the area you are editing.
2. Read the relevant specification and execution-plan documents before changing code.
3. Confirm dependencies and existing patterns before implementing.
4. Make the smallest change that satisfies the active task.
5. Add or update tests when behavior changes.
6. Run configured verification before reporting completion.
7. Update execution-plan checkboxes when scoped work requires it.
8. Commit using the project task format after verification passes.

## Guardrails

- Do not invent requirements that are not in the active spec or plan.
- Do not skip, disable, or misreport failing tests.
- Do not rewrite or revert unrelated user changes.
- Do not introduce new dependencies or APIs without noting the impact.
- If access, secrets, or requirements are missing, stop and ask.

## Verification

- Use `.claude/verification-config.json` when it exists.
- If scoped instructions define additional verification steps, follow them.
- If verification metadata is missing from an execution plan, add it before proceeding.

## Git Conventions

- Work on phase branches for execution-plan work.
- Create one commit per completed task after verification passes.
- Commit format: `task({id}): {description} [REQ-XXX]`
- If no requirement ID applies, omit the bracketed suffix.
- Use `/create-pr` instead of ad hoc PR formatting when available.

## Follow-Up Items

- Track out-of-scope issues in `TODOS.md` instead of silently dropping them.
- Capture durable project patterns in `LEARNINGS.md` when they will help future work.

## Completion Report

When finishing a task, report:
- what changed
- files touched
- verification status
- commit hash
