---
name: setup
description: Initialize a new project with the AI Coding Toolkit. Use when setting up toolkit skills in a new or existing project.
argument-hint: [target-directory]
allowed-tools: Bash, Read, Write, AskUserQuestion
toolkit-only: true
---

Initialize a new project at `$1` with the AI Coding Toolkit.

## Steps

0. **Directory guard (must run from toolkit repo)**
   - Confirm `.toolkit-marker` exists in the current working directory
   - If it is missing, **STOP** and tell the user to `cd` into the `ai_coding_project_base` toolkit repo and re-run `/setup $1`

0.5. **Idempotency Check**

   Check if target already has toolkit installed:

   ```bash
   if [[ -f "$1/.claude/toolkit-version.json" ]]; then
     EXISTING_COMMIT=$(jq -r '.toolkit_commit' "$1/.claude/toolkit-version.json")
     CURRENT_COMMIT=$(git rev-parse HEAD)
   fi
   ```

   Decision logic:
   - If `toolkit-version.json` doesn't exist → proceed with **full setup** (existing flow)
   - If exists and `toolkit_commit` = current HEAD → report "Already up to date" and skip to Step 7 (success report)
   - If exists and `toolkit_commit` ≠ current HEAD → proceed with **incremental update** (Step 3a)

   Store the result as `SETUP_MODE`:
   - `SETUP_MODE=full` — new installation
   - `SETUP_MODE=current` — already up to date
   - `SETUP_MODE=incremental` — updating existing installation

1. **Validate target directory**
   - If `$1` is empty, ask the user for the target directory path
   - Check if the directory exists; if not, offer to create it

2. **Ask project type**
   - Greenfield: Starting a new project from scratch
   - Feature: Adding a feature to an existing project

2a. **For Feature type: Ask feature name and create directory**
    - Prompt: "What should this feature be called? (used as folder name, e.g., 'analytics-dashboard')"
    - Validate: lowercase, hyphens and underscores allowed, no spaces or special characters
    - Create `$1/features/` directory if it doesn't exist
    - Create `$1/features/<feature-name>/` directory
    - Store the feature path as `FEATURE_PATH` = `$1/features/<feature-name>`

3. **Validate global skills runtime (global-only policy)**

   Skills must resolve globally via `~/.claude/skills/`. Do not copy toolkit
   skills into `$1/.claude/skills/`.

   See [GLOBAL_SYNC.md](../update-target-projects/GLOBAL_SYNC.md) for helper definitions.

   **Validation checks:**
   ```bash
   GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
   TOOLKIT_ROOT="$(pwd)"

   if [[ ! -d "$GLOBAL_SKILLS_DIR" ]]; then
     echo "Missing global skills directory: $GLOBAL_SKILLS_DIR"
     exit 1
   fi

   MISSING_GLOBAL=0
   for skill_dir in .claude/skills/*/; do
     skill_name="$(basename "$skill_dir")"
     if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
       continue
     fi

     global_path="$GLOBAL_SKILLS_DIR/$skill_name"
     resolved=$(realpath "$global_path" 2>/dev/null || true)
     expected=$(realpath "$skill_dir" 2>/dev/null || true)
     if [[ ! -L "$global_path" || -z "$resolved" || "$resolved" != "$expected" ]]; then
       echo "  $skill_name — missing or incorrect global symlink"
       MISSING_GLOBAL=1
     fi
   done

   if [[ "$MISSING_GLOBAL" -ne 0 ]]; then
     echo "Global skills are not ready. Run ./scripts/sync-agent-skills.sh from the toolkit repo first."
     exit 1
   fi
   ```

   **Local shadow cleanup (required):**
   - If `$1/.claude/skills/` exists, treat it as legacy shadowing.
   - Back up modified local skills to `$1/.claude/skills.bak/`.
   - Remove toolkit-managed directories under `$1/.claude/skills/`.
   - Do not delete non-toolkit custom skills silently; report and ask first.

   Copy verification config (if missing):
   - `.claude/verification-config.json` → target's `.claude/verification-config.json`

   Also verify configuration file:
   ```bash
   test -f "$1/.claude/verification-config.json" && echo "Config: OK" || echo "Config: MISSING (non-critical)"
   ```

3b. **Copy workstream scripts to target**

   Copy `.workstream/` scripts from the toolkit to the target project:

   ```bash
   mkdir -p "$1/.workstream"
   for file in lib.sh setup.sh dev.sh verify.sh README.md workstream.json.example; do
     if [ -f ".workstream/$file" ]; then
       cp ".workstream/$file" "$1/.workstream/$file"
     fi
   done
   chmod +x "$1/.workstream/"*.sh 2>/dev/null || true
   ```

   **Do NOT copy `workstream.json`** — this is project-owned and created by the user.

   **Verify copies:**
   ```bash
   ls -la "$1/.workstream/" 2>/dev/null
   ```
   Confirm `setup.sh`, `dev.sh`, `verify.sh`, and `lib.sh` exist and are executable.
   Verify with `ls -la` that permissions include `+x` on all `.sh` files. If any script is missing or not executable, report the discrepancy.

3c. **Copy Codex App templates to target**

   Copy `.codex/` templates from the toolkit to the target project:

   ```bash
   mkdir -p "$1/.codex"
   cp ".codex/setup.sh" "$1/.codex/setup.sh"
   cp ".codex/AGENTS.md" "$1/.codex/AGENTS.md"
   chmod +x "$1/.codex/setup.sh"
   ```

   These are recommended defaults for Codex App integration. Users configure
   the setup script in Codex App Settings (Cmd+,) → Local Environments.

   **Verify Codex App copies:**
   - Verify with `ls -la "$1/.codex/setup.sh"` that the file exists and is executable.
   - Verify with `ls "$1/.codex/AGENTS.md"` that the file was copied.

3a. **Incremental Sync (When SETUP_MODE=incremental)**

   Skip Step 3 entirely and use this incremental approach instead.

   **Check resolution mode from existing config:**
   ```bash
   FORCE_LOCAL=$(jq -r '.force_local_skills // empty' "$1/.claude/toolkit-version.json")
   CURRENT_RESOLUTION=$(jq -r '.skill_resolution // "global"' "$1/.claude/toolkit-version.json")
   ```

   **Important:** Global-only policy applies:
   - `force_local_skills=true` is legacy-only and should be migrated to `false`.
   - Remove local shadow copies after backup if present.
   - Do not copy toolkit skills into `.claude/skills/` during incremental sync.

   Load the stored file hashes from `$1/.claude/toolkit-version.json`:
   ```bash
   STORED_HASHES=$(jq '.files' "$1/.claude/toolkit-version.json")
   ```

   **Hash calculation pattern** (used for all file comparisons in this step and below):
   ```bash
   # Compute SHA-256 hash of a file — used for toolkit, target, and stored hash comparisons
   file_hash() { shasum -a 256 "$1" | cut -d' ' -f1; }
   ```

   For each skill in the tracked list (excluding toolkit-only skills — check `SKILL.md` frontmatter for `toolkit-only: true`):

   1. Calculate toolkit file hash: `TOOLKIT_HASH=$(file_hash "$TOOLKIT_FILE")`
   2. Get stored hash from toolkit-version.json (hash at last sync)
   3. Validate global symlink points to this toolkit skill directory

   **Classification and Action:**

   | Condition | Classification | Action |
   |-----------|----------------|--------|
   | Global symlink valid | `GLOBAL_USABLE` | Keep global mode |
   | Local shadow copies exist | `ADOPT_GLOBAL` | Backup modified local copies, remove local shadowing |
   | Global symlink missing/broken | `GLOBAL_MISSING` | Stop and instruct bootstrap repair |
   | Stored hash differs from toolkit | `TOOLKIT_UPDATED` | Update hash metadata (global resolution remains) |

   Track counts for each classification and report summary:
   ```
   INCREMENTAL SYNC
   ================
   Global resolution: {count} skills (via ~/.claude/skills)
   Local shadows removed: {count}
   Missing/broken globals: {count} (must repair before completion)
   Metadata updated: {count}
   ```

   If any skills are `GLOBAL_MISSING`, list them:
   ```
   ERROR: These global skills are missing or misconfigured:
   - ~/.claude/skills/phase-start
   - ~/.claude/skills/fresh-start

   Repair with:
   ./scripts/sync-agent-skills.sh
   Then re-run /setup.
   ```

4. **Create or Update toolkit-version.json**

   **For full setup (SETUP_MODE=full):**

   Create `.claude/toolkit-version.json` in the target to enable future syncs.
   Use global-only resolution metadata:

   ```json
   {
     "schema_version": "1.1",
     "toolkit_location": "{absolute path to this toolkit}",
     "toolkit_commit": "{current git HEAD commit hash}",
     "toolkit_commit_date": "{commit date in ISO format}",
     "last_sync": "{current ISO timestamp}",
     "force_local_skills": false,
     "skill_resolution": "global",
     "files": {
       ".claude/skills/fresh-start/SKILL.md": {
         "hash": "{sha256 hash of file}",
         "synced_at": "{ISO timestamp}",
         "resolution": "global"
       }
       // ... entry for each skill
     }
   }
   ```

   **Resolution determination:**
   - Always set `"skill_resolution": "global"` for toolkit-managed projects.

   **Per-file resolution:**
   - All toolkit-managed skills should record `"resolution": "global"`.

   **For incremental update (SETUP_MODE=incremental):**

   Update the existing `toolkit-version.json`:
   - Update `toolkit_commit` to current HEAD
   - Update `toolkit_commit_date` to current commit date
   - Update `last_sync` to current timestamp
   - Set `force_local_skills` to `false` when present
   - Update each tracked skill file `hash`, `synced_at`, and `resolution: "global"`
   - Set `skill_resolution` to `"global"`

   **For already current (SETUP_MODE=current):**

   Skip this step entirely.

   **Get toolkit info:**
   ```bash
   TOOLKIT_PATH=$(pwd)
   COMMIT_HASH=$(git rev-parse HEAD)
   COMMIT_DATE=$(git log -1 --format=%cI HEAD)
   ```

   **Calculate file hashes** using the `file_hash()` pattern defined in Step 3a.

   **Include entries for ALL files in non-toolkit-only skill directories:**
   ```bash
   # Hash every .md file in every skill directory (skip toolkit-only)
   for skill_dir in .claude/skills/*/; do
     # Skip toolkit-only skills (parse YAML frontmatter between --- markers)
     if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
       continue
     fi
     for file in "$skill_dir"*.md; do
       [[ -f "$file" ]] || continue
       hash=$(file_hash "$file")
       # Add entry for "$file" with hash and timestamp
     done
   done
   ```

   This ensures skills with supporting files (e.g., `audit-skills/CRITERIA.md`,
   `audit-skills/SCORING.md`) are tracked for conflict detection.

   **Skills with `toolkit-only: true` in frontmatter are NOT distributed or tracked.**
   These run only from the toolkit directory (e.g., setup, update-target-projects).

   **Verify toolkit-version.json:** Read back the file with `cat "$1/.claude/toolkit-version.json" | python3 -m json.tool` (or `jq .`) to confirm it contains valid JSON and the `toolkit_commit` field matches the expected value.

5. **Create CLAUDE.md if it doesn't exist**

   Create a minimal CLAUDE.md that references AGENTS.md:
   ```
   @AGENTS.md
   ```

   **Verify CLAUDE.md:** Read back `$1/CLAUDE.md` to confirm it was written correctly and contains the `@AGENTS.md` reference.

6. **Cross-Agent Runtime Bootstrap (Optional)**

   Check if OpenAI Codex CLI is installed:
   ```bash
   command -v codex >/dev/null 2>&1
   ```

   If Codex is detected:
   - Use AskUserQuestion to prompt:
     ```
     Question: "Codex CLI detected. Bootstrap shared runtime now? (skills + MCPs for Claude and Codex)"
     Options:
       - "Yes, bootstrap" — Run toolkit bootstrap for cross-agent skills + MCP sync
       - "No, skip" — Skip machine-level runtime setup
     ```

   If user selects "Yes, bootstrap":
   - Run from this toolkit directory:
     ```bash
     ./scripts/bootstrap-agent-runtime.sh
     ```
   - Verify with `ls -la ~/.claude/skills ~/.agents/skills ~/.codex/skills` that skill paths are configured.
   - Verify with `./scripts/sync-agent-mcps.sh --check` that MCP manifest entries are valid and planned correctly.
   - Report the bootstrap result

   If Codex is not detected:
   - Skip silently (don't mention Codex to users who don't have it)

   **Why this matters:** One command keeps machine-level skills and MCPs aligned across Claude Code and Codex.

6a. **Legacy Codex-Only MCP Path (Backward Compatibility)**

   If a user explicitly asks for Codex-only MCP setup, run:
   ```bash
   ./scripts/configure-codex-mcp.sh
   ```
   This now delegates to the shared MCP manifest flow and applies settings only to Codex.

7. **Report success and next steps**

   **For SETUP_MODE=current (already up to date):**
   ```
   ALREADY UP TO DATE
   ==================
   Target: $1
   Toolkit commit: {COMMIT_HASH} ({COMMIT_DATE})

   No changes needed — toolkit files are current.
   ```

   **For SETUP_MODE=incremental (updated existing):**
   ```
   TOOLKIT UPDATED
   ===============
   Target: $1
   Previous commit: {OLD_COMMIT_HASH}
   Current commit:  {COMMIT_HASH}

   {Summary from Step 3a showing files synced/skipped}

   All toolkit skills are now up to date.
   ```

   **For SETUP_MODE=full, Greenfield:**
   ```
   TOOLKIT INITIALIZED
   ===================
   Target: $1
   Skill resolution: global ({GLOBAL_COUNT} skills via ~/.claude/skills)

   Next steps (run from your project directory):
   1. cd $1
   2. /product-spec
   3. /technical-spec
   4. /generate-plan
   5. cd plans/greenfield
   6. /fresh-start
   7. /configure-verification
   8. /phase-prep 1
   9. /phase-start 1
   ```

   **Skill resolution line example:**
   - `Skill resolution: global (30 skills via ~/.claude/skills symlinks)`

   **For SETUP_MODE=full, Feature:**
   ```
   TOOLKIT INITIALIZED
   ===================
   Target: $1
   Feature directory: FEATURE_PATH

   Next steps (run from your project directory):
   1. cd $1
   2. /feature-spec <feature-name>
   3. /feature-technical-spec <feature-name>
   4. /feature-plan <feature-name>
   5. cd features/<feature-name>
   6. /fresh-start
   7. /configure-verification
   8. /phase-prep 1
   9. /phase-start 1
   ```

## Important

- This skill must be run from the ai_coding_project_base toolkit directory
- All other skills (`/product-spec`, `/technical-spec`, `/generate-plan`, `/feature-spec`, `/feature-technical-spec`, `/feature-plan`, and execution skills) run from the target project directory
- Only `/setup` and `/update-target-projects` run from the toolkit
- Use `cp -r` for directory copies to preserve structure
- Do not overwrite existing files without asking

## Error Handling

| Situation | Action |
|-----------|--------|
| Target directory does not exist and `mkdir -p` fails | Report permission error, suggest creating manually, exit without partial state |
| Global skill validation fails (`~/.claude/skills` missing/broken) | STOP immediately, report missing skills, and instruct user to run `./scripts/sync-agent-skills.sh` |
| `toolkit-version.json` write fails or produces invalid JSON | Complete file copies (primary goal), warn that incremental syncs will not work, suggest checking `.claude/` directory permissions |
| Codex CLI skill installation fails | Do NOT fail the entire setup; report the error and continue with remaining steps |
| Global symlink check fails (broken symlinks in `~/.claude/skills/`) | STOP and repair global symlinks; do not fall back to project-local copies |

## When Setup Cannot Complete

**If legacy local skills are detected during incremental sync:**
- List locally shadowed skills
- Back up modified local skills to `.claude/skills.bak/`
- Remove toolkit-managed local copies
- Keep untracked project-specific custom skills only with explicit user confirmation

**If target directory doesn't exist and can't be created:**
- Report: "Cannot create directory: {path}"
- Check parent directory permissions
- Suggest: Create manually with `mkdir -p {path}`
- Exit cleanly without partial state

**If Codex CLI skill installation fails:**
- Do NOT fail the entire setup
- Report: "Codex skill installation failed: {error}"
- Continue with rest of setup
- Note at end: "Codex skills not installed. Run `./scripts/install-codex-skill-pack.sh` manually."

**If toolkit-version.json cannot be written:**
- Report: "Cannot write toolkit-version.json"
- Complete non-skill setup files (`.workstream`, `.codex`, config) as possible
- Warn: "Future incremental syncs will not work until version file is created"
- Suggest: Check .claude/ directory permissions
