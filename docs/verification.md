# Verification Deep Dive

The toolkit enforces quality through multiple verification mechanisms that run automatically during execution.

## Code Verification

Every task has testable acceptance criteria. After completing a task, the `code-verification` skill checks:

- All acceptance criteria are met
- Tests pass
- No regressions introduced

The verification uses a multi-agent approach: a sub-agent independently verifies the work against criteria, preventing the implementing agent from marking incomplete work as done.

## TDD Enforcement

The `/verify-task` command includes TDD compliance checking.

### What It Verifies

| Check | Description |
|-------|-------------|
| **Test existence** | Every acceptance criterion has a corresponding test |
| **Test-first** | Tests were committed before or with implementation (via git history) |
| **Test effectiveness** | Tests have meaningful assertions and descriptive names |

### TDD Compliance Report

When running `/verify-task`, you'll see:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 3/3 criteria covered
Test-First: PASS
Issues: None
```

If tests are missing or were written after implementation:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 2/3 criteria covered
Test-First: WARNING
Issues:
- [Criterion 3] Missing test
- [Criterion 1] Test added after implementation
```

### Test Quality Standards

The generated `AGENTS.md` includes test quality standards:

- **AAA Pattern** — Tests use Arrange-Act-Assert structure
- **Naming** — Tests use `should {behavior} when {condition}` format
- **Coverage** — Happy path, edge cases, error cases, state changes
- **Independence** — No shared mutable state between tests

### Mocking Policy

`AGENTS.md` also includes mocking guidelines:

- **What to mock** — External APIs, databases, file system, time, random values
- **What not to mock** — Code under test, pure functions
- **Mock hygiene** — Reset between tests, prefer dependency injection

## Test Quality Gate (Optional)

Beyond TDD compliance, `/verify-task` performs a lightweight test-quality gate.
It checks that tests are meaningful, not just present.

### What It Checks

- Each acceptance criterion has at least one assertion that checks behavior
- At least one non-happy-path or boundary case is covered when applicable
- Tests verify state changes or outputs (not just "does not throw")
- External dependencies are mocked; code under test is not

If any criterion lacks assertions or only smoke-tests behavior, verification
stops until tests are improved.

### Optional Mutation Testing

If your project uses mutation testing, configure it in
`.claude/verification-config.json`:

```json
{
  "commands": {
    "mutation_test": "npm run test:mutation"
  }
}
```

When configured, `/verify-task` can run mutation tests on request, and
`/phase-checkpoint` treats mutation test failures as a local verification
failure.

## Automatic Spec Verification

After generating `TECHNICAL_SPEC.md`, `EXECUTION_PLAN.md`, or their feature equivalents, the toolkit automatically runs verification.

### Context Preservation

Ensures nothing important is lost as requirements flow through the document chain:

```
PRODUCT_SPEC.md → TECHNICAL_SPEC.md → EXECUTION_PLAN.md
```

For each upstream document, verification extracts key items (features, constraints, edge cases) and confirms they appear in the downstream document—either directly, consolidated into broader items, or explicitly deferred.

### Quality Checks

Scans for common specification anti-patterns:

| Issue Type | Example | Why It Matters |
|------------|---------|----------------|
| Vague language | "API should be fast" | Can't write tests for unmeasurable requirements |
| Missing rationale | "Use Redis" | Without "why", future decisions lack context |
| Undefined contracts | "POST /users" without request shape | Implementation will guess or stall |
| Untestable criteria | "Should feel intuitive" | Acceptance criteria must be verifiable |
| Scope creep | Feature in tech spec not in product spec | Requirements should flow downstream, not appear spontaneously |

### Interactive Repair

When issues are found, verification presents each one with resolution options:

```
ISSUE 1 of 2: Vague Language
Location: TECHNICAL_SPEC.md, Section "Performance"
Problem: "API responses should be fast" is unmeasurable

How would you like to resolve this?
○ Use suggested: "API responses return within 200ms p95" (Recommended)
○ Specify custom target
○ Remove requirement
```

Fixes are applied automatically based on your choices, then re-verified.

### Manual Verification

Run verification manually anytime:

```bash
/verify-spec technical-spec      # Verify TECHNICAL_SPEC.md
/verify-spec execution-plan      # Verify EXECUTION_PLAN.md
/verify-spec feature-technical   # Verify FEATURE_TECHNICAL_SPEC.md
/verify-spec feature-plan        # Verify feature EXECUTION_PLAN.md
```

## Browser Verification

For acceptance criteria that require browser interaction (UI rendering, user flows, visual checks), the toolkit supports automated browser verification with authentication.

### Supported Tools (in fallback order)

| Tool | Package | Best For |
|------|---------|----------|
| **ExecuteAutomation Playwright** | `@executeautomation/playwright-mcp-server` | Primary choice — most stable, 143 device presets |
| **Browser MCP** | [browsermcp.io](https://browsermcp.io/) extension | Uses existing browser sessions (stays logged in) |
| **Microsoft Playwright MCP** | `@anthropic-ai/mcp-server-playwright` | Official, but avoid `@latest` (includes unstable betas) |
| **Chrome DevTools MCP** | Built-in | Basic fallback, good for debugging |

The toolkit auto-detects available tools and uses the best option. Configure via `/configure-verification`.

**Note:** Avoid `@playwright/mcp@latest` — it includes unstable beta releases that cause "undefined" errors. Use ExecuteAutomation Playwright or a pinned Microsoft version instead.

### Authentication

Many apps require login before browser verification can access protected pages. The toolkit supports authenticated browser sessions:

1. **Run `/configure-verification`** — Answer questions about login route and credentials
2. **Create `.env.verification`** — Copy from `.env.verification.example` and fill in test credentials
3. **Verification auto-authenticates** — Browser skills log in before checking protected pages

```
# .env.verification (never commit this file)
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=your-test-password
```

The auth state is cached in `.claude/verification/auth-state.json` to avoid repeated logins.

### Fallback Chain

When browser verification runs, tools are tried in order:

1. **ExecuteAutomation Playwright MCP** — Primary, most stable
2. **Browser MCP** — If extension installed (uses existing sessions)
3. **Microsoft Playwright MCP** — If pinned version configured
4. **Chrome DevTools MCP** — Basic fallback, often pre-installed
5. **Manual verification** — If no tools available (with soft block prompt)

### Soft Block Behavior

When browser-based acceptance criteria exist but no browser MCP tools are available, the toolkit prompts before continuing:

```
⚠️  BROWSER VERIFICATION BLOCKED

This phase has {N} browser-based acceptance criteria but no browser
MCP tools are available.

Options:
1. Continue anyway (browser criteria become manual verification)
2. Stop and configure browser tools first
```

This prevents silent failures and ensures you're aware when automated browser verification can't run.

### No Browser Tools?

If no browser MCP is configured, browser-based criteria require manual verification. To enable automation, add to `~/.mcp.json`:

```json
{
  "mcpServers": {
    "executeautomation-playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    },
    "browsermcp": {
      "command": "npx",
      "args": ["@browsermcp/mcp@latest"]
    }
  }
}
```

**Note:** Browser MCP also requires the Chrome extension from [browsermcp.io](https://browsermcp.io/).

**Avoid:** `@playwright/mcp@latest` — includes unstable betas. Use ExecuteAutomation for stability.

## Auto-Verify (Automation Before Manual)

Before marking any verification item as "manual," the toolkit attempts automated verification using available tools. This reduces unnecessary human interruptions.

### How It Works

1. **Pattern Detection** — Criterion text is analyzed for automation hints (keywords like "API," "endpoint," "page loads," "file exists")
2. **Tool Selection** — Best available tool is chosen (curl is always available; browser MCP conditional)
3. **Execution** — Verification command runs with appropriate timeout
4. **Fallback** — Only if automation fails or is genuinely impossible does the item become manual

### Pattern Matching

| Criterion Pattern | Tool Used | Example |
|-------------------|-----------|---------|
| API endpoint, returns, status | curl | `curl -sf http://localhost:3000/api/users` |
| Response contains, JSON | curl + jq/grep | `curl -s {url} \| jq -e '.users'` |
| Redirect, Location header | curl | `curl -sI {url} \| grep Location` |
| Page loads, accessible | curl (HTTP-first) | `curl -sf {url}` |
| Element visible, shows | Browser MCP | Browser snapshot + selector check |
| File exists, created | bash | `test -f {path}` |
| Env var, environment | bash | `test -n "${VAR}"` |
| Looks, feels, UX, intuitive | **None** | Truly manual (subjective) |

### HTTP-First Optimization

Many "browser" criteria can be satisfied with a simple HTTP check. Before launching browser tools, the toolkit checks if the criterion only requires:

- Page accessibility (HTTP 200 status)
- API response validation
- Redirect verification

If curl satisfies the criterion and DOM inspection isn't needed, browser tools are skipped entirely — saving time and avoiding MCP dependency issues.

### Manual Verification Report

When running `/phase-checkpoint` or `/verify-task`, manual items are categorized:

```
Manual Local Checks:
- Automated: 3 items verified automatically
- Failed automation: 1 item (see details)
- Truly manual: 1 item (human judgment required)

Automated Successfully:
- [x] "Test API endpoints" — PASS (curl, 0.2s)
- [x] "Page loads at /dashboard" — PASS (HTTP-first, 0.1s)

Failed Automation:
- [ ] "Verify login form visible"
  - Attempted: curl (HTTP status)
  - Error: Element inspection requires browser MCP
  - Steps: 1. Navigate to /login 2. Verify form is visible

Truly Manual:
- [ ] "Verify UX feels intuitive"
  - Reason: subjective judgment required
  - Steps: 1. Navigate through app 2. Assess user experience
```

### Truly Manual Patterns

These patterns indicate criteria that genuinely require human judgment:

- `looks`, `appears`, `visual` — Subjective visual assessment
- `feels`, `intuitive`, `UX` — User experience judgment
- `brand`, `tone`, `voice` — Brand consistency
- `professional`, `polished` — Quality perception
- `appropriate`, `suitable` — Context-dependent evaluation

## Phase Checkpoint Verification

Phase checkpoints (`/phase-checkpoint N`) run a two-stage verification process.

### Local-First Verification

Local verification runs first. All local checks must pass before production verification begins:

| Check | Description |
|-------|-------------|
| Tests | All tests pass (unit, integration, e2e) |
| Lint | No linting errors |
| Build | Project builds successfully |
| Types | No type errors |
| Security scan | No critical/high vulnerabilities |
| Task verification | All phase tasks pass acceptance criteria |

### Production Verification

Only runs after local verification passes:

| Check | Description |
|-------|-------------|
| Deployment | App deploys and starts correctly |
| Smoke tests | Critical paths work in deployed environment |
| Integration | External service integrations function |

This prevents wasted cycles on production checks when basic issues exist locally.

### Auto-Advance

When verification passes with no manual items, the workflow automatically advances:

```
/phase-prep → /phase-start → /phase-checkpoint → /phase-prep N+1
     ↓              ↓               ↓
  (if ready)   (if no manual)  (if all pass)
```

**Core Principle:** If AI completes verification → AI auto-advances. If human completes verification → human triggers next step.

Auto-advance conditions for each command:

| Command | Auto-Advances When |
|---------|-------------------|
| `/phase-prep N` | All Pre-Phase Setup items are PASS |
| `/phase-start N` | All tasks complete AND no truly manual items (auto-verify attempted first) |
| `/phase-checkpoint N` | All automated checks pass AND no truly manual items remain |

Each transition shows a 15-second countdown. Press Enter to pause and take manual control.

**Configuration** (`.claude/settings.local.json`):
```json
{
  "autoAdvance": {
    "enabled": true,      // default: true
    "delaySeconds": 15    // default: 15
  }
}
```

**Session Tracking:** During auto-advance chains, progress is logged to `.claude/auto-advance-session.json`. When the chain stops, a summary report shows all completed steps and why it stopped.

## Security Scanning

The toolkit includes integrated security scanning that runs automatically during `/phase-checkpoint` and can be invoked manually via `/security-scan`.

### What It Checks

| Category | Examples | Severity |
|----------|----------|----------|
| **Dependency vulnerabilities** | Known CVEs in project dependencies | CRITICAL-LOW |
| **Hardcoded secrets** | AWS keys, GitHub tokens, API keys, private keys | CRITICAL-HIGH |
| **Insecure code patterns** | `eval()`, SQL concatenation, disabled SSL verification | HIGH-MEDIUM |

### How It Works

1. **Discovers security tooling** from project docs and configuration
2. **Runs documented tools** (or prompts for commands if missing)
3. **Presents findings** with severity levels and fix suggestions
4. **Offers resolution options** for each CRITICAL/HIGH issue
5. **Blocks checkpoint** if unresolved CRITICAL/HIGH issues remain

### Manual Scanning

```bash
/security-scan              # Full scan (deps + secrets + code)
/security-scan --deps       # Dependency vulnerabilities only
/security-scan --secrets    # Secrets detection only
/security-scan --code       # Static analysis only
/security-scan --fix        # Auto-fix where possible
```

## Stuck Detection

Agents can get stuck in loops, repeatedly failing on the same issue. The toolkit detects this and escalates to human intervention.

### Escalation Triggers

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Consecutive task failures | 3 tasks | Pause phase |
| Same error pattern | 2 occurrences | Pause and report |
| Verification loop | 5 attempts on same criterion | Mark task blocked |
| Test flakiness | Same test passes then fails | Flag for review |

### What Happens

When stuck, the agent stops and presents:
- Pattern description (what keeps failing)
- Last 3 errors
- Possible causes
- Options: skip task, modify criteria, try different approach, abort phase

This prevents agents from burning tokens on unfixable issues and ensures human judgment is applied where needed.
