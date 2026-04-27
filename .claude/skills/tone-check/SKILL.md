---
name: tone-check
description: Check a document for AI-generated writing markers and mismatches with the user's personal tone. Two-pass analysis — generic AI detection plus voice/style comparison against the user's own writing samples from past sessions.
argument-hint: "<file-path> [--strict] [--samples <N>]"
allowed-tools: Read, Bash, Glob, Grep
---

Analyze a document for signs of AI-generated writing and tone mismatches with the user's personal voice.

@shared/SESSION_PARSING.md

## Arguments

- **file-path** (required) — path to the document to check
- `--strict` — flag even mild AI markers (default: only flag moderate/strong signals)
- `--samples <N>` — number of user writing samples to collect for tone comparison (default: 20)

## Workflow

### 1. Read the Target Document

Read the file at the given path. If it doesn't exist, report the error and stop.

Note the document type (markdown, plain text, email draft, etc.) as this affects what markers are relevant.

### 2. AI Marker Analysis

Scan the document for these categories of AI writing markers. For each instance found, note the exact text and location.

**A. Filler & Hedge Phrases**
- "It's important to note that", "It's worth mentioning", "It should be noted"
- "In order to" (instead of "to")
- "At the end of the day", "Moving forward", "Going forward"
- "Leverage", "Utilize" (instead of "use")
- "Facilitate", "Streamline", "Optimize"
- "Comprehensive", "Robust", "Holistic", "Synergy"
- "Navigate" (used metaphorically), "Landscape"

**B. Structural Patterns**
- Numbered lists where prose would be more natural
- Every paragraph starting with a bold keyword
- Bullet points that each begin with a gerund ("-ing")
- Formulaic topic sentence → supporting points → summary sentence per section
- Excessive use of colons to introduce lists
- "Let's dive in", "Let's break this down", "Here's the thing"

**C. Hedging & Over-qualification**
- "While X, it's also true that Y" (unnecessary balance)
- "This is a nuanced topic" / "There are many factors to consider"
- Triple-stacked adjectives ("a comprehensive, robust, and scalable solution")
- Excessive "however" / "that said" / "on the other hand" transitions

**D. Summarization Tells**
- "In summary", "To summarize", "In conclusion", "Overall"
- Restating the question before answering
- Ending with a forward-looking statement that adds no information

**E. Emotional Flatness / Corporate Tone**
- Absence of contractions in otherwise informal text
- "I" statements that feel performative rather than personal
- Lack of specificity — vague claims without concrete examples
- "Excited to", "Thrilled to", "Passionate about" (hollow enthusiasm)

### 3. Collect User Writing Samples

To compare tone, collect samples of the user's actual writing from past sessions.

Find recent Claude Code sessions:
```bash
find ~/.claude/projects -name "*.jsonl" -not -path "*/subagents/*" -mtime -30 -type f | head -30
```

For each file, extract user messages that are likely **authored text** (not commands, not pasted content):
- Must be 50+ characters
- Must NOT start with `<` (system tags)
- Must NOT look like a pasted transcript, code block, or URL dump
- Must NOT be a slash command invocation
- Prefer messages that are conversational, opinionated, or explanatory — these reveal voice

Collect up to N samples (default 20). Also check Codex sessions:
```bash
find ~/.codex/sessions -name "*.jsonl" -mtime -30 -type f | head -10
```

For Codex, extract user messages from `response_item` payloads with `role: "user"`, same filtering rules.

### 4. Characterize the User's Voice

From the collected samples, identify:

- **Sentence structure**: short/punchy vs. long/complex? Fragments OK?
- **Formality level**: contractions? slang? technical jargon?
- **Directness**: does the user hedge or state things plainly?
- **Vocabulary patterns**: words/phrases the user favors
- **Emotional register**: dry, enthusiastic, sardonic, matter-of-fact?
- **Punctuation habits**: em-dashes, ellipses, exclamation marks?

### 5. Tone Comparison

Compare the target document against the user's voice profile. Flag passages where:

- The document is significantly more formal than the user's natural voice
- The document uses vocabulary the user never uses
- The document hedges where the user would be direct (or vice versa)
- The document has a different emotional register than the user's samples
- The sentence structure differs markedly (e.g., all long compound sentences when the user writes short ones)

### 6. Report

```
# Tone Check: FILENAME

## AI Marker Summary

**Overall AI signal:** Low / Medium / High
**Markers found:** N instances across M categories

### Flagged Passages

1. **[LINE/SECTION]** "QUOTED TEXT"
   → CATEGORY: EXPLANATION
   → Suggested rewrite: ALTERNATIVE

2. ...

## Voice Comparison

**Your typical voice:** [2-3 sentence characterization based on samples]

### Tone Mismatches

1. **[LINE/SECTION]** "QUOTED TEXT"
   → This reads as [MORE FORMAL / HEDGING / GENERIC] compared to your voice
   → In your style, this might be: ALTERNATIVE

## Score

- AI markers: X/10 (0 = fully human, 10 = obvious AI)
- Voice match: X/10 (0 = sounds nothing like you, 10 = indistinguishable)
```

Keep the report actionable — every flag should have a concrete suggestion. Don't flag things that are fine for the document type (e.g., formal structure in a PRD is appropriate).
