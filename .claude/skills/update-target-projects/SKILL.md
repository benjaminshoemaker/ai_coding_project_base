---
name: update-target-projects
description: Discover and sync all toolkit-using projects with the latest skills. Use when skills are modified, after the post-commit hook reminds you, or to batch-sync multiple projects.
toolkit-only: true
---

# Update Target Projects

Discover and sync all toolkit-using projects, the Codex CLI skill pack, and global Conductor skill symlinks with the latest skills.

## Trigger

Use this skill when:
- The post-commit hook reminds you to sync after skill changes
- You want to batch-sync multiple projects at once
- You need to check which projects are out of date
- You want to update the Codex CLI skill pack
- You want to verify global skill symlinks for Conductor autocomplete
- You want to sync curated skills to the public skills repo

## Configuration

**Codex skill pack location:**
1. `$CODEX_HOME/skills` if `CODEX_HOME` is set
2. `~/.codex/skills` (default)

**Project search paths:**
1. `$TOOLKIT_SEARCH_PATH` environment variable (colon-separated paths)
2. `~/Projects` (default)

**Search depth:** 4 levels (finds `~/Projects/*/`, `~/Projects/*/*/`, and `~/Projects/*/*/*/`)

**Global skills location:** `~/.claude/skills/` (symlinks for Conductor autocomplete)

**Public skills repo** (optional, `.claude/public-skills-config.json`):
```json
{
  "enabled": true,
  "path": "/path/to/awesome-claude-skills"
}
```
**Public skills manifest:** `.claude/public-skills-manifest.json` (lists curated skills to publish)

## Workflow

Copy this checklist and track progress:

```
Update Target Projects Progress:
- [ ] Phase 1: Discover projects with toolkit-version.json
- [ ] Phase 1b: Check Codex CLI skill pack status
- [ ] Phase 1c: Check global skill symlinks (Conductor autocomplete)
- [ ] Phase 1d: Detect orphaned skills (removed from toolkit)
- [ ] Phase 1e: Check workstream scripts status
- [ ] Phase 1f: Check skill resolution mode for each project
- [ ] Phase 1g: Check public skills repo status (if configured)
- [ ] Phase 2: Detect activity status for each project
- [ ] Phase 3: Check sync status (OUTDATED vs CURRENT)
- [ ] Phase 4: Display status report (including orphans, global status, and resolution)
- [ ] Phase 5: User selection (what to sync)
- [ ] Phase 6a: Sync Codex skill pack (if selected) — includes deletions
- [ ] Phase 6b: Sync global skill symlinks (if selected)
- [ ] Phase 6c: Sync target projects (if selected) — includes deletions
- [ ] Phase 6d: Sync workstream scripts (if selected)
- [ ] Phase 6g: Sync Codex App setup wrapper (if selected)
- [ ] Phase 6e: Adopt global skills (if selected) — migrate local to global
- [ ] Phase 6f: Revert to local skills (if selected) — copy from global back to project
- [ ] Phase 6h: Sync public skills repo (if selected)
- [ ] Phase 7: Generate summary report
```

### Phase 1: Discover Projects

See [PROJECT_SYNC.md](PROJECT_SYNC.md) for detailed discovery and sync logic.

1. Find all `toolkit-version.json` files in search paths
2. Read each file and verify `toolkit_location` matches
3. Extract `toolkit_commit` and `last_sync` timestamps

### Phase 1b: Check Codex CLI Skill Pack

See [CODEX_SYNC.md](CODEX_SYNC.md) for detailed Codex sync logic.

1. Discover skills dynamically from toolkit
2. Classify each skill: MISSING, SYMLINK_CURRENT, COPY_OUTDATED, etc.
3. Determine overall Codex status

### Phase 1c: Check Global Skill Symlinks

See [GLOBAL_SYNC.md](GLOBAL_SYNC.md) for detailed global sync logic.

1. Scan `~/.claude/skills/` for existing entries
2. Classify each: SYMLINK_CURRENT, MISSING, SYMLINK_OTHER, REAL_DIR
3. Detect orphaned symlinks (pointing to deleted toolkit skills)
4. Determine overall global status

### Phase 1e: Check Workstream Scripts Status

Detect `.workstream/` scripts in target projects and compare file hashes with toolkit:

1. Check if target has `.workstream/` directory
2. For each script (`lib.sh`, `setup.sh`, `dev.sh`, `verify.sh`, `README.md`):
   - Compare SHA256 hash with toolkit version
   - Classify: MISSING, CURRENT, OUTDATED
3. Check `workstream.json.example` separately (it's a reference, not a project file)
4. Track status in `toolkit-version.json` under a `"workstream"` key

Status determination:
- `MISSING` — no `.workstream/` directory in target
- `CURRENT` — all script hashes match toolkit
- `OUTDATED` — one or more scripts differ from toolkit

### Phase 1f: Check Skill Resolution Mode

For each target project, determine current skill resolution state:

See [GLOBAL_SYNC.md](GLOBAL_SYNC.md) for the full `check_project_resolution()` implementation.

Summary: reads `skill_resolution` and `force_local_skills` from `toolkit-version.json`,
counts local skill directories, checks global symlink health via `all_skills_globally_usable()`,
and returns one of the resolution states below.

| Resolution State | Meaning | Available Actions |
|------------------|---------|-------------------|
| `GLOBAL` | Using global symlinks (healthy) | Revert to local (option 9) |
| `LOCAL` | Local copies, globals not ready | Sync locally |
| `LOCAL_FORCED` | Local copies, `force_local_skills: true` | Sync locally (override active) |
| `ADOPTABLE` | Local, but global available | Adopt global (option 8) |
| `MISSING` | No local, no healthy global | ⚠️ Skills unavailable — run global sync first |

### Phase 1g: Check Public Skills Repo

See [PUBLIC_REPO_SYNC.md](PUBLIC_REPO_SYNC.md) for detailed public repo sync logic.

1. Read config from `.claude/public-skills-config.json`
2. If not configured or `enabled` is false, skip with status `NOT CONFIGURED`
3. Run pre-flight checks (path exists, is git repo, clean working tree)
4. Read `.claude/public-skills-manifest.json` for the list of curated skills
5. Validate all skill names match `^[a-z0-9-]+$`
6. Classify each skill: MISSING, CURRENT, OUTDATED, LOCAL_MODIFIED, UNMANAGED_PRESENT

### Phase 1d: Detect Orphaned Skills

Identify skills that exist in targets but have been removed from toolkit:

1. Compare installed skills against current toolkit skills
2. Mark as ORPHANED if skill directory no longer exists in toolkit
3. Check if orphaned skills have local modifications

See [CODEX_SYNC.md](CODEX_SYNC.md) and [PROJECT_SYNC.md](PROJECT_SYNC.md) for orphan detection logic.

### Phase 2-3: Activity and Sync Status

For each project:
- Classify activity: ACTIVE (uncommitted), RECENT (modified <24h), DORMANT
- Check if sync needed by comparing commits

### Phase 4: Display Status Report

```
TOOLKIT SYNC STATUS
===================
Toolkit: /path/to/toolkit
Current: abc1234 (2026-01-23)

GLOBAL SKILLS (Conductor Autocomplete)
───────────────────────────────────────
Location: ~/.claude/skills
Status:   CURRENT (30 symlinks active)

CODEX CLI SKILL PACK
────────────────────
Location: ~/.codex/skills
Status:   {status summary}

PUBLIC SKILLS REPO
──────────────────
Location: {path or "NOT CONFIGURED"}
Status:   {READY|NOT CONFIGURED|DIRTY|NOT A GIT REPO}
{If READY, show per-skill status table}

TARGET PROJECTS
───────────────
  #  Project          Sync Status   Resolution   Adoptable   Activity
  ─────────────────────────────────────────────────────────────────────
  1  ~/Projects/app   OUTDATED      local        ✓ (30 dirs) DORMANT
  2  ~/Projects/api   CURRENT       global       —           RECENT
  3  ~/Projects/lib   CURRENT       local        ⚠️ 2 modified ACTIVE
```

**Resolution column values:**
- `global` — Skills resolve via `~/.claude/skills/` symlinks
- `local` — Skills copied to project's `.claude/skills/`
- `mixed` — Some global, some local

**Adoptable column values:**
- `✓ (N dirs)` — Can adopt global resolution (N skill directories to remove)
- `⚠️ N modified` — Can adopt, but N skills have local modifications
- `—` — Already using global resolution (or not applicable)

### Phase 5: User Selection

Prompt with options:
1. Sync everything (Recommended) — includes public skills repo if configured
2. Global skill symlinks only
3. Codex skill pack only
4. Target projects only
5. Select specific items
6. Include ACTIVE projects too
7. Skip for now
8. Adopt global skills (remove local copies, switch to global resolution)
9. Revert to local skills (copy from global back to project)
10. Public skills repo only (visible only if enabled in `.claude/public-skills-config.json`)

**Option 8 visibility:** Only show if at least one project is `ADOPTABLE` (has local
copies and global symlinks are healthy).

**Option 9 visibility:** Only show if at least one project uses `global` resolution.

### Phase 6: Execute Sync

**6a: Codex Sync** — See [CODEX_SYNC.md](CODEX_SYNC.md)
**6b: Global Skills Sync** — See [GLOBAL_SYNC.md](GLOBAL_SYNC.md)
**6c: Project Sync** — See [PROJECT_SYNC.md](PROJECT_SYNC.md)

**6d: Workstream Scripts Sync** — Copy `.workstream/*.sh`, `README.md`, and `workstream.json.example` to target projects:

1. For each target project selected for sync:
   - Create `.workstream/` directory if missing
   - Copy scripts: `lib.sh`, `setup.sh`, `dev.sh`, `verify.sh`
   - Copy documentation: `README.md`, `workstream.json.example`
   - Run `chmod +x .workstream/*.sh`
   - Verify with `ls -la .workstream/*.sh` that scripts exist and have executable permissions.
2. Compare hashes before copying — skip if CURRENT
3. Update `toolkit-version.json` `"workstream"` key with new hashes. Read back the file to confirm valid JSON.
4. Do NOT copy or overwrite `workstream.json` (project-owned config)

**6g: Codex App Setup Wrapper Sync** — Copy `.codex/setup.sh` to target projects:

1. For each target project selected for sync:
   - Create `.codex/` directory if missing
   - Copy `setup.sh` from toolkit `.codex/setup.sh`
   - Run `chmod +x .codex/setup.sh`
   - Verify with `ls -la .codex/setup.sh` that the file exists and is executable.
2. Compare hashes before copying — skip if CURRENT
3. Do NOT overwrite `.codex/environments/` or other Codex App config (project-owned)

**6e: Adopt Global Skills** — Migrate from local to global resolution:

See [GLOBAL_SYNC.md](GLOBAL_SYNC.md) for state model and helper definitions.

**Pre-flight checks:**
1. Verify global health: `all_skills_globally_usable()` must return true
2. If unhealthy: abort with message "Global symlinks not healthy. Run sync first (option 1)."

**For each selected project:**

1. **Detect modified local skills** — skills where current hash != stored hash.
   See [GLOBAL_SYNC.md](GLOBAL_SYNC.md) for the full `find_modified_skills()` implementation.
   It compares each skill's current SHA-256 hash against the stored hash in `toolkit-version.json`
   and returns the list of skill names that differ.

2. **Show migration preview:**
   ```
   ADOPT GLOBAL SKILLS: ~/Projects/app
   ────────────────────────────────────
   Will remove:     30 skill directories
   Modified skills: 2 (will be backed up)
   After migration: Skills resolve via ~/.claude/skills/

   ⚠️  This project will no longer contain .claude/skills/.
       Collaborators without ~/.claude/skills/ will lose access.

   Proceed? [y/N]
   ```

3. **If user confirms:**
   - Back up modified skills to `.claude/skills.bak/{skill}/` (if any)
   - Verify with `ls .claude/skills.bak/` that backups were created before proceeding with deletion.
   - Delete local skill directories:
     ```bash
     # Note: glob must be OUTSIDE quotes to expand
     if [[ -d "$project_path/.claude/skills" ]]; then
       rm -rf "$project_path/.claude/skills/"*/
     fi
     ```
   - Verify with `ls "$project_path/.claude/skills/"` that skill directories were removed.
   - Update toolkit-version.json:
     - Set `"skill_resolution": "global"`
     - Set each file's `"resolution": "global"`
   - Read back `toolkit-version.json` to confirm valid JSON and that `skill_resolution` is `"global"`.
   - DO NOT use `git rm` — let user review and commit

4. **Report:**
   ```
   ✓ Migrated ~/Projects/app to global skill resolution
     Removed: 30 skill directories
     Backed up: 2 modified skills → .claude/skills.bak/
     Skills now resolve via: ~/.claude/skills/
   ```

**6f: Revert to Local Skills** — Copy from global back to project:

For projects that were migrated to global but need portability:

1. **Show revert preview:**
   ```
   REVERT TO LOCAL SKILLS: ~/Projects/app
   ───────────────────────────────────────
   Will copy:       30 skills from ~/.claude/skills/
   Target:          .claude/skills/
   After revert:    Skills copied locally for portability

   Proceed? [y/N]
   ```

2. **If user confirms:**
   - Create `.claude/skills/` directory
   - For each globally-resolved skill:
     - Copy from global symlink target to local
   - Verify with `ls .claude/skills/` that expected skill directories were copied.
   - Update toolkit-version.json:
     - Set `"skill_resolution": "local"`
     - Set each file's `"resolution": "local"`
     - Update hashes and timestamps
   - Read back `toolkit-version.json` to confirm valid JSON and that `skill_resolution` is `"local"`.

3. **Report:**
   ```
   ✓ Reverted ~/Projects/app to local skill resolution
     Copied: 30 skills to .claude/skills/
     Skills now resolve via: project-local copies
   ```

### Phase 6h: Sync Public Skills Repo

See [PUBLIC_REPO_SYNC.md](PUBLIC_REPO_SYNC.md) for detailed sync logic.

1. Read manifest from `.claude/public-skills-manifest.json`
2. For each skill in the manifest:
   - If MISSING or OUTDATED: wipe destination, `cp -r` from toolkit, remove `.DS_Store` files
   - If LOCAL_MODIFIED or UNMANAGED_PRESENT: warn and prompt before overwriting
   - If CURRENT: skip
3. Detect orphaned skills (tracked in `toolkit-version.json` but removed from manifest)
4. Update `toolkit-version.json` in public repo with new hashes
5. Stage managed paths: `git -C "$path" add skills/ toolkit-version.json`
6. Commit with sync summary
7. Prompt before push — never auto-push

### Phase 7: Summary Report

```
SYNC COMPLETE
=============

Global Skills (Conductor Autocomplete):
  Symlinks created: 2
  Symlinks removed: 1 (orphaned)
  Symlinks repaired: 0
  Already current:  28

Codex CLI Skill Pack:
  Skills updated:  3
  Skills deleted:  1 (orphaned)
  Already current: 12

Target Projects:
  Projects processed: 4
    Synced:  2
    Skipped: 1 (active)
    Current: 1
  Skills deleted: 1 (orphaned)

Public Skills Repo:
  Skills synced:   3 (2 updated, 1 added)
  Skills removed:  0
  Already current: 6
  Skipped:         0 (local modifications)
  Committed:       yes
  Pushed:          no (user declined)

Resolution Changes:
  Adopted global: 1 project (30 local dirs removed)
  Reverted local: 0 projects
  Modified backed up: 2 skills → .claude/skills.bak/

Deleted Skills (removed from toolkit):
  - multi-model-verify

All synced items are now at toolkit commit abc1234
```

**If projects were migrated:**
```
MIGRATION SUMMARY
─────────────────
Projects migrated to global resolution:
  ✓ ~/Projects/app (30 skills)
  ✓ ~/Projects/api (30 skills)

These projects now use ~/.claude/skills/ symlinks.
Local skill copies have been removed.

Note: Collaborators need ~/.claude/skills/ symlinks to access skills.
Run this from their toolkit clone: /update-target-projects → option 2
```

## Error Handling

| Situation | Action |
|-----------|--------|
| No `toolkit-version.json` files found in search paths | Report "No toolkit-using projects found in {search paths}" and list the paths searched; suggest running `/setup` first |
| `toolkit_location` in a project's `toolkit-version.json` points to a different toolkit | Skip that project with a warning; do not sync skills from a mismatched toolkit |
| `cp -r` or symlink creation fails during sync | Report the specific failure, continue syncing remaining items, include failures in the summary report |
| `rm -rf` fails during global adoption (option 8) | STOP adoption for that project, report permission error, do not update `toolkit-version.json` to `"global"` |
| `gh` or `git` commands fail during discovery | Report the error, skip affected projects, continue with remaining projects |
| Public skills repo path missing or not a git repo | Report specific pre-flight failure, skip public repo sync, continue with other sync operations |
| Public skills repo has dirty working tree | Report "public repo has uncommitted changes", skip public repo sync |
| Manifest skill name fails `^[a-z0-9-]+$` validation | Abort public repo sync entirely (path traversal risk) |
| Skill has local modifications in public repo | Warn and prompt before overwriting — never silently replace |

## Edge Cases

See [EDGE_CASES.md](EDGE_CASES.md) for handling:
- Codex directory doesn't exist
- No projects found
- Project uses different toolkit
- Git not available
- Public skills repo not configured / missing path / dirty / local modifications
- Sync conflicts

---

**REMINDER**: For projects using **local resolution**, always copy skills to target projects, not just update toolkit-version.json. The version file tracks state, but skills must actually be copied for changes to take effect. Projects using **global resolution** don't need local copies—they resolve via `~/.claude/skills/` symlinks.
