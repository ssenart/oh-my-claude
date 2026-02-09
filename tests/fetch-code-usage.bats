#!/usr/bin/env bats
# Tests for fetch-code-usage.sh

setup() {
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SRC_DIR="$PROJECT_ROOT/src"
    FETCH_CODE="$SRC_DIR/fetch-code-usage.sh"
}

@test "fetch-code-usage.sh exists and is executable" {
    [ -f "$FETCH_CODE" ]
    [ -x "$FETCH_CODE" ]
}

@test "fetch-code-usage.sh --version returns version information" {
    run bash "$FETCH_CODE" --version

    [ "$status" -eq 0 ]
    [[ "$output" =~ ^oh-my-claude\ fetch-code-usage.sh\ version ]]
}

@test "fetch-code-usage.sh requires jq" {
    # Skip if jq is installed (can't test missing dependency)
    if command -v jq >/dev/null 2>&1; then
        skip "jq is installed - cannot test missing dependency"
    fi

    run bash "$FETCH_CODE"

    [ "$status" -ne 0 ]
    [[ "$output" =~ "jq not found" ]]
}

@test "fetch-code-usage.sh debug mode shows helpful output" {
    skip "Requires ccusage to be available"

    run bash "$FETCH_CODE" --debug

    # Debug mode should output to stderr
    [[ "$output" =~ "Fetching:" ]] || [[ "$output" =~ "ERROR:" ]]
}
