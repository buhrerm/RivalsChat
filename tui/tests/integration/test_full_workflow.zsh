#!/usr/bin/env zsh

# test_full_workflow.zsh - Integration tests
# Tests the complete workflow of the application

TEST_PASSED=0
TEST_FAILED=0

assert_not_empty() {
    local value=$1
    local test_name=$2

    if [[ -n "$value" ]]; then
        echo "✓ PASS: $test_name"
        ((TEST_PASSED++))
    else
        echo "✗ FAIL: $test_name"
        ((TEST_FAILED++))
    fi
}

setup() {
    # Source all required modules
    local script_dir="${(%):-%x:A:h}"
    local project_root="${script_dir}/../.."
    source "${project_root}/src/utils/constants.zsh"
    source "${project_root}/src/state/app_state.zsh"
    source "${project_root}/src/utils/clipboard.zsh"
    source "${project_root}/src/utils/config.zsh"
    source "${project_root}/src/lib/text_converter.zsh"
    source "${project_root}/src/lib/text_renderer.zsh"
    config_init
}

test_pattern_loading() {
    config_load_patterns
    assert_not_empty "${ALL_PATTERNS[Rainbow]}" "Patterns loaded successfully"
}

test_text_rendering() {
    config_load_patterns
    local result=$(generate_rainbow_preview "Test" "Rainbow")
    assert_not_empty "$result" "Text rendering produces output"
}

test_text_conversion() {
    config_load_patterns
    local result=$(text_to_rivals "Test" "Rainbow")
    assert_not_empty "$result" "Text conversion produces output"
}

run_tests() {
    echo "Running integration tests..."
    echo "===================================="

    setup
    test_pattern_loading
    test_text_rendering
    test_text_conversion

    echo "===================================="
    echo "Tests passed: $TEST_PASSED"
    echo "Tests failed: $TEST_FAILED"

    if [[ $TEST_FAILED -gt 0 ]]; then
        exit 1
    fi
}

run_tests
