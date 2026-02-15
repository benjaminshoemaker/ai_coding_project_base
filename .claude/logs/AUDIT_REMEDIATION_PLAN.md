# Audit Remediation Plan

Addressing all Critical and Medium findings from the skill audit report.

## Scope

- Critical: 16 findings (L1, C1, C2)
- Medium: 46 findings (D1, E1, C3, D3, S3, L2)
- Low: SKIPPED (S2, D2, E2)

## Changes by Category

### 1. L1/L2: Split oversized monolithic prompts (4 findings, 2 files)

**GENERATOR_PROMPT.md (663 lines):**
- Extract Part 3 (AGENTS.md template, ~200 lines) into `AGENTS_TEMPLATE.md`
- Replace inline template with `Read [AGENTS_TEMPLATE.md](AGENTS_TEMPLATE.md) for the AGENTS.md template.`
- Target: <500 lines

**feature-plan/PROMPT.md (757 lines):**
- Extract the AGENTS_ADDITIONS.md format section and example AGENTS.md additions into `AGENTS_ADDITIONS_TEMPLATE.md`
- Replace inline content with reference link
- Target: <500 lines

### 2. C1: Add checklists to 9 files

Add a copyable checklist code block to each file's workflow section:

| File | Steps to list |
|------|---------------|
| phase-prep (skill) | Pre-flight checks 1-7 + auto-advance decision |
| capture-learning (cmd) | Get content, category, context, write, confirm |
| gh-init (cmd) | Determine target, check git, detect type, gitignore, init, remote |
| run-todos (cmd) | Find items, select, git workflow, implement loop, summary |
| install-hooks (cmd) | Verify git, list hooks, install selected, report |
| product-spec (cmd) | Directory guard, file guard, Q&A, write, deferred, review, next |
| technical-spec (cmd) | Directory guard, file guard, Q&A, verify, deferred, review, next |
| generate-plan (cmd) | Directory guard, file guard, process, setup env, verify, review, next |
| sync (cmd) | Detect direction, resolve paths, load state, detect changes, sync, update version, report |

### 3. C2: Add verification after critical actions (5 files)

| File | Action needing verification | Fix |
|------|---------------------------|-----|
| fresh-start (skill) | Git ops (add, commit, checkout -b) | Add `git status` / `git branch` verification after each git operation |
| fresh-start (skill) | /configure-verification invocation | Add "If /configure-verification fails, report error and continue manually" |
| product-spec (cmd) | Writing PRODUCT_SPEC.md | Add file existence check after write |
| criteria-audit (skill) | Reading PATTERNS.md | Add "If PATTERNS.md not found, skip false-MANUAL check and note limitation" |
| oauth-login (skill) | Token exchange | Add actual token validity test (e.g., test API call with obtained token) |
| progress (skill) | Parsing EXECUTION_PLAN.md | Add parse validation (check that phases/tasks were found) |

### 4. D1: Add "Use when..." trigger phrases (21 files)

Update YAML `description` field to include trigger phrases. Examples:

| File | Current | Proposed addition |
|------|---------|-------------------|
| auto-verify | "Attempt automated verification..." | + "Invoked by verify-task and phase-checkpoint for MANUAL criteria." |
| browser-verification | "Verify browser-based..." | + "Invoked by verify-task and phase-checkpoint for BROWSER:* criteria." |
| analyze-sessions | "Analyze session logs..." | + "Use periodically after multiple sessions to find automation opportunities." |
| configure-verification | "Auto-detect verification commands..." | + "Use during project setup or when build tooling changes." |
| data-flow-audit | "Detect split data source..." | + "Use at phase checkpoints or when investigating data consistency issues." |
| feature-spec | "Generate FEATURE_SPEC.md..." | + "Use when starting a new feature to define requirements." |
| feature-technical-spec | "Generate FEATURE_TECHNICAL_SPEC.md..." | + "Use after /feature-spec to define the technical approach." |
| feature-plan | "Generate EXECUTION_PLAN.md..." | + "Use after /feature-technical-spec to create the task breakdown." |
| go | "Resume execution..." | + "Use at the start of any session to pick up where you left off." |
| merge-prs | "Merge multiple PRs..." | + "Use when multiple feature branches need merging into the base branch." |
| security-scan | "Scan for security vulnerabilities..." | + "Use at phase checkpoints or before releases to check for vulnerabilities." |
| vercel-preview | "Resolve Vercel preview deployment URL..." | + "Use to check deployment status or when browser verification needs a URL." |
| verify-spec (cmd) | "Verify a specification document..." | + "Use after generating any spec document to check for quality issues." |
| capture-learning (cmd) | "Capture a project learning..." | + "Use when you discover a useful pattern or convention during development." |
| gh-init (cmd) | "Initialize git repo..." | + "Use when starting a new project that needs a GitHub repository." |
| run-todos (cmd) | "Implement [ready]-tagged TODO items..." | + "Use after /list-todos has marked items as [ready] for implementation." |
| install-hooks (cmd) | "Install git hooks..." | + "Use during project setup or after cloning to install automation hooks." |
| product-spec (cmd) | "Generate PRODUCT_SPEC.md..." | + "Use as the first step when starting a new greenfield project." |
| technical-spec (cmd) | "Generate TECHNICAL_SPEC.md..." | + "Use after /product-spec to define the technical architecture." |
| generate-plan (cmd) | "Generate EXECUTION_PLAN.md..." | + "Use after /technical-spec to create the phased task breakdown." |
| sync (cmd) | "Synchronize target projects..." | + "Use after toolkit skills are modified to push updates to target projects." |

### 5. E1: Add error handling sections (8 files)

| File | Error paths to add |
|------|-------------------|
| audit-skills (skill) | CRITERIA.md/SCORING.md not found; no auditable files found; file unreadable |
| criteria-audit (skill) | EXECUTION_PLAN.md not found; no acceptance criteria found; PATTERNS.md missing |
| fresh-start (skill) | Git init failure; AGENTS_ADDITIONS merge failure; phase-prep failure |
| sync (cmd) | shasum unavailable; file copy failure; git command failure |
| feature-spec/PROMPT.md | Insufficient project context; vague feature idea; overlapping functionality |
| PRODUCT_SPEC_PROMPT.md | Contradictory requirements; scope too large; insufficient input |
| TECHNICAL_SPEC_PROMPT.md | Ambiguities in PRODUCT_SPEC; infeasible requirements; missing information |
| GENERATOR_PROMPT.md | Contradictions between specs; specs insufficient for task generation |

### 6. C3: Add feedback loops (8 files)

Add a lightweight "Review your output" section to each:

| File | Feedback mechanism |
|------|-------------------|
| data-flow-audit (skill) | After report generation, verify all scanned files are represented and findings are actionable |
| list-todos (skill) | After analysis, confirm count matches TODOS.md and priorities are justified |
| vision-audit (skill) | After proposals, cross-check each against principles filter and verify no SDLC outcomes were missed |
| feature-spec/PROMPT.md | Before finalizing, re-read spec against original user answers to verify nothing was lost |
| feature-technical-spec/PROMPT.md | Before finalizing, verify all FEATURE_SPEC.md requirements are addressed |
| feature-plan/PROMPT.md | After generation, verify task coverage against both spec documents |
| PRODUCT_SPEC_PROMPT.md | Before finalizing, re-read spec against user answers to verify completeness |
| TECHNICAL_SPEC_PROMPT.md | Before finalizing, verify all PRODUCT_SPEC.md requirements have technical approaches |

### 7. D3: Improve vague descriptions (4 files)

| File | Current | Proposed |
|------|---------|----------|
| configure-verification | "Auto-detect verification commands for this project from package.json, Makefile, and other sources. Runs silently — no prompts." | "Auto-detect test, lint, typecheck, and build commands from package.json, Makefile, and other project config. Use during project setup or when build tooling changes. Runs silently — no prompts." |
| feature-spec | "Generate FEATURE_SPEC.md through guided Q&A" | "Define feature requirements (problem, users, scope, acceptance criteria) through guided Q&A and write FEATURE_SPEC.md. Use when starting a new feature." |
| feature-technical-spec | "Generate FEATURE_TECHNICAL_SPEC.md through guided Q&A" | "Define technical approach (architecture, integration points, data model) for a feature through guided Q&A and write FEATURE_TECHNICAL_SPEC.md. Use after /feature-spec." |
| verify-spec (cmd) | "Verify a specification document for context preservation and quality issues" | "Verify that a generated spec document preserves all upstream requirements and has no structural quality issues. Use after generating any spec document." |

### 8. S3: Clarify ambiguous action vs reference (3 files)

| File | Issue | Fix |
|------|-------|-----|
| audit-skills (skill) | Step 1 shows `find` commands | Change to explicit: "Use Glob to find files matching these patterns:" |
| data-flow-audit (skill) | Steps reference DETECTION_PATTERNS.md with inline summaries | Add explicit: "Read DETECTION_PATTERNS.md for the full procedure. The summary below is for quick reference only." |
| security-scan (skill) | "Apply fixes" is ambiguous | Change to: "Propose fixes to the user. Do not apply fixes automatically — present them for approval." |

## Files Modified (deduplicated)

**Skills (18):** audit-skills, auto-verify, browser-verification, analyze-sessions, configure-verification, criteria-audit, code-verification (D1 only — wait, code-verification wasn't D1), data-flow-audit, feature-spec, feature-technical-spec, feature-plan, fresh-start, go, list-todos, merge-prs, oauth-login, phase-prep, progress, security-scan, vercel-preview, vision-audit

**Commands (9):** all 9

**Prompts (6):** feature-spec/PROMPT.md, feature-technical-spec/PROMPT.md, feature-plan/PROMPT.md, PRODUCT_SPEC_PROMPT.md, TECHNICAL_SPEC_PROMPT.md, GENERATOR_PROMPT.md

**New files (2):** AGENTS_TEMPLATE.md, .claude/skills/feature-plan/AGENTS_ADDITIONS_TEMPLATE.md

Total: ~35 files modified, 2 new files created
