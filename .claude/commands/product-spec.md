---
description: "[DEPRECATED] Use /product-spec from your project directory instead."
argument-hint: [target-directory]
allowed-tools: Read, AskUserQuestion
---

**DEPRECATED:** This command has moved. The new `/product-spec` skill runs
from your project directory (no target-dir argument needed).

To use the new workflow:

1. `cd $1` (or your project directory)
2. Run `/product-spec`

The skill reads its prompt from `.claude/skills/product-spec/PROMPT.md` and
writes `PRODUCT_SPEC.md` to the current directory.
