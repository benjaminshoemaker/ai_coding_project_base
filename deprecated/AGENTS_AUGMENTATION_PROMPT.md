# AGENTS.md Augmentation Prompt

Use this prompt to customize `AGENTS_BASE.md` for a new project. Copy everything below the line and provide it to Claude along with your project's `ONE_PAGER.md` and `DEV_SPEC.md` files.

---

## Prompt

I have an `AGENTS_BASE.md` file that provides general guidelines for AI agents working on my project. I need you to augment it with project-specific context.

Please review the attached `ONE_PAGER.md` and `DEV_SPEC.md` files, then update `AGENTS_BASE.md` by filling in all the `TODO` sections with project-specific information. Specifically:

### 1. Project Context Section

Fill in:
- **Tech stack**: Language, runtime version, test framework, package manager, and key dependencies with their purposes
- **File structure conventions**: How source code is organized, where tests live, naming conventions
- **State/data conventions**: Config file formats, data persistence approach, any special file handling rules

### 2. Mocking Policy Section

Add project-specific mocking requirements:
- What external services need to be mocked (APIs, databases, file systems, etc.)
- Any third-party SDKs that must never make real calls in tests
- How to handle tests that legitimately need real external access

### 3. Error Handling Section

Add project-specific error information:
- If there's a typed error hierarchy, list the error classes and when to use each
- Any project-specific error handling patterns
- Logging conventions for errors

### 4. Additional Sections (if needed)

Based on the project's tech stack and architecture, add any additional sections that would help an agent work effectively:
- Async/concurrency patterns
- State management conventions
- API design patterns
- Security considerations
- Performance considerations

### 4.5. Browser/UI Verification Section (if applicable)

If the project has a frontend, web UI, or browser-based components, add:

- **Dev server configuration**:
  - Command to start the development server (e.g., `npm run dev`)
  - Local URL where the app runs (e.g., `http://localhost:3000`)
  - Startup time needed before server is ready (in seconds)

- **Chrome DevTools MCP integration**:
  - Confirm Chrome DevTools MCP server is available in the agent's environment
  - List pages/routes that should be tested
  - Specify any authentication requirements for testing protected pages
  - Note any browser-specific requirements (viewport sizes, cookies, etc.)

- **UI verification patterns**:
  - CSS selectors or test IDs used for element targeting (e.g., prefer `data-testid`)
  - Screenshot comparison baseline location (if using visual regression)
  - Accessibility testing requirements (WCAG level, specific checks)
  - Performance thresholds (LCP, FID, CLS targets)

Example section for a React/Vite app:
```
## Browser Verification

### Dev Server
- **Command**: `npm run dev`
- **URL**: `http://localhost:5173`
- **Startup wait**: 5 seconds

### Chrome DevTools MCP
- Use for all acceptance criteria involving: UI, render, display, click, visual, DOM, style, console, network
- Target elements using `data-testid` attributes
- Capture screenshots for visual verification items

### Testing Routes
- `/` - Landing page
- `/dashboard` - Requires mock auth (see Mocking section)
- `/settings` - Form validation tests

### Accessibility
- WCAG 2.1 AA compliance required
- Test with screen reader simulation where applicable
```

### 5. Update .gitignore Patterns

Review the default `.gitignore` patterns and add any project-specific patterns (build outputs, cache directories, generated files, etc.)

### 6. Update "Repository docs" Section

If the project uses different or additional documentation files (multiple PROMPT_PLAN files, different naming conventions, etc.), update this section to match.

### Output

Produce a complete, updated `AGENTS.md` file with:
- All `TODO` placeholders replaced with real content
- The "Note" at the top removed (since it's now customized)
- Any additional sections needed for this specific project
- All generic content preserved

Do not remove any of the base guardrails, testing policies, or agent responsibilities—only add project-specific context to them where appropriate.

---

## Files to Attach

When using this prompt, attach:
1. `AGENTS_BASE.md` - The base template
2. `ONE_PAGER.md` - Your project's product definition
3. `DEV_SPEC.md` - Your project's technical specification

Optionally attach:
- Any existing code files that show established patterns
- `package.json`, `Cargo.toml`, `pyproject.toml`, or equivalent for dependency context
- Existing test files that show testing patterns
