#!/usr/bin/env zsh

source "src/utils/constants.zsh"
source "src/state/app_state.zsh"
source "src/components/ui_common.zsh"
source "src/components/ui_input.zsh"
source "src/components/ui_footer.zsh"
source "src/components/ui_pattern_selector.zsh"

echo "Testing UI Stability - Border and Layout Consistency"
echo "===================================================="

TEST_PASSED=0
TEST_FAILED=0

test_ui_width() {
    local description=$1
    local output=$2
    local expected_width=$UI_WIDTH

    local line_count=$(echo "$output" | wc -l)
    local failed_lines=0

    while IFS= read -r line; do
        local stripped=$(echo -e "$line" | sed -E 's/\x1b\[[0-9;]*m//g')
        local width=$(echo -n "$stripped" | wc -m)
        if [[ $width -ne $expected_width ]]; then
            ((failed_lines++))
        fi
    done <<< "$output"

    if [[ $failed_lines -eq 0 ]]; then
        echo "✓ $description - All lines are $expected_width characters"
        ((TEST_PASSED++))
        return 0
    else
        echo "✗ $description - Found $failed_lines lines with incorrect width"
        ((TEST_FAILED++))
        return 1
    fi
}

test_input_with_selection() {
    INPUT_TEXT="Hello World"
    CURSOR_POS=5
    SELECTION_START=0
    SELECTION_END=5

    local output=$(draw_input)
    test_ui_width "Input field with selection" "$output"
}

test_input_long_text() {
    INPUT_TEXT="This is a very long text that should be truncated properly"
    CURSOR_POS=50
    SELECTION_START=-1
    SELECTION_END=-1

    local output=$(draw_input)
    test_ui_width "Input field with long text" "$output"
}

test_footer_success() {
    SHOW_SUCCESS=1
    SUCCESS_MSG="Copied to clipboard!"

    local output=$(draw_footer)
    test_ui_width "Footer with success message" "$output"
}

test_footer_unicode() {
    SHOW_SUCCESS=1
    SUCCESS_MSG="✓ Pattern saved successfully!"

    local output=$(draw_footer)
    test_ui_width "Footer with unicode success message" "$output"
}

test_pattern_selector_modes() {
    source "src/utils/config.zsh"
    config_load_patterns

    CURRENT_PATTERN_INDEX=1

    for repeat_mode in 0 1; do
        for sym_mode in 0 1 2; do
            REPEAT_MODE=$repeat_mode
            SYMMETRY_MODE=$sym_mode

            local output=$(draw_pattern_selector)
            test_ui_width "Pattern selector (repeat=$repeat_mode, sym=$sym_mode)" "$output"
        done
    done
}

echo ""
echo "Testing Input Field Stability..."
test_input_with_selection
test_input_long_text

echo ""
echo "Testing Footer Stability..."
test_footer_success
test_footer_unicode

echo ""
echo "Testing Pattern Selector Stability..."
test_pattern_selector_modes

echo ""
echo "════════════════════════════════════"
echo "Tests Passed: $TEST_PASSED"
echo "Tests Failed: $TEST_FAILED"
echo "════════════════════════════════════"

if [[ $TEST_FAILED -gt 0 ]]; then
    echo "❌ UI stability tests failed"
    exit 1
else
    echo "✅ All UI stability tests passed"
    exit 0
fi
