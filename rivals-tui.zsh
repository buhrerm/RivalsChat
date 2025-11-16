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
# NOTE: Zsh arrays are 1-indexed by default
RAINBOW_PATTERN=(Y O R P M U B I A T G E K)  # Full 13-color spectrum
WARM_PATTERN=(Y O R P M)                     # Fire colors
COOL_PATTERN=(U B I A T G)                   # Ice colors
NEON_PATTERN=(E G T A B U)                   # Electric neon colors
SUNSET_PATTERN=(Y E O R P M)                 # Warm gradient sunset
OCEAN_PATTERN=(B I A T G)                    # Deep sea colors
PSYCHEDELIC_PATTERN=(M U E O A R)            # Alternating vibrant
SPRING_PATTERN=(G E Y O P)                   # Fresh spring colors
CHERRY_PATTERN=(P M R O Y)                   # Cherry blossom gradient
MATRIX_PATTERN=(G T A)                       # Matrix green vibes

# Pattern metadata - MUST be in same order as patterns
PATTERN_NAMES=("Rainbow" "Warm" "Cool" "Neon" "Sunset" "Ocean" "Psychedelic" "Spring" "Cherry" "Matrix")
PATTERN_ICONS=("🌈" "🔥" "❄️" "⚡" "🌅" "🌊" "🎨" "🌸" "🍒" "💚")

# Total number of patterns
NUM_PATTERNS=${#PATTERN_NAMES[@]}

# Initialize state
INPUT_TEXT=""
CURRENT_PATTERN=1  # Using 1-based indexing for Zsh arrays
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

# Get pattern array by index (1-based)
# Returns the pattern name to be used with eval
get_pattern_name() {
    local idx=$1
    case $idx in
        1) echo "RAINBOW_PATTERN" ;;
        2) echo "WARM_PATTERN" ;;
        3) echo "COOL_PATTERN" ;;
        4) echo "NEON_PATTERN" ;;
        5) echo "SUNSET_PATTERN" ;;
        6) echo "OCEAN_PATTERN" ;;
        7) echo "PSYCHEDELIC_PATTERN" ;;
        8) echo "SPRING_PATTERN" ;;
        9) echo "CHERRY_PATTERN" ;;
        10) echo "MATRIX_PATTERN" ;;
    esac
}

# Convert text to Marvel Rivals code
convert_to_rivals() {
    local text=$1
    local pattern_idx=$2
    local result=""
    local color_idx=1  # Zsh arrays are 1-indexed

    # Get pattern array using indirect reference
    local pattern_name=$(get_pattern_name $pattern_idx)
    local -a pattern
    eval "pattern=(\${${pattern_name}[@]})"

    # Convert each character
    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            # Use 1-based array indexing
            local color="${pattern[$(( ((color_idx - 1) % ${#pattern[@]}) + 1 ))]}"
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
    local color_idx=1  # Zsh arrays are 1-indexed

    # Get pattern array using indirect reference
    local pattern_name=$(get_pattern_name $pattern_idx)
    local -a pattern
    eval "pattern=(\${${pattern_name}[@]})"

    if [[ ${#text} -eq 0 ]]; then
        echo ""
        return
    fi

    # Apply colors to each character
    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            # Use 1-based array indexing
            local color_code="${pattern[$(( ((color_idx - 1) % ${#pattern[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${char}${RESET}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Strip ANSI color codes from text to measure actual length
strip_ansi() {
    local text=$1
    # Remove ANSI escape sequences
    echo -n "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Get visible length of text (without ANSI codes)
visible_length() {
    local text=$1
    local stripped=$(strip_ansi "$text")
    echo ${#stripped}
}

# Draw header
draw_header() {
    local width=70
    echo -ne "${BORDER}${TL}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${TR}${RESET}"

    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    # Logo lines - each logo line is exactly 35 visible chars, need 31 spaces after (2 + 35 + 31 = 68)
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╔═══╗ ╔══╗ ╔╗  ╔╗ ╔═══╗ ╔╗    ╔═══╗${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔═╗║ ╚╣╠╝ ║╚╗╔╝║ ║╔═╗║ ║║    ║╔═╗║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╚═╝║  ║║  ╚╗║║╔╝ ║║ ║║ ║║    ║╚══╗${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔╗╔╝  ║║   ║╚╝║  ║╚═╝║ ║║    ╚══╗║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║║║╚╗ ╔╣╠╗  ╚╗╔╝  ║╔═╗║ ║╚═╗  ║╚═╝║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╚╝╚═╝ ╚══╝   ╚╝   ╚╝ ╚╝ ╚══╝  ╚═══╝${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    # Subtitle - "Rainbow Text Converter for Marvel Rivals" is 40 chars, centered
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..14})${TEXT}Rainbow Text Converter for Marvel Rivals${RESET}$(printf ' %.0s' {1..14})${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"
}

# Draw input section
draw_input_section() {
    local width=70
    local content_width=60  # Actual usable content area (text inside the box)
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    # "Type your text:" is 15 chars, 2 spaces prefix = 17 chars, need 51 spaces after
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Type your text:${RESET}$(printf ' %.0s' {1..51})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌──────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    # Display input with cursor - truncate if too long
    local display_text="${INPUT_TEXT}_"
    if [[ ${#display_text} -gt $content_width ]]; then
        display_text="${display_text:0:$content_width}"
    fi

    # Calculate padding needed (no ANSI codes in input, so simple calculation)
    local padding_needed=$((content_width - ${#display_text}))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${HIGHLIGHT}${display_text}${RESET}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"

    echo -e "${BORDER}${V}${RESET}  ${DIM}└──────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
}

# Draw preview section
draw_preview_section() {
    local width=70
    local content_width=60  # Actual usable content area (text inside the box)
    # "Preview:" is 8 chars, 2 spaces prefix = 10 chars, need 58 spaces after
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Preview:${RESET}$(printf ' %.0s' {1..58})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌──────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    if [[ -z "$INPUT_TEXT" ]]; then
        local empty_msg="${DIM}Type something to see the magic...${RESET}"
        local visible_len=$(visible_length "$empty_msg")
        local padding_needed=$((content_width - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})
        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${empty_msg}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    else
        local rainbow=$(generate_rainbow "$INPUT_TEXT" $CURRENT_PATTERN)
        # Calculate visible length (without ANSI codes)
        local visible_len=$(visible_length "$rainbow")

        # Truncate if too long
        if [[ $visible_len -gt $content_width ]]; then
            # Count visible characters and truncate
            local char_count=0
            local truncated=""
            local in_ansi=0
            for ((i=1; i<=${#rainbow}; i++)); do
                local char="${rainbow:$((i-1)):1}"
                if [[ "$char" == $'\033' ]]; then
                    in_ansi=1
                fi
                if [[ $in_ansi -eq 1 ]]; then
                    truncated+="$char"
                    if [[ "$char" == "m" ]]; then
                        in_ansi=0
                    fi
                else
                    if [[ $char_count -lt $content_width ]]; then
                        truncated+="$char"
                        ((char_count++))
                    else
                        break
                    fi
                fi
            done
            rainbow="$truncated${RESET}"
            visible_len=$content_width
        fi

        # Calculate padding needed
        local padding_needed=$((content_width - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})

        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${rainbow}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}  ${DIM}└──────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
}

# Draw pattern selector with scrolling support
draw_pattern_selector() {
    local width=70
    # "Pattern: (Tab to cycle)" = 23 chars, with 2 spaces prefix = 25, need 43 spaces after
    local pattern_label="${TEXT}Pattern:${RESET} ${DIM}(Tab to cycle)${RESET}"
    local visible_len=23  # "Pattern: (Tab to cycle)" without ANSI codes
    local padding_needed=$((68 - 2 - visible_len))  # 68 - 2 - 23 = 43
    local padding=$(printf ' %.0s' {1..$padding_needed})
    echo -e "${BORDER}${V}${RESET}  ${pattern_label}${padding}${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Show current pattern with icon and sample colors
    local current_name="${PATTERN_NAMES[$CURRENT_PATTERN]}"
    local current_icon="${PATTERN_ICONS[$CURRENT_PATTERN]}"

    # Get pattern array using indirect reference
    local pattern_name=$(get_pattern_name $CURRENT_PATTERN)
    local -a pattern
    eval "pattern=(\${${pattern_name}[@]})"

    # Generate color samples - build a string we can measure
    local color_sample_plain=""  # For length calculation
    local color_sample_colored="" # For display
    for color_code in ${pattern[@]}; do
        color_sample_plain+="●"
        color_sample_colored+="${COLORS[$color_code]}●${RESET}"
    done

    # Build pattern display components
    # Format: "🌈 Rainbow ●●●●●●●●●●●●● (1/10)"
    # Calculate visible lengths
    local icon_len=${#current_icon}  # Emoji is typically 2 bytes but displays as 1-2 chars
    local name_len=${#current_name}
    local dots_len=${#color_sample_plain}
    local info_text="(${CURRENT_PATTERN}/${NUM_PATTERNS})"
    local info_len=${#info_text}

    # Total visible length: icon + space + name + space + dots + space + info
    # Account for emoji width (most emojis display as 2 chars wide)
    local visible_total=$((2 + 1 + name_len + 1 + dots_len + 1 + info_len))

    # Calculate padding for centered display
    local padding_left=$(( (68 - visible_total) / 2 ))
    local padding_right=$(( 68 - visible_total - padding_left ))

    # Ensure padding is at least 0
    if [[ $padding_left -lt 0 ]]; then
        padding_left=0
    fi
    if [[ $padding_right -lt 0 ]]; then
        padding_right=0
    fi

    local left_pad=$(printf ' %.0s' {1..$padding_left})
    local right_pad=$(printf ' %.0s' {1..$padding_right})

    # Build the full display line
    echo -e "${BORDER}${V}${RESET}${left_pad}${current_icon} ${ACCENT}${BOLD}${current_name}${RESET} ${color_sample_colored} ${DIM}${info_text}${RESET}${right_pad}${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
}

# Draw controls
draw_controls() {
    local width=70
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"

    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    # Controls line: "Controls:  Tab Cycle Pattern  Enter Copy  Esc Quit"
    # Visible: "Controls:" (9) + "  " (2) + "Tab" (3) + " Cycle Pattern  " (16) + "Enter" (5) + " Copy  " (7) + "Esc" (3) + " Quit" (5) = 50 chars
    # With 2 spaces prefix = 52, need 16 spaces after
    local controls_text="${DIM}Controls:${RESET}  ${TEXT}Tab${RESET}${DIM} Cycle Pattern  ${TEXT}Enter${RESET}${DIM} Copy  ${TEXT}Esc${RESET}${DIM} Quit${RESET}"
    local visible_len=50  # Calculated visible length without ANSI codes
    local padding_needed=$((68 - 2 - visible_len))
    local padding=$(printf ' %.0s' {1..$padding_needed})
    echo -e "${BORDER}${V}${RESET}  ${controls_text}${padding}${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${BR}${RESET}"
}

# Draw success message (within TUI boundaries)
draw_success() {
    local width=70
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"

    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    # "✓ Copied to clipboard!" is 22 chars (✓ is 1 char), centered
    local success_msg="${SUCCESS}${BOLD}✓ Copied to clipboard!${RESET}"
    local visible_len=22
    local padding_left=$(( (68 - visible_len) / 2 ))  # (68-22)/2 = 23
    local padding_right=$(( 68 - visible_len - padding_left ))  # 68-22-23 = 23
    local left_pad=$(printf ' %.0s' {1..$padding_left})
    local right_pad=$(printf ' %.0s' {1..$padding_right})
    echo -e "${BORDER}${V}${RESET}${left_pad}${success_msg}${right_pad}${BORDER}${V}${RESET}"
    # Empty line
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${BR}${RESET}"
}

# Draw complete UI
draw_ui() {
    # Always position cursor at top-left
    tput cup 0 0
    # Clear from cursor to end of screen to remove old content
    tput ed
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
    echo -n "$rivals_code" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
    return $?
}

# Cleanup on exit - restores terminal to normal state
cleanup() {
    # Restore cursor, exit alternate screen, re-enable echo
    tput cnorm 2>/dev/null
    tput rmcup 2>/dev/null
    stty echo 2>/dev/null
    # Clear any partial line output
    echo -ne "\r\033[K"
    echo -e "\n${ACCENT}${BOLD}Thanks for using Rivals Rainbow Converter!${RESET}\n"
    # Ensure we exit the script completely
    exit 0
}

# Handle signals - proper Ctrl+C handling
# The trap ensures cleanup runs on EXIT, INT (Ctrl+C), and TERM signals
trap cleanup EXIT INT TERM

# Main loop
main() {
    # Setup
    detect_clipboard

    # Enter alternate screen buffer (like vim/less do)
    tput smcup
    # Clear the entire screen
    clear
    # Hide cursor for cleaner UI
    tput civis
    # Disable echo so keypresses don't show
    # Also set up stty to handle Ctrl+C properly
    stty -echo -icanon min 0

    # Initial draw
    draw_ui

    # Input loop
    while true; do
        # Read single character without debug output
        local char
        # Redirect stderr to /dev/null to suppress any debug output
        if ! IFS= read -r -s -k 1 char 2>/dev/null; then
            exit 0
        fi

        case "$char" in
            $'\x1b') # Escape sequences
                # Read additional characters for escape sequences
                IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                if [[ -z "$char2" ]]; then
                    # Just ESC - quit
                    break
                elif [[ "$char2" == "[" ]]; then
                    IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                    case "$char3" in
                        "Z") # Shift+Tab - cycle backwards
                            CURRENT_PATTERN=$(( ((CURRENT_PATTERN - 2 + NUM_PATTERNS) % NUM_PATTERNS) + 1 ))
                            draw_ui
                            ;;
                    esac
                fi
                ;;
            $'\t') # Tab - cycle forward through patterns
                CURRENT_PATTERN=$(( (CURRENT_PATTERN % NUM_PATTERNS) + 1 ))
                draw_ui
                ;;
            $'\n'|$'\r') # Enter - copy to clipboard
                if copy_to_clipboard; then
                    tput cup 0 0
                    tput ed
                    draw_header
                    draw_input_section
                    draw_preview_section
                    draw_pattern_selector
                    draw_success
                    sleep 1
                    draw_ui
                fi
                ;;
            $'\x7f'|$'\b') # Backspace - delete last character
                if [[ ${#INPUT_TEXT} -gt 0 ]]; then
                    INPUT_TEXT="${INPUT_TEXT:0:-1}"
                    draw_ui
                fi
                ;;
            $'\x15') # Ctrl+U - clear entire line
                INPUT_TEXT=""
                draw_ui
                ;;
            $'\x03') # Ctrl+C - exit gracefully
                exit 0  # Exit immediately, cleanup will run via trap
                ;;
            *) # Regular character - add to input
                # Limit input to 59 characters to fit in box (60 - 1 for cursor)
                if [[ ${#INPUT_TEXT} -lt 59 ]]; then
                    INPUT_TEXT+="$char"
                    draw_ui
                fi
                ;;
        esac
    done
}

# Run the application
main

# Ensure clean exit without any debug output
exit 0