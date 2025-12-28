#!/bin/bash
# Fetch Claude Pro usage data using sessionKey cookie from .env
# Uses curl and jq - no Node.js dependencies

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/.env"

# Check for required tools
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl not found" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq not found" >&2
    exit 1
fi

# Load credentials from .env
if [ ! -f "$env_file" ]; then
    echo "ERROR: .env file not found at $env_file" >&2
    exit 1
fi

SESSION_KEY=$(grep "^CLAUDE_SESSION_KEY=" "$env_file" | cut -d= -f2 | tr -d ' \r\n')
ORG_ID=$(grep "^CLAUDE_ORG_ID=" "$env_file" | cut -d= -f2 | tr -d ' \r\n')

if [ -z "$SESSION_KEY" ]; then
    echo "ERROR: CLAUDE_SESSION_KEY not found in .env" >&2
    echo "Add: CLAUDE_SESSION_KEY=sk-ant-sid01-..." >&2
    exit 1
fi

if [ -z "$ORG_ID" ]; then
    echo "ERROR: CLAUDE_ORG_ID not found in .env" >&2
    echo "Add: CLAUDE_ORG_ID=your-org-id" >&2
    exit 1
fi

# Debug mode flag
DEBUG=0
if [ "$1" = "--debug" ]; then
    DEBUG=1
fi

# Construct the API URL
url="https://claude.ai/api/organizations/${ORG_ID}/usage"

if [ $DEBUG -eq 1 ]; then
    echo "Fetching: $url" >&2
fi

# Make the request with sessionKey cookie and browser-like headers
response=$(curl -s -w "\n%{http_code}" \
    -H "Cookie: sessionKey=$SESSION_KEY" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Accept-Language: en-US,en;q=0.9" \
    -H "Referer: https://claude.ai/settings/usage" \
    -H "Origin: https://claude.ai" \
    -H "Sec-Fetch-Dest: empty" \
    -H "Sec-Fetch-Mode: cors" \
    -H "Sec-Fetch-Site: same-origin" \
    "$url" 2>/dev/null)

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ $DEBUG -eq 1 ]; then
    echo "HTTP $http_code" >&2
    echo "Response:" >&2
    echo "$body" | jq . >&2
fi

# Check for successful response
if [ "$http_code" != "200" ]; then
    echo "ERROR: HTTP $http_code" >&2
    if [ $DEBUG -eq 1 ]; then
        echo "$body" >&2
    fi
    exit 1
fi

# Parse the usage data
five_hour_pct=$(echo "$body" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
seven_day_pct=$(echo "$body" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
five_hour_resets=$(echo "$body" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
seven_day_resets=$(echo "$body" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)

if [ -z "$five_hour_pct" ] || [ -z "$seven_day_pct" ]; then
    echo "ERROR: Could not parse usage data" >&2
    if [ $DEBUG -eq 1 ]; then
        echo "Expected: .five_hour.utilization and .seven_day.utilization" >&2
    fi
    exit 1
fi

# Convert percentages to integers (remove decimal places)
five_hour_pct=${five_hour_pct%.*}
seven_day_pct=${seven_day_pct%.*}

# Output format: five_hour_pct|seven_day_pct|five_hour_resets|seven_day_resets
# Using pipe delimiter because timestamps contain colons
echo "${five_hour_pct}|${seven_day_pct}|${five_hour_resets}|${seven_day_resets}"

if [ $DEBUG -eq 1 ]; then
    echo "" >&2
    echo "Pro Usage:" >&2
    echo "  5-hour: ${five_hour_pct}% (resets at ${five_hour_resets})" >&2
    echo "  7-day:  ${seven_day_pct}% (resets at ${seven_day_resets})" >&2
fi
