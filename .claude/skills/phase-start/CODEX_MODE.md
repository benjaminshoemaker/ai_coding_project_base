# Codex Execution Mode

Detailed instructions for executing tasks via OpenAI Codex CLI.

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

### Read Codex Configuration

Read `.claude/settings.local.json` for Codex settings:

```json
{
  "codexReview": {
    "codeModel": "gpt-5.3-codex",
    "taskTimeoutMinutes": 60
  }
}
```

Extract configuration values:

```bash
# Extract model (default: gpt-5.3-codex for code tasks)
CODEX_MODEL=$(jq -r '.codexReview.codeModel // empty' .claude/settings.local.json 2>/dev/null)

# Extract reasoning effort (default: use Codex CLI default)
CODEX_EFFORT=$(jq -r '.codexReview.effort // empty' .claude/settings.local.json 2>/dev/null)

# Extract timeout in minutes (default: 60 = 1 hour)
TIMEOUT_MINS=$(jq -r '.codexReview.taskTimeoutMinutes // 60' .claude/settings.local.json 2>/dev/null || echo "60")
TIMEOUT_SECS=$((TIMEOUT_MINS * 60))
```

Use defaults if not configured: model=Codex default, timeout=60 minutes.

## Task Execution via Codex

### a. Build Task Prompt

Write to a temp file:

```bash
# Create prompt file path
TASK_PROMPT="/tmp/codex-task-${task_id}.md"
TASK_OUTPUT="/tmp/codex-task-${task_id}-output.txt"
```

Write the following content to `$TASK_PROMPT`:

```markdown
# Task Execution Request

## Project Context

Read these files first:
- AGENTS.md (workflow conventions)
- EXECUTION_PLAN.md (full plan context)
- {relevant source files for this task}

## Task to Execute

**Task ID:** {task_id}
**Description:** {task description}

## Acceptance Criteria

{list acceptance criteria from EXECUTION_PLAN.md}

## Instructions

1. **Explore first:** Search for similar existing functionality, identify patterns
2. **Write tests first:** One test per acceptance criterion
3. **Implement:** Minimum code to pass tests, following codebase patterns
4. **Verify:** Run tests, ensure all pass
5. **Report results** in this exact format at the end of your response:

TASK EXECUTION RESULT
=====================
Task: {task_id}
Status: COMPLETE | FAILED | BLOCKED

Files Created:
- {path}

Files Modified:
- {path}

Tests:
- {test status summary}

{If FAILED or BLOCKED}
Issue: {description}
{/If}

## Constraints

- Follow patterns in AGENTS.md
- Use project's existing conventions (naming, structure, error handling)
- Do NOT commit (orchestrator handles commits)
- Do NOT modify EXECUTION_PLAN.md (orchestrator handles checkboxes)
```

### b. Execute via Codex

Build the command with optional model flag:

```bash
# Build model flag if configured
MODEL_FLAG=""
if [ -n "$CODEX_MODEL" ]; then
  MODEL_FLAG="--model $CODEX_MODEL"
fi

# Build effort flag if configured
EFFORT_ARGS=()
if [ -n "$CODEX_EFFORT" ]; then
  EFFORT_ARGS=(-c "model_reasoning_effort=\"$CODEX_EFFORT\"")
fi

# Execute with timeout (default: 1 hour)
timeout ${TIMEOUT_SECS:-3600} bash -c "cat $TASK_PROMPT | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy=\"never\"' \
  -c 'features.search=true' \
  $MODEL_FLAG \
  ${EFFORT_ARGS[@]:+"${EFFORT_ARGS[@]}"} \
  -o $TASK_OUTPUT \
  -"
EXIT_CODE=$?
```

**Flags explained:**
- `--sandbox danger-full-access`: Full file and network access for task execution
- `-c 'approval_policy="never"'`: Non-interactive, no approval prompts
- `-c 'features.search=true'`: Enable web search for documentation research
- `--model`: Optional, uses configured model or Codex default
- `-c 'model_reasoning_effort=...'`: Optional, controls reasoning depth (low/medium/high/xhigh)
- `-o $TASK_OUTPUT`: Write final response to file for parsing
- `-`: Read prompt from stdin
- `timeout`: Hard limit per task (default 1 hour)

### c. Process Results

Handle exit codes and parse output:

```bash
# Check exit status
if [ $EXIT_CODE -eq 124 ]; then
  # Timeout
  STATUS="FAILED"
  ISSUE="Task timed out after ${TIMEOUT_MINS:-60} minutes"
elif [ $EXIT_CODE -ne 0 ]; then
  # Codex error
  STATUS="FAILED"
  ISSUE="Codex exited with code $EXIT_CODE"
elif [ ! -f "$TASK_OUTPUT" ]; then
  # No output file
  STATUS="FAILED"
  ISSUE="Codex produced no output"
else
  # Parse the output file for TASK EXECUTION RESULT block
  # Extract Status line (format: "Status: COMPLETE | FAILED | BLOCKED")
  STATUS=$(grep "^Status:" "$TASK_OUTPUT" | head -1 | awk '{print $2}')
  if [ -z "$STATUS" ]; then
    # Fallback: try without anchor in case of indentation
    STATUS=$(grep "Status:" "$TASK_OUTPUT" | head -1 | awk '{print $2}')
  fi
  if [ -z "$STATUS" ]; then
    STATUS="FAILED"
    ISSUE="Could not parse task result from Codex output"
  fi
fi
```

Based on status:
- If `COMPLETE`: proceed to verification
- If `FAILED` or `BLOCKED`: apply stuck detection logic
- Log the issue and increment failure counter

### d. Verify and Commit

- Run `/verify-task {task_id}` (Claude Code verifies Codex's work)
- Update checkboxes in EXECUTION_PLAN.md
- Commit (see Git Workflow in main SKILL.md)
- Clean up temp files: `rm -f $TASK_PROMPT $TASK_OUTPUT`
