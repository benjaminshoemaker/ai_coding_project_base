# Session Analysis Report

Generated: 2026-02-15
Sessions analyzed: 295
Date range: 2026-01-23 to 2026-02-15 (23 days)

## Summary

- Total sessions: 295 (283 unique, ~12 duplicates from reconnects)
- Projects: 26
- Common patterns identified: 8 high-impact
- Focus: Reducing human intervention

## Per-Project Breakdown

### KineticBI (104 sessions)

**Type:** Target
**Date range:** 2026-01-30 – 2026-02-14
**Key patterns:**
- 19.8% context overflow rate (38 sessions, 54 continuation markers)
- 10 sessions with multiple context overflows (up to 6 in one session)
- 18 sessions hit `psql: command not found` — database access confusion
- 103 user rejections across 51 sessions
- 21 rejections specifically redirecting to /codex-consult
- 142 AskUserQuestion calls
- 37 sessions hit `timeout` command not found
- `supabase db reset` mentioned 399 times — recurring forbidden operation

### ai_coding_project_base (80 sessions)

**Type:** Toolkit
**Date range:** 2026-01-23 – 2026-02-15
**Key patterns:**
- 5.1 average user interventions per session
- 30% of interventions are questions, 30% are directional corrections
- 38% of AskUserQuestion calls are sync-related
- 56% of AskUserQuestion calls are automatable
- 5 sessions hit context overflow

### Conductor Workstreams (36 sessions across 11 city-named worktrees)

**Type:** Parallel worktrees
**Date range:** 2026-02-02 (burst)
**Key patterns:**
- 40 sessions on Feb 2 alone — conductor orchestration testing
- Short-lived sessions with rapid restarts

### Other Target Projects

| Project | Sessions | User Msgs | AskUser Calls | Msgs/Session |
|---------|----------|-----------|---------------|--------------|
| fast_pr_analytics | 21 | 73 | 2 | 3.5 |
| personal_site | 13 | 141 | 11 | 10.8 |
| qr_code | 14 | 89 | 2 | 6.4 |
| notes_brain | 5 | 114 | 7 | 22.8 |
| letgo | 4 | 53 | 10 | 13.3 |
| aoe4 | 5 | 25 | 5 | 5.0 |
| my-new-calculator | 2 | 7 | 5 | 3.5 |
| PDQ_DSV | 2 | 4 | 0 | 2.0 |
| spidey | 2 | 2 | 0 | 1.0 |

## Cross-Project Insights

### Autonomy Levels

| Project | Sessions | Interventions/Session | Autonomy |
|---------|----------|-----------------------|----------|
| spidey | 2 | 1.0 | High |
| PDQ_DSV | 2 | 2.0 | High |
| fast_pr_analytics | 21 | 3.5 | High |
| my-new-calculator | 2 | 3.5 | High |
| aoe4-game-analyzer | 5 | 5.0 | Med |
| toolkit | 80 | 5.1 | Med |
| qr_code | 14 | 6.4 | Med |
| personal_site | 13 | 10.8 | Low |
| letgo | 4 | 13.3 | Low |
| notes_brain | 5 | 22.8 | Low |

### Shared Patterns Across Projects

1. **`timeout` command not found** — affects KineticBI (37 sessions), calculator, spidey, and any project using /codex-review or /codex-consult
2. **Browser MCP not connected** — affects notes_brain, calculator, qr_code during verification
3. **file:// URL blocked** — Playwright can't verify local HTML files; affects calculator, static sites
4. **Context overflow in spec pipelines** — affects any project running spec + tech spec + plan in one session
5. **Sync prompt fatigue** — toolkit users asked about sync after every commit

## Automation Opportunities

### HIGH PRIORITY

#### 1. Document Database Access in KineticBI AGENTS.md
**Occurrences:** 18 sessions, 40+ failed commands per session
**Projects:** KineticBI
**Pattern:** Agent tries `psql` (not installed), then `supabase db execute` (wrong syntax), then docker exec with wrong connection strings. After context overflow, loses the working approach and starts over.
**Suggested Automation:**
- Add to KineticBI's AGENTS.md:
  ```
  ## Database Access
  - Local: `docker exec -i supabase_db_KineticBI psql -U postgres -d postgres`
  - Remote: Use Supabase JS client through the app's API, NOT direct psql
  - NEVER use `psql` directly (not installed)
  - NEVER run `supabase db reset`
  ```
- **Estimated intervention reduction: 18+ sessions saved**

#### 2. Fix `timeout` Command for macOS
**Occurrences:** 37+ sessions (19.3%)
**Projects:** All projects using /codex-review or /codex-consult
**Pattern:** `command not found: timeout` — macOS doesn't have GNU `timeout`
**Suggested Automation:**
- Replace `timeout` with portable alternative in codex skill scripts
- Use: `gtimeout` (coreutils) with fallback, or `perl -e 'alarm(N); exec @ARGV'`
- **Estimated intervention reduction: 37+ sessions fixed**

#### 3. Auto-invoke /codex-consult After Plan Generation
**Occurrences:** 21 user rejections across 10+ sessions
**Projects:** KineticBI, toolkit, all target projects
**Pattern:** Agent generates plan, starts implementing. User rejects with "Review this plan with /codex-consult". This happens so consistently it should be automatic.
**Suggested Automation:**
- Update plan generation skills to always run /codex-consult before implementation
- Remove the manual redirect step
- **Estimated intervention reduction: 21+ rejections eliminated**

#### 4. Break Spec Pipelines Into Separate Sessions
**Occurrences:** 38 sessions (19.8%) hit context overflow
**Projects:** All projects running spec workflows
**Pattern:** Chaining /feature-spec + /feature-technical-spec + /feature-plan + implementation in one session causes context overflow. Files are re-read 8-12 times after each continuation.
**Suggested Automation:**
- Add AGENTS.md directive: "Complete and commit each spec artifact in a separate session"
- Add warnings in spec skills: "This artifact is complete. Start a new session for the next step."
- **Estimated intervention reduction: prevents 38+ context overflows**

### MEDIUM PRIORITY

#### 5. Auto-Accept Sync Prompts
**Occurrences:** 6 of 16 AskUserQuestion calls (38%) in toolkit
**Projects:** Toolkit
**Pattern:** After every commit that modifies skills, user is asked "Sync target projects now?" — user skips 43% of the time, accepts 57%.
**Suggested Automation:**
- Default to "skip" unless user explicitly requests sync
- Queue sync requests and batch them at end of session
- Or: add a `--auto-sync` flag to honor
- **Estimated intervention reduction: 6+ prompts per batch of sessions**

#### 6. Set Smart Defaults in /add-todo
**Occurrences:** 142 AskUserQuestion calls in KineticBI
**Projects:** KineticBI, any project using /add-todo or /list-todos
**Pattern:** /add-todo asks Priority, Section, Effort, and Description as separate questions for each item. 4+ sequential questions before a single TODO is created.
**Suggested Automation:**
- Default Priority=P2, auto-infer Section from context, infer Effort from description
- Only ask when genuinely ambiguous
- **Estimated intervention reduction: 3 questions per TODO item**

#### 7. Pre-Push Local Verification
**Occurrences:** 54 sessions with merge conflicts / CI failures
**Projects:** KineticBI
**Pattern:** Push to remote, CI fails, fix, push again — 4+ cycles per session
**Suggested Automation:**
- Add AGENTS.md directive: "Always run `.workstream/verify.sh` before pushing"
- Consider a pre-push git hook
- **Estimated intervention reduction: 3-4 CI round-trips per session**

### LOW PRIORITY

#### 8. Browser MCP Connection Guide
**Occurrences:** Affects notes_brain, calculator, qr_code verification
**Projects:** Any with BROWSER:* criteria
**Pattern:** Browser MCP extension not connected; Playwright fails on file:// URLs; Chrome conflict
**Suggested Automation:**
- Start a local server automatically when verifying HTML files
- Add fallback chain documentation to AGENTS.md
- **Estimated intervention reduction: 1-2 per affected session**

## Recommended Actions

1. **Add database access section to KineticBI AGENTS.md** — eliminates the #1 source of wasted cycles (40+ commands per session)
2. **Fix `timeout` in codex skills** — one-line fix, 37 sessions affected
3. **Auto-invoke /codex-consult after plan/spec generation** — eliminates 21+ manual redirections
4. **Add "commit and start new session" guidance to spec skills** — prevents 19.8% context overflow rate
5. **Default sync prompts to "skip"** — eliminates 38% of toolkit AskUserQuestion calls
6. **Smart defaults in /add-todo** — eliminates 3 questions per item
7. **Pre-push verification directive in AGENTS.md** — prevents CI failure loops
8. **Auto-start local server for browser verification** — fixes file:// URL blocking

## Raw Statistics

### Session Restart Rate
| Project | Quick Restarts (within 5 min) | % of Sessions |
|---------|-------------------------------|---------------|
| KineticBI | ~25 | 24% |
| ai_coding_project_base | ~22 | 28% |
| conductor workstreams | ~7 | 19% |
| Other | ~6 | 10% |
| **Total** | **~60** | **20%** |

### Context Overflow Rate
| Project | Sessions with Overflow | % |
|---------|-----------------------|---|
| KineticBI | 38 | 19.8% |
| ai_coding_project_base | 5 | 6.3% |

### AskUserQuestion Categories (Toolkit)
| Category | Count | % |
|----------|-------|---|
| Sync-related | 6 | 38% |
| Other (clarifications) | 5 | 31% |
| Codex-review | 3 | 19% |
| Docs | 1 | 6% |
| Plan-mode | 1 | 6% |

### User Intervention Types (Toolkit, 15 sessions)
| Type | Count | % |
|------|-------|---|
| Questions | 23 | 30% |
| Directional corrections | 23 | 30% |
| Git actions (commit/push) | 10 | 13% |
| Rubber-stamp (yes/ok) | 8 | 11% |
| Skill invocations | 7 | 9% |
| Interrupts | 5 | 7% |

### Blockers Encountered
| Blocker Type | Count | Resolution |
|--------------|-------|------------|
| Context overflow | 54 | Session continuation (lossy) |
| `timeout` not found | 37+ | Manual workaround or skip |
| `psql` not found | 18 | Docker exec after many attempts |
| Browser MCP not connected | 5+ | Fallback to Playwright or skip |
| file:// URL blocked | 2+ | Start local HTTP server |
| `supabase db reset` attempted | Multiple | User rejection/correction |
| File write before read | 17 | Re-read file first |
