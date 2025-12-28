#!/bin/bash
# Fetch Claude Code session usage using ccusage
# Uses npx ccusage - no Node.js global install required

# Check for required tools
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq not found" >&2
    exit 1
fi

# Debug mode flag
DEBUG=0
if [ "$1" = "--debug" ]; then
    DEBUG=1
fi

# Get current session usage from ccusage (total tokens only)
if [ $DEBUG -eq 1 ]; then
    echo "Fetching: npx ccusage blocks --active --json" >&2
fi

session_data=$(npx ccusage blocks --active --json 2>/dev/null)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "ERROR: ccusage command failed (exit code: $exit_code)" >&2
    exit 1
fi

if [ $DEBUG -eq 1 ]; then
    echo "Response:" >&2
    echo "$session_data" | jq . >&2
fi

# Extract total tokens for active session
session_tokens=$(echo "$session_data" | jq -r '.blocks[0].totalTokens // 0' 2>/dev/null)

# Validate we got a valid number
if ! [[ "$session_tokens" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not parse session tokens" >&2
    if [ $DEBUG -eq 1 ]; then
        echo "Expected: .blocks[0].totalTokens" >&2
    fi
    exit 1
fi

# Output just the token count
echo "$session_tokens"

if [ $DEBUG -eq 1 ]; then
    echo "" >&2
    echo "Code Usage:" >&2
    echo "  Session tokens: $session_tokens" >&2
fi
