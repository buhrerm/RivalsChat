#!/usr/bin/env zsh
# Marvel Rivals Rainbow Converter - Vim-Style Keybindings
# Comprehensive modal editing system with vim-like interface

# Color codes for Marvel Rivals
typeset -A COLORS=(
    [Y]="Gold" [O]="Orange" [R]="Red" [P]="Pink" [M]="Really Pink"
    [U]="Purple" [B]="Blue" [I]="Dark Blue" [A]="Teal"
    [T]="Blue Green" [G]="Green" [E]="Green Yellow" [K]="Yellow"
)

# Pattern arrays
typeset -a FULL_RAINBOW=(Y O R P M U B I A T G E K)
typeset -a WARM_RAINBOW=(Y O R P M)
typeset -a COOL_RAINBOW=(U B I A T G)
typeset -a WAVE_RAINBOW=(Y O R P M U B I A T G E K E G T A I B U M P R O)
typeset -a ALTERNATING=(Y R M B A G)

# ANSI color codes for terminal preview
typeset -A ANSI_COLORS=(
    [Y]=$'\033[38;5;226m' [O]=$'\033[38;5;208m' [R]=$'\033[38;5;196m'
    [P]=$'\033[38;5;205m' [M]=$'\033[38;5;199m' [U]=$'\033[38;5;135m'
    [B]=$'\033[38;5;33m'  [I]=$'\033[38;5;27m'  [A]=$'\033[38;5;51m'
    [T]=$'\033[38;5;45m'  [G]=$'\033[38;5;46m'  [E]=$'\033[38;5;154m'
    [K]=$'\033[38;5;190m'
)

# Terminal styling
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
UNDERLINE=$'\033[4m'
REVERSE=$'\033[7m'
CLEAR_LINE=$'\033[2K'
CURSOR_HIDE=$'\033[?25l'
CURSOR_SHOW=$'\033[?25h'

# Global state variables
MODE="NORMAL"           # Current mode: NORMAL, INSERT, VISUAL, COMMAND
typeset -a TEXT_BUFFER  # Text buffer (array of lines)
typeset -a YANK_BUFFER  # Clipboard for yank/delete operations
typeset -a UNDO_STACK   # Undo history
typeset -a REDO_STACK   # Redo history
CURSOR_LINE=1           # Current line (1-indexed)
CURSOR_COL=0            # Current column (0-indexed)
VISUAL_START_LINE=0     # Visual mode start line
VISUAL_START_COL=0      # Visual mode start column
CURRENT_PATTERN=1       # Current conversion pattern (1-6)
SHOW_PREVIEW=1          # Preview toggle (0=off, 1=on)
SEARCH_TERM=""          # Current search term
typeset -a SEARCH_MATCHES  # Search match positions
SEARCH_INDEX=0          # Current search match index
COMMAND_INPUT=""        # Command mode input buffer
MESSAGE=""              # Status message
MESSAGE_COLOR=""        # Status message color

# Initialize with empty buffer
TEXT_BUFFER=("")

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Save current state to undo stack
save_undo() {
    local state="${(j:\n:)TEXT_BUFFER}"
    UNDO_STACK+=("$state|$CURSOR_LINE|$CURSOR_COL")
    # Limit undo stack to 50 entries
    if (( ${#UNDO_STACK[@]} > 50 )); then
        shift UNDO_STACK
    fi
    REDO_STACK=()  # Clear redo stack on new change
}

# Undo last change
undo() {
    if (( ${#UNDO_STACK[@]} > 0 )); then
        local current_state="${(j:\n:)TEXT_BUFFER}|$CURSOR_LINE|$CURSOR_COL"
        REDO_STACK+=("$current_state")

        local state="${UNDO_STACK[-1]}"
        unset "UNDO_STACK[-1]"

        local parts=("${(@s:|:)state}")
        TEXT_BUFFER=("${(@f)parts[1]}")
        CURSOR_LINE=${parts[2]:-1}
        CURSOR_COL=${parts[3]:-0}

        set_message "Undo" "${ANSI_COLORS[G]}"
    else
        set_message "Already at oldest change" "${ANSI_COLORS[R]}"
    fi
}

# Redo last undone change
redo() {
    if (( ${#REDO_STACK[@]} > 0 )); then
        local current_state="${(j:\n:)TEXT_BUFFER}|$CURSOR_LINE|$CURSOR_COL"
        UNDO_STACK+=("$current_state")

        local state="${REDO_STACK[-1]}"
        unset "REDO_STACK[-1]"

        local parts=("${(@s:|:)state}")
        TEXT_BUFFER=("${(@f)parts[1]}")
        CURSOR_LINE=${parts[2]:-1}
        CURSOR_COL=${parts[3]:-0}

        set_message "Redo" "${ANSI_COLORS[G]}"
    else
        set_message "Already at newest change" "${ANSI_COLORS[R]}"
    fi
}

# Set status message
set_message() {
    MESSAGE="$1"
    MESSAGE_COLOR="${2:-$RESET}"
}

# Get current line text
get_current_line() {
    echo "${TEXT_BUFFER[$CURSOR_LINE]}"
}

# Set current line text
set_current_line() {
    TEXT_BUFFER[$CURSOR_LINE]="$1"
}

# Clamp cursor position to valid range
clamp_cursor() {
    # Clamp line
    if (( CURSOR_LINE < 1 )); then
        CURSOR_LINE=1
    elif (( CURSOR_LINE > ${#TEXT_BUFFER[@]} )); then
        CURSOR_LINE=${#TEXT_BUFFER[@]}
    fi

    # Clamp column
    local line_length=${#TEXT_BUFFER[$CURSOR_LINE]}
    if (( CURSOR_COL < 0 )); then
        CURSOR_COL=0
    elif (( CURSOR_COL > line_length )); then
        CURSOR_COL=$line_length
    fi

    # In normal mode, can't be past last character
    if [[ "$MODE" == "NORMAL" ]] && (( CURSOR_COL >= line_length )) && (( line_length > 0 )); then
        CURSOR_COL=$((line_length - 1))
    fi
}

# ============================================================================
# CONVERSION FUNCTIONS
# ============================================================================

convert_full_rainbow() {
    local text="$1"
    local output=""
    local color_idx=1

    for (( i=1; i<=${#text}; i++ )); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${FULL_RAINBOW[$color_idx]}"
            output+="#${color}${char}"
            ((color_idx = (color_idx % ${#FULL_RAINBOW[@]}) + 1))
        else
            output+="$char"
        fi
    done
    echo "$output"
}

convert_warm_rainbow() {
    local text="$1"
    local output=""
    local color_idx=1

    for (( i=1; i<=${#text}; i++ )); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${WARM_RAINBOW[$color_idx]}"
            output+="#${color}${char}"
            ((color_idx = (color_idx % ${#WARM_RAINBOW[@]}) + 1))
        else
            output+="$char"
        fi
    done
    echo "$output"
}

convert_cool_rainbow() {
    local text="$1"
    local output=""
    local color_idx=1

    for (( i=1; i<=${#text}; i++ )); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${COOL_RAINBOW[$color_idx]}"
            output+="#${color}${char}"
            ((color_idx = (color_idx % ${#COOL_RAINBOW[@]}) + 1))
        else
            output+="$char"
        fi
    done
    echo "$output"
}

convert_wave_rainbow() {
    local text="$1"
    local output=""
    local color_idx=1

    for (( i=1; i<=${#text}; i++ )); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${WAVE_RAINBOW[$color_idx]}"
            output+="#${color}${char}"
            ((color_idx = (color_idx % ${#WAVE_RAINBOW[@]}) + 1))
        else
            output+="$char"
        fi
    done
    echo "$output"
}

convert_alternating() {
    local text="$1"
    local output=""
    local color_idx=1

    for (( i=1; i<=${#text}; i++ )); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${ALTERNATING[$color_idx]}"
            output+="#${color}${char}"
            ((color_idx = (color_idx % ${#ALTERNATING[@]}) + 1))
        else
            output+="$char"
        fi
    done
    echo "$output"
}

convert_word_rainbow() {
    local text="$1"
    local output=""
    local color_idx=1
    local words=(${(z)text})

    for word in "${words[@]}"; do
        local color="${FULL_RAINBOW[$color_idx]}"
        output+="#${color}${word} "
        ((color_idx = (color_idx % ${#FULL_RAINBOW[@]}) + 1))
    done
    echo "${output% }"
}

# Convert text based on current pattern
convert_text() {
    local text="$1"
    case $CURRENT_PATTERN in
        1) convert_full_rainbow "$text" ;;
        2) convert_warm_rainbow "$text" ;;
        3) convert_cool_rainbow "$text" ;;
        4) convert_wave_rainbow "$text" ;;
        5) convert_alternating "$text" ;;
        6) convert_word_rainbow "$text" ;;
        *) convert_full_rainbow "$text" ;;
    esac
}

# Preview text with ANSI colors
preview_text() {
    local rivals_code="$1"
    local preview=""
    local i=1

    while (( i <= ${#rivals_code} )); do
        if [[ "${rivals_code:$((i-1)):1}" == "#" ]] && (( i < ${#rivals_code} )); then
            local color_code="${rivals_code:$i:1}"
            local char="${rivals_code:$((i+1)):1}"
            if [[ -n "${ANSI_COLORS[$color_code]}" ]]; then
                preview+="${ANSI_COLORS[$color_code]}${char}${RESET}"
                ((i += 3))
                continue
            fi
        fi
        preview+="${rivals_code:$((i-1)):1}"
        ((i++))
    done

    echo "$preview"
}

# Get pattern name
get_pattern_name() {
    case $CURRENT_PATTERN in
        1) echo "Full Rainbow" ;;
        2) echo "Warm Rainbow" ;;
        3) echo "Cool Rainbow" ;;
        4) echo "Wave Rainbow" ;;
        5) echo "Alternating" ;;
        6) echo "Word Rainbow" ;;
        *) echo "Unknown" ;;
    esac
}

# ============================================================================
# SEARCH FUNCTIONS
# ============================================================================

# Perform search
search() {
    SEARCH_MATCHES=()
    SEARCH_INDEX=0

    if [[ -z "$SEARCH_TERM" ]]; then
        return
    fi

    local line_num=1
    for line in "${TEXT_BUFFER[@]}"; do
        local col=0
        while [[ "$line" =~ "$SEARCH_TERM" ]]; do
            local match_pos=${line[(i)$SEARCH_TERM]}
            if (( match_pos <= ${#line} )); then
                SEARCH_MATCHES+=("$line_num:$((match_pos - 1))")
                line="${line:$match_pos}"
                ((col += match_pos))
            else
                break
            fi
        done
        ((line_num++))
    done

    if (( ${#SEARCH_MATCHES[@]} > 0 )); then
        jump_to_search_match 0
        set_message "Found ${#SEARCH_MATCHES[@]} matches" "${ANSI_COLORS[G]}"
    else
        set_message "Pattern not found: $SEARCH_TERM" "${ANSI_COLORS[R]}"
    fi
}

# Jump to search match by index
jump_to_search_match() {
    local idx=$1
    if (( ${#SEARCH_MATCHES[@]} == 0 )); then
        return
    fi

    SEARCH_INDEX=$idx
    if (( SEARCH_INDEX < 0 )); then
        SEARCH_INDEX=$((${#SEARCH_MATCHES[@]} - 1))
    elif (( SEARCH_INDEX >= ${#SEARCH_MATCHES[@]} )); then
        SEARCH_INDEX=0
    fi

    local match="${SEARCH_MATCHES[$((SEARCH_INDEX + 1))]}"
    local parts=("${(@s/:/)match}")
    CURSOR_LINE=${parts[1]}
    CURSOR_COL=${parts[2]}
    clamp_cursor
}

# ============================================================================
# DISPLAY FUNCTIONS
# ============================================================================

# Draw the interface
draw_screen() {
    print -n "$CURSOR_HIDE"
    tput cup 0 0

    # Header
    echo "${BOLD}${ANSI_COLORS[Y]}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${ANSI_COLORS[Y]}║${RESET}          ${BOLD}MARVEL RIVALS RAINBOW CONVERTER - VIM MODE${RESET}                     ${BOLD}${ANSI_COLORS[Y]}║${RESET}"
    echo "${BOLD}${ANSI_COLORS[Y]}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"

    # Mode indicator with color
    local mode_color=""
    local mode_text=""
    case "$MODE" in
        NORMAL)
            mode_color="${ANSI_COLORS[B]}"
            mode_text=" NORMAL "
            ;;
        INSERT)
            mode_color="${ANSI_COLORS[G]}"
            mode_text=" INSERT "
            ;;
        VISUAL)
            mode_color="${ANSI_COLORS[M]}"
            mode_text=" VISUAL "
            ;;
        COMMAND)
            mode_color="${ANSI_COLORS[Y]}"
            mode_text="COMMAND "
            ;;
    esac
    echo "${mode_color}${REVERSE}${BOLD}${mode_text}${RESET}  Pattern: $(get_pattern_name) [${CURRENT_PATTERN}/6]  Preview: $([[ $SHOW_PREVIEW -eq 1 ]] && echo "ON" || echo "OFF")"
    echo ""

    # Text buffer display (with line numbers)
    local display_start=1
    local display_end=${#TEXT_BUFFER[@]}
    local max_lines=10

    # Center view on cursor
    if (( ${#TEXT_BUFFER[@]} > max_lines )); then
        display_start=$((CURSOR_LINE - max_lines / 2))
        if (( display_start < 1 )); then
            display_start=1
        fi
        display_end=$((display_start + max_lines - 1))
        if (( display_end > ${#TEXT_BUFFER[@]} )); then
            display_end=${#TEXT_BUFFER[@]}
            display_start=$((display_end - max_lines + 1))
            if (( display_start < 1 )); then
                display_start=1
            fi
        fi
    fi

    echo "${BOLD}Text Buffer:${RESET}"
    for (( i=display_start; i<=display_end; i++ )); do
        local line="${TEXT_BUFFER[$i]}"
        local line_num=$(printf "%3d" $i)

        # Highlight current line
        if (( i == CURSOR_LINE )); then
            print -n "${DIM}${line_num}${RESET} ${REVERSE}"
            # Show cursor position
            for (( j=0; j<${#line}; j++ )); do
                if (( j == CURSOR_COL )); then
                    print -n "${BOLD}${ANSI_COLORS[Y]}${line:$j:1}${RESET}${REVERSE}"
                else
                    print -n "${line:$j:1}"
                fi
            done
            echo "${RESET}"
        else
            echo "${DIM}${line_num}${RESET} ${line}"
        fi
    done

    # Padding
    for (( i=display_end+1; i<=display_start+max_lines-1; i++ )); do
        echo "${DIM}  ~${RESET}"
    done
    echo ""

    # Preview section
    if [[ $SHOW_PREVIEW -eq 1 ]]; then
        echo "${BOLD}Preview:${RESET}"
        echo "${DIM}────────────────────────────────────────────────────────────────────────────${RESET}"
        for line in "${TEXT_BUFFER[@]}"; do
            if [[ -n "$line" ]]; then
                local converted=$(convert_text "$line")
                local previewed=$(preview_text "$converted")
                echo "  $previewed"
            fi
        done
        echo "${DIM}────────────────────────────────────────────────────────────────────────────${RESET}"
        echo ""
    fi

    # Command line / Status line
    if [[ "$MODE" == "COMMAND" ]]; then
        echo -n ":${COMMAND_INPUT}"
    elif [[ -n "$MESSAGE" ]]; then
        echo "${MESSAGE_COLOR}${MESSAGE}${RESET}"
        MESSAGE=""  # Clear after display
    else
        echo "${DIM}Press ? for help${RESET}"
    fi

    print -n "$CURSOR_SHOW"
}

# Show help overlay
show_help() {
    clear
    echo "${BOLD}${ANSI_COLORS[Y]}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo "${BOLD}                    MARVEL RIVALS VIM MODE - HELP                           ${RESET}"
    echo "${BOLD}${ANSI_COLORS[Y]}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "${BOLD}${ANSI_COLORS[B]}NORMAL MODE${RESET} (Navigation and Commands)"
    echo "  ${BOLD}h j k l${RESET}      Move cursor left/down/up/right"
    echo "  ${BOLD}0 ^${RESET}          Move to start of line"
    echo "  ${BOLD}\$${RESET}            Move to end of line"
    echo "  ${BOLD}w b${RESET}          Move forward/backward by word"
    echo "  ${BOLD}gg G${RESET}         Move to first/last line"
    echo "  ${BOLD}i${RESET}            Enter INSERT mode before cursor"
    echo "  ${BOLD}a${RESET}            Enter INSERT mode after cursor"
    echo "  ${BOLD}I${RESET}            Insert at beginning of line"
    echo "  ${BOLD}A${RESET}            Insert at end of line"
    echo "  ${BOLD}o${RESET}            Open new line below and enter INSERT mode"
    echo "  ${BOLD}O${RESET}            Open new line above and enter INSERT mode"
    echo "  ${BOLD}v${RESET}            Enter VISUAL mode"
    echo "  ${BOLD}dd${RESET}           Delete (cut) current line"
    echo "  ${BOLD}yy${RESET}           Yank (copy) current line"
    echo "  ${BOLD}p${RESET}            Paste after cursor"
    echo "  ${BOLD}P${RESET}            Paste before cursor"
    echo "  ${BOLD}u${RESET}            Undo"
    echo "  ${BOLD}Ctrl-r${RESET}       Redo"
    echo "  ${BOLD}/${RESET}            Enter search mode"
    echo "  ${BOLD}n${RESET}            Next search match"
    echo "  ${BOLD}N${RESET}            Previous search match"
    echo "  ${BOLD}:${RESET}            Enter COMMAND mode"
    echo ""
    echo "${BOLD}${ANSI_COLORS[G]}INSERT MODE${RESET} (Text Editing)"
    echo "  ${BOLD}ESC${RESET}          Return to NORMAL mode"
    echo "  ${BOLD}Ctrl-c${RESET}       Return to NORMAL mode (alternative)"
    echo "  ${BOLD}Printable${RESET}    Insert character at cursor"
    echo "  ${BOLD}Backspace${RESET}    Delete character before cursor"
    echo "  ${BOLD}Enter${RESET}        Insert new line"
    echo ""
    echo "${BOLD}${ANSI_COLORS[M]}VISUAL MODE${RESET} (Text Selection)"
    echo "  ${BOLD}h j k l${RESET}      Extend selection"
    echo "  ${BOLD}d${RESET}            Delete (cut) selection"
    echo "  ${BOLD}y${RESET}            Yank (copy) selection"
    echo "  ${BOLD}ESC${RESET}          Return to NORMAL mode"
    echo ""
    echo "${BOLD}${ANSI_COLORS[Y]}COMMAND MODE${RESET} (Special Commands)"
    echo "  ${BOLD}:w${RESET}           Write/Save converted output to file"
    echo "  ${BOLD}:q${RESET}           Quit"
    echo "  ${BOLD}:wq${RESET}          Write and quit"
    echo "  ${BOLD}:q!${RESET}          Quit without saving"
    echo "  ${BOLD}ESC${RESET}          Return to NORMAL mode"
    echo ""
    echo "${BOLD}${ANSI_COLORS[P]}SPECIAL SHORTCUTS${RESET} (Work in most modes)"
    echo "  ${BOLD}Tab${RESET}          Cycle to next pattern"
    echo "  ${BOLD}Shift-Tab${RESET}    Cycle to previous pattern"
    echo "  ${BOLD}Space${RESET}        Toggle preview on/off (NORMAL mode)"
    echo "  ${BOLD}Enter${RESET}        Apply conversion & copy to clipboard (NORMAL mode)"
    echo "  ${BOLD}Ctrl-s${RESET}       Quick save to file"
    echo "  ${BOLD}?${RESET}            Show this help (NORMAL mode)"
    echo ""
    echo "${BOLD}${ANSI_COLORS[T]}PATTERNS${RESET}"
    echo "  ${BOLD}1${RESET} Full Rainbow   - All 13 colors (Y→O→R→P→M→U→B→I→A→T→G→E→K)"
    echo "  ${BOLD}2${RESET} Warm Rainbow   - Fiery colors (Y→O→R→P→M)"
    echo "  ${BOLD}3${RESET} Cool Rainbow   - Chill colors (U→B→I→A→T→G)"
    echo "  ${BOLD}4${RESET} Wave Rainbow   - Smooth wave effect (forward and back)"
    echo "  ${BOLD}5${RESET} Alternating    - High contrast (Y, R, M, B, A, G)"
    echo "  ${BOLD}6${RESET} Word Rainbow   - Color per word (not per character)"
    echo ""
    echo "${DIM}Press any key to return...${RESET}"

    read -k 1
}

# ============================================================================
# MODE HANDLERS
# ============================================================================

# Handle NORMAL mode input
handle_normal_mode() {
    local key="$1"

    case "$key" in
        # Movement
        h) ((CURSOR_COL--)); clamp_cursor ;;
        l) ((CURSOR_COL++)); clamp_cursor ;;
        j) ((CURSOR_LINE++)); clamp_cursor ;;
        k) ((CURSOR_LINE--)); clamp_cursor ;;

        0) CURSOR_COL=0; clamp_cursor ;;
        '^') CURSOR_COL=0; clamp_cursor ;;
        '$') CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}; clamp_cursor ;;

        w) # Move to next word
            local line="${TEXT_BUFFER[$CURSOR_LINE]}"
            local rest="${line:$((CURSOR_COL+1))}"
            if [[ "$rest" =~ [[:space:]]*[^[:space:]]+ ]]; then
                local match="$MATCH"
                ((CURSOR_COL += ${#match}))
            fi
            clamp_cursor
            ;;

        b) # Move to previous word
            local line="${TEXT_BUFFER[$CURSOR_LINE]}"
            local before="${line:0:$CURSOR_COL}"
            if [[ "$before" =~ [^[:space:]]+[[:space:]]*$ ]]; then
                local match="$MATCH"
                ((CURSOR_COL -= ${#match}))
            fi
            clamp_cursor
            ;;

        g) # gg - go to first line
            read -k 1 -t 0.5 key2
            if [[ "$key2" == "g" ]]; then
                CURSOR_LINE=1
                CURSOR_COL=0
                clamp_cursor
            fi
            ;;

        G) # Go to last line
            CURSOR_LINE=${#TEXT_BUFFER[@]}
            CURSOR_COL=0
            clamp_cursor
            ;;

        # Mode changes
        i) MODE="INSERT" ;;
        a) ((CURSOR_COL++)); MODE="INSERT"; clamp_cursor ;;
        I) CURSOR_COL=0; MODE="INSERT"; clamp_cursor ;;
        A) CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}; MODE="INSERT"; clamp_cursor ;;

        o) # Open line below
            save_undo
            ((CURSOR_LINE++))
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
            CURSOR_COL=0
            MODE="INSERT"
            ;;

        O) # Open line above
            save_undo
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$((CURSOR_LINE-1))}" "" "${TEXT_BUFFER[@]:$((CURSOR_LINE-1))}")
            CURSOR_COL=0
            MODE="INSERT"
            ;;

        v) # Visual mode
            MODE="VISUAL"
            VISUAL_START_LINE=$CURSOR_LINE
            VISUAL_START_COL=$CURSOR_COL
            ;;

        # Editing
        d) # dd - delete line
            read -k 1 -t 0.5 key2
            if [[ "$key2" == "d" ]]; then
                save_undo
                YANK_BUFFER=("${TEXT_BUFFER[$CURSOR_LINE]}")
                if (( ${#TEXT_BUFFER[@]} == 1 )); then
                    TEXT_BUFFER=("")
                else
                    TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$((CURSOR_LINE-1))}" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
                fi
                clamp_cursor
                set_message "Deleted 1 line" "${ANSI_COLORS[R]}"
            fi
            ;;

        y) # yy - yank line
            read -k 1 -t 0.5 key2
            if [[ "$key2" == "y" ]]; then
                YANK_BUFFER=("${TEXT_BUFFER[$CURSOR_LINE]}")
                set_message "Yanked 1 line" "${ANSI_COLORS[G]}"
            fi
            ;;

        p) # Paste after
            if (( ${#YANK_BUFFER[@]} > 0 )); then
                save_undo
                ((CURSOR_LINE++))
                TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "${YANK_BUFFER[@]}" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
                set_message "Pasted ${#YANK_BUFFER[@]} line(s)" "${ANSI_COLORS[G]}"
            fi
            ;;

        P) # Paste before
            if (( ${#YANK_BUFFER[@]} > 0 )); then
                save_undo
                TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$((CURSOR_LINE-1))}" "${YANK_BUFFER[@]}" "${TEXT_BUFFER[@]:$((CURSOR_LINE-1))}")
                set_message "Pasted ${#YANK_BUFFER[@]} line(s)" "${ANSI_COLORS[G]}"
            fi
            ;;

        u) undo ;;

        # Search
        /)
            echo -n "${CLEAR_LINE}\rSearch: "
            read SEARCH_TERM
            search
            ;;

        n) # Next match
            if (( ${#SEARCH_MATCHES[@]} > 0 )); then
                jump_to_search_match $((SEARCH_INDEX + 1))
            fi
            ;;

        N) # Previous match
            if (( ${#SEARCH_MATCHES[@]} > 0 )); then
                jump_to_search_match $((SEARCH_INDEX - 1))
            fi
            ;;

        # Command mode
        :)
            MODE="COMMAND"
            COMMAND_INPUT=""
            ;;

        # Special shortcuts
        ' ') # Toggle preview
            if [[ $SHOW_PREVIEW -eq 1 ]]; then
                SHOW_PREVIEW=0
                set_message "Preview OFF" "${ANSI_COLORS[R]}"
            else
                SHOW_PREVIEW=1
                set_message "Preview ON" "${ANSI_COLORS[G]}"
            fi
            ;;

        $'\n') # Enter - apply and copy
            apply_conversion
            ;;

        $'\t') # Tab - next pattern
            ((CURRENT_PATTERN = (CURRENT_PATTERN % 6) + 1))
            set_message "Pattern: $(get_pattern_name)" "${ANSI_COLORS[Y]}"
            ;;

        '?') show_help ;;
    esac
}

# Handle INSERT mode input
handle_insert_mode() {
    local key="$1"

    case "$key" in
        $'\e') # ESC
            MODE="NORMAL"
            if (( CURSOR_COL > 0 )); then
                ((CURSOR_COL--))
            fi
            clamp_cursor
            ;;

        $'\x7f'|$'\b') # Backspace
            if (( CURSOR_COL > 0 )); then
                save_undo
                local line="${TEXT_BUFFER[$CURSOR_LINE]}"
                TEXT_BUFFER[$CURSOR_LINE]="${line:0:$((CURSOR_COL-1))}${line:$CURSOR_COL}"
                ((CURSOR_COL--))
            elif (( CURSOR_LINE > 1 )); then
                # Join with previous line
                save_undo
                local current_line="${TEXT_BUFFER[$CURSOR_LINE]}"
                ((CURSOR_LINE--))
                CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}
                TEXT_BUFFER[$CURSOR_LINE]+="$current_line"
                TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "${TEXT_BUFFER[@]:$((CURSOR_LINE+1))}")
            fi
            ;;

        $'\n') # Enter
            save_undo
            local line="${TEXT_BUFFER[$CURSOR_LINE]}"
            local before="${line:0:$CURSOR_COL}"
            local after="${line:$CURSOR_COL}"
            TEXT_BUFFER[$CURSOR_LINE]="$before"
            ((CURSOR_LINE++))
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "$after" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
            CURSOR_COL=0
            ;;

        *) # Regular character
            if [[ -n "$key" ]] && [[ "$key" =~ [[:print:]] ]]; then
                save_undo
                local line="${TEXT_BUFFER[$CURSOR_LINE]}"
                TEXT_BUFFER[$CURSOR_LINE]="${line:0:$CURSOR_COL}${key}${line:$CURSOR_COL}"
                ((CURSOR_COL++))
            fi
            ;;
    esac
}

# Handle VISUAL mode input
handle_visual_mode() {
    local key="$1"

    case "$key" in
        $'\e') # ESC
            MODE="NORMAL"
            ;;

        # Movement (same as normal mode)
        h) ((CURSOR_COL--)); clamp_cursor ;;
        l) ((CURSOR_COL++)); clamp_cursor ;;
        j) ((CURSOR_LINE++)); clamp_cursor ;;
        k) ((CURSOR_LINE--)); clamp_cursor ;;

        d) # Delete selection
            save_undo
            # Simple line-wise delete for now
            local start=$VISUAL_START_LINE
            local end=$CURSOR_LINE
            if (( start > end )); then
                local tmp=$start
                start=$end
                end=$tmp
            fi

            YANK_BUFFER=("${TEXT_BUFFER[@]:$start:$((end-start+1))}")
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$start}" "${TEXT_BUFFER[@]:$((end+1))}")

            if (( ${#TEXT_BUFFER[@]} == 0 )); then
                TEXT_BUFFER=("")
            fi

            CURSOR_LINE=$start
            clamp_cursor
            MODE="NORMAL"
            set_message "Deleted $((end-start+1)) line(s)" "${ANSI_COLORS[R]}"
            ;;

        y) # Yank selection
            local start=$VISUAL_START_LINE
            local end=$CURSOR_LINE
            if (( start > end )); then
                local tmp=$start
                start=$end
                end=$tmp
            fi

            YANK_BUFFER=("${TEXT_BUFFER[@]:$start:$((end-start+1))}")
            MODE="NORMAL"
            set_message "Yanked $((end-start+1)) line(s)" "${ANSI_COLORS[G]}"
            ;;
    esac
}

# Handle COMMAND mode input
handle_command_mode() {
    local key="$1"

    case "$key" in
        $'\e') # ESC
            MODE="NORMAL"
            COMMAND_INPUT=""
            ;;

        $'\n') # Enter - execute command
            execute_command "$COMMAND_INPUT"
            MODE="NORMAL"
            COMMAND_INPUT=""
            ;;

        $'\x7f'|$'\b') # Backspace
            COMMAND_INPUT="${COMMAND_INPUT:0:-1}"
            ;;

        *) # Regular character
            if [[ -n "$key" ]] && [[ "$key" =~ [[:print:]] ]]; then
                COMMAND_INPUT+="$key"
            fi
            ;;
    esac
}

# Execute command
execute_command() {
    local cmd="$1"

    case "$cmd" in
        w) save_to_file ;;
        q)
            clear
            echo "Thanks for using Marvel Rivals Vim Mode!"
            exit 0
            ;;
        wq) save_to_file; clear; echo "Saved and quit!"; exit 0 ;;
        q!) clear; echo "Quit without saving!"; exit 0 ;;
        *) set_message "Unknown command: :$cmd" "${ANSI_COLORS[R]}" ;;
    esac
}

# Apply conversion and copy to clipboard
apply_conversion() {
    local all_text="${(j:\n:)TEXT_BUFFER}"
    if [[ -z "$all_text" ]]; then
        set_message "No text to convert" "${ANSI_COLORS[R]}"
        return
    fi

    local converted=$(convert_text "$all_text")

    # Try to copy to clipboard
    if command -v xclip &> /dev/null; then
        echo -n "$converted" | xclip -selection clipboard
        set_message "Converted & copied to clipboard! (xclip)" "${ANSI_COLORS[G]}"
    elif command -v xsel &> /dev/null; then
        echo -n "$converted" | xsel --clipboard
        set_message "Converted & copied to clipboard! (xsel)" "${ANSI_COLORS[G]}"
    elif command -v pbcopy &> /dev/null; then
        echo -n "$converted" | pbcopy
        set_message "Converted & copied to clipboard! (pbcopy)" "${ANSI_COLORS[G]}"
    else
        set_message "Converted! (clipboard not available)" "${ANSI_COLORS[Y]}"
    fi

    # Also show result
    echo ""
    echo "${BOLD}Converted Result:${RESET}"
    echo "$converted"
    echo ""
    echo -n "Press any key to continue..."
    read -k 1
}

# Save to file
save_to_file() {
    local all_text="${(j:\n:)TEXT_BUFFER}"
    if [[ -z "$all_text" ]]; then
        set_message "No text to save" "${ANSI_COLORS[R]}"
        return
    fi

    local converted=$(convert_text "$all_text")
    local filename="rivals_output_$(date +%Y%m%d_%H%M%S).txt"

    echo "$converted" > "$filename"
    set_message "Saved to $filename" "${ANSI_COLORS[G]}"
}

# ============================================================================
# MAIN LOOP
# ============================================================================

main() {
    # Initialize terminal
    clear
    stty -echo  # Disable echo

    # Trap cleanup on exit
    trap 'stty echo; print -n "$CURSOR_SHOW"; clear' EXIT INT TERM

    # If arguments provided, use as initial text
    if [[ $# -gt 0 ]]; then
        TEXT_BUFFER=("$@")
    fi

    # Main loop
    while true; do
        clear
        draw_screen

        # Read single key
        read -k 1 key

        # Handle Ctrl+R (redo)
        if [[ "$key" == $'\x12' ]]; then
            redo
            continue
        fi

        # Handle Ctrl+S (quick save)
        if [[ "$key" == $'\x13' ]]; then
            save_to_file
            continue
        fi

        # Handle Ctrl+C (back to normal or quit)
        if [[ "$key" == $'\x03' ]]; then
            if [[ "$MODE" != "NORMAL" ]]; then
                MODE="NORMAL"
            else
                clear
                echo "Interrupted!"
                exit 130
            fi
            continue
        fi

        # Handle Shift+Tab (previous pattern)
        if [[ "$key" == $'\e' ]]; then
            read -k 2 -t 0.1 key2
            if [[ "$key2" == "[Z" ]]; then
                ((CURRENT_PATTERN = CURRENT_PATTERN - 1))
                if (( CURRENT_PATTERN < 1 )); then
                    CURRENT_PATTERN=6
                fi
                set_message "Pattern: $(get_pattern_name)" "${ANSI_COLORS[Y]}"
                continue
            fi
        fi

        # Route to appropriate mode handler
        case "$MODE" in
            NORMAL) handle_normal_mode "$key" ;;
            INSERT) handle_insert_mode "$key" ;;
            VISUAL) handle_visual_mode "$key" ;;
            COMMAND) handle_command_mode "$key" ;;
        esac
    done
}

# Run main if executed directly
if [[ "${(%):-%x}" == "${0}" ]] || [[ "${ZSH_ARGZERO}" == "${0}" ]]; then
    main "$@"
fi
