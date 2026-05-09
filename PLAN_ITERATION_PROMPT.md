# Prompt: Iterating Plans Without Polluting Repos

Explore a workflow for iterative product planning that lets agents move from discovery to product spec to technical spec to execution plan without leaving stale plans in active repo paths or confusing future agents.

Focus on:
- Where active plans should live versus archived plans.
- How to mark exactly one plan as current.
- How agents should treat old specs, rejected plans, feature experiments, and abandoned execution plans.
- Whether the toolkit should create `plans/current/`, `plans/archive/`, dated plan folders, or a manifest such as `plans/PLAN_STATUS.md`.
- How `/discover`, `/product-spec`, `/technical-spec`, `/generate-plan`, feature workflows, and AGENTS.md should hand off state.
- How to preserve useful prior thinking without letting agents accidentally implement obsolete requirements.
- What commands or skills should do automatically when a new plan supersedes an old one.

Use concrete examples from a repo that has historical greenfield plans, completed feature plans, and a new strategic pivot. Recommend a small, durable convention that works across Claude Code and Codex.
