#!/usr/bin/env zsh

# ui_footer.zsh - Footer component
# Renders controls and status messages

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

# Draw the footer component
draw_footer() {
    echo -ne "${UI_COLORS[BORDER]}${BOX[VR]}"
    printf "${BOX[H]}%.0s" {1..$((UI_WIDTH-2))}
    echo -e "${BOX[VL]}${UI_COLORS[RESET]}"

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}← →${UI_COLORS[RESET]}${UI_COLORS[DIM]} Navigate  ${UI_COLORS[TEXT]}Enter${UI_COLORS[RESET]}${UI_COLORS[DIM]} Copy  ${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat  ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} Quit${UI_COLORS[RESET]}$(printf ' %.0s' {1..3})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+P${UI_COLORS[RESET]}${UI_COLORS[DIM]} Patterns  ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry  ${UI_COLORS[TEXT]}Ctrl+A${UI_COLORS[RESET]}${UI_COLORS[DIM]} Select${UI_COLORS[RESET]}$(printf ' %.0s' {1..10})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    # Success message if needed
    if [[ $SHOW_SUCCESS -eq 1 ]]; then
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..23})${UI_COLORS[SUCCESS]}${UI_COLORS[BOLD]}✓ ${SUCCESS_MSG}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((68 - 23 - ${#SUCCESS_MSG} - 2))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    else
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    fi

    echo -ne "${UI_COLORS[BORDER]}${BOX[BL]}"
    printf "${BOX[H]}%.0s" {1..$((UI_WIDTH-2))}
    echo -e "${BOX[BR]}${UI_COLORS[RESET]}"
}
