#!/usr/bin/env bats
# Tests for statusline.sh

setup() {
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SRC_DIR="$PROJECT_ROOT/src"
    STATUSLINE="$SRC_DIR/statusline.sh"
}

@test "statusline.sh exists and is executable" {
    [ -f "$STATUSLINE" ]
    [ -x "$STATUSLINE" ]
}

@test "statusline.sh --version returns version information" {
    run bash "$STATUSLINE" --version

    [ "$status" -eq 0 ]
    [[ "$output" =~ ^oh-my-claude\ statusline.sh\ version\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "statusline.sh -v returns version information" {
    run bash "$STATUSLINE" -v

    [ "$status" -eq 0 ]
    [[ "$output" =~ ^oh-my-claude\ statusline.sh\ version ]]
}

@test "statusline.sh processes valid JSON input" {
    input='{"model":{"display_name":"Test Model"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}'

    run bash "$STATUSLINE" <<< "$input"

    [ "$status" -eq 0 ]
    # Output should contain ANSI color codes (oh-my-posh output)
    [[ "$output" =~ \[.*m ]]
}

@test "statusline.sh handles missing context_window" {
    input='{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"}}'

    run bash "$STATUSLINE" <<< "$input"

    [ "$status" -eq 0 ]
}

@test "statusline.sh calculates context percentage correctly" {
    # Test with 50% usage (100000 / 200000)
    input='{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":100000},"context_window_size":200000}}'

    run bash "$STATUSLINE" <<< "$input"

    [ "$status" -eq 0 ]
    # Output should contain 50% somewhere
    [[ "$output" =~ 50% ]]
}
