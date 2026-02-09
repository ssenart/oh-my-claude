#!/usr/bin/env bats
# Tests for fetch-pro-usage.sh

setup() {
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SRC_DIR="$PROJECT_ROOT/src"
    FETCH_PRO="$SRC_DIR/fetch-pro-usage.sh"
}

@test "fetch-pro-usage.sh exists and is executable" {
    [ -f "$FETCH_PRO" ]
    [ -x "$FETCH_PRO" ]
}

@test "fetch-pro-usage.sh --version returns version information" {
    run bash "$FETCH_PRO" --version

    [ "$status" -eq 0 ]
    [[ "$output" =~ ^oh-my-claude\ fetch-pro-usage.sh\ version ]]
}

@test "fetch-pro-usage.sh requires curl" {
    # Skip if curl is installed (can't test missing dependency)
    if command -v curl >/dev/null 2>&1; then
        skip "curl is installed - cannot test missing dependency"
    fi

    run bash "$FETCH_PRO"

    [ "$status" -ne 0 ]
    [[ "$output" =~ "curl not found" ]]
}

@test "fetch-pro-usage.sh checks for credentials file" {
    # Temporarily rename credentials if it exists
    if [ -f ~/.claude/.credentials.json ]; then
        skip "Credentials file exists - cannot test missing credentials"
    fi

    run bash "$FETCH_PRO"

    [ "$status" -ne 0 ]
    [[ "$output" =~ "credentials file not found" ]]
}
