# Browser Inspection Prompt Template

Template for generating the browser inspection agent prompt during a feature audit.

---

## Agent Prompt Structure

```
I need you to inspect the live {app_name} application UI using browser automation tools.
The app runs at {base_url}.

IMPORTANT: First, log in by navigating to {base_url}{login_path} — this will establish
a session and redirect you to the main page.

After logging in, systematically inspect these pages and take screenshots:

{for each page in pages_list}
### Page: {page_path}

Navigate to {base_url}{page_path}.

1. Take a full-page screenshot
2. Scroll through the entire page, taking screenshots of each major section
3. Try clicking interactive elements (buttons, drawers, expand/collapse, tabs)
4. Check browser console for errors
5. Note:
   - Layout and visual hierarchy
   - Information density — is it appropriate for expert users?
   - Whether actions/recommendations feel specific and actionable
   - Color usage, typography, spacing
   - Any accessibility concerns (missing labels, low contrast)
   - Any runtime errors or blank sections
{end for}

### Summary Requirements

For each page, provide a detailed report covering:

**Works Well:**
- Specific UI patterns that are effective
- Good information architecture decisions
- Appropriate use of progressive disclosure

**Needs Improvement:**
- Cluttered or confusing sections
- Missing context or labels
- Elements that don't drive user action
- Accessibility issues

**Bugs/Errors:**
- Console errors with full error messages
- Blank or crashed sections
- Broken links or buttons
- Missing data or undefined values

Use Playwright MCP tools as primary. Fall back to Chrome DevTools MCP if Playwright
is unavailable. Take screenshots for evidence of each significant finding.
```

---

## Variable Substitution

| Variable | Source | Fallback |
|----------|--------|----------|
| `{app_name}` | From AGENTS.md project name | "the application" |
| `{base_url}` | From Step 1 input `--url` | Required |
| `{login_path}` | From Step 1 input `--login-url` | Omit login step if not provided |
| `{pages_list}` | From Step 1 input `--pages` | Ask user |

---

## Tool Preference

The agent should use tools in this order:

1. **Playwright MCP** (`mcp__playwright__*`) — Best for navigation, screenshots, DOM inspection
2. **Chrome DevTools MCP** (`mcp__chrome-devtools__*`) — Fallback for console logs, network requests
3. **Manual observation** — If neither tool works, ask user to screenshot

## What to Look For (Feature-Specific)

Tailor the inspection based on what the feature does:

| Feature Type | Key Things to Check |
|-------------|-------------------|
| Recommendation system | Are recommendations specific? Do they have dollar amounts? Is there alert fatigue? |
| Data import wizard | Is each step clear? Error messages helpful? Progress visible? |
| Dashboard / metrics | Do metrics load? Are numbers formatted correctly? Color coding meaningful? |
| CRUD interface | Do all operations work? Validation messages clear? Empty states handled? |
| Report / PDF generation | Does the button work? Does the output download? Is it formatted well? |
| Search / filtering | Does search work? Are results relevant? Is the filter state visible? |
