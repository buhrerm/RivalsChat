# Rivals TUI - Architecture Documentation

## Overview

This is a **modular, component-based TUI (Terminal User Interface)** application built with best practices for maintainability, testability, and AI-assisted development.

## Design Principles

1. **Separation of Concerns**: Each module has a single, well-defined responsibility
2. **Component-Based**: UI is built from small, reusable components
3. **Testable**: Each module can be tested independently
4. **AI-Friendly**: Clear structure and naming make it easy for AI to understand and modify
5. **Stateless Components**: Components render based on global state, don't manage their own state

## Directory Structure

```
Rivals/
├── src/                          # Source code
│   ├── components/               # Reusable UI components
│   │   ├── ui_header.zsh        # Application header/banner
│   │   ├── ui_input.zsh         # Text input field with cursor
│   │   ├── ui_preview.zsh       # Colored text preview
│   │   ├── ui_pattern_selector.zsh  # Pattern selection UI
│   │   └── ui_footer.zsh        # Controls and status messages
│   │
│   ├── pages/                    # Full-page views
│   │   ├── main_page.zsh        # Main text editor page
│   │   ├── pattern_creator_page.zsh  # Pattern creation page
│   │   └── pattern_manager_page.zsh  # Pattern management page
│   │
│   ├── lib/                      # Business logic libraries
│   │   ├── text_converter.zsh   # Text → Rivals format conversion
│   │   └── text_renderer.zsh    # ANSI color preview rendering
│   │
│   ├── utils/                    # Utility modules
│   │   ├── constants.zsh        # Application constants
│   │   ├── clipboard.zsh        # Clipboard operations
│   │   └── config.zsh           # Configuration file I/O
│   │
│   ├── state/                    # State management
│   │   └── app_state.zsh        # Global application state
│   │
│   └── rivals-tui-modular.zsh   # Main entry point
│
├── tests/                        # Test suite
│   ├── unit/                     # Unit tests
│   │   ├── test_text_converter.zsh
│   │   └── test_clipboard.zsh
│   ├── integration/              # Integration tests
│   │   └── test_full_workflow.zsh
│   └── run_all_tests.zsh        # Test runner
│
├── rivals-tui.zsh               # Original monolithic version
└── ARCHITECTURE.md              # This file
```

## Module Descriptions

### Components (`src/components/`)

**Purpose**: Small, reusable UI rendering functions

- **ui_header.zsh**: Renders the ASCII art banner and title
- **ui_input.zsh**: Renders the text input box with cursor position and selection highlighting
- **ui_preview.zsh**: Renders the colored preview of the text
- **ui_pattern_selector.zsh**: Renders pattern selection with navigation hints
- **ui_footer.zsh**: Renders keyboard shortcuts and success messages

**Key Characteristic**: Pure rendering functions - they read from global state but don't modify it.

### Pages (`src/pages/`)

**Purpose**: Compose multiple components into full screens

- **main_page.zsh**: Combines header + input + preview + selector + footer
- **pattern_creator_page.zsh**: UI for creating custom color patterns
- **pattern_manager_page.zsh**: UI for browsing/editing/deleting patterns

**Key Characteristic**: Orchestration layer - calls multiple components to build complete views.

### Libraries (`src/lib/`)

**Purpose**: Core business logic with no UI dependencies

- **text_converter.zsh**: Converts plain text to Marvel Rivals color format (`#RA#GB#BC`)
  - Handles repeat modes (continuous/word/phrase)
  - Handles symmetry modes (off/mirror/full)
  - Pure logic, no rendering

- **text_renderer.zsh**: Renders text with ANSI color codes for terminal preview
  - Same logic as text_converter but outputs ANSI instead of Rivals format
  - Includes utility functions: `strip_ansi()`, `visible_length()`

**Key Characteristic**: Testable business logic - no side effects, pure functions.

### Utilities (`src/utils/`)

**Purpose**: System integration and configuration

- **constants.zsh**: All constants in one place
  - Color mappings
  - UI colors
  - Box drawing characters
  - Built-in patterns
  - Configuration paths

- **clipboard.zsh**: Cross-platform clipboard operations
  - Detects available clipboard tool (xclip/pbcopy/xsel)
  - Copy/paste functions

- **config.zsh**: Configuration file management
  - Initializes config directory
  - Loads custom patterns from JSON
  - Saves custom patterns to JSON

**Key Characteristic**: System interface layer - handles external dependencies.

### State (`src/state/`)

**Purpose**: Centralized state management

- **app_state.zsh**: All global application state
  - UI state (current mode, success messages)
  - Input state (text, cursor position, selection)
  - Pattern state (current pattern, modes)
  - Helper functions for state manipulation

**Key Characteristic**: Single source of truth - all state in one module.

## Data Flow

```
User Input → Main Loop → State Update → Render Components → Terminal
                ↓              ↓
            Business Logic   Global State
```

1. **Input**: User presses a key
2. **Handler**: Input handler modifies global state
3. **Business Logic**: Libraries process data from state
4. **Render**: Components read state and render UI
5. **Display**: Terminal shows the result

## Best Practices for Development

### Adding a New Component

1. Create file in `src/components/ui_<name>.zsh`
2. Source required dependencies (state, constants)
3. Create a `draw_<name>()` function
4. Read from global state, don't modify it
5. Return rendered output

Example:
```zsh
#!/usr/bin/env zsh
source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

draw_my_component() {
    # Read from global state
    local value=$SOME_STATE_VAR

    # Render UI
    echo -e "${UI_COLORS[BORDER]}${BOX[V]} $value ${BOX[V]}"
}
```

### Adding a New Page

1. Create file in `src/pages/<name>_page.zsh`
2. Source required components
3. Create a `<name>_page_draw()` function
4. Call components in order

Example:
```zsh
#!/usr/bin/env zsh
source "${0:A:h}/../components/ui_header.zsh"
source "${0:A:h}/../components/ui_my_component.zsh"

my_page_draw() {
    draw_header
    draw_my_component
}
```

### Adding Business Logic

1. Create file in `src/lib/<functionality>.zsh`
2. Keep functions pure (input → output, no side effects)
3. Read global state if needed, but prefer parameters
4. Make functions testable

Example:
```zsh
#!/usr/bin/env zsh

process_data() {
    local input=$1
    # Pure logic here
    echo -n "$result"
}
```

### Adding Tests

1. Create test file in `tests/unit/test_<module>.zsh`
2. Follow test template structure
3. Use assertion functions
4. Run with `./tests/run_all_tests.zsh`

Example:
```zsh
#!/usr/bin/env zsh

setup() {
    source "path/to/module.zsh"
}

test_my_function() {
    local result=$(my_function "input")
    assert_equals "expected" "$result" "Test description"
}

run_tests() {
    setup
    test_my_function
}
```

## Testing

### Running Tests

```bash
# Run all tests
./tests/run_all_tests.zsh

# Run specific test
./tests/unit/test_text_converter.zsh
```

### Test Structure

- **Unit Tests**: Test individual modules in isolation
- **Integration Tests**: Test multiple modules working together
- **Test Runner**: Executes all tests and provides summary

## AI Development Guidelines

When asking AI to modify this codebase:

1. **Be Specific About Module**: "Modify the ui_input component" is better than "change the input"
2. **Reference File Paths**: Use full paths like `src/components/ui_input.zsh`
3. **One Module at a Time**: Changes to single modules are easier to test
4. **Request Tests**: Always ask for tests when adding features
5. **State Changes**: Be explicit about which state variables should change

Example prompts:
- ✅ "Add a character counter to src/components/ui_input.zsh"
- ✅ "Create a new symmetry mode in src/lib/text_converter.zsh and add tests"
- ❌ "Make the input better" (too vague)

## Performance Considerations

- **Minimize Renders**: Only call `draw_ui()` when state changes
- **Lazy Loading**: Components only render when in current mode
- **Pure Functions**: Business logic functions are easily optimizable

## Future Enhancements

Potential additions that fit this architecture:

- **Plugins System**: Add `src/plugins/` directory
- **Themes**: Add `src/themes/` with color scheme files
- **History**: Add `src/lib/history.zsh` for undo/redo
- **Keybindings**: Add `src/config/keybindings.zsh` for customization
- **Export Formats**: Add export modules to `src/lib/exporters/`

## Migration from Monolithic Version

The original `rivals-tui.zsh` is preserved for reference. Key differences:

| Aspect | Monolithic | Modular |
|--------|------------|---------|
| File count | 1 file | 20+ files |
| Lines per file | ~2000 | ~50-200 |
| Testability | Difficult | Easy |
| Reusability | Low | High |
| AI understanding | Harder | Easier |
| Collaboration | Conflicts likely | Parallel development |

## Troubleshooting

### Module Not Found
- Ensure you're running from the correct directory
- Check that `${0:A:h}` resolves correctly
- Verify file paths in source statements

### State Not Updating
- Check that state variables are declared with `typeset -g`
- Verify state modification happens before `draw_ui()`
- Use `state_*` helper functions from `app_state.zsh`

### Tests Failing
- Ensure all dependencies are sourced in test setup
- Check that test files are executable
- Verify global state is reset between tests

## Contributing

1. Follow the module structure
2. Add tests for new features
3. Update this document for architectural changes
4. Keep components small (< 100 lines)
5. Document complex logic with comments
