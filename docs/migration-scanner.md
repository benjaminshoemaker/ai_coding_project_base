# Toolkit Residue Scanner

`scripts/scan-toolkit-residue.sh` produces a read-only inventory of files in a
target repository that may have come from the former AI Coding Project Toolkit.
It does not delete, move, or edit anything.

## Run It

```bash
./scripts/scan-toolkit-residue.sh /absolute/path/to/project
```

When the canonical library is available, compare copied reusable skills too:

```bash
./scripts/scan-toolkit-residue.sh \
  --canonical-skills /absolute/path/to/bens_indispensable_skills/skills \
  /absolute/path/to/project
```

The output is tab-separated so it remains readable in a terminal and can be
redirected for later review:

```text
CONFIDENCE  PATH  REASON
HIGH        .toolkit-marker  Toolkit metadata or transient workflow state
REVIEW      plans/greenfield/PRODUCT_SPEC.md  Generated-plan filename; preserve project-specific decisions before cleanup
```

## Interpret Findings

- **HIGH** identifies strong toolkit markers or generic components of the
  retired workflow. Confirm the path is not project-specific before removal.
- **MEDIUM** identifies a known reusable skill copied into the repository.
  With canonical comparison enabled, this means the local copy matches and can
  usually be replaced by selective global installation.
- **REVIEW** identifies plans or instructions that may contain genuine product
  decisions, unresolved ideas, or durable learning. It also identifies copied
  skills that differ from the canonical library. Extract or retain useful
  context and modifications before cleanup.

An unreported file is not automatically safe or relevant. The scanner is a
bounded inventory of known toolkit residue, not a general repository audit.

## Preserve Ideas Before Cleanup

Files such as `NEXT_FEATURES.md`, `NEXT_STEPS.md`, `DEFERRED.md`,
`BUGS.md`, `LEARNINGS.md`, `TODOS.md`, and generated plans may contain
valuable ideas even when their workflow conventions are being retired.
Top-level `features/<name>/` directories containing briefs, discovery notes,
specifications, or execution plans receive the same protection. The scanner
reports these as `REVIEW`, never as automatic deletion candidates.

For each target repository:

1. Read every `REVIEW` file and identify unresolved feature ideas, product
   questions, technical improvements, bugs, and durable decisions.
2. Remove duplicates and distinguish completed or obsolete history from ideas
   that are still worth considering.
   For feature directories, determine whether the feature is only an idea,
   planned, implemented, completed, superseded, or abandoned; do not infer
   status from the directory name alone.
3. Move the surviving content to the repository's natural long-lived surface:
   an existing roadmap, issue tracker, README section, product document, or a
   small `IDEAS.md` when no better home exists.
4. Preserve enough provenance to understand the idea, including its original
   source or rationale when that context matters. Do not carry forward phase
   numbers, generated task IDs, or stale priority claims as if they remain
   authoritative.
5. Compare the migration diff before removing the old file and verify that
   every worthwhile unresolved idea has a destination.

The goal is to retire workflow ceremony, not erase product memory.

## Safety Model

- The scanner accepts exactly one target directory and an optional canonical
  skill directory.
- It reads filenames and a small set of known instruction files.
- It has no mutation or deletion mode.
- Migration remains a separate, explicitly reviewed action.

Run the behavior test after changing scanner rules:

```bash
bash tests/test-scan-toolkit-residue.sh
```
