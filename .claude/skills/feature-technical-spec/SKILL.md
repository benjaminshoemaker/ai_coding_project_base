---
name: feature-technical-spec
description: Define technical approach (architecture, integration points, data model) for a feature through guided Q&A and write FEATURE_TECHNICAL_SPEC.md. Use after /feature-spec.
argument-hint: <feature-name>
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Glob, Grep
---

Generate a feature technical specification document for the feature `$1`.

## Workflow

Copy this checklist and track progress:

```
Feature Technical Spec Progress:
- [ ] Directory guard
- [ ] Plan status guard
- [ ] Check prerequisites (FEATURE_SPEC.md exists)
- [ ] Existing file guard (prevent overwrite)
- [ ] Existing code analysis (similar functionality, patterns, integration points)
- [ ] Codebase maturity assessment
- [ ] Generate FEATURE_TECHNICAL_SPEC.md
- [ ] Update plans/PLAN_STATUS.md
- [ ] Write FLOW_VERIFICATION_PLAN.md
- [ ] Run spec-verification
- [ ] Capture deferred requirements
- [ ] Cross-model review (if Codex available)
```

## Directory Guard

1. If `.toolkit-marker` exists in the current working directory → **STOP**:
   "You're in the toolkit repo. Feature skills run from your project directory.
    Run: `cd ~/Projects/your-project && /feature-technical-spec $1`"

2. Check `.claude/toolkit-version.json` exists in the current working directory (confirms `/setup` was run).
   If missing → **STOP**: "Toolkit not installed. Run `/setup` from the toolkit first."

3. Check `AGENTS.md` exists in the current working directory (confirms project root).
   If missing → **STOP**: "Run this from your project root (where AGENTS.md lives)."

## Arguments

- `$1` = feature name (e.g., `analytics`, `dark-mode`)
- If `$1` is empty, ask the user for the feature name
- `PROJECT_ROOT` = current working directory
- `FEATURE_DIR` = `PROJECT_ROOT/features/$1`

## Plan Status Guard

Read `~/.claude/skills/shared/PLAN_STATUS.md` before writing files.

1. Read `PROJECT_ROOT/plans/PLAN_STATUS.md` if it exists.
2. If the manifest exists and `Current plan` is different from `features/$1/`
   with `Current status: active`, ask whether this feature should become
   current, stay non-current planned work, or abort.
3. If the manifest is missing, create it after writing the technical spec.
4. If this technical spec replaces an existing feature technical direction,
   archive a snapshot under `features/archive/YYYYMMDD-HHMMSS-$1/` before
   overwriting downstream files.

## Prerequisites

- Check that `FEATURE_DIR/FEATURE_SPEC.md` exists. If not:
  "FEATURE_SPEC.md not found at features/$1/. Run `/feature-spec $1` first."
- Check that `PROJECT_ROOT/AGENTS.md` exists (indicates an existing project). If not, warn:
  "AGENTS.md not found. Feature development assumes an existing project. Did you mean to run `/product-spec` for a new project?"

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `FEATURE_DIR/FEATURE_TECHNICAL_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Archive then overwrite (recommended)**: copy the existing feature plan set to `features/archive/YYYYMMDD-HHMMSS-$1/`, mark the archived snapshot as superseded when practical, then write the new document to `FEATURE_DIR/FEATURE_TECHNICAL_SPEC.md`
  2. **Overwrite**: replace `FEATURE_DIR/FEATURE_TECHNICAL_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Process

Read `.claude/skills/feature-technical-spec/PROMPT.md` and follow its instructions exactly:

1. Read `FEATURE_DIR/FEATURE_SPEC.md` as input

2. **Perform Existing Code Analysis** (REQUIRED before any design):

   **Note:** All code analysis should be performed on PROJECT_ROOT (current working directory).

   a. **Similar Functionality Audit**
      - Search for existing code that does something similar to what the feature needs
      - List any utilities, helpers, or patterns that could be reused
      - Flag if creating new code when existing code could be extended
      - Output:
        ```
        SIMILAR FUNCTIONALITY FOUND
        ---------------------------
        - {file}: {description of similar functionality}
        - {file}: {reusable utility/helper}

        Recommendation: {extend existing | create new | hybrid approach}
        ```

   b. **Pattern Compliance Check**
      - Identify how similar features are implemented in the codebase
      - Note naming conventions, file organization, error handling patterns
      - Document the "house style" for this type of feature
      - Output:
        ```
        EXISTING PATTERNS
        -----------------
        File organization: {pattern}
        Naming convention: {pattern}
        Error handling: {pattern}
        Testing approach: {pattern}
        ```

   c. **Integration Point Mapping**
      - List every existing file/module the feature will touch
      - For each, assess: complexity, test coverage, documentation quality
      - Flag high-risk integration points
      - Output:
        ```
        INTEGRATION POINTS
        ------------------
        | File | Risk | Coverage | Notes |
        |------|------|----------|-------|
        | {file} | High/Med/Low | X% | {concerns} |
        ```

3. **Assess codebase maturity** — Is this a legacy/brownfield codebase?
   - Look for: outdated dependencies, missing tests, undocumented code, deprecated patterns
   - If legacy indicators found, explicitly address technical debt, undocumented behavior, and human decision points

4. Work through integration analysis, regression risks, and migration strategy

5. Generate the final FEATURE_TECHNICAL_SPEC.md document, incorporating findings from step 2

## Output

Write the completed specification to `FEATURE_DIR/FEATURE_TECHNICAL_SPEC.md`.

Update `PROJECT_ROOT/plans/PLAN_STATUS.md` so:
- `Current plan` is `features/$1/` unless the user explicitly chose non-current planned work
- `Current type` is `feature`
- `Current stage` is `feature-technical-spec`
- `Current status` is `active` for current work, or `planned` for non-current work
- the history table records any archived or superseded feature snapshot

## Flow Verification Plan

After writing `FEATURE_TECHNICAL_SPEC.md` and before post-generation gates, decide
whether this feature introduces or materially changes an end-to-end user,
integration, or agent flow that should be verified by an AI coding agent.

1. Read `.claude/skills/discover-flow-verification/SKILL.md`.
2. Use the feature spec, technical spec, project docs, tests, scripts, and
   existing verification conventions to answer:
   "Does this feature need agent-runnable flow verification beyond normal task
   acceptance criteria?"
3. If **yes**, apply the discovery steps from `/discover-flow-verification`:
   - Name the flow in plain user language.
   - Identify the real channel under test.
   - Map blind spots, controllable state, success/failure assertions, evidence,
     and teardown/rerun behavior.
   - Ask focused questions only when the flow, success condition, or external
     dependency policy is unclear.
   - Write `FEATURE_DIR/FLOW_VERIFICATION_PLAN.md` using the Plan Output
     headings from `/discover-flow-verification`, prefixed with:
     ```markdown
     # Flow Verification Plan: $1

     Status: Applicable
     ```
4. If **no**, write `FEATURE_DIR/FLOW_VERIFICATION_PLAN.md` with:
   ```markdown
   # Flow Verification Plan: $1

   Status: Not applicable
   Reason: {short reason this feature does not introduce or materially change an
   end-to-end flow that needs a dedicated agent-runnable harness}
   ```
5. If the answer is blocked by unresolved product or environment decisions,
   ask the user before continuing. Do not hand off to `/feature-plan` until
   `FLOW_VERIFICATION_PLAN.md` is either `Status: Applicable` with enough detail
   for execution planning, or `Status: Not applicable` with a concrete reason.

## Lean Mode (`--lean`)

When `--lean` is passed:
- **Skip all post-generation gates.** Do not run `/verify-spec`, `/codex-consult`, or `/criteria-audit`. Report each as `LEAN_SKIP` in the output.
- All other steps (Q&A, document generation, deferred capture) run normally.

## Post-Generation Gates (MANDATORY unless `--lean`)

These gates MUST execute before you produce the "Next Step" output. The output template requires results from each gate. Reporting `SKIPPED` without `--lean` is a skill violation — go back and run the gate.

### Gate 1: Spec Verification

After writing FEATURE_TECHNICAL_SPEC.md, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from FEATURE_SPEC.md appear in FEATURE_TECHNICAL_SPEC.md
3. Run quality checks for vague language, missing rationale, undefined contracts, integration gaps
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to Gate 2 until verification passes or user explicitly chooses to proceed with noted issues.

## Deferred Requirements Capture (During Q&A)

**IMPORTANT:** Capture deferred requirements interactively during the Q&A process, not after.

Write deferred items to `PROJECT_ROOT/DEFERRED.md` (not the feature directory).

### When to Trigger

During the Q&A, watch for signals that the user is deferring a technical decision:
- "out of scope"
- "not in this feature" / "separate feature"
- "v2" / "future version"
- "premature optimization"
- "technical debt we'll address later"
- "keep it simple for now"
- "follow-up" / "future enhancement"

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
   Options: "Premature optimization" / "Out of scope" / "Separate feature" / "V2" / "Needs more research" / "Other"

3. **Notes for later?**
   "Any technical context that will help when revisiting this?"
   (Optional — user can skip)

### Write to DEFERRED.md Immediately

After collecting answers, append to `PROJECT_ROOT/DEFERRED.md` right away.

**Add new section or append to existing feature section:**

```markdown

## From FEATURE_TECHNICAL_SPEC.md: {FEATURE_NAME} ({date})

| Requirement | Reason | Notes |
|-------------|--------|-------|
| {user's answer} | {selected reason} | {notes or "—"} |
```

### Continue Q&A

After capturing (or skipping), continue the spec Q&A where you left off.

### Gate 2: Cross-Model Review

After verification passes, run cross-model review if Codex CLI is available:

1. Check if Codex CLI is installed: `codex --version`
2. If available, run `/codex-consult` with upstream context
3. Present any findings to the user before proceeding

**Consultation invocation:**
```
/codex-consult --upstream features/$1/FEATURE_SPEC.md --research "{detected technologies from codebase}" features/$1/FEATURE_TECHNICAL_SPEC.md
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
| FEATURE_SPEC.md not found in `features/$1/` | Stop and report "Run `/feature-spec $1` first" |
| PROMPT.md not found at `.claude/skills/feature-technical-spec/PROMPT.md` | Stop and report "Skill asset missing — reinstall toolkit or run /setup" |
| `discover-flow-verification/SKILL.md` missing | Stop and report "Flow verification skill missing — reinstall toolkit or run /setup" |
| Codebase too large for full code analysis (>5000 files) | Limit analysis to `src/`, `lib/`, and `app/` directories; note reduced scope in output |
| DEFERRED.md write fails (permissions or disk) | Output deferred items to terminal, warn user, continue with spec generation |
| Codex CLI invocation fails or times out | Log the error, skip cross-model review, proceed to Next Step |

## Next Step

**Pre-condition**: All gates above have completed, or `--lean` was explicitly passed. If you have not run them, STOP and run them now. Reporting `SKIPPED` without `--lean` is a skill violation.

When complete, inform the user:
```
FEATURE_TECHNICAL_SPEC.md created and verified at features/$1/FEATURE_TECHNICAL_SPEC.md

Flow Verification Plan: APPLICABLE | NOT_APPLICABLE
Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW | LEAN_SKIP
Cross-Model Review: PASSED | PASSED WITH NOTES | UNAVAILABLE | LEAN_SKIP
Deferred Requirements: {count} items captured to DEFERRED.md

Next: Run /feature-plan $1
```
