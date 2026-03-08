# SDLC Outcomes Reference

Modern software development lifecycle **outcomes** for comparison during vision audits.

This document catalogs what successful software development achieves, organized
by phase. Practices and tools listed are *examples* of how these outcomes are
currently achieved, not prescriptions. As technology evolves (AI-assisted
coding, preview deployments, etc.), the practices may change while the outcomes
remain stable.

**Sources:** [DORA Research](https://dora.dev/), [Atlassian SDLC Guide](https://www.atlassian.com/agile/software-development/sdlc), [Jobs to Be Done Framework](https://www.productplan.com/glossary/jobs-to-be-done-framework/)

---

## How to Read This Document

Each phase contains **outcomes** (what we want to achieve) and **example practices** (how we might achieve them today).

```
OUTCOME: What success looks like (stable)
  Why it matters: The underlying motivation
  Example practices: Current ways to achieve this (can evolve)
  Example tools: Specific implementations (examples, not mandates)
```

The `/vision-audit` skill compares the toolkit against these **outcomes**, not specific practices.

---

## Phase 1: Plan

### Outcome 1.1: Requirements Are Captured and Structured

**Why it matters:** Without clear requirements, AI and humans alike build the wrong thing.

**Example practices:**
- Product specification documents
- User stories with acceptance criteria
- Technical design documents with architecture decisions

**Example tools (current):** Notion, Linear, Markdown specs, JIRA

---

### Outcome 1.2: Work Is Scoped and Bounded

**Why it matters:** Unbounded work leads to scope creep and never-ending projects.

**Example practices:**
- Definition of done per task
- Dependency identification
- Phase/milestone boundaries

**Example tools (current):** Project boards, execution plans with task IDs

---

### Outcome 1.3: Security Risks Are Considered Early

**Why it matters:** Security bolted on later is expensive and often inadequate.

**Example practices:**
- Threat modeling during design
- Security requirements in specs
- Trust boundary identification

**Example tools (current):** STRIDE analysis, threat matrices, security questionnaires

---

## Phase 2: Code

### Outcome 2.1: Code Changes Are Tracked and Reversible

**Why it matters:** Without history, you can't understand what changed or roll back mistakes.

**Example practices:**
- Version control for all code
- Meaningful commit messages
- Branching strategies

**Example tools (current):** Git, GitHub, GitLab

---

### Outcome 2.2: Code Quality Is Consistent

**Why it matters:** Inconsistent style creates cognitive load and hides bugs.

**Example practices:**
- Automated linting and formatting
- Code review before merge
- Coding standards documentation

**Example tools (current):** ESLint, Prettier, Ruff, PR reviews

---

### Outcome 2.3: Secrets Are Protected

**Why it matters:** Leaked credentials cause breaches.

**Example practices:**
- No hardcoded secrets in code
- Environment-based configuration
- Secret scanning in CI

**Example tools (current):** Vault, 1Password, .env files, git-secrets

---

## Phase 3: Build

### Outcome 3.1: Builds Are Automated and Reproducible

**Why it matters:** Manual builds are slow and error-prone.

**Example practices:**
- Continuous integration on every change
- Deterministic builds (same input → same output)
- Dependency locking

**Example tools (current):** GitHub Actions, CircleCI, npm/yarn lock files

---

### Outcome 3.2: Dependencies Are Known and Managed

**Why it matters:** Unknown dependencies are security and stability risks.

**Example practices:**
- Dependency manifests and lock files
- Vulnerability scanning
- License compliance tracking

**Example tools (current):** npm audit, Dependabot, Snyk, SBOM generation

---

## Phase 4: Test

### Outcome 4.1: Code Correctness Is Verified Before Commit

**Why it matters:** Bugs caught early are cheap; bugs in production are expensive.

**Example practices:**
- Test-driven development
- Unit, integration, and E2E tests
- Tests run before merge

**Example tools (current):** Jest, pytest, Playwright, CI test runners

*Note: "Before commit" is the outcome. Whether tests run locally, on preview deployments, or in CI is a tactical choice.*

---

### Outcome 4.2: Code Is Scanned for Security Vulnerabilities

**Why it matters:** Security flaws in code become breaches in production.

**Example practices:**
- Static analysis (SAST) during development
- Dynamic analysis (DAST) on running apps
- Dependency vulnerability scanning

**Example tools (current):** Semgrep, SonarQube, OWASP ZAP, Snyk

---

### Outcome 4.3: Test Quality Is Sufficient

**Why it matters:** Tests that don't catch bugs are false confidence.

**Example practices:**
- Coverage metrics (used thoughtfully, not as targets)
- Mutation testing to verify test effectiveness
- Test review as part of code review

**Example tools (current):** Coverage reporters, Stryker, code review checklists

---

## Phase 5: Release

### Outcome 5.1: Releases Are Identifiable and Documented

**Why it matters:** You need to know what's deployed and what changed.

**Example practices:**
- Semantic versioning
- Changelogs (automated or manual)
- Release tagging in version control

**Example tools (current):** GitHub Releases, conventional commits, CHANGELOG.md

---

### Outcome 5.2: Releases Can Be Controlled and Rolled Back

**Why it matters:** Bad releases need quick remediation.

**Example practices:**
- Feature flags for gradual rollout
- Blue-green or canary deployments
- One-click rollback capability

**Example tools (current):** LaunchDarkly, Vercel, Kubernetes rollouts

---

## Phase 6: Deploy

### Outcome 6.1: Deployments Are Automated and Consistent

**Why it matters:** Manual deployments cause errors and delays.

**Example practices:**
- Infrastructure as Code
- GitOps (git as source of truth)
- Environment parity (dev ≈ staging ≈ prod)

**Example tools (current):** Terraform, Pulumi, ArgoCD, Vercel

---

### Outcome 6.2: Deployments Are Safe and Recoverable

**Why it matters:** Deployment failures shouldn't cause extended outages.

**Example practices:**
- Zero-downtime deployment strategies
- Automated rollback on failure
- Database migration versioning

**Example tools (current):** Blue-green, canary, Prisma migrations, Flyway

---

## Phase 7: Operate

### Outcome 7.1: Operations Are Documented and Repeatable

**Why it matters:** Tribal knowledge doesn't scale and causes outages during handoffs.

**Example practices:**
- Runbooks for common operations
- Incident response procedures
- On-call rotation and escalation paths

**Example tools (current):** Runbook wikis, PagerDuty, incident.io

---

### Outcome 7.2: Systems Are Resilient and Recoverable

**Why it matters:** Failures happen; recovery capability determines impact.

**Example practices:**
- Backup and restore procedures
- Disaster recovery testing
- Chaos engineering

**Example tools (current):** Cloud backup services, DR drills, Chaos Monkey

---

## Phase 8: Monitor

### Outcome 8.1: System Health Is Observable

**Why it matters:** You can't fix what you can't see.

**Example practices:**
- Logging (structured, centralized)
- Metrics (application and infrastructure)
- Distributed tracing

**Example tools (current):** Datadog, Grafana, Loki, OpenTelemetry

---

### Outcome 8.2: Problems Are Detected and Alerted

**Why it matters:** Finding issues before users do reduces impact.

**Example practices:**
- Alerting with actionable thresholds
- Anomaly detection
- SLO/SLA monitoring

**Example tools (current):** PagerDuty, Prometheus Alertmanager, Datadog

---

### Outcome 8.3: Feedback Informs Improvement

**Why it matters:** Learning from production makes the next cycle better.

**Example practices:**
- Post-incident reviews (blameless)
- User feedback collection
- Analytics on feature usage

**Example tools (current):** Postmortems, user surveys, Amplitude, Mixpanel

---

## Cross-Cutting: Security

### Outcome S.1: Security Is Integrated Throughout

**Why it matters:** Security as an afterthought fails; security as a practice succeeds.

**Example practices:**
- Security gates in CI/CD pipelines
- Vulnerability triage and remediation
- Supply chain security (signed artifacts, provenance)

**Example tools (current):** Snyk, SLSA framework, artifact signing

---

## Cross-Cutting: Quality

### Outcome Q.1: Delivery Performance Is Understood

**Why it matters:** You can't improve what you don't measure.

**Example practices:**
- DORA metrics (deployment frequency, lead time, MTTR, change failure rate)
- Technical debt tracking
- Developer experience surveys

**Example tools (current):** DORA dashboards, LinearB, team retrospectives

---

### Outcome Q.2: Knowledge Is Captured and Shared

**Why it matters:** Context loss slows everything down.

**Example practices:**
- Documentation as code
- Architecture decision records
- Onboarding documentation

**Example tools (current):** READMEs, ADRs, Notion, Confluence

---

## Summary: Outcome Counts by Phase

| Phase | Outcomes |
|-------|----------|
| Plan | 3 |
| Code | 3 |
| Build | 2 |
| Test | 3 |
| Release | 2 |
| Deploy | 2 |
| Operate | 2 |
| Monitor | 3 |
| Security | 1 |
| Quality | 2 |
| **Total** | **23** |

---

## How This Document Is Used

The `/vision-audit` skill:

1. **Reads VISION.md** to understand scope and principles
2. **Compares each outcome** in this document against the toolkit
3. **Classifies** as:
   - **ACHIEVED** — Toolkit addresses this outcome
   - **INTENTIONALLY AVOIDED** — Out of scope per VISION.md
   - **OPPORTUNITY** — In scope, not yet addressed
4. **Ignores specific tools** — Focuses on whether the outcome is achieved, not how

Because this document focuses on outcomes rather than practices, it remains relevant even as technology changes.
