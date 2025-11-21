# Rivals TUI - Development Guidelines

## Project Philosophy

**KISS**: Keep It Simple, Stupid. No over-engineering. No abstractions until proven necessary.

**No AI Slop**: Clean, purposeful code only. No verbose comments, no "helper" functions that do one thing, no "improved" variable names that just add prefixes.

## Strict Rules

### NO MARKDOWN FILES
- **NEVER** create README.md, CONTRIBUTING.md, CHANGELOG.md, or any other .md files
- Documentation lives in code comments (sparingly) or not at all
- This file (CLAUDE.md) is the ONLY exception

### Code Quality
- No comments explaining obvious code
- No docstrings unless the function is genuinely complex
- No "TODO" comments - fix it or delete it
- No defensive programming for impossible states
- No error handling for internal functions that can't fail
- Variable names: short and clear (`pos` not `current_position`, `idx` not `loop_iteration_index`)
- Delete unused code completely - no commenting out, no `_unused_var` renaming

### Architecture
- No abstractions for single-use code
- No "utility" functions that wrap one operation
- Three similar lines > premature abstraction
- No feature flags or backwards compatibility hacks
- Trust zsh and internal guarantees - only validate at boundaries

## Directory Structure

```
Rivals/
├── src/
│   ├── rivals-tui-modular.zsh    # Main entry point, orchestrates everything
│   ├── components/               # UI rendering components ONLY
│   │   ├── ui_common.zsh         # Shared UI utilities, colors, borders
│   │   ├── ui_header.zsh         # Header rendering
│   │   ├── ui_footer.zsh         # Footer/help rendering
│   │   ├── ui_input.zsh          # Input field rendering
│   │   ├── ui_preview.zsh        # Text preview rendering
│   │   └── ui_pattern_selector.zsh # Pattern selector rendering
│   ├── handlers/                 # Input handling logic
│   │   ├── creator_input.zsh     # Pattern creator input handler
│   │   └── manager_input.zsh     # Pattern manager input handler
│   ├── lib/                      # Core business logic libraries
│   │   ├── text_converter.zsh    # Text to Rivals code conversion
│   │   └── text_renderer.zsh     # Renders colored text for preview
│   ├── pages/                    # Full page compositions
│   │   ├── main_page.zsh         # Main converter page
│   │   ├── pattern_creator_page.zsh # Pattern creation page
│   │   └── pattern_manager_page.zsh # Pattern management page
│   ├── state/                    # Application state management
│   │   └── app_state.zsh         # Global state, state mutations
│   └── utils/                    # System utilities ONLY
│       ├── clipboard.zsh         # Clipboard detection/operations
│       ├── config.zsh            # Pattern config file I/O
│       └── constants.zsh         # Constants, version, defaults
│
├── tests/                        # ALL testing lives here
│   ├── unit/                     # Unit tests for individual modules
│   │   ├── test_clipboard.zsh
│   │   ├── test_text_converter.zsh
│   │   └── test_*.zsh
│   ├── integration/              # Integration/workflow tests
│   │   └── test_full_workflow.zsh
│   ├── run_all_tests.zsh         # Test runner
│   └── test_*.zsh                # Legacy tests (consolidate into unit/)
│
└── CLAUDE.md                     # This file (ONLY .md allowed)
```

## File Placement Rules

### components/
- UI rendering ONLY
- Functions draw to screen, nothing else
- No business logic, no state mutations
- Pure functions where possible: input → rendered output

### handlers/
- Input handling for specific modes/pages
- Delegates to state/ for mutations, lib/ for logic
- Returns control flow signals (continue/exit/mode switch)

### lib/
- Core business logic
- Text conversion, rendering algorithms
- Pure functions preferred
- No I/O, no state mutations

### pages/
- Compose components into full screens
- Orchestrate component rendering
- No business logic beyond layout

### state/
- ALL global state lives here
- ALL state mutations happen here
- Functions return new values or mutate globals explicitly
- No side effects beyond state changes

### utils/
- System interaction ONLY: clipboard, file I/O, environment
- No business logic
- Detect capabilities, provide abstractions for system APIs

### tests/
- **ALL** testing code goes here
- No test files outside this directory
- Unit tests in unit/, integration in integration/
- Test runners at root of tests/

## Testing Requirements

### All Tests in tests/
- Unit tests: `tests/unit/test_<module>.zsh`
- Integration tests: `tests/integration/test_<feature>.zsh`
- Test runner: `tests/run_all_tests.zsh`
- No exceptions

### Test Structure
```zsh
#!/usr/bin/env zsh

# Source module under test
source ../src/lib/text_converter.zsh

# Test cases
test_basic_conversion() {
    local result=$(text_to_rivals "test" "rainbow")
    [[ "$result" == "<expected>" ]] || return 1
}

# Run tests
test_basic_conversion && echo "PASS" || echo "FAIL"
```

### What to Test
- Core conversion logic (lib/)
- State mutations (state/)
- Edge cases, boundary conditions
- Don't test UI rendering (brittle, low value)

## Code Style

### Functions
```zsh
# Good
calc_width() {
    echo $(( $TERM_WIDTH - 4 ))
}

# Bad - over-commented, verbose
calculate_available_terminal_width() {
    # Calculate the width available in the terminal
    local terminal_width=$TERM_WIDTH
    local padding=4
    # Subtract padding from terminal width to get usable width
    local usable_width=$(( terminal_width - padding ))
    echo $usable_width
}
```

### Variables
```zsh
# Good
pos=0
idx=1
sel_start=$SELECTION_START

# Bad
current_position=0
loop_iteration_index=1
selected_text_starting_position=$SELECTION_START
```

### Comments
```zsh
# Good - only for non-obvious logic
# Mirror symmetry: reflect pattern from center
local mirror_point=$(( ${#text} / 2 ))

# Bad - explaining obvious code
# Increment counter by one
((counter++))
```

## Common Violations to Avoid

### ❌ Over-engineering
```zsh
# Bad
create_helper_for_single_operation() {
    echo "$1"
}
result=$(create_helper_for_single_operation "$value")

# Good
result="$value"
```

### ❌ Defensive Programming
```zsh
# Bad - internal function, caller guarantees valid input
process_text() {
    if [[ -z "$1" ]]; then
        echo "Error: no text provided" >&2
        return 1
    fi
    # ... process
}

# Good - trust caller
process_text() {
    # ... process
}
```

### ❌ Unnecessary Abstraction
```zsh
# Bad - three lines, made into function
get_pattern_count() {
    echo ${#PATTERN_ORDER[@]}
}
total=$(get_pattern_count)

# Good - just use it
total=${#PATTERN_ORDER[@]}
```

### ❌ Verbose Names
```zsh
# Bad
current_selected_pattern_array_index=1
user_input_text_string=""

# Good
pat_idx=1
text=""
```

## When to Break Rules

You can break these rules when:
1. User explicitly requests it
2. The alternative is genuinely more complex
3. You can justify why the rule doesn't apply

Default to following the rules. When in doubt, KISS.
