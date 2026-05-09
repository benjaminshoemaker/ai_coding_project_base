# Plan Status Convention

Use this convention whenever a project may have more than one plan, spec set,
feature experiment, or historical execution plan.

## Purpose

`plans/PLAN_STATUS.md` is the single source of truth for planning authority.
Agents may implement only the plan listed as the current plan. All other specs,
plans, backups, rejected experiments, and archived folders are historical
context unless the user explicitly makes them current again.

## Canonical Locations

| Location | Meaning |
|----------|---------|
| `plans/PLAN_STATUS.md` | Manifest with exactly one current plan pointer |
| `plans/greenfield/` | Current or latest greenfield plan set |
| `features/<name>/` | Feature plan set |
| `plans/archive/YYYYMMDD-HHMMSS-<slug>/` | Archived greenfield snapshots |
| `features/archive/YYYYMMDD-HHMMSS-<slug>/` | Archived feature snapshots |

Keep `plans/greenfield/` as the greenfield path for compatibility. Do not
replace it with `plans/current/`.

## Status Values

| Status | Implementable? | Meaning |
|--------|----------------|---------|
| `active` | Yes, if listed as current | Current work the agent may implement |
| `planned` | No | Valid future plan, not current yet |
| `completed` | No | Implemented or intentionally closed |
| `superseded` | No | Replaced by another plan |
| `rejected` | No | Explicitly rejected by the user |
| `abandoned` | No | Stopped before completion |
| `research` | No | Useful thinking only |

Suggested stage values: `discovery`, `product-spec`, `technical-spec`,
`execution-plan`, `execution`, `completed`.

## Manifest Format

```markdown
# Plan Status

Current plan: `plans/greenfield/`
Current type: `greenfield`
Current stage: `execution-plan`
Current status: `active`
Last updated: YYYY-MM-DD
Updated by: /generate-plan

Rule: Agents may implement only the Current plan above. Archived, rejected,
abandoned, superseded, completed, and research-only plans are context only.

## Current Scope

- What is being built: {one sentence}
- Source docs: `plans/greenfield/PRODUCT_SPEC.md`, `plans/greenfield/TECHNICAL_SPEC.md`
- Next command: `cd plans/greenfield && /fresh-start`

## History

| Path | Type | Status | Superseded By | Updated | Notes |
|------|------|--------|---------------|---------|-------|
| `plans/greenfield/` | greenfield | active |  | YYYY-MM-DD | Current plan |
```

## Generation Rules

Before writing or replacing any plan document:

1. Ensure `plans/` exists.
2. Read `plans/PLAN_STATUS.md` if it exists.
3. If another plan is listed as current and `active`, ask whether the new plan:
   - supersedes the current plan
   - should be recorded as non-current research/planned work
   - should be aborted
4. If a plan is superseded, rejected, or abandoned, archive a snapshot before
   overwriting or replacing files.
5. Update `plans/PLAN_STATUS.md` after writing the new document so the current
   plan, stage, status, and history are accurate.

## Archive Rules

Use archive snapshots instead of loose `.bak` files in active plan directories.

For greenfield plan replacement:

1. Create `plans/archive/YYYYMMDD-HHMMSS-greenfield/`.
2. Copy the existing `plans/greenfield/` planning documents into that folder.
3. Add or prepend a status note to archived Markdown files when practical:

   ```markdown
   > STATUS: SUPERSEDED
   > Do not implement this plan. Current plan: `{current path}`.
   > This document is preserved for rationale and historical context only.
   ```

4. Keep `plans/greenfield/` as the live path and overwrite only the files being
   regenerated.

For feature replacement:

1. Create `features/archive/YYYYMMDD-HHMMSS-<feature-name>/`.
2. Copy the existing `features/<feature-name>/` planning documents into it.
3. Mark the old feature path as `superseded`, `rejected`, or `abandoned` in
   `plans/PLAN_STATUS.md`.

## Execution Guard

Before executing work from `plans/greenfield/` or `features/<name>/`:

1. Read `PROJECT_ROOT/plans/PLAN_STATUS.md` when it exists.
2. Compare the current plan path to the execution directory.
3. If they differ, stop and report the current plan path.
4. If the current status is not `active`, stop and ask the user to choose or
   reactivate a plan.
5. If the manifest is missing, continue with the legacy directory convention
   but recommend creating `plans/PLAN_STATUS.md` during the next planning step.

Never implement from `plans/archive/`, `features/archive/`, `.bak` files,
rejected plans, abandoned plans, or completed plans unless the user explicitly
reactivates that plan and updates `plans/PLAN_STATUS.md`.
