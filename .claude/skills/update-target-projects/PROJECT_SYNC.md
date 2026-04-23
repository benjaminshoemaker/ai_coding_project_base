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

Shared repos are informational only. The toolkit skill policy is global-only,
so do not auto-switch to project-local copies.

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
| Has git remote | Project likely shared with collaborators | Keep global resolution |
| CI environment | Running in automation | Keep global resolution |
| No indicators | Local-only project | Keep global resolution |

**Warning output (when shared repo detected):**
```
ℹ️  Shared repo detected (has git remote).
    Global-only skill policy still applies.
    Each collaborator should bootstrap ~/.claude/skills locally.
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
   → show informational note only; do not change resolution policy

1. Validate global symlink health
   → if all skills globally usable: continue
   → if unhealthy: classify as MISSING and repair globals first

2. Check for existing local shadow copies in .claude/skills/
   → if present: classify project as ADOPTABLE (legacy local/mixed)
   → if absent: classify as GLOBAL

3. Apply migration when ADOPTABLE
   → back up modified local skills
   → remove toolkit-managed local skill directories
   → record global resolution in toolkit-version.json
```

**Shared repo handling in code:**
```bash
# At start of classification for each project
if is_shared_repo "$project_path"; then
  echo "ℹ️  Shared repo detected. Global-only skill policy remains in effect."
fi
```

### Classification Table (Updated)

| Condition | Classification | Action |
|-----------|----------------|--------|
| Global symlinks healthy, no local copies | `GLOBAL` | Keep global resolution |
| Global symlinks healthy, local copies present | `ADOPTABLE` | Migrate to global |
| Global symlinks missing/broken | `MISSING` | Repair global symlinks and retry |

## Sync Execution

For each selected project:

```
[1/3] ~/Projects/my-app
      Checking global symlinks...
      Migrating legacy local shadows...
      Updating toolkit-version.json...
      Done (global resolution confirmed)
```

**Sync Logic (for each project):**

1. Change working context to target project
2. **Check resolution mode** — read `skill_resolution` and validate global symlink health
3. **Detect local shadow copies** — toolkit-managed skills under `.claude/skills/`
4. If local shadows exist:
   - Back up modified local skills
   - Remove toolkit-managed local copies
5. Update `toolkit-version.json` with current commit and `"skill_resolution": "global"`

**Skills to manage:** All distributable skills from `.claude/skills/` (excluding `toolkit-only: true`) are expected to resolve globally.

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

## Local Shadow Detection

Detect toolkit-managed local skill directories that should be removed:

```bash
find_local_shadow_skills() {
  local project_path="$1"
  local target_skills_dir="$project_path/.claude/skills"
  local shadows=()

  # List skills in target project
  for skill in $(ls -1 "$target_skills_dir" 2>/dev/null | grep -v "^\\."); do
    # Keep only toolkit-managed skills; custom project-specific skills are handled separately
    if [[ -d "$TOOLKIT_SKILLS_DIR/$skill" ]]; then
      shadows+=("$skill")
    fi
  done
  echo "${shadows[@]}"
}
```

**Local shadow handling:**

| Scenario | Action |
|----------|--------|
| Toolkit-managed local skill, no local changes | Delete automatically |
| Toolkit-managed local skill, has local changes | Backup then delete |
| Not from this toolkit | Skip by default; ask before deletion |

```bash
remove_local_shadow_skill() {
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
    # Has local changes — backup then delete
    mkdir -p "$project_path/.claude/skills.bak/$skill_name"
    cp -R "$skill_path"/. "$project_path/.claude/skills.bak/$skill_name/"
    rm -rf "$skill_path"
    echo "BACKED_UP_AND_DELETED"
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

Syncing will migrate local skill shadows and won't touch your source files.

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

## Codex App Setup Wrapper Sync

In addition to workstream scripts, sync the `.codex/setup.sh` wrapper to each target project.
This enables Codex App worktree initialization.

**File synced (from toolkit `.codex/`):**

| File | Target location | Notes |
|------|----------------|-------|
| `setup.sh` | `.codex/setup.sh` | Codex App setup wrapper (delegates to `.workstream/setup.sh`) |

**NOT synced:**

- `.codex/environments/` — Project-owned Codex App config (auto-generated by Codex)
- `.codex/AGENTS.md` — Project-specific agent instructions

**Sync logic:**

```bash
sync_codex_setup() {
  local project_path="$1"
  local toolkit_codex="$TOOLKIT_PATH/.codex"
  local target_codex="$project_path/.codex"

  # Only sync setup.sh
  local src="$toolkit_codex/setup.sh"
  local dest="$target_codex/setup.sh"

  if [ ! -f "$src" ]; then
    echo "  .codex/setup.sh — not in toolkit, skipping"
    return
  fi

  mkdir -p "$target_codex"

  local src_hash=$(shasum -a 256 "$src" | cut -d' ' -f1)
  local dest_hash=""
  if [ -f "$dest" ]; then
    dest_hash=$(shasum -a 256 "$dest" | cut -d' ' -f1)
  fi

  if [ "$src_hash" = "$dest_hash" ]; then
    echo "  .codex/setup.sh — current"
  else
    cp "$src" "$dest"
    chmod +x "$dest"
    echo "  .codex/setup.sh — updated"
  fi
}
```

**Tracking in toolkit-version.json:**

Codex setup hash is stored under a `"codex"` key:

```json
{
  "schema_version": "1.0",
  "toolkit_commit": "abc1234",
  "files": { ... },
  "workstream": { ... },
  "codex": {
    ".codex/setup.sh": {
      "hash": "{sha256}",
      "synced_at": "{ISO timestamp}"
    }
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
  "force_local_skills": false,
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
      "resolution": "global"
    }
  },
  "workstream": { ... }
}
```

### New Fields

| Field | Type | Description |
|-------|------|-------------|
| `force_local_skills` | `boolean\|null` | Legacy field; set `false` for global-only behavior |
| `skill_resolution` | `"global"\|"local"\|"mixed"` | Project-level summary (`global` is required target state) |
| `files.*.resolution` | `"global"\|"local"` | Per-file resolution indicator (`global` required for toolkit-managed skills) |

### Resolution Values

| `skill_resolution` | Meaning |
|--------------------|---------|
| `"global"` | All skills resolved via `~/.claude/skills/` |
| `"local"` | Legacy state; migrate to global |
| `"mixed"` | Legacy state; migrate to global |

## Updated Sync Summary Format

The sync summary now shows resolution breakdown:

```
SYNC SUMMARY
============
Global resolution:         30 skills (via ~/.claude/skills)
Legacy local dirs removed: 5
Local modifications backed up: 2
Missing globals:           0
```
