# Repository Sweep — 2026-09-29

This report records the GitHub-wide follow-up to retiring the AI Coding Project
Toolkit. The sweep covered all 48 non-fork, non-archived repositories owned by
`benjaminshoemaker`.

The governing rule was preservation-first: remove executable workflow machinery,
but retain feature ideas, product decisions, research, project-specific skills,
and durable operating constraints. Scanner findings are review prompts, not
automatic deletion approval.

## Outcome

- 33 repositories have no scanner findings on their default branch.
- 13 repositories have only preserved context findings: plans, feature folders,
  ideas, bugs, todos, next steps, deferred work, or learnings.
- 2 repositories still contain executable toolkit machinery because they appear
  to be historical workflow products rather than ordinary projects:
  `maestro_cli` and `auto_orchestrator`.
- No repository was archived or deleted.
- No idea-bearing feature folder or context document was deleted in this sweep.

## Migrations completed

The following repository migrations were merged during this sweep:

| Repository | Result |
| --- | --- |
| `nfl_game_explainer` | Removed copied commands, skills, metadata, verification logs, and Workstream; simplified `AGENTS.md`. |
| `aoe4-game-analyzer` | Removed copied skills, toolkit configuration, and Workstream; retained lightweight work files and project-specific rules. |
| `notes_brain` | Removed copied commands, skills, backup trees, verification state, and Workstream; preserved feature and plan context. |
| `jobs_ai_builder` | Removed generated verification state; preserved plans and follow-up documents as context. |
| `crm_personal` | Removed generated phase and verification state; retained security rules and plan context. |
| `bee_pm` | Removed only the retired `discover` skill; preserved Bee-specific skills and operating instructions. |
| `simple-qr-code-generator` | Removed copied toolkit machinery; retained product plans and follow-up context. |
| `provenance` | Removed copied toolkit machinery; retained product plans, feature context, and design-system guidance. |
| `letgo` | Removed copied toolkit machinery; retained product plans and todo context. |
| `microsoft-vibe` | Removed copied toolkit machinery; retained product and architecture plans. |
| `ripped` | Removed verification workflow configuration; retained math, safety, plan, and follow-up context. |

Earlier migrations in the same retirement effort covered
`ai_coding_project_base`, `tally_analytics`, and `benshoemaker-us`.
`bens_indispensable_skills` is now the canonical source for the curated reusable
skill library.

## Intentionally preserved review findings

These repositories now contain no executable toolkit infrastructure but still
surface documents worth preserving or reviewing:

- `aoe4-game-analyzer`: `BUGS.md`, `DEFERRED.md`, and `NEXT_STEPS.md`.
- `calc-example`: four generated product/technical/execution plan files in a
  disposable example repository.
- `cf-funnel-investigation`: `LEARNINGS.md`.
- `crm_personal`: four plan documents plus `LEARNINGS.md` and `TODOS.md`.
- `interview-documents`: `LEARNINGS.md`.
- `jobs_ai_builder`: four plan documents plus bugs, deferred work, and next steps.
- `letgo`: three plan documents plus `TODOS.md`.
- `microsoft-vibe`: three plan documents.
- `notes_brain`: archived and active plan documents, two feature folders, and
  bugs/deferred/next-step files.
- `provenance`: three plan documents, one feature folder, and `TODOS.md`.
- `ripped`: three plan documents and `TODOS.md`.
- `simple-qr-code-generator`: three plan documents and `TODOS.md`.
- `tally_analytics`: seven preserved feature-idea folders and `IDEAS.md`.

These are not considered active workflow residue. They should be consolidated
only when their product meaning is understood; Git history alone is not a
substitute for preserving unresolved ideas in a discoverable current document.

## Repositories requiring an explicit disposition

### `maestro_cli`

This repository contains a full copy of the retired phase/specification toolkit,
including commands, workflow skills, verification configuration, Workstream,
plans, and end-to-end fixtures. Because the repository itself appears to be a
workflow product, deleting those files would change its historical purpose rather
than merely clean project residue.

### `auto_orchestrator`

This repository likewise contains commands, workflow skills, verification
configuration, Workstream, and todo context as part of an orchestration product.
It should be retired, archived, or converted into clearly labeled historical
reference as one deliberate action.

## Recommended next decisions

1. Choose whether `maestro_cli` and `auto_orchestrator` should be archived as-is,
   retained as read-only historical references, or stripped down to short archive
   READMEs with Git history as the implementation record.
2. Decide whether test/demo repositories such as `calc-example` should remain
   active or be archived. Their plan files are harmless but add search noise.
3. Optionally consolidate preserved plan and feature context into `IDEAS.md` or
   another project-native document on a repo-by-repo basis. Do this only for
   projects likely to be resumed.
4. Keep `bens_indispensable_skills` as the canonical library and copy selected
   skills into each agent installation explicitly; do not restore project-local
   copies or shared symlink trees.

## Verification method

The sweep used the repository's read-only residue scanner for local checkouts and
the GitHub recursive-tree API for default branches. After migrations, the remote
default branches were scanned again. Application CI and deployment checks were
allowed to complete before merges when present.
