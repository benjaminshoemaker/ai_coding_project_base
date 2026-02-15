# AI Development Harness: Infrastructure Audit

**Repo:** `ai_coding_project_base` — a toolkit of prompts, skills, and automation for AI-first software development.

> **Important context:** This repo is not an application — it's the *harness itself*. It generates and enforces quality in *target projects*. Some infrastructure exists to maintain the toolkit's own quality; most exists to be deployed into projects the toolkit manages.

---

## 1. Test Infrastructure

**What exists in the toolkit itself: Nothing.** Zero test files, no jest/vitest/pytest config, no test scripts in `package.json`. This is intentional — the repo is markdown prompt templates, not code.

**What the toolkit deploys to target projects:**

| Component | Location | What it does |
|-----------|----------|--------------|
| `verify.sh` | `.workstream/verify.sh` | Fail-fast quality gate: typecheck → lint → test → build. Stops on first failure. |
| Verification config | `.claude/verification-config.json` | Schema for test/lint/typecheck/build/coverage/mutation commands per project |
| `/configure-verification` | `.claude/skills/configure-verification/SKILL.md` | Auto-detects test commands from package.json, Makefile, Taskfile, justfile, or README |
| `/verify-task` | `.claude/skills/verify-task/SKILL.md` | Verifies a single task's acceptance criteria with TDD compliance checking |
| `/code-verification` | `.claude/skills/code-verification/SKILL.md` | Multi-agent verification: spawns an independent sub-agent to verify work against requirements |
| `/auto-verify` | `.claude/skills/auto-verify/SKILL.md` | Pattern-matches acceptance criteria text and auto-generates curl/bash/browser checks before falling back to manual |
| Verification docs | `docs/verification.md` (425 lines) | Defines TDD enforcement rules, test quality standards (AAA pattern, naming conventions, mock hygiene, edge case coverage) |

**Testing ladder strategy:** The toolkit enforces a layered verification model in target projects:
1. **Automated** — unit tests, typecheck, lint, build, mutation tests
2. **Optional** — browser verification (Playwright MCP), code simplification, tech debt scan
3. **Manual** — only when auto-verify cannot find an automation pattern

**Notably absent:** No tests *for the toolkit's own skills*. The markdown linter is the only self-check.

---

## 2. Git Hooks / Pre-Commit Checks

The toolkit has a custom hook system — no husky or pre-commit framework, just bash scripts.

| Hook | Location | What it does |
|------|----------|--------------|
| Post-commit dispatcher | `.git/hooks/post-commit` | Calls both hooks below after every commit |
| Toolkit sync check | `.claude/hooks/post-commit-sync-check.sh` | Detects if `.claude/skills/` files changed; writes `.claude/sync-pending.json` marker; prints a visual box prompting the agent to sync target projects |
| Doc update trigger | `.claude/hooks/post-commit-doc-update.sh` | Creates `.claude/doc-update-pending.json` for non-docs commits; agent auto-runs `/update-docs` to sync README, AGENTS.md, CHANGELOG. Skips on `docs:` prefixed or `[skip-docs]` commits |
| Pre-push doc check | `.claude/hooks/pre-push-doc-check.sh` | Warns if skills/commands changed but docs weren't updated. **Implemented but not currently installed.** |
| Session logger | `.claude/hooks/session-end-logger.sh` | Claude Code SessionEnd hook (not git). Logs session metadata to `.claude/logs/sessions.jsonl`; triggers analysis every 5 sessions |
| `/install-hooks` | `.claude/skills/install-hooks/` | Interactive skill to install any/all hooks in a project |

**The pattern:** Hooks never block commits (always `exit 0`). They create JSON marker files that the AI agent detects and acts on — a "nudge, don't gate" philosophy.

---

## 3. CI/CD Pipeline

**Notably absent.** No GitHub Actions, CircleCI, GitLab CI, Travis, Jenkinsfile, Docker, Vercel, or Netlify config. Zero cloud CI.

**What exists instead:** Local-only, orchestrator-agnostic quality gates via `.workstream/`:

| Script | Location | What it does |
|--------|----------|--------------|
| `verify.sh` | `.workstream/verify.sh` | The CI replacement — runs typecheck → lint → test → build locally, fail-fast |
| `setup.sh` | `.workstream/setup.sh` | Initializes worktrees: copies env files, symlinks settings, installs deps |
| `dev.sh` | `.workstream/dev.sh` | Starts dev server with deterministic port allocation (hash-based, range 10000–14999) |
| `lib.sh` | `.workstream/lib.sh` | Shared utilities: JSON parsing, config resolution, package manager detection, port allocation |

**Design rationale:** These scripts are orchestrator-agnostic — they work identically under Codex App, Claude Code, Conductor, or manual invocation. The "CI" runs locally before the agent commits, not in a remote pipeline.

---

## 4. Linting & Static Analysis

| Tool | Config Location | What it enforces |
|------|----------------|-----------------|
| markdownlint-cli v0.47 | `.markdownlint.json` + `package.json` | Markdown consistency across all `.md` files (excluding `node_modules/` and `deprecated/`) |

**Key rules:** Dashes for unordered lists, fenced code blocks only, 300-char line length (relaxed for docs), limited inline HTML (`<details>`, `<summary>`, `<br>`, `<sup>`, `<sub>` only), alt text required on images, no bare URLs.

**Scripts:** `npm run lint` (check) and `npm run lint:fix` (auto-fix).

**What's absent:** No ESLint, Prettier, TypeScript, stylelint, or any code-level static analysis. Appropriate for a markdown-only repo.

---

## 5. Agent Instruction Files

This is the most developed layer of the harness — the repo is essentially *agent instructions as infrastructure*.

| File | Location | What it tells agents |
|------|----------|---------------------|
| `CLAUDE.md` | Root | Delegates to `@AGENTS.md` (one line) |
| `AGENTS.md` | Root | **Primary rulebook.** Conservative edits, don't break existing commands, docs are code, don't speculate — ask. No history rewriting. Run `npm run lint`. Post-commit sync/doc-update protocols. |
| `.claude/settings.json` | `.claude/` | **Tool permissions whitelist.** Restricts which tools and bash commands the agent may use |
| `.claude/settings.local.example.json` | `.claude/` | Extended permissions template: web access, MCP tools, Codex integration config |
| `CONTRIBUTING.md` | Root | Human + agent contribution guidelines: small focused changes, preserve compatibility, treat prompts as code |
| `VISION.md` | Root | Strategic alignment doc: AI strengths/weaknesses taxonomy, scope boundaries, success criteria |
| `PROJECT_GOALS.md` | Root | 7 goals, 4 non-goals, 5 constraints, evaluation criteria — prevents scope creep |

**Key "don't" rules from AGENTS.md:**
- Don't rewrite history, don't force push
- Don't add new tooling/formatters unless asked
- Don't make broad formatting changes
- Don't encode assumptions — ask the user
- Don't break existing command names

---

## 6. Spec / Task Templates

The toolkit implements a full **Specify → Plan → Execute** pipeline with structured documents at each stage:

### Project-level flow (greenfield):
```
/product-spec   → PRODUCT_SPEC.md (requirements with REQ-XXX IDs)
/technical-spec → TECHNICAL_SPEC.md (architecture, stack, data models)
/generate-plan  → EXECUTION_PLAN.md (phases/steps/tasks) + AGENTS.md
```

### Feature-level flow (existing projects):
```
/feature-spec          → features/{name}/FEATURE_SPEC.md
/feature-technical-spec → features/{name}/FEATURE_TECHNICAL_SPEC.md
/feature-plan          → features/{name}/EXECUTION_PLAN.md + AGENTS_ADDITIONS.md
```

**Template locations:**
- `PRODUCT_SPEC_PROMPT.md` and `TECHNICAL_SPEC_PROMPT.md` (root)
- `.claude/skills/feature-spec/PROMPT.md`
- `.claude/skills/feature-technical-spec/PROMPT.md`
- `.claude/skills/feature-plan/PROMPT.md`

**EXECUTION_PLAN.md task format** enforces:
- Verification type tags on every acceptance criterion: `(TEST)`, `(CODE)`, `(BROWSER:DOM)`, `(MANUAL)`, etc.
- `Verify:` lines with concrete commands
- `Reason:` lines required for any `(MANUAL)` criterion
- Files to create, files to modify, existing code to reference, dependencies, spec references

**Supporting skills:**
- `/criteria-audit` — validates EXECUTION_PLAN.md for missing verification metadata, vague language, untestable criteria
- `/spec-verification` — checks that generated specs preserve upstream context and don't introduce quality issues
- **Deferred requirements capture** — during Q&A, anything marked "v2" / "future" / "out of scope" is automatically offered for `DEFERRED.md`

---

## 7. Architecture Enforcement

### Directory Guards
16+ skills implement fail-fast guards — they check for required files (like `EXECUTION_PLAN.md` or `AGENTS.md`) and refuse to run in the wrong directory. Prevents agents from accidentally operating on the toolkit when they should be in a target project, or vice versa.

### Skill Resolution System
Three-tier discovery with shadowing:
1. **Managed** (`/Library/Application Support/ClaudeCode/.claude/skills`)
2. **User** (`~/.claude/skills/` — symlinks to toolkit)
3. **Project** (`.claude/skills/` — shadows higher tiers)

Configured via `toolkit-version.json` with modes: `global`, `local`, or `mixed`. The `toolkit-only: true` frontmatter flag prevents internal skills from syncing to target projects.

### Configuration Priority Chains
Every configurable command (dev server, test runner, linter) resolves through a 4-tier fallback:
1. `workstream.json` (project-owned, never overwritten)
2. `.claude/verification-config.json` (Claude Code config)
3. `package.json` scripts (auto-detected)
4. Sensible defaults

### Context Detection
Skills auto-detect whether they're running in a greenfield project or a feature subdirectory (`*/features/*`) and adjust paths and behavior accordingly.

### Naming Conventions
- Skills: `.claude/skills/{name}/SKILL.md` with valid YAML frontmatter (`name`, `description`, `argument-hint`, `allowed-tools`)
- Supporting files: `PROMPT.md`, `VERIFICATION.md`, `PATTERNS.md`, `CODEX_MODE.md`, etc.
- Commits: one branch per phase, one commit per task
- Requirements: `REQ-XXX` IDs for traceability from spec → plan → task → commit

---

## 8. Everything Else (Quality & Constraint Infrastructure)

### Cross-Model Verification
| Skill | What it does |
|-------|--------------|
| `/codex-review` | Sends code diffs to OpenAI Codex CLI for a second-opinion review. Auto-invoked by `/phase-checkpoint` and `/create-pr`. |
| `/codex-consult` | Sends documents/specs to Codex for cross-model consultation. Used by generation commands. |

Codex researches current docs before reviewing, catching issues where model training data diverges. Findings are advisory — they don't block workflows.

### Phase Checkpoint System
`/phase-checkpoint` runs a multi-layer verification after each phase:
1. Local: tests, typecheck, lint, build, mutation tests, dev server, security scan
2. Cross-model: Codex review (if available)
3. Browser: automated browser checks (if MCP tools available)
4. Manual: auto-verify attempts automation first, falls back to human
5. Auto-advance: proceeds to next phase if all gates pass

### Audit Skills
| Skill | Location | What it catches |
|-------|----------|-----------------|
| `/audit-skills` | `.claude/skills/audit-skills/` | Best practice violations in skill files: length, checklists, verification steps, progressive disclosure. Scores by severity. |
| `/data-flow-audit` | `.claude/skills/data-flow-audit/` | Split data source anti-patterns: scattered business rules, formula divergence, duplicated predicates across 3+ files. Catches semantic duplication that tools like jscpd miss. |
| `/tech-debt-check` | `.claude/skills/tech-debt-check/` | Detects duplication, complexity, and maintainability issues at phase checkpoints |
| `/security-scan` | `.claude/skills/security-scan/` | Dependency vulnerabilities, hardcoded secrets, insecure code patterns |
| `/vision-audit` | `.claude/skills/vision-audit/` | Checks project alignment against VISION.md and identifies SDLC gaps |

### Workflow Checklists
Nearly every major skill embeds a copyable markdown checklist (e.g., `/verify-task` has 8 steps, `/phase-checkpoint` has 8 steps, `/audit-skills` has 5 steps). These prevent agents from skipping steps during long operations or after context loss.

### Knowledge Capture
| File | Purpose |
|------|---------|
| `LEARNINGS.md` | Accumulated patterns and gotchas (via `/capture-learning`) |
| `TODOS.md` | Follow-up items discovered during work (via `/add-todo`, `/list-todos`) |
| `DEFERRED.md` | Requirements explicitly deferred from specs |
| `SDLC_REFERENCE.md` | Catalog of SDLC outcomes used by `/vision-audit` for gap analysis |
| `.claude/logs/sessions.jsonl` | Session telemetry for `/analyze-sessions` to find automation opportunities |

### PR Merge Safety
`/merge-prs` implements risk scoring (0–100) based on diff size, file count, hotspot overlap, test coverage, and staleness. PRs are classified into tiers (always/maybe/iffy/never). Security pre-flight scans for leaked secrets (BLOCK) and CVEs (WARN) before any merge.

### Sync Infrastructure
| Component | What it does |
|-----------|--------------|
| `/update-target-projects` | Discovers all projects using the toolkit and syncs skills, workstream scripts, settings |
| `/setup` | Initializes a new project with the toolkit, respecting global vs. local skill resolution |
| `toolkit-version.json` | Tracks file hashes for conflict detection during sync — distinguishes clean updates from local modifications |

---

## Summary: What's Present vs. What's Absent

| Layer | Present? | Notes |
|-------|----------|-------|
| Unit/integration/e2e tests | **No** (for toolkit) / **Yes** (enforced in targets) | TDD enforcement with test-first validation via git history |
| Git hooks | **Yes** | Post-commit sync + doc-update nudges; never blocking |
| CI/CD pipeline | **No** | Local-only `verify.sh` replaces cloud CI |
| Linting | **Yes** | markdownlint only (appropriate for the repo) |
| Agent instructions | **Yes, heavily** | AGENTS.md + CLAUDE.md + settings.json + VISION.md + 35+ skills with embedded rules |
| Spec/task templates | **Yes, heavily** | Full Specify → Plan → Execute pipeline with requirement traceability |
| Architecture enforcement | **Yes** | Directory guards, skill resolution tiers, config priority chains, naming conventions |
| Cross-model verification | **Yes** | Codex CLI integration for second-opinion reviews on code and docs |
| Security scanning | **Yes** | Integrated into phase checkpoints and PR merges |
| Audit tooling | **Yes** | Skill quality, data flow, tech debt, vision alignment audits |

**The overall pattern:** This harness trusts the AI to write code but constrains *how* it works — through structured specifications, layered verification, cross-model review, and agent instructions that function as programmatic guardrails. The quality infrastructure is the product.
