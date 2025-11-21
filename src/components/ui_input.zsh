#!/usr/bin/env zsh

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"
source "${0:A:h}/ui_common.zsh"

draw_input() {
    draw_spacer
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}Type your text:${UI_COLORS[RESET]}$(printf ' %.0s' {1..51})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    local display_text=""
    local plain_text=""
    local text_len=${#INPUT_TEXT}

    if [[ $CURSOR_POS -gt $text_len ]]; then
        CURSOR_POS=$text_len
    fi

    if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
        local sel_start=$SELECTION_START
        local sel_end=$SELECTION_END

        if [[ $sel_start -gt $sel_end ]]; then
            local tmp=$sel_start
            sel_start=$sel_end
            sel_end=$tmp
        fi

        for ((i=0; i<$text_len; i++)); do
            local char="${INPUT_TEXT:$i:1}"
            plain_text+="$char"
            if [[ $i -ge $sel_start && $i -lt $sel_end ]]; then
                display_text+="${UI_COLORS[SELECTED]}${char}${UI_COLORS[RESET]}${UI_COLORS[HIGHLIGHT]}"
            else
                display_text+="$char"
            fi
        done

        plain_text+="_"
        display_text+="${UI_COLORS[RESET]}_"
    else
        if [[ $CURSOR_POS -eq 0 ]]; then
            plain_text="_${INPUT_TEXT}"
            display_text="_${INPUT_TEXT}"
        elif [[ $CURSOR_POS -eq $text_len ]]; then
            plain_text="${INPUT_TEXT}_"
            display_text="${INPUT_TEXT}_"
        else
            plain_text="${INPUT_TEXT:0:$CURSOR_POS}_${INPUT_TEXT:$CURSOR_POS}"
            display_text="${INPUT_TEXT:0:$CURSOR_POS}_${INPUT_TEXT:$CURSOR_POS}"
        fi
    fi

    local visible_len=${#plain_text}
    if [[ $visible_len -gt $PREVIEW_MAX_LENGTH ]]; then
        local truncate_at=$((PREVIEW_MAX_LENGTH - 1))
        plain_text="${INPUT_TEXT:0:$truncate_at}_"
        display_text="${INPUT_TEXT:0:$truncate_at}_"
        visible_len=$PREVIEW_MAX_LENGTH
    fi

    local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    draw_box_content_line "${UI_COLORS[HIGHLIGHT]}${display_text}${UI_COLORS[RESET]}" "$visible_len"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    draw_spacer
}
