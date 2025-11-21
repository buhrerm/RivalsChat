#!/usr/bin/env zsh

# clipboard.zsh - Clipboard utilities
# Handles clipboard detection and operations across different platforms

source "${0:A:h}/../state/app_state.zsh"

# Detect available clipboard command
clipboard_detect() {
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

# Check if clipboard is available
clipboard_available() {
    [[ -n "$CLIPBOARD_CMD" ]]
}

# Copy text to clipboard
clipboard_copy() {
    local text=$1
    if [[ -z "$CLIPBOARD_CMD" || -z "$text" ]]; then
        return 1
    fi
    echo -n "$text" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
    return $?
}

# Paste from clipboard
clipboard_paste() {
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
