Ask me questions so that we can develop a product specification document for this idea.

The resulting document should answer at least (but not limited to) this set of questions:
- What problem does the app solve?
- Who is the ideal user for this app?
- What platform(s) does it live on (mobile web, mobile app, web, CLI)?
- Describe the core user experience, step-by-step.
- What are the must-have features for the MVP?
- What data will the app need to persist?
- Will it need user accounts, and will there be access controls?

Before you begin asking questions, plan your questions out to meet the following guidelines:
- If you can infer the answer from the initial idea input, no need to ask a question about it.
- Each set of questions builds on the questions before it.
- If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
- For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.

### Question Efficiency

Minimize user interruptions. Follow these rules strictly:

1. **Auto-decide strong recommendations.** If your recommendation strength is "strong" AND the question is about an implementation detail (not user-facing behavior), do NOT ask — just use your recommendation. State your assumption in the output so the user can correct if needed.

2. **Batch aggressively.** Use AskUserQuestion with up to 4 questions per call. Present all independent questions in a single batch rather than asking one at a time.

3. **Target 2-3 rounds maximum.** After reading all inputs, identify every ambiguity at once. Categorize as "must ask user" vs "can auto-decide." Only present "must ask" items, batched into 2-3 AskUserQuestion calls.

4. **Only ask about user-facing decisions.** Questions about scope, UX behavior, and user-visible functionality require user input. Questions about internal implementation, data formats, or technical approach can be auto-decided.

We are building an MVP - bias your choices towards simplicity, ease of implementation, and speed. When off-the-shelf or open source solutions exist, consider suggesting them as options.

## Making Product Choices

When facing significant product decisions (platform, feature prioritization, user experience approach), help the user make informed choices:

### Web Research (Required for Market/Competitive Decisions)
Before recommending product direction, use WebSearch to gather current information:
- Competitor analysis (what do similar products do?)
- User expectations for this category (what's table stakes vs. differentiator?)
- Platform trends (mobile-first? desktop? PWA adoption rates?)
- Common pitfalls in this product category

Cite your sources when presenting recommendations.

### Decision Matrix (Required When Multiple Approaches Exist)
When presenting choices between 2+ viable product approaches, generate a comparison matrix:

```
| Criterion               | Approach A    | Approach B    | Approach C    |
|-------------------------|---------------|---------------|---------------|
| User value delivered    | ✓ High        | ○ Medium      | ○ Medium      |
| Implementation effort   | Low           | Medium        | High          |
| Time to first user      | 1 week        | 3 weeks       | 6 weeks       |
| Differentiation         | Low           | Medium        | High          |
| Risk level              | Low           | Medium        | High          |

Recommendation: Approach A
Confidence: High
Rationale: {2-3 sentences explaining why this fits the specific product goals}
Sources: {links from web research if applicable}
```

Apply this to decisions including but not limited to:
- Platform choice (web vs mobile vs desktop vs CLI)
- MVP feature set (what's in vs. out)
- User experience approach (wizard vs. dashboard vs. single-page)
- Monetization model (if applicable)
- User onboarding flow

If the user wants to add features beyond the MVP scope during our discussion, acknowledge the idea and note it as a "post-MVP consideration" rather than expanding scope. Keep the MVP focused.

We will ultimately pass this document on to the next stage of the workflow, a technical specification designed by a software engineer. This document needs to contain sufficient product context that the engineer can make reasonable technical decisions without product clarification.

Once we have enough to generate a strong one-pager, tell the user that you can generate a product specification when they're ready. Generate `PRODUCT_SPEC.md` that:

1. Addresses all the required questions listed above
2. Includes any post-MVP considerations that came up during discussion
3. Is structured in whatever way best communicates this specific product
4. **Assigns unique requirement IDs** to each distinct requirement (see below)

You have latitude to organize the document as appropriate for the product. A CLI tool will look different from a web app. A simple utility will be shorter than a complex platform. Use your judgment to create a document that gives a software engineer everything they need to make technical decisions.

## Requirement ID Assignment

**CRITICAL:** Assign a unique requirement ID (REQ-XXX) to each distinct requirement in the specification.

### What Gets an ID

- Each MVP feature or capability
- Each user flow or experience requirement
- Each data/storage requirement
- Each access control or permission requirement
- Each integration requirement

### Format

Use sequential IDs: `REQ-001`, `REQ-002`, `REQ-003`, etc.

### How to Include

Prefix requirement statements with the ID:

```markdown
### MVP Features

- **REQ-001:** Users can create an account with email and password
- **REQ-002:** Users can log in to access their dashboard
- **REQ-003:** Users can create, edit, and delete notes
- **REQ-004:** Notes are automatically saved as the user types
- **REQ-005:** Users can search across all their notes
```

Or use inline IDs for prose sections:

```markdown
The application must support user authentication (REQ-001) and authorization (REQ-002).
Users need to be able to create notes (REQ-003) and organize them into folders (REQ-004).
```

### ID Summary Table

At the end of PRODUCT_SPEC.md, include a requirements summary table:

```markdown
## Requirements Index

| ID | Requirement | Section |
|----|-------------|---------|
| REQ-001 | User account creation | MVP Features |
| REQ-002 | User authentication | MVP Features |
| REQ-003 | Note CRUD operations | MVP Features |
| REQ-004 | Auto-save functionality | MVP Features |
| REQ-005 | Note search | MVP Features |
```

This enables downstream traceability from requirements → tasks → commits.

## Error Handling

| Situation | Action |
|-----------|--------|
| Contradictory requirements from user answers | List the contradictions and ask the user to clarify before continuing. |
| Scope too large for a single product spec | Suggest splitting into multiple specs or phasing. Ask the user to confirm scope. |
| Insufficient input (user gives one-line answers) | Ask follow-up questions to gather enough detail for a complete spec. |

## Review Your Output

Before finalizing PRODUCT_SPEC.md, re-read the spec against the user's original answers to verify:
- All user-provided requirements are represented
- No context was lost during synthesis
- User stories cover the stated use cases completely
