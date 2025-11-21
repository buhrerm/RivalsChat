#!/usr/bin/env zsh

# Component smoke tests - verify all modules load without errors

echo "🔧 Testing Component Loading..."
echo ""

SCRIPT_DIR="/home/mike/Workspace/Rivals"
cd "$SCRIPT_DIR"

TEST_PASSED=0
TEST_FAILED=0

test_module() {
    local module=$1
    local description=$2

    if source "$module" 2>/dev/null; then
        echo "✓ $description"
        ((TEST_PASSED++))
        return 0
    else
        echo "✗ $description - FAILED TO LOAD"
        ((TEST_FAILED++))
        return 1
    fi
}

echo "Testing Utilities..."
test_module "src/utils/constants.zsh" "Constants module"
test_module "src/state/app_state.zsh" "State management"
test_module "src/utils/clipboard.zsh" "Clipboard utilities"
test_module "src/utils/config.zsh" "Configuration management"

echo ""
echo "Testing Libraries..."
test_module "src/lib/text_converter.zsh" "Text converter library"
test_module "src/lib/text_renderer.zsh" "Text renderer library"

echo ""
echo "Testing Components..."
test_module "src/components/ui_header.zsh" "Header component"
test_module "src/components/ui_input.zsh" "Input component"
test_module "src/components/ui_preview.zsh" "Preview component"
test_module "src/components/ui_pattern_selector.zsh" "Pattern selector"
test_module "src/components/ui_footer.zsh" "Footer component"

echo ""
echo "Testing Pages..."
test_module "src/pages/main_page.zsh" "Main page"
test_module "src/pages/pattern_creator_page.zsh" "Pattern creator page"
test_module "src/pages/pattern_manager_page.zsh" "Pattern manager page"

echo ""
echo "Testing Main Entry Point..."
if [[ -x "src/rivals-tui-modular.zsh" ]]; then
    echo "✓ Main entry point is executable"
    ((TEST_PASSED++))
else
    echo "✗ Main entry point not executable"
    ((TEST_FAILED++))
fi

echo ""
echo "Testing Functional Capabilities..."

# Test text conversion
source "src/utils/constants.zsh"
source "src/state/app_state.zsh"
source "src/lib/text_converter.zsh"

ALL_PATTERNS["Test"]="R B G"
REPEAT_MODE=0
SYMMETRY_MODE=0

result=$(text_to_rivals "ABC" "Test")
if [[ "$result" == "#RA#BB#GC" ]]; then
    echo "✓ Text conversion works"
    ((TEST_PASSED++))
else
    echo "✗ Text conversion failed (got: $result)"
    ((TEST_FAILED++))
fi

# Test pattern loading
source "src/utils/config.zsh"
config_init
config_load_patterns

if [[ -n "${ALL_PATTERNS[Rainbow]}" ]]; then
    echo "✓ Pattern loading works"
    ((TEST_PASSED++))
else
    echo "✗ Pattern loading failed"
    ((TEST_FAILED++))
fi

echo ""
echo "════════════════════════════════════"
echo "Tests Passed: $TEST_PASSED"
echo "Tests Failed: $TEST_FAILED"
echo "════════════════════════════════════"

if [[ $TEST_FAILED -eq 0 ]]; then
    echo ""
    echo "✅ All components working!"
    exit 0
else
    echo ""
    echo "❌ Some components have issues"
    exit 1
fi
