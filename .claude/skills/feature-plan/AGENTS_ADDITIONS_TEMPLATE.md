═══════════════════════════════════════════════════════════════════
PART 6: AGENTS_ADDITIONS.md FORMAT
═══════════════════════════════════════════════════════════════════

AGENTS.md contains **workflow and process instructions** for AI agents—HOW to work.
It does NOT contain feature-specific business logic, domain rules, or implementation details—WHAT to build.

### What Belongs in AGENTS.md (and additions)
- Workflow procedures (how to run tests, migrations, deployments)
- Process policies (commit formats, branch strategies, verification steps)
- Tool usage patterns (MCP tools, CLI commands, dev server setup)
- Quality standards (testing policy, error handling conventions)

### What Does NOT Belong in AGENTS.md
- Business logic ("price threshold is ±5%", "filter by MLS area")
- Domain-specific rules (these belong in specs)
- Feature-specific commit examples (commit FORMAT is ok, specific commits are not)
- Acceptance criteria details (these belong in EXECUTION_PLAN.md)
- Implementation details for this specific feature

---

### When NO Additions Are Needed

If the existing AGENTS.md already covers all required workflows, output:

```markdown
# AGENTS_ADDITIONS.md

No additions required. The existing AGENTS.md covers all workflows needed for this feature:
- [x] {workflow 1}
- [x] {workflow 2}
- ...
```

Do NOT add "feature context notes" or "testing notes" as filler—this is noise that doesn't belong in AGENTS.md.

---

### When Additions ARE Needed

If the feature requires workflow elements not present in the existing AGENTS.md,
output suggested additions in this format:

```markdown
# AGENTS_ADDITIONS.md

## Additions Required

### {Section Name}

**Why needed:** {One sentence explaining the workflow gap}

**Content to add:**
\`\`\`markdown
{Actual content to merge into AGENTS.md}
\`\`\`

**Where to add:** {After which existing section}
```

---

### Common Workflow Additions

Only add these if they're MISSING from the existing AGENTS.md:

**Git Branch Strategy** — If not already defined in AGENTS.md
```
## Git Conventions

### Branch Strategy

Create one branch per **phase** (not per step or task):

git checkout -b phase-{N}
# Example: git checkout -b phase-1

**Branch lifecycle:**
1. Create branch from main/develop before starting first task in phase
2. Commit after each task completion (all tasks sequential on same branch)
3. Do not push until human reviews at checkpoint
4. Create PR for review at phase checkpoint
5. Merge after checkpoint approval

### Commit Format

task({id}): {description}
# Example: task(1.2.A): Add user authentication endpoint

### Branch and Commit Structure

| Item | Format | Example |
|------|--------|---------|
| Phase branch | `phase-{N}` | `phase-1` |
| Commit | `task({id}): {description}` | `task(1.2.A): Add login form` |

Steps are logical groupings within the branch—not separate branches.
```

**Code Verification Workflow** — Recommended for all features
```
## Verification

After implementing each task, verify all acceptance criteria are met.
Use verification metadata from EXECUTION_PLAN.md. If it is missing, infer and
add the metadata to EXECUTION_PLAN.md before proceeding. If ambiguous, ask the
human to confirm the verification method.

### Primary: Code Verification Skill (Claude Code)

If using Claude Code with the code-verification skill available:

Use /code-verification to verify this task against its acceptance criteria

The skill will:
- Parse each acceptance criterion
- Spawn sub-agents to verify each one
- Attempt fixes (up to 5 times) for failures
- Generate a verification report

### Fallback: Manual Verification Checklist

If the code-verification skill is not available, manually verify:

1. **Run tests** — Use the configured test command
2. **Type check** — Use the configured typecheck command (if applicable)
3. **Lint** — Use the configured lint command (if applicable)
4. **Manual check** — For each acceptance criterion:
   - Read the criterion
   - Verify it is met (inspect code, run app, check output)
   - If not met, fix and re-verify
5. **Document** — Note verification status in completion report
```

**Checkbox Update Format** — If not already defined in AGENTS.md
```
## Progress Tracking

When completing acceptance criteria, update EXECUTION_PLAN.md checkboxes:

# Before
- [ ] User can log in with email and password

# After
- [x] User can log in with email and password
```

**Browser Verification Workflow** — If feature has UI acceptance criteria
```
## Browser Verification

For acceptance criteria marked `BROWSER:*`:
1. Start dev server if not running
2. Navigate to relevant pages
3. Verify each UI acceptance criterion using `Verify:` metadata
4. Check browser console for errors
5. Capture screenshots for visual changes
```

**Regression Testing Policy** — If feature modifies existing functionality
```
## Regression Testing

When modifying existing code:
- Run full test suite, not just new tests
- Verify existing functionality still works
- Document any intentional behavior changes
```

**Test Quality Standards** — Recommended if AGENTS.md lacks testing guidance
```
## Test Quality Standards

### Test Structure
Use the AAA pattern for all tests:
1. **Arrange** — Set up test data and preconditions
2. **Act** — Execute the code under test
3. **Assert** — Verify the expected outcome

### Test Naming
Use descriptive names: `should {expected behavior} when {condition}`

### What to Test
- Happy path (valid inputs → expected outputs)
- Edge cases (empty, null, boundary values)
- Error cases (invalid inputs → appropriate errors)

### What NOT to Test
- Private implementation details
- Framework/library code
- Trivial getters/setters without logic
```

**Mocking Policy** — If feature involves external dependencies
```
## Mocking Policy

### What to Mock
| Dependency Type | Mock Strategy |
|-----------------|---------------|
| External APIs | Mock HTTP client or use MSW/nock |
| Database | Use test database or in-memory alternative |
| File system | Use temp directories, clean up after test |
| Time/dates | Use fixed timestamps |

### What NOT to Mock
- The code under test itself
- Pure functions with no side effects

### Mock Hygiene
- Reset mocks between tests
- Prefer dependency injection over global mocks
- Mock at the boundary, not deep in the call stack
```

**Database Migration Workflow** — If feature includes schema changes
```
## Database Migrations

For tasks involving database changes:
1. Write migration before implementation code
2. Test migration up AND down
3. Verify existing data is preserved
4. Document rollback procedure
```

**Follow-Up Items Workflow** — Always include this section
```
## Follow-Up Items (TODOS.md)

During development, you will discover items outside current task scope: refactoring opportunities, edge cases, documentation needs, technical debt, etc.

**When you identify a follow-up item:**

1. **Prompt the human to start TODOS.md** if it doesn't exist:
   I've identified a follow-up item: {description}
   Should I create TODOS.md to track this and future items?

2. **Add items to TODOS.md** with context:
   ## TODO: {Brief title}
   - **Source:** Task {id} or {file:line}
   - **Description:** {What needs to be done}
   - **Priority:** {Suggested: High/Medium/Low}
   - **Added:** {Date}

3. **Prompt for prioritization** when the list grows or at phase checkpoints:
   TODOS.md now has {N} items. Would you like to:
   - Review and prioritize them?
   - Add any to the current phase?
   - Defer to a future phase?

Do not silently ignore discovered issues. Do not scope-creep by fixing them without approval. Track them in TODOS.md and let the human decide.
```
