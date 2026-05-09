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
- [ ] Step 3: Plan status guard
- [ ] Step 4: Check for existing plans/greenfield/PRODUCT_SPEC.md
- [ ] Step 5: Conduct guided Q&A with user
- [ ] Step 6: Write plans/greenfield/PRODUCT_SPEC.md
- [ ] Step 7: Update plans/PLAN_STATUS.md
- [ ] Step 8: Handle deferred decisions
- [ ] Step 9: Review and refine with user
- [ ] Step 10: Suggest next step (/technical-spec)
```

## Lean Mode (`--lean`)

When `--lean` is passed:
- **Web research runs in background:** Launch all WebSearch research as background Agent calls (`run_in_background: true`). Continue the Q&A without waiting. When results arrive, only interrupt the flow if a finding would materially change a recommendation (e.g., a critical known issue, a dominant competitor, a clearly superior alternative). Skip routine competitive analysis summaries.
- **Skip all post-generation gates.** Do not run `/verify-spec`, `/codex-consult`, or `/criteria-audit`. Report each as `LEAN_SKIP` in the output.

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

## Plan Status Guard

Read `~/.claude/skills/shared/PLAN_STATUS.md` before writing files.

1. Ensure `plans/` exists.
2. Read `plans/PLAN_STATUS.md` if it exists.
3. If another path is listed as `Current plan` with `Current status: active`,
   ask whether this greenfield spec supersedes it, should be recorded as
   non-current research/planned work, or should abort.
4. If this spec supersedes the current greenfield plan, archive a snapshot under
   `plans/archive/YYYYMMDD-HHMMSS-greenfield/` before overwriting active files.
5. If `plans/PLAN_STATUS.md` is missing, create it after writing the spec.

## Existing File Guard (Prevent Overwrite)

Before asking any questions, ensure `plans/greenfield/` exists, then check whether
`plans/greenfield/PRODUCT_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Archive then overwrite (recommended)**: copy the existing greenfield plan set to `plans/archive/YYYYMMDD-HHMMSS-greenfield/`, mark the archived snapshot as superseded when practical, then write the new document to `plans/greenfield/PRODUCT_SPEC.md`
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

Update `plans/PLAN_STATUS.md` so:
- `Current plan` is `plans/greenfield/`
- `Current type` is `greenfield`
- `Current stage` is `product-spec`
- `Current status` is `active`
- the history table records any archived or superseded plan snapshot

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

## Post-Generation Gates (MANDATORY unless `--lean`)

These gates MUST execute before you produce the "Next Step" output. The output template requires results from each gate. Reporting `SKIPPED` without `--lean` is a skill violation — go back and run the gate.

### Gate 1: Spec Verification

After writing `plans/greenfield/PRODUCT_SPEC.md`, run quality verification:

1. Invoke `/verify-spec product-spec` on the generated document
2. This runs **quality checks only** (no upstream context preservation since PRODUCT_SPEC.md has no upstream):
   - Q-001: Vague/unmeasurable language ("fast", "user-friendly", "simple")
   - Q-002: Subjective terms without targets ("better", "improved")
   - Q-003: Missing rationale for decisions
   - Q-005: Implicit assumptions
   - Q-006: Conflicting requirements
   - Q-PS-001: Missing user flow (feature mentioned without step-by-step interaction)
   - Q-PS-002: Only happy path described (no edge cases)
   - Q-PS-003: Unbounded scope ("all", "any", "every" without limits)
   - Q-PS-004: Missing non-functional requirements (performance, security, accessibility)
3. Present CRITICAL issues with resolution options (max 2 fix iterations)
4. Do not proceed to Gate 2 until verification passes or user explicitly chooses to proceed with noted issues

### Gate 2: Cross-Model Review

After verification, run cross-model review if Codex CLI is available:

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

**If Codex CLI is not installed or not authenticated:** Report `UNAVAILABLE` (not `SKIPPED` — the distinction matters).

## Error Handling

| Situation | Action |
|-----------|--------|
| PROMPT.md not found at `.claude/skills/product-spec/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| DEFERRED.md write fails (permissions or disk) | Output deferred items to terminal, warn user, continue with spec generation |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

**Pre-condition**: All gates above have completed, or `--lean` was explicitly passed. If you have not run them, STOP and run them now. Reporting `SKIPPED` without `--lean` is a skill violation.

When complete, inform the user:
```
PRODUCT_SPEC.md created at ./plans/greenfield/PRODUCT_SPEC.md
Deferred Requirements: {count} items captured to DEFERRED.md
Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW | LEAN_SKIP
Cross-Model Review: PASSED | PASSED WITH NOTES | UNAVAILABLE | LEAN_SKIP

Next: Run /technical-spec
```
