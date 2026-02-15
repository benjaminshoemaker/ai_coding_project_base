# Local Verification Details

## Automated Local Checks

Run these commands and report results:

1. **Tests**
   ```
   {commands.test from verification-config}
   ```
   If `commands.test` is not in config: `Tests: SKIPPED (not configured)`

2. **Type Checking**
   ```
   {commands.typecheck from verification-config}
   ```
   If `commands.typecheck` is not in config: `Type Check: SKIPPED (not configured)`

3. **Linting**
   ```
   {commands.lint from verification-config}
   ```
   If `commands.lint` is not in config: `Linting: SKIPPED (not configured)`

4. **Build** (if applicable)
   ```
   {commands.build from verification-config}
   ```
   If `commands.build` is not in config: `Build: SKIPPED (not configured)`

5. **Dev Server Starts**
   ```
   {devServer.command from verification-config}
   ```
   Only start if `devServer.command` exists in config.
   If not in config: `Dev Server: SKIPPED (not configured)`

6. **Security Scan**

   Run security checks:
   - Use the project's configured security tooling (if documented)
   - Run secrets detection (pattern-based)
   - Run static analysis via documented tools or ask for a command

   For CRITICAL or HIGH issues:
   - Present each issue with resolution options
   - Apply fixes based on user choices
   - Re-scan to confirm resolution

   Security scan blocks checkpoint if CRITICAL or HIGH issues remain unresolved.

7. **Code Quality Metrics**

   Collect and report these metrics for the phase:

   ```
   CODE QUALITY METRICS
   --------------------
   Test Coverage: {X}% (target: 80%)
   Files changed in phase: {N}
   Lines added: {N}
   Lines removed: {N}
   New dependencies added: {list or "None"}
   ```

   To get coverage:
   - Use `commands.coverage` from verification-config if present
   - If empty, mark coverage as not applicable or ask to configure

   Flag if coverage dropped compared to before the phase (if a baseline exists).

## Optional Local Checks

These checks run only if the required tools are available.

### Code Simplification (requires: code-simplifier plugin)

If available, run code-simplifier on files changed in this phase:
```bash
git diff --name-only HEAD~{commits-in-phase}
```

Focus: reduce complexity, improve naming, eliminate redundancy. Preserve all functionality.

### Browser Verification (requires browser MCP tools)

First, check if phase includes UI work by scanning for `BROWSER:*` criteria.

**If browser criteria exist:**

a. **Resolve target URL** (deployment config check):
   - If `deployment` section missing from config → go straight to localhost
   - If `deployment.enabled` is true: Invoke vercel-preview skill to get preview URL
   - If preview URL found: TARGET = preview URL
   - If not found and `fallbackToLocal`: TARGET = localhost (with warning)
   - If not found and NO fallback: BLOCK verification
   - If deployment not enabled: TARGET = localhost (devServer.url)
   - If `devServer` section also missing from config → skip browser verification entirely:
     `"Browser Verification: SKIPPED (no dev server or deployment configured)"`

b. Check tool availability (fallback chain):
   - ExecuteAutomation Playwright → Browser MCP → Microsoft Playwright → Chrome DevTools

c. **If at least one tool available:**
   - Use the browser-verification skill with each criterion's `Verify:` metadata
   - Take snapshots for verification
   - Test against TARGET URL

**Display target in output:**
```
Browser Verification:
- Target: Vercel Preview (https://my-app-xyz.vercel.app)
[Or]
- Target: Local Dev Server (http://localhost:3000)
- Target: Local Dev Server (fallback - no preview deployment found)
```

c. **If NO browser tools available (SOFT BLOCK):**
   - Display warning and use AskUserQuestion:
     - "Continue with manual verification" → Add browser checks to Human Required section
     - "Stop to configure tools" → Halt checkpoint, provide setup instructions

### Technical Debt Check (optional)

If `.claude/skills/tech-debt-check/SKILL.md` exists:
- Run duplication analysis
- Run complexity analysis
- Check file sizes
- Detect AI code smells

Report findings with severity levels. Informational only (does not block).

---

## Manual Verification

### Auto-Verify Attempt

From the "Phase $1 Checkpoint" section in EXECUTION_PLAN.md, extract LOCAL items
marked for manual verification.

**Before listing for human review, attempt automation using the auto-verify skill:**

For each manual item:
1. Invoke auto-verify skill with item text and available tools
2. Record attempt result (PASS, FAIL, or MANUAL)

**Categorize results:**

For items that remain TRULY_MANUAL after auto-verify:
1. Check if criterion is tagged `(MANUAL:DEFER)` in EXECUTION_PLAN.md
2. If `MANUAL:DEFER` → enqueue to `.claude/deferred-reviews.json` with context (see [DEFERRED_QUEUE.md](DEFERRED_QUEUE.md))
3. If `MANUAL` (blocking) → add to Human Confirmation batch
4. If plain `MANUAL` with no qualifier → treat as blocking (backward compat)

**Report results:**

```
Automated Successfully:
- [x] "{item}" — PASS ({method}, {duration})

{If deferred items were queued:}
Deferred ({N} items queued for later review):
- "{criterion}" (Task {id}) — Reason: {reason}
Total queue: {M} items across {P} phases
{/If}
```

**Checkbox representation:** When a `MANUAL:DEFER` item is enqueued, mark it checked
in EXECUTION_PLAN.md with an inline annotation:
```
- [x] (MANUAL:DEFER) Button color matches brand palette — Deferred: 1:1.2.A:V-003
```

### Manual Verification Checklist

When items remain after auto-verify, present a single consolidated checklist.

**URL Resolution:** Before generating steps, resolve BASE_URL from
`deployment.enabled` in verification-config.json (invoke vercel-preview if
enabled). All URLs must use BASE_URL.

**Format:**

```
MANUAL VERIFICATION
===================
Target: {BASE_URL}

1. {Criterion title}
   a. Navigate to {BASE_URL}{route}
   b. {Action — what to do}
   c. Verify: {what you should see}

2. {Criterion title}
   a. {Step}
   b. {Step}
   c. Verify: {expected result}
```

Keep each item to 2-5 concrete steps. No preambles, prerequisites sections,
or troubleshooting tables — just the actions and what to check.

### Human Confirmation (Batch)

Only present BLOCKING manual items (not deferred). If zero blocking items remain
after deferral, skip human confirmation entirely.

After presenting the checklist, ask ONE question using AskUserQuestion:
- "All verified" → Update ALL checkboxes at once
- "Some verified" → Follow up asking which ones
- "None yet" → Leave unchecked, continue

Update checkboxes in EXECUTION_PLAN.md based on response.

After confirmation (or skip), check drain triggers on the deferred queue
(see [DEFERRED_QUEUE.md](DEFERRED_QUEUE.md)).

---

## Production Verification

**BLOCKED** until all Local Verification passes.

When local verification passes, extract PRODUCTION items from EXECUTION_PLAN.md:

1. **Staging/Production Deployment Verification**
2. **External Integration Verification**
3. **Production-Only Manual Checks**
