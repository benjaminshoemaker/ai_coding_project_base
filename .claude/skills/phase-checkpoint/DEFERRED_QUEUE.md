# Deferred Review Queue

Schema and management logic for the deferred verification review queue.

Referenced by: `/phase-checkpoint`, `/verify-task`, `/go`, `/review-deferred`, `/progress`.

## Relationship to DEFERRED.md

The toolkit has two distinct "deferred" concepts:

- **`DEFERRED.md`** (project root) — Deferred *requirements*: features/scope items explicitly
  postponed during spec Q&A (`/feature-spec`, `/feature-technical-spec`). Product decisions.
- **`.claude/deferred-reviews.json`** (`.claude/` directory) — Deferred *verification*: acceptance
  criteria that were implemented but need subjective human review. Quality checks.

The two files serve different purposes and never overlap.

## Queue File Format

**Location:** `.claude/deferred-reviews.json` (gitignored — runtime state only)

```json
{
  "version": 1,
  "queue": [
    {
      "key": "1:1.2.A:V-003",
      "phase": 1,
      "task_id": "1.2.A",
      "criterion_id": "V-003",
      "criterion": "Button color matches brand palette",
      "reason": "Subjective visual — no downstream dependency",
      "reviewed": false,
      "context": {
        "file": "src/components/Button.tsx",
        "line": 42,
        "summary": "Implemented as indigo-600 with hover:indigo-700"
      },
      "deferred_at": "2026-02-15T10:30:00Z"
    }
  ],
  "last_drained": null,
  "last_drain_reason": null
}
```

**Key fields:**

| Field | Description |
|-------|-------------|
| `key` | Deterministic: `{phase}:{task_id}:{criterion_id}`. Used for deduplication. |
| `reviewed` | `false` = pending review, `true` = reviewed (ready to clear) |
| `context` | Implementation context to help human reviewers |

**State-only file:** The queue JSON stores only runtime state. All configuration
(drain triggers, max queue size) lives in `.claude/settings.local.json` under
`autoAdvance`. The queue file has no config keys.

## Operations

### Enqueue

Add item with context, dedupe by `key`. Called by `/phase-checkpoint` and `/verify-task`.

1. Read `.claude/deferred-reviews.json` (create if missing with `{"version": 1, "queue": []}`)
2. Check if `key` already exists in queue
   - If yes: update existing entry (refresh `context` and `deferred_at`)
   - If no: append new entry
3. Write atomically (temp file + rename)

### Drain

Present all unreviewed items to human, set `reviewed: true`. Called when a drain trigger fires.

1. Read queue, filter to `reviewed: false` items
2. Group by phase for presentation
3. Present to human via AskUserQuestion
4. Mark reviewed items as `reviewed: true`
5. Update `last_drained` and `last_drain_reason`

### Clear

Remove all `reviewed: true` items from queue after drain.

## Drain Trigger Definitions

Configuration is read from `autoAdvance` in `.claude/settings.local.json`:

```json
{
  "autoAdvance": {
    "enabled": true,
    "maxDeferredQueue": 20,
    "drainOnBlocker": true,
    "drainOnCompletion": true
  }
}
```

A "blocker" that triggers drain is precisely defined as:

- **Auto-advance stopped for blocking MANUAL items** — checkpoint has `(MANUAL)` items
  requiring human judgment that affect downstream work
- **Checkpoint FAIL on automated gate** — a CODE/TEST/BROWSER criterion failed and
  requires human intervention

Drain does NOT occur on the FAIL path for automated criteria that can be fixed without
human input (e.g., a failing test the agent can retry). It only occurs when the human
is already being prompted via `AskUserQuestion`.

**Trigger conditions:**

1. **`drainOnBlocker`** (default: true): When auto-advance stops for blocking MANUAL
   items or checkpoint FAIL requiring human input → prepend "While you're here..." with
   deferred items
2. **`drainOnCompletion`** (default: true): When `/go` detects all phases complete →
   present queue via `/review-deferred`
3. **`maxDeferredQueue`** (default: 20): When queue reaches N items → present at next
   checkpoint regardless. Set to `0` to disable queue limit.
4. **Explicit**: User runs `/review-deferred`

## Checkbox Representation in EXECUTION_PLAN.md

When a `MANUAL:DEFER` item is enqueued, mark it checked with an inline annotation:

```
- [x] (MANUAL:DEFER) Button color matches brand palette — Deferred: 1:1.2.A:V-003
```

This means "implemented, review pending." The `Deferred: {key}` annotation lets
`/progress` distinguish "verified" from "deferred" and report accurate counts.
The checkbox is checked so it doesn't block phase completion, but the annotation
preserves traceability.

## Atomic Writes

Always write to a temp file and rename to prevent corruption:

```bash
# Write to temp, then atomic rename
echo "$JSON" > .claude/deferred-reviews.json.tmp
mv .claude/deferred-reviews.json.tmp .claude/deferred-reviews.json
```

If the queue file fails to parse on read:
1. Back up to `.claude/deferred-reviews.json.bak`
2. Start a fresh queue
3. Report the incident
