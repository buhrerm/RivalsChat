#!/usr/bin/env zsh

# Test clipboard functionality

CLIPBOARD_CMD=""

# Detect clipboard command
detect_clipboard() {
    if command -v xclip &> /dev/null; then
        CLIPBOARD_CMD="xclip -selection clipboard"
    elif command -v pbcopy &> /dev/null; then
        CLIPBOARD_CMD="pbcopy"
    elif command -v xsel &> /dev/null; then
        CLIPBOARD_CMD="xsel --clipboard"
    else
        CLIPBOARD_CMD=""
    fi
}

# Paste from clipboard
paste_from_clipboard() {
    if [[ -z "$CLIPBOARD_CMD" ]]; then
        return 1
    fi

    local pasted=""
    if command -v xclip &> /dev/null; then
        pasted=$(xclip -selection clipboard -o 2>/dev/null)
    elif command -v pbpaste &> /dev/null; then
        pasted=$(pbpaste 2>/dev/null)
    elif command -v xsel &> /dev/null; then
        pasted=$(xsel --clipboard --output 2>/dev/null)
    fi

    echo -n "$pasted"
}

# Copy raw text to clipboard (not Rivals format)
copy_raw_to_clipboard() {
    local text=$1
    if [[ -z "$CLIPBOARD_CMD" || -z "$text" ]]; then
        return 1
    fi

    echo -n "$text" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
    return $?
}

# Run tests
detect_clipboard

echo "Clipboard command detected: ${CLIPBOARD_CMD:-NONE}"

if [[ -n "$CLIPBOARD_CMD" ]]; then
    echo ""
    echo "Testing copy..."
    if copy_raw_to_clipboard "Test text for clipboard"; then
        echo "✓ Copy successful"
    else
        echo "✗ Copy failed"
    fi

    echo ""
    echo "Testing paste..."
    local pasted=$(paste_from_clipboard)
    if [[ "$pasted" == "Test text for clipboard" ]]; then
        echo "✓ Paste successful: '$pasted'"
    else
        echo "✗ Paste failed or incorrect: '$pasted'"
    fi
else
    echo "No clipboard tool found (xclip, pbcopy, or xsel required)"
fi
