#!/usr/bin/env zsh

# Marvel Rivals Rainbow Converter - Beautiful TUI
# Type text, Tab to switch patterns, Enter to copy, Esc to quit

# Marvel Rivals Color Codes (matching the game)
typeset -A RIVALS=(
    Y "Gold" O "Orange" R "Red" P "Pink" M "Really Pink"
    U "Purple" B "Blue" I "Dark Blue" A "Teal"
    T "Blue Green" G "Green" E "Green Yellow" K "Yellow"
)

# ANSI colors for preview
typeset -A COLORS=(
    Y '\033[38;5;226m' O '\033[38;5;208m' R '\033[38;5;196m'
    P '\033[38;5;205m' M '\033[38;5;199m' U '\033[38;5;135m'
    B '\033[38;5;33m'  I '\033[38;5;27m'  A '\033[38;5;51m'
    T '\033[38;5;45m'  G '\033[38;5;46m'  E '\033[38;5;154m'
    K '\033[38;5;190m'
)

# Fire colors (Warm)
FIRE_RED='\033[38;2;255;0;0m'
FIRE_ORANGE='\033[38;2;255;69;0m'
FIRE_DEEP_ORANGE='\033[38;2;255;140;0m'
FIRE_GOLD='\033[38;2;255;215;0m'
FIRE_YELLOW='\033[38;2;255;255;0m'

# Ice colors (Cool)
ICE_CYAN='\033[38;2;0;255;255m'
ICE_SKY='\033[38;2;135;206;250m'
ICE_BLUE='\033[38;2;0;191;255m'
ICE_DEEP='\033[38;2;0;0;255m'
ICE_PURPLE='\033[38;2;138;43;226m'

# UI Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ACCENT='\033[38;2;0;255;255m'
SUCCESS='\033[38;2;0;255;0m'
BORDER='\033[38;2;100;100;255m'
TEXT='\033[38;2;200;200;255m'
HIGHLIGHT='\033[38;2;255;255;0m'

# Box drawing characters
TL='╔'
TR='╗'
BL='╚'
BR='╝'
H='═'
V='║'
VR='╠'
VL='╣'
HU='╩'
HD='╦'
CROSS='╬'

# Pattern definitions (using Marvel Rivals codes)
RAINBOW_PATTERN=(Y O R P M U B I A T G E K)  # Full 13-color spectrum
WARM_PATTERN=(Y O R P M)                     # Fire colors
COOL_PATTERN=(U B I A T G)                   # Ice colors

typeset -A PATTERNS
PATTERNS=(
    0 "Rainbow"
    1 "Warm"
    2 "Cool"
)

# Initialize state
INPUT_TEXT=""
CURRENT_PATTERN=0
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

# Convert text to Marvel Rivals code
convert_to_rivals() {
    local text=$1
    local pattern_idx=$2
    local result=""
    local color_idx=0
    local pattern=()

    # Select pattern
    case $pattern_idx in
        0) pattern=($RAINBOW_PATTERN) ;;
        1) pattern=($WARM_PATTERN) ;;
        2) pattern=($COOL_PATTERN) ;;
    esac

    # Convert each character
    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${pattern[$((color_idx % ${#pattern[@]}))]}"
            result+="#${color}${char}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Generate rainbow preview
generate_rainbow() {
    local text=$1
    local pattern_idx=$2
    local result=""
    local color_idx=0
    local pattern=()

    # Select pattern
    case $pattern_idx in
        0) pattern=($RAINBOW_PATTERN) ;;
        1) pattern=($WARM_PATTERN) ;;
        2) pattern=($COOL_PATTERN) ;;
    esac

    if [[ ${#text} -eq 0 ]]; then
        echo ""
        return
    fi

    # Apply colors to each character
    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color_code="${pattern[$((color_idx % ${#pattern[@]}))]}"
            result+="${COLORS[$color_code]}${char}${RESET}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Draw header
draw_header() {
    local width=70
    echo -ne "${BORDER}${TL}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${TR}${RESET}"

    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╔═══╗ ╔══╗ ╔╗  ╔╗ ╔═══╗ ╔╗    ╔═══╗  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔═╗║ ╚╣╠╝ ║╚╗╔╝║ ║╔═╗║ ║║    ║╔═╗║  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╚═╝║  ║║  ╚╗║║╔╝ ║║ ║║ ║║    ║╚══╗  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔╗╔╝  ║║   ║╚╝║  ║╚═╝║ ║║    ╚══╗║  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║║║╚╗ ╔╣╠╗  ╚╗╔╝  ║╔═╗║ ║╚═╗  ║╚═╝║  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╚╝╚═╝ ╚══╝   ╚╝   ╚╝ ╚╝ ╚══╝  ╚═══╝  ${RESET}                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}          ${TEXT}Rainbow Text Converter for Marvel Rivals${RESET}            ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"
}

# Draw input section
draw_input_section() {
    local width=70
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Type your text:${RESET}                                                 ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌────────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    # Display input with cursor
    local display_text="${INPUT_TEXT}_"
    local padded=$(printf "%-62s" "$display_text")
    echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${HIGHLIGHT}${padded:0:62}${RESET} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"

    echo -e "${BORDER}${V}${RESET}  ${DIM}└────────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
}

# Draw preview section
draw_preview_section() {
    local width=70
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Preview:${RESET}                                                        ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌────────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    if [[ -z "$INPUT_TEXT" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${DIM}Type something to see the magic...${RESET}                          ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    else
        local rainbow=$(generate_rainbow "$INPUT_TEXT" $CURRENT_PATTERN)
        local padded=$(printf "%-62s" "$rainbow")
        # Note: padding won't work perfectly with colors, but it's close enough
        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} $rainbow$(printf ' %.0s' {1..30}) ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}  ${DIM}└────────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
}

# Draw pattern selector
draw_pattern_selector() {
    local width=70
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Pattern:${RESET}                                                        ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"

    # Pattern buttons
    local p0_style p1_style p2_style
    if [[ $CURRENT_PATTERN -eq 0 ]]; then
        p0_style="${ACCENT}${BOLD}[● Rainbow]${RESET}"
    else
        p0_style="${DIM}[○ Rainbow]${RESET}"
    fi

    if [[ $CURRENT_PATTERN -eq 1 ]]; then
        p1_style="${FIRE_ORANGE}${BOLD}[● Warm]${RESET}"
    else
        p1_style="${DIM}[○ Warm]${RESET}"
    fi

    if [[ $CURRENT_PATTERN -eq 2 ]]; then
        p2_style="${ICE_CYAN}${BOLD}[● Cool]${RESET}"
    else
        p2_style="${DIM}[○ Cool]${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}       $p0_style      $p1_style      $p2_style             ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
}

# Draw controls
draw_controls() {
    local width=70
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"

    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}Controls:${RESET}  ${TEXT}Tab${RESET}${DIM} Switch Pattern  ${TEXT}Enter${RESET}${DIM} Copy  ${TEXT}Esc${RESET}${DIM} Quit${RESET}          ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}                                                                    ${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${BR}${RESET}"
}

# Draw success message
draw_success() {
    local msg=$1
    tput cup $((LINES/2)) $((COLS/2 - ${#msg}/2))
    echo -ne "${SUCCESS}${BOLD}${msg}${RESET}"
    sleep 1.5
}

# Draw complete UI
draw_ui() {
    clear
    tput cup 0 0
    draw_header
    draw_input_section
    draw_preview_section
    draw_pattern_selector
    draw_controls
}

# Copy to clipboard
copy_to_clipboard() {
    if [[ -z "$CLIPBOARD_CMD" ]]; then
        return 1
    fi

    if [[ -z "$INPUT_TEXT" ]]; then
        return 1
    fi

    # Copy the Rivals code format, not the preview
    local rivals_code=$(convert_to_rivals "$INPUT_TEXT" $CURRENT_PATTERN)
    echo -n "$rivals_code" | eval "$CLIPBOARD_CMD" 2>/dev/null
    return $?
}

# Cleanup on exit
cleanup() {
    tput rmcup
    tput cnorm
    stty echo
    echo -e "\n${ACCENT}${BOLD}Thanks for using Rivals Rainbow Converter!${RESET}\n"
}

# Handle signals
trap cleanup EXIT INT TERM

# Main loop
main() {
    # Setup
    detect_clipboard

    # Enter alternate screen
    tput smcup
    tput civis
    stty -echo

    # Initial draw
    draw_ui

    # Input loop
    while true; do
        # Read single character
        local char
        read -k 1 char

        case "$char" in
            $'\x1b') # Escape sequences
                read -t 0.1 -k 1 char2
                if [[ -z "$char2" ]]; then
                    # Just ESC - quit
                    break
                elif [[ "$char2" == "[" ]]; then
                    read -t 0.1 -k 1 char3
                    case "$char3" in
                        "Z") # Shift+Tab
                            CURRENT_PATTERN=$(( (CURRENT_PATTERN - 1 + 3) % 3 ))
                            draw_ui
                            ;;
                    esac
                fi
                ;;
            $'\t') # Tab - switch pattern
                CURRENT_PATTERN=$(( (CURRENT_PATTERN + 1) % 3 ))
                draw_ui
                ;;
            $'\n'|$'\r') # Enter - copy
                if copy_to_clipboard; then
                    draw_ui
                    tput cup $((LINES/2)) $((COLS/2 - 15))
                    echo -ne "${SUCCESS}${BOLD}✓ Copied to clipboard!${RESET}"
                    sleep 1
                    draw_ui
                fi
                ;;
            $'\x7f'|$'\b') # Backspace
                if [[ ${#INPUT_TEXT} -gt 0 ]]; then
                    INPUT_TEXT="${INPUT_TEXT:0:-1}"
                    draw_ui
                fi
                ;;
            $'\x15') # Ctrl+U - clear line
                INPUT_TEXT=""
                draw_ui
                ;;
            *) # Regular character
                if [[ ${#INPUT_TEXT} -lt 60 ]]; then
                    INPUT_TEXT+="$char"
                    draw_ui
                fi
                ;;
        esac
    done
}

# Run
main
