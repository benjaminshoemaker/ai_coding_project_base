# Session Analysis Output Structure

Use this structure when writing to `.claude/logs/ANALYSIS_REPORT.md`:

```markdown
# Session Analysis Report

Generated: {timestamp}
Sessions analyzed: {N}
Date range: {earliest} to {latest}

## Summary

- Total sessions: {N}
- Projects: {list}
- Common patterns identified: {count}

## Per-Project Breakdown

### {Project Name} ({N} sessions)

**Type:** Toolkit | Target | Other
**Date range:** {first} -- {last}
**Key patterns:**
- {pattern 1}
- {pattern 2}

## Cross-Project Insights

### Autonomy Levels
| Project | Sessions | Questions/Session | Autonomy |
|---------|----------|-------------------|----------|
| {proj}  | {N}      | {avg}             | {level}  |

### Shared Patterns
- {pattern that appears across multiple projects}

## Automation Opportunities

### High Priority

#### 1. {Pattern Name}
**Occurrences:** {N} sessions
**Projects:** {list of projects where this appears}
**Pattern:** {description of what keeps happening}
**Suggested Automation:**
- {specific automation approach}
- {implementation hint}

### Medium Priority
...

### Low Priority
...

## Recommended Actions

1. **Create new skill:** {skill name} -- {what it would automate}
2. **Add to AGENTS.md:** {guidance to add}
3. **Create hook:** {hook description}

## Raw Statistics

### Questions Asked (AskUserQuestion)
| Question Pattern | Count | Projects |
|-----------------|-------|----------|
| {pattern} | {N} | {list} |

### Tools Used
| Tool | Total Uses | Avg per Session |
|------|------------|-----------------|
| {tool} | {N} | {avg} |

### Blockers Encountered
| Blocker Type | Count | Resolution |
|--------------|-------|------------|
| {type} | {N} | {how resolved} |
```
