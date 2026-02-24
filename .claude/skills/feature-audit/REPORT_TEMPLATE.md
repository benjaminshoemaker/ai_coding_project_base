# Feature Audit Report Template

This template defines the output format for the `/feature-audit` skill.

---

## Report Structure

```
# Feature Audit: {Feature Name}

**Audited:** {date}
**Streams completed:** {list: Code Exploration, UI/UX Research, Codex Consultation, Browser Inspection}
**Streams skipped/failed:** {list with reasons}

---

## Part 1: Spec Alignment — What Was Built vs What Was Planned

### Implemented as Designed

| Spec Item | Status | Notes |
|-----------|--------|-------|
| {item from spec} | **Complete** | {brief note} |
| {item from spec} | **Complete** | {brief note} |

### Spec Mismatches / Gaps

| Issue | Severity | Detail |
|-------|----------|--------|
| **{Short description}** | HIGH | {What spec says vs what was built. Source: {stream}} |
| **{Short description}** | MEDIUM | {Detail. Source: {stream}} |
| **{Short description}** | LOW | {Detail. Source: {stream}} |

---

## Part 2: Critical Issues (P0)

{Only include this section if runtime bugs, crashes, or blocking issues were found.}

| Bug | Location | Error | Impact |
|-----|----------|-------|--------|
| **{Short description}** | `{file:line}` | {Error message} | {User impact} |

---

## Part 3: UX / UI Assessment

### What Works Well

1. **{Finding title}.** {Detail. Why it's good.} (Sources: {streams that agree})
2. **{Finding title}.** {Detail.} (Sources: {streams})

### Issues & Improvement Opportunities

#### HIGH Priority

| Finding | Source(s) | Recommendation |
|---------|-----------|----------------|
| **{Issue}** | {streams} | {Specific recommendation} |

#### MEDIUM Priority

| Finding | Source(s) | Recommendation |
|---------|-----------|----------------|
| **{Issue}** | {streams} | {Specific recommendation} |

#### LOW Priority

| Finding | Source(s) | Recommendation |
|---------|-----------|----------------|
| **{Issue}** | {streams} | {Specific recommendation} |

---

## Part 4: Strategic Assessment

### Does this feature achieve its goals?

**Goal 1: "{goal from spec}"** — **{Yes/Partially/No}.** {Detail.}
**Goal 2: "{goal from spec}"** — **{Yes/Partially/No}.** {Detail.}

### Product Principles Alignment

| Principle | Alignment | Notes |
|-----------|-----------|-------|
| {principle from vision docs} | {Strong/Partial/Weak} | {Detail} |

### Key Decisions to Make

{List of unresolved architectural or product decisions the user should weigh in on.}

---

## Part 5: Summary of Next Steps

1. **{Action}** — {brief rationale}
2. **{Action}** — {brief rationale}
3. **{Action}** — {brief rationale}

### Questions for Discussion

- {Question 1}?
- {Question 2}?
```

---

## Synthesis Rules

When merging findings from multiple streams:

### Convergence Scoring

| # of Streams Agreeing | Confidence Label |
|-----------------------|-----------------|
| 1 stream | Single-source finding |
| 2 streams | Confirmed finding |
| 3+ streams | High-confidence finding |

### Severity Assignment

| Criteria | Severity |
|----------|----------|
| Runtime crash, data loss, security issue | **P0 / Critical** |
| Feature doesn't match spec, major UX problem, credibility risk | **HIGH** |
| Missing polish, suboptimal pattern, minor spec divergence | **MEDIUM** |
| Cosmetic, nice-to-have, future enhancement | **LOW** |

### Source Attribution Format

Always attribute findings to the stream(s) that identified them:

- `(Code exploration)` — found by reading implementation files
- `(UI/UX research)` — found by web research on patterns
- `(Codex consultation)` — found by Codex cross-model analysis
- `(Browser inspection)` — found by live UI testing
- `(Manual review)` — found by the primary agent's own analysis

### Handling Disagreements

If two streams disagree on a finding:

```
**{Finding title}** — Sources disagree:
- {Stream A} says: {perspective A}
- {Stream B} says: {perspective B}
- **Assessment:** {Your synthesis — which perspective is more credible and why}
```

### What NOT to Include

- Implementation details that don't affect the user experience
- Code style opinions unrelated to the feature's goals
- Theoretical concerns without evidence from any stream
- Duplicate findings (merge into single entry with multiple sources)
