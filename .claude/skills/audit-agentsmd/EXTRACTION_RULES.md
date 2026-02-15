# Extraction Rules: What Can Leave AGENTS.md

## The Two Categories

Every section in AGENTS.md is either **behavioral** (must stay inline) or **reference** (safe to extract). Getting this wrong is the primary risk of the audit — extracting a behavioral rule makes it invisible.

## Classification Checklist

For each section, check these indicators:

### Behavioral Indicators (MUST stay inline)

A section is behavioral if ANY of these apply:

- [ ] Contains NEVER, MUST, ALWAYS, or "do not" directives
- [ ] Establishes a rule that applies to EVERY task (not just a specific task type)
- [ ] Defines session-start or session-end workflows
- [ ] Sets guardrails around destructive operations
- [ ] Specifies what format/pattern to always use (e.g., "always use withAuth")
- [ ] Contains testing or verification policy
- [ ] Defines when to stop and ask for help

### Reference Indicators (safe to extract)

A section is reference if ALL of these apply:

- [ ] Only needed when working on a specific task type (migrations, Trigger jobs, etc.)
- [ ] Primarily contains code examples, syntax templates, or schema definitions
- [ ] Removing it would not change how an agent approaches a typical task
- [ ] Agent can discover/retrieve this information on-demand when needed
- [ ] No NEVER/MUST/ALWAYS directives embedded in the content

## Common Section Classifications

### Almost Always Behavioral (keep inline)

| Section Type | Why |
|-------------|-----|
| Agent Instructions / Guardrails | Core rules for every task |
| Testing Policy | Non-negotiable verification rules |
| Session start/end workflows | Must be visible at session boundary |
| "When to ask for human input" | Safety guardrail |
| API pattern requirements | "Always use X, never use Y" |
| Design token rules | "Never hardcode hex" is a guardrail |
| PostHog requirements | "All features MUST include tracking" |
| Task completion checklist | Applies to every task |

### Almost Always Reference (safe to extract)

| Section Type | Why |
|-------------|-----|
| Database schema / table definitions | Lookup when working with DB |
| Migration workflow (step-by-step) | Only needed when creating migrations |
| Trigger.dev syntax / code examples | Only needed when writing jobs |
| Git branch lifecycle details | Process reference |
| Phase checkpoint step-by-step | Skills handle this; process detail |
| Verification workflow details | Skills handle this; process detail |
| File organization / directory tree | Agent discovers via Glob |
| Follow-up item templates | Template reference |
| Color palette (hex values) | Lookup when building UI |
| Environment variable lists | Setup reference |

### Mixed — Partially Extractable

Some sections contain a behavioral rule wrapped in reference detail. For these:

1. **Keep a 3-5 line stub** with the behavioral rule
2. **Extract the details** to a docs/ file
3. **Link with clear "when to read" language**

**Example — Database Migration section:**

Before (86 lines inline):
```markdown
## Database Migration Workflow
### Creating Migrations
1. Generate timestamp...
[80+ lines of process detail]
```

After (8 lines inline + link):
```markdown
## Database
See [docs/DATABASE_MIGRATIONS.md](docs/DATABASE_MIGRATIONS.md) for full workflow.

**Key rules** (always apply):
- NEVER modify existing migration files after they've been applied
- NEVER use `supabase db reset` — it wipes all data
- Local DB access: `docker exec -i supabase_db_KineticBI psql -U postgres -d postgres`
```

The NEVER rules stay inline (behavioral). The step-by-step process moves out (reference).

## Extraction Destinations

Extracted files should go to `docs/` with clear, descriptive names:

| Source Section | Destination |
|---------------|-------------|
| Database schema | `docs/DATABASE_SCHEMA.md` |
| Migration workflow | `docs/DATABASE_MIGRATIONS.md` |
| Trigger.dev syntax | `docs/TRIGGER_REFERENCE.md` |
| Git branch process | `docs/GIT_WORKFLOW.md` |
| Verification details | `docs/VERIFICATION_WORKFLOW.md` |
| Follow-up templates | `docs/TODO_WORKFLOW.md` |
| Phase checkpoint process | `docs/PHASE_CHECKPOINT.md` |

## Linking Best Practices

When replacing extracted content with a stub:

1. **State the link clearly**: "See [docs/X.md](docs/X.md) for full workflow"
2. **Add "when to read" context**: "Read when creating or applying migrations"
3. **Keep the behavioral rules inline**: Any NEVER/MUST/ALWAYS stays in AGENTS.md
4. **Keep links one level deep**: docs/X.md should NOT link to docs/Y.md
5. **Add extracted files to Reference Documents section**: So agents can find them

## Post-Extraction Validation

After extracting, verify:
- [ ] No behavioral rules were moved to docs/ files
- [ ] Every extracted file is linked from AGENTS.md with "when to read" context
- [ ] Extracted files are listed in the "Reference Documents" section
- [ ] AGENTS.md is under 500 lines
- [ ] The Reminders section at EOF still covers all critical rules
