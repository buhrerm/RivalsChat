# Rivals - Development Guidelines

## Mono-repo Structure

```
Rivals/
├── tui/                          # Terminal UI application
│   ├── src/                      # TUI source code
│   │   ├── rivals-tui-modular.zsh
│   │   ├── components/
│   │   ├── handlers/
│   │   ├── lib/
│   │   ├── pages/
│   │   ├── state/
│   │   └── utils/
│   └── tests/                    # TUI tests
│       ├── unit/
│       ├── integration/
│       └── run_all_tests.zsh
│
├── webapp/                       # Web application (future)
│
├── CLAUDE.md                     # This file
└── README.md                     # Project overview
```

## Project Philosophy

**KISS**: Keep It Simple, Stupid. No over-engineering. No abstractions until proven necessary.

**No AI Slop**: Clean, purposeful code only. No verbose comments, no "helper" functions that do one thing, no "improved" variable names that just add prefixes.

## Strict Rules

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
- Trust internal guarantees - only validate at boundaries

---

# TUI-Specific Guidelines

## TUI Directory Structure

```
tui/
├── src/
│   ├── rivals-tui-modular.zsh    # Main entry point
│   ├── components/               # UI rendering components ONLY
│   │   ├── ui_common.zsh
│   │   ├── ui_header.zsh
│   │   ├── ui_footer.zsh
│   │   ├── ui_input.zsh
│   │   ├── ui_preview.zsh
│   │   └── ui_pattern_selector.zsh
│   ├── handlers/                 # Input handling logic
│   │   ├── creator_input.zsh
│   │   └── manager_input.zsh
│   ├── lib/                      # Core business logic
│   │   ├── text_converter.zsh
│   │   └── text_renderer.zsh
│   ├── pages/                    # Full page compositions
│   │   ├── main_page.zsh
│   │   ├── pattern_creator_page.zsh
│   │   └── pattern_manager_page.zsh
│   ├── state/                    # Application state management
│   │   └── app_state.zsh
│   └── utils/                    # System utilities ONLY
│       ├── clipboard.zsh
│       ├── config.zsh
│       └── constants.zsh
│
└── tests/                        # ALL testing lives here
    ├── unit/
    ├── integration/
    └── run_all_tests.zsh
```

## TUI File Placement Rules

### components/
- UI rendering ONLY
- Functions draw to screen, nothing else
- No business logic, no state mutations

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

### utils/
- System interaction ONLY: clipboard, file I/O, environment
- No business logic

### tests/
- ALL testing code goes here
- Unit tests in unit/, integration in integration/

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

## When to Break Rules

You can break these rules when:
1. User explicitly requests it
2. The alternative is genuinely more complex
3. You can justify why the rule doesn't apply

Default to following the rules. When in doubt, KISS.
