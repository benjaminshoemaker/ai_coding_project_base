---
description: Generate TECHNICAL_SPEC.md through guided Q&A. Use after /product-spec to define the technical architecture.
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob
---

Generate a technical specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/PRODUCT_SPEC.md` exists. If not:
  "PRODUCT_SPEC.md not found at $1. Run /product-spec $1 first."

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `TECHNICAL_SPEC_PROMPT.md` from the current working directory.

- If `TECHNICAL_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/technical-spec $1`

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `$1/TECHNICAL_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `$1/TECHNICAL_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `$1/TECHNICAL_SPEC.md`
  2. **Overwrite**: replace `$1/TECHNICAL_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Process

Copy this checklist and track progress:

```
Technical Spec Progress:
- [ ] Step 1: Verify correct directory
- [ ] Step 2: Check for existing TECHNICAL_SPEC.md
- [ ] Step 3: Conduct guided Q&A with user
- [ ] Step 4: Cross-verify against PRODUCT_SPEC.md
- [ ] Step 5: Handle deferred decisions
- [ ] Step 6: Review and refine with user
- [ ] Step 7: Suggest next step (/generate-plan)
```

Read TECHNICAL_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/PRODUCT_SPEC.md` as input
2. Work through each question category (Architecture, Stack, Data, APIs, Implementation)
3. Make recommendations with confidence levels
4. Generate the final TECHNICAL_SPEC.md document

## Output

Write the completed specification to `$1/TECHNICAL_SPEC.md`.

## Verification (Automatic)

After writing TECHNICAL_SPEC.md, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from PRODUCT_SPEC.md appear in TECHNICAL_SPEC.md
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

After collecting answers, append to `$1/DEFERRED.md` right away.

**If this is the first technical spec entry, add a new section:**

```markdown

## From TECHNICAL_SPEC.md ({date})

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
/codex-consult --upstream $1/PRODUCT_SPEC.md --research "{detected technologies}" $1/TECHNICAL_SPEC.md
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
TECHNICAL_SPEC.md created and verified at $1/TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED
Deferred Requirements: {count} items captured to DEFERRED.md

Next: Run /generate-plan $1
```
