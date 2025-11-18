# Text Editor Features - Quick Reference

## New Keyboard Shortcuts

```
┌─────────────────────────────────────────────────────────────┐
│                    TEXT EDITING FEATURES                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  NAVIGATION                                                  │
│  ← / →        Move cursor left/right                         │
│  Home         Jump to start of text                          │
│  End          Jump to end of text                            │
│                                                              │
│  SELECTION                                                   │
│  Ctrl+A       Select all text                                │
│                                                              │
│  CLIPBOARD                                                   │
│  Ctrl+X       Cut selected text                              │
│  Ctrl+V       Paste from clipboard                           │
│                                                              │
│  EDITING                                                     │
│  Backspace    Delete selection or char before cursor         │
│  Ctrl+U       Clear all text                                 │
│  Type         Delete selection (if any) and insert char      │
│                                                              │
│  PATTERN NAVIGATION (unchanged)                              │
│  Tab          Next pattern                                   │
│  Shift+Tab    Previous pattern                               │
│  Ctrl+Left    Previous pattern                               │
│  Ctrl+Right   Next pattern                                   │
│                                                              │
│  OTHER (unchanged)                                           │
│  Enter        Copy Rivals-formatted code to clipboard        │
│  Ctrl+P       Open Pattern Manager                           │
│  Ctrl+C       Exit application                               │
│  Esc          Quit                                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Visual Examples

### Cursor Position Display
```
Input: "Hello_World"
       ↑ cursor is here (position 5)
```

### Text Selection
```
Input: "Hello World"
Selection: chars 0-5 are selected (highlighted)
Display: [Hello] World_
         ^^^^^^ selected (inverted colors)
                      ^ cursor at end of selection
```

### Cut Operation (Ctrl+X)
```
Before: [Hello] World_    (selection shown with brackets)
After:  World_            ("Hello" copied to clipboard)
        ^ cursor moved to where selection started
```

### Paste Operation (Ctrl+V)
```
Clipboard: "Test"
Before: Hello_World       (cursor at position 5)
After:  HelloTest_World   (inserted at cursor)
              ^ cursor moved past pasted text
```

### Select All (Ctrl+A)
```
Before: Hello World_
After:  [Hello World]_
        ^^^^^^^^^^^^^ all text selected
                    ^ cursor at end
```

## Implementation Details

### State Management
```zsh
CURSOR_POS=0           # Current insertion point
SELECTION_START=-1     # -1 means no selection
SELECTION_END=-1       # Range is [START, END)
```

### Selection Rules
1. Always normalized: start <= end
2. Cleared on navigation (arrows, Home, End)
3. Replaced when typing
4. Used by Backspace, Cut, and typing

### Clipboard Functions
```zsh
copy_raw_to_clipboard(text)    # Copy raw text (for Cut)
paste_from_clipboard()         # Read from clipboard (for Paste)
copy_to_clipboard()            # Copy Rivals code (for Enter) [existing]
```

## Testing Checklist

- [x] Cursor movement (left/right arrows)
- [x] Home/End keys
- [x] Select all (Ctrl+A)
- [x] Cut (Ctrl+X)
- [x] Paste (Ctrl+V)
- [x] Backspace with selection
- [x] Typing with selection
- [x] Selection display
- [x] Cursor position display
- [x] Clipboard integration
- [x] Pattern navigation still works
- [x] Enter still copies Rivals code
- [x] Ctrl+P still opens Pattern Manager
- [x] All existing features preserved

## Browser Compatibility

### Clipboard Tools Supported
- **Linux**: xclip, xsel
- **macOS**: pbcopy/pbpaste
- **Windows**: Not supported (WSL users can install xclip)

### Terminal Requirements
- VT100/ANSI compatible terminal
- Support for escape sequences
- Proper handling of Ctrl key combinations

## Known Limitations

1. **No Mouse Support**: Selection is keyboard-only
2. **No Shift+Arrow Selection**: Would require complex escape sequence handling
3. **Character Limit**: 59 characters maximum (existing limitation)
4. **No Undo/Redo**: Could be added in future
5. **Ctrl+C = Exit**: Cannot use Ctrl+C for copy (uses Ctrl+X instead)

## Future Enhancements (Not Implemented)

- Shift+Arrow for selection
- Mouse selection support
- Undo/Redo (Ctrl+Z/Ctrl+Y)
- Find/Replace (Ctrl+F)
- Word movement (Ctrl+Left/Right) - currently used for patterns
- Delete key support
- Copy without cut (would need different key combo)
