# Codex CLI Setup

This toolkit includes a Codex CLI skill pack that provides the same execution workflow as Claude Code.

## Architecture

Both Claude Code and Codex CLI use the same skill files from `.claude/skills/`. This ensures:
- Single source of truth for all skill definitions
- Feature parity between platforms (including auto-advance)
- Easier maintenance and updates

The skills follow the [Agent Skills open standard](https://developers.openai.com/codex/skills/), which both platforms support. Claude Code-specific fields (like `allowed-tools`) are simply ignored by Codex.

## Prerequisites

```bash
# Install Codex CLI
npm install -g @openai/codex

# Authenticate
codex login
```

## Installation

### Recommended Bootstrap (Skills + MCPs)

From the toolkit repo root:

```bash
./scripts/bootstrap-agent-runtime.sh
```

This configures both agents in one run:

- Installs toolkit skills into:
  - `~/.claude/skills/` (Claude Code personal skills)
  - `~/.agents/skills/` (Codex user skills path)
- Maintains compatibility shim: `~/.codex/skills -> ~/.agents/skills` when `~/.codex/skills` is not already in use
- Applies MCP servers from `config/mcp/servers.json` to both `claude-code` and `codex` via `add-mcp`

Then restart Claude Code and Codex CLI.

### Bootstrap Options

```bash
# Default: symlink skills + apply MCP manifest + normalize existing MCPs
./scripts/bootstrap-agent-runtime.sh

# Show planned changes only
./scripts/bootstrap-agent-runtime.sh --dry-run

# Check-only mode (non-zero exit on skill drift)
./scripts/bootstrap-agent-runtime.sh --check

# Replace conflicting skill paths
./scripts/bootstrap-agent-runtime.sh --force

# Adopt conflicting external skill paths (opt-in, requires --force)
./scripts/bootstrap-agent-runtime.sh --force --adopt-unmanaged-skills

# Copy skills instead of symlink
./scripts/bootstrap-agent-runtime.sh --method copy

# Replace existing ~/.codex/skills with compatibility shim (opt-in, requires --force)
./scripts/bootstrap-agent-runtime.sh --force --adopt-codex-shim

# Override MCP manifest location
./scripts/bootstrap-agent-runtime.sh --manifest /path/to/servers.json

# Manifest-only MCP apply (skip add-mcp sync normalization)
./scripts/bootstrap-agent-runtime.sh --no-normalize-existing
```

### Legacy Codex-Only Install Script (Backward Compatibility)

If you only want Codex skills (without shared bootstrap), you can still use:

```bash
./scripts/install-codex-skill-pack.sh
```

This script remains supported for existing workflows.

### Skill Install Methods

The default bootstrap uses per-skill symlinks. This means:
- Skills auto-update when you update the toolkit
- No need to reinstall after toolkit updates
- Single source of truth for skill definitions
- Existing non-toolkit skills are preserved by default (no overwrite)

If you use `--method copy`, re-run with `--force` to refresh copied skills.

### New Skills

Symlinks are created per-skill, not for the entire skills directory:

| Change | Auto-updates? |
|--------|:-------------:|
| Skill content modified | ✅ Yes (with symlinks) |
| New skill added to toolkit | ❌ No — re-run needed |
| Skill renamed | ❌ No — re-run needed |

## Usage

In any target project directory, you can use the same commands:

```bash
/fresh-start
/phase-prep 1
/phase-start 1
/phase-checkpoint 1
```

## Available Skills

The Codex skill pack includes:

| Skill | Description |
|-------|-------------|
| `/fresh-start` | Orient to project, load context |
| `/phase-prep N` | Check prerequisites for phase N |
| `/phase-start N` | Execute phase N (with auto-advance) |
| `/phase-checkpoint N` | Run tests, security scan, verify completion |
| `/verify-task X.Y.Z` | Verify specific task |
| `/configure-verification` | Set up verification commands |
| `/progress` | Show execution progress |
| `/populate-state` | Generate phase-state.json |
| `/list-todos` | Analyze and prioritize TODOs |
| `/security-scan` | Run security checks |
| `/criteria-audit` | Audit execution plan criteria |

Plus supporting skills:
- `code-verification` — Multi-agent verification workflow
- `browser-verification` — Browser-based UI verification
- `spec-verification` — Specification document verification
- `tech-debt-check` — Technical debt analysis
- `auto-verify` — Attempt automation before manual verification

## Feature Parity

Both platforms now support:
- ✅ Auto-advance between phases
- ✅ Auto-verify for manual items
- ✅ Browser verification fallback chain
- ✅ State tracking in `.claude/phase-state.json`
- ✅ Verification logging

## Differences from Claude Code

The skill files are identical, but runtime behavior may differ:

- MCP tool detection may behave differently between platforms
- Some Claude Code features (like `allowed-tools` permission scoping) are ignored by Codex
- Subagent execution (`context: fork`) may work differently

## Cross-Model Review Configuration

When Codex CLI is installed, the toolkit automatically invokes it for second-opinion reviews at key points:

- **Generation commands** — `/product-spec`, `/technical-spec`, `/generate-plan`, and all feature commands run `/codex-consult` after creating documents
- **Phase checkpoints** — `/phase-checkpoint` reviews completed phase code via `/codex-review`
- **Pull requests** — `/create-pr` runs Codex review before creating the PR, includes findings in the PR body, and blocks on critical issues

Codex researches current documentation before reviewing, which helps catch issues where Claude's training data may be outdated.
Findings are auto-implemented during checkpoints: a Task subagent applies fixes, re-runs verification, and commits if passing (or reverts if not).
This keeps the auto-advance chain flowing without human intervention.

**Safety guard:** `/codex-review` and `/codex-consult` record the HEAD SHA before invoking Codex. After Codex finishes, any commits it made are reverted. This prevents accidental modifications to the working tree during review/consultation.

**Configuration** (`.claude/settings.local.json`):
```json
{
  "codexReview": {
    "enabled": true,
    "codeModel": "gpt-5.3-codex",
    "reviewTimeoutMinutes": 20
  },
  "codexConsult": {
    "enabled": true,
    "researchModel": "gpt-5.2",
    "consultTimeoutMinutes": 20
  }
}
```

You can also invoke `/codex-review` (code diffs), `/codex-consult` (documents), or `/create-pr` (PR with review) directly at any time.

## Codex Task Execution

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
    "codeModel": "gpt-5.3-codex",
    "taskTimeoutMinutes": 60
  }
}
```

## Troubleshooting

If commands aren't recognized after installation:

1. Ensure bootstrap completed successfully: `./scripts/bootstrap-agent-runtime.sh --check`
2. Restart Claude Code and Codex CLI completely
3. Verify skills exist in `~/.claude/skills/` and `~/.agents/skills/`
4. Verify compatibility shim: `ls -la ~/.codex/skills/`
5. Verify MCP manifest plan: `./scripts/sync-agent-mcps.sh --check`
