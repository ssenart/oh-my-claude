#!/usr/bin/env bats
# Tests for common.sh shared functions

# Setup - run before each test
setup() {
    # Get the project root directory
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SRC_DIR="$PROJECT_ROOT/src"

    # Load common functions
    source "$SRC_DIR/common.sh"

    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
}

# Teardown - run after each test
teardown() {
    # Clean up temporary directory
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
}

@test "get_version reads VERSION file from same directory" {
    echo "1.2.3" > "$TEST_TEMP_DIR/VERSION"

    result=$(cd "$TEST_TEMP_DIR" && get_version "$TEST_TEMP_DIR")

    [ "$result" = "1.2.3" ]
}

@test "get_version reads VERSION file from parent directory" {
    mkdir -p "$TEST_TEMP_DIR/subdir"
    echo "1.2.3" > "$TEST_TEMP_DIR/VERSION"

    result=$(cd "$TEST_TEMP_DIR/subdir" && get_version "$TEST_TEMP_DIR/subdir")

    [ "$result" = "1.2.3" ]
}

@test "get_version returns 'unknown' when VERSION file missing" {
    result=$(get_version "$TEST_TEMP_DIR")

    [ "$result" = "unknown" ]
}

@test "get_file_mtime returns timestamp for existing file" {
    touch "$TEST_TEMP_DIR/testfile"

    result=$(get_file_mtime "$TEST_TEMP_DIR/testfile")

    # Should be a number (Unix timestamp)
    [[ "$result" =~ ^[0-9]+$ ]]
}

@test "get_file_mtime returns 0 for non-existent file" {
    result=$(get_file_mtime "$TEST_TEMP_DIR/nonexistent")

    [ "$result" = "0" ]
}

@test "handle_version_flag exits with version message when --version passed" {
    run bash -c "source $SRC_DIR/common.sh; handle_version_flag '--version' '1.2.3'"

    [ "$status" -eq 0 ]
    [ "$output" = "oh-my-claude bash version 1.2.3" ]
}

@test "handle_version_flag exits with version message when -v passed" {
    run bash -c "source $SRC_DIR/common.sh; handle_version_flag '-v' '1.2.3'"

    [ "$status" -eq 0 ]
    [ "$output" = "oh-my-claude bash version 1.2.3" ]
}

@test "handle_version_flag does not exit when no version flag passed" {
    run bash -c "source $SRC_DIR/common.sh; handle_version_flag 'other' '1.2.3' && echo 'continued'"

    [ "$status" -eq 0 ]
    [ "$output" = "continued" ]
}

@test "parse_date parses ISO 8601 date to timestamp" {
    # Test a known date: 2024-01-01T00:00:00+00:00
    result=$(parse_date "2024-01-01T00:00:00+00:00")

    # Should be a Unix timestamp (number)
    [[ "$result" =~ ^[0-9]+$ ]]
}

@test "format_date formats timestamp correctly" {
    # Use a known timestamp and format it
    result=$(format_date "+%Y-%m-%d" "2024-01-01T00:00:00+00:00")

    # Should start with 2024-01 (exact day might vary with timezone)
    [[ "$result" =~ ^2024-01 ]]
}
