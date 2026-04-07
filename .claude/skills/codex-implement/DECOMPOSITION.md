# Task Decomposition

Decision tree and strategies for decomposing implementation requests into
bounded tasks for Codex execution.

## Decision Tree

```
Is the request a single bounded concern?
├─ YES: Does it touch ≤ 3 files?
│  ├─ YES: Is the estimated change ≤ ~80 lines?
│  │  ├─ YES → SINGLE TASK
│  │  └─ NO  → SINGLE TASK (large but cohesive — don't split)
│  └─ NO:  Are the extra files just imports/exports/config?
│     ├─ YES → SINGLE TASK (incidental touches don't count)
│     └─ NO  → DECOMPOSE
└─ NO: Are the concerns independent?
   ├─ YES → DECOMPOSE (one task per concern, parallel-safe)
   └─ NO  → DECOMPOSE (ordered by dependency, foundational first)
```

## Decomposition Heuristics

Split when ANY of these apply:

| Signal | Example | Split Strategy |
|--------|---------|----------------|
| Multiple layers | "Add endpoint + UI + migration" | One task per layer |
| Multiple concerns | "Add auth AND rate limiting" | One task per concern |
| > 3 substantive files | Touching API, service, model, test, config | Group by concern |
| Test + implementation | Large feature with significant test suite | Implementation first, tests second |
| Setup + usage | "Install library and integrate it" | Setup/config first, integration second |

## Ordering Rules

Tasks are executed sequentially. Order by:

1. **Foundation first**: Schema/model before service before API before UI
2. **Dependencies first**: If task B imports from task A's output, A goes first
3. **Tests last** (unless TDD is the project convention): Implementation, then tests
4. **Config/setup first**: Package installs, env changes before code

## Task Boundaries

Each decomposed task MUST be:

- **Self-contained**: Codex can complete it without knowing about other tasks
- **Verifiable**: Has at least one testable success criterion
- **Bounded**: Touches a predictable set of files (listed in the task)
- **Ordered**: Dependencies resolved by execution order

Each decomposed task MUST NOT:

- Depend on a future task's output
- Require interactive input during execution
- Modify the same file as another task (prefer merging into one task)

## Cap and Override

Default max tasks: 5 (configurable via `codexImplement.maxTasks`).

If decomposition produces more tasks than the cap:

1. Warn the user:
   ```
   This request decomposes into {N} tasks (cap: {MAX_TASKS}).
   For complex features, consider the full workflow:
     /feature-spec → /feature-technical-spec → /feature-plan → /phase-start
   ```
2. Offer options via AskUserQuestion:
   - "Proceed anyway" — execute all tasks
   - "Reduce scope" — Claude suggests which tasks to cut
   - "Use full workflow" — redirect to `/feature-spec`

## Single-File Overlap

If two tasks would modify the same file, prefer merging them into one task.
Codex handles a single cohesive change better than two sequential edits to
the same file where the second must account for the first's modifications.

Exception: if the file is a config/registry file (routes, exports, package.json)
that just needs a line added, allow overlap — these are append-only changes.
