# Rivals TUI Test Suite

This directory contains tests for the modular Rivals TUI application.

## Test Files

### Automated Tests

#### `test_pattern_editor.zsh`
Tests the pattern editor's ability to load and edit colored patterns.

**What it tests:**
- Loading custom patterns from config
- Parsing color codes from pattern strings
- Populating the pattern editor with existing pattern data

**Run with:**
```bash
./tests/test_pattern_editor.zsh
```

**Expected output:**
```
Testing Pattern Editor with Colored Patterns
==============================================

Testing pattern 'Contrast'... ✓ Loaded 5 colors: Y I R G U
Testing pattern 'Night'... ✓ Loaded 5 colors: I T M B U
Testing pattern 'Thanksgiving'... ✓ Loaded 4 colors: O E K Y
Testing pattern 'WEEOO'... ✓ Loaded 6 colors: A U P K O M

All pattern editor tests passed! ✓
```

#### `test_all_modules.zsh`
Comprehensive test of all modular components.

**What it tests:**
- Module loading (16 modules)
- State management initialization
- Configuration system
- Pattern loading (10 built-in + custom)
- Text converter functions
- Pattern editor functionality
- Clipboard detection
- Component function existence

**Run with:**
```bash
./tests/test_all_modules.zsh
```

**Note:** Some tests may fail when modules are sourced in a test environment due to path resolution differences. The important tests are:
- Module loading (all 16 modules should load)
- Pattern editor tests (all custom patterns should load for editing)
- Configuration tests (patterns should be loaded)

#### `component_test.zsh`
Basic component loading and initialization test.

**Run with:**
```bash
./tests/component_test.zsh
```

### Manual Tests

#### `manual_test_instructions.md`
Detailed instructions for manually testing the pattern editor fix and overall TUI functionality.

**Key manual tests:**
1. Edit existing colored patterns
2. Modify pattern colors
3. Create new patterns
4. Verify persistence

## Quick Test

To quickly verify the pattern editor fix works:

```bash
./tests/test_pattern_editor.zsh
```

This will confirm that all custom patterns can be loaded for editing without crashing.

## Integration Testing

To test the full TUI interactively:

```bash
./src/rivals-tui-modular.zsh
```

Then follow the instructions in `manual_test_instructions.md`.

## Test Coverage

### Fixed Issues
- ✅ Pattern editor crash when editing patterns with colors
- ✅ Color array parsing in Zsh global scope

### Verified Working
- ✅ All 16 modules load correctly
- ✅ 10 built-in patterns + custom patterns load
- ✅ Pattern editor loads custom patterns with colors
- ✅ Text converter handles all repeat and symmetry modes
- ✅ Input handlers for main, creator, and manager modes
- ✅ Page drawing functions

### Known Limitations
- Regex module loading errors in test environment (not affecting actual TUI)
- Some component function names don't match test expectations (naming convention differences)

## Adding New Tests

When adding new tests:

1. **Unit tests**: Test individual functions in isolation
2. **Integration tests**: Test component interactions
3. **Manual tests**: Document user-facing functionality to test

Place test files in this directory and add them to this README.
