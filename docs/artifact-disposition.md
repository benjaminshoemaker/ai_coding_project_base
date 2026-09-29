# Non-Skill Artifact Disposition

This inventory records the migration map used for repository retirement. Commit
`c4c30c5` preserved the complete pre-retirement tree before the classified
artifacts were removed from the active branch.

## Disposition Definitions

- **Keep during transition** — needed to manage or explain the migration.
- **Extract or relocate** — useful independently, but this repository should
  not remain its canonical home.
- **Retire** — exists primarily to operate or distribute the old workflow.
- **Historical** — useful as evidence or background, but should not remain
  prominent agent context after the transition.

## Commands

| Surface | Disposition | Reason or destination |
|---|---|---|
| `.claude/commands/generate-plan.md` | Retire | Compatibility shim for a retired stage. |
| `.claude/commands/product-spec.md` | Retire | Compatibility shim for a retired stage. |
| `.claude/commands/technical-spec.md` | Retire | Compatibility shim for a retired stage. |
| `.claude/commands/verify-spec.md` | Retire | Coupled to generated specification documents. |
| `.claude/commands/sync.md` | Retire | Broad target-project synchronization is being removed. |
| `.claude/commands/install-hooks.md` | Retire | Installs toolkit workflow hooks. |
| `.claude/commands/gh-init.md` | Extract or relocate | Generic repository setup can be a small independent skill if it is still needed. |
| `config/claude/commands/github-init.md` | Extract or relocate | Duplicate runtime-installed form of `gh-init`. |
| `config/claude/commands/innovate.md` | Retire after canonicalization | Legacy command wrapper should disappear once the skill copy is canonical. |

## Root Prompts and Generated-Project Templates

| Surface | Disposition | Reason |
|---|---|---|
| `PRODUCT_SPEC_PROMPT.md` | Retire | Implements the fixed greenfield specification stage. |
| `TECHNICAL_SPEC_PROMPT.md` | Retire | Implements the fixed technical-specification stage. |
| `GENERATOR_PROMPT.md` | Retire | Generates the old execution-plan hierarchy. |
| `PLAN_ITERATION_PROMPT.md` | Retire | Iterates on the old plan format. |
| `START_PROMPTS.md` | Retire | Entry points into the old workflow. |
| `AGENTS_TEMPLATE.md` | Retire | Generates broad workflow instructions in target projects. |
| `deprecated/` | Historical | Already superseded; Git history can preserve it after final review. |

## Distribution and Runtime Scripts

| Surface | Disposition | Reason or destination |
|---|---|---|
| `scripts/install-codex-skill-pack.sh` | Retire | Installs every toolkit skill rather than selected capabilities. |
| `scripts/sync-agent-skills.sh` | Replace | A selective installer should source skills from `bens_indispensable_skills`. |
| `scripts/bootstrap-agent-runtime.sh` | Replace or relocate | Bundles broad skill, MCP, and configuration installation. |
| `scripts/sync-agent-configs.sh` | Relocate | Personal cross-agent configuration is distinct from reusable skills. |
| `scripts/sync-agent-mcps.sh` | Relocate | MCP configuration is useful but belongs in personal agent setup. |
| `scripts/configure-codex-mcp.sh` | Retire after relocation | Backward-compatible wrapper around MCP synchronization. |

The replacement installer should be selective by default, list available
skills, support dry-run and check modes, and never prune unrelated user skills.

## Hooks and Automation

| Surface | Disposition | Reason or destination |
|---|---|---|
| `.claude/hooks/post-commit-sync-check.sh` | Retire | Enforces the target-project synchronization model. |
| `.claude/hooks/post-commit-doc-update.sh` | Retire | Creates workflow-specific pending state after commits. |
| `.claude/hooks/pre-push-doc-check.sh` | Retire | Coupled to repository documentation automation. |
| `.claude/hooks/session-end-logger.sh` | Evaluate for relocation | May support independent session analysis, but should not be mandatory. |
| `.claude/settings.json` | Replace before archive | Contains broad toolkit-specific permissions and hook integration. |

Mandatory guarantees that survive should move to ordinary tests or CI. Personal
agent conveniences should live in personal configuration, not be copied into
product repositories.

## Workstream and Verification Infrastructure

| Surface | Disposition | Reason |
|---|---|---|
| `.workstream/` | Retire | Implements generic orchestration infrastructure that is no longer the default. |
| `.claude/verification-config.json` | Retire | Configures the toolkit verification lifecycle. |
| `.env.verification.example` | Retire or relocate | Keep only if an independent verification skill still needs it. |
| `conductor.json` and `.conductor/` | Historical or retire | External workflow orchestration should not remain part of the starter. |
| `.codex/` | Review during archive | Separate repo-local setup from generally useful user configuration. |
| `.toolkit-marker` | Retire | Marks repositories for the old synchronization system. |

## Publication and Synchronization Metadata

| Surface | Disposition | Reason |
|---|---|---|
| `.claude/public-skills-manifest.json` | Retire after migration | `bens_indispensable_skills` becomes canonical. |
| `.claude/public-skills-config.json` | Retire after migration | Publication should run from the canonical skill repository. |
| `.claude/sync-log.txt` | Historical | Operational history, not active agent context. |
| `.claude/doc-update-pending.json` | Clear after preserving work | Pending state from the old documentation hook. |

## Documentation

### Keep During Transition

- `docs/repository-transition.md`
- `docs/skill-disposition.md`
- `docs/artifact-disposition.md`
- the README transition notice
- contribution and license information while the repository remains active

### Extract or Relocate

| Surface | Destination question |
|---|---|
| `docs/authenticated-browser-access.md` | Supporting resource for an independent browser-verification skill or personal agent documentation. |
| `docs/codex-cli.md` | Retain only the parts required by canonical cross-model skills. |
| useful parts of `docs/verification.md` | Supporting resources for independent verification skills or normal CI guidance. |

### Retire as Active Guidance

- `docs/advanced.md`
- `docs/commands.md`
- `docs/feature-workflow.md`
- `docs/manual-setup.md`
- `docs/recovery-commands.md`
- `docs/web-interfaces.md`
- `docs/workflow-automation.md`
- the workflow sections of `docs/index.html`
- `CODEX_APP_WORKFLOWS.md`
- `SDLC_REFERENCE.md`

These files can remain temporarily while links and retained content are
reconciled. At completion, Git history is preferable to an active `legacy/`
documentation tree.

## Strategy and Research Documents

| Surface | Disposition | Reason |
|---|---|---|
| `AI_DEVELOPMENT_HARNESS_ANALYSIS.md` | Historical | Records the reasoning behind the former system. |
| `COMPETITORS.md` | Historical | Time-sensitive market research should not guide agents indefinitely. |
| `PROJECT_GOALS.md` | Rewrite or retire | Its goals must reflect the transition if retained. |
| `VISION.md` | Rewrite or retire | The former workflow vision is no longer authoritative. |
| `LEARNINGS.md` | Review | Extract durable skill lessons; do not preserve obsolete workflow rules as active context. |

## Backlog and Feature State

| Surface | Disposition | Reason |
|---|---|---|
| `features/execution-memory/` | Retire | The proposal is coupled to phases, checkpoints, and generated plans. |
| `BUGS.md` | Close after preservation | The open command-shadowing bug becomes irrelevant when broad copying stops. |
| `NEXT_STEPS.md` | Replace during transition | Most ranked items deepen the workflow being retired. |
| `DEFERRED.md` | Review item by item | Keep only ideas that remain useful independently. |
| `archive/work-items/` | Historical | Preserve through Git rather than ongoing agent-visible context. |

## Repository Tooling

| Surface | Disposition | Reason |
|---|---|---|
| `package.json` and `package-lock.json` | Keep during transition | Markdown lint remains useful while documentation is changing. |
| `.markdownlint.json` | Keep during transition | Provides deterministic documentation validation. |
| `CONTRIBUTING.md` | Rewrite near completion | Contribution guidance must match the repository's final archived state. |
| `AGENTS.md` | Keep, then simplify | It protects the migration now; the archived repository will need a smaller historical notice. |

## Outcome

The active repository now retains only this migration documentation, the
read-only scanner and its tests, lint metadata, and basic repository files.
Reusable skills moved to `bens_indispensable_skills`; historical material
remains recoverable from Git.
