---
name: capture-session
description: Extract decisions, action items, new context, and insights from the current session into LEARNINGS.md and auto-memory. Run before ending any substantive conversation.
argument-hint: "[--dry-run]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Capture Session

Extract everything worth persisting from the current conversation and write it to the project's LEARNINGS.md file and auto-memory. This is the session-end counterpart to `/capture-learning` (which captures a single item). `/capture-session` sweeps the entire conversation.

## When to Use

- Before ending any conversation where decisions were made, context was discovered, or work was done
- When the user says "wrap up", "that's it for now", "save this", or similar
- Proactively suggest this when the session has been substantive (30+ minutes, multiple tool calls, stakeholder context discussed)

## Arguments

- `--dry-run` — Show what would be captured without writing anything

## What to Extract

Review the FULL conversation and extract items in these categories:

### 1. Decisions (with rationale)
Things that were decided and WHY. These prevent future sessions from re-litigating settled questions.
- Code architecture choices
- Classification rules, business logic
- What to include/exclude from scope
- Tool or approach selections

### 2. Action Items
Work that needs to happen but hasn't been done yet. Include owner if known.
- Bug fixes identified but not implemented
- Follow-ups with stakeholders
- Things to verify next month/sprint
- Changes to propagate to other scripts/files

### 3. New Context
Information discovered during the session that wasn't previously known to the project. This is the most commonly lost category.
- Stakeholder preferences, workflows, pain points
- External systems or processes mentioned
- Business rules clarified
- Constraints or requirements surfaced

### 4. Bugs & Issues
Problems discovered, whether fixed or not.
- What was broken and how it manifested
- Root cause (if identified)
- Fix applied (if any)
- Remaining risk or edge cases

### 5. Deferred Investigations
Ideas, hypotheses, or potential improvements that came up but weren't pursued. Worth revisiting later.
- Performance improvements
- Feature ideas
- Refactoring opportunities
- "What if we..." discussions

## Process

```
Capture Session Progress:
- [ ] Step 1: Review conversation for extractable items
- [ ] Step 2: Draft extraction (present to user)
- [ ] Step 3: User confirms/edits
- [ ] Step 4: Write to LEARNINGS.md
- [ ] Step 5: Update auto-memory for cross-session items
- [ ] Step 6: Confirm
```

### Step 1: Review Conversation

Scan the full conversation history. For each category above, identify concrete items. Be specific — include file names, line numbers, amounts, names, dates. Vague entries are useless.

**Good:** "Kay confirmed EXEMPT FOOD tax group should only apply to CF-produced items; 3rd party non-taxable food gets NONTAXABLE (2026-04-02 call)"

**Bad:** "Tax group codes need to be reviewed"

### Step 2: Present Draft

Show the user what you plan to capture, organized by category:

```
SESSION CAPTURE — DRAFT
=======================
Session: {brief description of what was done}
Date: {today}

DECISIONS (N items)
1. {decision} — Rationale: {why}

ACTION ITEMS (N items)
1. {item} — Owner: {who} — Due: {when, if known}

NEW CONTEXT (N items)
1. {context}

BUGS & ISSUES (N items)
1. {issue} — Status: {fixed/open/deferred}

DEFERRED INVESTIGATIONS (N items)
1. {idea}

Write to LEARNINGS.md? [Y/n]
```

Use AskUserQuestion to confirm. If `--dry-run`, stop here.

### Step 3: User Confirms

If user says yes (or modifies), proceed. If user removes items, respect that. If user adds items, include them.

### Step 4: Write to LEARNINGS.md

**File location:** LEARNINGS.md is always created/updated at PROJECT_ROOT (not feature directories), since learnings apply project-wide. To determine PROJECT_ROOT: if current directory matches `*/features/*`, go up two levels; otherwise use current directory.

**If LEARNINGS.md doesn't exist**, create it:

```markdown
# Session Learnings

> Persistent knowledge extracted from AI coding sessions.
> Captures decisions, context, action items, and insights that should survive between sessions.
> Add entries with `/capture-session` (full sweep) or `/capture-learning` (single item).

## Decisions

## Action Items

## Context

## Bugs & Issues

## Deferred Investigations
```

**Append entries** under the appropriate section. Each entry format:

```markdown
- **[YYYY-MM-DD]** {content} *(source: {conversation/stakeholder/code review/etc.})*
```

For action items, use checkbox format:
```markdown
- [ ] **[YYYY-MM-DD]** {action item} — Owner: {who}
```

### Step 5: Update Auto-Memory

For items that are broadly relevant across sessions (not just task-specific), also write to auto-memory:

- **New Context** about stakeholders, external systems, or business rules → `type: project` or `type: user` memory
- **Decisions** that affect how future sessions should behave → `type: feedback` memory
- **Don't duplicate** — check existing memory files first

Skip this step if the project doesn't use auto-memory (no `.claude/projects/` memory directory).

### Step 6: Confirm

```
SESSION CAPTURED
================
Written to LEARNINGS.md:
  - {N} decisions
  - {N} action items
  - {N} context items
  - {N} bugs/issues
  - {N} deferred investigations

{If auto-memory updated}
Auto-memory updated:
  - {list of memory files created/updated}
{/If}

This context will be available in future sessions.
```

## CLAUDE.md Integration

For the skill to be effective, the project's CLAUDE.md should include:

```markdown
@LEARNINGS.md
```

This ensures future sessions load the learnings at startup. If CLAUDE.md exists but doesn't reference LEARNINGS.md, suggest adding it.

## Guidance for Extraction Quality

**Include if:**
- It would save a future session from re-discovering something (> 5 min saved)
- A stakeholder said it (their words carry weight)
- It contradicts a prior assumption
- It affects multiple files or future work
- Someone would ask "why did we do it this way?"

**Exclude if:**
- It's obvious from reading the code or git log
- It's a temporary debugging step that's already resolved
- It's general programming knowledge
- It's already captured in CLAUDE.md, PROJECT_STATUS.md, or existing memory

**Convert relative dates:** "next month" → "May 2026", "Thursday" → "2026-04-03"

## Error Handling

| Situation | Action |
|-----------|--------|
| No substantive items found | Report "Nothing to capture — session was exploratory or all items are already documented" |
| LEARNINGS.md is very large (>200 lines) | Warn user, suggest archiving older entries to `LEARNINGS_ARCHIVE.md` |
| No auto-memory directory | Skip Step 5, note in output |
| User cancels | Stop gracefully, no writes |
