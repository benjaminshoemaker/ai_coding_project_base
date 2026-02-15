---
description: Generate EXECUTION_PLAN.md and AGENTS.md. Use after /technical-spec to create the phased task breakdown.
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob, Bash
---

Generate the execution plan and agent guidelines for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/PRODUCT_SPEC.md` exists. If not:
  "PRODUCT_SPEC.md not found at $1. Run /product-spec $1 first."
- Check that `$1/TECHNICAL_SPEC.md` exists. If not:
  "TECHNICAL_SPEC.md not found at $1. Run /technical-spec $1 first."

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `GENERATOR_PROMPT.md` from the current working directory.

- If `GENERATOR_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/generate-plan $1`

## Existing File Guard (Prevent Overwrite)

Before generating anything, check whether either output file already exists:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS.md`

- If neither exists: continue normally.
- If one or both exist: **STOP** and ask the user what to do for the existing file(s):
  1. **Backup then overwrite (recommended)**: for each existing file, read it and write it to `{path}.bak.YYYYMMDD-HHMMSS`, then write the new document(s) to the original path(s)
  2. **Overwrite**: replace the existing file(s) with the new document(s)
  3. **Abort**: do not write anything; suggest they rename/move the existing file(s) first

## Process

Copy this checklist and track progress:

```
Generate Plan Progress:
- [ ] Step 1: Verify correct directory
- [ ] Step 2: Check for existing EXECUTION_PLAN.md
- [ ] Step 3: Process specs into task breakdown
- [ ] Step 4: Set up environment (AGENTS.md, phase state)
- [ ] Step 5: Verify plan completeness
- [ ] Step 6: Review and refine with user
- [ ] Step 7: Suggest next step (/phase-prep)
```

Read GENERATOR_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/PRODUCT_SPEC.md` and `$1/TECHNICAL_SPEC.md` as inputs
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate AGENTS.md with workflow guidelines

## Output

Write both documents to the target directory:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS.md`

## Setup Execution Environment

After writing the documents, copy the execution skills to the target project so `/fresh-start`, `/phase-start`, etc. work when the user switches to that directory.

### 1. Copy Skills

Copy the skills directory (includes all execution skills like fresh-start, phase-start, etc.):

```bash
cp -r .claude/skills "$1/.claude/"
```

### 2. Add Verification Config

If `$1/.claude/verification-config.json` does not exist, copy the template:
```bash
cp .claude/verification-config.json "$1/.claude/verification-config.json"
```

If it already exists, do not overwrite it.

### 3. Create toolkit-version.json

Create `$1/.claude/toolkit-version.json` to enable future syncs with `/sync`:

```json
{
  "schema_version": "1.0",
  "toolkit_location": "{absolute path to this toolkit}",
  "toolkit_commit": "{current git HEAD commit hash}",
  "toolkit_commit_date": "{commit date in ISO format}",
  "last_sync": "{current ISO timestamp}",
  "files": {
    ".claude/skills/fresh-start/SKILL.md": {
      "hash": "{sha256 hash of copied file}",
      "synced_at": "{ISO timestamp}"
    }
  }
}
```

Get toolkit info:
```bash
TOOLKIT_PATH=$(pwd)
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_DATE=$(git log -1 --format=%cI HEAD)
```

Calculate file hashes for each copied file:
```bash
shasum -a 256 "$file" | cut -d' ' -f1
```

**Include entries for ALL files in skill directories:**
```bash
# Hash every .md file in every skill directory
for skill_dir in .claude/skills/*/; do
  for file in "$skill_dir"*.md; do
    [[ -f "$file" ]] || continue
    hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    # Add entry for "$file" with hash and timestamp
  done
done
```

This ensures skills with supporting files (e.g., `audit-skills/CRITERIA.md`) are tracked.

If the file already exists, **update it** with current hashes and commit info (this handles re-running generate-plan on an existing project).

### 4. Create CLAUDE.md

If `$1/CLAUDE.md` does not exist, create it with:

```
@AGENTS.md
```

If it already exists, do not overwrite it.

## Verification (Automatic)

After writing EXECUTION_PLAN.md and AGENTS.md:

### 1. AGENTS.md Size Check

Count the lines in the generated AGENTS.md:
```bash
wc -l $1/AGENTS.md
```

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

Run `/criteria-audit $1` to validate verification metadata in EXECUTION_PLAN.md.

- If FAIL: stop and ask the user to resolve missing metadata before proceeding.
- If WARN: report and continue.

## Cross-Model Review (Automatic)

After verification passes, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` with upstream context
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --upstream $1/TECHNICAL_SPEC.md --research "execution planning, task breakdown" $1/EXECUTION_PLAN.md
```

**If Codex finds issues:**
- Show critical issues and recommendations
- Ask user: "Address findings before proceeding?" (Yes/No)
- If Yes: Apply suggested fixes
- If No: Continue with noted issues

**If Codex unavailable:** Skip silently and proceed to Next Step.

## Next Step

When verification is complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS.md created and verified at $1

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED

Your project is ready for execution:
1. cd $1
2. /fresh-start
3. /configure-verification
4. /phase-prep 1
5. /phase-start 1
```
