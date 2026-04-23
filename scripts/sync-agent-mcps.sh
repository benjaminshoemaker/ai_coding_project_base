#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Sync MCP servers from the toolkit manifest to Claude Code and Codex.

Usage:
  ./scripts/sync-agent-mcps.sh [options]

Options:
  --manifest <path>          Manifest file (default: config/mcp/servers.json)
  --add-mcp-version <ver>    add-mcp version override (default: manifest value)
  --scope <user|project>     Scope override for all servers
  --agents <csv>             Agent override for all servers (example: claude-code,codex)
  --normalize-existing       Run add-mcp sync after apply (opt-in)
  --dry-run                  Show planned add-mcp commands without executing
  --check                    Validate manifest and show planned commands (no writes)
  -h, --help                 Show help

Notes:
  - Requires Node.js and npx.
  - Uses add-mcp for cross-agent config fan-out.
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT_DIR/config/mcp/servers.json"
ADD_MCP_VERSION=""
SCOPE_OVERRIDE=""
AGENTS_OVERRIDE=""
DRY_RUN="0"
CHECK_ONLY="0"
NORMALIZE_EXISTING="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      MANIFEST="${2:-}"
      shift 2
      ;;
    --add-mcp-version)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      ADD_MCP_VERSION="${2:-}"
      shift 2
      ;;
    --scope)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      SCOPE_OVERRIDE="${2:-}"
      shift 2
      ;;
    --agents)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      AGENTS_OVERRIDE="${2:-}"
      shift 2
      ;;
    --normalize-existing)
      NORMALIZE_EXISTING="1"
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

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

if [[ -n "$SCOPE_OVERRIDE" && "$SCOPE_OVERRIDE" != "user" && "$SCOPE_OVERRIDE" != "project" && "$SCOPE_OVERRIDE" != "global" ]]; then
  echo "Invalid --scope: $SCOPE_OVERRIDE (expected: user|project|global)" >&2
  exit 2
fi

python3 - "$MANIFEST" "$ADD_MCP_VERSION" "$SCOPE_OVERRIDE" "$AGENTS_OVERRIDE" "$DRY_RUN" "$CHECK_ONLY" "$NORMALIZE_EXISTING" <<'PY'
import json
import shlex
import subprocess
import sys
from collections import defaultdict

(
    manifest_path,
    version_override,
    scope_override,
    agents_override,
    dry_run_raw,
    check_only_raw,
    normalize_existing_raw,
) = sys.argv[1:]
dry_run = dry_run_raw == "1"
check_only = check_only_raw == "1"
normalize_existing = normalize_existing_raw == "1"

with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = json.load(f)

if manifest.get("schema_version") != 1:
    raise SystemExit(f"Unsupported schema_version in {manifest_path}: {manifest.get('schema_version')}")

add_mcp_version = version_override or manifest.get("add_mcp_version") or "1.8.0"
defaults = manifest.get("defaults", {})
servers = manifest.get("servers", [])

if not isinstance(servers, list):
    raise SystemExit("Manifest error: 'servers' must be an array")


def parse_agents(value):
    if value is None:
        return None
    if isinstance(value, list):
        return [str(v).strip() for v in value if str(v).strip()]
    if isinstance(value, str):
        return [v.strip() for v in value.split(",") if v.strip()]
    raise SystemExit("Invalid agents field; expected list or comma-separated string")


def normalize_scope(value):
    if value is None:
        return None
    scope = str(value).strip().lower()
    if scope == "global":
        return "user"
    return scope


cli_agents = parse_agents(agents_override) if agents_override else None

default_agents = parse_agents(defaults.get("agents")) or ["claude-code", "codex"]
default_scope = normalize_scope(defaults.get("scope", "user"))

if scope_override:
    default_scope = normalize_scope(scope_override)

if default_scope not in {"user", "project"}:
    raise SystemExit(f"Invalid default scope: {default_scope}")

print(f"MCP sync manifest: {manifest_path}")
print(f"add-mcp version:   {add_mcp_version}")
print(f"Mode:              {'check' if check_only else ('dry-run' if dry_run else 'apply')}")

planned = 0
applied = 0
target_scope_agents = defaultdict(set)

for idx, server in enumerate(servers, start=1):
    if not isinstance(server, dict):
        raise SystemExit(f"Manifest error: servers[{idx - 1}] must be an object")

    enabled = server.get("enabled", True)
    if not enabled:
        continue

    source = server.get("source") or server.get("package") or server.get("url")
    if not source:
        raise SystemExit(f"Manifest error: servers[{idx - 1}] is missing required field 'source'")

    scope = normalize_scope(scope_override or server.get("scope") or default_scope)
    if scope not in {"user", "project"}:
        raise SystemExit(f"Manifest error: invalid scope '{scope}' for server index {idx - 1}")

    agents = cli_agents or parse_agents(server.get("agents")) or default_agents
    if not agents:
        raise SystemExit(f"Manifest error: empty agents list for server index {idx - 1}")

    name = server.get("name")
    transport = server.get("transport")
    env_map = server.get("env") or {}
    headers_map = server.get("headers") or {}

    if not isinstance(env_map, dict):
        raise SystemExit(f"Manifest error: env must be an object for server index {idx - 1}")
    if not isinstance(headers_map, dict):
        raise SystemExit(f"Manifest error: headers must be an object for server index {idx - 1}")

    cmd = ["npx", "-y", f"add-mcp@{add_mcp_version}", str(source)]

    if scope == "user":
        cmd.append("-g")

    if transport:
        cmd.extend(["--transport", str(transport)])

    if name:
        cmd.extend(["--name", str(name)])

    for key, value in env_map.items():
        cmd.extend(["--env", f"{key}={value}"])

    for key, value in headers_map.items():
        cmd.extend(["--header", f"{key}: {value}"])

    for agent in agents:
        cmd.extend(["-a", agent])
        target_scope_agents[scope].add(agent)

    cmd.append("-y")

    planned += 1
    print(f"\n[{planned}] {server.get('name', source)}")
    print(f"  scope:  {scope}")
    print(f"  agents: {', '.join(agents)}")
    print("  cmd:    " + shlex.join(cmd))

    if dry_run or check_only:
        continue

    subprocess.run(cmd, check=True)
    applied += 1

if not target_scope_agents:
    for agent in (cli_agents or default_agents):
        target_scope_agents[default_scope].add(agent)

# Preflight: discover existing MCP configuration for all targeted scopes/agents.
for scope in sorted(target_scope_agents):
    list_cmd = ["npx", "-y", f"add-mcp@{add_mcp_version}", "list"]
    if scope == "user":
        list_cmd.append("-g")

    for agent in sorted(target_scope_agents[scope]):
        list_cmd.extend(["-a", agent])

    print(f"\n[CHECK] existing MCPs scope={scope} agents={', '.join(sorted(target_scope_agents[scope]))}")
    print("  cmd:    " + shlex.join(list_cmd))
    if dry_run:
        continue

    subprocess.run(list_cmd, check=True)

if planned == 0:
    print("\nNo enabled MCP servers found in manifest.")

# Normalize names and installations across targeted agents only when explicitly enabled.
sync_runs = 0
if normalize_existing:
    for scope in sorted(target_scope_agents):
        sync_cmd = ["npx", "-y", f"add-mcp@{add_mcp_version}", "sync", "-y"]
        if scope == "user":
            sync_cmd.append("-g")

        for agent in sorted(target_scope_agents[scope]):
            sync_cmd.extend(["-a", agent])

        print(f"\n[SYNC] scope={scope} agents={', '.join(sorted(target_scope_agents[scope]))}")
        print("  cmd:    " + shlex.join(sync_cmd))

        if dry_run or check_only:
            continue

        subprocess.run(sync_cmd, check=True)
        sync_runs += 1
else:
    print("\n[SYNC] skipped (manifest-only mode; pass --normalize-existing to run add-mcp sync)")

print("\nMCP sync summary")
print(f"  Planned: {planned}")
print(f"  Applied: {applied if not (dry_run or check_only) else 0}")
print(f"  Scopes:  {len(target_scope_agents)}")
print(f"  Syncs:   {sync_runs if not (dry_run or check_only) else 0}")
print(f"  Normalize existing: {'yes' if normalize_existing else 'no'}")
print(f"  Mode:    {'check' if check_only else ('dry-run' if dry_run else 'apply')}")
PY
