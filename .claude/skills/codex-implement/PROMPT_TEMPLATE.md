# Codex Implementation Task Prompt Template

This template is used by the `/codex-implement` skill to construct the prompt
piped to `codex exec` for each bounded task.

## Template

```markdown
# Implementation Task

## Project Context

Read these files to understand conventions and patterns:
- {AGENTS_PATH} (workflow conventions and coding standards)
{for each relevant_file}
- {file_path} — {reason this file is relevant to the task}
{/for}

## Task

{task_description}

## Success Criteria

{for each criterion}
{N}. {testable criterion}
{/for}

## Instructions

1. **Explore first**: Search the codebase for similar patterns, existing utilities,
   and conventions before writing any new code. Reuse what exists.
2. **Follow conventions**: Match the project's naming, file structure, error handling,
   and coding style exactly. Read nearby files for reference.
3. **Minimal changes**: Implement the minimum code needed to satisfy the success
   criteria. Do not refactor surrounding code, add comments to unchanged code,
   or introduce unnecessary abstractions.
4. **Write tests**: If the project has a test suite, add tests for new functionality.
   One test per success criterion where applicable.
5. **Verify**: Run existing tests to ensure nothing breaks. Run linting if configured.

## Constraints

- Do NOT commit (the orchestrator handles commits)
- Do NOT modify files outside the scope of this task
- Do NOT add unnecessary dependencies
- Do NOT add docstrings, comments, or type annotations to code you did not change
- Follow patterns in AGENTS.md
- Stay within scope: if you discover something that needs fixing but is unrelated,
  note it in the report but do not fix it

## Report

End your response with this exact format:

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

Notes:
- {any observations, out-of-scope issues noticed, or suggestions}

{If FAILED or BLOCKED}
Issue: {description of what went wrong}
Suggestion: {what the orchestrator could do to unblock}
{/If}
```

## Variable Substitution

| Variable | Source | Required |
|----------|--------|----------|
| `{AGENTS_PATH}` | Project root `AGENTS.md` or `CLAUDE.md` | Yes (skip if neither exists) |
| `{file_path}` | From Implementation Brief `affected_files` | Yes |
| `{reason}` | Claude's assessment of why the file matters for this task | Yes |
| `{task_description}` | From Implementation Brief or decomposed task | Yes |
| `{criterion}` | From Implementation Brief `success_criteria` | Yes |
| `{task_id}` | Sequential: `1`, `2`, `3`... or descriptive: `rate-limiter`, `tests` | Yes |

## Context Scoping Rules

Per research findings, feeding only relevant context per task improves quality:

1. **Always include**: AGENTS.md (conventions), files being modified
2. **Include if relevant**: Files imported by modified files, test files for modified code
3. **Do NOT include**: The full spec file, unrelated source files, the entire project tree
4. **Cap context files**: Maximum 8-10 files per task prompt. If more are needed,
   the task should be decomposed further.

## Notes

- The prompt is written to a temp file and piped via stdin: `cat $FILE | codex exec ... -`
- Output is captured via `-o $OUTPUT_FILE` flag
- The TASK EXECUTION RESULT block is parsed by Claude after execution
- Status values: `COMPLETE` (proceed), `FAILED` (retry/skip), `BLOCKED` (needs human input)
