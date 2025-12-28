---
name: code-verification
description: Multi-agent code verification workflow using a main agent and sub-agent loop. Use when verifying code against requirements, acceptance criteria, or quality standards. Triggers on requests to verify, validate, or check code against specifications, checklists, or instructions.
---

# Code Verification Skill

Verify code against requirements using a main agent / sub-agent loop with structured feedback and automatic retry.

## Workflow Overview

```
1. Parse verification instructions into testable items
2. For each instruction:
   a. Pre-flight: Confirm instruction is testable
   b. Sub-agent: Verify if instruction is met
   c. If failed: Main agent attempts fix
   d. Repeat b-c up to 5 times or until success
   e. Update checklist with result
3. Generate verification report
```

## Step 1: Parse Verification Instructions

Extract each verification instruction into a discrete, testable item:

- **ID**: Unique identifier (e.g., `V-001`)
- **Instruction**: The requirement text
- **Test approach**: How to verify (file inspection, run tests, lint, type check, etc.)
- **Files involved**: Which files to examine
- **Requires Browser**: Whether the instruction needs Chrome DevTools MCP verification
  - Auto-detect from keywords: UI, render, display, visible, hidden, show, hide, click, hover, focus, blur, scroll, DOM, element, component, layout, responsive, style, CSS, color, font, screenshot, visual, appearance, console, error, warning, log, network, request, response, accessibility, a11y, ARIA, animation, transition, loading, performance
  - Mark as: `browser: true` or `browser: false`
- **Browser Verification Type** (if `browser: true`):
  - `DOM_INSPECTION` - Element presence, visibility, content, computed styles
  - `SCREENSHOT` - Visual appearance, layout verification
  - `CONSOLE` - Browser console errors, warnings, logs
  - `NETWORK` - API requests, responses, status codes
  - `PERFORMANCE` - Load times, Core Web Vitals
  - `ACCESSIBILITY` - ARIA attributes, semantic HTML, color contrast

## Step 2: Pre-flight Validation

Before the verification loop, confirm each instruction is testable:

- Instruction is specific and unambiguous
- Success criteria are clear
- Required files/resources exist

Flag untestable instructions immediately rather than attempting verification.

### Browser-Specific Pre-Flight

For instructions with `browser: true`:

1. **Check Chrome DevTools MCP availability**
   - If unavailable, mark instruction as BLOCKED with reason: "Chrome DevTools MCP not available"
   - Suggest: "Ensure Chrome DevTools MCP server is running and accessible"

2. **Verify dev server is running**
   - Check if configured dev server URL responds (e.g., `http://localhost:3000`)
   - If not running, attempt to start using configured command (e.g., `npm run dev`)
   - Wait for configured startup time before proceeding
   - If unable to start, mark as BLOCKED: "Dev server not accessible at {URL}"

3. **Confirm target route exists**
   - Navigate to the page specified in the instruction
   - If 404 or error, mark as BLOCKED: "Target route not found: {route}"

## Step 3: Sub-Agent Verification Protocol

Spawn a sub-agent to verify each instruction. The sub-agent MUST return structured output:

```
VERIFICATION RESULT
-------------------
Instruction ID: [ID]
Status: PASS | FAIL | BLOCKED
Location: [file:line or "N/A"]
Severity: BLOCKING | MINOR
Finding: [What was found]
Expected: [What was expected]
Suggested Fix: [Specific fix recommendation]
```

Sub-agent rules:
- Check ONLY the specific instruction assigned
- Do not attempt fixes—report findings only
- Be precise about location (file, line number, function name)
- Distinguish between blocking failures and minor issues

### Browser-Enhanced Verification Output

For instructions with `browser: true`, the sub-agent MUST use Chrome DevTools MCP and return this extended format:

```
BROWSER VERIFICATION RESULT
---------------------------
Instruction ID: [ID]
Status: PASS | FAIL | BLOCKED
Verification Type: DOM | VISUAL | CONSOLE | NETWORK | PERFORMANCE | ACCESSIBILITY
URL Tested: [URL navigated to]
Viewport: [width]x[height]

Finding: [What was observed in the browser]
Expected: [What was expected]

--- DOM Details (if DOM inspection) ---
Selector: [CSS selector or data-testid used]
Element Found: Yes | No
Element Visible: Yes | No | N/A
Element Content: [text content or "N/A"]
Computed Styles: [relevant CSS properties if checking styles]

--- Screenshot (if visual check) ---
Screenshot Path: [path to captured screenshot]
Visual Description: [description of what's shown]

--- Console (if console check) ---
Errors: [count and messages]
Warnings: [count and messages]
Relevant Logs: [any logs matching the criterion]

--- Network (if network check) ---
Request URL: [API endpoint called]
Method: [GET/POST/etc]
Status: [response status code]
Response Summary: [brief response description]

--- Performance (if timing check) ---
Page Load Time: [ms]
LCP: [Largest Contentful Paint in ms]
FID: [First Input Delay in ms]
CLS: [Cumulative Layout Shift score]

--- Accessibility (if a11y check) ---
ARIA Attributes: [present/missing]
Semantic HTML: [proper usage assessment]
Color Contrast: [pass/fail]
Keyboard Navigation: [accessible/issues found]

Suggested Fix: [Specific fix recommendation]
```

#### Browser Sub-Agent Rules

In addition to standard sub-agent rules, browser verification sub-agents MUST:
- Start with a screenshot of the initial state
- Use stable selectors (prefer `data-testid` over complex CSS paths)
- Wait for dynamic content to load before inspecting DOM
- Capture console output before and after actions
- Take "after" screenshots when verifying interactive behavior
- Test at default viewport unless criterion specifies responsive/mobile

## Step 4: Main Agent Fix Protocol

When sub-agent reports FAIL:

1. **Review the finding** - Understand what failed and why
2. **Check fix history** - Do not repeat a previously attempted fix
3. **Apply targeted fix** - Make the minimum change to address the issue
4. **Log the attempt** - Record what was changed

### Fix attempt tracking

Maintain a fix log per instruction:

```
FIX LOG: [Instruction ID]
--------------------------
Attempt 1: [Description of change] → [Result]
Attempt 2: [Description of change] → [Result]
...
```

### Strategy escalation

- Attempts 1-2: Direct fix based on sub-agent suggestion
- Attempt 3: Try alternative approach
- Attempts 4-5: Broaden scope, consider architectural changes

If the same failure pattern repeats twice, explicitly try a different strategy.

### Browser-Specific Fix Strategies

When fixing browser verification failures:

**DOM/Visibility failures:**
- Check for conditional rendering logic
- Verify CSS display/visibility properties
- Check for z-index issues
- Verify data is being passed to component

**Console error failures:**
- Address JavaScript exceptions first
- Check for missing API mocks in tests
- Verify environment variables are set
- Check for CORS issues in development

**Network failures:**
- Verify API endpoints are correct
- Check authentication headers
- Verify request payload format
- Check for CORS configuration

**Visual/Screenshot failures:**
- Compare with baseline if available
- Check for CSS cascade issues
- Verify responsive breakpoints
- Check for font loading issues

**Performance failures:**
- Look for large bundle sizes
- Check for unoptimized images
- Verify lazy loading is working
- Check for render-blocking resources

**Accessibility failures:**
- Add missing ARIA attributes
- Fix color contrast issues
- Ensure proper heading hierarchy
- Add keyboard event handlers

## Step 5: Exit Conditions

Exit the verification loop when ANY condition is met:

| Condition | Action |
|-----------|--------|
| Sub-agent reports PASS | ✅ Check off instruction |
| 5 attempts exhausted | ❌ Mark failed with notes |
| Same failure 3+ times | ⚠️ Exit early, flag for review |
| Fix introduces regression | ⚠️ Revert, flag for review |
| Issue is MINOR severity | ⚠️ Note and continue |

## Step 6: Regression Check

After each fix attempt, verify:

- The targeted instruction (primary check)
- Any previously-passing related instructions (regression check)

If a fix breaks something else, revert and note the conflict.

### Browser Regression Checks

After each browser-related fix:

1. **Console regression**: Verify no new console errors introduced
2. **Visual regression**: Re-capture screenshots of affected pages
3. **Performance regression**: Re-check page load metrics if relevant
4. **Accessibility regression**: Re-run accessibility checks on modified components

If browser regression detected:
- Capture screenshots of before/after state
- Log the specific regression in the fix log
- Consider whether fix scope was too broad

## Step 7: Generate Verification Report

After all instructions are processed:

```
VERIFICATION REPORT
===================
Total Instructions: [N]
Passed: [N] ✅
Failed: [N] ❌
Needs Review: [N] ⚠️

DETAILS
-------
[V-001] ✅ [Instruction summary]
[V-002] ❌ [Instruction summary]
  - Failed after 5 attempts
  - Last error: [description]
  - Attempts: [brief log]
[V-003] ⚠️ [Instruction summary]
  - Flagged: Repeated same failure pattern
  - Recommendation: [suggestion]

AUDIT TRAIL
-----------
[Timestamp] V-001: Verified PASS on first check
[Timestamp] V-002: Attempt 1 - Changed X → FAIL
[Timestamp] V-002: Attempt 2 - Changed Y → FAIL
...

BROWSER VERIFICATION SUMMARY (if applicable)
--------------------------------------------
Total Browser Checks: [N]
Browser Checks Passed: [N] ✅
Browser Checks Failed: [N] ❌
Browser Checks Blocked: [N] ⚠️
Chrome DevTools MCP Status: Available | Unavailable
Dev Server Status: Running at [URL] | Not Running

Screenshots Captured:
- [V-001] screenshot-v001-initial.png
- [V-001] screenshot-v001-after-click.png
- [V-003] screenshot-v003-mobile-view.png

Console Issues Found:
- [V-002] Error: "Cannot read property 'map' of undefined" (app.js:45)

Network Issues Found:
- [V-004] 404 on GET /api/users

Performance Metrics:
- Page Load: 1.2s (target: <2s) ✅
- LCP: 0.8s (target: <2.5s) ✅
```

## Example

Given a checklist:
```
[ ] All functions have docstrings
[ ] No unused imports
[ ] Tests pass with >80% coverage
```

Workflow execution:
1. Parse into V-001, V-002, V-003
2. Pre-flight confirms all are testable
3. Sub-agent checks V-001 → FAIL (missing docstring in `utils.py:45`)
4. Main agent adds docstring
5. Sub-agent re-checks → PASS
6. Continue to V-002...
7. Final report shows 3/3 passed

## Key Principles

- **Structured feedback**: Sub-agent always returns actionable, located findings
- **No repeated fixes**: Track what was tried to avoid loops
- **Early exit**: Don't burn attempts on unfixable issues
- **Regression awareness**: Fixes shouldn't break other things
- **Audit everything**: The journey matters for debugging