#!/bin/bash
# Status line command for Claude Code with oh-my-posh integration

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
style=$(echo "$input" | jq -r '.output_style.name')

# Calculate context percentage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    input_tokens=$(echo "$usage" | jq '.input_tokens // 0')
    cache_creation=$(echo "$usage" | jq '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$usage" | jq '.cache_read_input_tokens // 0')
    size=$(echo "$input" | jq '.context_window.context_window_size // 1')

    # Calculate current usage (sum of all input token types)
    if command -v bc >/dev/null 2>&1; then
        current=$(echo "$input_tokens + $cache_creation + $cache_read" | bc)
        if [ "$size" != "0" ]; then
            pct=$(echo "scale=0; $current * 100 / $size" | bc)
        else
            pct=0
        fi
    else
        current=$(awk "BEGIN {print $input_tokens + $cache_creation + $cache_read}")
        if [ "$size" != "0" ]; then
            pct=$(awk "BEGIN {printf \"%.0f\", $current * 100 / $size}")
        else
            pct=0
        fi
    fi

    context_pct="${pct}%"
else
    context_pct=""
fi

# Get basename of current directory
dir_name=$(basename "$cwd" 2>/dev/null || echo "$cwd" | sed 's/.*[\/\\]//')

# Get git branch and status if in a git repository
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

    # Check if repository is dirty (has uncommitted changes)
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        git_status="●"  # Dirty indicator
    else
        git_status="✓"  # Clean indicator
    fi
else
    git_branch=""
    git_status=""
fi

# Fetch usage data with automatic updates from ccusage
cache_file="$HOME/.claude/.usage_cache"
cache_timeout=60
update_script="$HOME/.claude/update-usage.sh"

# Check if cache exists and is fresh
if [ -f "$cache_file" ]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))
    if [ "$cache_age" -ge "$cache_timeout" ]; then
        # Cache expired, trigger background update (don't wait for it)
        bash "$update_script" &>/dev/null &
    fi
    # Always use cached data (even if slightly stale)
    # Format: session_pct:weekly_pct:session_tokens:weekly_tokens:five_hour_limit:weekly_limit
    cached_data=$(cat "$cache_file" 2>/dev/null || echo "::::::")
    session_usage=$(echo "$cached_data" | cut -d: -f1)
    weekly_usage=$(echo "$cached_data" | cut -d: -f2)
    session_tokens=$(echo "$cached_data" | cut -d: -f3)
    weekly_tokens=$(echo "$cached_data" | cut -d: -f4)
    five_hour_limit=$(echo "$cached_data" | cut -d: -f5)
    weekly_limit=$(echo "$cached_data" | cut -d: -f6)
else
    # No cache, trigger update and use empty data for now
    bash "$update_script" &>/dev/null &
    session_usage=""
    weekly_usage=""
    session_tokens=""
    weekly_tokens=""
    five_hour_limit=""
    weekly_limit=""
fi

# Format usage display with token counts
if [ -n "$session_usage" ] && [ -n "$weekly_usage" ] && [ -n "$session_tokens" ] && [ -n "$weekly_tokens" ]; then
    # Format tokens in millions (M)
    if command -v bc >/dev/null 2>&1; then
        session_m=$(echo "scale=1; $session_tokens / 1000000" | bc | sed 's/\.0$//')
        weekly_m=$(echo "scale=1; $weekly_tokens / 1000000" | bc | sed 's/\.0$//')
        session_limit_m=$(echo "scale=0; $five_hour_limit / 1000000" | bc)
        weekly_limit_m=$(echo "scale=0; $weekly_limit / 1000000" | bc)
    else
        session_m=$(awk "BEGIN {val=$session_tokens/1000000; if(val==int(val)) printf \"%.0f\", val; else printf \"%.1f\", val}")
        weekly_m=$(awk "BEGIN {val=$weekly_tokens/1000000; if(val==int(val)) printf \"%.0f\", val; else printf \"%.1f\", val}")
        session_limit_m=$(awk "BEGIN {printf \"%.0f\", $five_hour_limit/1000000}")
        weekly_limit_m=$(awk "BEGIN {printf \"%.0f\", $weekly_limit/1000000}")
    fi

    usage_display="5h:${session_usage}% (${session_m}M/${session_limit_m}M) W:${weekly_usage}% (${weekly_m}M/${weekly_limit_m}M)"
else
    usage_display=""
fi

# Export variables for oh-my-posh
export CLAUDE_MODEL="$model"
export CLAUDE_DIR="$dir_name"
export CLAUDE_GIT_BRANCH="$git_branch"
export CLAUDE_GIT_STATUS="$git_status"
export CLAUDE_STYLE="$style"
export CLAUDE_CONTEXT="$context_pct"
export CLAUDE_USAGE="$usage_display"

# Path to oh-my-posh config file
config_file="$HOME/.claude/claude-statusline.omp.json"

# Use oh-my-posh to render the status line with clean environment
env -i \
  CLAUDE_MODEL="$CLAUDE_MODEL" \
  CLAUDE_DIR="$CLAUDE_DIR" \
  CLAUDE_GIT_BRANCH="$CLAUDE_GIT_BRANCH" \
  CLAUDE_GIT_STATUS="$CLAUDE_GIT_STATUS" \
  CLAUDE_STYLE="$CLAUDE_STYLE" \
  CLAUDE_CONTEXT="$CLAUDE_CONTEXT" \
  CLAUDE_USAGE="$CLAUDE_USAGE" \
  PATH="$PATH" \
  oh-my-posh print primary --config "$config_file" --pwd "$cwd"
