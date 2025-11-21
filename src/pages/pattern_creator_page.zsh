# Source common UI functions
source "${0:A:h}/../components/ui_common.zsh"

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

    echo -e "${BORDER}${V}${RESET}  ${color_highlight}${TEXT}Colors:${RESET} ${DIM}(Space to add, Backspace to remove last)${RESET}$(printf ' %.0s' {1..20})${BORDER}${V}${RESET}"
    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Show all available colors in a grid
    local -a color_codes
    color_codes=(Y O R P M U B I A T G E K)
    local color_line="  "

    for ((i=1; i<=${#color_codes[@]}; i++)); do
        local code="${color_codes[$i]}"
        local name="${RIVALS[$code]}"
        local selected_mark=""

        # Count how many times this color appears in pattern
        local color_count=0
        for c in ${CREATOR_COLORS[@]}; do
            if [[ "$c" == "$code" ]]; then
                ((color_count++))
            fi
        done

        local count_display=""
        if [[ $color_count -gt 0 ]]; then
            count_display="${color_count}"
            if [[ $color_count -gt 9 ]]; then
                count_display="9+"
            fi
        fi

        if [[ "$CREATOR_MODE" == "colors" && $i -eq $CREATOR_COLOR_CURSOR ]]; then
            if [[ $color_count -gt 0 ]]; then
                color_line+="${SELECTED}${COLORS[$code]}${count_display} ${code}${RESET} "
            else
                color_line+="${SELECTED}${COLORS[$code]}○ ${code}${RESET} "
            fi
        elif [[ $color_count -gt 0 ]]; then
            color_line+="${COLORS[$code]}${count_display} ${code}${RESET} "
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

    # Preview with mode indicators
    if [[ ${#CREATOR_COLORS[@]} -gt 0 && -n "$CREATOR_NAME" ]]; then
        # Show mode indicators
        local repeat_indicator=""
        case $REPEAT_MODE in
            1) repeat_indicator="${HIGHLIGHT}[WORD]${RESET}" ;;
            2) repeat_indicator="${HIGHLIGHT}[PHRASE]${RESET}" ;;
            *) repeat_indicator="${DIM}[CONT]${RESET}" ;;
        esac

        local sym_indicator=""
        case $SYMMETRY_MODE in
            1) sym_indicator=" ${ACCENT}[MIRROR]${RESET}" ;;
            2) sym_indicator=" ${HIGHLIGHT}[FULL]${RESET}" ;;
        esac

        echo -e "${BORDER}${V}${RESET}  ${TEXT}Preview:${RESET} ${repeat_indicator}${sym_indicator}$(printf ' %.0s' {1..45})${BORDER}${V}${RESET}"

        local test_text="The quick brown fox jumps"

        # Temporarily set pattern for preview
        local temp_pattern="${CREATOR_COLORS[*]}"
        ALL_PATTERNS[_preview_temp_]=$temp_pattern

        local preview=$(generate_rainbow "$test_text" "_preview_temp_")

        # Clean up temp pattern
        unset "ALL_PATTERNS[_preview_temp_]"

        echo -e "${BORDER}${V}${RESET}  ${preview}$(printf ' %.0s' {1..$((66 - ${#test_text}))})${BORDER}${V}${RESET}"
    else
        echo -e "${BORDER}${V}${RESET}  ${DIM}Complete the pattern to see preview${RESET}$(printf ' %.0s' {1..30})${BORDER}${V}${RESET}"
    fi

    echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"

    # Controls - use centralized controls based on mode
    draw_divider
    draw_spacer

    if [[ "$CREATOR_MODE" == "name" ]]; then
        draw_controls "pattern_creator_name"
    elif [[ "$CREATOR_MODE" == "icon" ]]; then
        draw_controls "pattern_creator_icon"
    elif [[ "$CREATOR_MODE" == "colors" ]]; then
        draw_controls "pattern_creator_colors"
    fi

    draw_spacer

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${BR}${RESET}"
}

# Wrapper to match expected function name
pattern_creator_page_draw() {
    draw_pattern_creator
}

