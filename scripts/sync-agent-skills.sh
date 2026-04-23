#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Sync toolkit skills to Claude and Codex user skill directories.

Usage:
  ./scripts/sync-agent-skills.sh [options]

Options:
  --method <symlink|copy>  Install method (default: symlink)
  --source <path>          Source skills directory (default: <repo>/.claude/skills)
  --force                  Replace conflicting existing paths
  --adopt-unmanaged-skills Replace conflicting non-toolkit skills (requires --force)
  --prune                  Remove orphaned toolkit-managed skills from targets
  --adopt-codex-shim       Replace existing ~/.codex/skills with compatibility shim (requires --force)
  --no-codex-shim          Skip ~/.codex/skills compatibility shim management
  --dry-run                Show planned changes without modifying files
  --check                  Check mode (exit non-zero when drift is detected)
  -h, --help               Show help

Targets:
  - ~/.claude/skills
  - ~/.agents/skills
  - ~/.codex/skills (compatibility shim to ~/.agents/skills, unless --no-codex-shim)
USAGE
}

METHOD="symlink"
FORCE="0"
ADOPT_UNMANAGED_SKILLS="0"
PRUNE="0"
DRY_RUN="0"
CHECK_ONLY="0"
INSTALL_CODEX_SHIM="1"
ADOPT_CODEX_SHIM="0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/.claude/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
AGENTS_SKILLS_DIR="${AGENTS_HOME:-$HOME/.agents}/skills"
CODEX_SHIM_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --method)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      METHOD="${2:-}"
      shift 2
      ;;
    --source)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      SRC_DIR="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    --adopt-unmanaged-skills)
      ADOPT_UNMANAGED_SKILLS="1"
      shift
      ;;
    --prune)
      PRUNE="1"
      shift
      ;;
    --adopt-codex-shim)
      ADOPT_CODEX_SHIM="1"
      shift
      ;;
    --no-codex-shim)
      INSTALL_CODEX_SHIM="0"
      shift
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    --check)
      CHECK_ONLY="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$METHOD" != "symlink" && "$METHOD" != "copy" ]]; then
  echo "Invalid --method: $METHOD (expected: symlink|copy)" >&2
  exit 2
fi

if [[ "$ADOPT_UNMANAGED_SKILLS" == "1" && "$FORCE" != "1" ]]; then
  echo "--adopt-unmanaged-skills requires --force." >&2
  exit 2
fi

if [[ "$ADOPT_CODEX_SHIM" == "1" && "$FORCE" != "1" ]]; then
  echo "--adopt-codex-shim requires --force." >&2
  exit 2
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source skills directory not found: $SRC_DIR" >&2
  exit 1
fi

print_cmd() {
  printf '  '
  printf '%q ' "$@"
  printf '\n'
}

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    print_cmd "$@"
    return 0
  fi
  "$@"
}

realpath_safe() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path" 2>/dev/null || true
    return
  fi
  python3 - "$path" <<'PY'
import os
import sys
try:
    print(os.path.realpath(sys.argv[1]))
except Exception:
    pass
PY
}

SKILL_NAMES=()
SKILL_PATHS=()

while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "$skill_dir")"
  [[ "$skill_name" == .* ]] && continue

  if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
    continue
  fi

  SKILL_NAMES+=("$skill_name")
  SKILL_PATHS+=("$skill_dir")
done < <(find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  echo "No distributable skills found in $SRC_DIR" >&2
  exit 1
fi

SKILL_SET=" ${SKILL_NAMES[*]} "
ROOT_DIR_REAL="$(realpath_safe "$ROOT_DIR")"
SRC_ROOT_REAL="$(realpath_safe "$SRC_DIR")"
MARKER_ROOT="${ROOT_DIR_REAL:-$ROOT_DIR}"

created=0
updated=0
skipped=0
conflicts=0
pruned=0
issues=0
preserved=0

status_for_skill() {
  local dest="$1"
  local src="$2"

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    echo "MISSING"
    return
  fi

  if [[ "$METHOD" == "symlink" ]]; then
    if [[ -L "$dest" ]]; then
      local actual
      local expected
      actual="$(realpath_safe "$dest")"
      expected="$(realpath_safe "$src")"
      if [[ -n "$actual" && -n "$expected" && "$actual" == "$expected" ]]; then
        echo "CURRENT"
      else
        echo "WRONG_LINK"
      fi
    else
      echo "EXISTS_NOT_LINK"
    fi
    return
  fi

  # copy mode
  if [[ -d "$dest" ]]; then
    if diff -rq -x '.toolkit-source' "$dest" "$src" >/dev/null 2>&1; then
      echo "CURRENT"
    else
      echo "OUTDATED_COPY"
    fi
  else
    echo "EXISTS_NOT_DIR"
  fi
}

is_toolkit_managed_entry() {
  local dest="$1"

  if [[ -L "$dest" ]]; then
    local resolved
    resolved="$(realpath_safe "$dest")"
    if [[ -n "$resolved" && -n "$SRC_ROOT_REAL" && "$resolved" == "$SRC_ROOT_REAL/"* ]]; then
      return 0
    fi
    return 1
  fi

  if marker_points_to_toolkit "$dest"; then
    return 0
  fi

  return 1
}

marker_points_to_toolkit() {
  local dest="$1"
  local marker_file="$dest/.toolkit-source"
  local marker_root=""
  local marker_real=""

  if [[ ! -f "$marker_file" ]]; then
    return 1
  fi

  marker_root="$(head -n 1 "$marker_file" 2>/dev/null | tr -d '\r')"
  if [[ -z "$marker_root" ]]; then
    return 1
  fi

  marker_real="$(realpath_safe "$marker_root")"
  if [[ -n "$ROOT_DIR_REAL" && -n "$marker_real" ]]; then
    [[ "$marker_real" == "$ROOT_DIR_REAL" ]]
    return
  fi

  [[ "$marker_root" == "$ROOT_DIR" ]]
}

create_skill() {
  local src="$1"
  local dest="$2"

  if [[ "$METHOD" == "symlink" ]]; then
    run_cmd ln -s "$src" "$dest"
    return
  fi

  run_cmd cp -R "$src" "$dest"
  if [[ "$DRY_RUN" == "1" ]]; then
    print_cmd /bin/sh -c "printf '%s\\n' '$MARKER_ROOT' > '$dest/.toolkit-source'"
  else
    printf '%s\n' "$MARKER_ROOT" > "$dest/.toolkit-source"
  fi
}

sync_target() {
  local target_dir="$1"

  echo
  echo "Syncing target: $target_dir"
  run_cmd mkdir -p "$target_dir"

  local i
  for i in "${!SKILL_NAMES[@]}"; do
    local name="${SKILL_NAMES[$i]}"
    local src="${SKILL_PATHS[$i]}"
    local dest="$target_dir/$name"
    local status
    local managed="0"

    status="$(status_for_skill "$dest" "$src")"
    if is_toolkit_managed_entry "$dest"; then
      managed="1"
    fi

    if [[ "$CHECK_ONLY" == "1" ]]; then
      if [[ "$status" == "CURRENT" ]]; then
        echo "  [$status] $name"
      elif [[ "$status" != "MISSING" && "$managed" != "1" ]]; then
        echo "  [$status] $name"
      else
        echo "  [$status] $name"
        issues=$((issues + 1))
      fi
      continue
    fi

    case "$status" in
      CURRENT)
        skipped=$((skipped + 1))
        echo "  [$status] $name"
        ;;
      MISSING)
        create_skill "$src" "$dest"
        created=$((created + 1))
        echo "  [CREATED] $name"
        ;;
      WRONG_LINK|EXISTS_NOT_LINK|OUTDATED_COPY|EXISTS_NOT_DIR)
        if [[ "$managed" != "1" && "$ADOPT_UNMANAGED_SKILLS" != "1" ]]; then
          preserved=$((preserved + 1))
          echo "  [PRESERVED:$status] $name (external skill preserved)"
          continue
        fi

        if [[ "$FORCE" == "1" ]]; then
          run_cmd rm -rf "$dest"
          create_skill "$src" "$dest"
          updated=$((updated + 1))
          echo "  [UPDATED:$status] $name"
        else
          conflicts=$((conflicts + 1))
          echo "  [CONFLICT:$status] $name (use --force to replace)"
        fi
        ;;
      *)
        conflicts=$((conflicts + 1))
        echo "  [UNKNOWN:$status] $name"
        ;;
    esac
  done

  if [[ "$PRUNE" != "1" ]]; then
    return
  fi

  echo "  Checking for orphaned toolkit-managed skills..."

  local entry
  for entry in "$target_dir"/*; do
    if [[ ! -e "$entry" && ! -L "$entry" ]]; then
      continue
    fi

    local entry_name
    entry_name="$(basename "$entry")"

    if [[ "$SKILL_SET" == *" $entry_name "* ]]; then
      continue
    fi

    local should_prune="0"

    if [[ -L "$entry" ]]; then
      local resolved
      resolved="$(realpath_safe "$entry")"
      if [[ -n "$resolved" && -n "$SRC_ROOT_REAL" && "$resolved" == "$SRC_ROOT_REAL/"* ]]; then
        should_prune="1"
      fi
    elif marker_points_to_toolkit "$entry"; then
      should_prune="1"
    fi

    if [[ "$should_prune" != "1" ]]; then
      continue
    fi

    if [[ "$CHECK_ONLY" == "1" ]]; then
      echo "  [ORPHAN] $entry_name"
      issues=$((issues + 1))
      continue
    fi

    run_cmd rm -rf "$entry"
    pruned=$((pruned + 1))
    echo "  [PRUNED] $entry_name"
  done
}

sync_codex_shim() {
  if [[ "$INSTALL_CODEX_SHIM" != "1" ]]; then
    return
  fi

  echo
  echo "Ensuring Codex compatibility shim: $CODEX_SHIM_DIR -> $AGENTS_SKILLS_DIR"

  local shim_parent
  shim_parent="$(dirname "$CODEX_SHIM_DIR")"

  if [[ ! -e "$CODEX_SHIM_DIR" && ! -L "$CODEX_SHIM_DIR" ]]; then
    if [[ "$CHECK_ONLY" == "1" ]]; then
      echo "  [MISSING] codex shim"
      issues=$((issues + 1))
      return
    fi

    run_cmd mkdir -p "$shim_parent"
    run_cmd ln -s "$AGENTS_SKILLS_DIR" "$CODEX_SHIM_DIR"
    echo "  [CREATED] codex shim"
    created=$((created + 1))
    return
  fi

  if [[ -L "$CODEX_SHIM_DIR" ]]; then
    local actual
    local expected
    actual="$(realpath_safe "$CODEX_SHIM_DIR")"
    expected="$(realpath_safe "$AGENTS_SKILLS_DIR")"

    if [[ -n "$actual" && -n "$expected" && "$actual" == "$expected" ]]; then
      echo "  [CURRENT] codex shim"
      skipped=$((skipped + 1))
      return
    fi

    if [[ "$CHECK_ONLY" == "1" ]]; then
      echo "  [PRESERVED:WRONG_LINK] codex shim"
      if [[ "$ADOPT_CODEX_SHIM" == "1" ]]; then
        issues=$((issues + 1))
      fi
      return
    fi

    if [[ "$ADOPT_CODEX_SHIM" == "1" && "$FORCE" == "1" ]]; then
      run_cmd rm -rf "$CODEX_SHIM_DIR"
      run_cmd mkdir -p "$shim_parent"
      run_cmd ln -s "$AGENTS_SKILLS_DIR" "$CODEX_SHIM_DIR"
      echo "  [UPDATED] codex shim"
      updated=$((updated + 1))
    else
      echo "  [PRESERVED] codex shim points elsewhere (use --adopt-codex-shim --force to replace)"
      preserved=$((preserved + 1))
    fi

    return
  fi

  if [[ "$CHECK_ONLY" == "1" ]]; then
    echo "  [PRESERVED:EXISTS_NOT_LINK] codex shim"
    if [[ "$ADOPT_CODEX_SHIM" == "1" ]]; then
      issues=$((issues + 1))
    fi
    return
  fi

  if [[ "$ADOPT_CODEX_SHIM" == "1" && "$FORCE" == "1" ]]; then
    run_cmd rm -rf "$CODEX_SHIM_DIR"
    run_cmd mkdir -p "$shim_parent"
    run_cmd ln -s "$AGENTS_SKILLS_DIR" "$CODEX_SHIM_DIR"
    echo "  [UPDATED] codex shim"
    updated=$((updated + 1))
  else
    echo "  [PRESERVED] codex shim path exists and is not a symlink (use --adopt-codex-shim --force to replace)"
    preserved=$((preserved + 1))
  fi
}

echo "Syncing ${#SKILL_NAMES[@]} skills using method=$METHOD"
echo "Source: $SRC_DIR"
if [[ "$CHECK_ONLY" == "1" ]]; then
  echo "Mode: check"
elif [[ "$DRY_RUN" == "1" ]]; then
  echo "Mode: dry-run"
else
  echo "Mode: apply"
fi

sync_target "$CLAUDE_SKILLS_DIR"
sync_target "$AGENTS_SKILLS_DIR"
sync_codex_shim

echo
echo "Skill sync summary"
echo "  Created:   $created"
echo "  Updated:   $updated"
echo "  Skipped:   $skipped"
echo "  Conflicts: $conflicts"
echo "  Preserved: $preserved"
echo "  Pruned:    $pruned"

if [[ "$CHECK_ONLY" == "1" ]]; then
  echo "  Drift:     $issues"
  if [[ "$issues" -gt 0 ]]; then
    exit 1
  fi
  exit 0
fi

if [[ "$conflicts" -gt 0 ]]; then
  echo
  echo "Some paths were not modified due to conflicts. Re-run with --force to replace conflicting entries." >&2
fi
