---
name: feature-audit
description: Multi-source audit of a shipped feature against its original plans, product vision, UI/UX best practices, and live browser inspection. Produces consolidated findings with prioritized recommendations.
argument-hint: "[--spec FILE] [--plan FILE] [--vision DIR] [--url URL] [--skip-browser] [--skip-codex]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
---

# Feature Audit

Comprehensive post-implementation audit of a shipped feature. Gathers evidence from 5 independent sources, then synthesizes into a consolidated analysis with prioritized findings.

## When to Use

- After a major feature ships and you want to assess quality, completeness, and UX
- When reviewing whether an implementation matches its original spec
- When you want a structured, multi-perspective evaluation before the next iteration
- When preparing a "what's next" roadmap for a feature area

**Not for:** Code-level diff reviews (use `/codex-review`), pre-ship verification (use `/verify-task`), or security scanning (use `/security-scan`).

## Prerequisites

- Feature spec or plan document exists (the "what was designed")
- The feature is deployed/accessible in a running app (for browser inspection)
- Product vision/principles docs exist somewhere in the project (for strategic alignment)

## Arguments

| Argument | Example | Default | Description |
|----------|---------|---------|-------------|
| `--spec FILE` | `--spec features/recs/FEATURE_SPEC.md` | — | Path to the feature specification |
| `--plan FILE` | `--plan ~/.claude/plans/my-plan.md` | — | Path to the execution/implementation plan |
| `--vision DIR` | `--vision docs/vision/` | — | Directory containing product vision docs (VISION.md, PRODUCT_PRINCIPLES.md, PRODUCT_MAP.md) |
| `--url URL` | `--url http://localhost:4321` | — | Base URL of the running application |
| `--login-url URL` | `--login-url /api/dev/login` | — | Path to auto-login endpoint (appended to base URL) |
| `--pages PATHS` | `--pages "/overview,/communities/CRTET"` | — | Comma-separated pages to inspect |
| `--skip-browser` | | false | Skip browser inspection (when app isn't running) |
| `--skip-codex` | | false | Skip Codex consultation (when Codex CLI unavailable) |
| `--skip-research` | | false | Skip UI/UX web research |

## Workflow

Copy this checklist and track progress:

```
Feature Audit Progress:
- [ ] Step 1: Gather inputs (interactive Q&A for missing args)
- [ ] Step 2: Read feature plans and product context
- [ ] Step 3: Launch parallel research streams
    - [ ] 3a: Code exploration (what was actually built)
    - [ ] 3b: UI/UX pattern research (web search)
    - [ ] 3c: Codex consultation (cross-model analysis)
    - [ ] 3d: Browser inspection (live UI audit)
- [ ] Step 4: Wait for all streams to complete
- [ ] Step 5: Synthesize consolidated analysis
- [ ] Step 6: Present findings to user
```

---

## Step 1: Gather Inputs

For each required input not provided as an argument, ask the user interactively.

### Feature Spec Location

If `--spec` not provided:

```
Question: "Where is the feature specification?"
Header: "Feature Spec"
Options:
  - Label: "features/ directory"
    Description: "Look in the features/ directory for a FEATURE_SPEC.md"
  - Label: "Provide path"
    Description: "I'll type the path to the spec file"
  - Label: "No spec exists"
    Description: "Skip spec alignment checking"
```

If "features/ directory" selected, search:
```bash
find features/ -name "FEATURE_SPEC.md" -o -name "*.spec.md" 2>/dev/null
```
Present found files for selection.

### Execution Plan Location

If `--plan` not provided:

```
Question: "Is there an execution plan or implementation plan for this feature?"
Header: "Execution Plan"
Options:
  - Label: "~/.claude/plans/ directory"
    Description: "Look in the Claude plans directory"
  - Label: "Provide path"
    Description: "I'll type the path to the plan file"
  - Label: "No plan exists"
    Description: "Skip plan alignment checking"
```

If "plans directory" selected, list recent plan files:
```bash
ls -lt ~/.claude/plans/*.md 2>/dev/null | head -10
```

### Product Vision Docs

If `--vision` not provided:

```
Question: "Where are the product vision/principles documents?"
Header: "Product Vision"
Options:
  - Label: "docs/vision/"
    Description: "Standard location for vision docs"
  - Label: "Provide directory"
    Description: "I'll specify the directory"
  - Label: "No vision docs"
    Description: "Skip strategic alignment analysis"
```

Scan provided directory for: `VISION.md`, `PRODUCT_PRINCIPLES.md`, `PRODUCT_MAP.md`, `DOMAIN_GLOSSARY.md`

### Application URL

If `--url` not provided and `--skip-browser` not set:

```
Question: "What is the base URL of the running application?"
Header: "App URL"
Options:
  - Label: "http://localhost:4321"
    Description: "Astro dev server default"
  - Label: "http://localhost:3000"
    Description: "Next.js / React dev server default"
  - Label: "Provide URL"
    Description: "I'll type the URL"
  - Label: "Skip browser inspection"
    Description: "App isn't running — skip live UI audit"
```

### Pages to Inspect

If `--pages` not provided and browser inspection is enabled:

```
Question: "Which pages should I inspect for this feature? (comma-separated paths)"
Header: "Pages to Audit"
```

Let user type paths like `/overview, /communities/CRTET, /communities/CRTET/what-if/123`

### Login URL

If `--login-url` not provided and browser inspection is enabled:

```
Question: "Does the app have an auto-login endpoint for dev?"
Header: "Dev Login"
Options:
  - Label: "/api/dev/login"
    Description: "Standard KineticBI dev login endpoint"
  - Label: "Provide path"
    Description: "I'll type the login path"
  - Label: "No auto-login"
    Description: "App doesn't require auth or login is manual"
```

---

## Step 2: Read Feature Plans and Product Context

Read all located documents into context:

1. **Feature spec** — the original design/requirements
2. **Execution plan** — the implementation approach
3. **Vision docs** — product principles, target users, strategic goals
4. **AGENTS.md / CLAUDE.md** — project conventions and patterns

Extract key context for downstream agents:
- **Feature name and summary** (from spec)
- **Target users and their goals** (from vision docs)
- **Key acceptance criteria** (from spec)
- **Product principles** (from vision/principles doc)
- **App tech stack** (from AGENTS.md)

---

## Step 3: Launch Parallel Research Streams

Launch up to 4 independent research streams using the Task tool. All streams run in parallel.

### Stream 3a: Code Exploration

```
Task(subagent_type="Explore", run_in_background=true)
```

Prompt the agent to:
- Find all files modified/created for the feature (use git log if branch info available)
- Read key implementation files (engine, types, components, API endpoints)
- Summarize what was actually built: categories, data model, UI components, API surface
- Identify what exists vs what's missing compared to the spec
- Check for: test coverage, PostHog analytics, error handling

### Stream 3b: UI/UX Pattern Research

Skip if `--skip-research` is set.

```
Task(subagent_type="general-purpose", run_in_background=true)
```

Prompt the agent to research (via WebSearch):
- UI/UX patterns for the type of feature being audited
- Best practices for the target user profile
- How comparable B2B SaaS tools handle similar features
- Progressive disclosure, information density, action-driving patterns
- Alert fatigue prevention if recommendations/notifications are involved

### Stream 3c: Codex Consultation

Skip if `--skip-codex` is set.

**Pre-flight checks:**
```bash
codex --version 2>/dev/null || echo "CODEX_NOT_AVAILABLE"
echo "${CODEX_SANDBOX:-NOT_IN_CODEX}"
```

If Codex is available and we're not inside Codex:

1. Build a consultation prompt incorporating:
   - Feature spec content
   - Execution plan content
   - Key implementation file diffs or current content
   - 5 evaluation dimensions: spec alignment, UI/UX quality, improvement opportunities, data visualization effectiveness, output quality (PDF/reports)
2. Record HEAD before invocation
3. Invoke Codex synchronously (do NOT use `run_in_background` for the Bash command):

```bash
cat {prompt_file} | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy="never"' \
  -c 'features.search=true' \
  --model $CODEX_MODEL \
  -o $OUTPUT_FILE \
  -
```

4. Check HEAD after — warn if Codex made commits (do NOT auto-revert per project guardrails)
5. Read Codex output

**Timeout:** Use Bash tool timeout parameter of `TIMEOUT_MINS * 60 * 1000` ms.

### Stream 3d: Browser Inspection

Skip if `--skip-browser` is set.

```
Task(subagent_type="general-purpose", run_in_background=true)
```

Prompt the agent to:
1. Navigate to the login URL to establish a session
2. For each page in the pages list:
   - Navigate to the page
   - Take screenshots (full page + key sections)
   - Inspect the DOM for accessibility issues
   - Check for console errors
   - Note: layout, visual hierarchy, information density, actionability
   - Check responsive behavior if relevant
3. Try clicking key interactive elements (buttons, drawers, expand/collapse)
4. Report detailed observations per page:
   - What works well (good UX patterns)
   - What seems off (cluttered, confusing, missing context)
   - Whether information density is appropriate for expert users
   - Whether actions/recommendations feel actionable (specific, not vague)
   - Color usage, typography, spacing
   - Any accessibility concerns
   - Any runtime errors or crashes

Use Playwright MCP tools as primary, Chrome DevTools MCP as fallback.

---

## Step 4: Wait for Streams to Complete

Check on background agents periodically. When all have completed, collect their outputs.

If any stream fails:
- Note the failure in the final report
- Continue with available data from other streams
- Do not block the entire audit on one failed stream

---

## Step 5: Synthesize Consolidated Analysis

Merge findings from all completed streams into a single structured report. The report has these sections:

### Report Structure

See [REPORT_TEMPLATE.md](REPORT_TEMPLATE.md) for the full output template.

**Section 1: Spec Alignment Assessment**
- Table of spec items: implemented / missing / diverged
- For each mismatch: severity (HIGH/MEDIUM/LOW) and detail
- Source attribution (which stream identified this)

**Section 2: Critical Issues (P0)**
- Runtime bugs, crashes, broken pages found by browser inspection
- Security or data integrity issues
- Blocking UX problems

**Section 3: UX/UI Assessment**
- What works well (converging positive findings across streams)
- Issues and improvement opportunities, organized by severity
- Each finding attributed to source(s) that identified it

**Section 4: Strategic Assessment**
- Does the feature achieve its stated goals?
- How well does it align with product principles?
- Key architectural decisions to make

**Section 5: Prioritized Recommendations**
- HIGH: Must address before next iteration
- MEDIUM: Should address soon
- LOW: Nice-to-have improvements

**Section 6: Summary of Next Steps**
- Numbered list of concrete actions
- Questions for the user to decide on

### Synthesis Rules

1. **Convergence = confidence:** When multiple streams identify the same issue, flag it as high-confidence
2. **Unique findings are valuable:** Single-source findings are still reported, with source noted
3. **Disagreements are noted:** If streams disagree, present both perspectives
4. **Quantify where possible:** Use dollar amounts, percentages, counts from the data
5. **Be specific:** "Reprice button is hidden below the fold on /overview" not "button placement needs work"

---

## Step 6: Present Findings

Present the consolidated report directly to the user in the conversation. Include:

1. A summary of what was audited and which streams completed
2. The full structured report (see REPORT_TEMPLATE.md)
3. Explicit questions for the user to decide on (architectural choices, priority calls)
4. Suggestion for next steps ("Should I create tasks for the HIGH items?")

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Feature spec not found | Ask user for path; if none exists, skip spec alignment section |
| No vision docs found | Skip strategic alignment section; note in report |
| App not running | Skip browser inspection; note in report |
| Codex CLI not installed | Skip Codex consultation; note in report |
| Codex times out | Report partial output if available; note timeout |
| Browser agent crashes | Report what was captured before crash; continue with other streams |
| All streams fail | Report failure; suggest running individual checks manually |
| Git history unavailable | Use file modification times instead of git log for change detection |

## Configuration

Read from `.claude/settings.local.json` if present:

```json
{
  "featureAudit": {
    "codexModel": "gpt-5.2",
    "codexTimeoutMinutes": 20,
    "browserTimeout": 60000,
    "maxPagesToInspect": 10,
    "skipCodex": false,
    "skipBrowser": false,
    "skipResearch": false
  }
}
```

Falls back to `codexConsult` or `codexReview` config for model/timeout if `featureAudit` section is absent.

## Examples

**Full audit with all streams:**
```
/feature-audit --spec features/recommendations_overhaul/FEATURE_SPEC.md \
  --plan ~/.claude/plans/floating-whistling-fairy.md \
  --vision docs/vision/ \
  --url http://localhost:4321 \
  --login-url /api/dev/login \
  --pages "/overview,/communities/CRTET,/communities/CRTET/what-if/123"
```

**Quick audit without browser (app not running):**
```
/feature-audit --spec features/auth/FEATURE_SPEC.md --skip-browser
```

**Minimal audit (just spec alignment + code exploration):**
```
/feature-audit --spec features/search/FEATURE_SPEC.md --skip-browser --skip-codex --skip-research
```
