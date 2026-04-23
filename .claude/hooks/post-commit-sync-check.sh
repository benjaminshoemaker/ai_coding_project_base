#!/bin/bash
#
# Post-commit hook for toolkit sync notification
#
# When skills are modified, writes a marker file and displays a message.
# Claude (in the current session) will see this and prompt the user to sync.
#
# Installation:
#   ln -sf ../../.claude/hooks/post-commit-sync-check.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
#
# Or use the /install-hooks command to set up automatically.

# Colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Get the toolkit directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
realpath_safe() {
    local path="$1"
    if command -v realpath >/dev/null 2>&1; then
        realpath "$path" 2>/dev/null || true
        return
    fi
    python3 - "$path" <<'PY'
import os
import sys
try:
    print(os.path.realpath(sys.argv[1]))
except Exception:
    pass
PY
}
TOOLKIT_DIR_REAL="$(realpath_safe "$TOOLKIT_DIR")"

# Marker file to signal sync is needed
SYNC_MARKER="$TOOLKIT_DIR/.claude/sync-pending.json"

# Get files changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)

# Check for skill changes (only .claude/skills/ files trigger sync)
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/" || true)

# Determine whether downstream migration work is needed.
# Global-only projects resolve skills from ~/.claude/skills and do not need per-project skill sync.
detect_sync_needed() {
    local search_paths=()
    local project_list=""
    local found_legacy_resolution="0"

    if ! command -v jq >/dev/null 2>&1; then
        # Conservative fallback: if jq is unavailable, keep previous behavior.
        echo "1"
        return
    fi

    if [ -n "${TOOLKIT_SEARCH_PATH:-}" ]; then
        IFS=':' read -r -a search_paths <<< "$TOOLKIT_SEARCH_PATH"
    else
        search_paths=("$HOME/Projects")
    fi

    local search_path
    for search_path in "${search_paths[@]}"; do
        [ -d "$search_path" ] || continue

        while IFS= read -r version_file; do
            [ -f "$version_file" ] || continue

            local toolkit_location
            local toolkit_location_real
            local force_local
            local resolution
            local project_dir

            toolkit_location=$(jq -r '.toolkit_location // empty' "$version_file" 2>/dev/null)
            [ -n "$toolkit_location" ] || continue
            toolkit_location_real="$(realpath_safe "$toolkit_location")"

            if [ -n "$TOOLKIT_DIR_REAL" ] && [ -n "$toolkit_location_real" ]; then
                [ "$toolkit_location_real" = "$TOOLKIT_DIR_REAL" ] || continue
            else
                [ "$toolkit_location" = "$TOOLKIT_DIR" ] || continue
            fi

            force_local=$(jq -r '.force_local_skills // "null"' "$version_file" 2>/dev/null)
            resolution=$(jq -r '.skill_resolution // "local"' "$version_file" 2>/dev/null)
            project_dir=$(cd "$(dirname "$version_file")/.." && pwd)

            if [ "$force_local" = "true" ] || [ "$resolution" != "global" ]; then
                found_legacy_resolution="1"
                project_list="${project_list}${project_dir}\n"
            fi
        done < <(find "$search_path" -maxdepth 4 -name "toolkit-version.json" -path "*/.claude/*" 2>/dev/null)
    done

    if [ "$found_legacy_resolution" = "1" ]; then
        printf "1\n"
        printf "%b" "$project_list" | sed '/^$/d' | sort -u
    else
        echo "0"
    fi
}

# If skill files changed, only write a marker when some project still uses legacy local/mixed resolution.
if [ -n "$SKILL_CHANGES" ]; then
    SYNC_NEEDS_OUTPUT=$(detect_sync_needed)
    SYNC_NEEDED=$(echo "$SYNC_NEEDS_OUTPUT" | head -n1)
    PROJECTS_NEEDING_SYNC=$(echo "$SYNC_NEEDS_OUTPUT" | tail -n +2)

    if [ "$SYNC_NEEDED" = "1" ]; then
        # Get commit info
        COMMIT_HASH=$(git rev-parse HEAD)
        COMMIT_SHORT=$(git rev-parse --short HEAD)
        COMMIT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        # Count skills changed
        SKILL_COUNT=$(echo "$SKILL_CHANGES" | wc -l | tr -d ' ')
        PROJECT_COUNT=$(echo "$PROJECTS_NEEDING_SYNC" | sed '/^$/d' | wc -l | tr -d ' ')

        PROJECTS_JSON=$(
            echo "$PROJECTS_NEEDING_SYNC" \
            | sed '/^$/d; s/\\/\\\\/g; s/"/\\"/g; s/^/    "/; s/$/"/' \
            | paste -sd ',' - \
            | sed 's/,/,\n/g'
        )

        # Write marker file with sync details
        cat > "$SYNC_MARKER" << EOF
{
  "timestamp": "$COMMIT_TIME",
  "commit": "$COMMIT_HASH",
  "commit_short": "$COMMIT_SHORT",
  "skills_changed": [
$(echo "$SKILL_CHANGES" | sed 's/^/    "/; s/$/"/' | paste -sd ',' - | sed 's/,/,\n/g')
  ],
  "skill_count": $SKILL_COUNT,
  "projects_requiring_sync": [
${PROJECTS_JSON}
  ],
  "project_count": $PROJECT_COUNT
}
EOF

        echo ""
        echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│${NC}              ${YELLOW}TOOLKIT SYNC PENDING${NC}                          ${CYAN}│${NC}"
        echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${YELLOW}Skills modified in commit ${COMMIT_SHORT}:${NC}"
        echo "$SKILL_CHANGES" | sed 's/^/  /'
        echo ""
        if [ "$PROJECT_COUNT" -gt 0 ]; then
            echo -e "${GREEN}${PROJECT_COUNT} project(s) still use legacy local/mixed skill resolution.${NC}"
            echo "$PROJECTS_NEEDING_SYNC" | sed 's/^/  - /'
            echo ""
        fi
        echo -e "${GREEN}Target projects may need migration to global skills.${NC}"
        echo -e "${DIM}Claude will prompt you to run /update-target-projects.${NC}"
        echo ""
    else
        # No downstream legacy local/mixed projects: clear stale marker and avoid unnecessary prompts.
        rm -f "$SYNC_MARKER"
        echo ""
        echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│${NC}          ${GREEN}GLOBAL SKILL MODE DETECTED${NC}                         ${CYAN}│${NC}"
        echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${GREEN}Skills changed, but tracked projects are global-only.${NC}"
        echo -e "${DIM}No project skill sync marker created.${NC}"
        echo ""
    fi
fi

# Always exit 0 - this hook should never block commits
exit 0
