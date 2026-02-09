#!/bin/bash
# Common functions shared across oh-my-claude scripts

# Get the directory where the calling script is located
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Read VERSION file from script directory or parent (for development)
get_version() {
    local dir="$1"
    cat "$dir/VERSION" 2>/dev/null || cat "$dir/../VERSION" 2>/dev/null || echo "unknown"
}

# Handle --version/-v flag and exit if present
handle_version_flag() {
    if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
        echo "oh-my-claude $(basename "$0") version $2"
        exit 0
    fi
}

# Get file modification time (cross-platform: Linux and macOS)
get_file_mtime() {
    stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# Parse ISO 8601 date to Unix timestamp (cross-platform)
parse_date() {
    date -d "$1" +%s 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S%z" "$1" +%s 2>/dev/null
}

# Format Unix timestamp or ISO date string (cross-platform)
format_date() {
    local fmt="$1"
    local ts="$2"
    date -d "$ts" "$fmt" 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S%z" "$ts" "$fmt" 2>/dev/null
}
