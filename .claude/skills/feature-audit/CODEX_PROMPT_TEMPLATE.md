# Codex Consultation Prompt Template

Template for generating the Codex consultation prompt during a feature audit.

---

## Prompt Structure

```markdown
# Feature Audit: Cross-Model Consultation

## Pre-Consultation Research

Before analyzing, research:
1. UI/UX patterns for {feature_type} in B2B SaaS dashboards
2. Best practices for {specific_pattern} visualization
3. {domain_specific_research_topic}

## Context

{project_description}

**Key users:**
{user_personas_from_vision_docs}

**The feature being reviewed:** {feature_summary_from_spec}

## Documents to Review

### 1. Feature Specification
Read the file: `{spec_path}`

### 2. Execution Plan (if provided)
Read the file: `{plan_path}`

### 3. Current Implementation Files
Read these files to understand what was actually built:
{list_of_key_implementation_files}

## Focus Areas

Analyze deeply on these dimensions:

### 1. Spec Alignment
- Were all planned items implemented?
- What's missing or diverged?
- Were key features fully implemented or stubbed?

### 2. UI/UX Quality for Target Users
- Are the {feature_elements} actionable?
- Is information density appropriate for {user_type}?
- Does the UI avoid alert fatigue?
- Is progressive disclosure effective?

### 3. Obvious Improvements
- What should be added?
- What should be removed as noise?
- Are there missing UX patterns?

### 4. Data Visualization Effectiveness
- Are key metrics communicated clearly?
- Do visualizations drive action or just inform?

### 5. Output Quality (if applicable — PDF, reports, exports)
- Does generated output look professional?
- Is it the right length/format for its purpose?

## Output

Write your complete analysis to `{output_path}` with these sections:
- Spec Alignment Assessment
- UI/UX Findings
- Recommended Improvements (HIGH / MEDIUM / LOW)
- Visualization/Output Assessment
- Overall Assessment
```

---

## Variable Substitution

| Variable | Source | Fallback |
|----------|--------|----------|
| `{feature_type}` | Inferred from spec (e.g., "recommendation system", "data import wizard") | "feature" |
| `{specific_pattern}` | Inferred from spec (e.g., "cost of inaction", "portfolio health scoring") | "dashboard component" |
| `{domain_specific_research_topic}` | Inferred from spec + vision docs | Omit if not applicable |
| `{project_description}` | From AGENTS.md "Project Overview" section | "A B2B SaaS application" |
| `{user_personas_from_vision_docs}` | From VISION.md or PRODUCT_PRINCIPLES.md | "Expert business users" |
| `{feature_summary_from_spec}` | First paragraph of spec's Problem Statement | Spec title/filename |
| `{spec_path}` | From Step 1 input gathering | — |
| `{plan_path}` | From Step 1 input gathering | Omit section if no plan |
| `{list_of_key_implementation_files}` | From Stream 3a code exploration | Auto-detect from git diff or file search |
| `{user_type}` | From vision docs | "expert users" |
| `{feature_elements}` | From spec (e.g., "recommendation cards", "import steps") | "feature components" |
| `{output_path}` | `/tmp/codex-consult-output-$(date +%s).md` | — |

---

## Codex Invocation

```bash
# Read config
CODEX_MODEL=$(jq -r '.featureAudit.codexModel // .codexConsult.researchModel // .codexReview.researchModel // "gpt-5.2"' .claude/settings.local.json 2>/dev/null || echo "gpt-5.2")
TIMEOUT_MINS=$(jq -r '.featureAudit.codexTimeoutMinutes // .codexConsult.consultTimeoutMinutes // 20' .claude/settings.local.json 2>/dev/null || echo "20")

# Safety: record HEAD
HEAD_BEFORE=$(git rev-parse HEAD)

# Invoke (use Bash tool timeout, NOT shell timeout)
cat {prompt_file} | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy="never"' \
  -c 'features.search=true' \
  --model $CODEX_MODEL \
  -o $OUTPUT_FILE \
  -

# Safety: check HEAD
HEAD_AFTER=$(git rev-parse HEAD)
if [ "$HEAD_BEFORE" != "$HEAD_AFTER" ]; then
  echo "WARNING: Codex made commits during consultation."
  # Do NOT auto-revert — report to user per project guardrails
fi
```

**CRITICAL:** Do NOT use `run_in_background` for the Codex Bash command. Use the Bash tool's `timeout` parameter set to `TIMEOUT_MINS * 60 * 1000` ms.

**CRITICAL:** Do NOT use `2>&1` — Codex streams progress to stderr and final output to stdout. Merging them corrupts the output.
