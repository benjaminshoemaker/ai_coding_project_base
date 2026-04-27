---
name: suggest-skills
description: Analyze past Claude Code and Codex sessions to suggest new skills, workflow improvements, or changes to existing skills. Identifies repetitive patterns and unmet automation opportunities.
argument-hint: "[--days <N>] [--project <name>]"
allowed-tools: Read, Bash, Glob, Grep, Agent
---

Analyze recent conversation history across Claude Code and Codex to identify opportunities for new skills, workflow improvements, or changes to existing skills.

@shared/SESSION_PARSING.md

## Arguments

- `--days <N>` — how far back to look (default: 14)
- `--project <name>` — focus on sessions from a specific project

## Workflow

### 1. Inventory Existing Skills

Read the skill directories to build a list of what already exists:

```bash
ls ~/.claude/skills/ | grep -v shared
```

For each skill, read just the frontmatter (first 6 lines) of `SKILL.md` to get the name and description.

### 2. Discover Recent Sessions

Find session files modified in the last N days:

```bash
find ~/.claude/projects -name "*.jsonl" -not -path "*/subagents/*" -mtime -${DAYS} -type f
find ~/.codex/sessions -name "*.jsonl" -mtime -${DAYS} -type f
```

If `--project` is set, filter to matching paths.

### 3. Sample Sessions

For efficiency, don't read every session end-to-end. Instead:

1. Sort files by modification time (newest first)
2. Take up to 20 sessions
3. For each session, extract only **user messages** (skip system messages, tool results, and assistant responses). These reveal what the user is asking for and doing repeatedly.

Use a Bash one-liner per file to extract user text:
```bash
python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    for line in f:
        try:
            obj = json.loads(line)
            if obj.get('type') == 'user':
                msg = obj.get('message', {})
                content = msg.get('content', '') if isinstance(msg, dict) else ''
                if isinstance(content, str) and len(content) > 20 and not content.startswith('<'):
                    print(content[:500])
            elif obj.get('type') == 'response_item':
                p = obj.get('payload', {})
                if p.get('role') == 'user':
                    for b in (p.get('content') or []):
                        t = b.get('text', '')
                        if len(t) > 20 and not t.startswith('<') and not t.startswith('#'):
                            print(t[:500])
        except: pass
" FILE
```

### 4. Analyze Patterns

With the sampled user messages, identify:

**A. Repetitive requests** — Things the user asks for repeatedly across sessions that could be automated into a skill. Look for:
- Similar phrasing across sessions
- Multi-step workflows the user orchestrates manually
- Recurring "can you..." / "I need to..." patterns

**B. Tool usage patterns** — If assistant messages show repeated tool call sequences (e.g., always running the same grep → read → edit pattern), that's a candidate for a skill.

**C. Pain points** — Moments where the user expresses frustration, restarts, or corrects the assistant. These suggest the current workflow is inadequate.

**D. Cross-session themes** — Topics or tasks that span multiple sessions, indicating ongoing work that would benefit from better tooling.

### 5. Cross-Reference with Existing Skills

For each identified pattern, check whether an existing skill already addresses it. If a skill exists but the user doesn't seem to use it, that's also worth noting (discoverability issue or skill gap).

### 6. Generate Recommendations

Present findings as a ranked list:

```
# Skill Suggestions

Based on analysis of N sessions over the last D days.

## New Skills

### 1. /SKILL-NAME — SHORT DESCRIPTION
**Pattern observed:** What the user does repeatedly
**Sessions:** List 2-3 session dates/projects where this appeared
**Effort:** Low / Medium / High
**Impact:** How much time/friction this would save

### 2. ...

## Improvements to Existing Skills

### 1. /EXISTING-SKILL — WHAT TO CHANGE
**Gap observed:** What the skill doesn't handle that the user needs
**Sessions:** Where this gap appeared

## Workflow Observations

- Any cross-cutting insights about how the user works that don't map to a single skill
```

Rank by impact (time saved × frequency). Limit to 5-7 recommendations total — quality over quantity.
