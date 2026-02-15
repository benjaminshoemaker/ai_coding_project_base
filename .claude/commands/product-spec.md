---
description: Generate PRODUCT_SPEC.md through guided Q&A. Use as the first step when starting a new greenfield project.
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a product specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `PRODUCT_SPEC_PROMPT.md` from the current working directory.

- If `PRODUCT_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/product-spec $1`

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `$1/PRODUCT_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `$1/PRODUCT_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `$1/PRODUCT_SPEC.md`
  2. **Overwrite**: replace `$1/PRODUCT_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Process

Copy this checklist and track progress:

```
Product Spec Progress:
- [ ] Step 1: Verify correct directory
- [ ] Step 2: Check for existing PRODUCT_SPEC.md
- [ ] Step 3: Conduct guided Q&A with user
- [ ] Step 4: Write PRODUCT_SPEC.md
- [ ] Step 5: Handle deferred decisions
- [ ] Step 6: Review and refine with user
- [ ] Step 7: Suggest next step (/technical-spec)
```

Read PRODUCT_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Ask the user to describe their idea
2. Work through each question category (Problem, Users, Experience, Features, Data)
3. Make recommendations with confidence levels
4. Generate the final PRODUCT_SPEC.md document

## Output

Write the completed specification to `$1/PRODUCT_SPEC.md`.

After writing PRODUCT_SPEC.md, verify the file exists and is non-empty by reading the first few lines. If the file was not created successfully, report the error and retry.

## Deferred Requirements Capture (During Q&A)

**IMPORTANT:** Capture deferred requirements interactively during the Q&A process, not after.

### When to Trigger

During the Q&A, watch for signals that the user is deferring a requirement:
- "out of scope"
- "not for MVP" / "post-MVP"
- "v2" / "version 2" / "future"
- "later" / "eventually"
- "maybe" / "nice to have"
- "we'll skip that for now"
- "not right now"
- "that's a separate thing"

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

Ask these clarifying questions (can be combined into one AskUserQuestion with multiple questions):

1. **What's being deferred?**
   "In one sentence, what's the requirement or feature?"
   (Pre-fill with your understanding from context)

2. **Why defer it?**
   Options: "Out of scope for MVP" / "Needs more research" / "V2 feature" / "Resource constraints" / "Other"

3. **Notes for later?**
   "Any context that will help when revisiting this?"
   (Optional — user can skip)

### Write to DEFERRED.md Immediately

After collecting answers, append to `$1/DEFERRED.md` right away (don't wait until end).

**If file doesn't exist, create it:**

```markdown
# Deferred Requirements

> Captured during specification Q&A. Review when planning future versions.

## From PRODUCT_SPEC.md ({date})

| Requirement | Reason | Notes |
|-------------|--------|-------|
| {user's answer} | {selected reason} | {notes or "—"} |
```

**If file exists, append:**

```markdown
| {user's answer} | {selected reason} | {notes or "—"} |
```

(If appending to a different spec's section, add a new section header first.)

### Continue Q&A

After capturing (or skipping), continue the spec Q&A where you left off. Don't break the flow.

## Cross-Model Review (Automatic)

After writing PRODUCT_SPEC.md, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` on the generated document
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --research "product requirements, user stories" $1/PRODUCT_SPEC.md
```

**If Codex finds issues:**
- Show critical issues and recommendations
- Ask user: "Address findings before proceeding?" (Yes/No)
- If Yes: Apply suggested fixes
- If No: Continue with noted issues

**If Codex unavailable:** Skip silently and proceed to Next Step.

## Next Step

When complete, inform the user:
```
PRODUCT_SPEC.md created at $1/PRODUCT_SPEC.md
Deferred Requirements: {count} items captured to DEFERRED.md
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED

Next: Run /technical-spec $1
```
