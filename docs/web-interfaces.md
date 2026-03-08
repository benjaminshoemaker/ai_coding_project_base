# Using Web Interfaces

The slash commands optimize for **workflow integration and consistency**, but web-based LLM interfaces may produce **higher quality specification documents** in certain scenarios.

## When Web Interfaces May Be Better

| Scenario | Why |
|----------|-----|
| **Greenfield product specs** | Web search enables competitor analysis, market research, and industry best practices |
| **Complex product decisions** | Extended thinking modes provide deeper reasoning on trade-offs |
| **Rich reference material** | Projects/uploads let you include user research, brand guides, competitor docs |
| **Document iteration** | Artifact panels make it easier to refine sections while viewing the whole |

## When Slash Commands Are Better

| Scenario | Why |
|----------|-----|
| **Feature development** | Needs codebase access to understand existing patterns and constraints |
| **Technical specs** | Benefits from reading actual code, not just descriptions |
| **Workflow velocity** | Documents land in the right place, ready for next step |
| **Team consistency** | Same environment produces predictable, uniform outputs |

## Hybrid Workflow

You can generate specs in a web interface and continue execution in Claude Code.

### For Greenfield Projects

```bash
# 1. In Claude/ChatGPT web interface:
#    - Paste contents of .claude/skills/product-spec/PROMPT.md
#    - Complete the Q&A, copy the resulting markdown

# 2. Save to your project:
#    - Create plans/greenfield/PRODUCT_SPEC.md in your target directory

# 3. Continue in Claude Code (from your project directory):
cd ~/Projects/my-app
/technical-spec                      # Reads plans/greenfield/PRODUCT_SPEC.md
/generate-plan

# 4. Execute normally:
cd plans/greenfield
/fresh-start
/configure-verification
/phase-prep 1
/phase-start 1
```

### For Feature Development

```bash
# 1. In web interface:
#    - Paste contents of .claude/skills/feature-spec/PROMPT.md
#    - Include relevant context about your existing app
#    - Copy the resulting markdown

# 2. Save to your project:
#    - Create FEATURE_SPEC.md in your target directory

# 3. Continue in Claude Code (from your project directory):
cd ~/Projects/my-app
/feature-technical-spec my-feature    # Benefits from codebase access
/feature-plan my-feature

# 4. Execute normally
```

## Prompt Files for Web Use

The raw prompts are available for copy-paste into any LLM:

| Document | Prompt File |
|----------|-------------|
| `plans/greenfield/PRODUCT_SPEC.md` | `.claude/skills/product-spec/PROMPT.md` |
| `plans/greenfield/TECHNICAL_SPEC.md` | `.claude/skills/technical-spec/PROMPT.md` |
| FEATURE_SPEC.md | `.claude/skills/feature-spec/PROMPT.md` |
| FEATURE_TECHNICAL_SPEC.md | `.claude/skills/feature-technical-spec/PROMPT.md` |

**Note:** The greenfield plan files (`plans/greenfield/EXECUTION_PLAN.md`, `plans/greenfield/AGENTS.md`) plus root `AGENTS.md` are best generated in Claude Code, where the generator can read your saved specs directly.
