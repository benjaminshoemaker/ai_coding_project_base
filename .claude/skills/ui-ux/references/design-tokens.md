# Design Tokens & Design System Setup

## Design System Setup

If the project lacks a design system, recommend creating one:

### 1. Design Tokens File

`design-system/tokens.css` or `@theme` in Tailwind v4:

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

### 2. Design System Documentation

`design-system/MASTER.md`: Document the chosen design direction, token values,
component conventions, and constraints. If ui-ux-pro-max is installed, use
`--persist` to generate this automatically. Otherwise, create it manually from
the design direction decisions.

### 3. Page-Specific Overrides

`design-system/pages/<page>.md`: For pages with unique design needs (marketing
landing vs. app dashboard), document how they deviate from the master rules.

## AI-Readable Token Metadata

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

## Component Patterns

If using shadcn/ui or similar copy-to-project libraries:
- **Wrapper components:** Create pre-configured wrappers (e.g., `AppButton`) with brand
  defaults instead of raw library imports. Scales better and ensures consistency.
- **Directory structure:** Separate raw library components (`components/ui/`), customized
  wrappers (`components/`), and feature compositions (`components/[feature]/`).

## Modern CSS Techniques

Recommend when the project supports them:
- **Container queries** (`@container`) — Components respond to parent size, not viewport.
- **`:has()` selector** — Style parents based on children without JavaScript.
- **Native CSS nesting** — SCSS-like organization without preprocessor.
- **`@layer`** — Cascade layers for design system vs component vs utility specificity.
- **Tailwind v4 `@theme`** — CSS-first design tokens replacing JavaScript config.
