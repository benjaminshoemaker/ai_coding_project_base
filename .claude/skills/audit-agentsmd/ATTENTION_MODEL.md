# LLM Attention Model for Long Instruction Files

## The "Lost in the Middle" Effect

LLMs process long contexts with uneven attention. Research and practical observation show three distinct attention zones:

1. **Primacy zone** (~first 20%): Strong attention. Instructions here are reliably followed.
2. **Dead zone** (~middle 30-60%): Weakest attention. Instructions here are frequently missed.
3. **Recency zone** (~last 20%): Strong attention. Instructions here benefit from proximity to the conversation.

## Zone Calculation

For a file of N lines:

```
Primacy:   line 1        → line N×0.20
Fade:      line N×0.20   → line N×0.35
Dead zone: line N×0.35   → line N×0.65
Recovery:  line N×0.65   → line N×0.80
Recency:   line N×0.80   → line N
```

### Example: 500-line file

| Zone | Lines | Attention |
|------|-------|-----------|
| Primacy | 1–100 | Strong |
| Fade | 100–175 | Moderate → Low |
| Dead zone | 175–325 | **Weakest** |
| Recovery | 325–400 | Low → Moderate |
| Recency | 400–500 | Strong |

## Context Position Matters Too

AGENTS.md is not the only content in an agent's context. The full system prompt structure for Claude Code is:

```
1. Claude Code system prompt (thousands of tokens)     ← true primacy
2. @AGENTS.md content (inlined)                        ← shifted toward middle
3. Auto memory (MEMORY.md, ~200 lines)                 ← after AGENTS.md
4. Conversation history                                ← true recency
```

This means:
- The START of AGENTS.md benefits from primacy spillover but isn't in the absolute primacy zone
- The END of AGENTS.md is NOT in the true recency zone — conversation history is
- The middle of AGENTS.md is genuinely deep in the overall context

For other agents (Codex, Cursor, etc.) that read AGENTS.md directly, the file's own primacy/recency zones are more dominant since there's less surrounding context.

## What Should Go Where

### Primacy Zone (first 20%): Behavioral Rules

Content that agents must ALWAYS follow regardless of task:
- Session-start workflows (e.g., "Read spec.md first")
- Non-negotiable guardrails (e.g., "NEVER ignore test output")
- Core task execution rules
- Testing policy

### Early-Middle (20-35%): Core Patterns

Content that applies to most tasks:
- Architecture overview
- API patterns and conventions
- UI component conventions
- Analytics requirements

### Middle/Dead Zone (35-65%): Reference Material

Content agents look up only when needed:
- Brand guidelines, color palettes
- Environment variables
- Deployment details
- AI feature architecture details

### Late/Recovery Zone (65-80%): Process Workflows

Content that applies at specific workflow stages:
- Commit message format
- Git branch strategy
- When to ask for human input
- Follow-up item tracking

### Recency Zone (last 20%): Reinforcement

Content that reinforces the most critical rules:
- Task completion checklist
- Reference document index
- **Reminders section** — 5-6 one-line repetitions of the most important behavioral rules

## The Reminders Pattern

A "## Reminders (Critical)" section at EOF is the single highest-impact structural improvement for any AGENTS.md over 300 lines. It exploits recency bias to reinforce primacy-zone rules:

```markdown
## Reminders (Critical)

- **Tapestry**: Read `.tapestry/spec.md` at session start; log decisions during work
- **Testing**: NEVER ignore test output, NEVER disable functionality to hide failures
- **API**: Always use `withAuth` from `apiHelpers.ts` — never raw Supabase SSR
- **Design tokens**: Use `text-ink`, `bg-brand` — never hardcode hex values
- **PostHog**: All new features MUST include analytics tracking
```

This creates "bookending" — the same rules appear at the top (primacy) and bottom (recency) of the file, covering both attention peaks.

## `@` Import vs "See X.md" — Behavioral Difference

Two mechanisms exist for referencing external files, with very different reliability:

### `@file.md` imports (in CLAUDE.md only)
- **Behavior**: File contents are automatically inlined into system prompt at session start
- **Reliability**: Same as inline content — always loaded
- **Use for**: The main AGENTS.md file itself

### "See docs/X.md for details" links
- **Behavior**: Claude must actively choose to read the file using its Read tool
- **Reliability**: On-demand — Claude reads them when it encounters a relevant task
- **Risk**: If Claude doesn't perceive the file as relevant, it won't read it
- **Use for**: Reference material (schema, syntax, process templates)
- **Critical rule**: NEVER extract behavioral rules to linked files — they become invisible

### Anthropic's guidance (from skill best practices)
> "When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them."

Keep references ONE level deep. Claude may partially read nested references.
