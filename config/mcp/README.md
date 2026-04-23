# MCP Manifest

`servers.json` is the toolkit's single source of truth for machine-level MCP setup across agents.

- `defaults.scope`
  - `user` (recommended): install globally for the current user
  - `project`: install in the current project
- `defaults.agents`
  - Default target agents when a server does not define `agents`

Each entry in `servers` supports:

- `name` (optional): explicit server name override in `add-mcp`
- `source` (required): package, URL, or full command string accepted by `add-mcp`
- `scope` (optional): `user` or `project`
- `agents` (optional): array of agent ids (for example `claude-code`, `codex`)
- `transport` (optional): `http` or `sse` for remote servers
- `env` (optional): map of environment variables
- `headers` (optional): map of HTTP headers
- `enabled` (optional, default `true`): set `false` to skip a server

Apply this manifest with:

```bash
./scripts/sync-agent-mcps.sh
```

`sync-agent-mcps.sh` performs three steps:

1. Check existing MCPs for targeted agents/scopes (`add-mcp list`)
2. Apply manifest MCP entries (`add-mcp <source> ...`)
3. Normalize/sync existing and newly-added MCP names/installations (`add-mcp sync`)

For full machine bootstrap (skills + MCPs):

```bash
./scripts/bootstrap-agent-runtime.sh
```
