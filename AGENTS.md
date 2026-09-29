# AGENTS.md (Retired Toolkit)

This repository preserves migration documentation and a read-only scanner for
projects created with the retired AI coding workflow. It is not an executable
project workflow and must not install, sync, or revive the former machinery
unless the user explicitly requests recovery from Git history.

## Active Scope

- Transition and migration documentation under `docs/`
- `scripts/scan-toolkit-residue.sh`
- `tests/test-scan-toolkit-residue.sh`
- Repository lint configuration

Reusable skills are maintained separately in `bens_indispensable_skills`.

## Editing Rules

- Keep the scanner read-only and test behavior changes first.
- Treat scanner findings as review prompts, never automatic deletion approval.
- Preserve project-specific context before removing residue from a target repo.
- Call out changes to target-project instruction or security files explicitly.
- Do not reintroduce phase state, plan manifests, copied skill trees, hooks, or
  mandatory document pipelines.
- Use Git history when historical workflow material is needed.

## Verification

Run both checks after relevant changes:

```bash
bash tests/test-scan-toolkit-residue.sh
npm run lint
```
