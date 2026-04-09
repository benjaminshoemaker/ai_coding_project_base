# Feature Audit Input Gathering Options

AskUserQuestion option blocks for each input that isn't provided as an argument.

## Feature Spec Location

If `--spec` not provided:

```
Question: "Where is the feature specification?"
Header: "Feature Spec"
Options:
  - Label: "features/ directory"
    Description: "Look in the features/ directory for a FEATURE_SPEC.md"
  - Label: "Provide path"
    Description: "I'll type the path to the spec file"
  - Label: "No spec exists"
    Description: "Skip spec alignment checking"
```

If "features/ directory" selected, search:
```bash
find features/ -name "FEATURE_SPEC.md" -o -name "*.spec.md" 2>/dev/null
```
Present found files for selection.

## Execution Plan Location

If `--plan` not provided:

```
Question: "Is there an execution plan or implementation plan for this feature?"
Header: "Execution Plan"
Options:
  - Label: "~/.claude/plans/ directory"
    Description: "Look in the Claude plans directory"
  - Label: "Provide path"
    Description: "I'll type the path to the plan file"
  - Label: "No plan exists"
    Description: "Skip plan alignment checking"
```

If "plans directory" selected, list recent plan files:
```bash
ls -lt ~/.claude/plans/*.md 2>/dev/null | head -10
```

## Product Vision Docs

If `--vision` not provided:

```
Question: "Where are the product vision/principles documents?"
Header: "Product Vision"
Options:
  - Label: "docs/vision/"
    Description: "Standard location for vision docs"
  - Label: "Provide directory"
    Description: "I'll specify the directory"
  - Label: "No vision docs"
    Description: "Skip strategic alignment analysis"
```

Scan provided directory for: `VISION.md`, `PRODUCT_PRINCIPLES.md`, `PRODUCT_MAP.md`, `DOMAIN_GLOSSARY.md`

## Application URL

If `--url` not provided and `--skip-browser` not set:

```
Question: "What is the base URL of the running application?"
Header: "App URL"
Options:
  - Label: "http://localhost:4321"
    Description: "Astro dev server default"
  - Label: "http://localhost:3000"
    Description: "Next.js / React dev server default"
  - Label: "Provide URL"
    Description: "I'll type the URL"
  - Label: "Skip browser inspection"
    Description: "App isn't running — skip live UI audit"
```

## Pages to Inspect

If `--pages` not provided and browser inspection is enabled:

```
Question: "Which pages should I inspect for this feature? (comma-separated paths)"
Header: "Pages to Audit"
```

Let user type paths like `/overview, /communities/CRTET, /communities/CRTET/what-if/123`

## Login URL

If `--login-url` not provided and browser inspection is enabled:

```
Question: "Does the app have an auto-login endpoint for dev?"
Header: "Dev Login"
Options:
  - Label: "/api/dev/login"
    Description: "Standard KineticBI dev login endpoint"
  - Label: "Provide path"
    Description: "I'll type the login path"
  - Label: "No auto-login"
    Description: "App doesn't require auth or login is manual"
```
