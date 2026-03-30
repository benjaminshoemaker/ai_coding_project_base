---
name: discover
description: Exploratory conversation before /product-spec. Asks one question at a time, runs background research for open-source/off-the-shelf alternatives, and writes DISCOVERY_NOTES.md. Use when the user has an idea but hasn't scoped it yet.
argument-hint: "[idea description] [--lean]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Agent, WebSearch, WebFetch, Bash, Grep, Glob
---

Explore a project idea through conversation and produce discovery notes for `/product-spec`.

## Workflow

```
Discovery Progress:
- [ ] Phase 1: Listen & orient
- [ ] Phase 2: Explore (conversational Q&A)
- [ ] Phase 3: Background research (non-blocking)
- [ ] Phase 4: Synthesis — write DISCOVERY_NOTES.md
- [ ] Phase 5: Handoff to /product-spec
```

## Lean Mode (`--lean`)

When `--lean` is passed:
- Tighter research scope — search for fewer terms, only surface findings that would change the direction entirely (e.g., a mature open-source tool that solves the exact problem).
- Skip the "Open Questions" review with the user — just write them into the notes.

## Phase 1: Listen & Orient

1. Read the user's initial description (the argument or first message).
2. If the project directory has existing code, quickly orient:
   - `git log --oneline -10` (if git repo)
   - Read `CLAUDE.md` or `README.md` if they exist
   - Quick `ls` of top-level structure
3. Assess what's already clear from the initial description vs. what's ambiguous. Mentally categorize each of these as "known" or "needs exploration":
   - Problem / motivation
   - Audience / users
   - Platform (web, mobile, CLI, etc.)
   - Core experience
   - Tech stack preferences
   - Scope / what "done" looks like

Do NOT output a long preamble. Acknowledge the idea in 1-2 sentences, then go straight to your first question.

## Phase 2: Explore

Ask questions **one at a time** via AskUserQuestion. Follow threads — if the user's answer raises something interesting, dig into that before moving to the next topic.

**Smart-skip:** Only ask about areas marked "needs exploration" from Phase 1. If the user's initial description already answers a question clearly, skip it.

### Question Areas (ask in whatever order fits the conversation)

1. **What's the real problem?** Not "what do you want to build" — what's the pain, desire, or motivation? Why now?
2. **Who's it for?** Just you? A team? Public users? A demo/interview? This shapes every decision.
3. **What does "done" look like?** What would you show someone to prove this works? What's the minimum that would make you happy?
4. **What exists already?** Have you seen anything similar? Anything you like or dislike about existing tools?
5. **Tech inclinations?** Any stack preferences, constraints, or things you want to learn? Deployment target?
6. **What's the most exciting part?** Where should we spend the most energy? What makes this interesting to you?

### Recommendations

When you have a genuine, informed recommendation for a question, include it with a brief explanation of why. Don't force recommendations where you don't have a real basis for one — many discovery questions are purely about understanding the user's intent, not making a choice.

Good recommendation: "I'd lean web here — dashboards are naturally browser-based, and you avoid app store friction." (There's a real rationale based on the problem domain.)

Bad recommendation: "My instinct is this is a personal tool." (You're just guessing about the user's intent — ask instead.)

### Conversation Rules

- **One question at a time.** Do not batch. Wait for the answer.
- **Follow threads.** If the answer to Q1 raises something interesting about scope, explore that before asking Q3.
- **Be a collaborator, not an interrogator.** Riff on ideas. Get excited about what's exciting. Suggest possibilities the user might not have considered.
- **Don't auto-decide.** This is the phase where the user is thinking out loud. Every question is worth asking (if not already answered). Your recommendations are suggestions, not decisions.
- **Don't give implementation opinions yet.** This is about the problem space and scope, not architecture. Tech stack preferences are fine to surface, but don't recommend specific libraries or patterns.

### Escape Hatch

If the user says "just build it," "let's go," "enough questions," or expresses impatience:
- Ask one final clarifying question — the single most important unanswered question.
- If they push back again, stop immediately and proceed to Phase 4.

### When to Move On

Move to Phase 4 when you have enough clarity to write a useful summary. You don't need every question answered — "Open Questions" exist for a reason. Typically 3-6 questions is enough.

## Phase 3: Background Research (Non-Blocking)

**Launch as soon as the idea is clear enough** — typically after the user answers the first 1-2 questions. Do not wait until Phase 2 is complete.

Launch a **single background Agent** (`run_in_background: true`) with this mission:

> Search for open-source projects, off-the-shelf products, and existing tools related to: {1-2 sentence description of what the user wants to build}.
>
> Categorize every finding into exactly one of these three buckets:
>
> **Use Directly** — Could replace building this entirely. Solves the core problem as-is or with minimal configuration.
>
> **Leverage** — Libraries, frameworks, APIs, or components that handle significant parts of the work. The user would still build their own product but stand on these.
>
> **Take Inspiration From** — Projects with good architecture, UX patterns, or approaches worth studying. Not directly usable but instructive.
>
> For each finding, include:
> - Name and URL (GitHub link or product page)
> - 1-2 sentence description of what it does
> - Why it's relevant to this specific project
> - Which bucket it belongs to and why
>
> Search for:
> - GitHub repos: "{problem domain} open source", "{key feature} library {likely language}"
> - Products: "{problem domain} tool", "{problem domain} SaaS"
> - Package registries: relevant npm/PyPI/crates packages if tech stack is known
>
> Return 3-8 findings total, prioritizing quality over quantity. If you find something in the "Use Directly" bucket, make sure to note it prominently.

**CRITICAL: Do not interrupt the Phase 2 conversation when results arrive.** Research findings are only used in Phase 4 when writing DISCOVERY_NOTES.md.

## Phase 4: Synthesis

Write `DISCOVERY_NOTES.md` to the project root (or `plans/greenfield/DISCOVERY_NOTES.md` if `plans/greenfield/` already exists).

Wait for the background research agent to complete before writing. If it hasn't finished, wait briefly — this is the one place where research blocks.

### Document Structure

```markdown
# Discovery Notes

Generated: {date}
Source: /discover conversation

## Idea Summary
{1-2 paragraph synthesis of what the user wants to build and why. Capture the energy and intent, not just the facts.}

## Key Decisions
- **Problem:** {what we're solving, in the user's words}
- **Audience:** {who it's for}
- **Platform:** {web/mobile/CLI/desktop/etc., or "TBD" if not discussed}
- **Stack preferences:** {any that emerged, or "none expressed"}
- **MVP scope:** {what "done" looks like — the minimum that would make the user happy}
- **Exciting part:** {where the user wants to focus energy}

## Open Questions
{Bulleted list of things we didn't resolve. These become questions for /product-spec.}

## Existing Solutions & Tools

### Use Directly
{Tools/products that could replace building this. If none found, say "None found that solve the full problem."}

### Leverage
{Libraries, frameworks, APIs worth building on top of.}

### Take Inspiration From
{Projects with good patterns, architecture, or UX to study.}

## Raw Context
{2-5 notable quotes or details from the conversation that capture nuance /product-spec should know. Things that wouldn't fit in the structured sections above.}
```

**If research returned no findings:** Include the Existing Solutions section with "No relevant open-source or off-the-shelf solutions found." under each bucket.

**If research found a strong "Use Directly" candidate:** Note it clearly but don't editorialize. The user will see it and decide.

## Phase 5: Handoff

After writing the file:

```
DISCOVERY_NOTES.md written to {path}

Next: /product-spec [--lean]
```

That's it. No lengthy summary — the user can read the file.

## Error Handling

| Situation | Action |
|-----------|--------|
| Background research agent fails or times out | Write DISCOVERY_NOTES.md without the research section. Add a note: "Background research did not complete. Run WebSearch manually or proceed without." |
| User provides a fully formed description with no ambiguity | Skip Phase 2 entirely. Run research, write notes, hand off. |
| User wants to explore multiple ideas | Pick the one they seem most excited about, note the others in "Raw Context" as alternatives worth revisiting. |
| Project already has DISCOVERY_NOTES.md | Ask: overwrite, backup then overwrite, or abort. |
