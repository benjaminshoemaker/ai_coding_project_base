# GitHub Migration Inventory

Snapshot date: 2026-09-29

The default-branch trees of selected repositories under
`github.com/benjaminshoemaker` were inspected through the GitHub API. This was a
read-only path scan; repositories were not cloned or modified.

## Results

| Repository | High | Medium | Review |
|---|---:|---:|---:|
| `benshoemaker-us` | 9 | 0 | 1 |
| `tally_analytics` | 9 | 0 | 19 |
| `verifiable_feature_delivery` | 0 | 0 | 0 |
| `vibecode_spec_generator` | 0 | 0 | 0 |
| `vibe_code_agent_workflow` | 0 | 0 | 0 |
| `just_talk_to_it` | 0 | 0 | 0 |
| `devplan-pm` | 0 | 0 | 0 |
| `tally-pages-router-test-project` | 0 | 0 | 0 |
| `tally-app-router-test-project` | 0 | 0 | 0 |

`benshoemaker-us` has three project-specific skills (`braindump`, `draft-post`,
and `pre-publish-check`); the scanner did not classify them as toolkit copies.
Its findings come from other known workflow artifacts.

`tally_analytics` contains substantial execution-plan history, including active
feature paths and archived plans. Those are review findings, not approved
removals.

The repositories with zero findings may still be related workflow experiments.
They simply do not contain paths recognized by the current residue rules.
Deprecating or archiving them is a repository-purpose decision, not a mechanical
cleanup decision.

## Limitations

- The scan covered the selected likely workflow repositories, not every account
  repository.
- It inspected paths, not file contents, so it did not classify root agent
  instructions by their text.
- It inspected only each repository's current default branch.
- It did not inspect issues, releases, pull requests, or non-default branches.
- It did not infer that a repository should be archived from its name or topic.

These results are sufficient to identify additional review candidates without
creating a broad remote cleanup operation.
