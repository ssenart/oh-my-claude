#!/bin/bash
# Background script to update Claude usage cache using ccusage

cache_file="$HOME/.claude/.usage_cache"
config_file="$HOME/.claude/usage-limits.conf"

# Load configuration
if [ -f "$config_file" ]; then
    source "$config_file"
else
    # Default limits if config doesn't exist
    FIVE_HOUR_LIMIT=40000000
    WEEKLY_LIMIT=100000000
fi

# Get current 5-hour session usage from ccusage
session_data=$(npx ccusage blocks --active --json 2>/dev/null)
if [ $? -ne 0 ]; then
    # ccusage failed, don't modify cache
    exit 0
fi

# Extract total tokens for active session
session_tokens=$(echo "$session_data" | jq -r '.blocks[0].totalTokens // 0' 2>/dev/null)

# Get current weekly usage from ccusage
weekly_data=$(npx ccusage weekly --json 2>/dev/null)
if [ $? -ne 0 ]; then
    # ccusage failed, don't modify cache
    exit 0
fi

# Extract total tokens for current week (last entry in weekly array)
weekly_tokens=$(echo "$weekly_data" | jq -r '.weekly[-1].totalTokens // 0' 2>/dev/null)

# Calculate percentages
if command -v bc >/dev/null 2>&1; then
    session_pct=$(echo "scale=0; $session_tokens * 100 / $FIVE_HOUR_LIMIT" | bc)
    weekly_pct=$(echo "scale=0; $weekly_tokens * 100 / $WEEKLY_LIMIT" | bc)
else
    session_pct=$(awk "BEGIN {printf \"%.0f\", $session_tokens * 100 / $FIVE_HOUR_LIMIT}")
    weekly_pct=$(awk "BEGIN {printf \"%.0f\", $weekly_tokens * 100 / $WEEKLY_LIMIT}")
fi

# Validate we got valid numbers
if ! [[ "$session_pct" =~ ^[0-9]+$ ]] || ! [[ "$weekly_pct" =~ ^[0-9]+$ ]]; then
    # Invalid data, don't modify cache
    exit 0
fi

# Write to cache (format: session_pct:weekly_pct:session_tokens:weekly_tokens:five_hour_limit:weekly_limit)
mkdir -p "$(dirname "$cache_file")"
echo "${session_pct}:${weekly_pct}:${session_tokens}:${weekly_tokens}:${FIVE_HOUR_LIMIT}:${WEEKLY_LIMIT}" > "$cache_file"
