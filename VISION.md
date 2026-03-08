# Vision

## How to Read This Document

This document is organized in layers, from stable to adaptable:

| Layer | Changes | Purpose |
|-------|---------|---------|
| **Problem & Aspiration** | Rarely | Why we exist |
| **Principles** | Rarely | Values that guide all decisions |
| **Outcomes** | Sometimes | What success looks like (measurable) |
| **Practices** | Often | Current tactics (examples, not mandates) |

**Principles are stable; practices evolve.** When evaluating changes, ask:
"Does this achieve the outcome?" not "Does this match the current practice?"
For example, "code is verified before commit" is an outcome. Whether that
verification happens locally, on a preview deployment, or via some future
approach is a tactical choice that can change.

Commands, tools, and specific implementations mentioned in this document are *examples* of how we currently achieve outcomes, not prescriptions.

---

## Problem

AI coding assistants are unreliable. Requirements get lost mid-conversation, scope creeps without warning, code quality varies wildly, and there's no consistent way to verify the AI did what was asked. The result: developers spend as much time supervising AI as they would writing the code themselves.

## Aspiration

**Reduce the overhead of supervising AI coding to near-zero.**

The toolkit should handle the tedious parts—tracking requirements, enforcing quality, verifying completion—so developers can focus on decisions that actually need human judgment.

## Principles

When evaluating proposed work, apply these filters in order:

1. **Simplicity over capability** — Remove useful features if they add too much complexity. The toolkit should feel lightweight, not like enterprise middleware.

2. **Flexibility over guardrails** — Don't force users into workflows. Provide structure that helps; don't mandate structure that restricts.

3. **90% rule** — Include only what 90% of solo developers would want. Niche needs belong in user customization, not the core toolkit.

## AI Strengths and Weaknesses

The toolkit's design is shaped by what AI agents are good and bad at.

**Lean on these strengths:**
- Following explicit instructions (e.g., AGENTS.md, acceptance criteria)
- Rigorous testing when the process enforces it
- Working methodically from clear specifications
- Executing well-defined, bounded tasks

**Guard against these weaknesses:**
- Context and progress loss across sessions
- Scope creep without external constraints
- Inconsistent quality without verification checkpoints
- Getting stuck in loops without escalation

## Scope

**In scope:** Specification → Planning → Execution → Verification

The toolkit helps you go from an idea to verified, committed code.

**Out of scope:**
- Upstream of specification (ideation, market research, design)
- Downstream of verification (deployment, monitoring, iteration)
- Multi-developer coordination
- Platform portability (this is Claude Code-native)

## Success

The toolkit is working when:

- A developer can go from idea to verified, committed code with minimal supervision. *(e.g., currently: `/product-spec` → `/technical-spec` → `/generate-plan` → `/phase-start`)*
- Time-to-completion drops because supervision overhead is minimal.
- More projects get built because the barrier to reliable AI coding is lower.
- Any AI agent (or human) can pick up where work left off by reading the artifacts.
- State persists across sessions—pause, leave, come back, continue.
