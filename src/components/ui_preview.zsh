#!/usr/bin/env zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/../lib/text_renderer.zsh"
source "${0:A:h}/ui_common.zsh"

draw_preview() {
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Preview:${UI_COLORS[RESET]}$(printf ' %.0s' {1..58})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    if [[ -z "$INPUT_TEXT" ]]; then
        local empty_msg="${UI_COLORS[DIM]}Type something to see the magic...${UI_COLORS[RESET]}"
        draw_box_content_line "$empty_msg" 34
    else
        local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
        local rainbow=$(generate_rainbow_preview "$INPUT_TEXT" "$current_pattern")

        local visible_len=${#INPUT_TEXT}
        if [[ $visible_len -gt $PREVIEW_MAX_LENGTH ]]; then
            visible_len=$PREVIEW_MAX_LENGTH
        fi

        draw_box_content_line "$rainbow" "$visible_len"
    fi

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    draw_spacer
}
