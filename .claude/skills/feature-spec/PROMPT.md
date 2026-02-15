# Feature Specification Prompt

Use this prompt to develop a feature specification for an existing project.

## Required Inputs

Provide these alongside your feature idea:
- **AGENTS.md** — Your existing project's workflow guidelines
- **Project context** — One of the following:
  - Project tree output (`tree -L 3` or similar)
  - Key file listing with descriptions
  - README.md or project documentation

---

## The Prompt

```
Ask me questions so that we can develop a feature specification document for this idea.

The resulting document should answer at least (but not limited to) this set of questions:

**Core Feature Definition**
* What problem does the feature solve?
* Who benefits from this feature?
* Describe the core user experience, step-by-step.
* What data will the feature need to persist?

**Integration with Existing Project**
* How does this feature integrate with existing functionality?
* Which existing components will this feature modify or extend?
* Are there backwards compatibility concerns?
* Could this feature break existing user workflows?

**Scope Boundaries**
* What is explicitly OUT of scope for this feature?
* Are there related features that should be deferred to later?

Before you begin asking questions, plan your questions out to meet the following guidelines:
* Review the provided project context to understand existing patterns and architecture.
* If you can infer the answer from the feature idea or project context, no need to ask a question about it.
* Each set of questions builds on the questions before it.
* If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
* For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.

### Question Efficiency

Minimize user interruptions. Follow these rules strictly:

1. **Auto-decide strong recommendations.** If your recommendation strength is "strong" AND the question is about an implementation detail (not user-facing behavior), do NOT ask — just use your recommendation. State your assumption in the output so the user can correct if needed.

2. **Batch aggressively.** Use AskUserQuestion with up to 4 questions per call. Present all independent questions in a single batch rather than asking one at a time.

3. **Target 2-3 rounds maximum.** After reading all inputs, identify every ambiguity at once. Categorize as "must ask user" vs "can auto-decide." Only present "must ask" items, batched into 2-3 AskUserQuestion calls.

4. **Only ask about user-facing decisions.** Questions about scope, UX behavior, and user-visible functionality require user input. Questions about internal implementation, data formats, or technical approach can be auto-decided.

We are building an MVP of this feature - bias your choices towards simplicity, ease of implementation, and speed. When off-the-shelf or open source solutions exist, consider suggesting them as options.

## Making Feature Choices

When facing significant feature decisions (scope, UX approach, integration strategy), help the user make informed choices:

### Web Research (When Relevant)
For features that have established patterns in the industry, use WebSearch to gather current information:
- How do similar products implement this feature?
- What are common UX patterns for this feature type?
- Are there accessibility or usability standards to consider?
- What are known anti-patterns to avoid?

Cite your sources when presenting recommendations.

### Decision Matrix (Required When Multiple Approaches Exist)
When presenting choices between 2+ viable feature approaches, generate a comparison matrix:

```
| Criterion               | Approach A    | Approach B    | Approach C    |
|-------------------------|---------------|---------------|---------------|
| User value delivered    | ✓ High        | ○ Medium      | ○ Medium      |
| Integration complexity  | Low           | Medium        | High          |
| Risk to existing flows  | Low           | Medium        | High          |
| Consistency with UX     | ✓ Matches     | ○ Extends     | ✗ New pattern |
| Implementation effort   | Small         | Medium        | Large         |

Recommendation: Approach A
Confidence: High
Rationale: {2-3 sentences explaining why this fits the specific feature and project context}
Sources: {links from web research if applicable}
```

Apply this to decisions including but not limited to:
- Feature scope (minimal vs. full-featured)
- UX approach (modal vs. page vs. inline)
- Data display (table vs. cards vs. list)
- User flow (single step vs. wizard)
- Integration depth (surface-level vs. deep integration)

If the user wants to add capabilities beyond the feature scope during our discussion, acknowledge the idea and note it as a "future enhancement" rather than expanding scope. Keep the feature focused.

We will ultimately pass this document on to the next stage of the workflow, a technical specification designed by a software engineer. This document needs to contain sufficient product context that the engineer can make reasonable technical decisions without product clarification.

## Error Handling

| Situation | Action |
|-----------|--------|
| Insufficient project context (no README, no existing code) | Ask the user to describe the project before proceeding. |
| Vague or underspecified feature idea | Ask clarifying questions until scope is concrete enough to define acceptance criteria. |
| Feature overlaps with existing functionality | Highlight the overlap and ask the user whether to extend existing or create new. |

## Review Your Output

Before finalizing FEATURE_SPEC.md, re-read the spec against the original user answers to verify:
- All user-provided context is preserved (nothing dropped or paraphrased away)
- Acceptance criteria are testable and specific
- Scope boundaries match what the user described

Once we have enough to generate a strong feature specification, tell the user that you can generate it when they're ready. Generate `FEATURE_SPEC.md` that:

1. Addresses all the required questions listed above (Core Feature Definition, Integration, Scope Boundaries)
2. Includes any future enhancements that came up during discussion
3. Is structured in whatever way best communicates this specific feature

You have latitude to organize the document as appropriate for the feature. A small UI enhancement will look different from a major new capability. Use your judgment to create a document that gives a software engineer everything they need to make technical decisions about integrating this feature.
```
