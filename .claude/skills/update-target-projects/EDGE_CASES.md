# Edge Cases

## Codex Skills Directory Doesn't Exist

If `~/.codex/skills` (or `$CODEX_HOME/skills`) doesn't exist:

```
CODEX CLI SKILL PACK
────────────────────
Location: ~/.codex/skills
Status:   DIRECTORY NOT FOUND

Codex CLI may not be installed, or uses a different skills location.

To install skills anyway:
  ./scripts/install-codex-skill-pack.sh

To specify a custom location:
  export CODEX_HOME=/path/to/codex
```

Skip Codex syncing unless user explicitly requests installation.

## No Projects Found

```
No toolkit-using projects found in ~/Projects

To set up a project with this toolkit:
1. Navigate to your project directory
2. Run /setup or /generate-plan

To search additional paths, set:
  export TOOLKIT_SEARCH_PATH="~/Projects:~/work"
```

## Project Points to Different Toolkit

Skip silently — it's using a different toolkit installation.

## Git Not Available in Project

```
Warning: ~/Projects/legacy-app is not a git repository
  Cannot detect activity status - treating as DORMANT
```

## Public Skills Repo Not Configured

If `publicSkillsRepo` is missing from `.claude/settings.local.json` or `enabled` is false:

```
PUBLIC SKILLS REPO
──────────────────
Status: NOT CONFIGURED (create .claude/public-skills-config.json)
```

Skip public repo sync silently. Option 10 is hidden from the menu.

## Public Skills Repo Path Missing or Not a Git Repo

```
PUBLIC SKILLS REPO
──────────────────
Location: /path/to/awesome-claude-skills
Status:   ERROR — path does not exist
```

Or:
```
Status:   ERROR — not a git repository
```

Report the specific failure and skip public repo sync. Continue with other sync operations.

## Public Skills Repo Has Dirty Working Tree

```
PUBLIC SKILLS REPO
──────────────────
Location: /path/to/awesome-claude-skills
Status:   DIRTY — uncommitted changes detected

Commit or stash changes in the public repo before syncing.
```

Skip public repo sync. Do not attempt to commit over dirty state.

## Public Repo Skill Has Local Modifications

If a skill in the public repo has been edited since the last sync (hash differs from both toolkit and last-synced):

1. Show which files changed
2. Ask user: Overwrite with toolkit version / Keep public repo version / Show diff
3. Never silently overwrite

## Public Repo Has Unmanaged Skills

If a skill directory exists in the public repo but was not synced from the toolkit (no entry in `toolkit-version.json`):

1. Warn: "Skill `{name}` exists in public repo but was not synced from toolkit"
2. Ask: Overwrite / Keep existing
3. Do not add to `toolkit-version.json` unless user chooses to overwrite

## Public Repo Has No Upstream Remote

If `git -C "$path" remote get-url origin` fails, the push prompt is skipped.
Commit still happens locally.

## Sync Conflicts

If a project has local modifications to skills that differ from both the last-synced version AND the toolkit version:

1. Show the conflict with diff
2. Ask user:
   - Backup local and overwrite
   - Keep local version
   - Show full diff
3. Follow standard `/sync` conflict resolution flow
