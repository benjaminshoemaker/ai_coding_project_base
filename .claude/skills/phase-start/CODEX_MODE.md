# Codex Execution Mode

Execute tasks via `/codex-implement` instead of raw Codex CLI. Claude orchestrates
the phase; `/codex-implement` handles decomposition, scoped context, safety guards,
and multi-tier verification for each task.

## Prerequisites Check

Skip this section if `--codex` was not provided.

### Check Codex CLI

```bash
# Verify Codex is installed
codex --version

# Verify authentication
codex login status
```

**If Codex CLI not available:**
```
ERROR: --codex flag requires Codex CLI
=======================================
Codex CLI is not installed or not authenticated.

Install: npm install -g @openai/codex
Auth:    codex login

Falling back to default execution mode.
```

Fall back to default mode (Claude Code executes directly). Do NOT block the phase.

## Task Execution via /codex-implement

For each task in the phase:

### a. Build Task Spec File

Write a temporary spec file from the execution plan task data:

```bash
TASK_SPEC="/tmp/phase-task-${TASK_ID}.md"
```

Write the following content to `$TASK_SPEC`:

```markdown
# Task {task_id}: {task description from EXECUTION_PLAN.md}

## Acceptance Criteria

{Copy acceptance criteria verbatim from EXECUTION_PLAN.md for this task}

## Files to Create/Modify

{Copy file list from EXECUTION_PLAN.md for this task}

## Constraints

- Follow patterns in AGENTS.md
- Follow conventions discovered in codebase
- Do NOT modify files outside the listed scope
- Do NOT modify EXECUTION_PLAN.md
{If task has Requirement traceability: "- Requirement: REQ-XXX"}
```

### b. Invoke /codex-implement

Use the Skill tool to invoke `/codex-implement` with the task spec file:

```
/codex-implement {TASK_SPEC} --no-commit --batch
```

**Flags explained:**
- `--no-commit`: Phase-start handles commits (one commit per task with traceability tags)
- `--batch`: Non-interactive mode — skips user confirmations since the execution plan is already approved

### c. Process Results

Parse the `CODEX_IMPLEMENT_RESULT` block from `/codex-implement`'s output:

```
CODEX_IMPLEMENT_RESULT
======================
Status: COMPLETE | PARTIAL | FAILED
Tasks: {completed}/{total}
Files changed: {list}
Issue: {description, only if PARTIAL or FAILED}
```

**On `COMPLETE`** (all sub-tasks succeeded):
1. Proceed to verification (see below)

**On `PARTIAL`** (some sub-tasks failed):
1. Review which sub-tasks succeeded — their changes are in the working tree
2. Proceed to verification for the successful parts
3. Log the failures to `phase-state.json`

**On `FAILED`**:
1. Apply phase-start's stuck detection logic (increment `failures.consecutive`, append `Issue` to `last_errors` in `phase-state.json`)
2. Clean up temp file: `rm -f $TASK_SPEC`
3. Check stuck thresholds before retrying
4. If not stuck: retry by invoking `/codex-implement` again with the same spec
5. If stuck: clean up temp file and escalate to human (see Stuck Detection in main SKILL.md)

### d. Verify and Commit

After `/codex-implement` returns `COMPLETE` or `PARTIAL`:

1. Run `/verify-task {task_id}` — **this is the commit gate**. Only commit if verification passes.
2. If `/verify-task` fails: apply stuck detection logic (same as task failure). Do NOT commit unverified work.
3. If `/verify-task` passes:
   - Update checkboxes in EXECUTION_PLAN.md: `- [ ]` → `- [x]`
   - Commit (see Git Workflow in main SKILL.md):
     ```bash
     git add -A
     git commit -m "task({task_id}): {description} [REQ-XXX]"
     ```
4. Clean up temp file (always, regardless of success/failure):
   ```bash
   rm -f $TASK_SPEC
   ```

## What /codex-implement Provides (vs raw codex exec)

| Capability | Raw codex exec | Via /codex-implement |
|-----------|---------------|---------------------|
| Context scoping | Full repo dump | Implementation Brief with only relevant files |
| Task decomposition | None (single prompt) | Auto-splits if >3 files or >80 LOC |
| Safety guards | None | HEAD recording, stash, commit revert |
| Verification | Basic exit code | 4-tier: scope guard → automated → Claude review → cross-model |
| Prompt quality | Generic template | Codebase-aware with discovered patterns |
| Error handling | Exit code parsing | Structured failure reporting with retry guidance |

## Configuration

`/codex-implement` reads its own configuration from `.claude/settings.local.json`:

```json
{
  "codexImplement": {
    "enabled": true,
    "model": "gpt-5.3-codex",
    "effort": "xhigh",
    "timeoutMinutes": 60,
    "maxTasks": 5
  }
}
```

Phase-start does not need to duplicate this configuration. The fallback chain
(`codexImplement` → `codexReview` → defaults) is handled by `/codex-implement`.
