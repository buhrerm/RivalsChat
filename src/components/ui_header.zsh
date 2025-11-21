#!/usr/bin/env zsh

source "${0:A:h}/../utils/constants.zsh"

draw_header() {
    local width=$UI_WIDTH

    echo -ne "${UI_COLORS[BORDER]}${BOX[TL]}"
    printf "${BOX[H]}%.0s" {1..$((width-2))}
    echo -e "${BOX[TR]}${UI_COLORS[RESET]}"

    local title="✨ RIVALS TEXT FORMATTER ✨"
    local title_len=${#title}
    local padding=$(( (68 - title_len - 2) / 2 ))

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$padding})${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}${title}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((68 - padding - title_len))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}
