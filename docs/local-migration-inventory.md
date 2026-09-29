# Local Migration Inventory

Snapshot date: 2026-09-29

The read-only residue scanner was run against each immediate Git repository
under `/Users/coding/Projects`. No scanned repository was modified.

## Summary

- 24 repositories contain at least one known toolkit-related finding.
- 164 findings are high-confidence workflow or toolkit artifacts.
- 28 findings are reusable skills that match the canonical library or have no
  canonical counterpart yet.
- 140 findings are plans, instructions, or locally divergent skills whose
  content must be reviewed.
- `bens_indispensable_skills`, `finance_ai`, `education_ai`, and `cod_stats`
  produced no findings under the current rules.

Counts describe scanner findings, not approved removals. A repository with many
`REVIEW` findings may contain valuable project history rather than cleanup
debt.

## Repositories With Findings

| Repository | High | Medium | Review |
|---|---:|---:|---:|
| `ai_coding_project_base` | 37 | 27 | 8 |
| `aoe4-game-analyzer` | 12 | 1 | 3 |
| `KineticBI` | 9 | 0 | 29 |
| `auto_orchestrator` | 9 | 0 | 0 |
| `calc-example-2` | 9 | 0 | 3 |
| `fast_pr_analytics` | 9 | 0 | 20 |
| `letgo` | 9 | 0 | 4 |
| `maestro_cli` | 9 | 0 | 6 |
| `my-new-calculator` | 9 | 0 | 4 |
| `nfl_game_explainer` | 9 | 0 | 0 |
| `notes_brain` | 9 | 0 | 14 |
| `personal_site` | 9 | 0 | 4 |
| `simple-qr-code-generator` | 9 | 0 | 4 |
| `ai_fluency_index` | 3 | 0 | 4 |
| `allergy_restaurant_finder` | 3 | 0 | 2 |
| `microsoft_vibe` | 3 | 0 | 4 |
| `provenance` | 3 | 0 | 4 |
| `bee_pm` | 1 | 0 | 0 |
| `crm_personal` | 1 | 0 | 6 |
| `jobs_ai_builder` | 1 | 0 | 9 |
| `ripped` | 1 | 0 | 5 |
| `ai_coding_orchestrator` | 0 | 0 | 1 |
| `athlete_charitable_contributions` | 0 | 0 | 2 |
| `calc-example` | 0 | 0 | 4 |

## Pilot Readiness

The initial candidates (`aoe4-game-analyzer`, `KineticBI`, and
`auto_orchestrator`) are not safe cleanup pilots today. All three have
uncommitted work; `KineticBI` and `auto_orchestrator` already contain extensive
user-owned skill deletions. The transition must not overwrite or duplicate that
work.

Only two local repositories with findings currently have clean working trees:

1. **`personal_site`** — nine high-confidence generic artifacts and four review
   items. Its root instructions mix valuable project facts with obsolete phase,
   commit, and TODO conventions, making it a good full migration pilot.
2. **`jobs_ai_builder`** — one high-confidence verification config and nine
   review items. It is a useful context-preservation pilot because most of its
   residue is plan and instruction content rather than copied machinery.

These are the safest available candidates, but cleanup still requires an
explicit choice because it changes high-impact instructions and removes tracked
files. Before either pilot, create a dedicated branch or recoverable worktree,
inspect every review artifact, and define what project context replaces the
retired plan hierarchy.

## Scanner Limitations Observed

- The scanner recognizes known filenames and toolkit skill names; it does not
  identify renamed artifacts.
- The snapshot uses `--canonical-skills`. Copied skills that differ from the
  library are counted as review findings rather than medium findings.
- It deliberately treats generated plan filenames as review items rather than
  inferring that their content is obsolete.
- It does not scan repositories that are not present locally.
- It does not detect global skill links or user-level agent configuration.

These limitations should be addressed through comparison reports and pilot
review, not by adding a broad automatic delete mode.
