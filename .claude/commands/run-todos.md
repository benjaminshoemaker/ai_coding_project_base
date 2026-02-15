---
description: Implement [ready]-tagged TODO items with commits. Use after /list-todos has marked items as [ready] for implementation.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Task
---

Implement TODO items that have been marked as `[ready]` in TODOS.md.

## Directory Guard

Before starting, confirm `TODOS.md` exists in the current working directory.

- If it does not exist, **STOP** and tell the user to create TODOS.md or `cd` into their project directory.

## Context Check

**Before starting:** If context is below 40% remaining, run `/compact` first. This ensures the full command instructions remain in context throughout execution. Compaction mid-command loses procedural instructions.

## Workflow

Copy this checklist and track progress:

```
Run TODOs Progress:
- [ ] Step 1: Find [ready]-tagged items in TODOS.md
- [ ] Step 2: Select items to implement
- [ ] Step 3: Create git branch for changes
- [ ] Step 4: Implement each selected item
- [ ] Step 5: Commit changes
- [ ] Step 6: Generate summary of completed work
```

## Find [ready] Items

1. Read TODOS.md
2. Find all items containing the `[ready]` tag
3. Exclude items that are already checked (`- [x]`) or have `— DONE`

If no [ready] items found:
```
NO READY ITEMS
==============
No items tagged [ready] found in TODOS.md.

To mark items as ready:
1. Run /list-todos
2. Go through Q&A to clarify requirements
3. Confirm readiness when asked

Or manually add [ready] tag to items you want to implement.
```

## User Selection

Show the list of [ready] items and let user select:

```
READY ITEMS
===========
Found {N} items tagged [ready]:

1. {item title 1}
2. {item title 2}
3. {item title 3}

Which items would you like to implement?
```

Use AskUserQuestion:
```
Question: "Which items would you like to implement?"
Header: "Selection"
Options:
  - Label: "All items"
    Description: "Implement all {N} ready items in sequence (Recommended)"
  - Label: "Select specific items"
    Description: "Choose which items to implement"
  - Label: "Cancel"
    Description: "Exit without implementing"
```

If "Select specific items", use AskUserQuestion with multiSelect:
```
Question: "Select items to implement:"
Header: "Items"
Options:
  - Label: "1. {item 1 title}"
    Description: "{priority if present}"
  - Label: "2. {item 2 title}"
    Description: "{priority if present}"
  ... (up to 4 items per question, use multiple questions if more)
multiSelect: true
```

If "Cancel", exit the command.

## Git Workflow

### Check for Unpushed Commits

Before creating a branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)
UNPUSHED=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "no-upstream")
```

If `UNPUSHED` > 0, use AskUserQuestion:
```
Question: "You have {UNPUSHED} unpushed commit(s) on `{CURRENT_BRANCH}`. Push before creating todo branch?"
Header: "Unpushed"
Options:
  - Label: "Yes, push first"
    Description: "Push current commits before starting (Recommended)"
  - Label: "No, continue anyway"
    Description: "Create branch from unpushed state"
```

### Create Branch

```bash
# Commit any dirty files first
git add -A && git diff --cached --quiet || git commit -m "wip: uncommitted changes before todo implementation"

# Create todo implementation branch
git checkout -b todo-impl-$(date +%Y-%m-%d)
```

## Implementation Loop

For each selected item:

### 1. Show Item Context

```
IMPLEMENTING: {item title}
===========================

{Full item text from TODOS.md}

{If clarifications exist:}
Clarifications:
- {Q1}: {A1}
- {Q2}: {A2}
```

### 2. Ask Final Clarifying Questions (if needed)

If the item description is vague or missing key details, use AskUserQuestion to clarify before implementing:

```
Question: "{Specific question about implementation}"
Header: "{Item title (truncated)}"
Options:
  - Label: "{Recommended approach}"
    Description: "(Recommended) {Why this is the suggested approach}"
  - Label: "{Alternative 1}"
    Description: "{Trade-offs of this approach}"
  - Label: "{Alternative 2}"
    Description: "{Trade-offs of this approach}"
```

### 3. Implement

Implement the TODO item following project conventions:
- Read relevant existing code to understand patterns
- Write tests first if acceptance criteria exist
- Implement the feature/fix
- Run tests to verify

### 4. Verify (if criteria exist)

If the item has acceptance criteria or testable requirements:
- Run the relevant test suite
- Use auto-verify skill for automatable checks
- Report verification results

### 5. Update TODOS.md

After successful implementation:

1. Check the box: `- [ ]` → `- [x]`
2. Add completion suffix: `— DONE ({short_commit_hash})`

**Before:**
```markdown
- [ ] **[P1 / Medium]** Add user auth endpoint [ready]
```

**After:**
```markdown
- [x] **[P1 / Medium]** Add user auth endpoint [ready] — DONE (a1b2c3d)
```

Use the Edit tool to make this update.

### 6. Commit

```bash
git add -A
git commit -m "todo: {item title (shortened if needed)}"
```

Get the commit hash for the TODOS.md update:
```bash
COMMIT_HASH=$(git rev-parse --short HEAD)
```

### 7. Handle Failure

If implementation fails (tests don't pass, errors occur), use AskUserQuestion:

```
Question: "Implementation of '{item title}' failed. What would you like to do?"
Header: "Failed"
Options:
  - Label: "Skip this item"
    Description: "Continue with the next item (Recommended if blocked)"
  - Label: "Retry"
    Description: "Try implementing again with a different approach"
  - Label: "Abort session"
    Description: "Stop and leave remaining items for later"
```

**If Skip:** Mark item as skipped in tracking, continue to next item
**If Retry:** Return to step 3 (Implement), try alternative approach
**If Abort:** Go directly to Summary Report

## Summary Report

After all items are processed (or aborted):

```
RUN-TODOS COMPLETE
==================

Branch: todo-impl-{date}

Completed: {N} items
{For each completed item:}
  ✓ {item title} ({commit_hash})

{If any skipped:}
Skipped: {N} items
{For each skipped item:}
  ✗ {item title} — {reason}

{If aborted early:}
Remaining: {N} items not attempted

TODOS.md updated with completion status.

Next: Review changes, then run:
  git push origin todo-impl-{date}
```

## Notes

- **Do NOT push automatically.** Leave pushing to the human after review.
- **One commit per item.** Each TODO gets its own commit for traceability.
- **Preserve [ready] tag.** The tag stays even after completion for history.
- **Short commit hashes.** Use 7-character short hash in DONE suffix.
