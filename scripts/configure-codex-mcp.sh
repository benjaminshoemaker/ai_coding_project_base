#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Configure MCP servers for Codex using the toolkit MCP manifest.

This command now delegates to ./scripts/sync-agent-mcps.sh and keeps
backward compatibility with existing workflows.

Usage:
  ./scripts/configure-codex-mcp.sh [options]

Options:
  --manifest <path>        MCP manifest path (default: config/mcp/servers.json)
  --add-mcp-version <ver>  add-mcp version override
  --scope <user|project>   Scope override (default from manifest)
  --dry-run                Show planned commands without changes
  --check                  Validate manifest and show planned commands
  --force                  Deprecated; accepted for backward compatibility
  -h, --help               Show help
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ARGS=()
FORCE_SEEN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE_SEEN="1"
      shift
      ;;
    --manifest|--add-mcp-version|--scope)
      ARGS+=("$1" "${2:-}")
      shift 2
      ;;
    --dry-run|--check)
      ARGS+=("$1")
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

if [[ "$FORCE_SEEN" == "1" ]]; then
  echo "Note: --force is deprecated and no longer required."
fi

exec "$ROOT_DIR/scripts/sync-agent-mcps.sh" --agents codex "${ARGS[@]}"
