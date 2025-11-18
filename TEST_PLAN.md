# Test Plan for Text Editor Features

## Manual Testing Guide

### Test 1: Basic Cursor Movement
1. Run `./rivals-tui.zsh`
2. Type "Hello World"
3. Press Left arrow 5 times
4. Verify cursor is between "Hello" and "World"
5. Press Right arrow 2 times
6. Verify cursor moved right

**Expected**: Cursor moves correctly, UI updates show cursor position with underscore

### Test 2: Home and End Keys
1. Type "Test text"
2. Press Home
3. Verify cursor at start (before "T")
4. Press End
5. Verify cursor at end (after "t")

**Expected**: Cursor jumps to start/end correctly

### Test 3: Select All
1. Type "Marvel Rivals"
2. Press Ctrl+A
3. Verify all text is highlighted (inverted colors)

**Expected**: All text shown with inverted background color

### Test 4: Cut Operation
1. Type "Hello World"
2. Press Ctrl+A (select all)
3. Press Ctrl+X (cut)
4. Verify text is cleared
5. Verify message "Cut to clipboard!" appears
6. Open another terminal and run: `xclip -selection clipboard -o`
7. Verify output is "Hello World"

**Expected**: Text removed, copied to clipboard, success message shown

### Test 5: Paste Operation
1. Clear input (Ctrl+U)
2. Copy something to clipboard externally: `echo -n "Pasted Text" | xclip -selection clipboard`
3. Press Ctrl+V in the TUI
4. Verify "Pasted Text" appears
5. Verify message "Pasted from clipboard!" appears

**Expected**: Clipboard content inserted, success message shown

### Test 6: Partial Selection with Cut
1. Type "Hello World"
2. Press Ctrl+A (select all)
3. Press Ctrl+X (cut)
4. Verify text cleared

**Expected**: Selection works and cut removes selected text

### Test 7: Insert at Cursor
1. Type "HelloWorld"
2. Press Left arrow 5 times (cursor between "Hello" and "World")
3. Type " " (space)
4. Verify result is "Hello World" with cursor after space

**Expected**: Character inserted at cursor position

### Test 8: Backspace with Selection
1. Type "Hello World"
2. Press Ctrl+A (select all)
3. Press Backspace
4. Verify all text deleted

**Expected**: Selection deleted with single backspace

### Test 9: Backspace without Selection
1. Type "Hello"
2. Press Backspace
3. Verify "Hell" remains
4. Cursor at end

**Expected**: Last character deleted

### Test 10: Type Over Selection
1. Type "Old Text"
2. Press Ctrl+A (select all)
3. Type "N"
4. Verify text is now just "N"

**Expected**: Selection replaced with new character

### Test 11: Pattern Navigation Still Works
1. Type "Test"
2. Press Tab
3. Verify pattern changes
4. Press Shift+Tab
5. Verify pattern changes back

**Expected**: Pattern navigation unaffected by new features

### Test 12: Enter Still Copies Rivals Code
1. Type "Test"
2. Press Enter
3. Verify "Copied to clipboard!" message
4. Run: `xclip -selection clipboard -o`
5. Verify output contains Rivals color codes (e.g., "#YT#Oe#Rs#Pt")

**Expected**: Rivals-formatted code copied (not raw text)

### Test 13: Paste with Length Limit
1. Copy long text: `echo -n "$(printf 'A%.0s' {1..100})" | xclip -selection clipboard`
2. Press Ctrl+V
3. Verify only 59 characters inserted

**Expected**: Paste respects 59 character limit

### Test 14: Cut Empty Selection
1. Type "Hello"
2. Press Ctrl+X (without selecting)
3. Verify nothing happens (no error)

**Expected**: No action when no selection

### Test 15: Paste at Different Positions
1. Type "Hello"
2. Press Home
3. Press Ctrl+V (paste "World" if in clipboard)
4. Verify "WorldHello" with cursor after "World"
5. Press End
6. Press Ctrl+V
7. Verify "WorldHelloWorld" with cursor at end

**Expected**: Paste works at any cursor position

### Test 16: All Existing Features Work
- Ctrl+P opens Pattern Manager
- Pattern Manager can create/edit/delete patterns
- Pattern Creator works as before
- Esc quits from main screen
- Ctrl+C exits application
- Ctrl+U clears text

**Expected**: All existing functionality preserved

## Automated Tests (if implemented)

```zsh
# Test cursor position bounds
CURSOR_POS=0
INPUT_TEXT="Hello"
# Simulate moving cursor right
((CURSOR_POS++))
[[ $CURSOR_POS -eq 1 ]] && echo "✓ Cursor increment works"

# Test selection normalization
SELECTION_START=5
SELECTION_END=2
sel_start=$SELECTION_START
sel_end=$SELECTION_END
if [[ $sel_start -gt $sel_end ]]; then
    tmp=$sel_start
    sel_start=$sel_end
    sel_end=$tmp
fi
[[ $sel_start -eq 2 && $sel_end -eq 5 ]] && echo "✓ Selection normalization works"
```

## Edge Cases to Test

1. **Empty text**: All operations on empty input
2. **Max length**: Operations at 59 character limit
3. **Selection at boundaries**: Start=0, End=length
4. **Rapid key presses**: Multiple operations in sequence
5. **Special characters**: Unicode, spaces, symbols in clipboard
6. **Newlines in clipboard**: Should be handled gracefully
7. **Very long clipboard**: Should truncate at 59 chars

## Performance Tests

1. Type 59 characters (should be responsive)
2. Select all 59 characters (should highlight instantly)
3. Cut 59 characters (should be immediate)
4. Paste 59 characters (should not lag)

## Regression Tests

Ensure these still work:
- Rainbow text conversion
- Pattern switching
- Custom pattern creation
- Pattern manager
- All built-in patterns
- Success message display
- UI rendering
- Terminal cleanup on exit

## Acceptance Criteria

All tests must pass with:
- No syntax errors
- No runtime errors
- Expected behavior matches actual behavior
- UI remains responsive
- No visual glitches
- Clipboard operations work correctly
- All existing features still function

## Test Environment

- OS: Linux (Ubuntu/Debian)
- Shell: zsh
- Terminal: Any VT100 compatible
- Clipboard: xclip installed
- File: rivals-tui.zsh (modified version)
