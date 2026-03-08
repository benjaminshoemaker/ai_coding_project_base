---
name: generate-plan
description: Generate the greenfield execution plan plus root and scoped AGENTS.md files. Use after /technical-spec to create the phased task breakdown.
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob, Bash
---

Generate the execution plan and agent guidelines for the current project.

## Workflow

Copy this checklist and track progress:

```
Generate Plan Progress:
- [ ] Step 1: Directory guard
- [ ] Step 2: Check prerequisites (plans/greenfield specs)
- [ ] Step 3: Check for toolkit setup
- [ ] Step 4: Check for existing output files
- [ ] Step 5: Process specs into task breakdown
- [ ] Step 6: Create root and scoped CLAUDE.md files (if missing)
- [ ] Step 7: Verify plan completeness
- [ ] Step 8: Review and refine with user
- [ ] Step 9: Suggest next step (/fresh-start)
```

## Directory Guard

1. If `.toolkit-marker` exists in the current working directory → **STOP**:
   "You're in the toolkit repo. Run this from your project directory instead:
    `cd ~/Projects/your-project && /generate-plan`"

## Project Root Confirmation

Before generating any files, confirm the output location with the user:

```
Will write:
- `AGENTS.md` to: {absolute path of cwd}/
- planning docs to: {absolute path of cwd}/plans/greenfield/
Continue? (Yes / Change directory)
```

If the user says "Change directory", ask for the correct path and instruct them to `cd` there first.

## Prerequisites

- Check for `plans/greenfield/PRODUCT_SPEC.md` first.
- If it does not exist, fall back to legacy `PRODUCT_SPEC.md` in the current directory.
- Check for `plans/greenfield/TECHNICAL_SPEC.md` first.
- If it does not exist, fall back to legacy `TECHNICAL_SPEC.md` in the current directory.
- If either legacy root file is used, copy it into `plans/greenfield/` before proceeding so the project adopts the canonical layout.
- If either spec is missing from both locations:
  "Greenfield specs not found. Run `/product-spec` and `/technical-spec` first."

## Setup Check

Check if `.claude/toolkit-version.json` exists in the current directory:

- If it exists: good — toolkit is initialized, execution skills are available.
- If it does NOT exist: warn the user:
  ```
  Toolkit not initialized in this project. Execution skills (/fresh-start,
  /phase-start, etc.) won't be available after plan generation.

  Recommended: Run /setup from the toolkit first to install execution skills.
  Continue with plan generation anyway? (Yes / Run /setup first)
  ```
  If user says "Run /setup first", stop and instruct them to run `/setup` from the toolkit directory.
  If user says "Yes", continue — spec generation will work, but they'll need `/setup` before execution.

## Existing File Guard (Prevent Overwrite)

Before generating anything, ensure `plans/greenfield/` exists, then check whether any output files already exist:
- `AGENTS.md`
- `plans/greenfield/EXECUTION_PLAN.md`
- `plans/greenfield/AGENTS.md`

- If none exist: continue normally.
- If one or more exist: **STOP** and ask the user what to do for the existing file(s):
  1. **Backup then overwrite (recommended)**: for each existing file, read it and write it to `{path}.bak.YYYYMMDD-HHMMSS`, then write the new document(s) to the original path(s)
  2. **Overwrite**: replace the existing file(s) with the new document(s)
  3. **Abort**: do not write anything; suggest they rename/move the existing file(s) first

## Process

Read `.claude/skills/generate-plan/PROMPT.md` and follow its instructions exactly:

1. Read greenfield specs from `plans/greenfield/`
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate root `AGENTS.md` with durable project-wide workflow guidelines
4. Generate `plans/greenfield/AGENTS.md` with greenfield execution-specific guidance

## Output

Write these files:
- `AGENTS.md`
- `plans/greenfield/EXECUTION_PLAN.md`
- `plans/greenfield/AGENTS.md`

## Create CLAUDE.md Files

If `CLAUDE.md` does not exist in the current directory, create it with:

```
@AGENTS.md
```

If it already exists, do not overwrite it.

If `plans/greenfield/CLAUDE.md` does not exist, create it with:

```
@AGENTS.md
```

If it already exists, do not overwrite it.

## Verification (Automatic)

After writing the root and scoped files:

### 1. AGENTS.md Size Check

Count the lines in the generated root `AGENTS.md`:

**Thresholds:**
- **≤100 lines**: PASS — Optimal for root `AGENTS.md`
- **101-150 lines**: WARN — "Root AGENTS.md is {N} lines. Keep durable project rules compact and push execution-specific detail into scoped plan directories."
- **>150 lines**: FAIL — "Root AGENTS.md exceeds 150 lines ({N} lines). Split durable rules from scoped execution guidance before proceeding."

If WARN or FAIL, offer to help split the file before proceeding.

### 2. Spec Verification

Run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from `TECHNICAL_SPEC.md` and `PRODUCT_SPEC.md` appear as tasks or acceptance criteria
3. Run quality checks for untestable criteria, missing dependencies, vague language
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

### 3. Criteria Audit

Run `/criteria-audit plans/greenfield` to validate verification metadata in `plans/greenfield/EXECUTION_PLAN.md`.

- If FAIL: stop and ask the user to resolve missing metadata before proceeding.
- If WARN: report and continue.

## Cross-Model Review (Automatic)

After verification passes, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` with upstream context
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --upstream plans/greenfield/TECHNICAL_SPEC.md --research "execution planning, task breakdown" plans/greenfield/EXECUTION_PLAN.md
```

**If Codex finds issues:**
- Show critical issues and recommendations
- Ask user: "Address findings before proceeding?" (Yes/No)
- If Yes: Apply suggested fixes
- If No: Continue with noted issues

**If Codex unavailable:** Skip silently and proceed to Next Step.

## Error Handling

| Situation | Action |
|-----------|--------|
| PRODUCT_SPEC.md or TECHNICAL_SPEC.md not found in `plans/greenfield/` or project root | Stop and report which file is missing with instructions to generate it |
| PROMPT.md not found at `.claude/skills/generate-plan/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| AGENTS_TEMPLATE.md not found at `.claude/skills/generate-plan/AGENTS_TEMPLATE.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| PLAN_AGENTS_TEMPLATE.md not found at `.claude/skills/generate-plan/PLAN_AGENTS_TEMPLATE.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| Contradictions between specs | Stop and list contradictions. Ask user to resolve before continuing |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

When verification is complete, inform the user:
```
Root AGENTS.md plus greenfield plan files created and verified.

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED

Your project is ready for execution:
1. cd plans/greenfield
2. /fresh-start
3. /configure-verification
4. /phase-prep 1
5. /phase-start 1
```
