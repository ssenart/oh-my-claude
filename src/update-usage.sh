#!/bin/bash
# Background script to update Claude usage cache using ccusage and Pro usage API

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_file="$script_dir/.usage_cache"

# Get current session usage from ccusage (if available)
session_tokens=""
if [ -f "$script_dir/fetch-code-usage.sh" ]; then
    session_tokens=$(bash "$script_dir/fetch-code-usage.sh" 2>/dev/null)
    if [ $? -ne 0 ] || ! [[ "$session_tokens" =~ ^[0-9]+$ ]]; then
        # ccusage failed or returned invalid data, don't modify cache
        exit 0
    fi
else
    # Script not found, don't modify cache
    exit 0
fi

# Get Claude Pro usage from web API (if available)
pro_five_hour_pct=""
pro_seven_day_pct=""
pro_five_hour_resets=""
pro_seven_day_resets=""

if [ -f "$script_dir/fetch-pro-usage.sh" ]; then
    # Try to fetch Pro usage data
    pro_data=$(bash "$script_dir/fetch-pro-usage.sh" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$pro_data" ]; then
        # Parse format: five_hour_pct|seven_day_pct|five_hour_resets|seven_day_resets
        pro_five_hour_pct=$(echo "$pro_data" | cut -d'|' -f1)
        pro_seven_day_pct=$(echo "$pro_data" | cut -d'|' -f2)
        pro_five_hour_resets=$(echo "$pro_data" | cut -d'|' -f3)
        pro_seven_day_resets=$(echo "$pro_data" | cut -d'|' -f4)
    fi
fi

# Write to cache in JSON format for clarity
mkdir -p "$(dirname "$cache_file")"

# Build Pro JSON object with reset times if available
if [ -n "$pro_five_hour_pct" ]; then
    pro_json=$(cat <<JSON_PRO
  "pro": {
    "five_hour_pct": ${pro_five_hour_pct},
    "five_hour_resets_at": "${pro_five_hour_resets}",
    "seven_day_pct": ${pro_seven_day_pct},
    "seven_day_resets_at": "${pro_seven_day_resets}"
  },
JSON_PRO
)
else
    pro_json='  "pro": null,'
fi

cat > "$cache_file" <<EOF
{
  "code": {
    "session_tokens": ${session_tokens}
  },
${pro_json}
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
