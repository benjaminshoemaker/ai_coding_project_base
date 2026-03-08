# Feature Spec: Execution Memory

## Problem

The toolkit collects 10+ types of execution telemetry: session transcripts
(295+ sessions across 26 projects), phase state, verification results,
auto-advance outcomes, blocker data, deferred reviews, and git commit
patterns. It then discards that data after each run. Auto-advance session data
is deleted after reporting. Verification results evaporate. Blocker data is
never aggregated. `LEARNINGS.md` doesn't even exist despite the capture
infrastructure being built.

Every project starts from zero. The same blockers (missing env vars, auth misconfiguration, schema mismatches) hit project after project. Phase timing is always a guess. The toolkit treats its 295th execution identically to its 1st.

Meanwhile, the #1 unsolved problem in AI coding (per 2026 surveys and analyst reports) is context drift and verification bottleneck. Every competitor — Kiro, Copilot Workspace, GitHub Spec Kit, Cursor — starts fresh each time. None learn from their own execution history.

## Users

- **Solo developers** using the toolkit across multiple projects — the primary audience. They benefit most from cross-project pattern recognition.
- **Repeat users** who build similar projects (e.g., Next.js + Supabase SaaS apps) — execution memory compounds fastest for them.
- **Teams** where multiple developers use the toolkit — shared execution memory could surface org-wide patterns (future scope).

## Solution

A persistent, structured Execution Memory layer that:

1. **Archives** execution telemetry instead of discarding it
2. **Fingerprints** projects by tech stack, size, and structure for cross-project matching
3. **Predicts** likely blockers and phase duration based on historical patterns
4. **Injects** predictive context into `/phase-prep` and `/fresh-start`
5. **Informs** plan generation with historically-grounded task sizing

### Before / After

**Before:** `/fresh-start` on a new Next.js + Supabase project. No historical context. Agent discovers missing `SUPABASE_URL` 45 minutes into Phase 2. Auth middleware misconfiguration blocks Phase 3. Same issues hit the last 3 projects.

**After:** `/fresh-start` says: "Based on 4 similar projects (Next.js + Supabase), expect Phase 2 to take ~3hrs. Common blockers: missing SUPABASE_URL (3/4 projects), auth middleware misconfiguration (2/4). Pre-checking environment... SUPABASE_URL is not set. Fix before proceeding?"

## Scope

### In Scope

- Persistent execution record store (`~/.claude/execution-memory/`)
- Project fingerprinting (framework, database, auth method, deploy target)
- Execution record archiving from `/phase-checkpoint` and auto-advance sessions
- Predictive pre-flight warnings in `/phase-prep`
- Historical context summary in `/fresh-start`
- Memory-informed phase sizing in `/generate-plan`
- Query/inspect interface (`/execution-memory`)
- Pruning and recency-weighted predictions

### Out of Scope

- Automatic skill generation from patterns (future enhancement on top of memory)
- Multi-user / team-shared memory (future scope)
- Real-time execution adjustment (memory informs planning, doesn't alter mid-execution)
- Dashboard or web UI for memory visualization

## Acceptance Criteria

### Core Storage

1. After every `/phase-checkpoint`, a structured execution record is appended to
   `~/.claude/execution-memory/runs.jsonl` containing: project fingerprint,
   phase number, duration, task count, tasks completed, blockers encountered
   (type + description), verification results (pass/fail per check), skills
   invoked, and auto-advance success/failure.
2. Auto-advance session data (`auto-advance-session.json`) is archived to execution memory instead of being deleted after reporting.
3. Each project gets a fingerprint in `~/.claude/execution-memory/fingerprints.json` containing: project path, framework, database, auth method, deploy target, phase count, and last-updated timestamp.

### Predictive Pre-flight

1. `/phase-prep` loads execution memory and matches the current project's
   fingerprint against historical runs (same project + similar projects by
   stack).
2. When historical data exists, `/phase-prep` displays: predicted phase
   duration (median of historical), top 3 likely blockers (with frequency), and
   environment pre-checks for historically common failures.
3. Pre-checks that can be verified automatically (env var existence, dependency
   installation, service connectivity) are executed and results shown before
   phase execution begins.
4. Predictions are advisory. They surface as warnings and never block
   execution.

### Context Injection

1. `/fresh-start` generates or updates the project fingerprint on first load.
2. When execution memory contains data for the current project or similar
   projects, `/fresh-start` displays a "Historical Context" summary: number of
   prior runs, overall success rate, most common blockers, and recommended
   pre-checks.

### Plan Generation

1. `/generate-plan` consults execution memory when sizing phases. If historical
   data shows that projects with this stack have phases that consistently take
   longer, task distribution is adjusted with a "Memory-Informed Adjustments"
   annotation.
2. If a specific integration (e.g., Stripe webhooks, OAuth) historically causes
   blockers, `/generate-plan` auto-adds prerequisite verification tasks to the
   plan.

### Memory Management

1. `/execution-memory` skill allows querying the store: list projects, show
   runs for a project, show aggregate stats, and search blockers.
2. `/execution-memory --prune` removes records older than a configurable
   threshold (default: 6 months).
3. Predictions are weighted by recency. Recent runs have more influence than
   old ones (exponential decay).
4. Each record includes a timestamp and toolkit version for staleness
   detection.

## Non-Functional Requirements

- Execution memory lives at `~/.claude/execution-memory/` (user-global, not per-project)
- JSONL format for append-only writes and easy parsing
- No external dependencies — pure file I/O + existing shell hooks
- Memory operations must not slow down phase execution (async append, sync read only at prep/start boundaries)
- Fingerprint matching uses simple field overlap scoring, not ML

## Open Questions

1. **Granularity of fingerprinting** — Is {framework, database, auth_method, deploy_target} sufficient, or do we need more dimensions (e.g., monorepo vs single-app, test framework, CI provider)?
2. **Cross-project matching threshold** — How many matching fingerprint fields constitute a "similar project"? Start with 2/4 match?
3. **Session transcript integration** — Should the session-end hook also extract structured signals into execution memory, or keep that as a `/analyze-sessions` enhancement?
4. **Memory size limits** — Should there be a max record count or file size cap beyond time-based pruning?
