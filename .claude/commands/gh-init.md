---
description: Initialize git repo and push to GitHub. Use when starting a new project that needs a GitHub repository.
argument-hint: [target-directory]
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion
---

Initialize a git repository with smart project detection and optional GitHub remote creation.

## Usage

```
/gh-init              # Initialize in current directory
/gh-init ./my-project # Initialize in specified directory
```

## Steps

Copy this checklist and track progress:

```
GitHub Init Progress:
- [ ] Step 1: Determine target directory
- [ ] Step 2: Check existing git status
- [ ] Step 3: Detect project type
- [ ] Step 4: Generate .gitignore
- [ ] Step 5: Initialize git repository
- [ ] Step 6: Create GitHub remote
```

### 1. Determine Target Directory

- If `$1` is provided, use that directory
- Otherwise, use the current working directory
- Verify the directory exists; if not, **STOP** with an error

### 2. Check for Existing Git Repository

```bash
git -C <target> rev-parse --git-dir 2>/dev/null
```

- If git repo already exists, report: "Git repository already initialized at <target>"
- Offer: "Would you like to create a GitHub remote?" and skip to Step 5

### 3. Detect Project Type

Check for marker files to determine project type:

| File Found | Project Type |
|------------|--------------|
| `package.json` | Node.js |
| `requirements.txt` OR `pyproject.toml` OR `setup.py` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| (none detected) | Generic |

Report: "Detected: {Project Type} project (found {marker file})"

### 4. Create .gitignore

Create or update `.gitignore` based on project type.

**Always include (all project types):**
```gitignore
# Environment and secrets
.env
.env.*
!.env.example
**/credentials*
**/*.pem
**/*.key

# Claude Code local settings
.claude/settings.local.json
.claude/verification/auth-state.json

# OS files
.DS_Store
Thumbs.db
```

**Node.js additions:**
```gitignore
# Dependencies
node_modules/

# Build outputs
dist/
build/
.next/
out/

# Cache
.npm/
.eslintcache
.parcel-cache/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Testing
coverage/
.nyc_output/
```

**Python additions:**
```gitignore
# Byte-compiled
__pycache__/
*.py[cod]
*$py.class
*.so

# Virtual environments
venv/
.venv/
env/
.env/
ENV/

# Distribution
dist/
build/
*.egg-info/
.eggs/

# Cache
.pytest_cache/
.mypy_cache/
.ruff_cache/
```

**Rust additions:**
```gitignore
# Build
target/

# Cargo.lock only for libraries
# Cargo.lock  # Uncomment if this is a library
```

**Go additions:**
```gitignore
# Binaries
bin/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Vendor (if not committed)
# vendor/
```

**Ruby additions:**
```gitignore
# Gems
vendor/bundle/
.bundle/

# Environment
.ruby-version
.ruby-gemset
```

**PHP additions:**
```gitignore
# Dependencies
vendor/

# Environment
.phpunit.result.cache
```

If `.gitignore` already exists:
- Read existing content
- Append missing patterns (don't duplicate)
- Report what was added

### 5. Initialize Git Repository

```bash
cd <target>
git init
git add .
git commit -m "Initial commit"
```

Report:
```
✓ Git repository initialized
✓ Created .gitignore ({count} patterns)
✓ Initial commit created
```

### 6. Offer GitHub Remote Creation

Use AskUserQuestion:
```
Question: "Create GitHub remote repository?"
Options:
  - "Yes, public" — Create a public repository on GitHub
  - "Yes, private" — Create a private repository on GitHub
  - "No, done" — Skip GitHub remote creation
```

If user selects a GitHub option:

1. **Determine repository name:**
   - Default to directory name
   - Ask: "Repository name? (default: {dirname})"

2. **Create repository:**
   ```bash
   gh repo create <name> --public  # or --private
   ```

3. **Push to remote:**
   ```bash
   git push -u origin main
   ```

4. **Report success:**
   ```
   ✓ GitHub repository created: https://github.com/{user}/{name}
   ✓ Pushed to origin/main
   ```

If `gh` CLI is not installed or not authenticated:
```
GitHub CLI (gh) not available or not authenticated.
To set up later:
  1. Install: https://cli.github.com/
  2. Authenticate: gh auth login
  3. Create repo: gh repo create <name> --public
  4. Push: git push -u origin main
```

## Output Format

```
GIT INIT
========

Target: /path/to/project
Detected: Node.js project (found package.json)

Creating .gitignore...
  - Added: node_modules/
  - Added: dist/
  - Added: .env*
  - Added: .claude/settings.local.json
  ... (15 patterns total)

Initializing repository...
  ✓ git init
  ✓ git add .
  ✓ git commit -m "Initial commit"

✓ Git repository initialized with 1 commit.

[If GitHub selected]
Creating GitHub repository...
  ✓ Repository created: https://github.com/user/project
  ✓ Pushed to origin/main

Done!
```

## Integration Notes

This command can be invoked by other commands when they detect no git repository:

- `/fresh-start` — If no `.git`, suggest: "Run /gh-init to initialize git repository"
- `/phase-prep` — If no `.git`, show as blocking item: "Git repository not initialized. Run /gh-init to resolve."
