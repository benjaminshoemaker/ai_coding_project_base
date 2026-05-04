# Codex CLI User-Level Config

Template for `~/.codex/config.toml` that can be laid down on a fresh machine.

## Files

| File | Lays down at | Notes |
|------|--------------|-------|
| `config.toml.example` | `~/.codex/config.toml` | Model, sandbox roots, trusted projects, notice flags, MCP servers, plugin enablement |

## Apply on a fresh machine

```bash
./scripts/sync-agent-configs.sh        # idempotent — won't overwrite an existing config.toml
./scripts/sync-agent-configs.sh --force # overwrite (backs up first)
```

After copy, edit `~/.codex/config.toml` to:

1. Set `[sandbox_workspace_write].writable_roots` to your machine's paths.
2. Add `[projects."/path"]` trust entries for each repo root you work in.
3. Add personal MCPs (Glean, Count, etc.) — see `config/mcp/servers.local.json.example`.

## Why MCPs are duplicated between this file and `config/mcp/servers.json`

The toolkit's preferred path is to install MCPs via `add-mcp` (run by
`scripts/sync-agent-mcps.sh`), which writes Claude Code's `~/.claude/.mcp.json`
**and** Codex's `~/.codex/config.toml` simultaneously. The `[mcp_servers.*]`
blocks in this template are present so the file is a complete, drop-in default
even before `sync-agent-mcps.sh` runs.
