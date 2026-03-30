---
name: product-spec
description: Generate PRODUCT_SPEC.md through guided Q&A. Use as the first step when starting a new greenfield project.
argument-hint: "[--lean]"
allowed-tools: Read, Write, AskUserQuestion, Bash, Agent
---

Generate a product specification document for the current project.

## Workflow

Copy this checklist and track progress:

```
Product Spec Progress:
- [ ] Step 1: Directory guard
- [ ] Step 2: Project root confirmation
- [ ] Step 3: Check for existing plans/greenfield/PRODUCT_SPEC.md
- [ ] Step 4: Conduct guided Q&A with user
- [ ] Step 5: Write plans/greenfield/PRODUCT_SPEC.md
- [ ] Step 6: Handle deferred decisions
- [ ] Step 7: Review and refine with user
- [ ] Step 8: Suggest next step (/technical-spec)
```

## Lean Mode (`--lean`)

When `--lean` is passed:
- **Web research runs in background:** Launch all WebSearch research as background Agent calls (`run_in_background: true`). Continue the Q&A without waiting. When results arrive, only interrupt the flow if a finding would materially change a recommendation (e.g., a critical known issue, a dominant competitor, a clearly superior alternative). Skip routine competitive analysis summaries.
- **Skip post-generation Codex consult:** Do not run `/codex-consult` after writing the spec. Proceed directly to the Next Step.

## Directory Guard

1. If `.toolkit-marker` exists in the current working directory → **STOP**:
   "You're in the toolkit repo. Run this from your project directory instead:
    `cd ~/Projects/your-project && /product-spec`"

## Project Root Confirmation

Before generating any files, confirm the output location with the user:

```
Will write PRODUCT_SPEC.md to: {absolute path of cwd}/plans/greenfield/
Continue? (Yes / Change directory)
```

If the user says "Change directory", ask for the correct path and instruct them to `cd` there first.

## Existing File Guard (Prevent Overwrite)

Before asking any questions, ensure `plans/greenfield/` exists, then check whether
`plans/greenfield/PRODUCT_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `plans/greenfield/PRODUCT_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `plans/greenfield/PRODUCT_SPEC.md`
  2. **Overwrite**: replace `plans/greenfield/PRODUCT_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Discovery Notes Integration

Before starting the Q&A, check for discovery notes:
1. Look for `plans/greenfield/DISCOVERY_NOTES.md`, then `DISCOVERY_NOTES.md` in project root.
2. If found, read the file and use it as pre-filled context:
   - **Key Decisions** entries answer questions about problem, audience, platform, stack, and scope — skip those questions in the Q&A.
   - **Open Questions** become the focus of the Q&A — ask about those specifically.
   - **Existing Solutions & Tools** should be referenced when making recommendations (e.g., suggest leveraging a library found during discovery).
   - **Raw Context** provides nuance — use it to inform your recommendations but don't re-ask about it.
3. Announce: "Found discovery notes — skipping {N} questions already answered during /discover."
4. If discovery notes are incomplete or ambiguous on a topic, still ask about it.

## Process

Read `.claude/skills/product-spec/PROMPT.md` and follow its instructions exactly:

1. Ask the user to describe their idea (skip if discovery notes provide a clear summary)
2. Work through each question category (Problem, Users, Experience, Features, Data)
3. Make recommendations with confidence levels
4. Generate the final PRODUCT_SPEC.md document

## Output

Write the completed specification to `plans/greenfield/PRODUCT_SPEC.md`.

After writing `plans/greenfield/PRODUCT_SPEC.md`, verify the file exists and is non-empty by reading the first few lines. If the file was not created successfully, report the error and retry.

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

After collecting answers, append to `DEFERRED.md` right away (don't wait until end).

**If file doesn't exist, create it:**

```markdown
# Deferred Requirements

> Captured during specification Q&A. Review when planning future versions.

## From plans/greenfield/PRODUCT_SPEC.md ({date})

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

## Cross-Model Review (Automatic — skipped in `--lean` mode)

If `--lean` was passed, skip this entire section and proceed to Next Step.

After writing `plans/greenfield/PRODUCT_SPEC.md`, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` on the generated document
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --research "product requirements, user stories" plans/greenfield/PRODUCT_SPEC.md
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
| PROMPT.md not found at `.claude/skills/product-spec/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| DEFERRED.md write fails (permissions or disk) | Output deferred items to terminal, warn user, continue with spec generation |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

When complete, inform the user:
```
PRODUCT_SPEC.md created at ./plans/greenfield/PRODUCT_SPEC.md
Deferred Requirements: {count} items captured to DEFERRED.md
Cross-Model Review: PASSED | PASSED WITH NOTES | SKIPPED

Next: Run /technical-spec
```
