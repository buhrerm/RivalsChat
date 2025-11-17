#!/usr/bin/env zsh

# Simple test to verify arrow key detection
echo "Testing arrow key detection (press q to quit):"
echo "Press arrow keys to test detection"
echo ""

while true; do
    IFS= read -r -s -k 1 char

    case "$char" in
        $'\x1b') # Escape sequences
            IFS= read -r -s -t 0.1 -k 1 char2
            if [[ "$char2" == "[" ]]; then
                IFS= read -r -s -t 0.1 -k 1 char3
                case "$char3" in
                    "A") echo "Up arrow detected" ;;
                    "B") echo "Down arrow detected" ;;
                    "C") echo "Right arrow detected (→)" ;;
                    "D") echo "Left arrow detected (←)" ;;
                    "Z") echo "Shift+Tab detected" ;;
                    *) echo "Unknown escape sequence: ESC [ $char3" ;;
                esac
            fi
            ;;
        $'\t') echo "Tab detected" ;;
        "q")
            echo "Quitting..."
            break
            ;;
        *) echo "Character: '$char'" ;;
    esac
done