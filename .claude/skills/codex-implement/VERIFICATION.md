# Verification Strategy

4-tier verification for `/codex-implement` tasks. Unlike `/phase-start` which has
formal acceptance criteria from an execution plan, ad-hoc implementation uses
Claude-generated success criteria from the Implementation Brief.

## Tier 1: Scope Guard

**Purpose**: Detect if Codex modified files outside the expected scope.

Claude performs this check logically (not as a script):

1. Run `git diff --name-only` to get the list of changed files
2. Compare each changed file against the expected files from the task
3. Flag any file not in the expected list as a scope violation

**On violation**:
- Warn the user: "Codex modified unexpected files: {list}"
- Ask via AskUserQuestion:
  - "Accept all changes" — proceed
  - "Revert unexpected files" — `git restore {files}`, keep expected changes
  - "Revert everything" — `git restore .`

**Exception**: Test files and config/export files (package.json, index.ts barrel
exports) that are reasonable side effects of the implementation are NOT violations.
Use judgment — a new component naturally needs a barrel export update.

## Tier 2: Automated Checks

**Purpose**: Run project-configured quality gates.

Check for available commands in order:

1. `.claude/verification-config.json` → `commands.test`, `commands.lint`, `commands.typecheck`
2. `workstream.json` → `verify.commands.*`
3. `package.json` → `scripts.test`, `scripts.lint`, `scripts.typecheck`

Run whichever are available:

```bash
# Typecheck (if available)
npm run typecheck 2>&1 || TYPECHECK_FAILED=true

# Lint (if available)
npm run lint 2>&1 || LINT_FAILED=true

# Test (if available)
npm test 2>&1 || TEST_FAILED=true
```

**On failure**:
- Report which checks failed and the output
- Do NOT automatically retry or fix — let the user decide
- Include failure details in the task result for the summary

**If no checks are configured**: Skip this tier with a note:
"No automated checks configured. Relying on Claude review."

## Tier 3: Claude Diff Review

**Purpose**: Semantic verification — do the changes match the success criteria?

Claude reads the full diff and evaluates:

1. **Completeness**: Does each success criterion have corresponding code?
2. **Correctness**: Does the implementation logic match the intent?
3. **Conventions**: Does it follow project patterns (from AGENTS.md, nearby code)?
4. **Side effects**: Are there unintended changes, debug code, or TODOs left behind?

```bash
# Get the diff for Claude to review
git diff
```

Claude produces a verdict:
- **PASS**: All criteria met, no issues
- **PASS_WITH_NOTES**: Criteria met, minor observations (proceed but note them)
- **NEEDS_ATTENTION**: Issues found that should be addressed before committing

**On NEEDS_ATTENTION**:
- Report specific issues
- Ask user: "Fix issues and retry" / "Accept as-is" / "Revert"

## Tier 4: Cross-Model Review (Optional)

**Purpose**: Exploit different blind spots between models.

Only runs when `--consult` flag was provided.

1. Write the diff to a temp file
2. Invoke `/codex-review` on the diff (Codex reviews its own implementation)
3. Present findings to user

This catches issues that Claude's review might miss due to shared architectural
assumptions with the implementer. Research shows 2-3 cross-model review rounds
catch the most issues, but for ad-hoc tasks a single round is sufficient.

**Important**: This tier is advisory. Findings do not block the commit unless the
user chooses to act on them.

## Verification Flow

```
Task complete
  │
  ├─ Tier 1: Scope guard
  │   └─ Violation? → Ask user
  │
  ├─ Tier 2: Automated checks
  │   └─ Failure? → Report, ask user
  │
  ├─ Tier 3: Claude diff review
  │   └─ NEEDS_ATTENTION? → Report, ask user
  │
  ├─ Tier 4: Cross-model (if --consult)
  │   └─ Issues? → Report (advisory)
  │
  └─ All passed → Commit (unless --no-commit)
```

If any tier fails and the user chooses to revert, skip remaining tiers.

## Failure Accumulation

Track failures across tasks:

- 1 failure: normal, retry or skip
- 2 consecutive failures on same task: recommend manual implementation
- 3+ total failures across tasks: warn that quality may be degraded,
  suggest running full test suite before merging
