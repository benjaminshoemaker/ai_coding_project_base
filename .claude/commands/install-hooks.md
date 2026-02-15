---
description: Install git hooks for this project. Use during project setup or after cloning to install automation hooks.
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Install git hooks to enhance the development workflow.

## Available Hooks

| Hook | Purpose | When It Runs |
|------|---------|--------------|
| `pre-push-doc-check` | Warns if docs may need updating | Before `git push` |
| `post-commit-sync-check` | Reminds to sync target projects | After `git commit` |
| `post-commit-doc-update` | Triggers `/update-docs` automatically | After `git commit` |
| `session-end-logger` | Logs all Claude Code sessions for analysis | After every session (user-level) |

## Steps

Copy this checklist and track progress:

```
Install Hooks Progress:
- [ ] Step 1: Verify git repository exists
- [ ] Step 2: List available hooks
- [ ] Step 3: Install selected hooks
- [ ] Step 4: Report installation results
```

### 1. Verify Git Repository

```bash
git rev-parse --git-dir
```

If not a git repository, **STOP** and report: "Not a git repository. Run /gh-init first."

### 2. List Available Hooks

Show the user which hooks are available:

```
AVAILABLE HOOKS
===============

1. pre-push-doc-check
   Purpose: Warns when skills/prompts change without documentation updates
   Checks: .claude/skills/, .claude/commands/, *PROMPT*.md
   Against: README.md, docs/*.md, AGENTS.md

2. post-commit-sync-check (toolkit only)
   Purpose: Reminds to sync target projects when skills are modified
   Checks: .claude/skills/*.md changes in commits
   Action: Displays reminder to run /update-target-projects

3. post-commit-doc-update (recommended for all projects)
   Purpose: Auto-updates documentation after commits
   Checks: Skills, config, and structural changes
   Action: Creates marker for /update-docs to process

4. session-end-logger (user-level, recommended)
   Purpose: Logs all Claude Code sessions for automation analysis
   Scope: ALL projects (installed at ~/.claude/ level)
   Action: Enables /analyze-sessions to discover cross-project patterns
   Note: Must confirm in /hooks UI after installation

Select hooks to install: [1] [2] [3] [4] [All] [None]
```

**Note:** Hooks 2 and 3 both use the `post-commit` git hook. If installing both,
they will be combined into a single dispatcher script.

**Note:** Hook 4 (session-end-logger) is a user-level Claude Code hook, not a git hook.
It is installed to `~/.claude/hooks/` and configured in `~/.claude/settings.json`.

### 3. Install Selected Hooks

For each selected hook, create a symlink from `.git/hooks/` to `.claude/hooks/`:

```bash
# For pre-push hook
ln -sf ../../.claude/hooks/pre-push-doc-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push

# For post-commit hook (single hook)
ln -sf ../../.claude/hooks/post-commit-sync-check.sh .git/hooks/post-commit
# OR
ln -sf ../../.claude/hooks/post-commit-doc-update.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit
```

**Combining multiple post-commit hooks:**

If both `post-commit-sync-check` and `post-commit-doc-update` are selected,
create a dispatcher script:

```bash
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash
# Combined post-commit hook dispatcher

REPO_ROOT=$(git rev-parse --show-toplevel)

# Run sync check (toolkit only)
if [ -f "$REPO_ROOT/.claude/hooks/post-commit-sync-check.sh" ]; then
    "$REPO_ROOT/.claude/hooks/post-commit-sync-check.sh"
fi

# Run doc update
if [ -f "$REPO_ROOT/.claude/hooks/post-commit-doc-update.sh" ]; then
    "$REPO_ROOT/.claude/hooks/post-commit-doc-update.sh"
fi
EOF
chmod +x .git/hooks/post-commit
```

**Note:** If a hook already exists at the destination:
- Check if it's a symlink to our hook (already installed)
- If it's a different file, warn and ask to backup/overwrite

### 4. Report Installation

```
HOOKS INSTALLED
===============

✓ pre-push → .claude/hooks/pre-push-doc-check.sh
✓ post-commit → .claude/hooks/post-commit-sync-check.sh

Hooks are now active. They will run automatically during git operations.

To uninstall: rm .git/hooks/<hook-name>
To bypass temporarily: git commit --no-verify  OR  git push --no-verify
```

## Hook Details

### pre-push-doc-check

**What it checks:**

| Files Changed | Documentation Expected |
|---------------|----------------------|
| `.claude/skills/*.md` | README.md or docs/*.md should be updated |
| `.claude/commands/*.md` | README.md or docs/*.md (legacy format) |
| `*PROMPT*.md` | README.md or docs/*.md |

**Behavior:**
- Analyzes commits in the push range
- If documentation may be stale, shows warning
- Prompts to continue or abort (interactive mode)
- In non-interactive mode, warns but allows push

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║           DOCUMENTATION SYNC CHECK - WARNING                   ║
╚════════════════════════════════════════════════════════════════╝

The following changes may require documentation updates:

  - Skills changed but README.md not updated:
      .claude/skills/new-skill/SKILL.md
      .claude/skills/phase-start/SKILL.md

Consider updating:
  - README.md (command list, file structure)
  - docs/*.md (detailed documentation)
  - AGENTS.md (if behavior changes affect agent instructions)

Continue with push anyway? [y/N]:
```

### post-commit-sync-check

**What it checks:**

| Files Changed | Action |
|---------------|--------|
| `.claude/skills/*.md` | Displays sync reminder |

**Behavior:**
- Analyzes the just-committed files
- If skills were modified, shows a reminder box
- Suggests running `/update-target-projects`
- Non-blocking (never prevents commits)

**Example output:**
```
╭─────────────────────────────────────────────────────────────╮
│              TOOLKIT SYNC REMINDER                          │
╰─────────────────────────────────────────────────────────────╯

Skills modified:
  .claude/skills/phase-start/SKILL.md
  .claude/skills/progress/SKILL.md

Projects using this toolkit may need syncing.

To discover and sync target projects, run:
  /update-target-projects

Or sync a specific project:
  /sync /path/to/project
```

## Uninstalling Hooks

To remove installed hooks:

```bash
rm .git/hooks/pre-push      # Remove pre-push hook
rm .git/hooks/post-commit   # Remove post-commit hook
```

To bypass hooks temporarily:

```bash
git commit --no-verify  # Skip post-commit hooks for this commit only
git push --no-verify    # Skip pre-push hooks for this push only
```

### session-end-logger

**Scope:** User-level (not a git hook — a Claude Code SessionEnd hook)

**What it does:**
- Logs every Claude Code session to `~/.claude/logs/sessions.jsonl`
- Records session_id, timestamp, project name, cwd, and transcript path
- Enables `/analyze-sessions` to discover automation patterns across all projects

**Installation (different from git hooks):**

```bash
# Create hooks directory
mkdir -p ~/.claude/hooks

# Copy hook script
cp .claude/hooks/session-end-logger.sh ~/.claude/hooks/session-end-logger.sh
chmod +x ~/.claude/hooks/session-end-logger.sh
```

Then add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "SessionEnd": [{
      "hooks": [{
        "type": "command",
        "command": "bash $HOME/.claude/hooks/session-end-logger.sh",
        "timeout": 30
      }]
    }]
  }
}
```

**Important:** After installation, you must confirm the new hook in the Claude Code
`/hooks` UI.

**Report:**
```
SESSION LOGGING INSTALLED
=========================

Hook: ~/.claude/hooks/session-end-logger.sh
Config: ~/.claude/settings.json (SessionEnd hook added)
Log file: ~/.claude/logs/sessions.jsonl

Session logging is now active for ALL Claude Code projects.
Run /analyze-sessions to discover automation opportunities.

IMPORTANT: Confirm the hook in the /hooks UI.
```

**Removing:**
1. Delete `~/.claude/hooks/session-end-logger.sh`
2. Remove the `hooks.SessionEnd` entry from `~/.claude/settings.json`

### post-commit-doc-update

**What it does:**

Creates a marker file (`.claude/doc-update-pending.json`) that signals Claude
to run `/update-docs` automatically after each commit.

**When it triggers:**
- After any commit with non-documentation changes
- Skipped for commits with `[skip-docs]` in the message
- Skipped for `docs:` prefixed commits (prevents loops)

**Example output:**
```
╭─────────────────────────────────────────────────────────────╮
│            DOCUMENTATION SYNC PENDING                       │
╰─────────────────────────────────────────────────────────────╯

Commit abc123d may require documentation updates.

  Skills changed: 2
  Config changed: 1

Claude will run /update-docs automatically.
To skip: add [skip-docs] to commit message
```

**Marker file format:**
```json
{
  "timestamp": "2026-01-27T10:30:00Z",
  "commit": "abc123...",
  "commit_short": "abc123d",
  "message": "feat: add new feature",
  "trigger": "post-commit",
  "changes": {
    "skills": 2,
    "config": 1,
    "structure": 0,
    "total_files": 5
  }
}
```

**How Claude processes it:**
1. Detects `.claude/doc-update-pending.json` exists
2. Runs `/update-docs` to analyze the commit
3. Updates README, CHANGELOG, docs/ as needed
4. Creates a follow-up `docs:` commit
5. Deletes the marker file
