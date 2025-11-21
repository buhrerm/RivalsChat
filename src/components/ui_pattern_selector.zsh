#!/usr/bin/env zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/ui_common.zsh"

draw_pattern_selector() {
    local total_patterns=${#PATTERN_ORDER[@]}
    local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
    local current_icon="${ALL_ICONS[$current_pattern]}"

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Pattern:${UI_COLORS[RESET]} ${UI_COLORS[DIM]}(← → or Tab to navigate, Ctrl+P for manager)${UI_COLORS[RESET]}             ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
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

    local pattern_name_display="${current_pattern:0:10}"
    local pattern_name_len=${#pattern_name_display}
    local pattern_name_padded="${pattern_name_display}$(printf ' %.0s' {1..$((10 - pattern_name_len))})"

    local counter_text="(${CURRENT_PATTERN_INDEX}/${total_patterns})"

    local content_left="  ← ${prev_icon}  ${current_icon} ${pattern_name_padded} ${repeat_indicator}${sym_indicator}"
    local content_right="  ${next_icon} →  "

    local content_left_len=$(get_visible_length "$content_left")
    local content_right_len=$(get_visible_length "$content_right")
    local counter_len=$(get_visible_length "$counter_text")

    local available_for_dots=$((68 - content_left_len - counter_len - content_right_len - 2))

    local color_dots_len=${#pattern_colors[@]}
    local dots_to_show=$available_for_dots
    if [[ $dots_to_show -gt $color_dots_len ]]; then
        dots_to_show=$color_dots_len
    fi
    if [[ $dots_to_show -lt 0 ]]; then
        dots_to_show=0
    fi

    local color_sample_display=""
    for ((i=1; i<=dots_to_show && i<=${#pattern_colors[@]}; i++)); do
        local color_code="${pattern_colors[$i]}"
        color_sample_display+="${COLORS[$color_code]}●${UI_COLORS[RESET]}"
    done

    local final_content_len=$((content_left_len + 1 + dots_to_show + 1 + counter_len + content_right_len))
    local padding_needed=$((68 - final_content_len))
    if [[ $padding_needed -lt 0 ]]; then
        padding_needed=0
    fi
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}${content_left} ${color_sample_display} ${UI_COLORS[DIM]}${counter_text}${UI_COLORS[RESET]}${content_right}${padding}${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}
