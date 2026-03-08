# Feature Development Workflow

This guide covers adding features to existing projects using the toolkit's feature workflow.

## Overview

Features are isolated in their own directories under `features/<name>/`, enabling multiple concurrent features without document conflicts.

## Quick Start

```bash
# Specification runs from project root (after /setup):
cd ~/Projects/existing-app
/feature-spec analytics
/feature-technical-spec analytics
/feature-plan analytics

# Execution runs from the feature directory:
cd features/analytics
/fresh-start    # Detects feature mode, auto-advances through phases
```

**Important:** Specification commands (`/feature-spec`, `/feature-technical-spec`, `/feature-plan`) run from the project root. Execution commands (`/fresh-start`, `/phase-start`, `/phase-checkpoint`) run from `features/<name>/`. The skills auto-detect feature mode from the directory path.

## Directory Structure

Each feature gets its own directory with isolated planning documents:

```
your-project/
├── AGENTS.md                    # Shared workflow rules
├── plans/
│   └── greenfield/
│       ├── EXECUTION_PLAN.md
│       └── AGENTS.md
├── DEFERRED.md                  # Project-wide deferred requirements
├── features/
│   ├── analytics/
│   │   ├── FEATURE_SPEC.md
│   │   ├── FEATURE_TECHNICAL_SPEC.md
│   │   ├── EXECUTION_PLAN.md
│   │   ├── AGENTS.md
│   │   └── CLAUDE.md
│   └── notifications/
│       ├── FEATURE_SPEC.md
│       ├── FEATURE_TECHNICAL_SPEC.md
│       ├── EXECUTION_PLAN.md
│       ├── AGENTS.md
│       └── CLAUDE.md
└── [your code]
```

Note: `DEFERRED.md` lives at the project root (not in feature directories) since deferred items often span features or apply to the whole project.

## Output Documents

| Document | Purpose |
|----------|---------|
| `FEATURE_SPEC.md` | Defines *what* the feature does and *why* |
| `FEATURE_TECHNICAL_SPEC.md` | Defines *how* the feature integrates technically |
| `EXECUTION_PLAN.md` | Breaks feature work into phases, steps, and tasks |
| `AGENTS.md` | Feature-local workflow guidance layered on top of the root `AGENTS.md` |

## Deferred Requirements

During spec Q&A, when you mention something is "out of scope," "v2," or "for later," the toolkit prompts you to capture it:

```
"Would you like to save this to your deferred requirements?"
○ Yes, capture it — I'll ask a few quick questions to document it
○ No, skip — Don't record this
```

If you choose to capture, it asks clarifying questions (what's being deferred, why, notes for later) and immediately appends to `PROJECT_ROOT/DEFERRED.md`. This prevents good ideas from getting lost during rapid specification work.

## Git Branching

For feature development, `/fresh-start` creates nested branches:

```
main
  └── feature/analytics (branch)
        └── phase-1 (branch)
              ├── task(1.1.A): ...
              ├── task(1.1.B): ...
              └── task(1.2.A): ...
```

## Feature-Local AGENTS.md

`/feature-plan` now writes a complete `features/<name>/AGENTS.md` for scoped execution:

1. Root `AGENTS.md` stays durable and project-wide
2. Feature-local `AGENTS.md` adds only the context and workflow deltas needed inside `features/<name>/`
3. `features/<name>/CLAUDE.md` loads that local file automatically for Claude Code

There is no merge step. If a feature discovers a rule that should apply project-wide, promote it to the root `AGENTS.md` deliberately instead of accumulating ad hoc additions there.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPECIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Feature Idea                                                     │
│       ↓                                                                 │
│   /feature-spec <name>  ────→  FEATURE_SPEC.md                          │
│       ↓                                                                 │
│   /feature-technical-spec <name>  ──→  FEATURE_TECHNICAL_SPEC.md        │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Inputs: Specs + existing AGENTS.md                                    │
│       ↓                                                                 │
│   /feature-plan <name>  ────→  EXECUTION_PLAN.md + AGENTS.md            │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXECUTION PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   cd features/<name>/                                                   │
│       ↓                                                                 │
│   /fresh-start  ────────→  Load root + local AGENTS, auto-advance       │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```
