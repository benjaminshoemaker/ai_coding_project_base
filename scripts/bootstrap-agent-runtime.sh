#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Bootstrap machine-level runtime config for both Claude Code and Codex.

This script runs:
  1) ./scripts/sync-agent-skills.sh
  2) ./scripts/sync-agent-mcps.sh
  3) ./scripts/sync-agent-configs.sh

Usage:
  ./scripts/bootstrap-agent-runtime.sh [options]

Options:
  --method <symlink|copy>    Skill install method (default: symlink)
  --force                    Replace conflicting skill paths
  --adopt-unmanaged-skills   Replace conflicting non-toolkit skills (requires --force)
  --prune                    Remove orphaned toolkit-managed skills
  --adopt-codex-shim         Replace existing ~/.codex/skills with compatibility shim (requires --force)
  --no-codex-shim            Do not maintain ~/.codex/skills compatibility symlink
  --manifest <path>          MCP manifest path (default: config/mcp/servers.json)
  --add-mcp-version <ver>    add-mcp version override
  --scope <user|project>     MCP scope override
  --agents <csv>             MCP agents override (example: claude-code,codex)
  --normalize-existing       Run add-mcp sync after manifest apply (default)
  --no-normalize-existing    Skip add-mcp sync (manifest-only MCP apply)
  --no-configs               Skip user-level config laydown (Claude/Codex)
  --force-configs            Overwrite existing user-level config files (with backups)
  --dry-run                  Show planned operations without writes
  --check                    Check mode (exit non-zero on skill or config drift)
  -h, --help                 Show help
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SKILLS_ARGS=()
MCPS_ARGS=()
CONFIGS_ARGS=()
NORMALIZE_EXISTING="1"
DO_CONFIGS="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --method|--source|--manifest|--add-mcp-version|--scope|--agents)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi

      case "$1" in
        --method|--source)
          SKILLS_ARGS+=("$1" "$2")
          ;;
        --manifest|--add-mcp-version|--scope|--agents)
          MCPS_ARGS+=("$1" "$2")
          ;;
      esac
      shift 2
      ;;
    --normalize-existing)
      NORMALIZE_EXISTING="1"
      shift
      ;;
    --no-normalize-existing)
      NORMALIZE_EXISTING="0"
      shift
      ;;
    --no-configs)
      DO_CONFIGS="0"
      shift
      ;;
    --force-configs)
      CONFIGS_ARGS+=("--force")
      shift
      ;;
    --force|--adopt-unmanaged-skills|--prune|--adopt-codex-shim|--no-codex-shim)
      SKILLS_ARGS+=("$1")
      shift
      ;;
    --dry-run)
      SKILLS_ARGS+=("--dry-run")
      MCPS_ARGS+=("--dry-run")
      CONFIGS_ARGS+=("--dry-run")
      shift
      ;;
    --check)
      SKILLS_ARGS+=("--check")
      MCPS_ARGS+=("--check")
      CONFIGS_ARGS+=("--check")
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

if [[ "$NORMALIZE_EXISTING" == "1" ]]; then
  MCPS_ARGS+=("--normalize-existing")
fi

echo "Bootstrapping agent runtime from: $ROOT_DIR"

echo
echo "[1/3] Syncing skills"
"$ROOT_DIR/scripts/sync-agent-skills.sh" ${SKILLS_ARGS[@]+"${SKILLS_ARGS[@]}"}

echo
echo "[2/3] Syncing MCPs"
"$ROOT_DIR/scripts/sync-agent-mcps.sh" ${MCPS_ARGS[@]+"${MCPS_ARGS[@]}"}

if [[ "$DO_CONFIGS" == "1" ]]; then
  echo
  echo "[3/3] Syncing user-level configs"
  "$ROOT_DIR/scripts/sync-agent-configs.sh" ${CONFIGS_ARGS[@]+"${CONFIGS_ARGS[@]}"}
else
  echo
  echo "[3/3] Skipping user-level config sync (--no-configs)"
fi

echo
echo "Bootstrap complete."
