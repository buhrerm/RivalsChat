#!/usr/bin/env zsh

# Test pattern editor with colored patterns

# Source all necessary modules
TEST_DIR="${0:A:h}"
SRC_DIR="${TEST_DIR}/../src"

# Source required modules
source "$SRC_DIR/utils/constants.zsh"
source "$SRC_DIR/state/app_state.zsh"
source "$SRC_DIR/utils/config.zsh"
source "$SRC_DIR/handlers/manager_input.zsh"

# Initialize
config_init
config_load_patterns

echo "Testing Pattern Editor with Colored Patterns"
echo "=============================================="
echo ""

# Test loading each custom pattern
for pattern_name in Contrast Night Thanksgiving WEEOO; do
    echo -n "Testing pattern '$pattern_name'... "

    # Simulate finding the pattern index
    local index=1
    for ((i=1; i<=${#PATTERN_ORDER[@]}; i++)); do
        if [[ "${PATTERN_ORDER[$i]}" == "$pattern_name" ]]; then
            index=$i
            break
        fi
    done

    # Set manager cursor to this pattern
    MANAGER_CURSOR=$index

    # Simulate the edit action (same code as in manager_input.zsh)
    local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"

    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        CURRENT_MODE="pattern_creator"
        CREATOR_MODE="name"
        CREATOR_NAME="$current_pattern"
        CREATOR_ICON="${ALL_ICONS[$current_pattern]}"

        # Parse colors from pattern string - properly expand into global array
        CREATOR_COLORS=()
        local -a parsed_colors
        parsed_colors=(${=ALL_PATTERNS[$current_pattern]})
        for color in "${parsed_colors[@]}"; do
            CREATOR_COLORS+=("$color")
        done

        CREATOR_CURSOR=1
        CREATOR_COLOR_CURSOR=1

        # Check if colors were loaded
        if [[ ${#CREATOR_COLORS[@]} -gt 0 ]]; then
            echo "✓ Loaded ${#CREATOR_COLORS[@]} colors: ${CREATOR_COLORS[@]}"
        else
            echo "✗ FAILED - No colors loaded!"
            exit 1
        fi
    else
        echo "✗ SKIP - Built-in pattern"
    fi

    # Reset state for next test
    state_reset_creator
done

echo ""
echo "All pattern editor tests passed! ✓"
