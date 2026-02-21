# Workflow Automation

The toolkit automates phase progression, verification, and project syncing so you can focus on the work that requires human judgment.

## Simplified Execution

After generating specs and plan, execution is typically **one command**:

```bash
cd ~/Projects/my-app     # or cd features/<name>/ for feature work
/fresh-start
```

`/fresh-start` auto-chains the entire execution workflow:

```
/fresh-start → /phase-prep 1 → /phase-start 1 → /phase-checkpoint 1 → /phase-prep 2 → ...
                     ↓              ↓                  ↓
                 (if ready)    (if no manual)    (if all pass)
```

The chain stops when human input is needed (manual verification, external setup, stuck detection) and resumes when you re-run `/fresh-start` or the specific phase command.

## Auto-Advance

**Core Principle:** If AI completes verification, AI auto-advances. If human intervention is needed, human triggers the next step.

| Command | Auto-Advances To | Conditions |
|---------|------------------|------------|
| `/phase-prep N` | `/phase-start N` | All setup items pass |
| `/phase-start N` | `/phase-checkpoint N` | All tasks complete, no truly manual checkpoint items |
| `/phase-checkpoint N` | `/phase-prep N+1` | All checks pass, no truly manual items, more phases exist |

Auto-advance executes immediately when conditions are met. Use `--pause` on any phase command to disable it for that invocation.

**Configuration** (`.claude/settings.local.json`):
```json
{
  "autoAdvance": {
    "enabled": true
  }
}
```

Codex cross-model review findings are auto-implemented during checkpoints — a Task subagent applies fixes, re-runs verification, and commits if all checks pass (or reverts and logs to the deferred queue if not). Blocking manual items halt the checkpoint deterministically without prompting.

When auto-advance stops (blocking manual items exist, a check fails, or the final phase completes), a session report shows all completed steps and what caused it to stop.

## Git Workflow

During execution, the toolkit enforces a structured git workflow:

- **One branch per phase** — `phase-1`, `phase-2`, etc.
- **One commit per task** — Immediately after verification passes
- **No auto-push** — Human reviews at checkpoint before pushing

```
main
  └── phase-1
        ├── task(1.1.A): Add user model
        ├── task(1.1.B): Add user routes
        └── task(1.2.A): Add auth middleware
```

For feature development, branches nest: `main → feature/analytics → phase-1`.

## Keeping Projects Updated

When the toolkit receives updates (new skills, bug fixes), sync them to your projects:

```bash
# Sync all toolkit-using projects at once (from toolkit directory)
/update-target-projects

# Sync a specific project
/sync ~/Projects/my-app
```

After committing skill changes to the toolkit, a post-commit hook reminds you to sync.

The sync command:
- **Detects changes** by comparing file hashes against the last sync
- **Auto-applies** new files and clean updates (no local modifications)
- **Prompts for conflicts** when you've customized a file locally
- **Tracks state** in `.claude/toolkit-version.json`

| Change Type | Action |
|-------------|--------|
| New toolkit file | Auto-copy without prompting |
| Toolkit updated, no local changes | Auto-copy without prompting |
| Toolkit updated, local changes exist | Show diff, ask: overwrite / skip / backup |
| File removed from toolkit | Warn, offer to delete (default: keep) |

## Parallel Workstreams

Run multiple AI agents in parallel using git worktrees. Each worktree gets isolated dependencies, env files, and dev server ports:

```bash
# Create a worktree for a feature
git worktree add ../my-feature -b feature/my-feature
cd ../my-feature

# Initialize it (installs deps, copies .env, symlinks settings)
bash .workstream/setup.sh

# Start dev server (auto-allocates a port unique to this worktree)
bash .workstream/dev.sh

# Run full quality gate before PR
bash .workstream/verify.sh
```

The `.workstream/` scripts are orchestrator-agnostic — they work with Codex App (worktree mode), Claude Code, Conductor, or manual usage. Each project can optionally create a `workstream.json` to configure dev commands, ports, and verification steps.

**Codex App:** Configure `bash .codex/setup.sh` as the setup script in Settings (Cmd+,) → Local Environments. When creating a worktree thread, select this environment and Codex will automatically get a ready-to-use workspace.

See [Codex App Workflows](../CODEX_APP_WORKFLOWS.md) for detailed parallel workflow patterns and `.workstream/README.md` for script documentation.

## Local-First Verification

Phase checkpoints run local verification first (tests, lint, security scan). Production verification (deployment, integration) only runs after local passes. This prevents wasted cycles on production checks when basic issues exist.

See [Verification Deep Dive](verification.md) for the full verification system.
