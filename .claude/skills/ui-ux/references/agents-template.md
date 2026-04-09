# AGENTS.md Design System Template

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
