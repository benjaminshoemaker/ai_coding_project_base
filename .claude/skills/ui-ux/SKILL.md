---
name: ui-ux
description: "Comprehensive UI/UX analysis and design intelligence. Point at any product to get: code analysis, product/user context assessment, industry pattern research, and prioritized improvement recommendations. Combines craft principles, data-driven design intelligence, and creative excellence. Also guides design system setup for consistent AI-assisted UI work."
allowed-tools: Bash, Read, Glob, Grep, WebSearch, WebFetch, Edit, Write, Task, AskUserQuestion
argument-hint: "[action] [target] — actions: audit, design, improve, setup-design-system. e.g. 'audit src/components' or 'design dashboard for analytics SaaS'"
---

# UI/UX Design Intelligence

Unified UI/UX skill for analysis, research, and design guidance. Works in two modes:

- **Audit mode** (`audit`, `review`, `improve`, `check`) — Analyze existing UI code against craft principles, accessibility, and industry patterns. Produces prioritized recommendations.
- **Design mode** (`design`, `build`, `create`, `plan`) — Guide new UI creation with research-backed design direction, style selection, and implementation.

Both modes use product context, user research, and the design knowledge embedded below.

## Acknowledgments

This skill incorporates ideas from three excellent sources. It bundles their key
insights directly so no separate installs are needed. For the full experience,
install the originals:

- **design-principles** by interface-design — Craft quality standards inspired by
  Linear, Notion, and Stripe. The design direction framework and depth/elevation
  strategies below are adapted from this skill.
- **ui-ux-pro-max** by nextlevelbuilder — Searchable design intelligence database
  with 50+ styles, 97 palettes, 57 font pairings. If installed, this skill can call
  its Python CLI for data-driven recommendations (see Phase 2a).
- **frontend-design** by Anthropic (Prithvi Rajasekaran, Alexander Bricken) — The
  anti-"AI slop" creative philosophy and spatial composition guidance below come from
  this official Claude Code plugin.

---

## Phase 1: Context Gathering (ALWAYS DO THIS FIRST)

### 1a. Scan for Product Context

Read these files if they exist (stop once you have a clear picture):

```
PRODUCT_SPEC.md, FEATURE_SPEC.md, README.md, VISION.md,
AGENTS.md (look for design system references),
design-system/MASTER.md, design-system/tokens.*,
.cursorrules, .ai/*.md
```

Extract: product type, target users, core user jobs, emotional tone, industry.

### 1b. Scan for Existing Design System

Look for evidence of an established design system:

```
design-system/**, tailwind.config.*, theme.ts, theme.js,
**/tokens.css, **/variables.css, **/design-tokens.*,
components/ui/**, shadcn components (components.json)
```

Note: existing tokens, color palette, typography scale, spacing system, component library.

### 1c. Identify Tech Stack

Detect from `package.json`, config files, file extensions:
- Framework: React, Next.js, Vue, Nuxt, Svelte, Astro, etc.
- Styling: Tailwind, CSS Modules, styled-components, vanilla CSS
- Component library: shadcn/ui, Radix, MUI, Mantine, Headless UI
- Icons: Lucide, Phosphor, Heroicons

### 1d. Scan UI Code (Audit Mode)

For audit targets, read the relevant UI files. Look at:
- Component structure and composition patterns
- Color usage and consistency
- Spacing and layout patterns
- Typography choices
- Interactive states (hover, focus, disabled, loading, error)
- Responsive behavior
- Accessibility attributes (aria-*, alt, role, labels)

### 1e. Ask for Missing Context

If product context is thin (no specs, no README with product description), use AskUserQuestion:

> "To give you the best UI/UX recommendations, I need some context:
> 1. What does this product do? Who uses it?
> 2. What's the emotional job? (Trust? Efficiency? Delight? Focus?)
> 3. Any design references or products you admire?
>
> You can also point me at product docs or a live URL."

---

## Phase 2: Research

### 2a. Design Intelligence Database (Optional Enhancement)

If **ui-ux-pro-max** is installed, use its Python CLI for data-driven recommendations.
Check for the search script at these paths:

1. `~/.agents/skills/ui-ux-pro-max/scripts/search.py`
2. `~/.claude/skills/ui-ux-pro-max/scripts/search.py`

If found, generate a design system recommendation:
```bash
python3 <path>/search.py "<product_type> <industry> <keywords>" --design-system -p "Project Name"
```

Domain searches for deeper detail:
```bash
python3 <path>/search.py "<keywords>" --domain <domain>  # product, style, typography, color, landing, chart, ux, web
python3 <path>/search.py "<keywords>" --stack <stack>     # html-tailwind, react, nextjs, vue, svelte, shadcn, etc.
```

Persist design system for future sessions:
```bash
python3 <path>/search.py "<keywords>" --design-system --persist -p "Project Name" [--page "dashboard"]
```

If not installed, skip this step — the inline knowledge and web research below are
sufficient. Note the availability to the user at the end: "For richer style/palette
recommendations, install ui-ux-pro-max by nextlevelbuilder."

### 2b. Industry & Competitor Research

Use WebSearch to find relevant patterns for the specific product type and user base:

```
Search: "[product type] UI design patterns 2025 2026"
Search: "[industry] dashboard UX best practices"
Search: "[competitor names] design system"
Search: "best [product type] interfaces examples"
```

Focus on:
- What interaction patterns do leading products in this space use?
- What are the common UX pitfalls in this product category?
- What accessibility concerns are specific to this product type?
- What recent design trends are relevant (not just trendy)?

### 2c. Framework-Specific Research

If the stack warrants it, search for current best practices:

```
Search: "[framework] [component type] accessibility patterns"
Search: "Tailwind v4 @theme design tokens" (if using Tailwind)
Search: "shadcn/ui [component] best practices" (if using shadcn)
```

---

## Phase 3: Design Direction

*Adapted from design-principles by interface-design.*

**Before writing any code, commit to a design direction.** Don't default. Think about
what this specific product needs to feel like.

### Context Questions

- **What does this product do?** A finance tool needs different energy than a creative tool.
- **Who uses it?** Power users want density. Occasional users want guidance.
- **What's the emotional job?** Trust? Efficiency? Delight? Focus?
- **What would make this memorable?** Every product has a chance to feel distinctive.

### Choose a Personality

| Personality | Characteristics | Best For |
|-------------|----------------|----------|
| **Precision & Density** | Tight spacing, monochrome, information-forward | Power user tools (Linear, Raycast, terminals) |
| **Warmth & Approachability** | Generous spacing, soft shadows, friendly colors | Collaborative tools (Notion, Coda) |
| **Sophistication & Trust** | Cool tones, layered depth, financial gravitas | Finance, sensitive data (Stripe, Mercury) |
| **Boldness & Clarity** | High contrast, dramatic negative space, confident type | Modern dashboards (Vercel) |
| **Utility & Function** | Muted palette, functional density, clear hierarchy | Developer tools (GitHub) |
| **Data & Analysis** | Chart-optimized, technical but accessible | Analytics, BI tools |
| **Bold Creative** | Unexpected layouts, distinctive type, atmospheric depth | Marketing, creative tools, portfolios |

Pick one. Or blend two. But commit to a direction that fits the product.

### Choose a Color Foundation

Don't default to warm neutrals. Consider the product:

- **Warm foundations** (creams, warm grays) — approachable, comfortable, human
- **Cool foundations** (slate, blue-gray) — professional, trustworthy, serious
- **Pure neutrals** (true grays, black/white) — minimal, bold, technical
- **Tinted foundations** (slight color cast) — distinctive, memorable, branded

Light or dark? Dark feels technical, focused, premium. Light feels open, approachable,
clean. Choose based on context. Pick ONE accent color that means something.

### Choose Typography

- **System fonts** — fast, native, invisible (utility-focused products)
- **Geometric sans** (Geist, Inter) — modern, clean, technical
- **Humanist sans** (SF Pro, Satoshi) — warmer, more approachable
- **Monospace influence** — technical, developer-focused, data-heavy
- **Distinctive display** — bold creative products deserve unexpected, characterful choices

### Creative Direction

*Adapted from frontend-design by Anthropic.*

For every project, push beyond safe defaults. Ask: **what makes this UNFORGETTABLE?**

- **Commit to a clear conceptual direction** and execute with precision. Bold maximalism
  and refined minimalism both work — the key is intentionality, not intensity.
- **Avoid generic AI aesthetics:** overused fonts (Inter everywhere, Space Grotesk
  everywhere), purple-gradient-on-white, predictable layouts, cookie-cutter components.
  No design should be the same. Vary themes, fonts, and aesthetics across projects.
- **Spatial composition:** Consider unexpected layouts, asymmetry, overlap, diagonal flow,
  grid-breaking elements, generous negative space OR controlled density.
- **Backgrounds & atmosphere:** Create depth rather than defaulting to solid colors. Use
  gradient meshes, noise textures, geometric patterns, layered transparencies, grain
  overlays — whatever fits the aesthetic direction.
- **Motion with purpose:** Focus on high-impact moments — one well-orchestrated page load
  with staggered reveals creates more delight than scattered micro-interactions.
- **Match complexity to vision:** Maximalist designs need elaborate code. Minimalist
  designs need restraint, precision, and careful attention to subtle details.

---

## Phase 4: Craft Principles (Quality Floor)

*Adapted from design-principles by interface-design.*

These apply regardless of design direction. This is the minimum bar.

### Spacing: 4px Grid
All spacing on a 4px base: 4, 8, 12, 16, 24, 32px. Symmetrical padding (TLBR match).

### Depth & Elevation
Choose ONE approach and commit. Mixing strategies creates visual inconsistency.

- **Borders-only** — Clean, technical, dense. Subtle borders define regions. Not lazy — intentional restraint. (Linear, Raycast)
- **Subtle single shadows** — `0 1px 3px rgba(0,0,0,0.08)`. Soft lift without complexity.
- **Layered shadows** — Multiple shadow layers for premium, dimensional feel. (Stripe, Mercury)
- **Surface color shifts** — Background tints establish hierarchy. Card at `#fff` on `#f8fafc` already feels elevated.

```css
/* Borders-only */
border: 0.5px solid rgba(0, 0, 0, 0.08);

/* Single shadow */
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);

/* Layered shadows */
box-shadow: 0 0 0 0.5px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.04), 0 2px 4px rgba(0,0,0,0.03), 0 4px 8px rgba(0,0,0,0.02);
```

The craft is in the choice, not the complexity.

### Typography Hierarchy
- Headlines: 600 weight, tight letter-spacing (-0.02em)
- Body: 400-500 weight, standard tracking. Line-height 1.5-1.75, 65-75 chars/line.
- Labels: 500 weight, slight positive tracking for uppercase
- Data/numbers: monospace, `tabular-nums` for columnar alignment

### Contrast & Color
- Four-level contrast: foreground (primary) → secondary → muted → faint
- Gray builds structure. Color only for meaning: status, action, error, success.
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes.

### Cards & Surfaces
Card layouts should vary to serve their content (metric card ≠ plan card ≠ settings card),
but surface treatment stays consistent: same border weight, shadow depth, corner radius,
padding scale. Cohesion comes from the container chrome, not identical internal layouts.

### Controls & Forms
Never use native `<select>`, `<input type="date">` in styled UI — they render OS-native
controls that can't be styled. Build custom: trigger button + dropdown, input + calendar
popover, styled div + state management.

### Navigation Context
Screens need grounding. A data table floating in space feels like a component demo, not
a product. Include navigation (sidebar/top nav), location indicators (breadcrumbs, active
state), and user context (who's logged in, what workspace).

### Dark Mode
- Borders over shadows — shadows barely show on dark backgrounds
- Desaturate semantic colors (success, warning, error) to avoid harshness
- Same contrast hierarchy, inverted values
- Border at 10-15% white opacity — resist making it more prominent

### Anti-Patterns
- Dramatic drop shadows, large border radius (16px+) on small elements
- Asymmetric padding without clear reason
- Thick borders (2px+) or gradients for decoration
- Multiple accent colors in one interface
- Spring/bouncy animations in professional UI
- Emojis as UI icons — use SVG icon sets (Lucide, Phosphor, Heroicons)

---

## Phase 5: Accessibility & Interaction Quality

### Non-Negotiable Accessibility

| Requirement | Standard |
|-------------|----------|
| Color contrast | 4.5:1 minimum for normal text (WCAG AA) |
| Touch targets | 44x44px minimum |
| Focus indicators | Visible focus rings on all interactive elements |
| Alt text | Descriptive alt text for meaningful images |
| ARIA | aria-label for icon-only buttons, proper roles |
| Keyboard | Tab order matches visual order, all flows keyboard-operable |
| Form labels | Every input has an associated label |
| Reduced motion | Respect `prefers-reduced-motion` |
| Semantic HTML | Use proper elements (button, nav, main, article) |
| Color independence | Color is never the only indicator of state |

### Interaction Quality

*Common mistakes adapted from ui-ux-pro-max by nextlevelbuilder.*

| Rule | Do | Don't |
|------|----|-------|
| Cursor | `cursor-pointer` on all clickable elements | Default cursor on interactive elements |
| Hover feedback | Color/opacity transitions on hover | Scale transforms that shift layout |
| Transitions | `transition-colors duration-200` (150-300ms) | Instant changes or >500ms |
| Loading | Disable button during async, show skeleton/spinner | No indication of loading state |
| Error feedback | Clear messages near the problem | Vague or distant error display |
| Icon sizing | Fixed viewBox (24x24), consistent `w-6 h-6` | Mixed icon sizes |
| Brand logos | Research official SVG from Simple Icons | Guess or use incorrect paths |

### Light/Dark Mode Contrast

| Context | Do | Don't |
|---------|----|-------|
| Glass cards (light) | `bg-white/80` or higher opacity | `bg-white/10` (too transparent) |
| Text (light) | `#0F172A` (slate-900) for body | `#94A3B8` (slate-400) for body |
| Muted text (light) | `#475569` (slate-600) minimum | gray-400 or lighter |
| Borders (light) | `border-gray-200` | `border-white/10` (invisible) |

---

## Phase 6: Deliver Recommendations

### Audit Mode Output

Structure findings as a prioritized report:

```markdown
# UI/UX Audit: [Product Name]

## Context
- Product type: ...
- Target users: ...
- Design direction: [recommended personality]
- Tech stack: ...

## Design System Status
- [EXISTS/PARTIAL/MISSING] — [details]

## Findings

### Critical (Fix Immediately)
[Accessibility, broken interactions, contrast failures]

### High Priority (Fix Soon)
[Layout inconsistencies, missing states, responsive issues]

### Medium Priority (Improve)
[Typography, spacing, animation opportunities]

### Suggestions (Consider)
[Design direction refinement, creative enhancements, industry patterns]

## Research Insights
[Patterns from industry research specific to this product type]

## Design System Recommendations
[What to establish for consistent future work — see Phase 7]

## Implementation Plan
[Ordered changes, grouped by file/component]
```

### Design Mode Output

For new UI work, provide:

1. **Design direction** — Personality, color foundation, typography, depth strategy
2. **Research findings** — Industry patterns and relevant references
3. **Implementation guidance** — Component structure, token setup, responsive strategy
4. **Creative direction** — What makes this design distinctive and memorable
5. **Pre-delivery checklist** — Quality gates before shipping

---

## Phase 7: Establish Best Practices (ALWAYS INCLUDE)

After every audit or design session, include a "Future-Proofing" section with relevant
recommendations. Don't include all — pick what's most impactful for this project's state.

### Design System Setup

If the project lacks a design system, recommend creating one:

**1. Design Tokens File** (`design-system/tokens.css` or `@theme` in Tailwind v4):
```css
@theme {
  --color-primary: #2563eb;       /* Trust, primary actions */
  --color-destructive: #dc2626;   /* Errors, destructive actions only */
  --color-success: #16a34a;       /* Confirmation, positive status */
  --color-warning: #d97706;       /* Caution, needs attention */
  --color-muted: #64748b;         /* Secondary text, less emphasis */
  --color-border: #e2e8f0;        /* Default borders */

  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;

  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
}
```

**2. Design System Documentation** (`design-system/MASTER.md`):
Document the chosen design direction, token values, component conventions, and
constraints. If ui-ux-pro-max is installed, use `--persist` to generate this
automatically. Otherwise, create it manually from the design direction decisions.

**3. Page-Specific Overrides** (`design-system/pages/<page>.md`):
For pages with unique design needs (marketing landing vs. app dashboard), document
how they deviate from the master rules.

### AGENTS.md Integration

Recommend adding a Design System section to the project's AGENTS.md:

```markdown
## Design System

This project follows [Personality] design direction.

- **Design tokens:** `design-system/tokens.css` (or `tailwind.config.*`)
- **Master design rules:** `design-system/MASTER.md`
- **Component library:** [shadcn/ui, Radix, custom, etc.]
- **Icon set:** [Lucide, Phosphor, Heroicons]
- **Key constraints:**
  - 4px spacing grid
  - [Chosen radius system]
  - [Chosen depth strategy]
  - WCAG AA minimum accessibility
  - `prefers-reduced-motion` respected

When building UI, read `design-system/MASTER.md` first. Check for page-specific
overrides at `design-system/pages/<page-name>.md`.
```

### AI-Readable Token Metadata

For maximum AI effectiveness, enrich tokens with usage context (DTCG format):

```json
{
  "color-feedback-error": {
    "$type": "color",
    "$value": "#DC2626",
    "$description": "Error messages, destructive button backgrounds, invalid input borders. Never decorative.",
    "when_to_use": ["form validation errors", "destructive action confirmations"],
    "avoid_when": ["decorative purposes", "warning states"]
  }
}
```

Tokens with `when_to_use` and `avoid_when` prevent arbitrary AI color choices.

### Component Patterns

If using shadcn/ui or similar copy-to-project libraries:
- **Wrapper components:** Create pre-configured wrappers (e.g., `AppButton`) with brand
  defaults instead of raw library imports. Scales better and ensures consistency.
- **Directory structure:** Separate raw library components (`components/ui/`), customized
  wrappers (`components/`), and feature compositions (`components/[feature]/`).

### Modern CSS Techniques

Recommend when the project supports them:
- **Container queries** (`@container`) — Components respond to parent size, not viewport.
- **`:has()` selector** — Style parents based on children without JavaScript.
- **Native CSS nesting** — SCSS-like organization without preprocessor.
- **`@layer`** — Cascade layers for design system vs component vs utility specificity.
- **Tailwind v4 `@theme`** — CSS-first design tokens replacing JavaScript config.

---

## Pre-Delivery Checklist

### Visual Quality
- [ ] Consistent spacing on 4px grid
- [ ] Typography hierarchy is clear and consistent
- [ ] Color usage is disciplined (accent earns its place)
- [ ] Depth strategy is consistent throughout
- [ ] No emojis as icons — using consistent SVG icon set
- [ ] Hover states don't cause layout shift
- [ ] Design feels intentional and distinctive, not generic

### Interaction
- [ ] All clickable elements have `cursor-pointer`
- [ ] Hover, focus, active, disabled states all defined
- [ ] Transitions smooth (150-300ms)
- [ ] Loading states for async operations

### Accessibility
- [ ] Color contrast 4.5:1+ (all text/background combinations)
- [ ] All images have alt text
- [ ] All form inputs have labels
- [ ] Keyboard navigation works (tab order, enter/space to activate)
- [ ] Focus rings visible
- [ ] `prefers-reduced-motion` respected
- [ ] Touch targets 44x44px minimum

### Responsive
- [ ] Works at 375px, 768px, 1024px, 1440px
- [ ] No horizontal scroll on mobile
- [ ] Content readable at all breakpoints

### Light/Dark Mode (if applicable)
- [ ] Text contrast sufficient in both modes
- [ ] Borders visible in both modes
- [ ] Semantic colors adjusted for dark backgrounds
- [ ] Glass/transparent elements visible in light mode
