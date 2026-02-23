---
name: vision-audit
description: Audit project alignment with VISION.md, identify SDLC gaps, and generate feature proposals. Use when reviewing strategic direction or planning new features.
allowed-tools: Read, Glob, Grep, Bash, WebSearch
---

# Vision Audit

A comprehensive audit that evaluates the toolkit against its vision, compares to SDLC outcomes, researches the landscape, and **generates feature proposals** with rationale.

This is both an audit tool and a **roadmap generator**.

**Key principle:** Focus on *outcomes*, not practices or tools. Proposals should achieve outcomes in ways that align with our principles and differentiate from competitors.

## Scope

This skill is **toolkit-specific**. It reads the toolkit's direction documents and generates proposals for improvement. Not synced to target projects.

## Trigger

Manual only. Run `/vision-audit` when you want to:
- Check alignment with vision and SDLC outcomes
- Get researched feature proposals
- Understand competitive positioning

---

## Prerequisites

The following documents should exist in the repository root:

| Document | Purpose | Required? |
|----------|---------|-----------|
| **VISION.md** | Principles, scope, success criteria | Yes |
| **SDLC_REFERENCE.md** | Outcomes to achieve | Yes |
| **COMPETITORS.md** | Landscape analysis, differentiation | Recommended |

If COMPETITORS.md is missing, proposals will lack competitive context but audit will still run.

---

## Workflow

Copy this checklist and track progress:

```
Vision Audit Progress:
- [ ] Phase 1: Parse direction documents
- [ ] Phase 2: Gather evidence from codebase
- [ ] Phase 3: Evaluate vision alignment (R/Y/G scoring)
- [ ] Phase 4: Classify SDLC outcomes (ACHIEVED / AVOIDED / OPPORTUNITY)
- [ ] Phase 5: Research opportunities (web search + competitor check)
- [ ] Phase 6: Generate proposals with rationale
- [ ] Phase 7: Output combined report
```

---

## Part A: Vision Alignment Audit

### Phase 1: Parse Direction Documents

Read and extract from each document:

**VISION.md:**
| Section | Extract |
|---------|---------|
| Problem | Context (not scored) |
| Aspiration | Core goal |
| Principles | Numbered principles (priority order) |
| AI Strengths | What to leverage |
| AI Weaknesses | What to guard against |
| Scope In/Out | Boundaries for classification |
| Success | Measurable criteria |

**SDLC_REFERENCE.md:**
- All outcomes by phase (1.1, 1.2, 2.1, etc.)
- "Why it matters" for each

**COMPETITORS.md:**
- Competitor list and philosophies
- Feature matrix (what they have vs us)
- Strengths to learn from
- Our unique differentiation
- Gaps & opportunities already identified

### Phase 2: Gather Evidence

Scan the codebase:

| Source | What to Look For |
|--------|------------------|
| `.claude/skills/` | Skill count, complexity, patterns |
| `.claude/commands/` | Legacy commands |
| `README.md` | Feature claims, workflow |
| `AGENTS.md` | Workflow rules |
| `docs/` | Documentation coverage |
| Prompt files | Spec/plan generation patterns |

### Phase 3: Evaluate Vision Alignment

Score each vision item:

| Score | Meaning |
|-------|---------|
| 🟢 Green | Aligned — clear evidence |
| 🟡 Yellow | Partial — mixed signals |
| 🔴 Red | Misaligned — contradiction |

---

## Part B: SDLC Gap Analysis

### Phase 4: Classify SDLC Outcomes

For each outcome in SDLC_REFERENCE.md:

```
ACHIEVED     → Toolkit achieves this outcome
AVOIDED      → Out of scope per VISION.md (with citation)
OPPORTUNITY  → In scope but not yet achieved
```

**Decision Tree:**
```
Does toolkit achieve this outcome?
├─ YES → ACHIEVED
├─ NO → Is it out of scope per VISION.md?
│       ├─ YES → AVOIDED (cite the scope exclusion)
│       └─ NO → OPPORTUNITY (proceed to research)
```

---

## Part C: Research & Proposals (NEW)

### Phase 5: Research Opportunities

For each OPPORTUNITY identified, conduct research:

#### 5a. Web Research (Live)

Use WebSearch to find current information:

```
Search: "{outcome} best practices 2026"
Search: "AI coding tools {outcome}"
Search: "{specific capability} implementation patterns"
```

Extract:
- Current industry trends
- How leading tools approach this
- Emerging patterns or technologies

#### 5b. Competitor Analysis

Check COMPETITORS.md for each opportunity:

- Do any competitors address this? How?
- What works well in their approach?
- What can we do differently/better?
- Does addressing this strengthen our differentiation?

#### 5c. Principles Filter

For each opportunity, check against VISION.md principles:

```
□ Simplicity: Does this add too much complexity?
□ Flexibility: Does this force a workflow?
□ 90% Rule: Do most solo developers want this?
```

If an opportunity fails the principles filter, mark it as **SKIP** with reasoning.

### Phase 6: Generate Proposals

For each researched opportunity that passes the principles filter, generate a proposal:

```
════════════════════════════════════════════════════════════════════

PROPOSAL: {Short Title}
─────────────────────────

Outcome Addressed: {SDLC outcome ID and name}

Gap: {What's missing today}

Research Findings:
  • Trend: {What current best practices say}
  • Competitors: {How others handle this}
  • Differentiation: {How we can do it uniquely}

Proposal: {What to build/change}

Rationale:
  • Vision fit: {How this advances our aspiration}
  • Principle alignment: {Which principles it respects}
  • Competitive angle: {Why our approach is better}

Implementation Sketch:
  • Approach: {High-level how}
  • Files affected: {Which skills/prompts to modify}
  • Effort: LOW / MEDIUM / HIGH

Priority: HIGH / MEDIUM / LOW
  {Brief justification for priority}

════════════════════════════════════════════════════════════════════
```

---

## Phase 7: Combined Report Structure

```
╔══════════════════════════════════════════════════════════════════╗
║                       VISION ALIGNMENT AUDIT                      ║
╚══════════════════════════════════════════════════════════════════╝

SUMMARY
───────
Vision Alignment:  X of Y items (🟢 N / 🟡 N / 🔴 N)
SDLC Outcomes:     X achieved, Y avoided, Z opportunities
Proposals:         N proposals generated (H high, M medium, L low)

════════════════════════════════════════════════════════════════════

PART A: VISION ALIGNMENT
────────────────────────
[R/Y/G scoring for aspiration, principles, AI strengths/weaknesses,
scope, success criteria]

════════════════════════════════════════════════════════════════════

PART B: SDLC OUTCOME COVERAGE
─────────────────────────────
[By-phase listing of ACHIEVED / AVOIDED / OPPORTUNITY]

[Coverage summary table]

════════════════════════════════════════════════════════════════════

PART C: PROPOSALS
─────────────────

[For each proposal, full detail as shown in Phase 6]

════════════════════════════════════════════════════════════════════

SKIPPED OPPORTUNITIES
─────────────────────
[Opportunities that failed principles filter, with reasoning]

════════════════════════════════════════════════════════════════════

COMPETITIVE POSITIONING
───────────────────────
Summary of how proposals strengthen differentiation:
• {Proposal 1} reinforces {unique angle}
• {Proposal 2} addresses gap vs {competitor}
• etc.

════════════════════════════════════════════════════════════════════

RECOMMENDED ROADMAP
───────────────────
Based on this audit, suggested implementation order:

1. {HIGH priority proposal} - {one-line rationale}
2. {HIGH priority proposal} - {one-line rationale}
3. {MEDIUM priority proposal} - {one-line rationale}
...
```

---

## Research Guidelines

### What to Search For

| Opportunity Type | Search Queries |
|-----------------|----------------|
| Security | "shift-left security AI coding 2026", "SAST tools modern development" |
| Testing | "AI-assisted testing best practices", "test generation tools 2026" |
| Context management | "LLM context management techniques", "AI coding context rot solutions" |
| Workflow | "AI coding workflow automation", "spec-driven development tools" |

### Competitive Questions to Answer

For each opportunity, answer:
1. Which competitors address this? (check COMPETITORS.md feature matrix)
2. What's their approach? (philosophy, not just features)
3. What works well? What doesn't?
4. Can we achieve the outcome with less complexity?
5. Can we leverage our unique angles (verification-first, cross-model, simplicity)?

### Principles Filter Details

**Simplicity over capability:**
- Would this add a new skill? (caution)
- Would this add significant lines to existing skills? (caution)
- Could this be documentation instead of tooling? (prefer docs)

**Flexibility over guardrails:**
- Does this force users into a specific workflow?
- Can users opt-out or skip this?
- Is this additive rather than mandatory?

**90% rule:**
- Is this a common need for solo developers?
- Is this enterprise/team-specific? (skip)
- Is this niche technology-specific? (skip)

---

## Edge Cases

### COMPETITORS.md Missing

```
NOTE: COMPETITORS.md not found.

Proposals will be generated without competitive analysis.
Consider creating COMPETITORS.md for richer proposals.
```

### No Opportunities Found

```
All SDLC outcomes are either ACHIEVED or correctly AVOIDED.

No proposals generated. The toolkit is well-aligned with its vision
and SDLC best practices.

Consider:
- Reviewing COMPETITORS.md for differentiation opportunities
- Checking if new SDLC trends have emerged (run with fresh research)
```

### Too Many Opportunities

If more than 10 opportunities are identified:
- Prioritize ruthlessly using principles filter
- Generate full proposals only for HIGH priority items
- Summarize MEDIUM/LOW in a list without full research

### Research Rate Limits

If web search is rate-limited:
- Fall back to COMPETITORS.md analysis only
- Note that proposals lack current trend research
- Suggest re-running later for full analysis

---

## Error Handling

| Situation | Action |
|-----------|--------|
| VISION.md is missing | Stop and report "VISION.md not found — cannot run vision audit"; do not proceed |
| SDLC_REFERENCE.md is missing | Stop and report "SDLC_REFERENCE.md not found — cannot evaluate outcomes"; do not proceed |
| COMPETITORS.md is missing | Continue without competitive analysis; note in report that proposals lack competitive context |
| Web search is rate-limited or unavailable | Fall back to COMPETITORS.md analysis only; note that proposals lack current trend research |
| More than 10 OPPORTUNITY items identified | Generate full proposals only for HIGH priority items; summarize MEDIUM/LOW in a compact list |

## Review Your Output

After generating proposals, verify:
- Each proposal was cross-checked against the design principles filter
- No SDLC outcomes from VISION.md were missed
- Proposals are actionable and scoped (not vague aspirations)

## Output Principles

1. **Actionable** — Each proposal should be implementable
2. **Justified** — Every recommendation tied to vision/outcomes/competition
3. **Honest** — If something doesn't fit our principles, say so and skip it
4. **Prioritized** — Don't overwhelm; rank by impact and effort
5. **Differentiated** — Proposals should strengthen our unique positioning
