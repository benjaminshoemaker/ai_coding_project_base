# Accessibility & Interaction Quality

## Non-Negotiable Accessibility

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

## Interaction Quality

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

## Light/Dark Mode Contrast

| Context | Do | Don't |
|---------|----|-------|
| Glass cards (light) | `bg-white/80` or higher opacity | `bg-white/10` (too transparent) |
| Text (light) | `#0F172A` (slate-900) for body | `#94A3B8` (slate-400) for body |
| Muted text (light) | `#475569` (slate-600) minimum | gray-400 or lighter |
| Borders (light) | `border-gray-200` | `border-white/10` (invisible) |
