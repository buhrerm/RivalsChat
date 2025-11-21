#!/usr/bin/env zsh

# test_clipboard.zsh - Unit tests for clipboard utilities

TEST_PASSED=0
TEST_FAILED=0

assert_true() {
    local condition=$1
    local test_name=$2

    if [[ $condition -eq 0 ]]; then
        echo "✓ PASS: $test_name"
        ((TEST_PASSED++))
    else
        echo "✗ FAIL: $test_name"
        ((TEST_FAILED++))
    fi
}

setup() {
    local script_dir="${(%):-%x:A:h}"
    local project_root="${script_dir}/../.."
    source "${project_root}/src/utils/constants.zsh"
    source "${project_root}/src/state/app_state.zsh"
    source "${project_root}/src/utils/clipboard.zsh"
}

test_clipboard_detection() {
    clipboard_detect
    # Just verify it doesn't crash
    assert_true 0 "Clipboard detection completes"
}

test_clipboard_available() {
    clipboard_detect
    if clipboard_available; then
        assert_true 0 "Clipboard is available"
    else
        echo "⚠ SKIP: No clipboard available on this system"
    fi
}

run_tests() {
    echo "Running clipboard utility tests..."
    echo "===================================="

    setup
    test_clipboard_detection
    test_clipboard_available

    echo "===================================="
    echo "Tests passed: $TEST_PASSED"
    echo "Tests failed: $TEST_FAILED"

    if [[ $TEST_FAILED -gt 0 ]]; then
        exit 1
    fi
}

run_tests
