---
description: "[DEPRECATED] Use /generate-plan from your project directory instead."
argument-hint: [target-directory]
allowed-tools: Read, AskUserQuestion
---

**DEPRECATED:** This command has moved. The new `/generate-plan` skill runs
from your project directory (no target-dir argument needed).

To use the new workflow:

1. `cd $1` (or your project directory)
2. Run `/generate-plan`

Prerequisites: `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md` must exist in the project directory.

The skill reads its prompt from `.claude/skills/generate-plan/PROMPT.md` and
generates `EXECUTION_PLAN.md` and `AGENTS.md` in the current directory.

**Note:** This skill no longer copies execution skills or creates `toolkit-version.json`.
Run `/setup` from the toolkit first to install execution skills.
