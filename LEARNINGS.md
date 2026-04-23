# Session Learnings

> Persistent knowledge extracted from AI coding sessions.
> Captures decisions, context, action items, and insights that should survive between sessions.
> Add entries with `/capture-session` (full sweep) or `/capture-learning` (single item).

## Decisions

- **[2026-04-23]** Adopt a canonical machine-level runtime flow in toolkit scripts: `bootstrap-agent-runtime.sh` orchestrates both skills sync and MCP sync for Claude Code + Codex. *(source: conversation + implementation)*
- **[2026-04-23]** Use a single MCP manifest at `config/mcp/servers.json` with pinned `add-mcp` version (`1.8.0`) as source of truth for cross-agent MCP setup. *(source: conversation + implementation)*
- **[2026-04-23]** Preserve existing non-toolkit skills and existing `~/.codex/skills` by default; make takeover behavior explicit opt-in (`--adopt-unmanaged-skills`, `--adopt-codex-shim`, both requiring `--force`). *(source: conversation + implementation)*
- **[2026-04-23]** Keep backward compatibility: `scripts/configure-codex-mcp.sh` remains available but delegates into shared manifest-based MCP sync logic for Codex-only targeting. *(source: implementation)*
- **[2026-04-23]** Standardize toolkit-managed projects on global-only skill resolution: `.claude/skills/` local copies are treated as migration debt and should be removed after backup. *(source: conversation + implementation)*
- **[2026-04-23]** Execute global migration on this machine for all detected legacy projects linked to this toolkit; update each project’s `toolkit-version.json` to `force_local_skills: false` and `skill_resolution: global`. *(source: runtime execution)*

## Action Items

- [ ] **[2026-04-23]** Apply `./scripts/bootstrap-agent-runtime.sh` on the second laptop and validate with `--check` to align both machines. — Owner: user
- [ ] **[2026-04-23]** Decide whether to adopt codex shim takeover (`--force --adopt-codex-shim`) on each machine after confirming local Codex behavior. — Owner: user
- [ ] **[2026-04-23]** Run `update-target-projects` equivalent on the second laptop so legacy target projects there are migrated to global skill resolution with backups. — Owner: user
- [ ] **[2026-04-23]** Investigate the malformed combined project path emitted in `.claude/sync-pending.json` and patch hook JSON generation. — Owner: toolkit maintainer

## Context

- **[2026-04-23]** Primary workflow requirement: seamless switching between two laptops with different primary agents (Codex CLI and Claude Code) while keeping both skills and MCPs consistently available. *(source: user)*
- **[2026-04-23]** macOS-only operational constraint for this setup; cross-platform symlink concerns are not in scope for the current implementation. *(source: user)*
- **[2026-04-23]** Migration run affected 17 toolkit-linked projects under `~/Projects`; toolkit-managed local skills were backed up to `.claude/skills.bak/migrate-global-20260423-160350/` before removal. *(source: runtime execution)*
- **[2026-04-23]** Several projects contained non-toolkit custom local skill directories (1-3 per project); those were preserved instead of removed. *(source: runtime execution)*

## Bugs & Issues

- **[2026-04-23]** `add-mcp sync` can normalize MCPs across targeted agents and introduce additional MCP entries to Claude Code from Codex (observed for `chrome-devtools` and `expo`). Status: open (behavior acknowledged, not disabled). *(source: runtime output from bootstrap apply)*
- **[2026-04-23]** `.claude/sync-pending.json` included one malformed concatenated project path entry (`auto_orchestrator calc-example-2 ...`) instead of individual paths. Status: open (hook output formatting bug). *(source: runtime inspection)*
- **[2026-04-23]** Codex shim remains preserved (not adopted) because `~/.codex/skills` is an existing non-symlink path; runtime deliberately left it untouched. Status: expected/open decision. *(source: runtime output from bootstrap apply)*

## Deferred Investigations

- **[2026-04-23]** Add a stricter MCP mode that applies manifest entries but skips global cross-agent normalization (`add-mcp sync`) for users who want manifest-only propagation. *(source: discussion after bootstrap output)*
- **[2026-04-23]** Extend MCP manifest schema to support explicit include/exclude sync policies per agent and per scope if stricter separation is required later. *(source: design follow-up)*
- **[2026-04-23]** Add a dedicated executable `update-target-projects` backend script so migrations are script-driven rather than reconstructed from skill instructions. *(source: implementation friction during this session)*
