---
name: generate-plan
description: Generate EXECUTION_PLAN.md and AGENTS.md. Use after /technical-spec to create the phased task breakdown.
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob, Bash
---

Generate the execution plan and agent guidelines for the current project.

## Workflow

Copy this checklist and track progress:

```
Generate Plan Progress:
- [ ] Step 1: Directory guard
- [ ] Step 2: Check prerequisites (PRODUCT_SPEC.md + TECHNICAL_SPEC.md)
- [ ] Step 3: Check for toolkit setup
- [ ] Step 4: Check for existing EXECUTION_PLAN.md
- [ ] Step 5: Process specs into task breakdown
- [ ] Step 6: Create CLAUDE.md (if missing)
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
Will write EXECUTION_PLAN.md and AGENTS.md to: {absolute path of cwd}/
Continue? (Yes / Change directory)
```

If the user says "Change directory", ask for the correct path and instruct them to `cd` there first.

## Prerequisites

- Check that `PRODUCT_SPEC.md` exists in the current directory. If not:
  "PRODUCT_SPEC.md not found. Run `/product-spec` first."
- Check that `TECHNICAL_SPEC.md` exists in the current directory. If not:
  "TECHNICAL_SPEC.md not found. Run `/technical-spec` first."

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

Before generating anything, check whether either output file already exists:
- `EXECUTION_PLAN.md`
- `AGENTS.md`

- If neither exists: continue normally.
- If one or both exist: **STOP** and ask the user what to do for the existing file(s):
  1. **Backup then overwrite (recommended)**: for each existing file, read it and write it to `{path}.bak.YYYYMMDD-HHMMSS`, then write the new document(s) to the original path(s)
  2. **Overwrite**: replace the existing file(s) with the new document(s)
  3. **Abort**: do not write anything; suggest they rename/move the existing file(s) first

## Process

Read `.claude/skills/generate-plan/PROMPT.md` and follow its instructions exactly:

1. Read `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md` as inputs
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate AGENTS.md with workflow guidelines

## Output

Write both documents to the current directory:
- `EXECUTION_PLAN.md`
- `AGENTS.md`

## Create CLAUDE.md

If `CLAUDE.md` does not exist in the current directory, create it with:

```
@AGENTS.md
```

If it already exists, do not overwrite it.

## Verification (Automatic)

After writing EXECUTION_PLAN.md and AGENTS.md:

### 1. AGENTS.md Size Check

Count the lines in the generated AGENTS.md:

**Thresholds:**
- **≤150 lines**: PASS — Optimal for LLM instruction-following
- **151-200 lines**: WARN — "AGENTS.md is {N} lines. Research shows LLMs follow ~150 instructions consistently. Consider splitting project-specific rules into subdirectory CLAUDE.md files."
- **>200 lines**: FAIL — "AGENTS.md exceeds 200 lines ({N} lines). This will degrade agent performance. Split into:
  - AGENTS.md (core workflow, ≤100 lines)
  - `.claude/CLAUDE.md` files in subdirectories for context-specific rules"

If WARN or FAIL, offer to help split the file before proceeding.

### 2. Spec Verification

Run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from TECHNICAL_SPEC.md and PRODUCT_SPEC.md appear as tasks or acceptance criteria
3. Run quality checks for untestable criteria, missing dependencies, vague language
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

### 3. Criteria Audit

Run `/criteria-audit` to validate verification metadata in EXECUTION_PLAN.md.

- If FAIL: stop and ask the user to resolve missing metadata before proceeding.
- If WARN: report and continue.

## Cross-Model Review (Automatic)

After verification passes, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` with upstream context
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --upstream TECHNICAL_SPEC.md --research "execution planning, task breakdown" EXECUTION_PLAN.md
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
| PRODUCT_SPEC.md or TECHNICAL_SPEC.md not found | Stop and report which file is missing with instructions to generate it |
| PROMPT.md not found at `.claude/skills/generate-plan/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| AGENTS_TEMPLATE.md not found at `.claude/skills/generate-plan/AGENTS_TEMPLATE.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| Contradictions between specs | Stop and list contradictions. Ask user to resolve before continuing |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

When verification is complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS.md created and verified.

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED

Your project is ready for execution:
1. /fresh-start
2. /configure-verification
3. /phase-prep 1
4. /phase-start 1
```
