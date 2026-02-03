# Codex App Agent Instructions

This file provides instructions for Codex App threads working in this project.

## Full Context

For complete project context, coding standards, and architecture details, see
the main **AGENTS.md** at the repository root.

## Workstream Contract

This project uses the workstream contract (`.workstream/`) for environment setup
and verification. The scripts are orchestrator-agnostic and work with Codex App,
Claude Code, or manual usage.

### Available Scripts

| Script | When to use |
|--------|-------------|
| `.workstream/setup.sh` | Already run by Codex App on thread creation (via `.codex/setup.sh`) |
| `.workstream/dev.sh [PORT]` | Start the dev server when you need to test changes locally |
| `.workstream/verify.sh` | **Run before creating PRs** — executes typecheck, lint, test, build |

### Before Creating a PR

**Preferred:** Use the `/create-pr` skill instead of the Create PR button:

```
/create-pr
```

This automatically runs `.workstream/verify.sh` before creating the PR.

**Alternative:** If using the Create PR button, manually run verification first:

```bash
bash .workstream/verify.sh
```

Fix any failures before creating the pull request.

### Dev Server

If you need a running dev server for testing:

```bash
bash .workstream/dev.sh
```

The port is auto-allocated based on the worktree directory. Check the output
for the assigned port number.

## Codex App Setup

Codex App reads the following from `.codex/`:

- **AGENTS.md** (this file) — Agent instructions shown to every thread
- **Skills** (`.codex/skills/`) — Custom Codex skills (if any)

The following must be configured via the **Codex App UI**:

- **Setup script** — Settings (Cmd+,) → Local Environments → set setup
  script to `bash .codex/setup.sh`
- **Common actions** — Settings → Local Environments → Actions (optional)

The setup script delegates to `.workstream/setup.sh`, which handles dependency
installation, env file provisioning, and settings symlinks.
