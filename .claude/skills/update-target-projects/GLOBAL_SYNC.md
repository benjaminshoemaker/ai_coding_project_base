# Global Skills Sync

Manage symlinks in `~/.claude/skills/` that point to the toolkit, enabling Conductor autocomplete across all workspaces and global skill resolution for Claude Code.

## Configuration

```bash
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
TOOLKIT_SKILLS_DIR="$(pwd)/.claude/skills"
TOOLKIT_ROOT="$(pwd)"  # For symlink target verification
```

## Check Global Skills Status

```bash
# Dynamically discover all distributable skills from toolkit
TOOLKIT_SKILLS=()
for skill_dir in "$TOOLKIT_SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  [[ "$skill_name" == .* ]] && continue
  # Skip toolkit-only skills
  if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
    continue
  fi
  TOOLKIT_SKILLS+=("$skill_name")
done

# Discover what's currently in the global directory
GLOBAL_INSTALLED=($(ls -1 "$GLOBAL_SKILLS_DIR" 2>/dev/null | grep -v "^\."))
```

## Status Classification

For each skill, determine its global status:

```bash
check_global_skill() {
  local skill_name="$1"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  local toolkit_path="$TOOLKIT_SKILLS_DIR/$skill_name"

  # Check for broken symlink first (-L tests symlink existence, -e tests target)
  if [[ -L "$global_path" && ! -e "$global_path" ]]; then
    echo "BROKEN_SYMLINK"
    return
  fi

  if [[ ! -e "$global_path" ]]; then
    echo "MISSING"
  elif [[ -L "$global_path" ]]; then
    # Use realpath for canonical comparison (handles relative symlinks correctly)
    local resolved=$(realpath "$global_path" 2>/dev/null)
    local expected=$(realpath "$toolkit_path" 2>/dev/null)
    if [[ "$resolved" == "$expected" ]]; then
      echo "SYMLINK_CURRENT"
    else
      echo "SYMLINK_OTHER"
    fi
  else
    # Real directory — never touch these (e.g., design-principles)
    echo "REAL_DIR"
  fi
}
```

| Status | Meaning | Action |
|--------|---------|--------|
| `MISSING` | Skill not in global dir | Create symlink |
| `SYMLINK_CURRENT` | Symlink to this toolkit | No action needed |
| `SYMLINK_OTHER` | Symlink to different source | Skip (not ours) |
| `REAL_DIR` | Real directory (not symlink) | Skip (preserve) |
| `BROKEN_SYMLINK` | Symlink target doesn't exist | Repair or warn |

## Symlink Target Verification

Verify that symlinks point to the expected toolkit location using `realpath`:

```bash
verify_symlink_target() {
  local skill_name="$1"
  local expected_toolkit="${2:-$TOOLKIT_ROOT}"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"

  if [[ ! -L "$global_path" ]]; then
    return 1  # Not a symlink
  fi

  local resolved=$(realpath "$global_path" 2>/dev/null)
  local expected_resolved=$(realpath "$expected_toolkit/.claude/skills/$skill_name" 2>/dev/null)

  [[ "$resolved" == "$expected_resolved" ]]
}
```

## High-Level Availability Helpers

These helpers determine if skills can be resolved globally (used by `/setup` and `/update-target-projects`):

```bash
# Check if a specific skill is globally usable (healthy symlink to this toolkit)
is_globally_usable() {
  local skill_name="$1"
  local status=$(check_global_skill "$skill_name")

  # Must be a current symlink AND point to this toolkit
  if [[ "$status" == "SYMLINK_CURRENT" ]]; then
    verify_symlink_target "$skill_name" "$TOOLKIT_ROOT"
    return $?
  fi

  return 1
}

# Returns true if ALL distributable skills are globally usable
all_skills_globally_usable() {
  for skill_name in "${TOOLKIT_SKILLS[@]}"; do
    if ! is_globally_usable "$skill_name"; then
      return 1
    fi
  done
  return 0
}

# Repair a broken symlink
repair_global_symlink() {
  local skill_name="$1"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"

  if [[ -L "$global_path" ]]; then
    rm "$global_path"  # Remove broken or wrong symlink
  fi
  ln -s "$TOOLKIT_ROOT/.claude/skills/$skill_name" "$global_path"
  echo "REPAIRED"
}
```

| Helper | Purpose | Returns |
|--------|---------|---------|
| `is_globally_usable` | Check if a single skill resolves via global symlink | 0=usable, 1=not usable |
| `all_skills_globally_usable` | Check if ALL skills can use global resolution | 0=all usable, 1=some missing |
| `repair_global_symlink` | Fix a broken or missing symlink | "REPAIRED" |

## Orphan Detection

Detect global symlinks pointing to this toolkit for skills that no longer exist:

```bash
find_orphaned_global_skills() {
  local orphans=()
  for item in "${GLOBAL_INSTALLED[@]}"; do
    local global_path="$GLOBAL_SKILLS_DIR/$item"
    # Only consider symlinks pointing to this toolkit
    if [[ -L "$global_path" ]]; then
      # Use realpath for canonical comparison (handles relative symlinks)
      local resolved=$(realpath "$global_path" 2>/dev/null)
      local toolkit_resolved=$(realpath "$TOOLKIT_ROOT/.claude/skills" 2>/dev/null)
      if [[ "$resolved" == "$toolkit_resolved/"* ]]; then
        # Check if skill still exists in toolkit
        if [[ ! -d "$TOOLKIT_SKILLS_DIR/$item" ]]; then
          orphans+=("$item")
        fi
      fi
    fi
  done
  echo "${orphans[@]}"
}
```

| Orphan Type | Description | Action |
|-------------|-------------|--------|
| Dangling symlink to toolkit | Skill removed from toolkit | Delete automatically |
| Symlink to other source | Not from this toolkit | Skip |
| Real directory | User-created | Skip (preserve) |

## Sync Logic

```bash
sync_global_skill() {
  local skill_name="$1"
  local status="$2"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  local toolkit_path="$TOOLKIT_SKILLS_DIR/$skill_name"

  case "$status" in
    MISSING)
      ln -s "$toolkit_path" "$global_path"
      echo "LINKED"
      ;;
    BROKEN_SYMLINK)
      # Remove broken symlink and recreate
      rm "$global_path"
      ln -s "$toolkit_path" "$global_path"
      echo "REPAIRED"
      ;;
    SYMLINK_CURRENT|REAL_DIR)
      echo "CURRENT"
      ;;
    SYMLINK_OTHER)
      echo "SKIPPED"
      ;;
  esac
}

delete_orphaned_global_skill() {
  local skill_name="$1"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  rm "$global_path"
  echo "DELETED"
}
```

## Status Display

```
GLOBAL SKILLS (Conductor Autocomplete)
───────────────────────────────────────
Location: ~/.claude/skills
Status:   CURRENT (30 symlinks active)

  Skill                  Status
  ──────────────────────────────────────
  fresh-start            SYMLINK_CURRENT
  phase-start            SYMLINK_CURRENT
  new-skill              MISSING          ← needs linking
  design-principles      REAL_DIR         (preserved)
```

**If all linked:**
```
Status: CURRENT (all 30 skills symlinked)
All distributable skills are globally available for Conductor autocomplete.
```

**If orphans found:**
```
ORPHANED GLOBAL SYMLINKS
────────────────────────
The following global symlinks point to skills removed from toolkit:
  - old-removed-skill

These will be deleted during sync.
```

**If directory missing:**
```
Status: DIRECTORY NOT FOUND
Creating ~/.claude/skills/ ...
```

**If broken symlinks found:**
```
BROKEN SYMLINKS DETECTED
────────────────────────
The following global symlinks have invalid targets:
  - old-skill (target: /nonexistent/path)

Options:
1. Repair automatically (re-create pointing to toolkit)
2. Delete broken symlinks
3. Skip (leave as-is)
```

## Global Resolution for New Projects

When `/setup` creates a new project, it checks `is_globally_usable()` for each skill.
If a skill is globally usable, it is NOT copied to the project—Claude Code will
discover it from `~/.claude/skills/` automatically.

**State model:**

| State | Global symlink? | Local copy? | Claude uses |
|-------|-----------------|-------------|-------------|
| `GLOBAL_USABLE` | ✅ healthy | ❌ none | Global ✅ |
| `LOCAL_SHADOWING` | ✅ healthy | ✅ exists | Local (shadows global) |
| `LOCAL_ONLY` | ❌ missing | ✅ exists | Local |
| `MISSING` | ❌ missing | ❌ none | ⚠️ Skill unavailable |

**Key insight:** Only `GLOBAL_USABLE` actually resolves via global symlinks.
If local copies exist, they shadow the global symlinks—explicit migration is
required to switch existing projects to global resolution.
