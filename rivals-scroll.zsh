#!/usr/bin/env zsh

# Marvel Rivals Message Converter - Advanced Scrolling & Navigation
# Smooth scrolling with momentum, elastic bounce, and advanced navigation features

# Enable extended glob and command substitution
setopt extended_glob
setopt prompt_subst

# Terminal control codes
typeset -A TERM_CODES
TERM_CODES=(
    [clear_screen]=$'\e[2J'
    [clear_line]=$'\e[2K'
    [cursor_home]=$'\e[H'
    [cursor_hide]=$'\e[?25l'
    [cursor_show]=$'\e[?25h'
    [alt_buffer]=$'\e[?1049h'
    [main_buffer]=$'\e[?1049l'
    [save_cursor]=$'\e7'
    [restore_cursor]=$'\e8'
    [bold]=$'\e[1m'
    [dim]=$'\e[2m'
    [reset]=$'\e[0m'
    [reverse]=$'\e[7m'
)

# Color codes for UI
typeset -A COLORS
COLORS=(
    [yellow]=$'\e[33m'
    [cyan]=$'\e[36m'
    [green]=$'\e[32m'
    [red]=$'\e[31m'
    [magenta]=$'\e[35m'
    [blue]=$'\e[34m'
    [white]=$'\e[37m'
    [gray]=$'\e[90m'
    [reset]=$'\e[0m'
)

# Global state
typeset -g VIEWPORT_TOP=0
typeset -g VIEWPORT_HEIGHT=0
typeset -g VIEWPORT_WIDTH=0
typeset -g CURSOR_LINE=0
typeset -g TOTAL_LINES=0
typeset -g SMOOTH_SCROLL_ENABLED=1
typeset -g LINE_NUMBERS_MODE="absolute"  # absolute, relative, none
typeset -g FOCUS_MODE=0
typeset -g SHOW_MINIMAP=1
typeset -A BOOKMARKS
typeset -a JUMP_LIST
typeset -g JUMP_LIST_INDEX=-1
typeset -a TEXT_LINES
typeset -a RENDERED_CACHE
typeset -g SEARCH_PATTERN=""
typeset -a SEARCH_MATCHES
typeset -g CURRENT_MATCH=0
typeset -g VELOCITY=0
typeset -g MOMENTUM_ACTIVE=0

# Physics constants for smooth scrolling
typeset -g -F FRICTION=0.85
typeset -g -F BOUNCE_FACTOR=0.3
typeset -g -F SCROLL_ACCELERATION=2.0
typeset -g -F EASING_DURATION=0.3
typeset -g -F FRAME_DELAY=0.016  # ~60 FPS

# Initialize terminal
function init_terminal() {
    # Get terminal size
    VIEWPORT_HEIGHT=$(tput lines)
    VIEWPORT_WIDTH=$(tput cols)

    # Reserve lines for status bar and command line
    ((VIEWPORT_HEIGHT -= 3))

    # Enter alternate buffer and hide cursor
    print -n "${TERM_CODES[alt_buffer]}${TERM_CODES[cursor_hide]}${TERM_CODES[clear_screen]}"

    # Setup trap for cleanup
    trap cleanup EXIT INT TERM
}

# Cleanup on exit
function cleanup() {
    print -n "${TERM_CODES[cursor_show]}${TERM_CODES[main_buffer]}"
    stty echo
}

# Load text content
function load_text() {
    local file=$1

    if [[ -f "$file" ]]; then
        TEXT_LINES=("${(@f)$(<$file)}")
    else
        TEXT_LINES=(
            "Marvel Rivals Message Converter - Smooth Scroll Demo"
            ""
            "Navigation Keys:"
            "  Up/Down Arrow - Scroll line by line"
            "  Page Up/Down  - Scroll page by page"
            "  Home/End      - Jump to top/bottom"
            "  Ctrl+F        - Find text"
            "  Ctrl+G        - Go to line"
            "  Ctrl+B        - Toggle bookmark"
            "  Ctrl+O/I      - Navigate jump list"
            "  Ctrl+L        - Toggle line numbers"
            "  Ctrl+M        - Toggle minimap"
            "  F            - Toggle focus mode"
            "  S            - Toggle smooth scroll"
            "  Q            - Quit"
            ""
            "Features:"
            "  - Momentum scrolling with deceleration"
            "  - Elastic bounce at boundaries"
            "  - Virtual rendering for performance"
            "  - Smooth animations with easing"
            "  - Search highlighting"
            "  - Line numbers (absolute/relative)"
            ""
        )

        # Add some sample content
        for i in {1..100}; do
            TEXT_LINES+=("Sample line $i - This demonstrates smooth scrolling in terminal")
        done
    fi

    TOTAL_LINES=${#TEXT_LINES}
}

# Easing function (ease-out cubic)
function ease_out_cubic() {
    local -F t=$1
    local -F result
    result=$(( 1 - (1 - t) ** 3 ))
    print $result
}

# Smooth scroll to target line
function smooth_scroll_to() {
    local target=$1
    local duration=${2:-$EASING_DURATION}

    # Clamp target
    local max_scroll=$(( TOTAL_LINES - VIEWPORT_HEIGHT ))
    [[ $max_scroll -lt 0 ]] && max_scroll=0
    [[ $target -lt 0 ]] && target=0
    [[ $target -gt $max_scroll ]] && target=$max_scroll

    if [[ $SMOOTH_SCROLL_ENABLED -eq 1 ]]; then
        local start=$VIEWPORT_TOP
        local distance=$(( target - start ))

        if [[ $distance -ne 0 ]]; then
            local steps=$(( int(duration / FRAME_DELAY) ))
            [[ $steps -lt 1 ]] && steps=1

            for ((i=1; i<=steps; i++)); do
                local -F progress=$(( i / (steps * 1.0) ))
                local -F eased=$(ease_out_cubic $progress)
                local new_pos=$(( start + int(distance * eased) ))

                VIEWPORT_TOP=$new_pos
                render_viewport
                sleep $FRAME_DELAY
            done
        fi
    fi

    VIEWPORT_TOP=$target
    render_viewport
}

# Apply momentum physics
function apply_momentum() {
    if [[ $MOMENTUM_ACTIVE -eq 1 ]] && [[ $VELOCITY -ne 0 ]]; then
        # Apply velocity
        VIEWPORT_TOP=$(( VIEWPORT_TOP + VELOCITY ))

        # Check boundaries with elastic bounce
        local max_scroll=$(( TOTAL_LINES - VIEWPORT_HEIGHT ))
        [[ $max_scroll -lt 0 ]] && max_scroll=0

        if [[ $VIEWPORT_TOP -lt 0 ]]; then
            VIEWPORT_TOP=0
            VELOCITY=$(( -int(VELOCITY * BOUNCE_FACTOR) ))
            if [[ $VELOCITY -eq 0 ]]; then
                MOMENTUM_ACTIVE=0
            fi
        elif [[ $VIEWPORT_TOP -gt $max_scroll ]]; then
            VIEWPORT_TOP=$max_scroll
            VELOCITY=$(( -int(VELOCITY * BOUNCE_FACTOR) ))
            if [[ $VELOCITY -eq 0 ]]; then
                MOMENTUM_ACTIVE=0
            fi
        else
            # Apply friction
            VELOCITY=$(( int(VELOCITY * FRICTION) ))
            if [[ $VELOCITY -eq 0 ]] || [[ ${VELOCITY#-} -lt 1 ]]; then
                VELOCITY=0
                MOMENTUM_ACTIVE=0
            fi
        fi

        render_viewport
    fi
}

# Start momentum scrolling
function start_momentum() {
    local initial_velocity=$1
    VELOCITY=$initial_velocity
    MOMENTUM_ACTIVE=1

    while [[ $MOMENTUM_ACTIVE -eq 1 ]]; do
        apply_momentum
        sleep $FRAME_DELAY
    done
}

# Render line number
function render_line_number() {
    local line_idx=$1
    local current=$2

    case $LINE_NUMBERS_MODE in
        absolute)
            if [[ $current -eq 1 ]]; then
                print -n "${COLORS[yellow]}${TERM_CODES[bold]}"
            else
                print -n "${COLORS[gray]}"
            fi
            printf "%4d " $(( line_idx + 1 ))
            print -n "${COLORS[reset]}"
            ;;
        relative)
            local rel_num=$(( line_idx - CURSOR_LINE ))
            if [[ $current -eq 1 ]]; then
                print -n "${COLORS[yellow]}${TERM_CODES[bold]}"
                printf "%4d " $(( line_idx + 1 ))
            else
                print -n "${COLORS[gray]}"
                printf "%4d " ${rel_num#-}
            fi
            print -n "${COLORS[reset]}"
            ;;
        none)
            ;;
    esac
}

# Render minimap
function render_minimap() {
    if [[ $SHOW_MINIMAP -eq 0 ]]; then
        return
    fi

    local map_height=$(( VIEWPORT_HEIGHT / 2 ))
    [[ $map_height -lt 10 ]] && map_height=10
    [[ $map_height -gt 20 ]] && map_height=20

    local map_width=5
    local map_left=$(( VIEWPORT_WIDTH - map_width - 2 ))

    # Calculate minimap positions
    local viewport_ratio=$(( VIEWPORT_HEIGHT * 100 / TOTAL_LINES ))
    local viewport_start=$(( VIEWPORT_TOP * map_height / TOTAL_LINES ))
    local viewport_size=$(( viewport_ratio * map_height / 100 ))
    [[ $viewport_size -lt 1 ]] && viewport_size=1

    # Draw minimap frame
    for ((i=0; i<map_height; i++)); do
        print -n "\e[$(( i + 2 ));${map_left}H"
        print -n "${COLORS[gray]}│"

        if [[ $i -ge $viewport_start ]] && [[ $i -lt $(( viewport_start + viewport_size )) ]]; then
            print -n "${COLORS[cyan]}${TERM_CODES[reverse]}"
            for ((j=0; j<map_width-1; j++)); do
                print -n "█"
            done
            print -n "${TERM_CODES[reset]}"
        else
            # Show bookmarks and search matches on minimap
            local map_line=$(( i * TOTAL_LINES / map_height ))
            local marker=" "

            for bookmark_line in ${(k)BOOKMARKS}; do
                if [[ $map_line -eq $bookmark_line ]]; then
                    marker="${COLORS[yellow]}▸${COLORS[reset]}"
                    break
                fi
            done

            print -n "$marker"
        fi
    done
}

# Highlight search matches in line
function highlight_search() {
    local line=$1

    if [[ -z $SEARCH_PATTERN ]]; then
        print -n "$line"
        return
    fi

    local output=""
    local remaining=$line

    while [[ -n $remaining ]]; do
        if [[ $remaining =~ (.*)($SEARCH_PATTERN)(.*) ]]; then
            output+="$match[1]${COLORS[yellow]}${TERM_CODES[reverse]}$match[2]${TERM_CODES[reset]}"
            remaining=$match[3]
        else
            output+="$remaining"
            break
        fi
    done

    print -n "$output"
}

# Render viewport
function render_viewport() {
    local visible_start=$VIEWPORT_TOP
    local visible_end=$(( VIEWPORT_TOP + VIEWPORT_HEIGHT ))

    # Clamp visible range
    [[ $visible_start -lt 0 ]] && visible_start=0
    [[ $visible_end -gt $TOTAL_LINES ]] && visible_end=$TOTAL_LINES

    # Clear screen and reset cursor
    print -n "${TERM_CODES[cursor_home]}"

    # Render visible lines
    local screen_line=0
    for ((line_idx=visible_start; line_idx<visible_end; line_idx++)); do
        ((screen_line++))
        print -n "\e[${screen_line};1H${TERM_CODES[clear_line]}"

        local is_current=0
        [[ $line_idx -eq $CURSOR_LINE ]] && is_current=1

        # Show bookmark indicator
        if [[ -n ${BOOKMARKS[$line_idx]} ]]; then
            print -n "${COLORS[yellow]}▸ ${COLORS[reset]}"
        else
            print -n "  "
        fi

        # Line number
        render_line_number $line_idx $is_current

        # Line content
        local line=${TEXT_LINES[$((line_idx + 1))]}

        if [[ $FOCUS_MODE -eq 1 ]] && [[ $is_current -eq 0 ]]; then
            print -n "${TERM_CODES[dim]}"
        fi

        if [[ $is_current -eq 1 ]]; then
            print -n "${COLORS[cyan]}${TERM_CODES[reverse]}"
        fi

        highlight_search "$line"

        print -n "${TERM_CODES[reset]}"
    done

    # Clear remaining lines
    for ((; screen_line<VIEWPORT_HEIGHT; screen_line++)); do
        ((screen_line++))
        print -n "\e[${screen_line};1H${TERM_CODES[clear_line]}"
        print -n "${COLORS[blue]}~${COLORS[reset]}"
    done

    # Render minimap
    render_minimap

    # Render status bar
    render_status_bar

    # Render command line
    render_command_line
}

# Render status bar
function render_status_bar() {
    local status_line=$(( VIEWPORT_HEIGHT + 1 ))
    print -n "\e[${status_line};1H${TERM_CODES[clear_line]}"
    print -n "${COLORS[white]}${TERM_CODES[reverse]}"

    # Left side
    local mode_indicators=""
    [[ $SMOOTH_SCROLL_ENABLED -eq 1 ]] && mode_indicators+="[SMOOTH] "
    [[ $FOCUS_MODE -eq 1 ]] && mode_indicators+="[FOCUS] "
    [[ -n $SEARCH_PATTERN ]] && mode_indicators+="[SEARCH: $SEARCH_PATTERN] "

    print -n " $mode_indicators"

    # Right side - position info
    local pos_info="Line $((CURSOR_LINE + 1))/$TOTAL_LINES "
    local percent=$(( (VIEWPORT_TOP + VIEWPORT_HEIGHT/2) * 100 / TOTAL_LINES ))
    [[ $percent -gt 100 ]] && percent=100
    pos_info+="($percent%) "

    local padding=$(( VIEWPORT_WIDTH - ${#mode_indicators} - ${#pos_info} - 2 ))
    printf "%${padding}s" ""
    print -n "$pos_info"

    print -n "${TERM_CODES[reset]}"
}

# Render command line
function render_command_line() {
    local cmd_line=$(( VIEWPORT_HEIGHT + 2 ))
    print -n "\e[${cmd_line};1H${TERM_CODES[clear_line]}"
    print -n "${COLORS[cyan]}Press 'h' for help, 'q' to quit${COLORS[reset]}"
}

# Add to jump list
function add_to_jump_list() {
    local line=$1

    # Remove duplicates and add new position
    JUMP_LIST=("${(@)JUMP_LIST:#$line}")
    JUMP_LIST+=($line)
    JUMP_LIST_INDEX=${#JUMP_LIST}
}

# Navigate jump list
function jump_back() {
    if [[ ${#JUMP_LIST} -gt 0 ]] && [[ $JUMP_LIST_INDEX -gt 1 ]]; then
        ((JUMP_LIST_INDEX--))
        local target=${JUMP_LIST[$JUMP_LIST_INDEX]}
        CURSOR_LINE=$target
        smooth_scroll_to $(( target - VIEWPORT_HEIGHT/2 ))
    fi
}

function jump_forward() {
    if [[ $JUMP_LIST_INDEX -lt ${#JUMP_LIST} ]]; then
        ((JUMP_LIST_INDEX++))
        local target=${JUMP_LIST[$JUMP_LIST_INDEX]}
        CURSOR_LINE=$target
        smooth_scroll_to $(( target - VIEWPORT_HEIGHT/2 ))
    fi
}

# Search functionality
function search_text() {
    print -n "\e[$(( VIEWPORT_HEIGHT + 2 ));1H${TERM_CODES[clear_line]}"
    print -n "${COLORS[yellow]}Search: ${COLORS[reset]}"
    print -n "${TERM_CODES[cursor_show]}"

    read -r SEARCH_PATTERN
    print -n "${TERM_CODES[cursor_hide]}"

    if [[ -n $SEARCH_PATTERN ]]; then
        # Find all matches
        SEARCH_MATCHES=()
        for ((i=0; i<TOTAL_LINES; i++)); do
            if [[ ${TEXT_LINES[$((i+1))]} =~ $SEARCH_PATTERN ]]; then
                SEARCH_MATCHES+=($i)
            fi
        done

        if [[ ${#SEARCH_MATCHES} -gt 0 ]]; then
            CURRENT_MATCH=0
            local target=${SEARCH_MATCHES[$((CURRENT_MATCH+1))]}
            add_to_jump_list $CURSOR_LINE
            CURSOR_LINE=$target
            smooth_scroll_to $(( target - VIEWPORT_HEIGHT/2 ))
        fi
    fi
}

# Go to next search match
function next_search_match() {
    if [[ ${#SEARCH_MATCHES} -gt 0 ]]; then
        ((CURRENT_MATCH++))
        [[ $CURRENT_MATCH -ge ${#SEARCH_MATCHES} ]] && CURRENT_MATCH=0

        local target=${SEARCH_MATCHES[$((CURRENT_MATCH+1))]}
        CURSOR_LINE=$target
        smooth_scroll_to $(( target - VIEWPORT_HEIGHT/2 ))
    fi
}

# Go to line
function goto_line() {
    print -n "\e[$(( VIEWPORT_HEIGHT + 2 ));1H${TERM_CODES[clear_line]}"
    print -n "${COLORS[yellow]}Go to line: ${COLORS[reset]}"
    print -n "${TERM_CODES[cursor_show]}"

    local line_num
    read -r line_num
    print -n "${TERM_CODES[cursor_hide]}"

    if [[ $line_num =~ ^[0-9]+$ ]]; then
        ((line_num--))
        [[ $line_num -lt 0 ]] && line_num=0
        [[ $line_num -ge $TOTAL_LINES ]] && line_num=$((TOTAL_LINES - 1))

        add_to_jump_list $CURSOR_LINE
        CURSOR_LINE=$line_num
        smooth_scroll_to $(( line_num - VIEWPORT_HEIGHT/2 ))
    fi
}

# Toggle bookmark
function toggle_bookmark() {
    if [[ -n ${BOOKMARKS[$CURSOR_LINE]} ]]; then
        unset "BOOKMARKS[$CURSOR_LINE]"
    else
        BOOKMARKS[$CURSOR_LINE]=1
    fi
    render_viewport
}

# Show help
function show_help() {
    print -n "${TERM_CODES[clear_screen]}${TERM_CODES[cursor_home]}"

    cat << 'EOF'
Marvel Rivals Smooth Scroll - Keyboard Reference

SCROLLING:
  ↑/k         Scroll up one line
  ↓/j         Scroll down one line
  PgUp/Ctrl+U Page up (smooth animation)
  PgDn/Ctrl+D Page down (smooth animation)
  Home/g      Jump to top (smooth)
  End/G       Jump to bottom (smooth)
  Ctrl+Y      Scroll up (momentum)
  Ctrl+E      Scroll down (momentum)

NAVIGATION:
  Ctrl+F      Find/search text
  n           Next search match
  N           Previous search match
  Ctrl+G      Go to line number
  Ctrl+O      Jump back (jump list)
  Ctrl+I      Jump forward (jump list)
  Ctrl+B      Toggle bookmark on current line

VIEW OPTIONS:
  Ctrl+L      Cycle line numbers (absolute/relative/none)
  Ctrl+M      Toggle minimap
  f           Toggle focus mode
  s           Toggle smooth scrolling
  +           Increase viewport
  -           Decrease viewport

GENERAL:
  h/?         Show this help
  q           Quit

Press any key to continue...
EOF

    read -k 1
    render_viewport
}

# Handle keyboard input
function handle_input() {
    local key

    while true; do
        # Read single key
        read -sk 1 key

        case $key in
            q)  # Quit
                return 0
                ;;
            h|\?)  # Help
                show_help
                ;;
            j)  # Down one line
                ((CURSOR_LINE++))
                [[ $CURSOR_LINE -ge $TOTAL_LINES ]] && CURSOR_LINE=$((TOTAL_LINES - 1))
                if [[ $CURSOR_LINE -ge $(( VIEWPORT_TOP + VIEWPORT_HEIGHT )) ]]; then
                    smooth_scroll_to $(( VIEWPORT_TOP + 1 )) 0.1
                else
                    render_viewport
                fi
                ;;
            k)  # Up one line
                ((CURSOR_LINE--))
                [[ $CURSOR_LINE -lt 0 ]] && CURSOR_LINE=0
                if [[ $CURSOR_LINE -lt $VIEWPORT_TOP ]]; then
                    smooth_scroll_to $(( VIEWPORT_TOP - 1 )) 0.1
                else
                    render_viewport
                fi
                ;;
            g)  # Top
                add_to_jump_list $CURSOR_LINE
                CURSOR_LINE=0
                smooth_scroll_to 0
                ;;
            G)  # Bottom
                add_to_jump_list $CURSOR_LINE
                CURSOR_LINE=$((TOTAL_LINES - 1))
                smooth_scroll_to $(( TOTAL_LINES - VIEWPORT_HEIGHT ))
                ;;
            f)  # Toggle focus mode
                FOCUS_MODE=$((1 - FOCUS_MODE))
                render_viewport
                ;;
            s)  # Toggle smooth scroll
                SMOOTH_SCROLL_ENABLED=$((1 - SMOOTH_SCROLL_ENABLED))
                render_viewport
                ;;
            n)  # Next search
                next_search_match
                ;;
            $'\x1b')  # Escape sequence
                read -sk 2 -t 0.01 key
                case $key in
                    '[A')  # Up arrow
                        ((CURSOR_LINE--))
                        [[ $CURSOR_LINE -lt 0 ]] && CURSOR_LINE=0
                        if [[ $CURSOR_LINE -lt $VIEWPORT_TOP ]]; then
                            smooth_scroll_to $(( VIEWPORT_TOP - 1 )) 0.1
                        else
                            render_viewport
                        fi
                        ;;
                    '[B')  # Down arrow
                        ((CURSOR_LINE++))
                        [[ $CURSOR_LINE -ge $TOTAL_LINES ]] && CURSOR_LINE=$((TOTAL_LINES - 1))
                        if [[ $CURSOR_LINE -ge $(( VIEWPORT_TOP + VIEWPORT_HEIGHT )) ]]; then
                            smooth_scroll_to $(( VIEWPORT_TOP + 1 )) 0.1
                        else
                            render_viewport
                        fi
                        ;;
                    '[5')  # Page Up
                        read -sk 1 -t 0.01  # consume ~
                        add_to_jump_list $CURSOR_LINE
                        local target=$(( VIEWPORT_TOP - VIEWPORT_HEIGHT + 3 ))
                        CURSOR_LINE=$(( CURSOR_LINE - VIEWPORT_HEIGHT + 3 ))
                        [[ $CURSOR_LINE -lt 0 ]] && CURSOR_LINE=0
                        smooth_scroll_to $target
                        ;;
                    '[6')  # Page Down
                        read -sk 1 -t 0.01  # consume ~
                        add_to_jump_list $CURSOR_LINE
                        local target=$(( VIEWPORT_TOP + VIEWPORT_HEIGHT - 3 ))
                        CURSOR_LINE=$(( CURSOR_LINE + VIEWPORT_HEIGHT - 3 ))
                        [[ $CURSOR_LINE -ge $TOTAL_LINES ]] && CURSOR_LINE=$((TOTAL_LINES - 1))
                        smooth_scroll_to $target
                        ;;
                    '[H')  # Home
                        add_to_jump_list $CURSOR_LINE
                        CURSOR_LINE=0
                        smooth_scroll_to 0
                        ;;
                    '[F')  # End
                        add_to_jump_list $CURSOR_LINE
                        CURSOR_LINE=$((TOTAL_LINES - 1))
                        smooth_scroll_to $(( TOTAL_LINES - VIEWPORT_HEIGHT ))
                        ;;
                esac
                ;;
            $'\x06')  # Ctrl+F - Search
                search_text
                ;;
            $'\x07')  # Ctrl+G - Go to line
                goto_line
                ;;
            $'\x02')  # Ctrl+B - Bookmark
                toggle_bookmark
                ;;
            $'\x0f')  # Ctrl+O - Jump back
                jump_back
                ;;
            $'\x09')  # Ctrl+I - Jump forward
                jump_forward
                ;;
            $'\x0c')  # Ctrl+L - Line numbers
                case $LINE_NUMBERS_MODE in
                    absolute) LINE_NUMBERS_MODE="relative" ;;
                    relative) LINE_NUMBERS_MODE="none" ;;
                    none) LINE_NUMBERS_MODE="absolute" ;;
                esac
                render_viewport
                ;;
            $'\x0d')  # Ctrl+M - Minimap (conflicts with Enter, using Ctrl+P instead)
                ;;
            $'\x10')  # Ctrl+P - Toggle minimap
                SHOW_MINIMAP=$((1 - SHOW_MINIMAP))
                render_viewport
                ;;
            $'\x15')  # Ctrl+U - Page up (half)
                local target=$(( VIEWPORT_TOP - VIEWPORT_HEIGHT / 2 ))
                CURSOR_LINE=$(( CURSOR_LINE - VIEWPORT_HEIGHT / 2 ))
                [[ $CURSOR_LINE -lt 0 ]] && CURSOR_LINE=0
                smooth_scroll_to $target
                ;;
            $'\x04')  # Ctrl+D - Page down (half)
                local target=$(( VIEWPORT_TOP + VIEWPORT_HEIGHT / 2 ))
                CURSOR_LINE=$(( CURSOR_LINE + VIEWPORT_HEIGHT / 2 ))
                [[ $CURSOR_LINE -ge $TOTAL_LINES ]] && CURSOR_LINE=$((TOTAL_LINES - 1))
                smooth_scroll_to $target
                ;;
            $'\x19')  # Ctrl+Y - Scroll up with momentum
                start_momentum -10 &
                ;;
            $'\x05')  # Ctrl+E - Scroll down with momentum
                start_momentum 10 &
                ;;
        esac
    done
}

# Main function
function main() {
    local file=${1:-}

    # Initialize
    init_terminal
    load_text "$file"

    # Initial render
    render_viewport

    # Handle input
    handle_input

    # Cleanup is handled by trap
}

# Run if executed directly
if [[ "${(%):-%N}" == "${0}" ]]; then
    main "$@"
fi
