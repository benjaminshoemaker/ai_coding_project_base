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

### Manual Installation

From the toolkit repo root:

```bash
./scripts/install-codex-skill-pack.sh
```

This creates symlinks from `~/.codex/skills/` to the toolkit's `.claude/skills/` directory.

Then restart Codex CLI.

### Installation Options

```bash
# Default: symlinks (recommended)
./scripts/install-codex-skill-pack.sh

# Force overwrite existing skills
./scripts/install-codex-skill-pack.sh --force

# Copy instead of symlink
./scripts/install-codex-skill-pack.sh --method copy

# Custom destination
./scripts/install-codex-skill-pack.sh --dest /custom/path/skills
```

### Symlinks vs Copy

The default installation uses symlinks. This means:
- Skills auto-update when you update the toolkit
- No need to reinstall after toolkit updates
- Single source of truth for skill definitions

If you use `--method copy`, you'll need to re-run with `--force` to get updates.

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

Codex researches current documentation before reviewing, which helps catch issues where Claude's training data may be outdated. Findings are advisory — they don't block auto-advance.

**Safety guard:** Both `/codex-review` and `/codex-consult` stash uncommitted changes and record the HEAD SHA before invoking Codex. After Codex finishes, any commits it made are reverted and the stash is restored. This prevents accidental modifications to the working tree during review/consultation.

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

1. Ensure the install script completed successfully
2. Restart Codex CLI completely
3. Verify skills exist in `~/.codex/skills/`
4. Check that symlinks point to valid paths: `ls -la ~/.codex/skills/`
