# AI Coding Project Toolkit

A structured framework for AI agents to build software autonomously — with verification, guardrails, and human oversight built in.

**[View Landing Page](https://benjaminshoemaker.github.io/ai_coding_project_base/)** · **[Example Project Output](https://github.com/benjaminshoemaker/calc-example)**

## What Is This?

A framework that turns ad-hoc AI prompting into a repeatable workflow with automatic verification. Three phases:

1. **Specify** — Guided Q&A produces `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Plan** — Generator creates `EXECUTION_PLAN.md` (tasks with testable acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execute** — AI agents work task-by-task with automatic verification after each one

**What makes execution robust?**

- **Code verification** — Multi-agent system checks each task against its acceptance criteria
- **TDD enforcement** — Verifies tests exist, were written first, and have meaningful assertions
- **Security scanning** — Dependency audits, secrets detection, and static analysis at checkpoints
- **Auto-advance** — Phases chain automatically when no human intervention is needed
- **Stuck detection** — Agents escalate to humans instead of spinning on failures
- **Cross-model review** — Optional second-opinion review using OpenAI Codex CLI

## Prerequisites

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude (primary interface)
- **Git** — Required for the branching and commit workflow

Codex CLI users: see [Codex CLI Setup](docs/codex-cli.md). Not using Claude Code? See [Manual Setup](docs/manual-setup.md).

## Quick Start

```bash
# 1. Clone the toolkit
git clone https://github.com/benjaminshoemaker/ai_coding_project_base.git
cd ai_coding_project_base

# 2. Generate specs and plan (from toolkit directory)
/product-spec ~/Projects/my-new-app
/technical-spec ~/Projects/my-new-app
/generate-plan ~/Projects/my-new-app

# 3. Execute (from your project directory)
cd ~/Projects/my-new-app
/fresh-start
```

`/fresh-start` loads context and auto-advances through `phase-prep → phase-start → phase-checkpoint` for each phase, stopping only when human input is needed. To resume later, run `/go` — it detects where you left off.

For feature development in existing projects, see [Feature Workflow](docs/feature-workflow.md).

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPECIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Idea                                                             │
│       ↓                                                                 │
│   /product-spec  ───────────→  PRODUCT_SPEC.md                          │
│       ↓                                                                 │
│   /technical-spec  ─────────→  TECHNICAL_SPEC.md                        │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   /generate-plan  ──────────→  EXECUTION_PLAN.md                        │
│                                 AGENTS.md                               │
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
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Key Commands

| Command | Description |
|---------|-------------|
| `/product-spec [path]` | Generate product specification |
| `/technical-spec [path]` | Generate technical specification |
| `/generate-plan [path]` | Generate execution plan and AGENTS.md |
| `/go` | Resume execution from wherever you left off |
| `/fresh-start` | Orient to project, load context, begin execution |
| `/phase-start N` | Execute phase N (creates branch, commits per task) |
| `/phase-checkpoint N` | Verify phase: tests, lint, security, then production checks |
| `/verify-task X.Y.Z` | Verify a specific task's acceptance criteria |
| `/create-pr` | Create GitHub PR with automatic Codex review |

See [Command Reference](docs/commands.md) for the full list including feature, setup, verification, and recovery commands.

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

## Documentation

- [Command Reference](docs/commands.md) — Full list of all slash commands with options
- [Feature Workflow](docs/feature-workflow.md) — Adding features to existing projects
- [Workflow Automation](docs/workflow-automation.md) — Auto-advance, git workflow, parallel workstreams, project syncing
- [Verification Deep Dive](docs/verification.md) — TDD, security scanning, browser verification, spec verification
- [Codex CLI Setup](docs/codex-cli.md) — Cross-model review, Codex task execution, installation
- [Codex App Workflows](CODEX_APP_WORKFLOWS.md) — Parallel workstreams with Codex App and Claude Code
- [Recovery Commands](docs/recovery-commands.md) — Handling failures and rollbacks
- [Advanced Topics](docs/advanced.md) — Brownfield support, AGENTS.md limits, optional tools
- [Web Interface Usage](docs/web-interfaces.md) — Using with ChatGPT, Claude web, etc.
- [Manual Setup](docs/manual-setup.md) — Copy-paste prompts for non-Claude-Code users

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

```bash
npm run lint      # Check markdown
npm run lint:fix  # Auto-fix
```

## License

MIT
