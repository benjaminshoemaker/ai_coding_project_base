# Command Reference

Complete list of slash commands provided by the toolkit.

## Generation Commands

Run from the **toolkit directory**. These produce specification and planning documents for a target project.

| Command | Description |
|---------|-------------|
| `/product-spec [path]` | Generate product specification via guided Q&A |
| `/technical-spec [path]` | Generate technical specification (requires `PRODUCT_SPEC.md`) |
| `/generate-plan [path]` | Generate execution plan and AGENTS.md (requires both specs) |
| `/verify-spec <type>` | Verify spec document for quality issues |

`/verify-spec` types: `technical-spec`, `execution-plan`, `feature-technical`, `feature-plan`, `feature-spec`

## Feature Commands

Run from your **project directory**. These produce feature-scoped documents in `features/<name>/`.

| Command | Description |
|---------|-------------|
| `/feature-spec <name>` | Generate feature specification via guided Q&A |
| `/feature-technical-spec <name>` | Generate feature technical spec (analyzes existing codebase) |
| `/feature-plan <name>` | Generate feature execution plan and AGENTS_ADDITIONS.md |

## Execution Commands

Run from your **project directory**. These drive the phase-based execution workflow.

| Command | Description |
|---------|-------------|
| `/go` | Resume execution from wherever you left off — detects state and runs the right command |
| `/fresh-start` | Orient to project, load context, detect resume state |
| `/phase-prep N` | Check prerequisites for phase N, preview future human items |
| `/phase-start N` | Execute phase N (creates branch, one commit per task) |
| `/phase-checkpoint N` | Run verification gate: tests, lint, security, then production checks |
| `/progress` | Report completion status of phases, tasks, and acceptance criteria |

Use `--pause` with any phase command to disable auto-advance. Use `--codex` with `/phase-start` to have Codex CLI execute tasks while Claude orchestrates.

## Verification Commands

Run from your **project directory**. These verify code, specs, and criteria quality.

| Command | Description |
|---------|-------------|
| `/verify-task X.Y.Z` | Verify a specific task's acceptance criteria |
| `/configure-verification` | Auto-detect and set test/lint/build/auth commands for your stack |
| `/criteria-audit [dir]` | Validate acceptance criteria metadata in EXECUTION_PLAN.md |
| `/security-scan` | Run dependency audits, secrets detection, and static analysis |
| `/tech-debt-check` | Identify duplication, complexity, large files, and maintainability anti-patterns |
| `/data-flow-audit` | Detect scattered business rules and split data sources |

`/security-scan` flags: `--deps` (dependencies only), `--secrets` (secrets only), `--code` (static analysis only), `--fix` (auto-fix where possible)

## Cross-Model Review Commands

Run from your **project directory**. These use OpenAI Codex CLI for second-opinion reviews.

| Command | Description |
|---------|-------------|
| `/codex-review [focus]` | Review current branch code diffs using Codex |
| `/codex-consult [file]` | Get Codex second opinion on documents, specs, or plans |
| `/create-pr [focus]` | Create GitHub PR with automatic Codex review |

`/codex-review` flags: `--upstream`, `--research`, `--base`, `--model`
`/codex-consult` flags: `--upstream`, `--research`, `--model`
`/create-pr` flags: `--skip-verify`, `--skip-review`, `--base`, `--title`, `--draft`

See [Codex CLI Setup](codex-cli.md) for installation and configuration.

## Setup Commands

Run from the **toolkit directory**. These initialize and sync projects.

| Command | Description |
|---------|-------------|
| `/setup [path]` | Initialize new project with toolkit skills and structure |
| `/sync [path]` | Sync a specific project with latest toolkit skills |
| `/update-target-projects` | Discover and sync all toolkit-using projects at once |
| `/gh-init [path]` | Initialize git repo with smart .gitignore and optional GitHub remote |
| `/install-hooks [path]` | Install git hooks and session logging for workflow automation |

## Project Utility Commands

Run from your **project directory**.

| Command | Description |
|---------|-------------|
| `/list-todos` | Analyze, prioritize, and research TODO items |
| `/run-todos` | Implement `[ready]`-tagged TODO items with commits |
| `/add-todo` | Add a formatted TODO item to TODOS.md |
| `/capture-learning` | Save project patterns and conventions to LEARNINGS.md |
| `/update-docs` | Sync documentation with recent code changes |
| `/populate-state` | Regenerate phase-state.json from EXECUTION_PLAN.md and git history |
| `/review-deferred` | Review and clear deferred verification items from the queue |
| `/oauth-login <provider>` | Complete OAuth flow (Google/GitHub) for browser verification |

## Toolkit-Only Commands

Run from the **toolkit directory**. These are not synced to target projects.

| Command | Description |
|---------|-------------|
| `/analyze-sessions` | Extract automation patterns from session logs and rank by impact |
| `/vision-audit` | Audit vision alignment, research trends, generate feature proposals |
| `/audit-skills` | Audit skills for best practice violations |

## Recovery Commands

These are optional and not installed by default. To enable:

```bash
cp extras/claude/commands/* .claude/commands/
```

| Command | Description |
|---------|-------------|
| `/phase-analyze N` | Analyze what went wrong in a phase |
| `/phase-rollback N` | Roll back to end of a completed phase (or specific task) |
| `/task-retry X.Y.Z` | Retry a failed task with fresh context |

See [Recovery Commands](recovery-commands.md) for detailed usage.
