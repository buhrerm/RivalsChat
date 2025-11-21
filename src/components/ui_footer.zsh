#!/usr/bin/env zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/ui_common.zsh"

draw_footer() {
    draw_divider
    draw_spacer
    draw_controls "main"
    draw_spacer

    if [[ $SHOW_SUCCESS -eq 1 ]]; then
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..23})${UI_COLORS[SUCCESS]}${UI_COLORS[BOLD]}✓ ${SUCCESS_MSG}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((68 - 23 - ${#SUCCESS_MSG} - 2))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    else
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    fi

    echo -ne "${UI_COLORS[BORDER]}${BOX[BL]}"
    printf "${BOX[H]}%.0s" {1..$((UI_WIDTH-2))}
    echo -e "${BOX[BR]}${UI_COLORS[RESET]}"
}
