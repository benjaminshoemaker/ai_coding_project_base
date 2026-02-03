# AI Coding Project Toolkit

A structured framework for AI agents to build software autonomously—with verification, guardrails, and human oversight built in.

**[View Landing Page](https://benjaminshoemaker.github.io/ai_coding_project_base/)** · **[Example Project Output](https://github.com/benjaminshoemaker/calc-example)**

## TL;DR

**What is this?** A framework that turns ad-hoc AI prompting into a repeatable workflow with automatic verification.

**How does it work?** Three phases:

1. **Specify** — Guided Q&A produces `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Plan** — Generator creates `EXECUTION_PLAN.md` (tasks with testable acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execute** — AI agents work task-by-task with automatic verification after each one

**What makes execution robust?**

- **Code verification** — Multi-agent system checks each task against its acceptance criteria
- **TDD enforcement** — Verifies tests exist, were written first, and have meaningful assertions
- **Test quality gate** — Optional mutation testing and heuristic checks for weak tests
- **Security scanning** — Dependency audits, secrets detection, and static analysis at checkpoints
- **Stuck detection** — Agents escalate to humans instead of spinning on failures
- **Git workflow** — One branch per phase, one commit per task, human review before push

**Who is it for?** Developers who want AI agents to write code reliably, not just occasionally.

## Prerequisites

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude (primary interface)
- **Git** — Required for the branching and commit workflow

Codex CLI users: see [Codex Setup](docs/codex-cli.md).

Not using Claude Code? See [Manual Setup](docs/manual-setup.md) for copy-paste prompts.

## Quick Start

```bash
# 1. Clone the toolkit
git clone https://github.com/benjaminshoemaker/ai_coding_project_base.git
cd ai_coding_project_base

# Open this folder in Claude Code to use the slash commands

# 2. Generate specs and plan (from toolkit directory)
/product-spec ~/Projects/my-new-app
/technical-spec ~/Projects/my-new-app
/generate-plan ~/Projects/my-new-app   # Also copies execution skills to your project

# 3. Execute (from your project directory)
cd ~/Projects/my-new-app
/fresh-start                # Orient to project, load context
/configure-verification     # Set test/lint/build commands for your stack
/phase-prep 1               # Check prerequisites
/phase-start 1              # Execute Phase 1 (creates branch, commits per task)
/phase-checkpoint 1         # Run tests, security scan, verify completion
# Review changes, then: git push origin phase-1
```

For feature development in existing projects:

```bash
# From your project directory (after /setup):
/feature-spec analytics
/feature-technical-spec analytics
/feature-plan analytics
/fresh-start
/phase-start 1
```

See [Feature Workflow](docs/feature-workflow.md) for the complete guide.

## Workflow Overview

### Greenfield Projects

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPECIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Idea                                                             │
│       ↓                                                                 │
│   PRODUCT_SPEC_PROMPT  ──────→  PRODUCT_SPEC.md                         │
│       ↓                                                                 │
│   TECHNICAL_SPEC_PROMPT  ────→  TECHNICAL_SPEC.md                       │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   GENERATOR_PROMPT  ─────────→  EXECUTION_PLAN.md                       │
│                                  AGENTS.md                              │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXECUTION PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   /fresh-start  ────────────→  Orient to project, load context          │
│       ↓                                                                 │
│   /phase-start N  ──────────→  Execute phase (branch + commits)         │
│       ↓                                                                 │
│   /phase-checkpoint N  ─────→  Verify, test, security scan              │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Adding Features to Existing Projects

See [Feature Workflow](docs/feature-workflow.md) for the complete guide. The pattern is similar:

```
/feature-spec <name> → /feature-technical-spec <name> → /feature-plan <name> → /fresh-start → /phase-start
```

Feature commands run from your project directory (not the toolkit). Features are isolated in `features/<name>/` directories, enabling concurrent feature development.

## Commands Reference

### Generation Commands (run from toolkit directory)

| Command | Description |
|---------|-------------|
| `/product-spec [path]` | Generate product specification |
| `/technical-spec [path]` | Generate technical specification |
| `/generate-plan [path]` | Generate execution plan and AGENTS.md |
| `/verify-spec <type>` | Verify spec document for quality issues |

### Feature Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/feature-spec <name>` | Generate feature specification |
| `/feature-technical-spec <name>` | Generate feature technical specification |
| `/feature-plan <name>` | Generate feature execution plan |

### Setup Commands (run from toolkit directory)

| Command | Description |
|---------|-------------|
| `/setup [path]` | Initialize new project with toolkit structure |
| `/sync [path]` | Sync target project with latest toolkit skills |
| `/update-target-projects` | Discover and sync all toolkit-using projects at once |
| `/gh-init [path]` | Initialize git repo with smart .gitignore and optional GitHub remote |
| `/install-hooks [path]` | Install git hooks and session logging for workflow automation |

### Toolkit Maintenance (run from toolkit directory, not synced to projects)

| Command | Description |
|---------|-------------|
| `/analyze-sessions` | Analyze cross-project session logs for automation opportunities |
| `/vision-audit` | Audit vision alignment, research trends, generate feature proposals |

### Execution Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project, load context |
| `/configure-verification` | Set test/lint/build/auth commands for your stack |
| `/oauth-login <provider>` | Complete OAuth flow (Google/GitHub) for browser verification |
| `/phase-prep N` | Check prerequisites, preview future human items |
| `/phase-start N [--codex]` | Execute phase N (creates branch, commits per task). Use `--codex` to have Codex CLI execute tasks while Claude orchestrates. |
| `/phase-checkpoint N` | Local-first verification, then production checks |
| `/verify-task X.Y.Z` | Verify specific task acceptance criteria |
| `/criteria-audit [dir]` | Validate acceptance criteria metadata |
| `/security-scan` | Run security checks (deps, secrets, code) |
| `/codex-review` | Cross-model code review using Codex CLI |
| `/codex-consult` | Cross-model document consultation using Codex CLI |
| `/create-pr` | Create GitHub PR with automatic Codex review |
| `/progress` | Show progress through execution plan |
| `/list-todos` | Analyze, prioritize, and research TODO items with suggestions |
| `/run-todos` | Implement [ready]-tagged TODO items with commits |
| `/capture-learning` | Save project patterns to LEARNINGS.md |
| `/update-docs` | Sync documentation with code changes (auto or manual) |

See [Recovery Commands](docs/recovery-commands.md) for failure handling (`/phase-analyze`, `/phase-rollback`, `/task-retry`).

## What You Get

```
your-project/
├── PRODUCT_SPEC.md          # What you're building
├── TECHNICAL_SPEC.md        # How it's built
├── EXECUTION_PLAN.md        # Tasks with acceptance criteria
├── AGENTS.md                # Workflow rules for AI agents
├── LEARNINGS.md             # Discovered patterns (created as you work)
├── DEFERRED.md              # Deferred requirements (captured during Q&A)
├── .claude/
│   ├── skills/              # Execution skills (auto-copied)
│   ├── verification-config.json
│   └── toolkit-version.json # Tracks toolkit sync state
└── [your code]
```

These documents persist across sessions, enabling any AI agent to pick up where another left off.

`LEARNINGS.md` is created as you work—use `/capture-learning` to save project-specific patterns, conventions, and gotchas. The `/fresh-start` command loads these learnings into context for each new task.

`DEFERRED.md` is populated during specification Q&A. When you mention something is "out of scope," "v2," or "for later," the toolkit prompts you to capture it with clarifying context so nothing gets lost.

### Keeping Projects Updated

When the toolkit receives updates (new commands, improved skills, bug fixes), sync them to your projects:

```bash
# Sync all toolkit-using projects at once (from toolkit directory)
/update-target-projects

# Sync a specific project
/sync ~/Projects/my-app
```

**Note:** After committing skill changes to the toolkit, a post-commit hook reminds you to sync. Codex CLI skills are symlinked and update automatically.

The sync command:
- **Detects changes** by comparing file hashes against the last sync
- **Auto-applies** new files and clean updates (no local modifications)
- **Prompts for conflicts** when you've customized a file locally
- **Tracks state** in `.claude/toolkit-version.json`

| Change Type | Action |
|-------------|--------|
| New toolkit file | Auto-copy without prompting |
| Toolkit updated, no local changes | Auto-copy without prompting |
| Toolkit updated, local changes exist | Show diff, ask: overwrite / skip / backup |
| File removed from toolkit | Warn, offer to delete (default: keep) |

## Workflow Automation

### Auto-Advance

The toolkit automatically chains phase commands when no human intervention is required:

```
/phase-prep 1 → /phase-start 1 → /phase-checkpoint 1 → /phase-prep 2 → ...
      ↓              ↓                  ↓
  (if ready)    (if no manual)    (if all pass)
```

**Core Principle:** If AI completes verification → AI auto-advances. If human intervention is needed → human triggers the next step.

| Command | Auto-Advances To | Conditions |
|---------|------------------|------------|
| `/phase-prep N` | `/phase-start N` | All setup items pass (including human setup when complete) |
| `/phase-start N` | `/phase-checkpoint N` | All tasks complete, no truly manual checkpoint items |
| `/phase-checkpoint N` | `/phase-prep N+1` | All checks pass, no truly manual items, more phases exist |

Auto-advance executes immediately when conditions are met. No countdown or delay.

**Configuration** (`.claude/settings.local.json`):
```json
{
  "autoAdvance": {
    "enabled": true
  }
}
```

When auto-advance stops (manual items exist, check fails, or final phase complete), a session report shows all completed steps and any blocking issues.

### Cross-Model Verification (Codex)

When Codex CLI is installed, the toolkit automatically invokes Codex for second-opinion reviews at key points:

- **Generation commands** — `/product-spec`, `/technical-spec`, `/generate-plan`, `/feature-spec`, `/feature-technical-spec`, and `/feature-plan` all run `/codex-consult` after creating documents
- **Phase checkpoints** — `/phase-checkpoint` reviews completed phase code via `/codex-review`
- **Pull requests** — `/create-pr` runs Codex review before creating the PR, includes findings in the PR body, and blocks on critical issues

Codex researches current documentation before reviewing, which helps catch issues where Claude's training data may be outdated.

**Setup:**
```bash
# Install Codex CLI
npm install -g @openai/codex

# Authenticate
codex login
```

**Configuration** (`.claude/settings.local.json`):
```json
{
  "codexReview": {
    "enabled": true,
    "codeModel": "gpt-5.2-codex",
    "reviewTimeoutMinutes": 10
  },
  "codexConsult": {
    "enabled": true,
    "researchModel": "gpt-5.2",
    "consultTimeoutMinutes": 15
  }
}
```

Codex findings are advisory — they don't block auto-advance. You can also invoke `/codex-review` (code diffs), `/codex-consult` (documents), or `/create-pr` (PR with review) directly.

### Codex Task Execution

You can have Codex CLI execute tasks while Claude Code orchestrates:

```bash
/phase-start 1 --codex
```

**How it works:**
- Claude Code reads tasks and builds prompts
- Codex CLI executes each task (with web search for current docs)
- Claude Code verifies results and commits
- Auto-advance and state tracking work normally

**When to use `--codex`:**
- Tasks involve external APIs where current documentation matters
- You want cross-model execution for different perspectives
- Codex's web search during implementation adds value

**Configuration** (`.claude/settings.local.json`):
```json
{
  "codexReview": {
    "codeModel": "gpt-5.2-codex",
    "taskTimeoutMinutes": 60
  }
}
```

### Parallel Workstreams (Worktree Contract)

Run multiple AI agents in parallel using git worktrees. Each worktree gets isolated dependencies, env files, and dev server ports:

```bash
# Create a worktree for a feature
git worktree add ../my-feature -b feature/my-feature
cd ../my-feature

# Initialize it (installs deps, copies .env, symlinks settings)
bash .workstream/setup.sh

# Start dev server (auto-allocates a port unique to this worktree)
bash .workstream/dev.sh

# Run full quality gate before PR
bash .workstream/verify.sh
```

The `.workstream/` scripts are orchestrator-agnostic — they work with Codex App (worktree mode), Claude Code, Conductor, or manual usage. Each project can optionally create a `workstream.json` to configure dev commands, ports, and verification steps.

**Codex App:** Configure `bash .codex/setup.sh` as the setup script in Settings (Cmd+,) → Local Environments. When creating a worktree thread, select this environment and Codex will automatically get a ready-to-use workspace.

See `.workstream/README.md` for full documentation.

### Local-First Verification

Phase checkpoints run local verification first (tests, lint, security scan). Production verification (deployment, integration) only runs after local passes. This prevents wasted cycles on production checks when basic issues exist.

## How Verification Works

The toolkit enforces quality through multiple mechanisms:

- **Code Verification** — After each task, a sub-agent checks acceptance criteria. Tests must pass before the task is marked complete.
- **TDD Enforcement** — Verification checks that tests exist, were committed before implementation, and have meaningful assertions.
- **Security Scanning** — At checkpoints, the toolkit runs dependency audits, secrets detection, and static analysis. Critical issues block progress.
- **Spec Verification** — After generating specs, automatic verification ensures requirements flow through the document chain without loss.
- **Auto-Verify** — Before listing items as "manual," the toolkit attempts automation using available tools (curl, browser MCP, file inspection). Only truly subjective criteria (UX, brand tone) require human review.
- **Manual Verification Guides** — When human verification is required, the toolkit generates comprehensive step-by-step guides with prerequisites, exact commands, expected results, and troubleshooting tips.
- **Stuck Detection** — Agents escalate to humans after repeated failures instead of spinning forever.
- **Cross-Model Verification** — Optional second-opinion review using OpenAI Codex CLI. Codex researches current documentation before reviewing, catching blind spots from different training data.
- **Vercel Preview Integration** — Browser tests can run against Vercel preview deployments instead of localhost, providing real HTTPS and working OAuth callbacks.

### Vercel Preview URL Integration

For projects deployed to Vercel, browser verification can run against preview deployments instead of localhost:

**Benefits:**
- Real HTTPS environment (matches production)
- OAuth callbacks work correctly
- Tests production-like build output
- No need to run local dev server

**Setup:**
```bash
# During configure-verification, enable deployment verification
/configure-verification
# Answer "Yes" to "Do you deploy to Vercel?"
```

**How it works:**
1. Push changes to trigger Vercel deployment
2. Run `/phase-checkpoint` — it resolves the preview URL automatically
3. Browser tests run against `https://your-app-xyz.vercel.app`
4. If no preview found, falls back to localhost (configurable)

**Configuration in `.claude/verification-config.json`:**
```json
{
  "deployment": {
    "enabled": true,
    "service": "vercel",
    "useForBrowserVerification": true,
    "fallbackToLocal": true,
    "waitForDeployment": true,
    "deploymentTimeout": 300
  }
}
```

For detailed documentation, see [Verification Deep Dive](docs/verification.md).

## Git Workflow

During execution:
- **One branch per phase** — `phase-1`, `phase-2`, etc.
- **One commit per task** — Immediately after verification passes
- **No auto-push** — Human reviews at checkpoint before pushing

```
main
  └── phase-1
        ├── task(1.1.A): Add user model
        ├── task(1.1.B): Add user routes
        └── task(1.2.A): Add auth middleware
```

For feature development, branches nest: `main → feature/analytics → phase-1`.

## File Structure

```
ai_coding_project_base/
├── PRODUCT_SPEC_PROMPT.md           # Spec generation prompts
├── TECHNICAL_SPEC_PROMPT.md
├── GENERATOR_PROMPT.md
├── START_PROMPTS.md
├── .claude/
│   ├── skills/                      # All skills (create /slash-commands)
│   ├── commands/                    # Legacy command format (still works)
│   │   ├── auto-verify/             # Automation-before-manual logic
│   │   ├── browser-verification/    # Browser MCP verification
│   │   ├── code-verification/       # Multi-agent code verification
│   │   ├── oauth-login/             # OAuth flow for browser verification
│   │   ├── vercel-preview/          # Vercel preview URL resolution
│   │   └── ...                      # Security, tech-debt, etc.
│   └── hooks/                       # Git hooks + session logger template
├── .workstream/                     # Worktree setup/run/verify scripts
│   ├── lib.sh                       # Shared utility library
│   ├── setup.sh                     # Initialize worktree environment
│   ├── dev.sh                       # Start dev server on allocated port
│   ├── verify.sh                    # Run quality gate (fail-fast)
│   ├── workstream.json.example      # Config template
│   └── README.md                    # Full documentation
├── .codex/                          # Codex App integration
│   ├── setup.sh                     # Wrapper → .workstream/setup.sh
│   └── AGENTS.md                    # Codex thread instructions
├── docs/                            # Detailed documentation
├── extras/                          # Landing page, optional tools
└── AGENTS.md                        # Toolkit contributor guidelines
```

## Documentation

- [Codex App Workflows](CODEX_APP_WORKFLOWS.md) — Parallel workstreams with Codex App and Claude Code
- [Feature Workflow](docs/feature-workflow.md) — Adding features to existing projects
- [Verification Deep Dive](docs/verification.md) — TDD, security, spec verification details
- [Recovery Commands](docs/recovery-commands.md) — Handling failures and rollbacks
- [Web Interface Usage](docs/web-interfaces.md) — Using with ChatGPT, Claude web, etc.
- [Manual Setup](docs/manual-setup.md) — Copy-paste prompts for non-Claude-Code users
- [Advanced Topics](docs/advanced.md) — Brownfield support, AGENTS.md limits, optional tools
- [Codex CLI Setup](docs/codex-cli.md) — Using with OpenAI's Codex CLI

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.

```bash
npm run lint      # Check markdown
npm run lint:fix  # Auto-fix
```

## License

MIT
