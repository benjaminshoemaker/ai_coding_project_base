# Claude Code User-Level Config

Templates for `~/.claude/` config that can be laid down on a fresh machine.
These are user-level (machine-wide for one user), not project-scoped.

## Files

| File | Lays down at | Notes |
|------|--------------|-------|
| `settings.json.example` | `~/.claude/settings.json` | Status line, tool search, plugin enablement, effort level |
| `statusline.sh` | `~/.claude/statusline.sh` | Custom status line script (model + dir + git + Claude usage). Referenced by `settings.json`. |
| `commands/github-init.md` | `~/.claude/commands/github-init.md` | Standalone user-level slash command |
| `commands/innovate.md` | `~/.claude/commands/innovate.md` | Standalone user-level slash command |

## Apply on a fresh machine

```bash
./scripts/sync-agent-configs.sh        # idempotent — won't overwrite existing files
./scripts/sync-agent-configs.sh --force # overwrite (backs up first)
```

## Notes on `settings.local.json`

`~/.claude/settings.local.json` holds the per-machine permission allowlist
(Bash patterns the user has approved, MCP server enablement, etc.). It is
intentionally **not** templated here — it accumulates organically per machine
and contains paths/decisions specific to that environment.

## Plugins

`settings.json.example` enables `code-simplifier@claude-plugins-official`. To
install it on a new machine:

```bash
claude plugin install code-simplifier@claude-plugins-official
```
