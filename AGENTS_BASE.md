# AGENTS.md - Base Template

> **Note**: This is a base template. Run the augmentation prompt to add project-specific context before use.

## Repository docs
- `PRODUCT_SPEC.md` - Captures Problem, Audience, Platform, Core Flow, MVP Features
- `TECHNICAL_SPEC.md` - Minimal functional and technical specification consistent with prior docs, including a concise **Definition of Done**
- `IMPLEMENTATION_PLAN.md` - Agent-Ready Planner with per-step prompts, expected artifacts, tests, rollback notes, idempotency notes, and a TODO checklist using Markdown checkboxes
- `AGENTS.md` - This file

---

## Project context

> **TODO**: Add project-specific context here using the augmentation prompt.

### Tech stack
<!-- To be filled: Language, runtime, test framework, package manager, key dependencies -->

### File structure conventions
<!-- To be filled: Source layout, test organization, naming conventions -->

### State/data conventions
<!-- To be filled: Config files, data formats, persistence approach -->

---

## Agent responsibility

### Checklist management
- After completing any coding, refactor, or test step, **immediately update the corresponding TODO checklist item** in `IMPLEMENTATION_PLAN.md`
- Use Markdown checkbox format (`- [x]`) to mark completion
- Always commit changes to `IMPLEMENTATION_PLAN.md` alongside the code and tests that fulfill them
- Do not consider work "done" until the matching checklist item is checked and all related tests are green

### Completion protocol
When a plan step is finished, document its completion state with a short checklist:
- [ ] Step name & number
- [ ] Test results (all green)
- [ ] `IMPLEMENTATION_PLAN.md` updated
- [ ] Manual checks performed (human confirmed)
- [ ] Release notes updated (if user-facing change)
- [ ] Inline commit summary for human to copy

### Release notes
- If the step adds or changes **user-facing behavior**, update the README "Release notes" section
- Internal refactors and test additions do not require release notes
- State "No user-facing changes" explicitly when applicable

### Manual test suggestion
Even when automated coverage exists, always suggest a feasible manual test path so the human can exercise the feature end-to-end.

---

## Guardrails for agents

### General
- Make the smallest change that passes tests and improves the code
- Do not introduce new public APIs without updating `TECHNICAL_SPEC.md` and relevant tests
- Do not duplicate templates or files to work around issues—fix the original
- Respect privacy: do not log secrets, prompts, completions, or PII

### When stuck
- If a file cannot be opened, content is missing, **or a test fails unexpectedly**, say so explicitly and stop
- Do not guess or work around
- If you don't understand why a test is failing, **read the full error output** before attempting fixes—the answer is usually in the stack trace

### Deferred-work notation
- When a task is intentionally paused or skipped, keep its checkbox unchecked and prepend `(Deferred)` to the TODO label, followed by a short reason
- Apply the same `(Deferred)` tag to every downstream checklist item that depends on the paused work
- Remove the tag only after the work resumes

### When the IMPLEMENTATION_PLAN is fully satisfied
- Once every Definition of Done task in `IMPLEMENTATION_PLAN.md` is either checked off or explicitly marked `(Deferred)`, the plan is considered **complete**
- After that point, you no longer need to update IMPLEMENTATION_PLAN TODOs or reference upstream docs to justify changes
- All other guardrails, testing requirements, and agent responsibilities continue to apply

---

## Testing policy (non-negotiable)

### Core rules
- Tests **MUST** cover the functionality being implemented
- **NEVER** ignore the output of the system or the tests—logs and messages often contain **critical** information
- **NEVER** disable functionality to hide a failure—fix root cause
- **NEVER** claim something is "working" when any functionality is disabled or broken

### Test output policy
- stdout/stderr from tests must be empty unless explicitly testing output behavior
- Capture expected output and assert on it—don't let it leak
- If a test legitimately produces output, capture it and assert on it

### What "green tests" means
All configured checks must pass. Typically includes:
1. Test suite passes
2. Type checking passes (if applicable)
3. Linting passes (if applicable)
4. Build succeeds (if applicable)

A step is not complete until all checks pass.

### TDD workflow
1. Write a failing test that defines a desired function or improvement
2. Run the test to confirm it fails as expected
3. Write minimal code to make the test pass
4. Run the test to confirm success
5. Refactor while keeping tests green
6. Repeat for each new feature or bugfix

---

## Mocking policy

> **TODO**: Add project-specific mocking requirements here using the augmentation prompt.

### General principles
- External services (APIs, databases, file systems) should be mocked in unit tests
- Use temp directories for file system tests—clean up after each test
- Integration tests that require real external services must be:
  - Skippable when credentials are not available
  - Excluded from CI by default
  - Documented as manual verification steps

---

## Error handling

> **TODO**: Add project-specific error hierarchy here using the augmentation prompt.

### General principles
- Use typed/structured errors when the language supports it
- Include context in error messages (what failed, why, what to do)
- Don't catch errors just to re-throw them without adding information
- Log errors at the point of handling, not at the point of throwing

---

## Commit messages

Format: `<scope>: <description>`

| Scope | Use |
|-------|-----|
| `feat` | New functionality |
| `fix` | Bug fix |
| `test` | Test additions/changes |
| `refactor` | Code restructuring |
| `docs` | Documentation |
| `chore` | Build/tooling changes |

Examples:
- `feat(api): add user authentication endpoint`
- `fix(parser): handle empty input gracefully`
- `test(utils): add edge case coverage for date formatting`

---

## Important checks

- **NEVER** disable functionality to hide a failure—fix root cause
- **NEVER** create duplicate templates or files—fix the original
- **NEVER** claim something is "working" when any functionality is disabled or broken
- If you can't open a file or access something requested, say so—do not assume contents
- **ALWAYS** identify and fix the root cause of template or compilation errors
- If git is initialized, ensure `.gitignore` exists and contains at least:
  ```
  .env
  .env.local
  .env.*
  ```
- Ask the human whether additional patterns should be added to `.gitignore`

---

## Context management between steps

### Starting a new step
When beginning a new IMPLEMENTATION_PLAN step, **start a fresh conversation**. Do not carry forward conversation history from previous steps.

Before working on any step, ensure you have loaded:
1. `AGENTS.md` (this file - guardrails and conventions)
2. `TECHNICAL_SPEC.md` (architecture reference)
3. The current step's section from `IMPLEMENTATION_PLAN.md` (the actual task)

Read source files and tests on-demand as needed for the specific step. Do not preload the entire codebase.

### Why clear context between steps?
- Each step is self-contained with complete instructions
- Decisions from previous steps exist in the code, not conversation history
- Stale context causes confusion and wastes tokens
- The code and tests are the source of truth

### When to preserve context
**Within a single step**, if tests fail or issues arise, continue in the same conversation to debug. The iteration loop is:

```
Step N starts (fresh context)
    → Implement
    → Test fails
    → Debug (keep context)
    → Fix
    → Test fails again
    → Debug (keep context)
    → Fix
    → Tests pass
    → Step N complete
Step N+1 starts (fresh context)
```

Only clear context when moving to the next step, not while iterating on the current one.

### Resuming work after a break
When returning to a project after stopping:
1. Start a fresh conversation
2. Load `AGENTS.md`, `TECHNICAL_SPEC.md`
3. Check `IMPLEMENTATION_PLAN.md` checkboxes to find the current step
4. Run tests to verify current state
5. Continue from the first unchecked step

Do not attempt to reconstruct previous conversation context. The checked boxes and passing tests tell you everything you need to know.

---

## When to ask for human input

Ask the human if any of the following is true:
- You need new environment variables or secrets
- An external dependency or major architectural change is required
- A test is failing and you cannot determine why after reading the full error output
- You're unsure whether a change is user-facing (and thus needs release notes)
- Manual verification requires credentials or external services you cannot access
