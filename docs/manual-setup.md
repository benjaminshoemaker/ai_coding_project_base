# Manual Setup

If you're not using Claude Code, you can use this toolkit with any LLM by copying prompts manually.

## Setup Steps

1. **Clone the toolkit** to get access to the prompt files:
   ```bash
   git clone https://github.com/yourusername/ai_coding_project_base.git
   ```

2. **Copy execution skills** to your project:
   ```bash
   cp -r ai_coding_project_base/.claude/skills/ your-project/.claude/skills/
   ```

3. **Generate specs** by pasting prompt contents into your LLM:
   - `.claude/skills/product-spec/PROMPT.md` → produces `plans/greenfield/PRODUCT_SPEC.md`
   - `.claude/skills/technical-spec/PROMPT.md` → produces `plans/greenfield/TECHNICAL_SPEC.md`

4. **Generate execution plan** (requires file access):
   - If your LLM can read files, use `.claude/skills/generate-plan/PROMPT.md`
   - Otherwise, paste your specs into the prompt context

5. **Execute using START_PROMPTS.md**:
   - Copy the relevant execution prompts
   - Paste them into your LLM session with your project context

## Prompt Files Reference

### Greenfield Projects

| Output Document | Prompt File |
|-----------------|-------------|
| `plans/greenfield/PRODUCT_SPEC.md` | `.claude/skills/product-spec/PROMPT.md` |
| `plans/greenfield/TECHNICAL_SPEC.md` | `.claude/skills/technical-spec/PROMPT.md` |
| `AGENTS.md` + `plans/PLAN_STATUS.md` + `plans/greenfield/EXECUTION_PLAN.md` + `plans/greenfield/AGENTS.md` | `.claude/skills/generate-plan/PROMPT.md` |

### Feature Development

| Output Document | Prompt File |
|-----------------|-------------|
| FEATURE_SPEC.md | `.claude/skills/feature-spec/PROMPT.md` |
| FEATURE_TECHNICAL_SPEC.md | `.claude/skills/feature-technical-spec/PROMPT.md` |
| `EXECUTION_PLAN.md` + `AGENTS.md` | `.claude/skills/feature-plan/PROMPT.md` |

### Execution

See `START_PROMPTS.md` for phase execution prompts.
Read `plans/PLAN_STATUS.md` before executing; only the current active plan is
implementable.

## Limitations

Without Claude Code's slash commands, you lose:

- **Automatic file placement** — You'll need to save outputs manually
- **Automatic verification** — Run tests and checks manually
- **Git workflow automation** — Manage branches and commits yourself
- **MCP tool detection** — Configure tools manually

The core workflow (specify → plan → execute) still works, but requires more manual coordination.

## Recommended Workflow

1. Use a web LLM (Claude, ChatGPT) for specification generation
2. Save the generated docs to your project
3. Use any code-capable LLM for execution, following `START_PROMPTS.md`
   - Greenfield execution runs from `plans/greenfield/`
   - Feature execution runs from `features/<name>/`
4. Manually run verification between tasks
