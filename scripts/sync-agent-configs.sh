#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Lay down user-level config files for Claude Code and Codex from toolkit templates.

Targets:
  ~/.claude/settings.json          <- config/claude/settings.json.example
  ~/.claude/statusline.sh          <- config/claude/statusline.sh
  ~/.claude/commands/*.md          <- config/claude/commands/*.md
  ~/.codex/config.toml             <- config/codex/config.toml.example

By default, existing files are NOT overwritten. Use --force to overwrite
(timestamped backups are written first).

Usage:
  ./scripts/sync-agent-configs.sh [options]

Options:
  --force        Overwrite existing files (creates *.bak.<ts> backups first)
  --dry-run      Print actions without writing
  --check        Exit 0 if all targets match templates, non-zero otherwise
  --no-claude    Skip ~/.claude/* targets
  --no-codex     Skip ~/.codex/* targets
  -h, --help     Show help
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE="0"
DRY_RUN="0"
CHECK_ONLY="0"
DO_CLAUDE="1"
DO_CODEX="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)      FORCE="1"; shift ;;
    --dry-run)    DRY_RUN="1"; shift ;;
    --check)      CHECK_ONLY="1"; shift ;;
    --no-claude)  DO_CLAUDE="0"; shift ;;
    --no-codex)   DO_CODEX="0"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

TS="$(date +%Y%m%d-%H%M%S)"
DRIFT="0"

log() { printf '%s\n' "$*"; }

# Place SRC -> DEST. If DEST exists and differs and --force is not set, leave it
# alone (warn). If DEST does not exist, copy. In --check mode, exit non-zero on
# any drift. Preserves executable bit when SRC is executable.
place() {
  local src="$1" dest="$2"
  if [[ ! -f "$src" ]]; then
    log "  SKIP missing template: $src"
    return 0
  fi

  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ ! -e "$dest" ]]; then
    log "  CREATE $dest"
    if [[ "$DRY_RUN" == "1" || "$CHECK_ONLY" == "1" ]]; then
      [[ "$CHECK_ONLY" == "1" ]] && DRIFT="1"
      return 0
    fi
    mkdir -p "$dest_dir"
    cp "$src" "$dest"
    [[ -x "$src" ]] && chmod +x "$dest" || true
    return 0
  fi

  if cmp -s "$src" "$dest"; then
    log "  OK     $dest (matches template)"
    return 0
  fi

  if [[ "$CHECK_ONLY" == "1" ]]; then
    log "  DRIFT  $dest"
    DRIFT="1"
    return 0
  fi

  if [[ "$FORCE" != "1" ]]; then
    log "  KEEP   $dest (differs from template; use --force to overwrite)"
    return 0
  fi

  log "  REPLACE $dest (backup -> $dest.bak.$TS)"
  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi
  cp "$dest" "$dest.bak.$TS"
  cp "$src" "$dest"
  [[ -x "$src" ]] && chmod +x "$dest" || true
}

if [[ "$DO_CLAUDE" == "1" ]]; then
  log "Claude Code config:"
  place "$ROOT_DIR/config/claude/settings.json.example" "$HOME/.claude/settings.json"
  place "$ROOT_DIR/config/claude/statusline.sh"         "$HOME/.claude/statusline.sh"

  if [[ -d "$ROOT_DIR/config/claude/commands" ]]; then
    while IFS= read -r -d '' cmd; do
      place "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
    done < <(find "$ROOT_DIR/config/claude/commands" -type f -name '*.md' -print0)
  fi
fi

if [[ "$DO_CODEX" == "1" ]]; then
  log "Codex CLI config:"
  place "$ROOT_DIR/config/codex/config.toml.example" "$HOME/.codex/config.toml"
fi

if [[ "$CHECK_ONLY" == "1" && "$DRIFT" == "1" ]]; then
  log ""
  log "Drift detected. Run without --check to apply (use --force to overwrite changed files)."
  exit 1
fi

log ""
log "Done."
