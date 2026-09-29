# Skill Disposition Inventory

This records the first-pass classification used for the retirement. The active
toolkit copies were subsequently removed after commit `c4c30c5` preserved the
pre-retirement state.

## Disposition Definitions

- **Keep** — independently useful with little or no workflow coupling.
- **Refactor** — useful capability whose current implementation depends on
  toolkit conventions or is broader than necessary.
- **Merge** — useful behavior that should become part of a clearer retained
  skill instead of remaining a separate command.
- **Retire** — primarily exists to create, operate, recover, or maintain the
  old specification and phase workflow.

## Keep

These are candidates for canonical ownership in `bens_indispensable_skills`.
They still require normal validation and duplicate comparison.

| Skill | Rationale or required check |
|---|---|
| `audit-agentsmd` | Useful for any repository with agent instructions. |
| `audit-skills` | Maintains the independent skill library itself. |
| `codex-consult` | Narrow cross-model consultation capability. |
| `codex-implement` | Independent delegation capability if its verification assumptions are decoupled. |
| `codex-review` | Independent branch and diff review capability. |
| `data-flow-audit` | Domain-independent correctness audit. |
| `discover-flow-verification` | Useful before implementation without requiring a formal spec chain. |
| `feature-audit` | Can evaluate shipped behavior directly; remove plan requirements if any. |
| `innovate` | Independent product exploration, provided it does not force premature planning. |
| `merge-prs` | Standalone repository operation with clear verification value. |
| `modify-skill` | Supports maintenance of the curated skill library. |
| `oauth-login` | Narrow supporting capability for authenticated verification. |
| `prepare-goal-harness` | Optional goal-oriented verification, not a mandatory lifecycle. |
| `search-chats` | Independent context-retrieval capability. |
| `security-scan` | Independent, executable verification capability. |
| `suggest-skills` | Useful for evidence-based skill evolution. |
| `tech-debt-check` | Independent code-quality audit. |
| `tone-check` | Independent writing review. |
| `ui-ux` | Independent design analysis; compare scope with `design-directions`. |
| `vercel-preview` | Narrow deployment lookup; consider generalizing only with demonstrated need. |
| `vision-audit` | Potentially useful strategy audit when `VISION.md` is optional. |

## Refactor

These contain a potentially valuable capability, but their current form carries
workflow assumptions, mandatory file conventions, or excessive orchestration.

| Skill | Direction |
|---|---|
| `analyze-sessions` | Focus on observed recurring needs and skill candidates, not workflow telemetry. |
| `auto-verify` | Turn into a reusable verification helper or fold it into code verification. |
| `browser-verification` | Accept direct outcomes and flows instead of toolkit acceptance-criterion syntax. |
| `capture-learning` | Make durable output optional and project-selected rather than always `LEARNINGS.md`. |
| `capture-session` | Remove mandatory end-of-session invocation and fixed project files. |
| `capture-work` | Avoid imposing `BUGS.md`, `NEXT_STEPS.md`, and `DEFERRED.md` universally. |
| `code-verification` | Preserve evidence-first verification while removing phase and task-schema coupling. |
| `configure-verification` | Retain repository-native command discovery without generating workflow state. |
| `create-pr` | Keep PR creation and verification but make cross-model review optional and composable. |
| `triage` | Generalize beyond toolkit-specific work files or merge into a broader repository triage skill. |
| `update-docs` | Update relevant documentation without assuming commits or toolkit-generated files. |
| `work-status` | Discover the repository's actual tracking surfaces instead of requiring toolkit files. |

## Merge

| Skill | Proposed destination |
|---|---|
| `capture-learning` | Consider merging its useful behavior into an optional mode of `capture-session`. |
| `auto-verify` | Consider making it an internal resource of a refactored `code-verification`. |
| `configure-verification` | Consider making it a reusable resource shared by verification and PR skills. |

Items appear here as architectural proposals and remain listed under
**Refactor** until the destination design is tested.

## Retire

| Skill or resource | Reason |
|---|---|
| `criteria-audit` | Validates the retired execution-plan schema. |
| `discover` | Replaced by the broader and less prescriptive `project-research` skill. |
| `feature-plan` | Generates the retired execution-plan structure. |
| `feature-spec` | Enforces a fixed specification stage that is no longer the default. |
| `feature-technical-spec` | Enforces a fixed specification chain. |
| `fresh-start` | Orients and auto-advances the phase workflow. |
| `generate-plan` | Generates the retired plan hierarchy and scoped instructions. |
| `go` | Routes execution through phase and plan state. |
| `phase-checkpoint` | Operates the retired phase lifecycle. |
| `phase-prep` | Operates the retired phase lifecycle. |
| `phase-start` | Operates the retired phase lifecycle. |
| `populate-state` | Reconstructs retired phase state. |
| `product-spec` | Mandatory greenfield specification stage. Research and direct planning replace it. |
| `progress` | Reports against the retired plan and phase structure. |
| `review-deferred` | Manages verification state created by the retired lifecycle. |
| `setup` | Installs and generates the old toolkit structure. |
| `spec-verification` | Verifies documents produced by the fixed specification chain. |
| `technical-spec` | Mandatory stage in the fixed specification chain. |
| `update-target-projects` | Broad synchronization is being replaced by selective skill installation and migration. |
| `verify-task` | Thin entrypoint tied to execution-plan task identifiers; replace with direct verification. |
| `shared/` | Shared plan schemas and phase resources retire with their consumers; inspect before removal. |

## Skills Already Added to the Canonical Library

The following new skills live in `bens_indispensable_skills` rather than this
repository:

| Skill | Role |
|---|---|
| `project-research` | Researches unfamiliar domains, alternatives, evidence, and hypotheses before committing to a solution. |
| `design-directions` | Generates and compares distinctive visual directions, then helps evolve a chosen design language. |
| `security-scan` | Runs independent dependency, secret, and project-native static-analysis checks without phase coupling. |
| `tone-check` | Reviews formulaic AI-writing markers and personal-voice fit using locally packaged session parsing. |

`data-flow-audit` and `discover-flow-verification` have also been reconciled
into their canonical library copies. Details and validation results are in the
skill library's `docs/canonical-reconciliation.md`.

## Review Outcomes

- Cross-model consultation, implementation, and review remain separate.
- `capture-session`, `capture-work`, `triage`, `work-status`, and
  `update-docs` were retired from the canonical library.
- `innovate` adopted the newer runners-up and compounding/flywheel behavior.
- `ui-ux` and `design-directions` remain separate evaluation and generative
  capabilities.
- Skills not promoted during reconciliation remain available only in Git
  history pending concrete demand.
