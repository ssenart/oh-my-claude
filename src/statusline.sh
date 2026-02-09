#!/bin/bash
# Status line command for Claude Code with oh-my-posh integration

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Get script directory and version
script_dir=$(get_script_dir)
VERSION=$(get_version "$script_dir")
handle_version_flag "$1" "$VERSION"

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Calculate context percentage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    input_tokens=$(echo "$usage" | jq '.input_tokens // 0')
    cache_creation=$(echo "$usage" | jq '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$usage" | jq '.cache_read_input_tokens // 0')
    size=$(echo "$input" | jq '.context_window.context_window_size // 1')

    # Calculate current usage using awk (no bc dependency)
    current=$(awk "BEGIN {print $input_tokens + $cache_creation + $cache_read}")
    if [ "$size" != "0" ]; then
        pct=$(awk "BEGIN {printf \"%.0f\", $current * 100 / $size}")
    else
        pct=0
    fi

    context_pct="${pct}%"
else
    context_pct=""
fi

# Fetch usage data with automatic updates from ccusage
cache_file="$script_dir/.usage_cache"
cache_timeout=60
update_script="$script_dir/update-usage.sh"

# Check if cache exists and is fresh
if [ -f "$cache_file" ]; then
    cache_age=$(($(date +%s) - $(get_file_mtime "$cache_file")))
    [ "$cache_age" -ge "$cache_timeout" ] && bash "$update_script" &>/dev/null &

    # Read cache once and parse all values
    cache_json=$(cat "$cache_file" 2>/dev/null)
    session_tokens=$(echo "$cache_json" | jq -r '.code.session_tokens // 0')
    pro_five_hour_usage=$(echo "$cache_json" | jq -r '.pro.five_hour_pct // empty')
    pro_seven_day_usage=$(echo "$cache_json" | jq -r '.pro.seven_day_pct // empty')
    pro_five_hour_resets=$(echo "$cache_json" | jq -r '.pro.five_hour_resets_at // empty')
    pro_seven_day_resets=$(echo "$cache_json" | jq -r '.pro.seven_day_resets_at // empty')
else
    # No cache, trigger update and use empty data for now
    bash "$update_script" &>/dev/null &
    session_tokens=""
    pro_five_hour_usage=""
    pro_seven_day_usage=""
    pro_five_hour_resets=""
    pro_seven_day_resets=""
fi

# Format Code usage display (tokens only) - using only awk
code_usage_display=""
if [ -n "$session_tokens" ] && [ "$session_tokens" != "0" ]; then
    session_m=$(awk -v t="$session_tokens" 'BEGIN {v=t/1000000; printf(v==int(v)?"%.0f":"%.1f", v)}')
    code_usage_display="${session_m}M"
fi

# Format Pro usage display
pro_usage_display=""
if [ -n "$pro_five_hour_usage" ] && [ -n "$pro_seven_day_usage" ]; then
    pro_usage_display="5h:${pro_five_hour_usage}% 7d:${pro_seven_day_usage}%"
fi

# Format reset times display
reset_display=""
if [ -n "$pro_five_hour_resets" ] && [ -n "$pro_seven_day_resets" ]; then
    # Parse reset time (remove milliseconds for compatibility)
    five_hour_clean=$(echo "$pro_five_hour_resets" | sed 's/\.[0-9]*+/+/')
    seven_day_clean=$(echo "$pro_seven_day_resets" | sed 's/\.[0-9]*+/+/')

    # Get current time and reset time in seconds since epoch
    now_sec=$(date +%s)
    five_hour_sec=$(parse_date "$five_hour_clean")

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
    seven_day_day=$(format_date "+%a" "$seven_day_clean")
    seven_day_time=$(format_date "+%H:%M" "$seven_day_clean")

    if [ -n "$seven_day_day" ] && [ -n "$seven_day_time" ]; then
        seven_day_display="${seven_day_day}${seven_day_time}"
    else
        seven_day_display="?"
    fi

    reset_display="5h:${five_hour_display} 7d:${seven_day_display}"
fi

# Path to oh-my-posh config file
config_file="$script_dir/claude-statusline.omp.json"

# Use oh-my-posh to render the status line with clean environment
env -i \
  CLAUDE_MODEL="$model" \
  CLAUDE_CONTEXT="$context_pct" \
  CLAUDE_CODE_USAGE="$code_usage_display" \
  CLAUDE_PRO_USAGE="$pro_usage_display" \
  CLAUDE_RESET="$reset_display" \
  PATH="$PATH" \
  oh-my-posh print primary --config "$config_file" --pwd "$cwd"
