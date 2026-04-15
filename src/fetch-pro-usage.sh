#!/bin/bash
# Fetch Claude Pro usage data using OAuth credentials
# Uses curl and jq - no Node.js dependencies

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Get script directory and version
script_dir=$(get_script_dir)
VERSION=$(get_version "$script_dir")
handle_version_flag "$1" "$VERSION"

# Check for required tools
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl not found" >&2
    exit 1
fi

# Extract access token from macOS keychain (preferred) or fall back to credentials file
KEYCHAIN_SERVICE="Claude Code-credentials"
CREDS_PATH="${HOME}/.claude/.credentials.json"

if security find-generic-password -s "$KEYCHAIN_SERVICE" -w &>/dev/null; then
    # Read from keychain — token never written to disk
    if command -v jq &>/dev/null; then
        ACCESS_TOKEN=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)
    else
        ACCESS_TOKEN=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null | grep -o '"accessToken":"[^"]*"' | sed 's/"accessToken":"\([^"]*\)"/\1/')
    fi
elif [ -f "$CREDS_PATH" ]; then
    # Fall back to credentials file if keychain entry is absent
    if command -v jq &>/dev/null; then
        ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDS_PATH" 2>/dev/null)
    else
        ACCESS_TOKEN=$(grep -o '"accessToken":"[^"]*"' "$CREDS_PATH" | sed 's/"accessToken":"\([^"]*\)"/\1/')
    fi
else
    echo "ERROR: No credentials found. Checked keychain ('$KEYCHAIN_SERVICE') and $CREDS_PATH" >&2
    echo "Please ensure Claude Code is authenticated." >&2
    exit 1
fi

# Verify we got a token
if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo "ERROR: Could not extract access token from credentials" >&2
    echo "Try re-authenticating with Claude Code." >&2
    exit 1
fi

# Debug mode flag
DEBUG=0
if [ "$1" = "--debug" ]; then
    DEBUG=1
fi

# OAuth API endpoint
url="https://api.anthropic.com/api/oauth/usage"

if [ $DEBUG -eq 1 ]; then
    echo "Fetching: $url" >&2
fi

# Make the request with OAuth Bearer token
response=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-code/2.0.32" \
    -H "anthropic-beta: oauth-2025-04-20" \
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
        echo "Response: $body" >&2
        echo "Troubleshoot: Re-authenticate with Claude Code" >&2
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
