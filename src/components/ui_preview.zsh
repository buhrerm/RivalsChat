#!/usr/bin/env zsh

# ui_preview.zsh - Preview component
# Renders the colored text preview

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/../lib/text_renderer.zsh"

# Draw the preview component
draw_preview() {
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Preview:${UI_COLORS[RESET]}$(printf ' %.0s' {1..58})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    if [[ -z "$INPUT_TEXT" ]]; then
        local empty_msg="${UI_COLORS[DIM]}Type something to see the magic...${UI_COLORS[RESET]}"
        local visible_len=34
        local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${empty_msg}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    else
        local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
        local rainbow=$(generate_rainbow_preview "$INPUT_TEXT" "$current_pattern")
        local visible_len=$(visible_length "$rainbow")

        if [[ $visible_len -gt $PREVIEW_MAX_LENGTH ]]; then
            visible_len=$PREVIEW_MAX_LENGTH
        fi

        local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})

        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${rainbow}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    fi

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}
