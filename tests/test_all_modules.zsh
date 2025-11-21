#!/usr/bin/env zsh

# Comprehensive test suite for all modular components

TEST_DIR="${0:A:h}"
SRC_DIR="${TEST_DIR}/../src"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_pass() {
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
    echo -e "${GREEN}✓${NC} $1"
}

test_fail() {
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
    echo -e "${RED}✗${NC} $1"
}

test_section() {
    echo ""
    echo -e "${YELLOW}=== $1 ===${NC}"
}

# Test 1: Module Loading
test_section "Module Loading Tests"

test_modules=(
    "utils/constants.zsh"
    "state/app_state.zsh"
    "utils/config.zsh"
    "utils/clipboard.zsh"
    "lib/text_converter.zsh"
    "lib/text_renderer.zsh"
    "components/ui_header.zsh"
    "components/ui_footer.zsh"
    "components/ui_input.zsh"
    "components/ui_preview.zsh"
    "components/ui_pattern_selector.zsh"
    "handlers/creator_input.zsh"
    "handlers/manager_input.zsh"
    "pages/main_page.zsh"
    "pages/pattern_creator_page.zsh"
    "pages/pattern_manager_page.zsh"
)

for module in "${test_modules[@]}"; do
    module_path="$SRC_DIR/$module"
    if [[ -f "$module_path" ]]; then
        if source "$module_path" 2>/dev/null; then
            test_pass "Loaded $module"
        else
            test_fail "Failed to source $module"
        fi
    else
        test_fail "Missing $module"
    fi
done

# Test 2: State Management
test_section "State Management Tests"

if [[ -n "$CURRENT_MODE" ]]; then
    test_pass "Global state variables initialized"
else
    test_fail "Global state variables not initialized"
fi

if [[ -n "${COLORS[Y]}" ]]; then
    test_pass "Color constants defined"
else
    test_fail "Color constants missing"
fi

# Test 3: Configuration
test_section "Configuration Tests"

config_init
if [[ -d "$CONFIG_DIR" ]]; then
    test_pass "Config directory created"
else
    test_fail "Config directory not created"
fi

config_load_patterns
if [[ ${#PATTERN_ORDER[@]} -gt 0 ]]; then
    test_pass "Patterns loaded (${#PATTERN_ORDER[@]} total)"
else
    test_fail "No patterns loaded"
fi

# Verify built-in patterns
builtin_count=0
for pattern in Rainbow Warm Cool Neon Sunset Ocean Psychedelic Spring Cherry Matrix; do
    if [[ -n "${ALL_PATTERNS[$pattern]}" ]]; then
        ((builtin_count++))
    fi
done

if [[ $builtin_count -eq 10 ]]; then
    test_pass "All 10 built-in patterns loaded"
else
    test_fail "Missing built-in patterns (found $builtin_count/10)"
fi

# Test 4: Text Converter
test_section "Text Converter Tests"

# Test basic conversion
test_text="Hello"
result=$(convert_to_rivals "$test_text" "Rainbow")
if [[ -n "$result" ]]; then
    test_pass "Text conversion works"
else
    test_fail "Text conversion failed"
fi

# Test with different repeat modes
REPEAT_MODE=0
result=$(convert_to_rivals "Test" "Rainbow")
[[ -n "$result" ]] && test_pass "Continuous mode conversion" || test_fail "Continuous mode failed"

REPEAT_MODE=1
result=$(convert_to_rivals "Test Word" "Rainbow")
[[ -n "$result" ]] && test_pass "Per-word mode conversion" || test_fail "Per-word mode failed"

REPEAT_MODE=2
result=$(convert_to_rivals "Test Phrase" "Rainbow")
[[ -n "$result" ]] && test_pass "Per-phrase mode conversion" || test_fail "Per-phrase mode failed"

# Test symmetry modes
REPEAT_MODE=0
SYMMETRY_MODE=1
result=$(convert_to_rivals "Test" "Rainbow")
[[ -n "$result" ]] && test_pass "Mirror symmetry conversion" || test_fail "Mirror symmetry failed"

SYMMETRY_MODE=2
result=$(convert_to_rivals "Test" "Rainbow")
[[ -n "$result" ]] && test_pass "Full symmetry conversion" || test_fail "Full symmetry failed"

# Reset modes
REPEAT_MODE=0
SYMMETRY_MODE=0

# Test 5: Pattern Editor
test_section "Pattern Editor Tests"

# Test editing custom patterns
custom_patterns=(Contrast Night Thanksgiving WEEOO)
for pattern_name in "${custom_patterns[@]}"; do
    # Find pattern index
    local index=1
    for ((i=1; i<=${#PATTERN_ORDER[@]}; i++)); do
        if [[ "${PATTERN_ORDER[$i]}" == "$pattern_name" ]]; then
            index=$i
            break
        fi
    done

    MANAGER_CURSOR=$index
    local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"

    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        CREATOR_NAME="$current_pattern"
        CREATOR_ICON="${ALL_ICONS[$current_pattern]}"

        # Parse colors (using the fixed code)
        CREATOR_COLORS=()
        local -a parsed_colors
        parsed_colors=(${=ALL_PATTERNS[$current_pattern]})
        for color in "${parsed_colors[@]}"; do
            CREATOR_COLORS+=("$color")
        done

        if [[ ${#CREATOR_COLORS[@]} -gt 0 ]]; then
            test_pass "Pattern '$pattern_name' loads for editing (${#CREATOR_COLORS[@]} colors)"
        else
            test_fail "Pattern '$pattern_name' has no colors"
        fi

        state_reset_creator
    fi
done

# Test 6: Clipboard Detection
test_section "Clipboard Tests"

clipboard_detect
if [[ -n "$CLIPBOARD_CMD" ]]; then
    test_pass "Clipboard command detected: $CLIPBOARD_CMD"
else
    test_fail "No clipboard command available"
fi

# Test 7: Component Functions
test_section "Component Function Tests"

# Test if UI component functions exist
if typeset -f ui_header_draw > /dev/null 2>&1; then
    test_pass "UI header component function exists"
else
    test_fail "UI header component function missing"
fi

if typeset -f ui_footer_draw > /dev/null 2>&1; then
    test_pass "UI footer component function exists"
else
    test_fail "UI footer component function missing"
fi

if typeset -f ui_input_draw > /dev/null 2>&1; then
    test_pass "UI input component function exists"
else
    test_fail "UI input component function missing"
fi

if typeset -f ui_preview_draw > /dev/null 2>&1; then
    test_pass "UI preview component function exists"
else
    test_fail "UI preview component function missing"
fi

if typeset -f ui_pattern_selector_draw > /dev/null 2>&1; then
    test_pass "UI pattern selector component function exists"
else
    test_fail "UI pattern selector component function missing"
fi

# Test handler functions
if typeset -f handle_creator_input > /dev/null 2>&1; then
    test_pass "Creator input handler exists"
else
    test_fail "Creator input handler missing"
fi

if typeset -f handle_manager_input > /dev/null 2>&1; then
    test_pass "Manager input handler exists"
else
    test_fail "Manager input handler missing"
fi

# Test page drawing functions
if typeset -f pattern_creator_page_draw > /dev/null 2>&1; then
    test_pass "Pattern creator page function exists"
else
    test_fail "Pattern creator page function missing"
fi

if typeset -f pattern_manager_page_draw > /dev/null 2>&1; then
    test_pass "Pattern manager page function exists"
else
    test_fail "Pattern manager page function missing"
fi

# Final Results
test_section "Test Results"

echo ""
echo "Total Tests: $TESTS_TOTAL"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
fi

echo ""
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
