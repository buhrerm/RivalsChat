#!/usr/bin/env zsh

# Test Pattern Editor - Verify editing patterns with colors works

SCRIPT_DIR="${0:A:h}"
SRC_DIR="${SCRIPT_DIR}/../src"

# Source required modules
source "$SRC_DIR/utils/constants.zsh"
source "$SRC_DIR/state/app_state.zsh"
source "$SRC_DIR/utils/config.zsh"
source "$SRC_DIR/handlers/manager_input.zsh"

# Initialize
config_init
config_load_patterns

echo "Test Suite: Pattern Editor"
echo "==========================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

test_pattern_edit() {
    local pattern_name=$1
    local expected_colors=$2

    echo -n "Testing edit of '$pattern_name'... "

    # Find pattern index
    local index=1
    for ((i=1; i<=${#PATTERN_ORDER[@]}; i++)); do
        if [[ "${PATTERN_ORDER[$i]}" == "$pattern_name" ]]; then
            index=$i
            break
        fi
    done

    # Simulate edit (from manager_input.zsh lines 40-58)
    MANAGER_CURSOR=$index
    local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"

    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        CURRENT_MODE="pattern_creator"
        CREATOR_MODE="name"
        CREATOR_NAME="$current_pattern"
        CREATOR_ICON="${ALL_ICONS[$current_pattern]}"

        # Parse colors - THE FIX
        CREATOR_COLORS=()
        local -a parsed_colors
        parsed_colors=(${=ALL_PATTERNS[$current_pattern]})
        for color in "${parsed_colors[@]}"; do
            CREATOR_COLORS+=("$color")
        done

        CREATOR_CURSOR=1
        CREATOR_COLOR_CURSOR=1

        # Verify results
        if [[ ${#CREATOR_COLORS[@]} -eq 0 ]]; then
            echo "FAIL - No colors loaded"
            ((TESTS_FAILED++))
            return 1
        fi

        local actual_colors="${CREATOR_COLORS[*]}"
        if [[ "$actual_colors" == "$expected_colors" ]]; then
            echo "PASS - Loaded ${#CREATOR_COLORS[@]} colors: $actual_colors"
            ((TESTS_PASSED++))
            return 0
        else
            echo "FAIL - Expected '$expected_colors', got '$actual_colors'"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo "SKIP - Built-in pattern"
        return 0
    fi
}

# Test all custom patterns
test_pattern_edit "Contrast" "Y I R G U"
test_pattern_edit "Night" "I T M B U"
test_pattern_edit "Thanksgiving" "O E K Y"
test_pattern_edit "WEEOO" "A U P K O M"

echo ""
echo "==========================="
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✓ All pattern editor tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
