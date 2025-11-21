#!/usr/bin/env zsh

# test_text_converter.zsh - Unit tests for text conversion
# Tests the text_to_rivals conversion function

# Test framework setup
TEST_PASSED=0
TEST_FAILED=0

assert_equals() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if [[ "$expected" == "$actual" ]]; then
        echo "✓ PASS: $test_name"
        ((TEST_PASSED++))
    else
        echo "✗ FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TEST_FAILED++))
    fi
}

# Setup test environment
setup() {
    local script_dir="${(%):-%x:A:h}"
    local project_root="${script_dir}/../.."
    # Source the module under test
    source "${project_root}/src/utils/constants.zsh"
    source "${project_root}/src/state/app_state.zsh"
    source "${project_root}/src/lib/text_converter.zsh"

    # Initialize test patterns
    typeset -gA ALL_PATTERNS
    ALL_PATTERNS["TestPattern"]="R B G"
    REPEAT_MODE=0
    SYMMETRY_MODE=0
}

# Test basic conversion
test_basic_conversion() {
    local result=$(text_to_rivals "ABC" "TestPattern")
    assert_equals "#RA#BB#GC" "$result" "Basic text conversion"
}

# Test with spaces
test_conversion_with_spaces() {
    local result=$(text_to_rivals "A B" "TestPattern")
    assert_equals "#RA #BB" "$result" "Conversion preserves spaces"
}

# Test empty string
test_empty_string() {
    local result=$(text_to_rivals "" "TestPattern")
    assert_equals "" "$result" "Empty string returns empty"
}

# Run all tests
run_tests() {
    echo "Running text_converter unit tests..."
    echo "===================================="

    setup
    test_basic_conversion
    test_conversion_with_spaces
    test_empty_string

    echo "===================================="
    echo "Tests passed: $TEST_PASSED"
    echo "Tests failed: $TEST_FAILED"

    if [[ $TEST_FAILED -gt 0 ]]; then
        exit 1
    fi
}

run_tests
