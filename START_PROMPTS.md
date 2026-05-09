# Start Prompts

Copy-paste prompts for executing phases from your EXECUTION_PLAN.md.

---

## Greenfield Projects

Use these prompts when working with documents generated from the greenfield workflow (`AGENTS.md`, `plans/PLAN_STATUS.md`, `plans/greenfield/PRODUCT_SPEC.md`, `plans/greenfield/TECHNICAL_SPEC.md`, `plans/greenfield/EXECUTION_PLAN.md`, `plans/greenfield/AGENTS.md`).

### Fresh Start

Use this when beginning work on a new project or onboarding to an existing execution plan.

```
Read the following files to understand the structure and purpose of this project:
- ../../AGENTS.md or AGENTS.md at project root (workflow guidelines)
- ../PLAN_STATUS.md or plans/PLAN_STATUS.md at project root (current-plan pointer)
- AGENTS.md in `plans/greenfield/` (scoped execution guidance)
- PRODUCT_SPEC.md (what we're building and why)
- TECHNICAL_SPEC.md (how it's built technically)
- EXECUTION_PLAN.md (tasks and acceptance criteria)

Summarize your understanding and confirm you're ready to begin execution.
```

### Phase Prep

Use this before starting a new phase to verify prerequisites are met.

```
I want to execute Phase {N} from EXECUTION_PLAN.md. Before starting:

1. Check plans/PLAN_STATUS.md — is this directory the current active plan?
2. Check the Pre-Phase Setup section — are there unmet prerequisites I need to complete?
3. Verify dependencies — are all prior phases complete?
4. Run a criteria audit for Phase 1 — are acceptance criteria tagged with verification metadata?
5. Ensure verification config is set — if missing, run /configure-verification
6. Review permissions — are there any permissions needed in configuration files for autonomous execution?

Report what's ready and what's blocking.
```

### Phase Start

Use this to execute all tasks in a phase autonomously.

```
I have completed all prerequisites for Phase {N}. Execute all steps and tasks in Phase {N} from EXECUTION_PLAN.md, one at a time.

Guidelines:
- Read both the root `AGENTS.md` and the scoped `plans/greenfield/AGENTS.md`
- Confirm `plans/PLAN_STATUS.md` marks `plans/greenfield/` as the current active plan
- Use the code-verification skill for every task
- Do not check back until the phase is complete, unless blocked
- Report blockers using the format in AGENTS.md

Begin with Step {N}.1.
```

### Phase Checkpoint

Use this after completing a phase to verify before proceeding.

```
Phase {N} is complete. Run the checkpoint criteria from EXECUTION_PLAN.md:

1. Automated checks — run tests, type checking, linting
2. Manual verification — list items for me to verify
3. Summarize what was built in this phase

Report results and confirm ready to proceed to Phase {N+1}.
```

---

## Feature Development

Use these prompts when working with documents generated from the feature workflow (`AGENTS.md` at project root plus `plans/PLAN_STATUS.md`, `features/<name>/AGENTS.md`, `FEATURE_SPEC.md`, `FEATURE_TECHNICAL_SPEC.md`, and `EXECUTION_PLAN.md`).

### Fresh Start

Use this when beginning work on a new feature.

```
Read the following files to understand this feature and how it integrates:
- ../../AGENTS.md (project-wide workflow guidelines)
- ../../plans/PLAN_STATUS.md (current-plan pointer)
- AGENTS.md in this feature directory (scoped workflow guidance)
- FEATURE_SPEC.md (what the feature does and why)
- FEATURE_TECHNICAL_SPEC.md (how it integrates technically)
- EXECUTION_PLAN.md (tasks and acceptance criteria)

Summarize your understanding of the feature and its integration points. Confirm you're ready to begin execution.
```

### Phase Prep

Use this before starting a new phase to verify prerequisites are met.

```
I want to execute Phase {N} from EXECUTION_PLAN.md for this feature. Before starting:

1. Check plans/PLAN_STATUS.md — is this feature directory the current active plan?
2. Check the Pre-Phase Setup section — are there unmet prerequisites I need to complete?
3. Verify dependencies — are all prior phases complete?
4. Run a criteria audit for Phase 1 — are acceptance criteria tagged with verification metadata?
5. Ensure verification config is set — if missing, run /configure-verification
6. Review integration points — are the existing components we're modifying in the expected state?
7. Check for any permissions needed in configuration files for autonomous execution

Report what's ready and what's blocking.
```

### Phase Start

Use this to execute all tasks in a phase autonomously.

```
I have completed all prerequisites for Phase {N}. Execute all steps and tasks in Phase {N} from EXECUTION_PLAN.md, one at a time.

Guidelines:
- Read both the root `AGENTS.md` and the feature-local `AGENTS.md`
- Confirm `plans/PLAN_STATUS.md` marks this feature directory as the current active plan
- Use the code-verification skill for every task
- Pay attention to "Existing Code to Reference" in each task for patterns to follow
- Run existing tests after modifications to catch regressions
- Do not check back until the phase is complete, unless blocked
- Report blockers using the format in AGENTS.md

Begin with Step {N}.1.
```

### Phase Checkpoint

Use this after completing a phase to verify before proceeding.

```
Phase {N} is complete. Run the checkpoint criteria from EXECUTION_PLAN.md:

1. Automated checks — run tests (including existing tests), type checking, linting
2. Regression verification — confirm existing functionality still works
3. Manual verification — list items for me to verify
4. Browser verification (if applicable) — verify UI acceptance criteria

Report results and confirm ready to proceed to Phase {N+1}.
```

---

## Recovery Prompts

Use these when execution is interrupted or blocked. Optional: some are also available as slash commands if you've installed the recovery commands.

### Analyze Phase Problems

Use `/phase-analyze` to understand what went wrong in a phase before deciding how to proceed.

```bash
/phase-analyze 2    # Analyze Phase 2
/phase-analyze      # Analyze current/most recent phase
```

This generates a comprehensive report including:
- Task completion status
- Failure patterns detected
- High-churn files (rework indicators)
- Spec alignment issues
- Root cause analysis
- Recommended next steps

### Rollback to Clean State

Use `/phase-rollback` when you need to undo work and start fresh.

```bash
/phase-rollback 1       # Rollback to end of Phase 1
/phase-rollback 2.1.A   # Rollback to just after Task 2.1.A
/phase-rollback --last  # Undo only the most recent task commit
```

The command will:
- Show what commits will be removed
- Ask for confirmation before proceeding
- Update EXECUTION_PLAN.md checkboxes
- Provide recovery instructions if needed

### Retry Failed Task

Use `/task-retry` when a specific task failed and needs another attempt.

```bash
/task-retry 2.1.A              # Retry with fresh context
/task-retry 2.1.A --fresh      # Explicitly start clean
/task-retry 2.1.A --alternative # Try a different approach
```

The `--alternative` flag is useful when the standard approach keeps failing. It will:
- Document what was tried before
- Generate alternative approaches
- Let you choose which to try
- Add constraints to avoid repeating mistakes

### Resume After Blocker

Use this when a blocker has been resolved and you want to continue.

```
The blocker for Task {X.Y.Z} has been resolved.

Resolution: {describe what was fixed or provided}

Continue execution from Task {X.Y.Z}. Pick up where you left off.
```

### Handle Scope Discovery

Use this when new work is discovered that's outside the current task scope.

```
While working on Task {X.Y.Z}, I discovered: {description of issue or opportunity}

Add this to TODOS.md with appropriate context and priority, then continue with the current task scope. Do not expand scope without approval.
```

### Skip to Specific Task

Use this to jump to a specific task (e.g., after manual fixes).

```
Skip to Task {X.Y.Z} in EXECUTION_PLAN.md.

Context: {why we're skipping, what was done manually}

Begin execution from this task. Verify any dependencies are met before starting.
```

---

## Tips

- **Always run Phase Prep before Phase Start** — Catching missing prerequisites early saves time
- **Use checkpoints religiously** — They catch issues before they compound
- **Fresh context per task** — Each task should start with fresh context as specified in AGENTS.md
- **Track discoveries in TODOS.md** — Don't let scope creep derail execution
