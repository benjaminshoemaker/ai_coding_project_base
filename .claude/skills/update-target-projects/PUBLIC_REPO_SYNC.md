# Public Skills Repo Sync

Supporting document for syncing curated skills to the public skills repo.

## Configuration

Read from `.claude/public-skills-config.json` (local-only, not committed to toolkit):

```json
{
  "enabled": true,
  "path": "/path/to/awesome-claude-skills"
}
```

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | `false` | Set to `true` to enable public repo sync |
| `path` | — | Absolute path to the public skills repo clone |

**Manifest location:** `.claude/public-skills-manifest.json` in the toolkit repo.

## Pre-flight Checks

Before syncing, verify all of the following:

1. **Config exists:** `publicSkillsRepo.path` is set in `.claude/public-skills-config.json`
2. **Path exists:** The configured path is a real directory
3. **Is git repo:** `git -C "$path" rev-parse --show-toplevel` succeeds
4. **Clean working tree:** `git -C "$path" status --porcelain` is empty — abort if dirty
5. **Manifest readable:** `.claude/public-skills-manifest.json` exists and is valid JSON
6. **Manifest valid:** Every skill name matches `^[a-z0-9-]+$` — abort if any name fails validation (prevents path traversal)

If any check fails, report the specific failure and skip public repo sync.

## Status Classification

For each skill in the manifest, classify its status:

| Status | Condition |
|--------|-----------|
| `MISSING` | Skill directory does not exist in public repo `skills/` |
| `CURRENT` | Skill hash matches last-synced hash in `toolkit-version.json` |
| `OUTDATED` | Skill exists but hash differs from toolkit (toolkit was updated) |
| `LOCAL_MODIFIED` | Skill hash differs from both toolkit AND last-synced hash (someone edited the public repo copy) |
| `UNMANAGED_PRESENT` | Skill directory exists in public repo but has no entry in `toolkit-version.json` (manually created) |

## Hashing Algorithm

Per-skill hash computation (macOS-compatible, deterministic):

```bash
compute_skill_hash() {
  local skill_dir="$1"

  # 1. List all files recursively, excluding .DS_Store
  # 2. Sort for determinism
  # 3. For each file: hash "relative_path:file_contents"
  # 4. Combine all file hashes into a single hash

  local combined=""
  while IFS= read -r file; do
    local rel_path="${file#$skill_dir/}"
    local file_hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    combined="${combined}${rel_path}:${file_hash}\n"
  done < <(find "$skill_dir" -type f -not -name '.DS_Store' | sort)

  echo -e "$combined" | shasum -a 256 | cut -d' ' -f1
}
```

This matches the per-file approach used in PROJECT_SYNC.md but combines into a single per-skill hash since entire skill directories are the unit of sync.

## Conflict Detection

Compare hashes at three points:

1. **Toolkit hash** — computed from toolkit's `.claude/skills/{name}/`
2. **Last-synced hash** — stored in public repo's `toolkit-version.json` under `skills.{name}.hash`
3. **Current public hash** — computed from public repo's `skills/{name}/`

| Toolkit vs Last-synced | Current vs Last-synced | Status |
|------------------------|------------------------|--------|
| Same | Same | `CURRENT` |
| Different | Same | `OUTDATED` (safe to overwrite) |
| Different | Different | `LOCAL_MODIFIED` (warn + prompt) |
| Same | Different | `LOCAL_MODIFIED` (warn + prompt) |
| — | No entry | `UNMANAGED_PRESENT` (warn + prompt) |

**Never silently overwrite `LOCAL_MODIFIED` or `UNMANAGED_PRESENT` skills.** Prompt the user before replacing.

## Sync Process

For each skill in the manifest:

### MISSING or OUTDATED

1. Remove destination directory: `rm -rf "$public_repo/skills/$skill"`
2. Copy from toolkit: `cp -r "$toolkit/.claude/skills/$skill" "$public_repo/skills/$skill"`
3. Remove any `.DS_Store` files: `find "$public_repo/skills/$skill" -name .DS_Store -delete`
4. Update hash in `toolkit-version.json`

Wiping before copy ensures deleted files in toolkit propagate to public repo.

### LOCAL_MODIFIED

1. Warn: "Skill `{name}` has been modified in the public repo since last sync"
2. Show diff summary (file count, which files changed)
3. Prompt: "Overwrite with toolkit version?" / "Keep public repo version" / "Show diff"
4. If overwrite: proceed as OUTDATED
5. If keep: skip, leave hash unchanged

### UNMANAGED_PRESENT

1. Warn: "Skill `{name}` exists in public repo but was not synced from toolkit"
2. Prompt: "Overwrite with toolkit version?" / "Keep existing"
3. If overwrite: proceed as OUTDATED
4. If keep: skip, do not add to `toolkit-version.json`

## Orphan Detection

After processing the manifest, check for orphaned skills:

1. Read all skill names from `toolkit-version.json` `skills` object
2. Compare against current manifest
3. Skills tracked in `toolkit-version.json` but not in manifest are orphaned

**For orphaned skills:**
- Prompt: "Skill `{name}` is no longer in the manifest. Remove from public repo?"
- If yes: `rm -rf "$public_repo/skills/$skill"`, remove from `toolkit-version.json`
- If no: leave in place but remove from `toolkit-version.json` (stop tracking)

**Untracked directories** (in `skills/` but not in `toolkit-version.json`) are left untouched — they may be user-added skills.

## Public Repo `toolkit-version.json`

Schema for the version file in the public repo root:

```json
{
  "toolkit_commit": "abc1234",
  "last_sync": "2026-02-24T18:51:24Z",
  "skills": {
    "codex-review": {
      "hash": "sha256-of-skill-directory",
      "synced_at": "2026-02-24T18:51:24Z"
    },
    "innovate": {
      "hash": "sha256-of-skill-directory",
      "synced_at": "2026-02-24T18:51:24Z"
    }
  }
}
```

**Note:** `source_toolkit` path is deliberately omitted — this is a public repo and local filesystem paths should not be committed.

- `toolkit_commit`: Short hash of the toolkit commit at time of sync
- `last_sync`: ISO 8601 timestamp of the sync operation
- `skills.{name}.hash`: Per-skill directory hash (see Hashing Algorithm above)
- `skills.{name}.synced_at`: When this specific skill was last synced

## Git Operations

After all skills are synced:

1. Stage managed paths only: `git -C "$public_repo" add skills/ toolkit-version.json`
   - Do NOT stage README.md or other user-maintained files
2. Check if there are staged changes: `git -C "$public_repo" diff --cached --quiet`
3. If changes exist, commit with summary:
   ```
   sync: update {N} skills from toolkit ({commit})

   Updated: skill1, skill2
   Added: skill3
   Removed: skill4
   ```
4. **Prompt before push:** "Push to remote?" — never auto-push

## Status Display

In the Phase 4 status report, add a PUBLIC SKILLS REPO section:

```
PUBLIC SKILLS REPO
──────────────────
Location: /path/to/awesome-claude-skills
Status:   {READY|NOT CONFIGURED|DIRTY|NOT A GIT REPO}

  Skill              Status
  ───────────────────────────
  codex-review       CURRENT
  codex-consult      OUTDATED
  innovate           MISSING
  audit-skills       CURRENT
  list-todos         LOCAL_MODIFIED
  add-todo           CURRENT
  run-todos           CURRENT
  update-docs        CURRENT
  capture-learning   MISSING
```

If not configured: `Status: NOT CONFIGURED (add publicSkillsRepo to .claude/settings.local.json)`
