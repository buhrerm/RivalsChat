#!/usr/bin/env zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/ui_common.zsh"

draw_pattern_selector() {
    local total_patterns=${#PATTERN_ORDER[@]}
    local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
    local current_icon="${ALL_ICONS[$current_pattern]}"

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Pattern:${UI_COLORS[RESET]} ${UI_COLORS[DIM]}(← → or Tab to navigate, Ctrl+P for manager)${UI_COLORS[RESET]}$(printf ' %.0s' {1..15})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    local -a pattern_colors
    pattern_colors=(${=ALL_PATTERNS[$current_pattern]})

    local color_sample=""
    for color_code in ${pattern_colors[@]}; do
        color_sample+="${COLORS[$color_code]}●${UI_COLORS[RESET]}"
    done

    local is_custom=""
    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        is_custom=" ${UI_COLORS[DIM]}[Custom]${UI_COLORS[RESET]}"
    fi

    local prev_index=$(( CURRENT_PATTERN_INDEX == 1 ? total_patterns : CURRENT_PATTERN_INDEX - 1 ))
    local prev_pattern="${PATTERN_ORDER[$prev_index]}"
    local prev_icon="${ALL_ICONS[$prev_pattern]}"

    local next_index=$(( CURRENT_PATTERN_INDEX == total_patterns ? 1 : CURRENT_PATTERN_INDEX + 1 ))
    local next_pattern="${PATTERN_ORDER[$next_index]}"
    local next_icon="${ALL_ICONS[$next_pattern]}"

    local repeat_indicator=""
    case $REPEAT_MODE in
        1) repeat_indicator="${UI_COLORS[HIGHLIGHT]}[WORD  ]${UI_COLORS[RESET]}" ;;
        *) repeat_indicator="${UI_COLORS[DIM]}[CONT  ]${UI_COLORS[RESET]}" ;;
    esac

    local sym_indicator=""
    case $SYMMETRY_MODE in
        1) sym_indicator=" ${UI_COLORS[ACCENT]}[MIRROR]${UI_COLORS[RESET]}" ;;
        2) sym_indicator=" ${UI_COLORS[HIGHLIGHT]}[FULL  ]${UI_COLORS[RESET]}" ;;
        *) sym_indicator=" ${UI_COLORS[DIM]}[OFF   ]${UI_COLORS[RESET]}" ;;
    esac

    local pattern_name_padded="${current_pattern}$(printf ' %.0s' {1..$((15 - ${#current_pattern}))})"
    pattern_name_padded="${pattern_name_padded:0:15}"

    local custom_tag="       "
    if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
        custom_tag="[Custom]"
    fi

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}← ${prev_icon}${UI_COLORS[RESET]}  ${current_icon} ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}${pattern_name_padded}${UI_COLORS[RESET]} ${UI_COLORS[DIM]}${custom_tag}${UI_COLORS[RESET]} ${repeat_indicator}${sym_indicator} ${color_sample} ${UI_COLORS[DIM]}(${CURRENT_PATTERN_INDEX}/${total_patterns})${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${next_icon} →${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}
