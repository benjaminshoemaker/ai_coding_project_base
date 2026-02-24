---
description: "[DEPRECATED] Use /technical-spec from your project directory instead."
argument-hint: [target-directory]
allowed-tools: Read, AskUserQuestion
---

**DEPRECATED:** This command has moved. The new `/technical-spec` skill runs
from your project directory (no target-dir argument needed).

To use the new workflow:

1. `cd $1` (or your project directory)
2. Run `/technical-spec`

Prerequisites: `PRODUCT_SPEC.md` must exist in the project directory.

The skill reads its prompt from `.claude/skills/technical-spec/PROMPT.md` and
writes `TECHNICAL_SPEC.md` to the current directory.
