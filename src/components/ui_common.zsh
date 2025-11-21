#!/usr/bin/env zsh

# ui_common.zsh - Common UI component utilities
# Provides reusable UI rendering functions for borders, boxes, and controls

source "${0:A:h}/../utils/constants.zsh"

# Draw a bordered box with title and content
# Usage: draw_bordered_box "Title" "content_or_empty_message" [content_callback]
draw_bordered_box() {
    local title=$1
    local content_or_callback=$2
    local is_callback=${3:-0}

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}${title}:${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((66 - ${#title}))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    # Call the content callback or display provided content
    if [[ $is_callback -eq 1 ]]; then
        eval "$content_or_callback"
    else
        # Display single line content
        local visible_len=${#content_or_callback}
        local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${content_or_callback}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    fi

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

# Draw a box content line with proper padding
# Usage: draw_box_content_line "content_with_ansi_codes" visible_length
draw_box_content_line() {
    local content=$1
    local visible_len=$2

    local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${content}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

# Draw control instructions for different modes
# Usage: draw_controls "main|pattern_manager|pattern_creator_name|pattern_creator_icon|pattern_creator_colors"
draw_controls() {
    local mode=$1

    case "$mode" in
        "main")
            # Main page controls
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}← →${UI_COLORS[RESET]}${UI_COLORS[DIM]} Navigate  ${UI_COLORS[TEXT]}Enter${UI_COLORS[RESET]}${UI_COLORS[DIM]} Copy  ${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat  ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} Quit${UI_COLORS[RESET]}$(printf ' %.0s' {1..3})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+P${UI_COLORS[RESET]}${UI_COLORS[DIM]} Patterns  ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry  ${UI_COLORS[TEXT]}Ctrl+A${UI_COLORS[RESET]}${UI_COLORS[DIM]} Select${UI_COLORS[RESET]}$(printf ' %.0s' {1..10})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_manager")
            # Pattern manager controls
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}↑ ↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} Navigate  ${UI_COLORS[TEXT]}Enter${UI_COLORS[RESET]}${UI_COLORS[DIM]} Select  ${UI_COLORS[TEXT]}N${UI_COLORS[RESET]}${UI_COLORS[DIM]} New  ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} Back${UI_COLORS[RESET]}$(printf ' %.0s' {1..6})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}E${UI_COLORS[RESET]}${UI_COLORS[DIM]} Edit  ${UI_COLORS[TEXT]}D${UI_COLORS[RESET]}${UI_COLORS[DIM]} Delete (custom patterns only)${UI_COLORS[RESET]}$(printf ' %.0s' {1..13})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_name")
            # Pattern creator - name input mode
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}Type pattern name, ${UI_COLORS[TEXT]}Tab${UI_COLORS[RESET]}${UI_COLORS[DIM]} or ${UI_COLORS[TEXT]}↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} to continue, ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} to cancel${UI_COLORS[RESET]}$(printf ' %.0s' {1..14})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_icon")
            # Pattern creator - icon selection mode
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}←/→${UI_COLORS[RESET]}${UI_COLORS[DIM]} select, ${UI_COLORS[TEXT]}Space${UI_COLORS[RESET]}${UI_COLORS[DIM]} choose, ${UI_COLORS[TEXT]}Tab/↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} continue, ${UI_COLORS[TEXT]}↑${UI_COLORS[RESET]}${UI_COLORS[DIM]} back${UI_COLORS[RESET]}$(printf ' %.0s' {1..15})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_colors")
            # Pattern creator - color selection mode
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}Arrows move, ${UI_COLORS[TEXT]}Space${UI_COLORS[RESET]}${UI_COLORS[DIM]} add, ${UI_COLORS[TEXT]}Backspace${UI_COLORS[RESET]}${UI_COLORS[DIM]} del, ${UI_COLORS[TEXT]}S${UI_COLORS[RESET]}${UI_COLORS[DIM]} save${UI_COLORS[RESET]}$(printf ' %.0s' {1..13})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
    esac
}

# Draw a horizontal divider line
draw_divider() {
    echo -ne "${UI_COLORS[BORDER]}${BOX[VR]}"
    printf "${BOX[H]}%.0s" {1..$((UI_WIDTH-2))}
    echo -e "${BOX[VL]}${UI_COLORS[RESET]}"
}

# Draw a spacer line (empty line within the border)
draw_spacer() {
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

# Draw a simple page header with title
# Usage: draw_page_header "Page Title"
draw_page_header() {
    local title=$1
    local width=$UI_WIDTH

    # Top border
    echo -ne "${UI_COLORS[BORDER]}${BOX[TL]}"
    printf "${BOX[H]}%.0s" {1..$((width-2))}
    echo -e "${BOX[TR]}${UI_COLORS[RESET]}"

    # Spacer
    draw_spacer

    # Title
    local title_len=${#title}
    local padding=$(( (68 - title_len - 2) / 2 ))
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$padding})${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}${title}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((68 - padding - title_len))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    # Spacer
    draw_spacer
}
