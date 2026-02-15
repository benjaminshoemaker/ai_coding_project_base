---
name: criteria-audit
description: Validate EXECUTION_PLAN.md for verification metadata, manual reasons, and testability. Use when preparing Phase 1 or after editing EXECUTION_PLAN.md.
---

# Criteria Audit Skill

Audit EXECUTION_PLAN.md to ensure acceptance criteria are automation-ready and
use the verification metadata format.

## Arguments

- `$1` (optional) = directory containing `EXECUTION_PLAN.md`
  - If provided, read `$1/EXECUTION_PLAN.md`
  - If empty, read `EXECUTION_PLAN.md` from the current working directory

## Workflow Overview

Copy this checklist and track progress:

```
Criteria Audit Progress:
- [ ] Step 1: Read EXECUTION_PLAN.md
- [ ] Step 2: Parse phases, tasks, and acceptance criteria
- [ ] Step 3: Validate verification metadata
- [ ] Step 4: Report issues and summarize
```

## Step 1: Parse Acceptance Criteria

Resolve the plan path: if `$1` is provided, use `$1/EXECUTION_PLAN.md`; otherwise use `EXECUTION_PLAN.md` in the current working directory.

For each task, collect:
- Criterion text
- Type tag (e.g., `(TEST)`)
- `Verify:` line
- If manual: `Reason:` line

Also collect Pre-Phase Setup items and their `Verify:` lines.

## Step 2: Validation Rules

### Acceptance Criteria Rules

- Every criterion must include a type tag: `(TEST)`, `(CODE)`, `(LINT)`,
  `(TYPE)`, `(BUILD)`, `(SECURITY)`, `(BROWSER:DOM)` etc.
- Every criterion must include a `Verify:` line unless it is `MANUAL`.
- `MANUAL` criteria must include a `Reason:` line.
- Flag ambiguous criteria (vague, subjective, or missing measurable details).

### Pre-Phase Setup Rules

- Each setup item must include a `Verify:` command.
- If missing, mark as human-required.

## Step 3: Check MANUAL Criteria for False Tags

Read `~/.claude/skills/auto-verify/PATTERNS.md` for the full pattern matching table
and MANUAL decision tree.

For each criterion tagged `(MANUAL)`, check if it contains keywords from the
Pattern Matching Table that indicate it CAN be automated (priorities 1-10).
If it matches any automatable pattern, it is a **false MANUAL tag**.

Only criteria matching the "Truly Manual Patterns" section (subjective UX/brand/tone
judgment) should remain as MANUAL.

## Step 4: Report

Provide a structured report:

```
CRITERIA AUDIT
==============

Tasks Checked: {N}
Criteria Checked: {N}
Issues Found: {N}

Missing Type Tags:
- Task 1.2.A: "{criterion}"

Missing Verify Lines:
- Task 1.3.B: "{criterion}"

Manual Missing Reason:
- Task 2.1.A: "{criterion}"

Pre-Phase Setup Missing Verify:
- Phase 1: "{setup item}"

False MANUAL Tags (should be automated):
- Task 1.2.A: (MANUAL) "{criterion}"
  → Suggest: (CODE) — Verify: `curl -sf {url} -o /dev/null`
  → Reason: Contains "endpoint"/"returns" — automatable via curl
- Task 2.1.B: (MANUAL) "{criterion}"
  → Suggest: (BROWSER:DOM) — Verify: route=`/page`, selector=`.class`
  → Reason: Contains "visible"/"displays" — automatable via browser

MANUAL Summary:
  Total MANUAL criteria: {N}
  Likely false tags: {N} (should be retagged)
  Truly manual: {N} (subjective judgment)

Status: PASS | WARN | FAIL
```

**FAIL** if any false MANUAL tags are found. **WARN** if MANUAL criteria exceed 10%
of total criteria. **PASS** otherwise.

## Resolution Guidance

- If missing metadata is obvious, propose the exact type and `Verify:` line.
- For false MANUAL tags, propose the specific replacement type and verify command.
- If ambiguous, recommend asking the human to clarify.
- Do not edit EXECUTION_PLAN.md automatically unless explicitly requested.
