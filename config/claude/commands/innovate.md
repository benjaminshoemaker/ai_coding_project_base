---
description: Identify the single smartest, most radically innovative addition to make to the current app or plan
allowed-tools: Read, Glob, Grep, Task, WebSearch
---

# Innovate

Generate the single most radically innovative, accretive, and compelling addition for the current project context.

## Step 1: Detect Context

Determine whether the current project is an **app** (built or in-progress codebase) or a **plan** (spec/feature in design phase).

**Check for plan indicators** in the working directory and one level up:
- `EXECUTION_PLAN.md` with incomplete tasks (`- [ ]`)
- `FEATURE_SPEC.md`
- `FEATURE_TECHNICAL_SPEC.md`
- Working directory is inside a `features/` subdirectory

**If ANY plan indicator is found** → context is **"plan"**
**Otherwise** → context is **"app"**

## Step 2: Load Project Context

Read the following files if they exist (skip missing ones silently):

**Always read:**
- `PRODUCT_SPEC.md` or `README.md` (understand what the project is)
- `VISION.md` (understand strategic direction)
- `DESIGN_SYSTEM.md` (understand design constraints)
- `TECHNICAL_SPEC.md` (understand architecture)
- `TODOS.md` (understand known gaps)

**If plan context**, also read:
- `EXECUTION_PLAN.md`
- `FEATURE_SPEC.md`
- `FEATURE_TECHNICAL_SPEC.md`

**If app context**, also explore:
- `package.json` (dependencies and capabilities)
- App directory structure (routes, pages, components — high-level only)
- Database schema files (understand data model)

## Step 3: Catalog Existing Ideas

Identify and read ALL existing feature proposals, roadmap items, and post-MVP ideas so you know what's already been captured. Check:

- `features/` or `features/*/` directories — read every spec file
- Post-MVP sections in PRODUCT_SPEC.md or TECHNICAL_SPEC.md
- Any `ROADMAP.md` or similar files

Build a mental list of every idea already captured. You must not propose something that overlaps with these.

## Step 4: Generate the Recommendation

Now answer this question with depth and conviction:

> **Excluding ideas already captured in existing feature proposals and roadmap items, what's the single smartest and most radically innovative and accretive and useful and compelling addition you could make to the {CONTEXT} at this point?**

Where `{CONTEXT}` is either "app" or "plan" based on Step 1.

### Requirements for your answer:

1. **One idea, not a list.** Commit to a single recommendation. No hedging with "alternatively..."
2. **Concrete, not abstract.** Describe what the user would see and do, not just a concept name.
3. **Explain WHY this is the #1 pick** — what makes it smarter than other options you considered.
4. **Address feasibility** — how it builds on what already exists.
5. **Name the idea** with a clear, memorable title.
6. **Be genuinely radical** — if the idea feels safe or obvious, push further. The user wants to be surprised.
