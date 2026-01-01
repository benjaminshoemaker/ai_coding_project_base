# AI Coding Project Toolkit

A structured prompt framework for building software products with AI coding assistants. This toolkit guides you through product specification, technical design, and implementation planning—producing documents that AI agents can execute against.

## What This Solves

AI coding assistants are powerful but work best with clear, structured context. This toolkit provides prompts that help you:

1. **Define what to build** — through guided product and technical specifications
2. **Plan how to build it** — with phased execution plans and acceptance criteria
3. **Execute systematically** — using prompts designed for iterative, agent-driven development

## Quick Start

### Option 1: Clone the Repository
```bash
git clone https://github.com/yourusername/ai_coding_project_base.git
```

### Option 2: Copy the Files
Download and copy these files to your project:
- `PRODUCT_SPEC_PROMPT.md`
- `TECHNICAL_SPEC_PROMPT.md`
- `GENERATOR_PROMPT.md` (for new projects)
- `FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` (for adding features)
- `START_PROMPTS.md`

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SPECIFICATION PHASE                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Idea                                                             │
│       ↓                                                                 │
│   PRODUCT_SPEC_PROMPT  ──────→  PRODUCT_SPEC.md                        │
│       ↓                                                                 │
│   TECHNICAL_SPEC_PROMPT  ────→  TECHNICAL_SPEC.md                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                            PLANNING PHASE                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Choose your generator:                                                │
│                                                                         │
│   ┌─────────────────────┐    ┌─────────────────────────────────────┐   │
│   │ New Project?        │    │ Adding to Existing Project?         │   │
│   │                     │    │                                     │   │
│   │ GENERATOR_PROMPT    │    │ FEATURE_EXECUTION_PLAN_GENERATOR    │   │
│   │         ↓           │    │              ↓                      │   │
│   │ • EXECUTION_PLAN.md │    │ • EXECUTION_PLAN.md                 │   │
│   │ • AGENTS.md         │    │ • AGENTS.md additions               │   │
│   └─────────────────────┘    └─────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           EXECUTION PHASE                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   START_PROMPTS  ────→  Execute phases iteratively with AI agents      │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Usage

### Step 1: Product Specification

Paste `PRODUCT_SPEC_PROMPT.md` into your AI assistant along with your idea.

The AI will ask questions to clarify:
- What problem the app solves
- Who the target users are
- Core user experience
- MVP features
- Data requirements

**Output:** `PRODUCT_SPEC.md`

```markdown
# Example output snippet:
## Problem Statement
Users struggle to track their daily habits consistently...

## Target Users
- Primary: Young professionals (25-35) seeking self-improvement
- Secondary: Students building study routines
```

### Step 2: Technical Specification

Paste `TECHNICAL_SPEC_PROMPT.md` along with your `PRODUCT_SPEC.md`.

The AI will guide you through:
- Architecture decisions
- Tech stack selection
- Data models
- API contracts
- Implementation sequence

**Output:** `TECHNICAL_SPEC.md`

```markdown
# Example output snippet:
## Tech Stack
- Frontend: Next.js 14 with App Router
- Database: SQLite with Drizzle ORM
- Styling: Tailwind CSS

## Data Models
### Habit
| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| name | string | Habit name |
| frequency | enum | daily/weekly/custom |
```

### Step 3: Choose Your Generator

**Use `GENERATOR_PROMPT.md` when:**
- Starting a brand new project
- Building from scratch with no existing codebase
- You need both EXECUTION_PLAN.md and AGENTS.md

**Use `FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` when:**
- Adding a feature to an existing project
- You already have an AGENTS.md file
- You need to integrate with existing code patterns

```
                    ┌──────────────────────────┐
                    │  Do you have an existing │
                    │  codebase with AGENTS.md?│
                    └────────────┬─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
               ┌────────┐               ┌────────┐
               │   No   │               │  Yes   │
               └────┬───┘               └────┬───┘
                    │                        │
                    ▼                        ▼
        ┌───────────────────┐    ┌─────────────────────────┐
        │ GENERATOR_PROMPT  │    │ FEATURE_EXECUTION_PLAN  │
        │                   │    │ _GENERATOR_PROMPT       │
        └───────────────────┘    └─────────────────────────┘
```

**Output:** `EXECUTION_PLAN.md` and `AGENTS.md` (or additions)

```markdown
# Example EXECUTION_PLAN.md snippet:
## Phase 1: Foundation

### Step 1.1: Project Setup

#### Task 1.1.A: Initialize Project Structure

**What:** Create Next.js project with required dependencies

**Acceptance Criteria:**
- [ ] Project runs with `npm run dev`
- [ ] Tailwind CSS configured and working
- [ ] Basic folder structure in place

**Files:**
- Create: `src/app/page.tsx` — Landing page
- Create: `src/app/layout.tsx` — Root layout
```

### Step 4: Execute with START_PROMPTS

Use the prompts in `START_PROMPTS.md` to guide execution:

- **Fresh start** — Orient the AI to your project structure
- **Phase prep** — Check prerequisites before starting a phase
- **Phase start** — Execute all tasks in a phase autonomously

## Output Documents

| Document | Purpose |
|----------|---------|
| `PRODUCT_SPEC.md` | Defines *what* you're building and *why* |
| `TECHNICAL_SPEC.md` | Defines *how* it will be built technically |
| `EXECUTION_PLAN.md` | Breaks work into phases, steps, and tasks with acceptance criteria |
| `AGENTS.md` | Workflow guidelines for AI agents (TDD policy, context management, guardrails) |

## Tips for Best Results

1. **Be specific with your initial idea** — The more detail you provide upfront, the fewer clarification rounds needed

2. **Accept or push back on recommendations** — The prompts include AI recommendations with confidence levels; feel free to override them

3. **Keep specs updated** — If scope changes during development, update your specs to keep agents aligned

4. **Use phase checkpoints** — Each phase ends with verification; don't skip these

5. **Track follow-ups in TODOS.md** — The framework encourages capturing scope creep items rather than addressing them immediately

## File Structure

```
ai_coding_project_base/
├── PRODUCT_SPEC_PROMPT.md           # Step 1: Product specification prompt
├── TECHNICAL_SPEC_PROMPT.md         # Step 2: Technical specification prompt
├── GENERATOR_PROMPT.md              # Step 3a: For new projects
├── FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md  # Step 3b: For features
├── START_PROMPTS.md                 # Step 4: Execution prompts
├── docs/                            # Additional documentation
└── deprecated/                      # Legacy prompts (kept for reference)
```

## License

MIT
