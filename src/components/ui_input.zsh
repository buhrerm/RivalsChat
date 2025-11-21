#!/usr/bin/env zsh

# ui_input.zsh - Text input component
# Renders the text input field with cursor and selection

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

# Draw the text input component
draw_input() {
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Type your text:${UI_COLORS[RESET]}$(printf ' %.0s' {1..51})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    # Build display text with selection and cursor
    local display_text=""
    local text_len=${#INPUT_TEXT}

    # Ensure cursor position is valid
    if [[ $CURSOR_POS -gt $text_len ]]; then
        CURSOR_POS=$text_len
    fi

    # Handle selection display
    if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
        local sel_start=$SELECTION_START
        local sel_end=$SELECTION_END

        # Ensure correct order
        if [[ $sel_start -gt $sel_end ]]; then
            local tmp=$sel_start
            sel_start=$sel_end
            sel_end=$tmp
        fi

        # Build text with selection highlighting
        for ((i=0; i<$text_len; i++)); do
            local char="${INPUT_TEXT:$i:1}"
            if [[ $i -ge $sel_start && $i -lt $sel_end ]]; then
                display_text+="${UI_COLORS[SELECTED]}${char}${UI_COLORS[RESET]}${UI_COLORS[HIGHLIGHT]}"
            else
                display_text+="$char"
            fi
        done

        display_text+="${UI_COLORS[RESET]}_"
    else
        # No selection, just show text with cursor
        if [[ $CURSOR_POS -eq 0 ]]; then
            display_text="_${INPUT_TEXT}"
        elif [[ $CURSOR_POS -eq $text_len ]]; then
            display_text="${INPUT_TEXT}_"
        else
            display_text="${INPUT_TEXT:0:$CURSOR_POS}_${INPUT_TEXT:$CURSOR_POS}"
        fi
    fi

    # Truncate if too long
    local visible_len=${#display_text}
    if [[ $visible_len -gt $PREVIEW_MAX_LENGTH ]]; then
        display_text="${INPUT_TEXT:0:59}_"
        visible_len=$PREVIEW_MAX_LENGTH
    fi

    local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${UI_COLORS[HIGHLIGHT]}${display_text}${UI_COLORS[RESET]}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}
