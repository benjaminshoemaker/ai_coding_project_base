---
name: configure-verification
description: Configure verification commands for this project. Use when setting up a new project or when verification-config.json is missing or incomplete.
argument-hint: [project-directory]
allowed-tools: Read, Edit, Grep, Glob, Bash, AskUserQuestion
---

Configure `.claude/verification-config.json` with the project's actual commands
for tests, lint, typecheck, build, coverage, mutation testing, dev server, and authentication.

## Project Directory

Use the current working directory by default.

If `$1` is provided, treat `$1` as the working directory and read files under
`$1` instead.

## Context Detection

Determine working context:

1. If the working directory matches `*/features/*`:
   - PROJECT_ROOT = parent of parent of working directory
2. Otherwise:
   - PROJECT_ROOT = working directory

## Directory Guard

Confirm `PROJECT_ROOT` exists and is writable. If not, stop and ask for a valid
project directory.

## Check Browser Tool Availability

Before configuring, verify that browser verification tools are available.
Attempt harmless calls to detect installed MCPs (in priority order):

| Tool | Check Method | Install Instructions |
|------|--------------|---------------------|
| ExecuteAutomation Playwright | Check for `mcp__playwright__*` or `mcp__executeautomation__*` tools | `npx -y @executeautomation/playwright-mcp-server` |
| Browser MCP | Check for `mcp__browsermcp__*` tools | Install extension from browsermcp.io |
| Microsoft Playwright MCP | Check for `mcp__playwright__*` tools | `npx -y @anthropic-ai/mcp-server-playwright` |
| Chrome DevTools MCP | Call `mcp__chrome-devtools__list_pages` | Often pre-installed |

**Report availability:**

```
BROWSER TOOLS (in fallback order)
=================================
ExecuteAutomation Playwright: Available | Not detected  (recommended)
Browser MCP Extension: Available | Not detected
Microsoft Playwright MCP: Available | Not detected
Chrome DevTools MCP: Available | Not detected

{If none available}
WARNING: No browser MCP tools detected.
Browser verification will require manual verification.

To enable automated browser verification, add to .claude/settings.json:

{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    }
  }
}

NOTE: Avoid @playwright/mcp@latest — it includes unstable betas.
Use @executeautomation/playwright-mcp-server for stability.
```

Continue with configuration even if no browser tools are available (browser
verification will fall back to manual).

## Discovery (Read-Only)

Scan project documentation for commands and hints:
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `Makefile`
- `Taskfile.yml`
- `justfile`
- Any `docs/` or `scripts/` usage notes

Look for sections mentioning: tests, linting, type checking, build, coverage,
local dev server, authentication, and login routes.

Summarize any candidate commands you find.

## Configure Commands

If `.claude/verification-config.json` does not exist, create it with empty
fields. Then ask the human to confirm or provide commands for:

- Test command
- Lint command
- Typecheck command (if applicable)
- Build command (if applicable)
- Coverage command (if applicable)
- Mutation test command (optional, if used)
- Dev server command + URL + startup wait

If a command is not applicable, set it to an empty string and note it as
"not applicable" in the summary.

## Configure Authentication

Ask the human about authentication requirements:

1. "Does your app require login for browser verification?"
   - If NO: Set `auth.strategy` to `"none"` and skip remaining auth questions
   - If YES: Continue with auth configuration

2. "What authentication method does your app use?"

   Use AskUserQuestion:
   ```
   Question: "What authentication method does your app use?"
   Header: "Auth method"
   Options:
     - Label: "Email/Password (Recommended)"
       Description: "Standard login form with email and password fields"
     - Label: "Google OAuth"
       Description: "Sign in with Google button"
     - Label: "GitHub OAuth"
       Description: "Sign in with GitHub button"
   ```

### If Email/Password:

3. "What is the login route?" (default: `/login`)
   - Set `auth.loginRoute`

4. "What environment variable holds the test username/email?"
   - Default: `TEST_USER_EMAIL`
   - Set `auth.credentials.usernameVar`

5. "What environment variable holds the test password?"
   - Default: `TEST_USER_PASSWORD`
   - Set `auth.credentials.passwordVar`

6. Set `auth.strategy` to `"env"` and `auth.storageState` to
   `.claude/verification/auth-state.json`

### If Google or GitHub OAuth:

3. Set `auth.strategy` to `"oauth"` and `auth.provider` to `"google"` or `"github"`

4. Ask: "Would you like to complete OAuth setup now?"

   Use AskUserQuestion:
   ```
   Question: "Complete OAuth login now? You'll need your OAuth app credentials ready."
   Header: "OAuth setup"
   Options:
     - Label: "Yes, set up now (Recommended)"
       Description: "Run /oauth-login to complete OAuth flow and store tokens"
     - Label: "No, I'll do it later"
       Description: "Skip for now - run /oauth-login {provider} later"
   ```

   If YES: Invoke the `/oauth-login` skill with the selected provider.
   If NO: Continue without tokens (verification will fail until tokens are set up).

5. Set `auth.storageState` to `.claude/verification/auth-state.json`

## Configure Deployment Verification

Ask the human about deployment verification for browser tests:

1. **Detect Vercel project** by checking for:
   - `.vercel/project.json` (linked project)
   - `vercel.json` (Vercel config)
   - `package.json` scripts containing "vercel"

2. **If Vercel detected, ask:**

   Use AskUserQuestion:
   ```
   Question: "Do you deploy to Vercel and want to run browser tests against preview URLs?"
   Header: "Deployment"
   Options:
     - Label: "Yes, use preview URLs (Recommended)"
       Description: "Browser tests run against Vercel preview deployments (HTTPS, OAuth works)"
     - Label: "No, use localhost"
       Description: "Browser tests run against local dev server only"
   ```

3. **If Yes, ask about fallback behavior:**

   Use AskUserQuestion:
   ```
   Question: "How should we handle missing preview deployments?"
   Header: "Fallback"
   Options:
     - Label: "Fall back to localhost (Recommended)"
       Description: "If no preview URL found, use local dev server with a warning"
     - Label: "Block until deployment ready"
       Description: "Wait for deployment or fail verification if unavailable"
   ```

4. **Configure deployment settings:**

   ```json
   {
     "deployment": {
       "enabled": true,
       "service": "vercel",
       "useForBrowserVerification": true,
       "fallbackToLocal": true,
       "waitForDeployment": true,
       "deploymentTimeout": 300,
       "tokenVar": "VERCEL_TOKEN"
     }
   }
   ```

   | Setting | Default | Description |
   |---------|---------|-------------|
   | `enabled` | false | Enable deployment URL resolution |
   | `service` | "vercel" | Deployment service (currently only Vercel supported) |
   | `useForBrowserVerification` | true | Use preview URL for browser tests |
   | `fallbackToLocal` | true | Fall back to localhost if no preview |
   | `waitForDeployment` | true | Wait for deployment to be ready |
   | `deploymentTimeout` | 300 | Max seconds to wait for deployment |
   | `tokenVar` | "VERCEL_TOKEN" | Env var for Vercel auth token (CI/CD) |

5. **If No (localhost only):**

   Set `deployment.enabled` to `false` (or omit the section entirely).

## Ensure .gitignore Protection

If authentication is configured, verify `.env.verification` won't be committed:

1. Check if `.gitignore` exists in PROJECT_ROOT
2. Check if `.env.verification` is already listed
3. If not listed, **automatically add it**:

```bash
# Add to .gitignore if not present
if ! grep -q "^\.env\.verification$" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# Verification credentials (never commit)" >> .gitignore
  echo ".env.verification" >> .gitignore
  echo "Added .env.verification to .gitignore"
fi
```

4. Also ensure `.claude/verification/auth-state.json` is ignored:

```bash
if ! grep -q "\.claude/verification/auth-state\.json" .gitignore 2>/dev/null; then
  echo ".claude/verification/auth-state.json" >> .gitignore
  echo "Added auth-state.json to .gitignore"
fi
```

**CRITICAL:** If `.gitignore` doesn't exist and auth is configured, create it
with these entries before proceeding.

## Write Config

Update `.claude/verification-config.json` with all confirmed values.

Set `browser.tool` to `"auto"` (no user prompt needed — the browser-verification
skill will automatically detect and use the best available tool).

## Report

```
VERIFICATION CONFIGURED
=======================
Project Root: {path}

Browser Tools (in fallback order):
- ExecuteAutomation Playwright: {Available | Not detected} (recommended)
- Browser MCP Extension: {Available | Not detected}
- Microsoft Playwright MCP: {Available | Not detected}
- Chrome DevTools MCP: {Available | Not detected}

Commands:
- test: {value or ""}
- lint: {value or ""}
- typecheck: {value or ""}
- build: {value or ""}
- coverage: {value or ""}

Dev Server:
- command: {value or ""}
- url: {value or ""}
- startupSeconds: {value}

Authentication:
- strategy: {none | env | oauth}
- loginRoute: {value or "N/A"} (env strategy only)
- usernameVar: {value or "N/A"} (env strategy only)
- passwordVar: {value or "N/A"} (env strategy only)
- provider: {google | github | N/A} (oauth strategy only)
- tokens: {Configured | Not configured} (oauth strategy only)

Deployment Verification:
- enabled: {true | false}
- service: {vercel | N/A}
- useForBrowserVerification: {true | false}
- fallbackToLocal: {true | false}
- waitForDeployment: {true | false}
- deploymentTimeout: {value}s

Git Protection:
- .gitignore includes .env.verification: {Yes | Added | WARNING: No .gitignore}

Status: READY | READY WITH NOTES
Notes: {missing commands, auth setup needed, no browser tools, etc.}
```

## Post-Configuration Reminders

If email/password authentication was configured:

```
AUTHENTICATION SETUP REQUIRED
=============================
1. Copy .env.verification.example to .env.verification
2. Fill in TEST_USER_EMAIL and TEST_USER_PASSWORD
3. Verify .env.verification is in .gitignore (should be auto-added)
4. Run a browser verification to test login works
```

If OAuth was configured but tokens not set up:

```
OAUTH SETUP REQUIRED
====================
Run /oauth-login {provider} to complete OAuth setup.

You will need:
1. OAuth app credentials (Client ID and Secret)
2. Redirect URI configured: http://localhost:3847/oauth/callback

For Google: https://console.cloud.google.com/apis/credentials
For GitHub: https://github.com/settings/developers
```

If no browser tools detected:

```
BROWSER VERIFICATION NOTE
=========================
No browser MCP tools were detected. Browser-based acceptance criteria
will require manual verification until a browser MCP is configured.

Recommended: Add Playwright MCP to your Claude settings.
```

If deployment verification was configured:

```
DEPLOYMENT VERIFICATION CONFIGURED
==================================
Browser tests will run against Vercel preview deployments.

How it works:
1. Push changes to trigger Vercel deployment
2. Run /phase-checkpoint — it resolves the preview URL automatically
3. Browser tests run against the preview (HTTPS, OAuth callbacks work)

Fallback: {Enabled - will use localhost if no preview | Disabled - will block}

To test manually:
1. Push your branch to GitHub
2. Wait for Vercel deployment (check dashboard or `vercel ls`)
3. Run /phase-checkpoint to verify against preview
```
