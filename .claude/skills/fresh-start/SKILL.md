---
name: fresh-start
description: Orient to project structure and load context. Use at the start of each new session or after context reset to understand the project state.
argument-hint: [project-directory]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, AskUserQuestion
---

Orient to a scoped execution directory and load context for execution.

## Workflow

**Nested skill rule:** When this workflow invokes another skill (e.g.,
`/configure-verification`, `/phase-prep`, `/phase-start`), you MUST return to
this checklist after the nested skill completes and continue with the next
unchecked item. Do not stop or summarize after a nested skill returns.

Copy this checklist and track progress:

```
Fresh Start Progress:
- [ ] Detect context (greenfield plan vs feature directory)
- [ ] Directory guard (verify AGENTS.md + EXECUTION_PLAN.md exist)
- [ ] Git initialization (if needed)
- [ ] Feature branch setup (feature mode only)
- [ ] Scoped AGENTS check
- [ ] Read context and summarize
- [ ] Auto-configure verification (first run only)
- [ ] Phase state detection
- [ ] Auto-prep phase (first run only)
- [ ] Branch context detection
```

## Project Directory

Use the current working directory by default.

If `$1` is provided, treat `$1` as the working directory and read files under `$1` instead.

## Context Detection

Determine working context before validation.

**Convention:** Run execution commands from the scoped directory that contains the active `EXECUTION_PLAN.md`:
- Greenfield: `plans/greenfield/`
- Feature work: `features/<name>/`

1. Let WORKING_DIR = `$1` if provided, otherwise current working directory

2. If WORKING_DIR matches pattern `*/features/*` (contains `/features/` followed by a feature name):
   - PROJECT_ROOT = parent of parent of WORKING_DIR (e.g., `/project/features/foo` → `/project`)
   - SCOPE_DIR = WORKING_DIR
   - MODE = "feature"

3. If WORKING_DIR matches pattern `*/plans/greenfield*`:
   - PROJECT_ROOT = parent of parent of WORKING_DIR (e.g., `/project/plans/greenfield` → `/project`)
   - SCOPE_DIR = WORKING_DIR
   - MODE = "greenfield"

4. Otherwise:
   - PROJECT_ROOT = WORKING_DIR
   - SCOPE_DIR = WORKING_DIR
   - MODE = "greenfield-legacy"

## Directory Guard (Wrong Directory Check)

Confirm the required files exist:
- `PROJECT_ROOT/AGENTS.md` must exist
- `EXECUTION_PLAN.md` must exist in `SCOPE_DIR`

- If either is missing:
  - If `WORKING_DIR = PROJECT_ROOT` and `PROJECT_ROOT/plans/greenfield/EXECUTION_PLAN.md` exists, tell the user:
    1. The greenfield execution plan now lives in `plans/greenfield/`
    2. `cd plans/greenfield`
    3. Re-run `/fresh-start`
  - Tell the user this project is not ready for execution yet
  - If they are in the toolkit repo (e.g., `.toolkit-marker` exists), instruct them to:
    1. Run `/setup <project-path>` from the toolkit repo, then `/generate-plan` from the project (or `/feature-plan` for features)
    2. `cd` into the project/feature directory
    3. Re-run `/fresh-start`
  - Otherwise, ask the user for the correct project directory path and re-run `/fresh-start <project-path>`

## Git Initialization (First Run)

In PROJECT_ROOT (not the feature directory):

1. Check whether this is already a git repo by running:
   ```bash
   git -C PROJECT_ROOT rev-parse --is-inside-work-tree 2>/dev/null
   ```
   If this returns "true", it's already a git repo.
2. If not a git repo:
   - Ask: "Initialize git in this project now?" (recommended)
   - If yes:
     ```bash
     git init
     git branch -M main
     ```
3. If it is a git repo but has no commits yet:
   - Ask: "Create an initial commit of the current project state now?" (recommended)
   - If yes:
     ```bash
     git add -A
     ```
     Verify with `git status` that files are staged correctly.
     ```bash
     git commit -m "chore: initial commit"
     ```
     Verify with `git log --oneline -1` that the commit was created.

## Feature Branch Setup (Feature Mode Only)

If MODE = "feature", create an isolated branch for this feature work:

1. Derive FEATURE_NAME from the feature directory (basename of `SCOPE_DIR`, e.g., `analytics-dashboard`)

2. Check current branch:
   ```bash
   git branch --show-current
   ```

3. If already on a `feature/FEATURE_NAME` branch, skip (already set up)

4. Otherwise, create and switch to the feature branch:
   ```bash
   # Commit any uncommitted changes first (preserves user work)
   git add -A && git diff --cached --quiet || git commit -m "wip: uncommitted changes before feature/FEATURE_NAME"
   ```
   Verify with `git status` that files are staged correctly.
   ```bash
   # Create feature branch from current HEAD
   git checkout -b feature/FEATURE_NAME
   ```
   Verify with `git branch` that the new branch is active.

5. Report: "Created branch `feature/FEATURE_NAME` for isolated feature development"

## Scoped AGENTS Check

If `SCOPE_DIR/AGENTS.md` exists and `SCOPE_DIR != PROJECT_ROOT`, report:
- "Scoped AGENTS.md found. Local instructions will layer on top of PROJECT_ROOT/AGENTS.md."

If it does not exist and `MODE` is `feature` or `greenfield`, report:
- "No scoped AGENTS.md found in this directory. Execution will fall back to PROJECT_ROOT/AGENTS.md only."

## Auto-Configure Verification (First Run Only)

Silently auto-detect verification commands if not already configured.

1. Read `PROJECT_ROOT/.claude/verification-config.json` (use Read tool directly).
   If the file does not exist (read fails with not found), treat as missing and go to step 4.
2. **If the file exists and has a `commands` key → SKIP. Do not invoke /configure-verification.**
   Report "Verification config already exists" and go directly to Phase State Detection.
3. **If the file exists with `{"skipped": true}` → SKIP.** Same as above.
4. **If the file is missing, empty, or malformed** (exists but has neither `commands` nor
   `skipped`), invoke `/configure-verification` with `SCOPE_DIR`. This runs silently
   with no prompts. If it fails, report the error and continue.

**→ CONTINUE to Phase State Detection** (do not stop after this step).

## Phase State Detection

Check for existing phase state to determine if this is a resume or first run:

1. Check if `.claude/phase-state.json` exists in:
   - `SCOPE_DIR` (if feature mode)
   - `PROJECT_ROOT` (if greenfield mode)

2. **If valid phase state exists** (file exists, parses correctly, has `current_phase`):
   - This is a **resume**. Skip auto-configure and auto-prep (already done).
   - Report:
     ```
     RESUMING SESSION
     ================
     Current phase: {current_phase}
     Completed: {count} tasks
     In progress: Task {in_progress_task} (if any)
     Last activity: {relative time, e.g., "2 hours ago"}
     ```
   - If `in_progress_task` exists, offer to continue:
     - "Continue with Task {id}: {task title}?" [Y/n]
     - If yes, jump directly to that task after context load
   - **Do not run auto-prep on resume.** Go straight to Branch Context Detection.

3. **If no phase state exists** (or file is invalid/stale):
   - This is a **first run**. Continue to Auto-Prep Phase section.

## Auto-Prep Phase (First Run Only)

**Skip this section entirely if resuming** (phase-state.json exists and is valid).

After context reading and verification config, automatically prepare the next phase:

1. **Determine next phase number:**
   - If no phase state exists → Phase 1
   - If phase state exists but is stale/invalid → Phase 1

2. **Invoke `/phase-prep {next_phase}`** silently.
   - Phase-prep will verify prerequisites and auto-advance to `/phase-start` if
     all checks pass (via its existing auto-advance logic).
   - If phase-prep blocks (human setup needed), it will report what's needed
     and the user runs `/phase-start` manually after resolving.

3. **Fallback auto-advance check** — After `/phase-prep` returns, read
   `.claude/phase-prep-result.json`. If the file does NOT exist, phase-prep
   dropped its auto-advance step (known issue with nested Skill tool invocations).
   In this case:
   - Check if all phase-prep pre-flight checks passed (read the verification log)
   - If READY: show a warning and invoke `/phase-start {next_phase}` directly
     ```
     WARNING: phase-prep did not complete auto-advance. Invoking /phase-start directly.
     ```
   - If BLOCKED or unclear: report what's known and stop

**→ CONTINUE to Branch Context Detection** (do not stop after this step).

## Branch Context Detection

Detect the current git branch and load relevant context:

1. Get current branch:
   ```bash
   git branch --show-current 2>/dev/null
   ```

2. If branch matches `feature/*` pattern:
   - Extract feature name from branch (e.g., `feature/analytics-dashboard` → `analytics-dashboard`)
   - Look for matching feature directory: `PROJECT_ROOT/features/{feature-name}/`
   - If found and MODE is "greenfield", suggest: "Switch to feature mode? Found feature directory for this branch."

3. Summarize recent branch activity:
   ```bash
   git log --oneline -5 2>/dev/null
   ```
   Report: "Recent commits on this branch: {summary}"

4. Check for uncommitted changes:
   ```bash
   git status --porcelain 2>/dev/null
   ```
   If changes exist, report: "Note: {N} uncommitted changes in working tree"

## Required Context

Read these files first:
- **PROJECT_ROOT/AGENTS.md** — Durable project-wide workflow guidelines
- **SCOPE_DIR/AGENTS.md** — Scoped execution guidance (if `SCOPE_DIR != PROJECT_ROOT`)
- **SCOPE_DIR/EXECUTION_PLAN.md** — Tasks and acceptance criteria

## Specification Documents

Check which of these exist and read them:

**From PROJECT_ROOT** (always check):
- **LEARNINGS.md** — Discovered patterns and gotchas (if exists)

**From `plans/greenfield/`** (if greenfield mode):
- **PRODUCT_SPEC.md** — What we're building
- **TECHNICAL_SPEC.md** — How it's built

**From PROJECT_ROOT** (if `MODE = "greenfield-legacy"`):
- **PRODUCT_SPEC.md** — Legacy greenfield product spec
- **TECHNICAL_SPEC.md** — Legacy greenfield technical spec

**From SCOPE_DIR** (if feature mode):
- **FEATURE_SPEC.md** — Feature requirements
- **FEATURE_TECHNICAL_SPEC.md** — Feature technical approach

## Your Task

1. Read all available documents above
2. Summarize your understanding:
   - What is being built
   - Current phase and progress
   - Tech stack and key patterns
   - Key learnings to follow (if LEARNINGS.md exists)
3. Confirm you're ready to begin execution

## Error Handling

| Situation | Action |
|-----------|--------|
| Git init or clone failure | Report the error and stop — cannot proceed without a working repository. |
| Scoped AGENTS.md missing or malformed | Report the issue and continue with root AGENTS.md only. |
| /phase-prep failure | Report which pre-flight check failed and stop. Do not proceed to execution. |

**Important:** If LEARNINGS.md exists, apply those patterns throughout your work. These are project-specific conventions discovered during development that override general defaults.
