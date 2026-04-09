---
description: Synchronize target projects with toolkit updates. Triggers after toolkit skill modifications.
argument-hint: [target-or-toolkit-path]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

Synchronize a target project with the latest toolkit skills.

## Workflow

Copy this checklist and track progress:

```
Sync Progress:
- [ ] Step 1: Detect sync direction (push/pull)
- [ ] Step 2: Resolve target project paths
- [ ] Step 3: Load current sync state
- [ ] Step 4: Detect changed files
- [ ] Step 5: Sync files to target
- [ ] Step 6: Update version tracking
- [ ] Step 7: Report sync results
```

## Direction Detection

Determine sync direction by checking for toolkit markers:

```bash
# Check if current directory is the toolkit
if [[ -f ".toolkit-marker" ]]; then
  SYNC_FROM="toolkit"  # Current dir is toolkit, $1 is target
else
  SYNC_FROM="target"   # Current dir is target, resolve toolkit location
fi
```

## Resolve Paths

### If running from toolkit (`SYNC_FROM="toolkit"`):
- `TOOLKIT_PATH` = current working directory
- `TARGET_PATH` = `$1` (required argument)
- If `$1` is empty, ask user for target directory path

### If running from target (`SYNC_FROM="target"`):
- `TARGET_PATH` = current working directory
- Resolve `TOOLKIT_PATH` in order:
  1. Use `$1` if provided
  2. Check `.claude/toolkit-version.json` → `toolkit_location`
  3. Check `$AI_TOOLKIT_PATH` environment variable
  4. Search common paths: `~/Projects/ai_coding_project_base`, `~/ai_coding_project_base`
  5. Ask user if none found

### Validate Paths
- Confirm `TOOLKIT_PATH` contains `.toolkit-marker` (toolkit marker)
- Confirm `TARGET_PATH` exists and is a directory
- If validation fails, **STOP** with clear error message

## Files to Sync

These files are synced from toolkit to target:

**Skills** (`.claude/skills/`):
All skill directories in the toolkit's `.claude/skills/` are synced automatically,
**excluding toolkit-only skills** (those with `toolkit-only: true` in SKILL.md frontmatter).
Skills are discovered dynamically — no hardcoded list.

```bash
# Discover all skills, excluding toolkit-only
for skill_dir in "$TOOLKIT_PATH/.claude/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  [[ "$skill_name" == .* ]] && continue
  # Skip toolkit-only skills (parse YAML frontmatter between --- markers)
  if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
    continue
  fi
  echo "$skill_name"
done
```

**Cleanup of toolkit-only skills in targets:** If a toolkit-only skill is found in the target,
treat it as an orphan and handle with the same safety rules (auto-delete if unmodified, prompt if modified).

**Config** (only if missing):
- `.claude/verification-config.json`

## Load Version State

Read `TARGET_PATH/.claude/toolkit-version.json` if it exists:

```json
{
  "schema_version": "1.0",
  "toolkit_location": "/path/to/toolkit",
  "toolkit_commit": "abc123...",
  "toolkit_commit_date": "2026-01-22T10:30:00Z",
  "last_sync": "2026-01-22T12:00:00Z",
  "files": {
    "skills/phase-start/SKILL.md": "sha256:...",
    "skills/phase-checkpoint/SKILL.md": "sha256:..."
  }
}
```

If the file doesn't exist, this is the first sync — treat all files as `NEVER_SYNCED`.

## Change Detection

For each file in the sync list, calculate hashes and classify.

**Hash calculation** (same pattern used in `/setup` Step 3a):
```bash
file_hash() { shasum -a 256 "$1" | cut -d' ' -f1; }
```

**Classification logic:**

| Condition | Status | Action |
|-----------|--------|--------|
| Toolkit hash = Target hash | `CURRENT` | Skip (already up to date) |
| Target file doesn't exist | `NEW` | Auto-copy |
| Toolkit changed, Target = Last synced hash | `CLEAN_UPDATE` | Auto-copy |
| Toolkit changed, Target ≠ Last synced hash | `LOCAL_MODIFIED` | Prompt user |
| No version file, Target ≠ Toolkit | `NEVER_SYNCED` | Prompt user |

## Interactive Sync

### 1. Show Toolkit Changes Summary

```bash
# Get commits since last sync
cd "$TOOLKIT_PATH"
git log --oneline "$LAST_SYNC_COMMIT"..HEAD -- .claude/skills
```

Display:
```
TOOLKIT UPDATES SINCE LAST SYNC
===============================
Last sync: 2026-01-15 (abc123)
Current:   2026-01-22 (def456)

Recent changes:
- def456 fix: phase-start auto-advance logic
- cde345 feat: add browser fallback chain
- bcd234 docs: clarify criteria-audit usage
```

### 2. Auto-Apply Safe Updates

For `NEW` and `CLEAN_UPDATE` files:
- Copy from toolkit to target without prompting
- Report what was updated

```
AUTO-APPLIED (no local changes)
===============================
+ .claude/skills/auto-verify/SKILL.md (NEW)
~ .claude/skills/phase-start/SKILL.md (CLEAN_UPDATE)
~ .claude/skills/browser-verification/SKILL.md (CLEAN_UPDATE)
```

### 3. Prompt for Conflicts

For `LOCAL_MODIFIED` and `NEVER_SYNCED` files, show diff and prompt:

```
LOCAL MODIFICATION DETECTED
===========================
File: .claude/skills/phase-start/SKILL.md

Your version differs from the toolkit version.
```

Show abbreviated diff (first 20 lines of changes):
```bash
diff -u "$TARGET_FILE" "$TOOLKIT_FILE" | head -40
```

Then ask:
```
How should I handle this file?
Options:
1. Overwrite with toolkit version
2. Keep local version (skip this file)
3. Backup local and overwrite (SKILL.md.local.YYYYMMDD)
4. Show full diff
```

### 4. Handle Removed Files

Check if any files in the version state no longer exist in toolkit:

```
FILES REMOVED FROM TOOLKIT
==========================
The following files no longer exist in the toolkit:
- .claude/skills/old-skill/SKILL.md

Options:
1. Delete from target (match toolkit)
2. Keep in target (may become stale)
```

Default: Keep (don't delete without confirmation).

## Update Version File

After sync completes, write `TARGET_PATH/.claude/toolkit-version.json`:

```json
{"schema_version":"1.0","toolkit_location":"{TOOLKIT_PATH}","toolkit_commit":"{HEAD}","toolkit_commit_date":"{ISO}","last_sync":"{ISO}","files":{"<rel_path>":{"hash":"{sha256}","synced_at":"{ISO}"}}}
```
<!-- Full structure: see /setup Step 4 for field descriptions and resolution tracking -->

**IMPORTANT:** The `files` object must include an entry for every `.md` file in every
synced skill directory, not just `SKILL.md` (e.g., `audit-skills` has `CRITERIA.md`
and `SCORING.md`). Use the `file_hash()` pattern above to hash each file and add it
with its relative path. This ensures conflict detection works for all supporting files.

Get toolkit commit info:
```bash
cd "$TOOLKIT_PATH"
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_DATE=$(git log -1 --format=%cI HEAD)
```

## Report

```
SYNC COMPLETE
=============
Toolkit: {TOOLKIT_PATH}
Target:  {TARGET_PATH}

Files synced: {count}
- New:           {count}
- Updated:       {count}
- Skipped:       {count}
- Conflicts:     {count resolved} / {count total}

Toolkit version: {commit} ({date})

{If any files were skipped due to local modifications}
NOTE: Some files with local modifications were skipped.
Run /sync again to review these files.
```

## Edge Cases

### Invalid Stored Toolkit Path

If `toolkit_location` in version file doesn't exist or isn't a valid toolkit:

```
TOOLKIT PATH INVALID
====================
Stored path: /old/path/to/toolkit
This path no longer contains a valid toolkit.

Please provide the current toolkit location:
```

Update `toolkit_location` in version file after successful sync.

### First Sync (No Version File)

Treat all differing files as `NEVER_SYNCED`:
- Show each file that differs
- Ask user to confirm overwrite or keep local
- Create version file after sync

### Partial Sync (Interrupted)

If sync is interrupted, the version file won't be updated.
Next sync will re-detect and re-apply needed changes (safe).

### Skills Directories

For skill directories, compare the `SKILL.md` file as the primary indicator:
- If `SKILL.md` changed → sync entire skill directory
- Use `cp -r` to copy skill directories

## Error Handling

| Situation | Action |
|-----------|--------|
| `shasum` command unavailable | Fall back to `md5` or file modification time for change detection. Report the fallback. |
| File copy failure (permissions, disk space) | Report the specific file and error. Continue syncing remaining files. |
| Git command failure in target project | Report the error. Do not force git operations — let the user resolve. |
