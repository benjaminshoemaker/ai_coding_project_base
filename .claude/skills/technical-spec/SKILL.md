---
name: technical-spec
description: Generate TECHNICAL_SPEC.md through guided Q&A. Use after /product-spec to define the technical architecture.
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob, Bash
---

Generate a technical specification document for the current project.

## Workflow

Copy this checklist and track progress:

```
Technical Spec Progress:
- [ ] Step 1: Directory guard
- [ ] Step 2: Project root confirmation
- [ ] Step 3: Check prerequisites (plans/greenfield/PRODUCT_SPEC.md)
- [ ] Step 4: Check for existing plans/greenfield/TECHNICAL_SPEC.md
- [ ] Step 5: Conduct guided Q&A with user
- [ ] Step 6: Cross-verify against PRODUCT_SPEC.md
- [ ] Step 7: Handle deferred decisions
- [ ] Step 8: Review and refine with user
- [ ] Step 9: Suggest next step (/generate-plan)
```

## Directory Guard

1. If `.toolkit-marker` exists in the current working directory → **STOP**:
   "You're in the toolkit repo. Run this from your project directory instead:
    `cd ~/Projects/your-project && /technical-spec`"

## Project Root Confirmation

Before generating any files, confirm the output location with the user:

```
Will write TECHNICAL_SPEC.md to: {absolute path of cwd}/plans/greenfield/
Continue? (Yes / Change directory)
```

If the user says "Change directory", ask for the correct path and instruct them to `cd` there first.

## Prerequisites

- Check for `plans/greenfield/PRODUCT_SPEC.md` first.
- If it does not exist, fall back to legacy `PRODUCT_SPEC.md` in the current directory.
- If the legacy root file is used, copy it to `plans/greenfield/PRODUCT_SPEC.md` before continuing so the project adopts the canonical layout.
- If neither exists:
  "PRODUCT_SPEC.md not found. Run `/product-spec` first."

## Existing File Guard (Prevent Overwrite)

Before asking any questions, ensure `plans/greenfield/` exists, then check whether
`plans/greenfield/TECHNICAL_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `plans/greenfield/TECHNICAL_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `plans/greenfield/TECHNICAL_SPEC.md`
  2. **Overwrite**: replace `plans/greenfield/TECHNICAL_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Process

Read `.claude/skills/technical-spec/PROMPT.md` and follow its instructions exactly:

1. Read `plans/greenfield/PRODUCT_SPEC.md` as input
2. Work through each question category (Architecture, Stack, Data, APIs, Implementation)
3. Make recommendations with confidence levels
4. Generate the final TECHNICAL_SPEC.md document

## Output

Write the completed specification to `plans/greenfield/TECHNICAL_SPEC.md`.

## Verification (Automatic)

After writing `plans/greenfield/TECHNICAL_SPEC.md`, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from `PRODUCT_SPEC.md` appear in `TECHNICAL_SPEC.md`
3. Run quality checks for vague language, missing rationale, undefined contracts
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Deferred Requirements Capture (During Q&A)

**IMPORTANT:** Capture deferred requirements interactively during the Q&A process, not after.

### When to Trigger

During the Q&A, watch for signals that the user is deferring a technical decision:
- "out of scope"
- "not for MVP" / "post-MVP"
- "v2" / "future version"
- "premature optimization"
- "over-engineering" / "overkill"
- "later" / "eventually"
- "we'll skip that for now"
- "keep it simple for now"

### Capture Flow

When you detect a deferral signal, immediately use AskUserQuestion:

```
Question: "Would you like to save this to your deferred requirements?"
Header: "Defer?"
Options:
  - "Yes, capture it" — I'll ask a few quick questions to document it
  - "No, skip" — Don't record this
```

**If user selects "Yes, capture it":**

Ask these clarifying questions:

1. **What's being deferred?**
   "In one sentence, what's the technical decision or feature?"
   (Pre-fill with your understanding from context)

2. **Why defer it?**
   Options: "Premature optimization" / "Over-engineering for MVP" / "Needs more research" / "V2 feature" / "Other"

3. **Notes for later?**
   "Any technical context that will help when revisiting this?"
   (Optional — user can skip)

### Write to DEFERRED.md Immediately

After collecting answers, append to `DEFERRED.md` right away.

**If this is the first technical spec entry, add a new section:**

```markdown

## From plans/greenfield/TECHNICAL_SPEC.md ({date})

| Requirement | Reason | Notes |
|-------------|--------|-------|
| {user's answer} | {selected reason} | {notes or "—"} |
```

**If section exists, append row:**

```markdown
| {user's answer} | {selected reason} | {notes or "—"} |
```

### Continue Q&A

After capturing (or skipping), continue the spec Q&A where you left off.

## Cross-Model Review (Automatic)

After verification passes, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` with upstream context
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --upstream plans/greenfield/PRODUCT_SPEC.md --research "{detected technologies}" plans/greenfield/TECHNICAL_SPEC.md
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
| PRODUCT_SPEC.md not found in `plans/greenfield/` or project root | Stop and report "Run `/product-spec` first" |
| PROMPT.md not found at `.claude/skills/technical-spec/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| DEFERRED.md write fails (permissions or disk) | Output deferred items to terminal, warn user, continue with spec generation |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

When verification is complete, inform the user:
```
TECHNICAL_SPEC.md created and verified at ./plans/greenfield/TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED
Deferred Requirements: {count} items captured to DEFERRED.md

Next: Run /generate-plan
```
