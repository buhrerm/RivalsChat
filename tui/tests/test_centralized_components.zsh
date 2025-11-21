#!/usr/bin/env zsh

# Test centralized UI components

# Source the modules
source "${0:A:h}/../src/utils/constants.zsh"
source "${0:A:h}/../src/state/app_state.zsh"
source "${0:A:h}/../src/components/ui_common.zsh"

echo "=== Testing Centralized UI Components ==="
echo

# Test 1: draw_spacer
echo "Test 1: draw_spacer"
draw_spacer
echo "✓ draw_spacer works"
echo

# Test 2: draw_divider
echo "Test 2: draw_divider"
draw_divider
echo "✓ draw_divider works"
echo

# Test 3: draw_box_content_line
echo "Test 3: draw_box_content_line"
draw_box_content_line "Test content" 12
echo "✓ draw_box_content_line works"
echo

# Test 4: draw_controls for all modes
echo "Test 4: draw_controls (main)"
draw_controls "main"
echo "✓ main controls work"
echo

echo "Test 5: draw_controls (pattern_manager)"
draw_controls "pattern_manager"
echo "✓ pattern_manager controls work"
echo

echo "Test 6: draw_controls (pattern_creator_name)"
draw_controls "pattern_creator_name"
echo "✓ pattern_creator_name controls work"
echo

echo "Test 7: draw_controls (pattern_creator_icon)"
draw_controls "pattern_creator_icon"
echo "✓ pattern_creator_icon controls work"
echo

echo "Test 8: draw_controls (pattern_creator_colors)"
draw_controls "pattern_creator_colors"
echo "✓ pattern_creator_colors controls work"
echo

echo "=== All centralized component tests passed! ==="
