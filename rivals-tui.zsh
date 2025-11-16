#!/usr/bin/env zsh

# Marvel Rivals Rainbow Converter - Enhanced TUI with Custom Pattern Creator
# Type text, Tab to switch patterns, Enter to copy, Esc to quit
# Press 'P' to enter Pattern Creator mode

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

# UI Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ACCENT='\033[38;2;0;255;255m'
SUCCESS='\033[38;2;0;255;0m'
BORDER='\033[38;2;100;100;255m'
TEXT='\033[38;2;200;200;255m'
HIGHLIGHT='\033[38;2;255;255;0m'
ERROR='\033[38;2;255;0;0m'
SELECTED='\033[48;2;50;50;150m'

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

# Configuration
CONFIG_DIR="${HOME}/.config/rivals"
PATTERNS_FILE="${CONFIG_DIR}/custom_patterns.json"

# Built-in patterns (stored as associative array)
typeset -A BUILTIN_PATTERNS=(
    "Rainbow" "Y O R P M U B I A T G E K"
    "Warm" "Y O R P M"
    "Cool" "U B I A T G"
    "Neon" "E G T A B U"
    "Sunset" "Y E O R P M"
    "Ocean" "B I A T G"
    "Psychedelic" "M U E O A R"
    "Spring" "G E Y O P"
    "Cherry" "P M R O Y"
    "Matrix" "G T A"
)

typeset -A BUILTIN_ICONS=(
    "Rainbow" "🌈"
    "Warm" "🔥"
    "Cool" "❄️"
    "Neon" "⚡"
    "Sunset" "🌅"
    "Ocean" "🌊"
    "Psychedelic" "🎨"
    "Spring" "🌸"
    "Cherry" "🍒"
    "Matrix" "💚"
)

# Dynamic pattern storage
typeset -A ALL_PATTERNS
typeset -A ALL_ICONS
typeset -a PATTERN_ORDER  # Maintains order of patterns

# Initialize state
INPUT_TEXT=""
CURRENT_PATTERN_INDEX=1
CLIPBOARD_CMD=""
CURRENT_MODE="main"  # main, pattern_creator, pattern_manager
SHOW_SUCCESS=0
SUCCESS_MSG=""

# Pattern creator state
typeset -a CREATOR_COLORS
CREATOR_NAME=""
CREATOR_ICON=""
CREATOR_CURSOR=1
CREATOR_COLOR_CURSOR=1
CREATOR_MODE="name"  # name, icon, colors, preview

# Pattern manager state
MANAGER_CURSOR=1
MANAGER_ACTION=""  # edit, delete

# Initialize configuration directory
init_config() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi

    # Create default patterns file if it doesn't exist
    if [[ ! -f "$PATTERNS_FILE" ]]; then
        echo '{"patterns": {}}' > "$PATTERNS_FILE"
    fi
}

# Load patterns from file and built-ins
load_patterns() {
    ALL_PATTERNS=()
    ALL_ICONS=()
    PATTERN_ORDER=()

    # First, add built-in patterns
    for name in Rainbow Warm Cool Neon Sunset Ocean Psychedelic Spring Cherry Matrix; do
        ALL_PATTERNS[$name]="${BUILTIN_PATTERNS[$name]}"
        ALL_ICONS[$name]="${BUILTIN_ICONS[$name]}"
        PATTERN_ORDER+=("$name")
    done

    # Then, load custom patterns from file
    if [[ -f "$PATTERNS_FILE" ]] && command -v jq &>/dev/null; then
        # Parse JSON and add custom patterns
        local json=$(cat "$PATTERNS_FILE")
        local names=$(echo "$json" | jq -r '.patterns | keys[]' 2>/dev/null)

        while IFS= read -r name; do
            if [[ -n "$name" ]]; then
                local pattern=$(echo "$json" | jq -r ".patterns[\"$name\"].pattern" 2>/dev/null)
                local icon=$(echo "$json" | jq -r ".patterns[\"$name\"].icon" 2>/dev/null)

                if [[ -n "$pattern" ]]; then
                    ALL_PATTERNS[$name]="$pattern"
                    ALL_ICONS[$name]="${icon:-🎨}"
                    PATTERN_ORDER+=("$name")
                fi
            fi
        done <<< "$names"
    elif [[ -f "$PATTERNS_FILE" ]]; then
        # Fallback: simple text parsing if jq is not available
        while IFS='|' read -r name pattern icon; do
            if [[ -n "$name" && -n "$pattern" ]]; then
                ALL_PATTERNS[$name]="$pattern"
                ALL_ICONS[$name]="${icon:-🎨}"
                PATTERN_ORDER+=("$name")
            fi
        done < <(grep -E '^[^#]' "$PATTERNS_FILE" 2>/dev/null || true)
    fi
}

# Save custom patterns to file
save_patterns() {
    local json='{"patterns": {'
    local first=1

    for name in "${PATTERN_ORDER[@]}"; do
        # Skip built-in patterns
        if [[ -n "${BUILTIN_PATTERNS[$name]}" ]]; then
            continue
        fi

        if [[ $first -eq 0 ]]; then
            json+=', '
        fi
        first=0

        # Escape name and pattern for JSON
        local escaped_name=$(echo "$name" | sed 's/"/\\"/g')
        local escaped_pattern="${ALL_PATTERNS[$name]}"
        local escaped_icon="${ALL_ICONS[$name]}"

        json+="\"$escaped_name\": {\"pattern\": \"$escaped_pattern\", \"icon\": \"$escaped_icon\"}"
    done

    json+='}}'

    echo "$json" > "$PATTERNS_FILE"
}

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
    local pattern_name=$2
    local result=""
    local color_idx=1

    local -a pattern
    pattern=(${=ALL_PATTERNS[$pattern_name]})

    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
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
    local pattern_name=$2
    local result=""
    local color_idx=1

    local -a pattern
    pattern=(${=ALL_PATTERNS[$pattern_name]})

    if [[ ${#text} -eq 0 ]]; then
        echo ""
        return
    fi

    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color_code="${pattern[$(( ((color_idx - 1) % ${#pattern[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${char}${RESET}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Strip ANSI color codes
strip_ansi() {
    local text=$1
    echo -n "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Get visible length
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

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╔═══╗ ╔══╗ ╔╗  ╔╗ ╔═══╗ ╔╗    ╔═══╗${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔═╗║ ╚╣╠╝ ║╚╗╔╝║ ║╔═╗║ ║║    ║╔═╗║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╚═╝║  ║║  ╚╗║║╔╝ ║║ ║║ ║║    ║╚══╗${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║╔╗╔╝  ║║   ║╚╝║  ║╚═╝║ ║║    ╚══╗║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}║║║╚╗ ╔╣╠╗  ╚╗╔╝  ║╔═╗║ ║╚═╗  ║╚═╝║${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}╚╝╚═╝ ╚══╝   ╚╝   ╚╝ ╚╝ ╚══╝  ╚═══╝${RESET}$(printf ' %.0s' {1..31})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..14})${TEXT}Rainbow Text Converter for Marvel Rivals${RESET}$(printf ' %.0s' {1..14})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((width-2))}
    echo -e "${VL}${RESET}"
}

# Draw main mode interface
draw_main_mode() {
    # Input section
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Type your text:${RESET}$(printf ' %.0s' {1..51})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌──────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    local display_text="${INPUT_TEXT}_"
    if [[ ${#display_text} -gt 60 ]]; then
        display_text="${display_text:0:60}"
    fi

    local padding_needed=$((60 - ${#display_text}))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${HIGHLIGHT}${display_text}${RESET}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}└──────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Preview section
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Preview:${RESET}$(printf ' %.0s' {1..58})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}┌──────────────────────────────────────────────────────────────┐${RESET}  ${BORDER}${V}${RESET}"

    if [[ -z "$INPUT_TEXT" ]]; then
        local empty_msg="${DIM}Type something to see the magic...${RESET}"
        local visible_len=34
        local padding_needed=$((60 - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})
        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${empty_msg}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    else
        local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
        local rainbow=$(generate_rainbow "$INPUT_TEXT" "$current_pattern")
        local visible_len=$(visible_length "$rainbow")

        if [[ $visible_len -gt 60 ]]; then
            # Truncate if too long (complex logic omitted for brevity)
            visible_len=60
        fi

        local padding_needed=$((60 - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})

        echo -e "${BORDER}${V}${RESET}  ${DIM}│${RESET} ${rainbow}${padding} ${DIM}│${RESET}  ${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}  ${DIM}└──────────────────────────────────────────────────────────────┘${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Pattern selector with navigation
    local total_patterns=${#PATTERN_ORDER[@]}
    local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
    local current_icon="${ALL_ICONS[$current_pattern]}"

    echo -e "${BORDER}${V}${RESET}  ${TEXT}Pattern:${RESET} ${DIM}(Tab/Shift+Tab to navigate, P for pattern manager)${RESET}$(printf ' %.0s' {1..14})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Show current pattern with navigation hints
    local -a pattern_colors
    pattern_colors=(${=ALL_PATTERNS[$current_pattern]})

    local color_sample=""
    for color_code in ${pattern_colors[@]}; do
        color_sample+="${COLORS[$color_code]}●${RESET}"
    done

    local is_custom=""
    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        is_custom=" ${DIM}[Custom]${RESET}"
    fi

    # Previous pattern hint
    local prev_index=$(( CURRENT_PATTERN_INDEX == 1 ? total_patterns : CURRENT_PATTERN_INDEX - 1 ))
    local prev_pattern="${PATTERN_ORDER[$prev_index]}"
    local prev_icon="${ALL_ICONS[$prev_pattern]}"

    # Next pattern hint
    local next_index=$(( CURRENT_PATTERN_INDEX == total_patterns ? 1 : CURRENT_PATTERN_INDEX + 1 ))
    local next_pattern="${PATTERN_ORDER[$next_index]}"
    local next_icon="${ALL_ICONS[$next_pattern]}"

    echo -e "${BORDER}${V}${RESET}  ${DIM}← ${prev_icon}${RESET}  ${current_icon} ${ACCENT}${BOLD}${current_pattern}${RESET}${is_custom} ${color_sample} ${DIM}(${CURRENT_PATTERN_INDEX}/${total_patterns})${RESET}  ${DIM}${next_icon} →${RESET}  ${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Controls
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${VL}${RESET}"

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${DIM}${TEXT}Tab${RESET}${DIM} Next  ${TEXT}Shift+Tab${RESET}${DIM} Prev  ${TEXT}Enter${RESET}${DIM} Copy  ${TEXT}P${RESET}${DIM} Patterns  ${TEXT}Esc${RESET}${DIM} Quit${RESET}$(printf ' %.0s' {1..9})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Success message if needed
    if [[ $SHOW_SUCCESS -eq 1 ]]; then
        echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..23})${SUCCESS}${BOLD}✓ ${SUCCESS_MSG}${RESET}$(printf ' %.0s' {1..$((68 - 23 - ${#SUCCESS_MSG} - 2))})${BORDER}${V}${RESET}"
    else
        echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    fi

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${BR}${RESET}"
}

# Draw pattern creator interface
draw_pattern_creator() {
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}Pattern Creator${RESET}$(printf ' %.0s' {1..51})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Name input
    local name_highlight=""
    if [[ "$CREATOR_MODE" == "name" ]]; then
        name_highlight="${SELECTED}"
    fi

    echo -e "${BORDER}${V}${RESET}  ${name_highlight}${TEXT}Name:${RESET} ${CREATOR_NAME}_$(printf ' %.0s' {1..$((60 - ${#CREATOR_NAME} - 1))})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Icon selector
    local icon_highlight=""
    if [[ "$CREATOR_MODE" == "icon" ]]; then
        icon_highlight="${SELECTED}"
    fi

    local icons=("🎨" "🌟" "💎" "🔥" "❄️" "⚡" "🌈" "🌸" "🍀" "🎭" "🎪" "🎯")
    local icon_line="  ${icon_highlight}Icon:${RESET} "

    for ((i=1; i<=${#icons[@]}; i++)); do
        if [[ "$CREATOR_MODE" == "icon" && $i -eq $CREATOR_CURSOR ]]; then
            icon_line+="${SELECTED}${icons[$i]}${RESET} "
        elif [[ "${icons[$i]}" == "$CREATOR_ICON" ]]; then
            icon_line+="${ACCENT}[${icons[$i]}]${RESET} "
        else
            icon_line+="${icons[$i]} "
        fi
    done

    echo -e "${BORDER}${V}${RESET}${icon_line}$(printf ' %.0s' {1..$((68 - ${#icon_line} + 30))})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Color selector
    local color_highlight=""
    if [[ "$CREATOR_MODE" == "colors" ]]; then
        color_highlight="${SELECTED}"
    fi

    echo -e "${BORDER}${V}${RESET}  ${color_highlight}${TEXT}Colors:${RESET} ${DIM}(Space to add/remove, Enter when done)${RESET}$(printf ' %.0s' {1..20})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Show all available colors in a grid
    local color_codes=(Y O R P M U B I A T G E K)
    local color_line="  "

    for ((i=1; i<=${#color_codes[@]}; i++)); do
        local code="${color_codes[$i]}"
        local name="${RIVALS[$code]}"
        local selected_mark=""

        # Check if color is in pattern
        local is_selected=0
        for c in ${CREATOR_COLORS[@]}; do
            if [[ "$c" == "$code" ]]; then
                is_selected=1
                break
            fi
        done

        if [[ "$CREATOR_MODE" == "colors" && $i -eq $CREATOR_COLOR_CURSOR ]]; then
            if [[ $is_selected -eq 1 ]]; then
                color_line+="${SELECTED}${COLORS[$code]}● ${code}${RESET} "
            else
                color_line+="${SELECTED}${COLORS[$code]}○ ${code}${RESET} "
            fi
        elif [[ $is_selected -eq 1 ]]; then
            color_line+="${COLORS[$code]}● ${code}${RESET} "
        else
            color_line+="${DIM}${COLORS[$code]}○ ${code}${RESET} "
        fi

        # Line break after 6 colors
        if [[ $((i % 6)) -eq 0 && $i -lt ${#color_codes[@]} ]]; then
            echo -e "${BORDER}${V}${RESET}${color_line}$(printf ' %.0s' {1..$((68 - 30))})${BORDER}${V}${RESET}"
            color_line="  "
        fi
    done

    # Print last line
    echo -e "${BORDER}${V}${RESET}${color_line}$(printf ' %.0s' {1..$((68 - 30))})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Current pattern display - show selected icon
    echo -e "${BORDER}${V}${RESET}  ${TEXT}Current Pattern:${RESET} ${CREATOR_ICON}$(printf ' %.0s' {1..48})${BORDER}${V}${RESET}"

    if [[ ${#CREATOR_COLORS[@]} -gt 0 ]]; then
        local pattern_display="  "
        for color in ${CREATOR_COLORS[@]}; do
            pattern_display+="${COLORS[$color]}●${RESET} "
        done
        echo -e "${BORDER}${V}${RESET}${pattern_display}$(printf ' %.0s' {1..$((68 - ${#CREATOR_COLORS[@]} * 3 - 2))})${BORDER}${V}${RESET}"
    else
        echo -e "${BORDER}${V}${RESET}  ${DIM}No colors selected${RESET}$(printf ' %.0s' {1..48})${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Preview
    if [[ ${#CREATOR_COLORS[@]} -gt 0 && -n "$CREATOR_NAME" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${TEXT}Preview:${RESET}$(printf ' %.0s' {1..58})${BORDER}${V}${RESET}"

        local test_text="The quick brown fox jumps"
        local preview=""
        local color_idx=1

        for ((i=1; i<=${#test_text}; i++)); do
            local char="${test_text:$((i-1)):1}"
            if [[ "$char" =~ [[:alnum:]] ]]; then
                local color="${CREATOR_COLORS[$(( ((color_idx - 1) % ${#CREATOR_COLORS[@]}) + 1 ))]}"
                preview+="${COLORS[$color]}${char}${RESET}"
                ((color_idx++))
            else
                preview+="$char"
            fi
        done

        echo -e "${BORDER}${V}${RESET}  ${preview}$(printf ' %.0s' {1..$((66 - ${#test_text}))})${BORDER}${V}${RESET}"
    else
        echo -e "${BORDER}${V}${RESET}  ${DIM}Complete the pattern to see preview${RESET}$(printf ' %.0s' {1..30})${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Controls
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${VL}${RESET}"

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    if [[ "$CREATOR_MODE" == "name" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${DIM}Type pattern name, ${TEXT}Tab${RESET}${DIM} or ${TEXT}↓${RESET}${DIM} to continue, ${TEXT}Esc${RESET}${DIM} to cancel${RESET}$(printf ' %.0s' {1..14})${BORDER}${V}${RESET}"
    elif [[ "$CREATOR_MODE" == "icon" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${DIM}${TEXT}←/→${RESET}${DIM} select, ${TEXT}Space${RESET}${DIM} choose, ${TEXT}Tab/↓${RESET}${DIM} continue, ${TEXT}↑${RESET}${DIM} back${RESET}$(printf ' %.0s' {1..15})${BORDER}${V}${RESET}"
    elif [[ "$CREATOR_MODE" == "colors" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${DIM}Arrows to move, ${TEXT}Space${RESET}${DIM} toggle, ${TEXT}S${RESET}${DIM} save, ${TEXT}Esc${RESET}${DIM} cancel${RESET}$(printf ' %.0s' {1..15})${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${BR}${RESET}"
}

# Draw pattern manager interface
draw_pattern_manager() {
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}  ${ACCENT}${BOLD}Pattern Manager${RESET}$(printf ' %.0s' {1..51})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    local total_patterns=${#PATTERN_ORDER[@]}
    local start_idx=1
    local end_idx=$total_patterns
    local max_display=10

    # Calculate display range for scrolling
    if [[ $total_patterns -gt $max_display ]]; then
        if [[ $MANAGER_CURSOR -le $((max_display / 2)) ]]; then
            start_idx=1
            end_idx=$max_display
        elif [[ $MANAGER_CURSOR -ge $(($total_patterns - $max_display / 2)) ]]; then
            start_idx=$(($total_patterns - $max_display + 1))
            end_idx=$total_patterns
        else
            start_idx=$(($MANAGER_CURSOR - $max_display / 2))
            end_idx=$(($MANAGER_CURSOR + $max_display / 2))
        fi
    fi

    # Display patterns
    for ((i=$start_idx; i<=$end_idx; i++)); do
        local pattern="${PATTERN_ORDER[$i]}"
        local icon="${ALL_ICONS[$pattern]}"
        local is_builtin=""
        local is_selected=""

        if [[ -z "${BUILTIN_PATTERNS[$pattern]}" ]]; then
            is_builtin="${DIM}[Custom]${RESET}"
        else
            is_builtin="${DIM}[Built-in]${RESET}"
        fi

        if [[ $i -eq $MANAGER_CURSOR ]]; then
            is_selected="${SELECTED}"
        fi

        # Get pattern colors for preview
        local -a pattern_colors
        pattern_colors=(${=ALL_PATTERNS[$pattern]})
        local color_sample=""
        local sample_count=0

        for color_code in ${pattern_colors[@]}; do
            if [[ $sample_count -lt 5 ]]; then
                color_sample+="${COLORS[$color_code]}●${RESET}"
                ((sample_count++))
            else
                color_sample+="..."
                break
            fi
        done

        echo -e "${BORDER}${V}${RESET}  ${is_selected}${icon} ${pattern}${RESET} ${color_sample} ${is_builtin}$(printf ' %.0s' {1..$((50 - ${#pattern} - ${#is_builtin}))})${BORDER}${V}${RESET}"
    done

    # Fill remaining lines if needed
    for ((i=$(($end_idx + 1)); i<=$(($start_idx + $max_display - 1)); i++)); do
        echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    done

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Action buttons
    echo -ne "${BORDER}${VR}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${VL}${RESET}"

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"
    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        echo -e "${BORDER}${V}${RESET}  ${DIM}${TEXT}E${RESET}${DIM} Edit  ${TEXT}D${RESET}${DIM} Delete  ${TEXT}N${RESET}${DIM} New  ${TEXT}Enter${RESET}${DIM} Select  ${TEXT}Esc${RESET}${DIM} Back${RESET}$(printf ' %.0s' {1..16})${BORDER}${V}${RESET}"
    else
        echo -e "${BORDER}${V}${RESET}  ${DIM}${TEXT}N${RESET}${DIM} New  ${TEXT}Enter${RESET}${DIM} Select  ${TEXT}Esc${RESET}${DIM} Back${RESET}$(printf ' %.0s' {1..33})${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${BR}${RESET}"
}

# Draw complete UI
draw_ui() {
    tput cup 0 0
    tput ed
    draw_header

    case "$CURRENT_MODE" in
        "main")
            draw_main_mode
            ;;
        "pattern_creator")
            draw_pattern_creator
            ;;
        "pattern_manager")
            draw_pattern_manager
            ;;
    esac
}

# Copy to clipboard
copy_to_clipboard() {
    if [[ -z "$CLIPBOARD_CMD" || -z "$INPUT_TEXT" ]]; then
        return 1
    fi

    local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
    local rivals_code=$(convert_to_rivals "$INPUT_TEXT" "$current_pattern")
    echo -n "$rivals_code" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
    return $?
}

# Handle pattern creator input
handle_creator_input() {
    local char=$1

    case "$CREATOR_MODE" in
        "name")
            case "$char" in
                $'\t') # Tab - move to icon selection
                    if [[ -n "$CREATOR_NAME" ]]; then
                        CREATOR_MODE="icon"
                        draw_ui
                    fi
                    ;;
                $'\x7f'|$'\b') # Backspace
                    if [[ ${#CREATOR_NAME} -gt 0 ]]; then
                        CREATOR_NAME="${CREATOR_NAME:0:-1}"
                        draw_ui
                    fi
                    ;;
                $'\x1b') # Escape sequences for arrow keys or ESC
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to main
                        CURRENT_MODE="main"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "B") # Down arrow - move to icon selection
                                if [[ -n "$CREATOR_NAME" ]]; then
                                    CREATOR_MODE="icon"
                                    draw_ui
                                fi
                                ;;
                        esac
                    fi
                    ;;
                *) # Regular character
                    if [[ ${#CREATOR_NAME} -lt 20 ]]; then
                        CREATOR_NAME+="$char"
                        draw_ui
                    fi
                    ;;
            esac
            ;;

        "icon")
            case "$char" in
                $'\t') # Tab - move to color selection
                    if [[ -n "$CREATOR_ICON" ]]; then
                        CREATOR_MODE="colors"
                        draw_ui
                    fi
                    ;;
                $'\x1b') # Escape sequences for arrow keys or ESC
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to main
                        CURRENT_MODE="main"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "C") # Right arrow
                                local icons_count=12
                                CREATOR_CURSOR=$(( (CREATOR_CURSOR % icons_count) + 1 ))
                                draw_ui
                                ;;
                            "D") # Left arrow
                                local icons_count=12
                                CREATOR_CURSOR=$(( ((CREATOR_CURSOR - 2 + icons_count) % icons_count) + 1 ))
                                draw_ui
                                ;;
                            "A") # Up arrow - go back to name
                                CREATOR_MODE="name"
                                draw_ui
                                ;;
                            "B") # Down arrow - move to colors
                                if [[ -n "$CREATOR_ICON" ]]; then
                                    CREATOR_MODE="colors"
                                    draw_ui
                                fi
                                ;;
                        esac
                    fi
                    ;;
                ' ') # Space - select icon
                    local icons=("🎨" "🌟" "💎" "🔥" "❄️" "⚡" "🌈" "🌸" "🍀" "🎭" "🎪" "🎯")
                    CREATOR_ICON="${icons[$CREATOR_CURSOR]}"
                    draw_ui
                    ;;
            esac
            ;;

        "colors")
            case "$char" in
                $'\x1b') # Escape or arrow keys
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to main
                        CURRENT_MODE="main"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "C") # Right arrow
                                CREATOR_COLOR_CURSOR=$(( (CREATOR_COLOR_CURSOR % 13) + 1 ))
                                draw_ui
                                ;;
                            "D") # Left arrow
                                CREATOR_COLOR_CURSOR=$(( ((CREATOR_COLOR_CURSOR - 2 + 13) % 13) + 1 ))
                                draw_ui
                                ;;
                            "A") # Up arrow - navigate up in grid or go to icon mode
                                if [[ $CREATOR_COLOR_CURSOR -gt 6 ]]; then
                                    CREATOR_COLOR_CURSOR=$((CREATOR_COLOR_CURSOR - 6))
                                else
                                    # Go back to icon mode
                                    CREATOR_MODE="icon"
                                fi
                                draw_ui
                                ;;
                            "B") # Down arrow - navigate down in grid
                                if [[ $CREATOR_COLOR_CURSOR -le 7 ]]; then
                                    CREATOR_COLOR_CURSOR=$((CREATOR_COLOR_CURSOR + 6))
                                    if [[ $CREATOR_COLOR_CURSOR -gt 13 ]]; then
                                        CREATOR_COLOR_CURSOR=13
                                    fi
                                fi
                                draw_ui
                                ;;
                        esac
                    fi
                    ;;
                ' ') # Space - toggle color
                    local color_codes=(Y O R P M U B I A T G E K)
                    local selected_code="${color_codes[$CREATOR_COLOR_CURSOR]}"

                    # Check if color is already selected
                    local found=0
                    local new_colors=()
                    for c in ${CREATOR_COLORS[@]}; do
                        if [[ "$c" == "$selected_code" ]]; then
                            found=1
                        else
                            new_colors+=("$c")
                        fi
                    done

                    if [[ $found -eq 0 ]]; then
                        # Add the color
                        CREATOR_COLORS+=("$selected_code")
                    else
                        # Remove the color
                        CREATOR_COLORS=("${new_colors[@]}")
                    fi

                    draw_ui
                    ;;
                's'|'S') # Save pattern
                    if [[ ${#CREATOR_COLORS[@]} -gt 0 && -n "$CREATOR_NAME" && -n "$CREATOR_ICON" ]]; then
                        # Add to patterns
                        ALL_PATTERNS[$CREATOR_NAME]="${CREATOR_COLORS[*]}"
                        ALL_ICONS[$CREATOR_NAME]="$CREATOR_ICON"

                        # Add to order if new
                        local exists=0
                        for p in "${PATTERN_ORDER[@]}"; do
                            if [[ "$p" == "$CREATOR_NAME" ]]; then
                                exists=1
                                break
                            fi
                        done

                        if [[ $exists -eq 0 ]]; then
                            PATTERN_ORDER+=("$CREATOR_NAME")
                        fi

                        # Save to file
                        save_patterns

                        # Return to main mode
                        CURRENT_MODE="main"
                        SUCCESS_MSG="Pattern '$CREATOR_NAME' saved!"
                        SHOW_SUCCESS=1

                        # Find and select the new pattern
                        for ((i=1; i<=${#PATTERN_ORDER[@]}; i++)); do
                            if [[ "${PATTERN_ORDER[$i]}" == "$CREATOR_NAME" ]]; then
                                CURRENT_PATTERN_INDEX=$i
                                break
                            fi
                        done

                        # Reset creator state
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()

                        draw_ui

                        # Clear success message after delay
                        (sleep 2; SHOW_SUCCESS=0; draw_ui) &
                    fi
                    ;;
            esac
            ;;
    esac
}

# Handle pattern manager input
handle_manager_input() {
    local char=$1
    local total_patterns=${#PATTERN_ORDER[@]}

    case "$char" in
        $'\x1b') # Escape or arrow keys
            IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
            if [[ -z "$char2" ]]; then
                # Just escape - return to main
                CURRENT_MODE="main"
                draw_ui
            elif [[ "$char2" == "[" ]]; then
                IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                case "$char3" in
                    "A") # Up arrow
                        if [[ $MANAGER_CURSOR -gt 1 ]]; then
                            ((MANAGER_CURSOR--))
                            draw_ui
                        fi
                        ;;
                    "B") # Down arrow
                        if [[ $MANAGER_CURSOR -lt $total_patterns ]]; then
                            ((MANAGER_CURSOR++))
                            draw_ui
                        fi
                        ;;
                esac
            fi
            ;;
        'n'|'N') # New pattern
            CURRENT_MODE="pattern_creator"
            CREATOR_MODE="name"
            CREATOR_NAME=""
            CREATOR_ICON=""
            CREATOR_COLORS=()
            CREATOR_CURSOR=1
            CREATOR_COLOR_CURSOR=1
            draw_ui
            ;;
        'e'|'E') # Edit pattern (only for custom patterns)
            local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"
            if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
                CURRENT_MODE="pattern_creator"
                CREATOR_MODE="name"
                CREATOR_NAME="$current_pattern"
                CREATOR_ICON="${ALL_ICONS[$current_pattern]}"
                local -a colors
                colors=(${=ALL_PATTERNS[$current_pattern]})
                CREATOR_COLORS=("${colors[@]}")
                CREATOR_CURSOR=1
                CREATOR_COLOR_CURSOR=1
                draw_ui
            fi
            ;;
        'd'|'D') # Delete pattern (only for custom patterns)
            local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"
            if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
                # Remove from arrays
                unset "ALL_PATTERNS[$current_pattern]"
                unset "ALL_ICONS[$current_pattern]"

                # Remove from order
                local new_order=()
                for p in "${PATTERN_ORDER[@]}"; do
                    if [[ "$p" != "$current_pattern" ]]; then
                        new_order+=("$p")
                    fi
                done
                PATTERN_ORDER=("${new_order[@]}")

                # Adjust cursor if needed
                if [[ $MANAGER_CURSOR -gt ${#PATTERN_ORDER[@]} ]]; then
                    MANAGER_CURSOR=${#PATTERN_ORDER[@]}
                fi

                # Save changes
                save_patterns

                SUCCESS_MSG="Pattern '$current_pattern' deleted!"
                SHOW_SUCCESS=1
                draw_ui

                # Clear success message after delay
                (sleep 2; SHOW_SUCCESS=0; draw_ui) &
            fi
            ;;
        $'\n'|$'\r') # Enter - select pattern
            CURRENT_PATTERN_INDEX=$MANAGER_CURSOR
            CURRENT_MODE="main"
            draw_ui
            ;;
    esac
}

# Cleanup on exit
cleanup() {
    tput cnorm 2>/dev/null
    tput rmcup 2>/dev/null
    stty echo 2>/dev/null
    echo -ne "\r\033[K"
    echo -e "\n${ACCENT}${BOLD}Thanks for using Enhanced Rivals Rainbow Converter!${RESET}\n"
    exit 0
}

# Main loop
main() {
    # Initialize
    init_config
    load_patterns
    detect_clipboard

    # Setup terminal
    trap cleanup EXIT INT TERM
    tput smcup
    clear
    tput civis
    stty -echo -icanon min 0

    # Initial draw
    draw_ui

    # Input loop
    while true; do
        local char
        if ! IFS= read -r -s -k 1 char 2>/dev/null; then
            exit 0
        fi

        case "$CURRENT_MODE" in
            "main")
                case "$char" in
                    $'\x1b') # Escape sequences
                        IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                        if [[ -z "$char2" ]]; then
                            # Just ESC - quit
                            break
                        elif [[ "$char2" == "[" ]]; then
                            IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                            case "$char3" in
                                "Z") # Shift+Tab - cycle backwards
                                    local total=${#PATTERN_ORDER[@]}
                                    CURRENT_PATTERN_INDEX=$(( ((CURRENT_PATTERN_INDEX - 2 + total) % total) + 1 ))
                                    draw_ui
                                    ;;
                            esac
                        fi
                        ;;
                    $'\t') # Tab - cycle forward
                        local total=${#PATTERN_ORDER[@]}
                        CURRENT_PATTERN_INDEX=$(( (CURRENT_PATTERN_INDEX % total) + 1 ))
                        draw_ui
                        ;;
                    'p'|'P') # Pattern manager
                        CURRENT_MODE="pattern_manager"
                        MANAGER_CURSOR=$CURRENT_PATTERN_INDEX
                        draw_ui
                        ;;
                    $'\n'|$'\r') # Enter - copy
                        if copy_to_clipboard; then
                            SUCCESS_MSG="Copied to clipboard!"
                            SHOW_SUCCESS=1
                            draw_ui
                            (sleep 2; SHOW_SUCCESS=0; draw_ui) &
                        fi
                        ;;
                    $'\x7f'|$'\b') # Backspace
                        if [[ ${#INPUT_TEXT} -gt 0 ]]; then
                            INPUT_TEXT="${INPUT_TEXT:0:-1}"
                            draw_ui
                        fi
                        ;;
                    $'\x15') # Ctrl+U - clear
                        INPUT_TEXT=""
                        draw_ui
                        ;;
                    $'\x03') # Ctrl+C - exit
                        exit 0
                        ;;
                    *) # Regular character
                        if [[ ${#INPUT_TEXT} -lt 59 ]]; then
                            INPUT_TEXT+="$char"
                            draw_ui
                        fi
                        ;;
                esac
                ;;
            "pattern_creator")
                handle_creator_input "$char"
                ;;
            "pattern_manager")
                handle_manager_input "$char"
                ;;
        esac
    done
}

# Run the application
main

exit 0