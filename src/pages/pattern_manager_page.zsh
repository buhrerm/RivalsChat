# Source common UI functions
source "${0:A:h}/../components/ui_common.zsh"

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
        local max_preview=8  # Show more colors

        for color_code in ${pattern_colors[@]}; do
            if [[ $sample_count -lt $max_preview ]]; then
                color_sample+="${COLORS[$color_code]}●${RESET}"
                ((sample_count++))
            else
                # Show count of remaining colors
                local remaining=$(( ${#pattern_colors[@]} - $sample_count ))
                if [[ $remaining -gt 0 ]]; then
                    color_sample+=" ${DIM}+${remaining}${RESET}"
                fi
                break
            fi
        done

        # If pattern has repeated colors, show total length
        if [[ ${#pattern_colors[@]} -gt 13 ]]; then
            color_sample+=" ${DIM}[${#pattern_colors[@]}]${RESET}"
        fi

        echo -e "${BORDER}${V}${RESET}  ${is_selected}${icon} ${pattern}${RESET} ${color_sample} ${is_builtin}$(printf ' %.0s' {1..$((50 - ${#pattern} - ${#is_builtin}))})${BORDER}${V}${RESET}"
    done

    # Fill remaining lines if needed
    for ((i=$(($end_idx + 1)); i<=$(($start_idx + $max_display - 1)); i++)); do
        echo -e "${BORDER}${V}${RESET}$(printf ' %.0s' {1..68})${BORDER}${V}${RESET}"
    done

    draw_spacer

    # Action buttons - use centralized controls
    draw_divider
    draw_spacer
    draw_controls "pattern_manager"
    draw_spacer

    echo -ne "${BORDER}${BL}"
    printf "${H}%.0s" {1..$((70-2))}
    echo -e "${BR}${RESET}"
}

# Wrapper to match expected function name
pattern_manager_page_draw() {
    draw_pattern_manager
}

