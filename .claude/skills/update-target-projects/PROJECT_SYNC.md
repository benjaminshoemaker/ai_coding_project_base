# Target Project Sync

## Discover Projects

```bash
SEARCH_PATH="${TOOLKIT_SEARCH_PATH:-$HOME/Projects}"
TOOLKIT_PATH="$(pwd)"
CURRENT_COMMIT=$(git rev-parse HEAD)

# Find all projects with toolkit-version.json
find "$SEARCH_PATH" -maxdepth 4 -name "toolkit-version.json" -path "*/.claude/*" 2>/dev/null
```

## Shared Repo Detection

Before classifying skills, detect if the project is shared (requires local copies for portability):

```bash
is_shared_repo() {
  local project_path="$1"

  # Has git remote?
  if git -C "$project_path" remote -v 2>/dev/null | grep -q .; then
    return 0
  fi

  # In CI environment?
  if [[ -n "$CI" || -n "$GITHUB_ACTIONS" || -n "$GITLAB_CI" || -n "$JENKINS_URL" ]]; then
    return 0
  fi

  return 1
}
```

| Indicator | Meaning | Default Behavior |
|-----------|---------|------------------|
| Has git remote | Project likely shared with collaborators | Use local copies |
| CI environment | Running in automation | Use local copies |
| No indicators | Local-only project | Can use global resolution |

**Warning output (when shared repo detected):**
```
⚠️  Shared repo detected (has git remote).
    Using local skill copies for portability.
    Set "force_local_skills": false to override.
```

For each discovered project:
1. Read `.claude/toolkit-version.json`
2. Verify `toolkit_location` matches current toolkit (skip if different)
3. Extract `toolkit_commit` and `last_sync` timestamps

## Activity Detection

```bash
detect_activity() {
  local project_path="$1"

  # ACTIVE: Has uncommitted changes
  if [ -n "$(git -C "$project_path" status --porcelain 2>/dev/null)" ]; then
    echo "ACTIVE"
    return
  fi

  # RECENT: Files modified in last 24 hours
  if find "$project_path" -maxdepth 3 -type f -mtime -1 \
       -not -path '*/node_modules/*' \
       -not -path '*/.git/*' \
       -not -name '*.log' 2>/dev/null | head -1 | grep -q .; then
    echo "RECENT"
    return
  fi

  echo "DORMANT"
}
```

| Status | Meaning | Default Action |
|--------|---------|----------------|
| `ACTIVE` | Uncommitted git changes | Skip (ask first) |
| `RECENT` | Modified in last 24h | Include with note |
| `DORMANT` | No recent activity | Safe to sync |

## Sync Status Check

```bash
LAST_COMMIT="<from toolkit-version.json>"
CURRENT_COMMIT=$(git rev-parse HEAD)

if [ "$LAST_COMMIT" != "$CURRENT_COMMIT" ]; then
  SKILL_CHANGES=$(git diff --name-only "$LAST_COMMIT".."$CURRENT_COMMIT" -- .claude/skills 2>/dev/null | wc -l)
  WORKSTREAM_CHANGES=$(git diff --name-only "$LAST_COMMIT".."$CURRENT_COMMIT" -- .workstream 2>/dev/null | wc -l)
  if [ "$SKILL_CHANGES" -gt 0 ] || [ "$WORKSTREAM_CHANGES" -gt 0 ]; then
    echo "OUTDATED"
  else
    echo "CURRENT"
  fi
else
  echo "CURRENT"
fi
```

## Skill Classification Flow

For each skill being synced, follow this classification logic:

```
0. Check if shared repo (has git remote or in CI)
   → if is_shared_repo() AND force_local_skills is NOT explicitly false:
     force local resolution, show warning, skip global checks

1. Check force_local_skills override in toolkit-version.json
   → if true, skip global check entirely (always copy locally)
   → if false, force global resolution (user explicitly wants global)

2. Check if this is a NEW project (no existing .claude/skills/)
   → if new AND is_globally_usable(skill_name):
     classify as GLOBAL_USABLE — skip copy, record resolution "global"

3. Check if EXISTING project with local copies
   → if local copy exists: continue syncing locally (preserve shadowing)
   → classification falls through to existing CURRENT/NEW/CLEAN_UPDATE/LOCAL_MODIFIED

4. (Existing logic) Hash-based classification for local copies
```

**Shared repo handling in code:**
```bash
# At start of classification for each project
if is_shared_repo "$project_path"; then
  local force_local=$(jq -r '.force_local_skills // null' "$version_file" 2>/dev/null)
  if [[ "$force_local" != "false" ]]; then
    # Auto-enable local mode for shared repos
    echo "⚠️  Shared repo detected. Using local skill copies for portability."
    FORCE_LOCAL_RESOLUTION=true
  fi
fi
```

### Classification Table (Updated)

| Condition | Classification | Action |
|-----------|----------------|--------|
| New project, globally usable | `GLOBAL_USABLE` | Skip copy, record "global" |
| Existing project, local copy exists | (use existing logic) | Sync locally |
| Target doesn't exist, not global | `NEW` | Copy from toolkit |
| Target hash = Toolkit hash | `CURRENT` | Skip (already up to date) |
| Target hash = Stored hash | `CLEAN_UPDATE` | Copy from toolkit |
| Target hash ≠ Stored hash | `LOCAL_MODIFIED` | Skip with warning |

## Sync Execution

For each selected project:

```
[1/3] ~/Projects/my-app
      Checking files...
      Copying skills...
      Removing orphaned skills...
      Updating toolkit-version.json...
      Done (5 files updated, 1 deleted)
```

**Sync Logic (for each project):**

1. Change working context to target project
2. **Check resolution mode** — read `force_local_skills` and `skill_resolution` from toolkit-version.json
3. **Detect orphaned skills** — skills in target that no longer exist in toolkit
4. For each skill in the sync list, compare hashes:
   - If toolkit hash = target hash: skip (current)
   - If target missing: copy from toolkit (new)
   - If target = last-synced hash: copy from toolkit (clean update)
   - If target differs from last-synced: report conflict (ask user)
5. **Delete orphaned skills** (with user confirmation if locally modified)
6. Update `toolkit-version.json` with new commit, hashes, and removed skills

**Skills to sync:** All skills from `.claude/skills/` are synced dynamically, **excluding toolkit-only skills** (those with `toolkit-only: true` in SKILL.md frontmatter).

**Toolkit-only filtering:**
```bash
# Check if a skill is toolkit-only
is_toolkit_only() {
  local skill_dir="$1"
  sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'
}
```

**Cleanup of toolkit-only skills in targets:** During sync, if a toolkit-only skill is found in a target project, treat it as an orphan:
- If unmodified (hash matches last sync): delete automatically
- If locally modified: prompt user (delete/keep/backup)

## Orphan Detection

Detect skills in target project that no longer exist in toolkit:

```bash
find_orphaned_project_skills() {
  local project_path="$1"
  local target_skills_dir="$project_path/.claude/skills"
  local orphans=()

  # List skills in target project
  for skill in $(ls -1 "$target_skills_dir" 2>/dev/null | grep -v "^\\."); do
    # Check if skill exists in toolkit
    if [[ ! -d "$TOOLKIT_SKILLS_DIR/$skill" ]]; then
      orphans+=("$skill")
    fi
  done
  echo "${orphans[@]}"
}
```

**Orphan handling:**

| Scenario | Action |
|----------|--------|
| Orphaned, no local changes | Delete automatically |
| Orphaned, has local changes | Prompt: delete / keep / backup |
| Not from this toolkit | Skip (may be project-specific) |

```bash
delete_orphaned_project_skill() {
  local project_path="$1"
  local skill_name="$2"
  local skill_path="$project_path/.claude/skills/$skill_name"

  # Check for local modifications (compare against last-synced hash)
  local last_synced_hash=$(jq -r ".skills[\"$skill_name\"].hash // empty" \
    "$project_path/.claude/toolkit-version.json" 2>/dev/null)

  if [[ -z "$last_synced_hash" ]]; then
    # Not tracked — might be project-specific, skip
    echo "SKIPPED"
    return
  fi

  local current_hash=$(find "$skill_path" -type f -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)

  if [[ "$current_hash" == "$last_synced_hash" ]]; then
    # No local changes, safe to delete
    rm -rf "$skill_path"
    echo "DELETED"
  else
    # Has local changes — prompt user
    echo "MODIFIED"
  fi
}
```

## Active Project Handling

For ACTIVE projects, show confirmation:

```
Project: ~/Projects/api-service
Status: ACTIVE (uncommitted changes)

This project has uncommitted git changes:
  M src/api/handlers.ts
  ?? src/api/new-file.ts

Syncing will update skill files but won't affect your uncommitted changes.

Options:
1. Sync anyway
2. Skip this project
3. Show full git status
```

## Workstream Scripts Sync

In addition to skills, sync the `.workstream/` scripts to each target project.

**Files synced (from toolkit `.workstream/`):**

| File | Target location | Notes |
|------|----------------|-------|
| `lib.sh` | `.workstream/lib.sh` | Shared utility library |
| `setup.sh` | `.workstream/setup.sh` | Worktree initializer |
| `dev.sh` | `.workstream/dev.sh` | Dev server launcher |
| `verify.sh` | `.workstream/verify.sh` | Quality gate runner |
| `README.md` | `.workstream/README.md` | Documentation |
| `workstream.json.example` | `.workstream/workstream.json.example` | Schema reference |

**NOT synced:**

- `workstream.json` — Project-owned config (each project has different ports/commands)

**Sync logic:**

```bash
sync_workstream_scripts() {
  local project_path="$1"
  local toolkit_ws="$TOOLKIT_PATH/.workstream"
  local target_ws="$project_path/.workstream"

  mkdir -p "$target_ws"

  for file in lib.sh setup.sh dev.sh verify.sh README.md workstream.json.example; do
    local src="$toolkit_ws/$file"
    local dest="$target_ws/$file"

    if [ ! -f "$src" ]; then continue; fi

    local src_hash=$(shasum -a 256 "$src" | cut -d' ' -f1)
    local dest_hash=""
    if [ -f "$dest" ]; then
      dest_hash=$(shasum -a 256 "$dest" | cut -d' ' -f1)
    fi

    if [ "$src_hash" = "$dest_hash" ]; then
      echo "  $file — current"
    else
      cp "$src" "$dest"
      echo "  $file — updated"
    fi
  done

  # Ensure scripts are executable
  chmod +x "$target_ws"/*.sh 2>/dev/null || true
}
```

**Tracking in toolkit-version.json:**

Workstream script hashes are stored under a `"workstream"` key:

```json
{
  "schema_version": "1.0",
  "toolkit_commit": "abc1234",
  "files": { ... },
  "workstream": {
    ".workstream/lib.sh": {
      "hash": "{sha256}",
      "synced_at": "{ISO timestamp}"
    },
    ".workstream/setup.sh": { ... },
    ".workstream/dev.sh": { ... },
    ".workstream/verify.sh": { ... },
    ".workstream/README.md": { ... }
  }
}
```

## Schema Extension for Global Resolution

The toolkit-version.json schema is extended to track skill resolution mode:

```json
{
  "schema_version": "1.1",
  "toolkit_location": "/path/to/toolkit",
  "toolkit_commit": "abc1234",
  "toolkit_commit_date": "2026-02-01T12:00:00Z",
  "last_sync": "2026-02-01T12:00:00Z",
  "force_local_skills": null,
  "skill_resolution": "global",
  "files": {
    ".claude/skills/fresh-start/SKILL.md": {
      "hash": "abc123...",
      "synced_at": "2026-02-01T12:00:00Z",
      "resolution": "global"
    },
    ".claude/skills/custom-skill/SKILL.md": {
      "hash": "def456...",
      "synced_at": "2026-02-01T12:00:00Z",
      "resolution": "local"
    }
  },
  "workstream": { ... }
}
```

### New Fields

| Field | Type | Description |
|-------|------|-------------|
| `force_local_skills` | `boolean\|null` | Override auto-detection: `true`=always local, `false`=always global, `null`=auto |
| `skill_resolution` | `"global"\|"local"\|"mixed"` | Project-level summary of resolution mode |
| `files.*.resolution` | `"global"\|"local"` | Per-file resolution indicator |

### Resolution Values

| `skill_resolution` | Meaning |
|--------------------|---------|
| `"global"` | All skills resolved via `~/.claude/skills/` |
| `"local"` | All skills copied to project's `.claude/skills/` |
| `"mixed"` | Some global, some local (e.g., partial migration or unavailable global skills) |

## Updated Sync Summary Format

The sync summary now shows resolution breakdown:

```
SYNC SUMMARY
============
Global resolution:  25 skills (via ~/.claude/skills)
Local resolution:   5 skills (copied to project)
  - New files:      2 copied
  - Updated files:  1 copied
  - Current files:  2 skipped
  - Modified files: 0 skipped (local changes preserved)
```

For projects using all-local resolution:
```
SYNC SUMMARY
============
Resolution mode: local (skill_resolution: "local")
  - New files:      3 copied
  - Updated files:  5 copied
  - Current files:  22 skipped
  - Modified files: 0 skipped
```
