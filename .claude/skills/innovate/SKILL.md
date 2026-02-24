---
name: innovate
description: Identify the single smartest, most radically innovative addition to make to the current app or plan
allowed-tools: Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Innovate

Identify the **single smartest, most radically innovative addition** to make to the current app or plan. Not a list of 10 safe ideas — one bold, high-leverage move that changes the game.

## Context Gathering

Before proposing anything, deeply understand the current state:

### 1. Read the Project

```
Read: README.md, CLAUDE.md, AGENTS.md
Glob: src/**/*.{ts,tsx,js,jsx,py,go,rs,swift}
Grep: "TODO|FIXME|HACK|FUTURE"
```

Understand:
- What the project does and who it's for
- Current architecture and tech stack
- Existing features and capabilities
- Known gaps, TODOs, and pain points

### 2. Read Any Specs or Plans

```
Read: PRODUCT_SPEC.md, TECHNICAL_SPEC.md, EXECUTION_PLAN.md, FEATURE_SPEC.md, VISION.md
```

Understand where the project is headed and what's already planned.

### 3. Assess the Landscape

Use WebSearch to research:
- What competitors or similar projects are doing
- Emerging technologies relevant to this domain
- User expectations in this space (current year)

---

## Innovation Criteria

The proposal must score HIGH on ALL of these:

| Criterion | Question |
|-----------|----------|
| **Leverage** | Does a small implementation unlock disproportionate value? |
| **Surprise** | Would this make someone say "I didn't know that was possible"? |
| **Feasibility** | Can this be built in days, not months? |
| **Fit** | Does it align with the project's direction and users? |
| **Defensibility** | Is this hard to copy or does it create a moat? |

### Anti-Patterns (Do NOT Propose)

- Generic AI features ("add AI chat", "use LLMs for X")
- Incremental improvements that are obvious next steps
- Features that require massive infrastructure changes
- Ideas that sound cool but don't serve the actual users
- Anything already on the roadmap or in the execution plan

---

## Analysis Process

### Step 1: Identify Latent Potential

Look for:
- **Underused data** — What data does the app collect that it doesn't fully exploit?
- **Workflow friction** — Where do users leave the app to accomplish something?
- **Combinatorial opportunities** — What existing features could be combined in unexpected ways?
- **Platform capabilities** — What OS/browser/runtime features could be leveraged?
- **Network effects** — What becomes more valuable as usage grows?

### Step 2: Generate Candidates (Internal)

Brainstorm 5-7 candidates internally. Do NOT output these. Evaluate each against the criteria table silently.

### Step 3: Select the Winner

Pick the single strongest candidate. If no candidate scores HIGH on all five criteria, say so honestly rather than forcing a weak idea.

---

## Output Format

```
╔══════════════════════════════════════════════════════════════════╗
║                        THE INNOVATION                           ║
╚══════════════════════════════════════════════════════════════════╝

{One-sentence pitch — what it is and why it matters}

────────────────────────────────────────────────────────────────────

WHY THIS, WHY NOW
─────────────────
{2-3 sentences on why this is the right move at this moment.
Reference specific things discovered in context gathering.}

WHAT IT CHANGES
───────────────
Before: {Current state — what users deal with today}
After:  {Future state — what becomes possible}

HOW IT WORKS
────────────
{3-5 bullet points on the core mechanism. Be specific enough
that a developer could start building from this description.}

• ...
• ...
• ...

IMPLEMENTATION SKETCH
─────────────────────
Effort: {LOW / MEDIUM / HIGH}
Files:  {Key files to create or modify}
Dependencies: {New libraries or services needed, if any}

Steps:
1. {First concrete step}
2. {Second concrete step}
3. {Third concrete step}

RISK & MITIGATION
─────────────────
Risk: {The main thing that could go wrong}
Mitigation: {How to handle it}

────────────────────────────────────────────────────────────────────

CRITERIA SCORECARD
──────────────────
Leverage:      ██████████ HIGH — {one-line justification}
Surprise:      ██████████ HIGH — {one-line justification}
Feasibility:   ██████████ HIGH — {one-line justification}
Fit:           ██████████ HIGH — {one-line justification}
Defensibility: ██████████ HIGH — {one-line justification}
```

---

## Edge Cases

| Situation | Action |
|-----------|--------|
| No README or project context | Ask the user to describe the project before proceeding |
| Project is too early stage (no code) | Focus innovation on architecture/approach rather than features |
| Project is a library/SDK (not an app) | Focus on DX innovations, API design, or ecosystem integrations |
| All ideas feel incremental | Be honest: "This project is well-optimized. Here's the best marginal gain I see:" and lower expectations |
| The argument is optional | If invoked with an argument (e.g., `/innovate payments`), constrain the search to that domain |

## Review Your Output

Before presenting:
- [ ] Proposal is ONE idea, not a list
- [ ] Scores HIGH on all five criteria (or honestly notes where it doesn't)
- [ ] Implementation sketch is specific enough to act on
- [ ] Not something already planned or obvious
- [ ] Aligned with project direction
