#!/usr/bin/env zsh

# ui_header.zsh - Application header component
# Renders the header banner for the TUI

source "${0:A:h}/../utils/constants.zsh"

# Draw the application header
draw_header() {
    local width=$UI_WIDTH

    echo -ne "${UI_COLORS[BORDER]}${BOX[TL]}"
    printf "${BOX[H]}%.0s" {1..$((width-2))}
    echo -e "${BOX[TR]}${UI_COLORS[RESET]}"

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}╔═══╗ ╔══╗ ╔╗  ╔╗ ╔═══╗ ╔╗    ╔═══╗${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}║╔═╗║ ╚╣╠╝ ║╚╗╔╝║ ║╔═╗║ ║║    ║╔═╗║${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}║╚═╝║  ║║  ╚╗║║╔╝ ║║ ║║ ║║    ║╚══╗${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}║╔╗╔╝  ║║   ║╚╝║  ║╚═╝║ ║║    ╚══╗║${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}║║║╚╗ ╔╣╠╗  ╚╗╔╝  ║╔═╗║ ║╚═╗  ║╚═╝║${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}╚╝╚═╝ ╚══╝   ╚╝   ╚╝ ╚╝ ╚══╝  ╚═══╝${UI_COLORS[RESET]}$(printf ' %.0s' {1..31})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..14})${UI_COLORS[TEXT]}Rainbow Text Converter for Marvel Rivals${UI_COLORS[RESET]}$(printf ' %.0s' {1..14})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    echo -ne "${UI_COLORS[BORDER]}${BOX[VR]}"
    printf "${BOX[H]}%.0s" {1..$((width-2))}
    echo -e "${BOX[VL]}${UI_COLORS[RESET]}"
}
