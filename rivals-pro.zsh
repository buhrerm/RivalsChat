#!/usr/bin/env zsh
# Marvel Rivals Rainbow Converter - Professional Unified TUI
# A htop/vim-quality terminal interface with split-screen panels
# Integrates: rivals-tui.zsh, rivals-keybindings.zsh, rivals-preview.zsh

setopt extended_glob local_options local_traps NO_NOTIFY NO_MONITOR

# ============================================================================
# TERMINAL CONTROL & COLOR DEFINITIONS
# ============================================================================

# Terminal escape sequences
typeset -gA TERM_ESC=(
    [HIDE_CURSOR]="\e[?25l"
    [SHOW_CURSOR]="\e[?25h"
    [SAVE_CURSOR]="\e[s"
    [RESTORE_CURSOR]="\e[u"
    [CURSOR_HOME]="\e[H"
    [CLEAR_SCREEN]="\e[2J"
    [CLEAR_LINE]="\e[2K"
    [CLEAR_TO_EOL]="\e[K"
    [CLEAR_TO_EOS]="\e[J"
    [ALT_SCREEN_ON]="\e[?1049h"
    [ALT_SCREEN_OFF]="\e[?1049l"
    [MOUSE_ON]="\e[?1000h\e[?1002h\e[?1015h\e[?1006h"
    [MOUSE_OFF]="\e[?1006l\e[?1015l\e[?1002l\e[?1000l"
    [RESET]="\e[0m"
    [BOLD]="\e[1m"
    [DIM]="\e[2m"
    [ITALIC]="\e[3m"
    [UNDERLINE]="\e[4m"
    [REVERSE]="\e[7m"
)

# 256-color palette (optimized for Marvel Rivals)
typeset -gA COLORS=(
    # Rivals colors
    [Y_GOLD]=220
    [O_ORANGE]=208
    [R_RED]=196
    [P_PINK]=213
    [M_MAGENTA]=201
    [U_PURPLE]=141
    [B_BLUE]=75
    [I_INDIGO]=27
    [A_AQUA]=51
    [T_TEAL]=49
    [G_GREEN]=46
    [E_LIME]=154
    [K_YELLOW]=226

    # UI theme colors
    [BG_DARK]=232
    [BG_PANEL]=234
    [BG_INPUT]=235
    [BG_SELECTED]=238
    [BG_HEADER]=24
    [BG_STATUS]=240
    [FG_NORMAL]=252
    [FG_BRIGHT]=255
    [FG_DIM]=244
    [BORDER]=240
    [BORDER_FOCUS]=75
    [ACCENT_1]=201
    [ACCENT_2]=51
)

# RGB color mappings for visual preview
typeset -gA RGB_COLORS=(
    [Y]="255;215;0"
    [O]="255;140;0"
    [R]="220;20;60"
    [P]="255;105;180"
    [M]="255;20;147"
    [U]="138;43;226"
    [B]="30;144;255"
    [I]="25;25;112"
    [A]="0;206;209"
    [T]="64;224;208"
    [G]="50;205;50"
    [E]="173;255;47"
    [K]="255;255;0"
)

# ============================================================================
# GLOBAL STATE MANAGEMENT
# ============================================================================

# Application state
typeset -gA APP_STATE=(
    [RUNNING]=0
    [NEEDS_REDRAW]=1
    [FOCUS_PANEL]=0          # 0=input, 1=preview, 2=patterns
    [VIM_MODE]=NORMAL        # NORMAL, INSERT, VISUAL, COMMAND
    [CURRENT_PATTERN]=0      # 0-6
    [SHOW_HELP]=0
    [SHOW_COMMAND_PALETTE]=0
    [MOUSE_ENABLED]=1
    [ANIMATION_FRAME]=0
    [LAST_UPDATE_TIME]=0
)

# Terminal dimensions
typeset -gA TERM_INFO=(
    [WIDTH]=0
    [HEIGHT]=0
    [COLOR_SUPPORT]=256
)

# Panel layout (percentages converted to columns/rows)
typeset -gA LAYOUT=(
    [LEFT_WIDTH]=0
    [RIGHT_WIDTH]=0
    [RIGHT_TOP_HEIGHT]=0
    [RIGHT_BOTTOM_HEIGHT]=0
    [STATUS_HEIGHT]=2
    [HEADER_HEIGHT]=3
)

# Text buffer (vim-style)
typeset -ga TEXT_BUFFER=("")
typeset -g CURSOR_LINE=1
typeset -g CURSOR_COL=0
typeset -g SCROLL_OFFSET=0
typeset -g VISUAL_START_LINE=0
typeset -g VISUAL_START_COL=0

# Edit history
typeset -ga UNDO_STACK
typeset -ga REDO_STACK
typeset -g MAX_UNDO=100

# Clipboard
typeset -ga YANK_BUFFER

# Search
typeset -g SEARCH_TERM=""
typeset -ga SEARCH_MATCHES
typeset -g SEARCH_INDEX=0

# Pattern definitions
typeset -ga PATTERN_NAMES=(
    "Full Rainbow"
    "Warm Rainbow"
    "Cool Rainbow"
    "Wave Rainbow"
    "Alternating"
    "Word Rainbow"
    "Gradient"
)

typeset -ga PATTERN_DESCRIPTIONS=(
    "All 13 colors (Y→O→R→P→M→U→B→I→A→T→G→E→K)"
    "Warm colors only (Y→O→R→P→M)"
    "Cool colors only (U→B→I→A→T→G)"
    "Smooth wave effect (forward & back)"
    "High contrast (Y, R, M, B, A, G)"
    "Color per word (not per character)"
    "Gradient transition (Gold→Purple→Blue)"
)

typeset -ga RAINBOW_FULL=(Y O R P M U B I A T G E K)
typeset -ga RAINBOW_WARM=(Y O R P M)
typeset -ga RAINBOW_COOL=(U B I A T G)
typeset -ga RAINBOW_WAVE=(Y O R P M U B I A T G E K E G T A I B U M P R O)
typeset -ga RAINBOW_ALT=(Y R M B A G)

# Command palette items
typeset -ga COMMAND_PALETTE=(
    "convert:Convert & Copy to Clipboard"
    "save:Save to File"
    "clear:Clear Text Buffer"
    "undo:Undo Last Change"
    "redo:Redo Last Change"
    "pattern:next:Next Pattern"
    "pattern:prev:Previous Pattern"
    "focus:next:Next Panel"
    "help:Toggle Help"
    "quit:Quit Application"
)

# Performance optimization
typeset -g LAST_RENDERED_HASH=""
typeset -g DEBOUNCE_COUNTER=0
typeset -g DEBOUNCE_DELAY=2

# Status message
typeset -g STATUS_MESSAGE=""
typeset -g STATUS_COLOR=""
typeset -g STATUS_TIMEOUT=0

# Tab management
typeset -ga TABS=("Main")
typeset -g CURRENT_TAB=0

# Function key bindings
typeset -gA FKEY_ACTIONS=(
    [F1]="show_help"
    [F2]="save_file"
    [F3]="search"
    [F4]="clear_buffer"
    [F5]="refresh"
    [F6]="toggle_preview"
    [F7]="prev_pattern"
    [F8]="next_pattern"
    [F9]="undo"
    [F10]="redo"
    [F11]="fullscreen"
    [F12]="command_palette"
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Color output helpers
fg() { echo -n "\e[38;5;${1}m"; }
bg() { echo -n "\e[48;5;${1}m"; }
rgb_fg() { echo -n "\e[38;2;${1}m"; }
reset_color() { echo -n "${TERM_ESC[RESET]}"; }

# Cursor movement
move_cursor() { echo -n "\e[${1};${2}H"; }
hide_cursor() { echo -n "${TERM_ESC[HIDE_CURSOR]}"; }
show_cursor() { echo -n "${TERM_ESC[SHOW_CURSOR]}"; }

# Screen control
clear_screen() { echo -n "${TERM_ESC[CLEAR_SCREEN]}${TERM_ESC[CURSOR_HOME]}"; }
clear_line() { echo -n "${TERM_ESC[CLEAR_LINE]}"; }

# Detect terminal capabilities
detect_terminal() {
    TERM_INFO[WIDTH]=$(tput cols 2>/dev/null || echo 80)
    TERM_INFO[HEIGHT]=$(tput lines 2>/dev/null || echo 24)

    local colors=$(tput colors 2>/dev/null || echo 8)
    if [[ $colors -ge 256 ]]; then
        TERM_INFO[COLOR_SUPPORT]=256
    elif [[ $colors -ge 16 ]]; then
        TERM_INFO[COLOR_SUPPORT]=16
    else
        TERM_INFO[COLOR_SUPPORT]=8
    fi

    # Check for true color
    if [[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ (truecolor|24bit) ]]; then
        TERM_INFO[COLOR_SUPPORT]=16777216
    fi

    # Calculate layout
    calculate_layout
}

# Calculate panel dimensions
calculate_layout() {
    local w=${TERM_INFO[WIDTH]}
    local h=${TERM_INFO[HEIGHT]}

    # Left panel: 40% of width
    LAYOUT[LEFT_WIDTH]=$((w * 40 / 100))

    # Right panel: 60% of width
    LAYOUT[RIGHT_WIDTH]=$((w - LAYOUT[LEFT_WIDTH] - 1))

    # Right top: 60% of available height
    local available_h=$((h - LAYOUT[HEADER_HEIGHT] - LAYOUT[STATUS_HEIGHT]))
    LAYOUT[RIGHT_TOP_HEIGHT]=$((available_h * 60 / 100))

    # Right bottom: remaining height
    LAYOUT[RIGHT_BOTTOM_HEIGHT]=$((available_h - LAYOUT[RIGHT_TOP_HEIGHT] - 1))
}

# Set status message
set_status() {
    STATUS_MESSAGE="$1"
    STATUS_COLOR="${2:-${COLORS[FG_NORMAL]}}"
    STATUS_TIMEOUT=$(date +%s)
}

# Hash text for change detection (performance optimization)
hash_text() {
    echo -n "$1" | md5sum 2>/dev/null | cut -d' ' -f1
}

# ============================================================================
# DRAWING PRIMITIVES
# ============================================================================

# Draw box with borders
draw_box() {
    local x=$1 y=$2 w=$3 h=$4
    local title=$5
    local focused=${6:-0}

    local border_color=$COLORS[BORDER]
    [[ $focused -eq 1 ]] && border_color=$COLORS[BORDER_FOCUS]

    # Box characters
    local TL="┌" TR="┐" BL="└" BR="┘"
    local H="─" V="│"
    local LT="├" RT="┤"

    # Draw top
    move_cursor $y $x
    fg $border_color
    echo -n "$TL"
    for ((i=1; i<w-1; i++)); do echo -n "$H"; done
    echo -n "$TR"

    # Draw title
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        local title_x=$((x + (w - title_len - 4) / 2))
        move_cursor $y $title_x
        echo -n "$LT${TERM_ESC[BOLD]} $title ${TERM_ESC[RESET]}"
        fg $border_color
        echo -n "$RT"
    fi

    # Draw sides
    for ((i=1; i<h-1; i++)); do
        move_cursor $((y+i)) $x
        echo -n "$V"
        move_cursor $((y+i)) $((x+w-1))
        echo -n "$V"
    done

    # Draw bottom
    move_cursor $((y+h-1)) $x
    echo -n "$BL"
    for ((i=1; i<w-1; i++)); do echo -n "$H"; done
    echo -n "$BR"

    reset_color
}

# Draw horizontal separator
draw_separator() {
    local x=$1 y=$2 w=$3
    local char="${4:-─}"

    move_cursor $y $x
    fg $COLORS[BORDER]
    for ((i=0; i<w; i++)); do echo -n "$char"; done
    reset_color
}

# Draw text with truncation
draw_text() {
    local x=$1 y=$2 text=$3 max_width=$4

    move_cursor $y $x
    if [[ ${#text} -gt $max_width ]]; then
        echo -n "${text:0:$((max_width-3))}..."
    else
        echo -n "$text"
    fi
}

# Draw centered text
draw_centered() {
    local y=$1 text=$2 width=$3
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))

    move_cursor $y $((padding > 0 ? padding : 1))
    echo -n "$text"
}

# ============================================================================
# CONVERSION FUNCTIONS (from rivals-keybindings.zsh)
# ============================================================================

convert_full_rainbow() {
    local text=$1
    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" != " " ]]; then
            output+="#${RAINBOW_FULL[$((color_idx % ${#RAINBOW_FULL[@]} + 1))]}${char}"
            ((color_idx++))
        else
            output+=" "
        fi
    done
    echo -n "$output"
}

convert_warm_rainbow() {
    local text=$1
    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" != " " ]]; then
            output+="#${RAINBOW_WARM[$((color_idx % ${#RAINBOW_WARM[@]} + 1))]}${char}"
            ((color_idx++))
        else
            output+=" "
        fi
    done
    echo -n "$output"
}

convert_cool_rainbow() {
    local text=$1
    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" != " " ]]; then
            output+="#${RAINBOW_COOL[$((color_idx % ${#RAINBOW_COOL[@]} + 1))]}${char}"
            ((color_idx++))
        else
            output+=" "
        fi
    done
    echo -n "$output"
}

convert_wave_rainbow() {
    local text=$1
    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" != " " ]]; then
            output+="#${RAINBOW_WAVE[$((color_idx % ${#RAINBOW_WAVE[@]} + 1))]}${char}"
            ((color_idx++))
        else
            output+=" "
        fi
    done
    echo -n "$output"
}

convert_alternating() {
    local text=$1
    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" != " " ]]; then
            output+="#${RAINBOW_ALT[$((color_idx % ${#RAINBOW_ALT[@]} + 1))]}${char}"
            ((color_idx++))
        else
            output+=" "
        fi
    done
    echo -n "$output"
}

convert_word_rainbow() {
    local text=$1
    local output=""
    local words=(${(s: :)text})
    local color_idx=0

    for word in "${words[@]}"; do
        if [[ -n "$word" ]]; then
            output+="#${RAINBOW_FULL[$((color_idx % ${#RAINBOW_FULL[@]} + 1))]}${word} "
            ((color_idx++))
        fi
    done
    echo -n "${output% }"
}

convert_gradient() {
    local text=$1
    local output=""
    local third=$((${#text} / 3))

    # First third: Gold
    for ((i=0; i<third && i<${#text}; i++)); do
        local char="${text:$i:1}"
        [[ "$char" == " " ]] && output+=" " || output+="#Y${char}"
    done

    # Second third: Purple
    for ((i=third; i<third*2 && i<${#text}; i++)); do
        local char="${text:$i:1}"
        [[ "$char" == " " ]] && output+=" " || output+="#U${char}"
    done

    # Last third: Blue
    for ((i=third*2; i<${#text}; i++)); do
        local char="${text:$i:1}"
        [[ "$char" == " " ]] && output+=" " || output+="#B${char}"
    done

    echo -n "$output"
}

# Main conversion dispatcher
convert_text() {
    local text=$1
    local pattern=${2:-${APP_STATE[CURRENT_PATTERN]}}

    case $pattern in
        0) convert_full_rainbow "$text" ;;
        1) convert_warm_rainbow "$text" ;;
        2) convert_cool_rainbow "$text" ;;
        3) convert_wave_rainbow "$text" ;;
        4) convert_alternating "$text" ;;
        5) convert_word_rainbow "$text" ;;
        6) convert_gradient "$text" ;;
        *) convert_full_rainbow "$text" ;;
    esac
}

# Visual preview with RGB colors
render_visual_preview() {
    local text=$1
    local pattern=${2:-${APP_STATE[CURRENT_PATTERN]}}

    local sequence=""
    case $pattern in
        0) sequence=(${RAINBOW_FULL[@]}) ;;
        1) sequence=(${RAINBOW_WARM[@]}) ;;
        2) sequence=(${RAINBOW_COOL[@]}) ;;
        3) sequence=(${RAINBOW_WAVE[@]}) ;;
        4) sequence=(${RAINBOW_ALT[@]}) ;;
        5|6) sequence=(${RAINBOW_FULL[@]}) ;;
    esac

    local output=""
    local color_idx=0

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [[ "$char" == " " ]]; then
            output+=" "
        else
            local color_code="${sequence[$((color_idx % ${#sequence[@]} + 1))]}"
            local rgb="${RGB_COLORS[$color_code]}"
            output+="\e[38;2;${rgb}m${char}${TERM_ESC[RESET]}"
            ((color_idx++))
        fi
    done

    echo -n "$output"
}

# ============================================================================
# PANEL RENDERING
# ============================================================================

# Draw header bar
draw_header() {
    local y=1
    local w=${TERM[WIDTH]}

    # Background
    move_cursor $y 1
    bg $COLORS[BG_HEADER]
    fg $COLORS[FG_BRIGHT]
    printf "%${w}s" ""

    # Title
    move_cursor $y 3
    echo -n "${TERM_ESC[BOLD]}MARVEL RIVALS RAINBOW CONVERTER PRO${TERM_ESC[RESET]}"

    # Tab indicator
    move_cursor $y $((w - 40))
    fg $COLORS[FG_BRIGHT]
    bg $COLORS[BG_HEADER]
    echo -n "Tab: ${TABS[$((CURRENT_TAB + 1))]} [${CURRENT_TAB}/${#TABS[@]}]"

    # Clock
    local timestamp=$(date "+%H:%M:%S")
    move_cursor $y $((w - ${#timestamp} - 2))
    echo -n "$timestamp"

    reset_color

    # Mode indicator line
    ((y++))
    move_cursor $y 1
    bg $COLORS[BG_PANEL]
    printf "%${w}s" ""

    move_cursor $y 3
    local mode_color=""
    local mode_text=""

    case "${APP_STATE[VIM_MODE]}" in
        NORMAL)
            mode_color=$COLORS[B_BLUE]
            mode_text="NORMAL"
            ;;
        INSERT)
            mode_color=$COLORS[G_GREEN]
            mode_text="INSERT"
            ;;
        VISUAL)
            mode_color=$COLORS[M_MAGENTA]
            mode_text="VISUAL"
            ;;
        COMMAND)
            mode_color=$COLORS[Y_GOLD]
            mode_text="COMMAND"
            ;;
    esac

    fg $mode_color
    echo -n "${TERM_ESC[BOLD]}${TERM_ESC[REVERSE]} $mode_text ${TERM_ESC[RESET]}"

    fg $COLORS[FG_DIM]
    bg $COLORS[BG_PANEL]
    echo -n "  Pattern: ${PATTERN_NAMES[$((${APP_STATE[CURRENT_PATTERN]} + 1))]} [${APP_STATE[CURRENT_PATTERN]}]"

    reset_color
}

# Draw left panel (input area with vim keybindings)
draw_input_panel() {
    local x=1
    local y=$((${LAYOUT[HEADER_HEIGHT]} + 1))
    local w=${LAYOUT[LEFT_WIDTH]}
    local h=$((${TERM_INFO[HEIGHT]} - ${LAYOUT[HEADER_HEIGHT]} - ${LAYOUT[STATUS_HEIGHT]} - 1))

    local focused=$([[ ${APP_STATE[FOCUS_PANEL]} -eq 0 ]] && echo 1 || echo 0)

    # Draw border
    draw_box $x $y $w $h "INPUT TEXT" $focused

    # Content area
    local content_x=$((x + 2))
    local content_y=$((y + 1))
    local content_w=$((w - 4))
    local content_h=$((h - 2))

    # Clear content area
    bg $COLORS[BG_INPUT]
    for ((i=0; i<content_h; i++)); do
        move_cursor $((content_y + i)) $content_x
        printf "%${content_w}s" ""
    done

    # Display visible lines with line numbers
    local visible_lines=$content_h
    local start_line=$((CURSOR_LINE - visible_lines / 2))
    [[ $start_line -lt 1 ]] && start_line=1
    local end_line=$((start_line + visible_lines - 1))
    [[ $end_line -gt ${#TEXT_BUFFER[@]} ]] && end_line=${#TEXT_BUFFER[@]}

    local display_row=0
    for ((line_num=start_line; line_num<=end_line && display_row<content_h; line_num++)); do
        move_cursor $((content_y + display_row)) $content_x

        # Line number
        fg $COLORS[FG_DIM]
        bg $COLORS[BG_INPUT]
        printf "%3d " $line_num

        # Line content
        local line="${TEXT_BUFFER[$line_num]}"
        fg $COLORS[FG_BRIGHT]

        # Highlight cursor line
        if [[ $line_num -eq $CURSOR_LINE ]]; then
            bg $COLORS[BG_SELECTED]

            # Show cursor position
            for ((j=0; j<${#line} && j<content_w-5; j++)); do
                if [[ $j -eq $CURSOR_COL ]]; then
                    fg $COLORS[Y_GOLD]
                    echo -n "${TERM_ESC[REVERSE]}${line:$j:1}${TERM_ESC[RESET]}"
                    fg $COLORS[FG_BRIGHT]
                    bg $COLORS[BG_SELECTED]
                else
                    echo -n "${line:$j:1}"
                fi
            done
        else
            echo -n "${line:0:$((content_w-5))}"
        fi

        ((display_row++))
    done

    # Fill remaining space with tildes
    for ((i=display_row; i<content_h; i++)); do
        move_cursor $((content_y + i)) $content_x
        fg $COLORS[FG_DIM]
        bg $COLORS[BG_INPUT]
        echo -n "  ~ "
    done

    reset_color
}

# Draw right top panel (live preview)
draw_preview_panel() {
    local x=$((${LAYOUT[LEFT_WIDTH]} + 2))
    local y=$((${LAYOUT[HEADER_HEIGHT]} + 1))
    local w=${LAYOUT[RIGHT_WIDTH]}
    local h=${LAYOUT[RIGHT_TOP_HEIGHT]}

    local focused=$([[ ${APP_STATE[FOCUS_PANEL]} -eq 1 ]] && echo 1 || echo 0)

    # Draw border
    draw_box $x $y $w $h "LIVE PREVIEW" $focused

    # Content area
    local content_x=$((x + 2))
    local content_y=$((y + 1))
    local content_w=$((w - 4))
    local content_h=$((h - 2))

    # Clear content
    bg $COLORS[BG_PANEL]
    for ((i=0; i<content_h; i++)); do
        move_cursor $((content_y + i)) $content_x
        printf "%${content_w}s" ""
    done

    # Render preview sections
    local row=0

    # Section 1: Visual preview with colors
    if [[ $row -lt $content_h ]]; then
        move_cursor $((content_y + row)) $content_x
        fg $COLORS[ACCENT_1]
        bg $COLORS[BG_PANEL]
        echo -n "${TERM_ESC[BOLD]}Visual Preview:${TERM_ESC[RESET]}"
        ((row++))
    fi

    if [[ $row -lt $content_h ]]; then
        move_cursor $((content_y + row)) $content_x
        bg $COLORS[BG_PANEL]

        local all_text="${(j:\n:)TEXT_BUFFER}"
        if [[ -n "$all_text" ]]; then
            local visual=$(render_visual_preview "$all_text")
            echo -n "${visual:0:$content_w}"
        else
            fg $COLORS[FG_DIM]
            echo -n "(type something to see preview...)"
        fi
        ((row++))
    fi

    ((row++))

    # Section 2: Rivals code output
    if [[ $row -lt $content_h ]]; then
        move_cursor $((content_y + row)) $content_x
        fg $COLORS[ACCENT_2]
        bg $COLORS[BG_PANEL]
        echo -n "${TERM_ESC[BOLD]}Rivals Code:${TERM_ESC[RESET]}"
        ((row++))
    fi

    if [[ $row -lt $content_h ]]; then
        move_cursor $((content_y + row)) $content_x
        bg $COLORS[BG_PANEL]

        local all_text="${(j:\n:)TEXT_BUFFER}"
        if [[ -n "$all_text" ]]; then
            local converted=$(convert_text "$all_text")
            fg $COLORS[E_LIME]
            echo -n "${converted:0:$content_w}"
        else
            fg $COLORS[FG_DIM]
            echo -n "(code will appear here)"
        fi
        ((row++))
    fi

    ((row++))

    # Section 3: Stats
    if [[ $row -lt $content_h ]]; then
        move_cursor $((content_y + row)) $content_x
        fg $COLORS[FG_DIM]
        bg $COLORS[BG_PANEL]

        local all_text="${(j:\n:)TEXT_BUFFER}"
        local char_count=${#all_text}
        local line_count=${#TEXT_BUFFER[@]}

        echo -n "Lines: $line_count | Characters: $char_count | Cursor: $CURSOR_LINE:$CURSOR_COL"
        ((row++))
    fi

    reset_color
}

# Draw right bottom panel (pattern browser)
draw_pattern_panel() {
    local x=$((${LAYOUT[LEFT_WIDTH]} + 2))
    local y=$((${LAYOUT[HEADER_HEIGHT]} + ${LAYOUT[RIGHT_TOP_HEIGHT]} + 2))
    local w=${LAYOUT[RIGHT_WIDTH]}
    local h=${LAYOUT[RIGHT_BOTTOM_HEIGHT]}

    local focused=$([[ ${APP_STATE[FOCUS_PANEL]} -eq 2 ]] && echo 1 || echo 0)

    # Draw border
    draw_box $x $y $w $h "PATTERNS" $focused

    # Content area
    local content_x=$((x + 2))
    local content_y=$((y + 1))
    local content_w=$((w - 4))
    local content_h=$((h - 2))

    # Clear content
    bg $COLORS[BG_PANEL]
    for ((i=0; i<content_h; i++)); do
        move_cursor $((content_y + i)) $content_x
        printf "%${content_w}s" ""
    done

    # Display patterns
    local row=0
    for ((i=0; i<${#PATTERN_NAMES[@]} && row<content_h; i++)); do
        move_cursor $((content_y + row)) $content_x

        if [[ $i -eq ${APP_STATE[CURRENT_PATTERN]} ]]; then
            bg $COLORS[BG_SELECTED]
            fg $COLORS[Y_GOLD]
            echo -n "▶ "
        else
            bg $COLORS[BG_PANEL]
            fg $COLORS[FG_DIM]
            echo -n "  "
        fi

        # Pattern name
        fg $COLORS[FG_BRIGHT]
        echo -n "${TERM_ESC[BOLD]}${PATTERN_NAMES[$((i+1))]}${TERM_ESC[RESET]}"

        ((row++))

        # Description
        if [[ $row -lt $content_h ]]; then
            move_cursor $((content_y + row)) $((content_x + 4))
            bg $COLORS[BG_PANEL]
            fg $COLORS[FG_DIM]
            local desc="${PATTERN_DESCRIPTIONS[$((i+1))]}"
            echo -n "${desc:0:$((content_w-6))}"
            ((row++))
        fi
    done

    reset_color
}

# Draw status bar
draw_status_bar() {
    local y=${TERM_INFO[HEIGHT]}
    local w=${TERM_INFO[WIDTH]}

    # Background
    move_cursor $y 1
    bg $COLORS[BG_STATUS]
    fg $COLORS[FG_NORMAL]
    printf "%${w}s" ""

    # Left side: shortcuts
    move_cursor $y 2

    local shortcuts=""
    case "${APP_STATE[VIM_MODE]}" in
        NORMAL)
            shortcuts="hjkl:Move | i:Insert | v:Visual | ::Cmd | Tab:Focus | F1:Help | q:Quit"
            ;;
        INSERT)
            shortcuts="ESC:Normal | Ctrl-C:Normal | Type to edit..."
            ;;
        VISUAL)
            shortcuts="hjkl:Extend | d:Delete | y:Yank | ESC:Normal"
            ;;
        COMMAND)
            shortcuts="Enter:Execute | ESC:Cancel"
            ;;
    esac

    echo -n "$shortcuts"

    # Right side: status message or info
    local right_text=""

    if [[ -n "$STATUS_MESSAGE" ]]; then
        local current_time=$(date +%s)
        if [[ $((current_time - STATUS_TIMEOUT)) -lt 3 ]]; then
            right_text="$STATUS_MESSAGE"
            fg $STATUS_COLOR
        else
            STATUS_MESSAGE=""
        fi
    else
        right_text="Ready"
    fi

    move_cursor $y $((w - ${#right_text} - 2))
    echo -n "$right_text"

    reset_color
}

# ============================================================================
# VIM MODE HANDLERS
# ============================================================================

# Save to undo stack
save_undo() {
    local state="${(j:\n:)TEXT_BUFFER}|$CURSOR_LINE|$CURSOR_COL"
    UNDO_STACK+=("$state")

    if [[ ${#UNDO_STACK[@]} -gt $MAX_UNDO ]]; then
        shift UNDO_STACK
    fi

    REDO_STACK=()
}

# Undo last change
do_undo() {
    if [[ ${#UNDO_STACK[@]} -gt 0 ]]; then
        local current="${(j:\n:)TEXT_BUFFER}|$CURSOR_LINE|$CURSOR_COL"
        REDO_STACK+=("$current")

        local state="${UNDO_STACK[-1]}"
        unset "UNDO_STACK[-1]"

        local parts=(${(@s:|:)state})
        TEXT_BUFFER=(${(@f)parts[1]})
        CURSOR_LINE=${parts[2]:-1}
        CURSOR_COL=${parts[3]:-0}

        set_status "Undo" $COLORS[G_GREEN]
        APP_STATE[NEEDS_REDRAW]=1
    fi
}

# Redo last undo
do_redo() {
    if [[ ${#REDO_STACK[@]} -gt 0 ]]; then
        local current="${(j:\n:)TEXT_BUFFER}|$CURSOR_LINE|$CURSOR_COL"
        UNDO_STACK+=("$current")

        local state="${REDO_STACK[-1]}"
        unset "REDO_STACK[-1]"

        local parts=(${(@s:|:)state})
        TEXT_BUFFER=(${(@f)parts[1]})
        CURSOR_LINE=${parts[2]:-1}
        CURSOR_COL=${parts[3]:-0}

        set_status "Redo" $COLORS[G_GREEN]
        APP_STATE[NEEDS_REDRAW]=1
    fi
}

# Clamp cursor to valid position
clamp_cursor() {
    [[ $CURSOR_LINE -lt 1 ]] && CURSOR_LINE=1
    [[ $CURSOR_LINE -gt ${#TEXT_BUFFER[@]} ]] && CURSOR_LINE=${#TEXT_BUFFER[@]}

    local line_len=${#TEXT_BUFFER[$CURSOR_LINE]}
    [[ $CURSOR_COL -lt 0 ]] && CURSOR_COL=0
    [[ $CURSOR_COL -gt $line_len ]] && CURSOR_COL=$line_len

    if [[ "${APP_STATE[VIM_MODE]}" == "NORMAL" ]] && [[ $CURSOR_COL -ge $line_len ]] && [[ $line_len -gt 0 ]]; then
        CURSOR_COL=$((line_len - 1))
    fi
}

# Handle NORMAL mode
handle_normal_mode() {
    local key=$1

    case "$key" in
        # Movement
        h) ((CURSOR_COL--)); clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;
        l) ((CURSOR_COL++)); clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;
        j) ((CURSOR_LINE++)); clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;
        k) ((CURSOR_LINE--)); clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;

        0|'^') CURSOR_COL=0; clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;
        '$') CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}; clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;

        # Mode changes
        i) APP_STATE[VIM_MODE]=INSERT; APP_STATE[NEEDS_REDRAW]=1 ;;
        a) ((CURSOR_COL++)); APP_STATE[VIM_MODE]=INSERT; clamp_cursor; APP_STATE[NEEDS_REDRAW]=1 ;;
        I) CURSOR_COL=0; APP_STATE[VIM_MODE]=INSERT; APP_STATE[NEEDS_REDRAW]=1 ;;
        A) CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}; APP_STATE[VIM_MODE]=INSERT; APP_STATE[NEEDS_REDRAW]=1 ;;

        o)
            save_undo
            ((CURSOR_LINE++))
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
            CURSOR_COL=0
            APP_STATE[VIM_MODE]=INSERT
            APP_STATE[NEEDS_REDRAW]=1
            ;;

        O)
            save_undo
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$((CURSOR_LINE-1))}" "" "${TEXT_BUFFER[@]:$((CURSOR_LINE-1))}")
            CURSOR_COL=0
            APP_STATE[VIM_MODE]=INSERT
            APP_STATE[NEEDS_REDRAW]=1
            ;;

        v)
            APP_STATE[VIM_MODE]=VISUAL
            VISUAL_START_LINE=$CURSOR_LINE
            VISUAL_START_COL=$CURSOR_COL
            APP_STATE[NEEDS_REDRAW]=1
            ;;

        # Editing
        d)
            read -k 1 -t 0.5 key2
            if [[ "$key2" == "d" ]]; then
                save_undo
                YANK_BUFFER=("${TEXT_BUFFER[$CURSOR_LINE]}")
                if [[ ${#TEXT_BUFFER[@]} -eq 1 ]]; then
                    TEXT_BUFFER=("")
                else
                    TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$((CURSOR_LINE-1))}" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
                fi
                clamp_cursor
                set_status "Deleted 1 line" $COLORS[R_RED]
                APP_STATE[NEEDS_REDRAW]=1
            fi
            ;;

        y)
            read -k 1 -t 0.5 key2
            if [[ "$key2" == "y" ]]; then
                YANK_BUFFER=("${TEXT_BUFFER[$CURSOR_LINE]}")
                set_status "Yanked 1 line" $COLORS[G_GREEN]
                APP_STATE[NEEDS_REDRAW]=1
            fi
            ;;

        p)
            if [[ ${#YANK_BUFFER[@]} -gt 0 ]]; then
                save_undo
                ((CURSOR_LINE++))
                TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "${YANK_BUFFER[@]}" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
                set_status "Pasted ${#YANK_BUFFER[@]} line(s)" $COLORS[G_GREEN]
                APP_STATE[NEEDS_REDRAW]=1
            fi
            ;;

        u) do_undo ;;

        # Command mode
        :) APP_STATE[VIM_MODE]=COMMAND; APP_STATE[NEEDS_REDRAW]=1 ;;

        # Quit
        q) APP_STATE[RUNNING]=0 ;;
    esac
}

# Handle INSERT mode
handle_insert_mode() {
    local key=$1

    case "$key" in
        $'\e'|$'\x03')
            APP_STATE[VIM_MODE]=NORMAL
            [[ $CURSOR_COL -gt 0 ]] && ((CURSOR_COL--))
            clamp_cursor
            APP_STATE[NEEDS_REDRAW]=1
            ;;

        $'\x7f'|$'\b')
            if [[ $CURSOR_COL -gt 0 ]]; then
                save_undo
                local line="${TEXT_BUFFER[$CURSOR_LINE]}"
                TEXT_BUFFER[$CURSOR_LINE]="${line:0:$((CURSOR_COL-1))}${line:$CURSOR_COL}"
                ((CURSOR_COL--))
                APP_STATE[NEEDS_REDRAW]=1
            elif [[ $CURSOR_LINE -gt 1 ]]; then
                save_undo
                local current_line="${TEXT_BUFFER[$CURSOR_LINE]}"
                ((CURSOR_LINE--))
                CURSOR_COL=${#TEXT_BUFFER[$CURSOR_LINE]}
                TEXT_BUFFER[$CURSOR_LINE]+="$current_line"
                TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "${TEXT_BUFFER[@]:$((CURSOR_LINE+1))}")
                APP_STATE[NEEDS_REDRAW]=1
            fi
            ;;

        $'\n')
            save_undo
            local line="${TEXT_BUFFER[$CURSOR_LINE]}"
            local before="${line:0:$CURSOR_COL}"
            local after="${line:$CURSOR_COL}"
            TEXT_BUFFER[$CURSOR_LINE]="$before"
            ((CURSOR_LINE++))
            TEXT_BUFFER=("${TEXT_BUFFER[@]:0:$CURSOR_LINE}" "$after" "${TEXT_BUFFER[@]:$CURSOR_LINE}")
            CURSOR_COL=0
            APP_STATE[NEEDS_REDRAW]=1
            ;;

        *)
            if [[ -n "$key" ]] && [[ "$key" =~ [[:print:]] ]]; then
                save_undo
                local line="${TEXT_BUFFER[$CURSOR_LINE]}"
                TEXT_BUFFER[$CURSOR_LINE]="${line:0:$CURSOR_COL}${key}${line:$CURSOR_COL}"
                ((CURSOR_COL++))
                APP_STATE[NEEDS_REDRAW]=1
            fi
            ;;
    esac
}

# ============================================================================
# INPUT HANDLING
# ============================================================================

# Read key with escape sequence handling
read_key() {
    local key=""
    read -k 1 -s key

    if [[ "$key" == $'\e' ]]; then
        read -k 2 -s -t 0.01 key_seq
        if [[ -n "$key_seq" ]]; then
            key="${key}${key_seq}"

            if [[ "$key" == $'\e[' ]]; then
                read -k 1 -s -t 0.01 extra
                key="${key}${extra}"

                if [[ "$extra" =~ [0-9] ]]; then
                    read -k 1 -s -t 0.01 final
                    key="${key}${final}"
                fi
            fi
        fi
    fi

    echo -n "$key"
}

# Main input handler
handle_input() {
    local key=$(read_key)

    # Global shortcuts (work in all modes)
    case "$key" in
        $'\t')  # Tab - cycle focus
            APP_STATE[FOCUS_PANEL]=$(( (${APP_STATE[FOCUS_PANEL]} + 1) % 3 ))
            APP_STATE[NEEDS_REDRAW]=1
            return
            ;;

        $'\e[A')  # Up arrow in pattern panel
            if [[ ${APP_STATE[FOCUS_PANEL]} -eq 2 ]]; then
                APP_STATE[CURRENT_PATTERN]=$(( (${APP_STATE[CURRENT_PATTERN]} - 1 + ${#PATTERN_NAMES[@]}) % ${#PATTERN_NAMES[@]} ))
                APP_STATE[NEEDS_REDRAW]=1
                return
            fi
            ;;

        $'\e[B')  # Down arrow in pattern panel
            if [[ ${APP_STATE[FOCUS_PANEL]} -eq 2 ]]; then
                APP_STATE[CURRENT_PATTERN]=$(( (${APP_STATE[CURRENT_PATTERN]} + 1) % ${#PATTERN_NAMES[@]} ))
                APP_STATE[NEEDS_REDRAW]=1
                return
            fi
            ;;

        $'\x12')  # Ctrl-R - redo
            do_redo
            return
            ;;
    esac

    # Mode-specific handling
    case "${APP_STATE[VIM_MODE]}" in
        NORMAL) handle_normal_mode "$key" ;;
        INSERT) handle_insert_mode "$key" ;;
        # VISUAL and COMMAND modes would go here
    esac
}

# ============================================================================
# RENDERING ENGINE
# ============================================================================

# Main render function
render_frame() {
    # Performance: skip if nothing changed
    local current_hash=$(hash_text "${(j:\n:)TEXT_BUFFER}")
    if [[ "$current_hash" == "$LAST_RENDERED_HASH" ]] && [[ ${APP_STATE[NEEDS_REDRAW]} -eq 0 ]]; then
        return
    fi

    LAST_RENDERED_HASH="$current_hash"

    hide_cursor

    draw_header
    draw_input_panel
    draw_preview_panel
    draw_pattern_panel
    draw_status_bar

    show_cursor

    APP_STATE[NEEDS_REDRAW]=0
}

# ============================================================================
# MAIN LOOP
# ============================================================================

# Handle window resize
handle_resize() {
    detect_terminal
    APP_STATE[NEEDS_REDRAW]=1
}

# Initialize TUI
init_tui() {
    detect_terminal

    # Check minimum size - adjusted for smaller terminals
    if [[ ${TERM_INFO[WIDTH]} -lt 60 ]] || [[ ${TERM_INFO[HEIGHT]} -lt 20 ]]; then
        echo "Terminal too small. Minimum: 60x20"
        echo "Current: ${TERM_INFO[WIDTH]}x${TERM_INFO[HEIGHT]}"
        exit 1
    fi

    # Enable alternate screen
    echo -n "${TERM_ESC[ALT_SCREEN_ON]}"

    # Enable mouse
    if [[ ${APP_STATE[MOUSE_ENABLED]} -eq 1 ]]; then
        echo -n "${TERM_ESC[MOUSE_ON]}"
    fi

    clear_screen
    hide_cursor

    # Setup resize handler
    trap 'handle_resize' WINCH

    APP_STATE[RUNNING]=1
}

# Cleanup TUI
cleanup_tui() {
    show_cursor

    if [[ ${APP_STATE[MOUSE_ENABLED]} -eq 1 ]]; then
        echo -n "${TERM_ESC[MOUSE_OFF]}"
    fi

    echo -n "${TERM_ESC[ALT_SCREEN_OFF]}"
    reset_color
    clear
}

# Main event loop
main_loop() {
    while [[ ${APP_STATE[RUNNING]} -eq 1 ]]; do
        render_frame

        # Read input with timeout
        if read -t 0.1 -k 1; then
            handle_input
        fi

        # Periodic updates (clock, etc.)
        local current_time=$(date +%s)
        if [[ $((current_time - ${APP_STATE[LAST_UPDATE_TIME]})) -ge 1 ]]; then
            APP_STATE[LAST_UPDATE_TIME]=$current_time
            APP_STATE[NEEDS_REDRAW]=1
        fi
    done
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main() {
    # Setup cleanup on exit
    trap cleanup_tui EXIT INT TERM

    # Initialize
    init_tui

    # Initial render
    APP_STATE[NEEDS_REDRAW]=1

    # Enter main loop
    main_loop

    # Cleanup
    cleanup_tui

    # Show final output
    local all_text="${(j:\n:)TEXT_BUFFER}"
    if [[ -n "$all_text" ]]; then
        echo "\nGenerated Marvel Rivals format:"
        echo "$(convert_text "$all_text")"
    fi
}

# Run if executed directly
if [[ "${(%):-%N}" == "${0}" ]] || [[ "${0}" == "rivals-pro.zsh" ]]; then
    main "$@"
fi
