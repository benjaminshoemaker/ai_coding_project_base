---
summary: Lightweight conversation-first workflow for AI coding agents, tuned for fast iteration with guardrails.
read_when:
  - Starting a new feature with an AI agent
  - Session quality is dropping due to prompt complexity
  - You need consistent commit hygiene and docs habits
---

# Agentic Workflow

This project uses a conversation-first approach:

1. Discuss options before editing for non-trivial tasks.
2. Estimate blast radius (files, risks, tests) before execution.
3. Execute in small, reversible steps.
4. Keep commits path-scoped and atomic.
5. Add tests right after implementation.
6. Keep docs current as behavior changes.

## Prompt Patterns

Use short prompts with clear intent:

- `Give me 2-3 options and tradeoffs before making changes.`
- `Estimate blast radius: files touched, risk level, and verification plan.`
- `Implement option 2 in small commits. Show progress after each step.`
- `Write or update tests for this change now.`
- `Status update: what's done, what's pending, and blockers?`

For UI tasks, prefer screenshot + concise instruction.

## Docs Index Convention

When adding docs in `docs/`, use this frontmatter:

```yaml
---
summary: One-line purpose of this doc.
read_when:
  - Situation where this doc should be read
  - Another trigger condition
---
```

These hints should be surfaced before coding by scanning `docs/` (for example `rg --files docs` and opening the relevant files).
