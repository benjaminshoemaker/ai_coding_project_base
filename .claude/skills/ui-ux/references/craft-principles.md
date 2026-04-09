# Craft Principles (Quality Floor)

*Adapted from design-principles by interface-design.*

These apply regardless of design direction. This is the minimum bar.

## Spacing: 4px Grid
All spacing on a 4px base: 4, 8, 12, 16, 24, 32px. Symmetrical padding (TLBR match).

## Depth & Elevation
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

## Typography Hierarchy
- Headlines: 600 weight, tight letter-spacing (-0.02em)
- Body: 400-500 weight, standard tracking. Line-height 1.5-1.75, 65-75 chars/line.
- Labels: 500 weight, slight positive tracking for uppercase
- Data/numbers: monospace, `tabular-nums` for columnar alignment

## Contrast & Color
- Four-level contrast: foreground (primary) -> secondary -> muted -> faint
- Gray builds structure. Color only for meaning: status, action, error, success.
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes.

## Cards & Surfaces
Card layouts should vary to serve their content (metric card != plan card != settings card),
but surface treatment stays consistent: same border weight, shadow depth, corner radius,
padding scale. Cohesion comes from the container chrome, not identical internal layouts.

## Controls & Forms
Never use native `<select>`, `<input type="date">` in styled UI — they render OS-native
controls that can't be styled. Build custom: trigger button + dropdown, input + calendar
popover, styled div + state management.

## Navigation Context
Screens need grounding. A data table floating in space feels like a component demo, not
a product. Include navigation (sidebar/top nav), location indicators (breadcrumbs, active
state), and user context (who's logged in, what workspace).

## Dark Mode
- Borders over shadows — shadows barely show on dark backgrounds
- Desaturate semantic colors (success, warning, error) to avoid harshness
- Same contrast hierarchy, inverted values
- Border at 10-15% white opacity — resist making it more prominent

## Anti-Patterns
- Dramatic drop shadows, large border radius (16px+) on small elements
- Asymmetric padding without clear reason
- Thick borders (2px+) or gradients for decoration
- Multiple accent colors in one interface
- Spring/bouncy animations in professional UI
- Emojis as UI icons — use SVG icon sets (Lucide, Phosphor, Heroicons)
