---
name: capture-learning
description: Capture a project learning or pattern to LEARNINGS.md. Use when you discover a useful pattern or convention during development.
argument-hint: ["learning description"]
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion
---

# Capture Learning

Capture a discovered pattern, convention, or gotcha to the project's LEARNINGS.md file.

## Usage

```
/capture-learning "Use vi.mock() not jest.mock() - this is Vitest"
/capture-learning
```

If no argument provided, prompt for the learning content.

## Process

Copy this checklist and track progress:

```
Capture Learning Progress:
- [ ] Step 1: Get learning content from user
- [ ] Step 2: Determine category (pattern, convention, pitfall, tool-tip)
- [ ] Step 3: Gather context (when it applies, why it matters)
- [ ] Step 4: Write entry to LEARNINGS.md
- [ ] Step 5: Confirm entry was saved correctly
```

### 1. Get Learning Content

- If `$ARGUMENTS` is provided and non-empty, use it as the learning content
- Otherwise, use AskUserQuestion to prompt:
  ```
  Question: "What did you learn?"
  Header: "Learning"
  Options:
    - Label: "Enter below"
      Description: "Type your learning in the text field"
  ```
  (User will select "Other" to type their learning)

### 2. Get Category (Optional)

Use AskUserQuestion to ask for category:

```
Question: "Which category fits this learning?"
Header: "Category"
Options:
  - Label: "Conventions"
    Description: "Code style, naming, patterns used in this project"
  - Label: "Testing"
    Description: "Test setup, mocking, assertions"
  - Label: "Gotchas"
    Description: "Non-obvious behavior, things that caused debugging"
  - Label: "Error Handling"
    Description: "How errors are handled, Result patterns, etc."
```

If user selects "Other", use their custom category name.

### 3. Get Context

Determine the current task context:
- Check if `.claude/phase-state.json` exists (if available) and extract current task ID
- If not available, use "Manual capture" as the context
- Get today's date in YYYY-MM-DD format

### 4. Create or Update LEARNINGS.md

**If LEARNINGS.md doesn't exist**, create it with this template:

```markdown
# Discovered Patterns

> Project-specific patterns and conventions discovered during development.
> This file provides context for future sessions.
> Add learnings with `/capture-learning` or manually.

## Conventions

## Testing

## Gotchas

## Error Handling

## Performance
```

**Then append the learning** under the appropriate category section:

Format: `- {learning content} ({date}, {task context})`

Example:
```markdown
## Testing
- Use `vi.mock()` not `jest.mock()` — this is a Vitest project (2026-01-22, Task 1.1.A)
```

### 5. Confirm

Output:
```
Captured to LEARNINGS.md:

**{Category}:** {learning content}

This pattern will be loaded into context on future sessions.
```

## What Makes a Good Learning

Capture things that:
- **Differ from common defaults** — project uses Vitest not Jest, pnpm not npm
- **Are project-specific conventions** — API response shapes, naming patterns
- **Caused debugging time** — lazy-loaded fields, import side effects
- **Would surprise a new contributor** — non-obvious architectural decisions

Don't capture:
- General programming knowledge
- Things obvious from reading the code
- Temporary workarounds (use TODOS.md instead)

## File Location

LEARNINGS.md is always created/updated in PROJECT_ROOT (not feature directories), since learnings apply project-wide.

To determine PROJECT_ROOT:
- If current directory matches `*/features/*`, go up two levels
- Otherwise, use current directory
