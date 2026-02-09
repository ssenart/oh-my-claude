#!/usr/bin/env bats
# Tests for update-usage.sh

setup() {
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SRC_DIR="$PROJECT_ROOT/src"
    UPDATE_USAGE="$SRC_DIR/update-usage.sh"

    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
}

teardown() {
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
}

@test "update-usage.sh exists and is executable" {
    [ -f "$UPDATE_USAGE" ]
    [ -x "$UPDATE_USAGE" ]
}

@test "update-usage.sh --version returns version information" {
    run bash "$UPDATE_USAGE" --version

    [ "$status" -eq 0 ]
    [[ "$output" =~ ^oh-my-claude\ update-usage.sh\ version ]]
}

@test "update-usage.sh creates cache file with valid JSON" {
    skip "Requires mock scripts for fetch-code-usage.sh and fetch-pro-usage.sh"
}
