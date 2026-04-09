# TODO Format Reference

TODOs in this system follow a specific format for compatibility with other skills:

## Basic Format

```markdown
- [ ] **[{Priority} / {Effort}]** {Title} — {Brief description}
```

**Components:**

| Component | Format | Examples |
|-----------|--------|----------|
| Checkbox | `- [ ]` (pending) or `- [x]` (done) | `- [ ]` |
| Priority | `P0` (critical), `P1` (high), `P2` (low) | `**[P1 / Medium]**` |
| Effort | `Low`, `Medium`, `High` | `**[P2 / Low]**` |
| Multiplier | Optional `x{N}` (0.5-2.0) | `**[P1 / Medium x1.5]**` |
| Title | Short, actionable description | `Add user authentication` |
| Description | Optional extended description | `— Support OAuth and email/password` |

## Tags

| Tag | Meaning | When to Use |
|-----|---------|-------------|
| `[ready]` | Clarified and ready to implement | After Q&A in /list-todos |
| `[priority: N]` | Personal priority multiplier | Inline override (0.5-2.0) |

## Status Markers

| Marker | Meaning |
|--------|---------|
| `— DONE` | Completed |
| `— DONE ({hash})` | Completed with commit reference |
| `— **DEFERRED** ({reason})` | Postponed with explanation |
| `— **REMOVED** ({reason})` | Canceled with explanation |

## Clarifications Section

When requirements are refined through Q&A, add a clarifications block:

```markdown
- [ ] **[P1 / Medium]** {Title}

**Clarifications (from Q&A {YYYY-MM-DD}):**
- {Question 1}: {Answer 1}
- {Question 2}: {Answer 2}
```
