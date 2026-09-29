# AI Coding Project Base (Retired)

This repository no longer ships or recommends a mandatory specification,
planning, phase-execution, or project-state workflow. The previous toolkit is
preserved in Git history; the active tree now contains only migration guidance
and a read-only residue scanner.

Reusable skills live in
[`bens_indispensable_skills`](https://github.com/benjaminshoemaker/bens_indispensable_skills)
and should be installed selectively.

## Migrate an Existing Project

Start with the [repository transition](docs/repository-transition.md), then use
the [migration scanner guide](docs/migration-scanner.md):

```bash
./scripts/scan-toolkit-residue.sh /absolute/path/to/project \
  --canonical-skills /absolute/path/to/bens_indispensable_skills/skills
```

The scanner is read-only. Its findings are review prompts, not deletion
instructions. Preserve project-specific decisions and useful context before
removing copied workflow machinery.

Supporting inventories:

- [Skill disposition](docs/skill-disposition.md)
- [Artifact disposition](docs/artifact-disposition.md)
- [Local migration inventory](docs/local-migration-inventory.md)
- [GitHub migration inventory](docs/github-migration-inventory.md)

## Historical Toolkit

The complete pre-retirement state is preserved by commit `c4c30c5` on the
`codex/toolkit-retirement` branch. Use Git history to inspect or recover old
files; do not restore them to active projects by default.

## Validate This Repository

```bash
bash tests/test-scan-toolkit-residue.sh
npm run lint
```

## License

MIT
