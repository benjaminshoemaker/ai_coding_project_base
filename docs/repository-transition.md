# Repository Transition Plan

## Decision

The structured specification, planning, and phase-execution workflow in this
repository is no longer the recommended default for AI-assisted development.
Modern coding agents can usually plan, implement, and verify work directly when
they have good project context and deterministic feedback from tests, linting,
builds, and CI.

The replacement is not a smaller mandatory workflow. It is a lean operating
model:

1. Use substantial research when the domain, opportunity, or intended outcome
   is unclear.
2. Preserve conclusions and project-specific context when they will matter in
   later sessions.
3. Plan and prototype proportionally to the risk and reversibility of the work.
4. Invoke narrowly scoped skills only when their capability is useful.
5. Put mandatory guarantees in executable checks rather than prompt ceremony.

`bens_indispensable_skills` will be the canonical home for reusable skills.
This repository is now a deprecated reference and migration aid for the former
workflow.

## Desired End State

### `bens_indispensable_skills`

- Contains the curated set of independently useful skills.
- Does not require this repository's plans, phases, state files, or work-item
  conventions.
- Supports selective installation instead of distributing an entire workflow.
- Includes `project-research` for open-ended domain and opportunity research.
- Includes `design-directions` for exploring and evolving distinctive visual
  languages.

### Product Repositories

- Keep concise, project-specific agent instructions.
- Keep useful product, technical, research, and decision context.
- Use repository-native tests, linting, type checks, builds, and CI.
- Install only the skills the project or user actually needs.
- Remove stale phase state, generated plans, duplicated generic skills, and
  abandoned workflow artifacts from the active tree.
- Rely on Git history instead of in-repository archives for retired generic
  material that agents should no longer treat as context.

### This Repository

- Clearly identifies the old workflow as retired and deprecated.
- Provides a traceable disposition for every skill and major artifact.
- Supplies safe, dry-run-first migration support for existing projects.
- Stops publishing or synchronizing retired workflow components.
- Preserves the historical implementation in Git.

## Guardrails

- Do not mass-delete or mass-sync while the inventory is provisional.
- Do not overwrite the current dirty working tree to create a clean-looking
  transition.
- Preserve project-specific documents even when their filenames resemble
  generated toolkit artifacts.
- Make cleanup tools report-only by default and require explicit targets for
  mutations.
- Pilot migrations on representative repositories before applying them
  broadly.
- Audit retained or refactored skills independently of this workflow.

## Workstreams

### 1. Preserve and Inventory

Status: **Complete**

- Preserve the current uncommitted toolkit work before destructive cleanup.
- Classify every skill as keep, refactor, merge, or retire.
- Inventory commands, prompts, scripts, hooks, configuration, and documentation
  that exist solely to operate the old workflow.
- Identify which public repositories contain copied or synchronized artifacts.

The initial skill classification is in
[`skill-disposition.md`](skill-disposition.md).
The first-pass classification of commands, scripts, prompts, hooks, runtime
configuration, and documentation is in
[`artifact-disposition.md`](artifact-disposition.md).

### 2. Curate the Independent Skill Library

Status: **Complete**

- Treat `bens_indispensable_skills` as canonical.
- Finish and validate `project-research` and `design-directions`.
- Move retained skills out of this repository or confirm their canonical copy.
- Remove assumptions about phase files, plan directories, and toolkit-specific
  work tracking from retained skills.
- Merge overlapping skills when one clearer capability is sufficient.
- Run `audit-skills` and repository validation after each meaningful batch.

Completed: explicit selective installation, canonical reconciliation of
retained skills, promotion of `security-scan` and `tone-check`, retirement of
the five project-state/documentation skills, and validation of the changed
skill set. The decisions are recorded in the canonical library's
`docs/canonical-reconciliation.md`.

### 3. Stop Workflow Distribution

Status: **Complete**

- Replace broad skill-pack synchronization with selective installation.
- Remove retired skills from public manifests and global bootstrap behavior.
- Stop generating the old plan hierarchy and phase-state files for new
  projects.
- Update documentation so it no longer recommends the retired workflow.

The canonical installer now requires one or more `--skill` selections or an
explicit `--all`.

### 4. Build Migration Support

Status: **Complete for read-only migration**

- Maintain the read-only scanner documented in
  [`migration-scanner.md`](migration-scanner.md).
- Distinguish generic copied files from files containing project-specific
  decisions or content.
- Produce a proposed cleanup manifest before making changes.
- Keep cleanup as a reviewed repository-specific operation; no generic mutation
  mode was added.

The initial scanner reports copied `.claude/skills`, toolkit commands, phase
state, verification configuration, generic root prompts, plan manifests, and
generated plans. It separates high-confidence workflow artifacts, reusable
skills, and files that require content review. Filename matches alone are not
sufficient evidence for deletion.

### 5. Pilot Project Cleanup

Status: **First pilot complete**

- Select two or three projects with different amounts of toolkit residue.
- Run the scanner and review every proposed removal.
- Migrate each project to concise project-specific instructions and native
  verification.
- Compare agent effectiveness, context consumption, correction rate, and useful
  artifact retention before and after migration.
- Revise the migration rules before broader use.

The first local scan and proposed pilot set are recorded in
[`local-migration-inventory.md`](local-migration-inventory.md).
Selected GitHub-only or locally absent repositories are summarized in
[`github-migration-inventory.md`](github-migration-inventory.md).

`personal_site` was migrated in the isolated
`codex/remove-toolkit-residue` worktree. Its project-specific writing skills
and useful future-work context were retained; copied skill backups, commands,
phase state, verification logs, workstream scripts, and scoped plan instructions
were removed. The migrated branch passes its production build and Astro check.

### 6. Deprecate and Archive

Status: **Complete**

- Publish final transition guidance in this repository's README.
- Archive or clearly deprecate related workflow experiments where appropriate.
- Remove obsolete active backlog items rather than carrying them indefinitely.
- Preserve the final workflow implementation in Git history or a release tag.
- Stop treating this repository as an active project starter.

## Current Backlog Disposition

The existing backlog mostly extends the workflow being retired:

- Retire the execution-memory feature in its current phase-coupled form.
- Retire universal lightweight work tracking as a toolkit requirement.
- Retire spec regeneration, execution-command path handling, phase recovery,
  and generic review-queue work.
- Close the nested `.claude/` command-shadowing bug when broad command and skill
  copying is removed.
- Evaluate deployment-preview resolution, flow verification, session analysis,
  and code/data auditing as independent capabilities rather than discarding
  them automatically.

The former backlog and workflow implementation are preserved in Git history.

## Completion Criteria

The transition is complete when:

1. Every skill and major workflow artifact has an explicit disposition.
2. Retained skills work without this repository's workflow structure.
3. New projects are not instructed to adopt the old phase system.
4. Broad sync and bootstrap paths no longer publish retired components.
5. A dry-run migration inventory has been validated on representative repos.
6. Pilot projects retain useful context while removing obsolete agent-visible
   material.
7. This repository clearly points users to the independent skill library and
   is no longer presented as the recommended development workflow.

All seven criteria were met for the toolkit, canonical library, and first pilot
on 2026-09-29. Broader repository cleanup remains optional follow-on migration,
not unfinished work in this repository.
