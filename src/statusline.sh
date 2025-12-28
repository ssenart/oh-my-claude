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
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_file="$script_dir/.usage_cache"
cache_timeout=60
update_script="$script_dir/update-usage.sh"

# Check if cache exists and is fresh
if [ -f "$cache_file" ]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))
    if [ "$cache_age" -ge "$cache_timeout" ]; then
        # Cache expired, trigger background update (don't wait for it)
        bash "$update_script" &>/dev/null &
    fi
    # Always use cached data (even if slightly stale)
    # Read JSON cache
    if [ -f "$cache_file" ]; then
        session_tokens=$(jq -r '.code.session_tokens // 0' "$cache_file" 2>/dev/null)
        pro_five_hour_usage=$(jq -r '.pro.five_hour_pct // empty' "$cache_file" 2>/dev/null)
        pro_seven_day_usage=$(jq -r '.pro.seven_day_pct // empty' "$cache_file" 2>/dev/null)
        pro_five_hour_resets=$(jq -r '.pro.five_hour_resets_at // empty' "$cache_file" 2>/dev/null)
        pro_seven_day_resets=$(jq -r '.pro.seven_day_resets_at // empty' "$cache_file" 2>/dev/null)
    else
        session_tokens=""
        pro_five_hour_usage=""
        pro_seven_day_usage=""
        pro_five_hour_resets=""
        pro_seven_day_resets=""
    fi
else
    # No cache, trigger update and use empty data for now
    bash "$update_script" &>/dev/null &
    session_tokens=""
    pro_five_hour_usage=""
    pro_seven_day_usage=""
fi

# Format Code usage display (tokens only)
code_usage_display=""
if [ -n "$session_tokens" ] && [ "$session_tokens" != "0" ]; then
    # Format Code tokens in millions (M)
    if command -v bc >/dev/null 2>&1; then
        session_m=$(echo "scale=1; $session_tokens / 1000000" | bc | sed 's/\.0$//')
    else
        session_m=$(awk "BEGIN {val=$session_tokens/1000000; if(val==int(val)) printf \"%.0f\", val; else printf \"%.1f\", val}")
    fi
    code_usage_display="${session_m}M"
fi

# Format Pro usage display (separate)
pro_usage_display=""
if [ -n "$pro_five_hour_usage" ] && [ -n "$pro_seven_day_usage" ]; then
    pro_usage_display="5h:${pro_five_hour_usage}% 7d:${pro_seven_day_usage}%"
fi

# Format reset times display
reset_display=""
if [ -n "$pro_five_hour_resets" ] && [ -n "$pro_seven_day_resets" ]; then
    # Calculate time until 5-hour reset
    if command -v date >/dev/null 2>&1; then
        # Parse reset time (remove milliseconds for compatibility)
        five_hour_clean=$(echo "$pro_five_hour_resets" | sed 's/\.[0-9]*+/+/')
        seven_day_clean=$(echo "$pro_seven_day_resets" | sed 's/\.[0-9]*+/+/')

        # Get current time and reset time in seconds since epoch
        now_sec=$(date +%s)
        five_hour_sec=$(date -d "$five_hour_clean" +%s 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S%z" "$five_hour_clean" +%s 2>/dev/null)

        if [ -n "$five_hour_sec" ]; then
            # Calculate difference
            diff_sec=$((five_hour_sec - now_sec))

            if [ "$diff_sec" -gt 0 ]; then
                hours=$((diff_sec / 3600))
                mins=$(((diff_sec % 3600) / 60))
                five_hour_display="${hours}h${mins}min"
            else
                five_hour_display="resetting..."
            fi
        else
            five_hour_display="?"
        fi

        # Format 7-day reset time (day + time)
        seven_day_day=$(date -d "$seven_day_clean" "+%a" 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S%z" "$seven_day_clean" "+%a" 2>/dev/null)
        seven_day_time=$(date -d "$seven_day_clean" "+%H:%M" 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S%z" "$seven_day_clean" "+%H:%M" 2>/dev/null)

        if [ -n "$seven_day_day" ] && [ -n "$seven_day_time" ]; then
            seven_day_display="${seven_day_day}${seven_day_time}"
        else
            seven_day_display="?"
        fi

        reset_display="5h:${five_hour_display} 7d:${seven_day_display}"
    fi
fi

# Export variables for oh-my-posh
export CLAUDE_MODEL="$model"
export CLAUDE_DIR="$dir_name"
export CLAUDE_GIT_BRANCH="$git_branch"
export CLAUDE_GIT_STATUS="$git_status"
export CLAUDE_STYLE="$style"
export CLAUDE_CONTEXT="$context_pct"
export CLAUDE_CODE_USAGE="$code_usage_display"
export CLAUDE_PRO_USAGE="$pro_usage_display"
export CLAUDE_RESET="$reset_display"

# Path to oh-my-posh config file
config_file="$script_dir/claude-statusline.omp.json"

# Use oh-my-posh to render the status line with clean environment
env -i \
  CLAUDE_MODEL="$CLAUDE_MODEL" \
  CLAUDE_DIR="$CLAUDE_DIR" \
  CLAUDE_GIT_BRANCH="$CLAUDE_GIT_BRANCH" \
  CLAUDE_GIT_STATUS="$CLAUDE_GIT_STATUS" \
  CLAUDE_STYLE="$CLAUDE_STYLE" \
  CLAUDE_CONTEXT="$CLAUDE_CONTEXT" \
  CLAUDE_CODE_USAGE="$CLAUDE_CODE_USAGE" \
  CLAUDE_PRO_USAGE="$CLAUDE_PRO_USAGE" \
  CLAUDE_RESET="$CLAUDE_RESET" \
  PATH="$PATH" \
  oh-my-posh print primary --config "$config_file" --pwd "$cwd"
