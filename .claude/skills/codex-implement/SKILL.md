---
name: codex-implement
description: Delegate code implementation to Codex CLI. Claude decomposes, scopes context, and verifies; Codex implements. Accepts a spec file, text description, or gathers requirements interactively.
argument-hint: "[SPEC_FILE | \"description\"] [--consult] [--no-commit] [--dry-run] [--model MODEL]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
---

# Codex Implement

Delegate bounded implementation tasks to OpenAI Codex CLI. Claude acts as
Architect (decomposes, selects context, verifies); Codex acts as Editor
(implements each bounded task).

## When to Use

- Ad-hoc implementation: "have Codex build this"
- Cross-model implementation for blind-spot coverage
- When you want Claude to orchestrate and verify, not write the code itself

## Arguments

- **Positional**: Spec file path OR quoted text description (optional)
- `--consult` — Run `/codex-consult` on the implementation plan before executing
- `--no-commit` — Skip commits after each task (leave changes unstaged)
- `--dry-run` — Show Implementation Brief + task decomposition without executing
- `--model MODEL` — Override Codex model for this invocation

## Workflow

Copy this checklist and track progress:

```
Implementation Progress:
- [ ] Phase 1: Pre-flight checks
- [ ] Phase 2: Gather input
- [ ] Phase 3: Analyze and decompose
- [ ] Phase 4: Optional consultation (if --consult)
- [ ] Phase 5: Execute tasks
- [ ] Phase 6: Summary
```

## Phase 1: Pre-flight

### Guard Checks

```bash
# Already inside Codex?
if [ -n "$CODEX_SANDBOX" ]; then
  echo "Already running inside Codex. Skipping."
  exit 0
fi

# Codex CLI installed?
codex --version

# Authenticated?
codex login status
```

If Codex CLI is not available or not authenticated, report the error and STOP:
```
ERROR: Codex CLI required
==========================
Install: npm install -g @openai/codex
Auth:    codex login
```

### Load Configuration

Read `.claude/settings.local.json`:

```bash
CODEX_MODEL=$(jq -r '.codexImplement.model // .codexReview.codeModel // empty' .claude/settings.local.json 2>/dev/null)
CODEX_EFFORT=$(jq -r '.codexImplement.effort // .codexReview.effort // empty' .claude/settings.local.json 2>/dev/null)
TIMEOUT_MINS=$(jq -r '.codexImplement.timeoutMinutes // .codexReview.taskTimeoutMinutes // 60' .claude/settings.local.json 2>/dev/null || echo "60")
MAX_TASKS=$(jq -r '.codexImplement.maxTasks // 5' .claude/settings.local.json 2>/dev/null || echo "5")
ENABLED=$(jq -r '.codexImplement.enabled // true' .claude/settings.local.json 2>/dev/null || echo "true")
```

If `--model` flag provided, override `CODEX_MODEL`.
If `enabled` is `false`, report and STOP.

### Parse Flags

Extract from argument string:
- `--consult` → `CONSULT=true`
- `--no-commit` → `NO_COMMIT=true`
- `--dry-run` → `DRY_RUN=true`
- `--model VALUE` → override `CODEX_MODEL`
- Remaining text → `INPUT` (file path or description)

## Phase 2: Gather Input

Determine input mode from `INPUT`:

### Mode A: Spec File

If `INPUT` is a file path that exists:

1. Read the file
2. Extract: problem statement, requirements, acceptance criteria, scope boundaries
3. Present summary to user via AskUserQuestion: "This is what I'll have Codex implement. Correct?"
4. If user modifies, incorporate changes

### Mode B: Inline Text

If `INPUT` is quoted text (not a file path):

1. Claude explores the codebase to understand the affected area:
   - Glob for relevant files
   - Read key files to understand patterns
   - Identify what exists vs. what needs to be built
2. Generate an **Implementation Brief** (internal, not written to disk):
   - What to build (from user's description)
   - Affected files (from codebase exploration)
   - Success criteria (Claude generates testable criteria)
   - Constraints (from AGENTS.md and codebase conventions)
3. Present brief to user via AskUserQuestion for confirmation

### Mode C: Interactive

If no `INPUT` provided:

1. Ask one question at a time via AskUserQuestion (conversational, discover-style)
2. Follow threads: if an answer raises something interesting, explore it
3. Smart-skip: don't ask what's already clear from context
4. Typical questions:
   - "What would you like Codex to build?"
   - "Where in the codebase should this live?" (after exploring to suggest options)
   - "Any constraints or patterns it should follow?"
   - "How should we verify it works?"
5. Escape hatch: if user says "just do it", ask one final critical question then proceed
6. Move on when sufficient clarity achieved (typically 3-5 questions)
7. Build Implementation Brief from answers (same structure as Mode B)

### Implementation Brief Structure

All modes produce this internal structure:

```
IMPLEMENTATION BRIEF
====================
Description: {what to build}
Affected files: {list of files Codex should read/modify}
Success criteria:
  1. {testable criterion}
  2. {testable criterion}
Constraints:
  - {from AGENTS.md}
  - {from codebase conventions}
```

## Phase 3: Analyze and Decompose

See [DECOMPOSITION.md](DECOMPOSITION.md) for the full decision tree.

Claude reads the Implementation Brief and decides single vs. multi-task:

**Single task** if ALL of:
- Touches ≤ 3 files
- Single concern (one logical change)
- Estimated ≤ ~80 lines of change
- No cross-cutting concerns

**Multiple tasks** if ANY of:
- Touches > 3 files
- Multiple concerns
- Cross-cutting layers (API + frontend + database)
- Estimated > 80 lines

### Decomposition Rules

- Each task: single bounded concern
- Order by dependency (foundational first)
- Cap at `MAX_TASKS` (default 5)
- If exceeds cap: warn and suggest full `/feature-spec` → `/feature-plan` workflow,
  but allow override if user confirms

### User Confirmation

Present the task list to the user:

```
IMPLEMENTATION PLAN
===================
Tasks: {N}

1. {task description} — touches {files}
2. {task description} — touches {files}
...

Estimated Codex time: ~{N * timeout/4} minutes (worst case: {N * timeout} minutes)
```

Ask: "Ready to execute?" with options:
- "Execute (Recommended)"
- "Modify tasks"
- "Cancel"

### Dry Run Exit

If `--dry-run`: display the Implementation Brief and task list, then STOP.

## Phase 4: Optional Consultation

If `--consult` flag is set:

1. Write Implementation Brief to temp file
2. Invoke `/codex-consult` on the temp file
3. Present Codex's findings to user
4. Ask: "Incorporate suggestions?" → refine brief if yes
5. Clean up temp file
6. Proceed to Phase 5

## Phase 5: Execute Tasks

### Safety Guard Pattern

Apply this pattern before and after every Codex invocation to prevent
accidental commits from persisting:

```bash
# Before invocation — fail fast on dirty worktree, record HEAD
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: Worktree has uncommitted changes. Commit or stash before running Codex."
fi
HEAD_BEFORE=$(git rev-parse HEAD)

# ... invoke Codex ...

# After invocation — revert any commits Codex made
HEAD_AFTER=$(git rev-parse HEAD)
if [ "$HEAD_BEFORE" != "$HEAD_AFTER" ]; then
  echo "WARNING: Codex made commits. Reverting."
  git reset --soft "$HEAD_BEFORE"
  git restore --staged .
fi
```

For each task (sequentially):

### Step 1: Capture Safety State

Apply the safety guard pattern (pre-invocation half) defined above.

### Step 2: Build Task Prompt

See [PROMPT_TEMPLATE.md](PROMPT_TEMPLATE.md) for the full template.

Write prompt to temp file. Include:
- AGENTS.md context
- ONLY files relevant to this specific task (not all affected files)
- Success criteria for THIS task only
- Constraints: follow patterns, don't commit, stay in scope

### Step 3: Invoke Codex

```bash
# Build model flag
MODEL_FLAG=""
if [ -n "$CODEX_MODEL" ]; then
  MODEL_FLAG="--model $CODEX_MODEL"
fi

# Build effort flag
EFFORT_ARGS=()
if [ -n "$CODEX_EFFORT" ]; then
  EFFORT_ARGS=(-c "model_reasoning_effort=\"$CODEX_EFFORT\"")
fi

PROMPT_FILE="/tmp/codex-impl-task-${TASK_NUM}.md"
OUTPUT_FILE="/tmp/codex-impl-task-${TASK_NUM}-output.txt"

cat $PROMPT_FILE | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy="never"' \
  -c 'features.search=true' \
  $MODEL_FLAG \
  "${EFFORT_ARGS[@]}" \
  -o $OUTPUT_FILE \
  -
EXIT_CODE=$?
```

Use Bash tool `timeout` parameter: `TIMEOUT_MINS * 60 * 1000` milliseconds.

**MANDATORY rules:**
- NEVER use `run_in_background`
- NEVER retry with modified syntax
- NEVER use `2>&1` (corrupts output parsing)
- Use Bash tool timeout, not shell `timeout`

### Step 4: Safety Check

Apply the safety guard pattern (post-invocation half) defined above.

### Step 5: Parse Result

```bash
if [ $EXIT_CODE -eq 124 ]; then
  STATUS="FAILED"; ISSUE="Timeout after ${TIMEOUT_MINS} minutes"
elif [ $EXIT_CODE -ne 0 ]; then
  STATUS="FAILED"; ISSUE="Codex exited with code $EXIT_CODE"
elif [ ! -f "$OUTPUT_FILE" ]; then
  STATUS="FAILED"; ISSUE="No output file produced"
else
  STATUS=$(grep "^Status:" "$OUTPUT_FILE" | head -1 | awk '{print $2}')
  if [ -z "$STATUS" ]; then
    STATUS=$(grep "Status:" "$OUTPUT_FILE" | head -1 | awk '{print $2}')
  fi
  if [ -z "$STATUS" ]; then
    STATUS="FAILED"; ISSUE="Could not parse task result"
  fi
fi
```

### Step 6: Verify

See [VERIFICATION.md](VERIFICATION.md) for the full verification strategy.

4-tier verification:
1. **Scope guard**: `git diff --name-only` — did Codex only touch expected files?
2. **Automated checks**: Run tests/lint/typecheck if configured
3. **Claude review**: Read `git diff`, compare against success criteria
4. **Cross-model review** (only with `--consult`): Run `/codex-review` on the changes

### Step 7: Commit or Rollback

**On success** (unless `--no-commit`):
- Stage changed files: `git add {specific files}`
- Commit: `impl: {task description} [codex-implement]`

**On failure**:
- Show what went wrong (Codex output + verification results)
- Ask user via AskUserQuestion:
  - "Retry this task"
  - "Skip and continue"
  - "Abort remaining tasks"
  - "I'll implement this one manually"
- After 2 consecutive failures on same task: recommend manual implementation

### Step 8: Clean Up

```bash
rm -f $PROMPT_FILE $OUTPUT_FILE
```

## Phase 6: Summary

```
IMPLEMENTATION COMPLETE
=======================
Tasks: {completed}/{total}
Files created: {count}
Files modified: {count}
Commits: {count}

Changes:
  {commit message 1}
  {commit message 2}
  ...

Next steps:
  - Run full test suite: {test command}
  - Review changes: git diff HEAD~{N}
```

If any tasks failed or were skipped, include them in the summary with recommendations.

## Error Handling

| Situation | Action |
|-----------|--------|
| Codex CLI not installed | Report, suggest install command, STOP |
| Codex not authenticated | Report, suggest `codex login`, STOP |
| Codex times out | Show partial output if available, ask user |
| Output unparseable | Show raw output, ask user to review |
| Scope violation | Warn, ask user to accept or revert |
| 2 consecutive failures | Recommend manual implementation |
| Exceeds maxTasks | Warn, suggest full workflow, allow override |
| `--dry-run` | Show brief + tasks, STOP before execution |

## Configuration

Add to `.claude/settings.local.json`:

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

Fallback chain: `codexImplement` → `codexReview` → defaults.

## REMINDER: Codex Invocation Rules

These rules are mandatory for every `codex exec` invocation:

- **NEVER** use `run_in_background` — always execute synchronously
- **NEVER** retry with modified syntax — report exit code and skip
- **NEVER** use `2>&1` — corrupts output parsing (Codex streams progress to stderr)
- **Use Bash tool `timeout` parameter** — not shell `timeout` command
- **Always capture HEAD before and after** — revert accidental commits
