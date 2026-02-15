---
name: phase-checkpoint
description: Run checkpoint criteria after completing a phase. Use after /phase-start completes all tasks to verify quality gates before proceeding.
argument-hint: [phase-number]
allowed-tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion, WebFetch, WebSearch
---

Phase $1 is complete. Run the checkpoint criteria from EXECUTION_PLAN.md.

## Workflow

Copy this checklist and track progress:

```
Phase Checkpoint Progress:
- [ ] Step 1: Context detection
- [ ] Step 2: Tool availability & config
- [ ] Step 3: Local verification (automated, optional, manual)
- [ ] Step 4: Cross-model review (Codex)
- [ ] Step 5: Production verification
- [ ] Step 6: State update
- [ ] Step 7: Generate report
- [ ] Step 8: Auto-advance check
```

## Step 1: Context Detection

Determine working context:

1. If CWD matches `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD
   - MODE = "feature"
2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

**Directory Guard:** Confirm `EXECUTION_PLAN.md` exists. If not, STOP and tell user to `cd` into their project directory.

**Context Check:** If context is below 40% remaining, run `/compact` first.

## Step 2: Tool Availability & Config

Check which optional tools are available:

| Tool | Check Method | Fallback |
|------|--------------|----------|
| ExecuteAutomation Playwright | Check for `mcp__playwright__*` | Next in chain |
| Browser MCP | Check for `mcp__browsermcp__*` | Next in chain |
| Chrome DevTools MCP | `mcp__chrome-devtools__list_pages` | Manual verification |
| code-simplifier | Check if agent type available | Skip |
| Codex CLI | `codex --version` | Skip cross-model review |

**Browser fallback chain:** ExecuteAutomation → Browser MCP → Microsoft Playwright → Chrome DevTools → Manual

Read `.claude/verification-config.json` from PROJECT_ROOT. If missing entirely, run `/configure-verification`. Omitted keys mean those checks are not configured — skip them rather than blocking.

Read `.claude/settings.local.json` for cross-model review config:
```json
{
  "codexReview": {
    "enabled": true,
    "triggerOn": ["phase-checkpoint"]
  }
}
```

If `codexReview` is not configured, default to `enabled: true` when Codex CLI is available.

## Step 3: Local Verification (Must Pass First)

**IMPORTANT**: All local verification must pass before production verification.

See [VERIFICATION.md](VERIFICATION.md) for detailed check procedures.

### Automated Checks

Run these using commands from verification-config (skip any that are not configured):
1. Tests (`commands.test`) — skip if not in config
2. Type Checking (`commands.typecheck`) — skip if not in config
3. Linting (`commands.lint`) — skip if not in config
4. Build (`commands.build`) — skip if not in config
5. Mutation Tests (`commands.mutation_test`) — skip if not in config
6. Dev Server (`devServer.command`) — skip if not in config
7. Security Scan
8. Code Quality Metrics

If `commands.mutation_test` is configured, treat failures as a local verification
failure (it is part of the quality gate).

### Optional Checks

- Code Simplification (if code-simplifier available)
- Browser Verification (if browser tools available)
- Technical Debt Check (if skill exists)

### Manual Verification

1. Extract manual items from "Phase $1 Checkpoint" in EXECUTION_PLAN.md
2. Attempt automation using auto-verify skill
3. Classify remaining items:
   - `MANUAL:DEFER` → enqueue to deferred review queue (see [DEFERRED_QUEUE.md](DEFERRED_QUEUE.md))
   - `MANUAL` (blocking) → generate verification guide for human
4. If blocking items exist: ask human for batch confirmation
5. If only deferred items: skip human confirmation, report queue status
6. Update checkboxes in EXECUTION_PLAN.md

For external integrations, follow [DOCS_PROTOCOL.md](DOCS_PROTOCOL.md) to fetch latest documentation.

## Step 4: Cross-Model Review (Codex)

**Purpose:** Get a second opinion from a different AI model to catch blind spots.

### When This Step Runs

This step runs if ALL of these conditions are true:
- Codex CLI is available (`codex --version` succeeds)
- `codexReview.enabled` is true (or not configured, defaulting to true)
- `"phase-checkpoint"` is in `codexReview.triggerOn` (or not configured)

### Execution

1. **Gather phase context:**
   ```bash
   # Identify technologies from changed files for --research flag
   # Check package.json, imports in changed files
   ```

2. **Invoke `/codex-review`** with appropriate flags:
   ```
   /codex-review --research "{technologies}" security
   ```

   The `/codex-review` skill handles:
   - Branch diff gathering
   - Prompt generation with research instructions
   - Codex CLI invocation
   - Result parsing

3. **Process results:**

   | Codex Status | Checkpoint Action |
   |--------------|-------------------|
   | `pass` | Continue, note in report |
   | `pass_with_notes` | Show recommendations, continue |
   | `needs_attention` | Show critical issues, ask user how to proceed |
   | `skipped` | Note unavailable, continue |
   | `error` | Note error, continue |

4. **For `needs_attention` status:**
   - Display critical issues from Codex
   - Ask user: "Address Codex findings before proceeding?"
     - Yes → List issues to fix, pause checkpoint
     - No → Continue, note as accepted risk
   - Critical issues do NOT auto-block (user decides)

### Output

```
Cross-Model Review (Codex):
- Status: PASS | PASS WITH NOTES | NEEDS ATTENTION | SKIPPED
- Critical Issues: {N}
- Recommendations: {N}
{If issues}
- Top Issue: {description}
{/If}
```

### Skip Conditions

Skip this step (mark as SKIPPED) if:
- Running inside Codex CLI (`$CODEX_SANDBOX` is set) — `/codex-review` detects this automatically
- Codex CLI not installed
- `codexReview.enabled` is explicitly false
- Phase has fewer than 3 tasks (trivial phase)
- `--skip-codex` flag passed to checkpoint

## Step 5: Production Verification

**BLOCKED** until all Local Verification passes.

When local passes, verify:
- Staging/production deployment
- External integrations
- Production-only manual checks

## Step 6: State Update

After checkpoint passes, update `.claude/phase-state.json`:

```json
{
  "phases": [{
    "number": 1,
    "status": "CHECKPOINTED",
    "completed_at": "{ISO timestamp}",
    "checkpoint": {
      "tests_passed": true,
      "type_check_passed": true,
      "lint_passed": true,
      "security_passed": true,
      "mutation_tests_passed": true,
      "coverage_percent": 85,
      "manual_verified": true,
      "codex_review": {
        "status": "pass | pass_with_notes | needs_attention | skipped",
        "critical_issues": 0,
        "recommendations": 2,
        "user_accepted_risks": []
      }
    }
  }]
}
```

Write checkpoint report to `.claude/verification/phase-$1.md` and append to `.claude/verification-log.jsonl`.

## Step 7: Report

```
Phase $1 Checkpoint Results
===========================

Tool Availability:
- ExecuteAutomation Playwright: ✓ | ✗
- Browser MCP: ✓ | ✗
- Chrome DevTools MCP: ✓ | ✗
- code-simplifier: ✓ | ✗
- Codex CLI: ✓ | ✗

## Local Verification

Automated Checks:
- Tests: PASSED | FAILED
- Type Check: PASSED | FAILED | SKIPPED
- Linting: PASSED | FAILED | SKIPPED
- Build: PASSED | FAILED | SKIPPED
- Mutation Tests: PASSED | FAILED | SKIPPED
- Security: PASSED | FAILED

Optional Checks:
- Browser Verification: PASSED | SKIPPED
  - Target: {URL}
- Tech Debt: PASSED | NOTES | SKIPPED

Manual Checks:
- Automated: {X} items
- Blocking manual: {Y} items
- Deferred: {Z} items (queued for later review)
- Total deferred queue: {M} items across {P} phases

Local Verification: ✓ PASSED | ✗ FAILED

---

## Cross-Model Review (Codex)

Status: PASS | PASS WITH NOTES | NEEDS ATTENTION | SKIPPED
{If not skipped}
- Critical Issues: {N}
- Recommendations: {N}
{If needs_attention}
- User Action: Addressed | Accepted as risk
{/If}
{/If}

{If has recommendations}
Top Recommendations:
1. {recommendation}
2. {recommendation}
{/If}

---

## Production Verification
{items or "Blocked: Complete local verification first"}

---

Overall: Ready to proceed | Issues to address
```

## Step 8: Auto-Advance

See [AUTO_ADVANCE.md](AUTO_ADVANCE.md) for auto-advance logic.

**Summary:** If all checks pass and no blocking manual items remain, automatically invoke `/phase-prep {N+1}`. `MANUAL:DEFER` items are queued and do not block.

**Codex review and auto-advance:** Codex findings do NOT block auto-advance unless user explicitly chooses to address them. The review is advisory.

---

## When Checkpoint Cannot Pass

**If both local AND production verification fail:**
- Report all failures clearly, separated by category
- Do NOT suggest skipping checks
- Prioritize: Fix local failures first (they often cause production failures)
- Suggest: Run `/phase-start $1` to address failing tasks before re-running checkpoint

**If manual verification items cannot be completed:**
- Ask user: "Skip this item and document reason?" vs "Block until complete"
- If skipping: Record in DEFERRED.md with reason and timestamp
- Note: Skipped items don't count as PASSED for auto-advance

**If verification config file is missing entirely:**
- Run `/configure-verification` to auto-detect
- Omitted keys in an existing config are intentional — skip those checks

**If auto-advance chain should stop:**
- Report: "Auto-advance stopped at Phase $1 checkpoint"
- List specific blocking items
- Provide: "Run `/phase-checkpoint $1` again after resolving issues"

**If a tool consistently fails mid-checkpoint:**
- Mark that specific check as FAILED (not SKIPPED)
- Continue with remaining checks
- Report tool failure in final summary
- Suggest troubleshooting steps for the failing tool

**If Codex review times out or errors:**
- Mark as SKIPPED with reason
- Do NOT block checkpoint progress
- Note in report: "Cross-model review unavailable: {reason}"
- Suggest: Re-run `/codex-review` manually after checkpoint if desired

**If Codex finds critical issues:**
- Present issues to user with context
- Ask: "Address before proceeding or accept as noted risk?"
- If user chooses to proceed: Log as "accepted risk" in state
- Do NOT auto-block — cross-model review is advisory

---

**REMINDER**: Local verification must pass before production verification. If any local check fails, stop and report — do not proceed to production checks.
