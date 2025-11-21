#!/usr/bin/env zsh

source "${0:A:h}/../utils/constants.zsh"

get_visible_length() {
    local text=$1
    local stripped=$(echo -e "$text" | sed -E 's/\x1b\[[0-9;]*m//g')
    echo ${#stripped}
}

draw_bordered_box() {
    local title=$1
    local content_or_callback=$2
    local is_callback=${3:-0}

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[TEXT]}${title}:${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((66 - ${#title}))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}┌──────────────────────────────────────────────────────────────┐${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    if [[ $is_callback -eq 1 ]]; then
        eval "$content_or_callback"
    else
        local visible_len=${#content_or_callback}
        local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
        local padding=$(printf ' %.0s' {1..$padding_needed})
        echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${content_or_callback}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    fi

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}└──────────────────────────────────────────────────────────────┘${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

draw_box_content_line() {
    local content=$1
    local visible_len=$2

    local padding_needed=$((PREVIEW_MAX_LENGTH - visible_len))
    local padding=$(printf ' %.0s' {1..$padding_needed})

    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}│${UI_COLORS[RESET]} ${content}${padding} ${UI_COLORS[DIM]}│${UI_COLORS[RESET]}  ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

draw_controls() {
    local mode=$1

    case "$mode" in
        "main")
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Patterns:${UI_COLORS[RESET]}${UI_COLORS[DIM]} ← → Navigate  ${UI_COLORS[TEXT]}Ctrl+P${UI_COLORS[RESET]}${UI_COLORS[DIM]} Manager  ${UI_COLORS[TEXT]}Enter${UI_COLORS[RESET]}${UI_COLORS[DIM]} Copy  ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} Quit${UI_COLORS[RESET]}      ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Edit:${UI_COLORS[RESET]}${UI_COLORS[DIM]} Ctrl+A Select  Ctrl+C Copy  Ctrl+X Cut  Ctrl+V Paste${UI_COLORS[RESET]}        ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Navigate:${UI_COLORS[RESET]}${UI_COLORS[DIM]} ← → Char  Ctrl+← → Word  Shift+← → Select${UI_COLORS[RESET]}               ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Modes:${UI_COLORS[RESET]}${UI_COLORS[DIM]} Ctrl+R Repeat  Ctrl+S Symmetry  Ctrl+U Clear${UI_COLORS[RESET]}               ${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_manager")
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}↑ ↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} Navigate  ${UI_COLORS[TEXT]}Enter${UI_COLORS[RESET]}${UI_COLORS[DIM]} Select  ${UI_COLORS[TEXT]}N${UI_COLORS[RESET]}${UI_COLORS[DIM]} New  ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} Back${UI_COLORS[RESET]}$(printf ' %.0s' {1..6})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}E${UI_COLORS[RESET]}${UI_COLORS[DIM]} Edit  ${UI_COLORS[TEXT]}D${UI_COLORS[RESET]}${UI_COLORS[DIM]} Delete (custom patterns only)${UI_COLORS[RESET]}$(printf ' %.0s' {1..13})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_name")
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}Type pattern name, ${UI_COLORS[TEXT]}Tab${UI_COLORS[RESET]}${UI_COLORS[DIM]} or ${UI_COLORS[TEXT]}↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} to continue, ${UI_COLORS[TEXT]}Esc${UI_COLORS[RESET]}${UI_COLORS[DIM]} to cancel${UI_COLORS[RESET]}$(printf ' %.0s' {1..14})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_icon")
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}←/→${UI_COLORS[RESET]}${UI_COLORS[DIM]} select, ${UI_COLORS[TEXT]}Space${UI_COLORS[RESET]}${UI_COLORS[DIM]} choose, ${UI_COLORS[TEXT]}Tab/↓${UI_COLORS[RESET]}${UI_COLORS[DIM]} continue, ${UI_COLORS[TEXT]}↑${UI_COLORS[RESET]}${UI_COLORS[DIM]} back${UI_COLORS[RESET]}$(printf ' %.0s' {1..15})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
        "pattern_creator_colors")
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}Arrows move, ${UI_COLORS[TEXT]}Space${UI_COLORS[RESET]}${UI_COLORS[DIM]} add, ${UI_COLORS[TEXT]}Backspace${UI_COLORS[RESET]}${UI_COLORS[DIM]} del, ${UI_COLORS[TEXT]}S${UI_COLORS[RESET]}${UI_COLORS[DIM]} save${UI_COLORS[RESET]}$(printf ' %.0s' {1..13})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}  ${UI_COLORS[DIM]}${UI_COLORS[TEXT]}Ctrl+R${UI_COLORS[RESET]}${UI_COLORS[DIM]} Repeat mode, ${UI_COLORS[TEXT]}Ctrl+S${UI_COLORS[RESET]}${UI_COLORS[DIM]} Symmetry toggle${UI_COLORS[RESET]}$(printf ' %.0s' {1..20})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
            ;;
    esac
}

draw_divider() {
    echo -ne "${UI_COLORS[BORDER]}${BOX[VR]}"
    printf "${BOX[H]}%.0s" {1..$((UI_WIDTH-2))}
    echo -e "${BOX[VL]}${UI_COLORS[RESET]}"
}

draw_spacer() {
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..68})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"
}

draw_page_header() {
    local title=$1
    local width=$UI_WIDTH

    echo -ne "${UI_COLORS[BORDER]}${BOX[TL]}"
    printf "${BOX[H]}%.0s" {1..$((width-2))}
    echo -e "${BOX[TR]}${UI_COLORS[RESET]}"

    draw_spacer

    local title_len=${#title}
    local padding=$(( (68 - title_len - 2) / 2 ))
    echo -e "${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$padding})${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}${title}${UI_COLORS[RESET]}$(printf ' %.0s' {1..$((68 - padding - title_len))})${UI_COLORS[BORDER]}${BOX[V]}${UI_COLORS[RESET]}"

    draw_spacer
}
