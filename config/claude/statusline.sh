#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
DIR_DISPLAY="${DIR/#$HOME/~}"
CONTEXT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Duration
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DURATION_MIN=$((DURATION_MS / 60000))

# Git status: branch + dirty file count
GIT_STATUS=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    DIRTY_COUNT=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ -n "$BRANCH" ]; then
        if [ "$DIRTY_COUNT" -gt 0 ]; then
            GIT_STATUS=" 🌿 ${BRANCH} ⚠️ ${DIRTY_COUNT}"
        else
            GIT_STATUS=" 🌿 ${BRANCH} ✓"
        fi
    fi
fi

# ============================================
# Claude Code Usage (API-based with caching)
# ============================================
CLAUDE_USAGE_CACHE="$HOME/.claude/usage-cache.json"
CLAUDE_CACHE_MAX_AGE=300  # 5 minutes

get_claude_usage() {
    local now=$(date +%s)
    local cache_valid=false

    # Check if cache exists and is fresh
    if [ -f "$CLAUDE_USAGE_CACHE" ]; then
        local cache_time=$(jq -r '.cached_at // 0' "$CLAUDE_USAGE_CACHE" 2>/dev/null)
        local age=$((now - cache_time))
        if [ "$age" -lt "$CLAUDE_CACHE_MAX_AGE" ]; then
            cache_valid=true
        fi
    fi

    if [ "$cache_valid" = false ]; then
        # Fetch fresh data from API
        local creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$creds" ]; then
            local token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ]; then
                local response=$(curl -s --max-time 3 \
                    -H "Authorization: Bearer $token" \
                    -H "User-Agent: claude-code/2.0.31" \
                    -H "anthropic-beta: oauth-2025-04-20" \
                    -H "Accept: application/json" \
                    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

                if [ -n "$response" ] && echo "$response" | jq -e '.seven_day' >/dev/null 2>&1; then
                    # Cache the response
                    echo "$response" | jq --arg now "$now" '. + {cached_at: ($now | tonumber)}' > "$CLAUDE_USAGE_CACHE" 2>/dev/null
                fi
            fi
        fi
    fi

    # Read from cache
    if [ -f "$CLAUDE_USAGE_CACHE" ]; then
        local util=$(jq -r '.seven_day.utilization // "?"' "$CLAUDE_USAGE_CACHE" 2>/dev/null)
        local reset=$(jq -r '.seven_day.resets_at // ""' "$CLAUDE_USAGE_CACHE" 2>/dev/null)

        # Format reset time with countdown
        local reset_display=""
        if [ -n "$reset" ] && [ "$reset" != "null" ]; then
            local reset_epoch
            local now_epoch=$(date +%s)

            # Convert ISO timestamp to epoch and local display
            if command -v gdate &>/dev/null; then
                reset_display=$(gdate -d "$reset" "+%a %H:%M" 2>/dev/null)
                reset_epoch=$(gdate -d "$reset" "+%s" 2>/dev/null)
            else
                # macOS date
                reset_display=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${reset%%.*}" "+%a %H:%M" 2>/dev/null)
                reset_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${reset%%.*}" "+%s" 2>/dev/null)
            fi

            # Calculate time remaining
            if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now_epoch" ]; then
                local diff=$((reset_epoch - now_epoch))
                local days=$((diff / 86400))
                local hours=$(((diff % 86400) / 3600))

                if [ "$days" -gt 0 ]; then
                    reset_display="${reset_display} (${days}d ${hours}h)"
                else
                    reset_display="${reset_display} (${hours}h)"
                fi
            fi
        fi

        # Round utilization to integer
        if [ "$util" != "?" ]; then
            util=$(printf "%.0f" "$util" 2>/dev/null || echo "$util")
        fi

        if [ -n "$reset_display" ]; then
            echo "${util}%→${reset_display}"
        else
            echo "${util}%"
        fi
    else
        echo "?"
    fi
}

CLAUDE_USAGE=$(get_claude_usage)

# Output format:
# [Model] ⏱️Xm | 📁 ~/path/to/dir 🌿branch✓ | Ctx:X% | CC:X%→Day
echo "[$MODEL] ⏱️ ${DURATION_MIN}m | 📁 ${DIR_DISPLAY}$GIT_STATUS | Ctx:${CONTEXT}% | CC:$CLAUDE_USAGE"
