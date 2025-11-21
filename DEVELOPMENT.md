## Development Guide - Rivals TUI

## Quick Start

### Setup Development Environment

```bash
# Clone the repository
cd /home/mike/Workspace/Rivals

# Make scripts executable
chmod +x src/rivals-tui-modular.zsh
chmod +x tests/run_all_tests.zsh

# Run tests
./tests/run_all_tests.zsh

# Run the application
./src/rivals-tui-modular.zsh
```

### Project Structure

```
src/
├── components/     # UI components (small, reusable)
├── pages/          # Full pages (compose components)
├── lib/            # Business logic (pure functions)
├── utils/          # System utilities
├── state/          # State management
└── rivals-tui-modular.zsh  # Entry point

tests/
├── unit/           # Test individual modules
├── integration/    # Test module interactions
└── run_all_tests.zsh
```

## Development Workflow

### 1. Adding a New Feature

Example: Add a "reverse text" feature

```bash
# 1. Add state variable
# Edit: src/state/app_state.zsh
typeset -g REVERSE_MODE=0

# 2. Add business logic
# Create: src/lib/text_reverser.zsh
reverse_text() {
    local text=$1
    # Implementation
}

# 3. Add UI component (if needed)
# Edit: src/components/ui_preview.zsh
# Add reverse indicator

# 4. Add input handler
# Edit: src/rivals-tui-modular.zsh
# Add key binding for Ctrl+T

# 5. Add tests
# Create: tests/unit/test_text_reverser.zsh
test_reverse_text() {
    assert_equals "CBA" "$(reverse_text "ABC")"
}

# 6. Run tests
./tests/run_all_tests.zsh
```

### 2. Modifying a Component

Example: Change the input box border style

```bash
# Edit: src/components/ui_input.zsh
# Change the box drawing characters

# Test visually
./src/rivals-tui-modular.zsh

# No unit tests needed for UI-only changes
# (Unless you want screenshot tests)
```

### 3. Fixing a Bug

```bash
# 1. Write a failing test
# Edit: tests/unit/test_<module>.zsh
test_bug_case() {
    # Test that demonstrates the bug
}

# 2. Run test to confirm failure
./tests/unit/test_<module>.zsh

# 3. Fix the bug
# Edit: src/lib/<module>.zsh

# 4. Run test to confirm fix
./tests/unit/test_<module>.zsh

# 5. Run all tests
./tests/run_all_tests.zsh
```

## Module Development Patterns

### Creating a Component

Components are **pure rendering functions** that read global state.

```zsh
#!/usr/bin/env zsh
# src/components/ui_example.zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

draw_example() {
    # 1. Read from global state
    local value=$SOME_STATE_VAR

    # 2. Compute display values
    local display="${value} items"

    # 3. Render using constants
    echo -e "${UI_COLORS[BORDER]}${BOX[V]} ${display} ${BOX[V]}"
}
```

**Rules**:
- Read state, never modify it
- Use `UI_COLORS` and `BOX` from constants
- Keep it simple (< 100 lines)
- No business logic here

### Creating a Library Module

Library modules contain **pure business logic**.

```zsh
#!/usr/bin/env zsh
# src/lib/example_processor.zsh

source "${0:A:h}/../utils/constants.zsh"

process_example() {
    local input=$1
    local mode=$2
    local result=""

    # Pure logic - no state modification
    # Input → Processing → Output

    echo -n "$result"
}
```

**Rules**:
- Pure functions (same input = same output)
- No side effects
- Accept parameters, don't rely on global state
- Return via echo -n
- Easily testable

### Creating a Page

Pages **compose components** into full views.

```zsh
#!/usr/bin/env zsh
# src/pages/example_page.zsh

source "${0:A:h}/../components/ui_header.zsh"
source "${0:A:h}/../components/ui_example.zsh"
source "${0:A:h}/../components/ui_footer.zsh"

example_page_draw() {
    draw_header
    draw_example
    draw_footer
}
```

**Rules**:
- Call components in order
- Don't duplicate rendering logic
- Keep it simple - just orchestration

### Managing State

State modifications happen in **handlers** and **state helpers**.

```zsh
# In src/state/app_state.zsh
state_toggle_mode() {
    EXAMPLE_MODE=$(( (EXAMPLE_MODE + 1) % 3 ))
}

# In src/rivals-tui-modular.zsh (input handler)
handle_input() {
    case "$char" in
        $'\x14') # Ctrl+T
            state_toggle_mode
            state_show_success "Mode changed"
            draw_ui
            ;;
    esac
}
```

**Rules**:
- State changes in one place (handlers or state module)
- Call `draw_ui()` after state changes
- Use helper functions from `app_state.zsh`

## Testing Best Practices

### Unit Test Template

```zsh
#!/usr/bin/env zsh
# tests/unit/test_<module>.zsh

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

setup() {
    source "$(dirname $0)/../../src/lib/<module>.zsh"
}

test_feature_x() {
    local result=$(function_to_test "input")
    assert_equals "expected output" "$result" "Description"
}

run_tests() {
    echo "Running <module> tests..."
    echo "===================================="

    setup
    test_feature_x
    # More tests...

    echo "===================================="
    echo "Tests passed: $TEST_PASSED"
    echo "Tests failed: $TEST_FAILED"

    [[ $TEST_FAILED -gt 0 ]] && exit 1 || exit 0
}

run_tests
```

### Integration Test Template

```zsh
#!/usr/bin/env zsh
# tests/integration/test_<workflow>.zsh

setup() {
    # Source all required modules
    source "path/to/module1.zsh"
    source "path/to/module2.zsh"
}

test_complete_workflow() {
    # Test multiple modules working together
    step1_result=$(module1_function "input")
    step2_result=$(module2_function "$step1_result")
    assert_not_empty "$step2_result" "Workflow produces output"
}
```

## Common Tasks

### Add a New Color Pattern

```bash
# Edit: src/utils/constants.zsh
# Add to BUILTIN_PATTERNS and BUILTIN_ICONS

# Test by running the app
./src/rivals-tui-modular.zsh
```

### Add a New Keyboard Shortcut

```bash
# Edit: src/rivals-tui-modular.zsh
# Find handle_main_input() function
# Add new case for your key

# Edit: src/components/ui_footer.zsh
# Update the help text

# Test the shortcut
./src/rivals-tui-modular.zsh
```

### Change UI Colors

```bash
# Edit: src/utils/constants.zsh
# Modify UI_COLORS

# Preview changes
./src/rivals-tui-modular.zsh
```

### Add State Variable

```bash
# Edit: src/state/app_state.zsh
typeset -g NEW_VARIABLE="default_value"

# Add to state_init() if needed
state_init() {
    # ...
    NEW_VARIABLE="initial_value"
}

# Use in components
# Edit: src/components/ui_<component>.zsh
local value=$NEW_VARIABLE
```

## Debugging

### Enable Debug Output

```zsh
# Add to any module
debug_log() {
    echo "[DEBUG] $1" >> /tmp/rivals-debug.log
}

# Use in code
debug_log "Variable value: $MY_VAR"
```

### Test Individual Module

```zsh
# Source the module in a new shell
zsh
source src/lib/text_converter.zsh
source src/state/app_state.zsh
source src/utils/constants.zsh

# Test functions interactively
ALL_PATTERNS["Test"]="R B G"
text_to_rivals "ABC" "Test"
```

### Isolate Component

Create a test script:

```zsh
#!/usr/bin/env zsh
# test_component.zsh

source src/utils/constants.zsh
source src/state/app_state.zsh
source src/components/ui_input.zsh

# Set up minimal state
INPUT_TEXT="Test"
CURSOR_POS=4

# Render just this component
clear
draw_input
```

## Code Style

### Naming Conventions

- **Functions**: `snake_case` - `draw_header()`, `text_to_rivals()`
- **Global variables**: `UPPER_SNAKE` - `CURRENT_MODE`, `INPUT_TEXT`
- **Local variables**: `snake_case` - `local result=""`, `local char=$1`
- **Constants**: `UPPER_SNAKE` - `VERSION`, `CONFIG_DIR`
- **Arrays**: `UPPER_SNAKE` - `PATTERN_ORDER`, `CREATOR_COLORS`

### File Organization

```zsh
#!/usr/bin/env zsh

# <filename> - Brief description
# Longer description of purpose

# Source dependencies
source "${0:A:h}/relative/path.zsh"

# Functions
function_name() {
    # Implementation
}

# More functions...
```

### Comments

```zsh
# Single-line comment for brief explanation

# Multi-line comment
# for complex logic that needs
# more detailed explanation

# Section separator
# ─────────────────────────────────────

# TODO: Future enhancement
# FIXME: Known issue
# NOTE: Important information
```

## Performance Tips

1. **Minimize `draw_ui()` calls**: Only redraw when state changes
2. **Avoid loops in components**: Pre-compute in libraries
3. **Use local variables**: Faster than global access
4. **Cache pattern data**: Don't re-parse on every render

## Getting Help

- Read `ARCHITECTURE.md` for system design
- Check existing modules for patterns
- Run tests to understand expected behavior
- Use debug logging for runtime inspection

## AI-Assisted Development

When working with AI (like me!):

### Good Prompts

✅ "Add a word count feature to src/components/ui_input.zsh"
✅ "Create a new test for text_converter.zsh that tests emoji handling"
✅ "Refactor the pattern selector to show 5 patterns at once"

### Vague Prompts

❌ "Make it better"
❌ "Add more features"
❌ "Fix the bugs"

### Request Tests

Always ask: "Also create tests for this feature"

### Request Documentation

Always ask: "Update ARCHITECTURE.md with this change"
