---
name: audit-skills
description: Audits skills, commands, and prompt templates for best practice violations including length, checklists, verification steps, and progressive disclosure. Use after creating or modifying skills, during reviews, or to improve existing prompt files. Produces prioritized improvement suggestions.
---

# Audit Skills

Analyze skills, legacy commands, and prompt templates in this repository against best practices and produce prioritized improvements.

## Workflow

Copy this checklist and track progress:

```
Audit Progress:
- [ ] Step 1: Discover all auditable files (skills, commands, prompts)
- [ ] Step 2: Load criteria
- [ ] Step 3: Audit each file
- [ ] Step 4: Score and prioritize
- [ ] Step 5: Output report
```

### Step 1: Discover All Auditable Files

Find all skill-like files in the repository:

Use Glob to find files matching these patterns:
- `.claude/skills/*/SKILL.md` — Skills
- `.claude/commands/*.md` — Legacy commands
- `.claude/skills/*/PROMPT.md` — Co-located prompts
- `*_PROMPT.md` — Root-level prompt templates

Classify each file:

| Type | Example | Criteria Applied |
|------|---------|-----------------|
| **Skill** | `.claude/skills/*/SKILL.md` | All criteria (L, C, S, E, D) |
| **Command** | `.claude/commands/*.md` | All criteria (L, C, S, E, D) — same frontmatter as skills |
| **Prompt** | `PROMPT.md`, `*_PROMPT.md` | L, C, S, E only — no frontmatter, so skip D1-D3 |

Record the total count across all types for verification later.

### Step 2: Load Criteria

Read [CRITERIA.md](CRITERIA.md) for the full audit checklist.

Read [SCORING.md](SCORING.md) for severity definitions.

### Step 3: Audit Each File

For each discovered file:

1. **Read the file** — note line count immediately
2. **Check applicable criteria** from CRITERIA.md (see type table in Step 1)
3. **For skills with co-located PROMPT.md** — audit the PROMPT.md too and report alongside the SKILL.md (they function as a unit)
4. **Cross-reference check** — Grep for `/skill-name` invocation patterns in other SKILL.md files. If explicitly invoked (not merely mentioned in prose), apply CO1 (output contract) check
5. **Record violations** with criterion ID and evidence

Use this template per file:

```
File: <path>
Type: Skill | Command | Prompt
Lines: <count> (+ <N> in PROMPT.md if applicable)
Violations:
- <ID>: <brief evidence>
```

### Step 4: Score and Prioritize

Group findings by severity (from SCORING.md):
- **Critical**: Likely to cause execution failures
- **Medium**: Degrades quality but may still work
- **Low**: Polish items

Within each severity, sort by:
1. Most violations in single skill (fix skill holistically)
2. Most common violation across skills (systemic issue)

**Systemic pattern detection**: If any single criterion appears in >50% of audited skills *and* the sample size is 5 or more, flag it as a systemic issue requiring a template-level fix rather than per-skill remediation.

### Step 5: Output Report

Use this format:

```markdown
# Skill Audit Report

Generated: <date>
Skills audited: <N>
Total findings: <N>

## Critical (fix first)

- **<skill-name>**: <violation summary> (<criterion-id>)
  - Evidence: <quote or line numbers>
  - Suggested fix: <concrete action>

## Medium Priority

...

## Low Priority

...

## Top 3 Recommendations

1. **<most impactful fix>** — affects <N> skills (<criterion-ids>)
2. **<second most impactful>** — affects <N> skills (<criterion-ids>)
3. **<third most impactful>** — affects <N> skills (<criterion-ids>)

{If any criterion appears in >50% of skills}
## Systemic Issues

- **<criterion-id>**: Found in <N>/<total> skills — consider a template-level fix
{/If}

## Summary by Criterion

| ID | Description | Count |
|----|-------------|-------|
| C1 | Missing checklist | 5 |
| ... | ... | ... |
```

## Error Handling

| Situation | Action |
|-----------|--------|
| CRITERIA.md or SCORING.md not found | Report the missing file and stop — audit cannot proceed without criteria definitions. |
| No auditable files found (no skills, commands, or prompts) | Report that no files were discovered and stop. |
| Individual file unreadable | Log the file as "skipped (unreadable)" in the report and continue with remaining files. |

---

**REMINDER**: After completing the audit, verify your report includes all discovered files (skills, commands, and prompts). Missing files indicates incomplete analysis.
