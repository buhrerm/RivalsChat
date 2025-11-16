#!/usr/bin/env zsh

# Marvel Rivals Rainbow Converter - Live Preview System
# Ultra-fast real-time preview with visual color rendering

setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

# ============================================================================
# COLOR DEFINITIONS & ANSI CODES
# ============================================================================

# Marvel Rivals color codes to ANSI color mappings
typeset -A RIVALS_COLORS
RIVALS_COLORS=(
    Y "\033[38;2;255;215;0m"      # Gold
    O "\033[38;2;255;140;0m"      # Orange
    R "\033[38;2;220;20;60m"      # Red
    P "\033[38;2;255;105;180m"    # Pink
    M "\033[38;2;255;20;147m"     # Really Pink
    U "\033[38;2;138;43;226m"     # Purple
    B "\033[38;2;30;144;255m"     # Blue
    I "\033[38;2;25;25;112m"      # Dark Blue
    A "\033[38;2;0;206;209m"      # Teal
    T "\033[38;2;64;224;208m"     # Blue Green
    G "\033[38;2;50;205;50m"      # Green
    E "\033[38;2;173;255;47m"     # Green Yellow
    K "\033[38;2;255;255;0m"      # Yellow
)

# ANSI control codes
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CLEAR_SCREEN="\033[2J"
CLEAR_LINE="\033[2K"
SAVE_CURSOR="\033[s"
RESTORE_CURSOR="\033[u"
HIDE_CURSOR="\033[?25l"
SHOW_CURSOR="\033[?25h"

# ============================================================================
# PATTERN DEFINITIONS
# ============================================================================

typeset -A PATTERN_SEQUENCES
PATTERN_SEQUENCES=(
    "full"        "Y O R P M U B I A T G E K"
    "warm"        "Y O R P M"
    "cool"        "U B I A T G"
    "wave"        "Y O R P M U B I A T G E K E G T A I B U M P R O"
    "alternating" "Y R M B A G"
    "fire"        "Y O R P M R O Y"
    "ocean"       "B I A T B I"
    "forest"      "G E T G E"
    "sunset"      "O R P M U"
    "neon"        "M U B A M"
)

# ============================================================================
# GLOBAL STATE
# ============================================================================

typeset -g current_text=""
typeset -g current_pattern="full"
typeset -g preview_zoom=1.0
typeset -a history_stack
typeset -g history_index=0
typeset -g max_history=50
typeset -g show_help=0
typeset -g split_mode="vertical"
typeset -g animation_enabled=1
typeset -g update_counter=0

# Performance optimization
typeset -g last_rendered_text=""
typeset -g last_rendered_pattern=""
typeset -g cached_output=""

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Get terminal dimensions
get_terminal_size() {
    local size=($(stty size 2>/dev/null || echo "24 80"))
    TERM_ROWS=$size[1]
    TERM_COLS=$size[2]
}

# Move cursor to position
move_cursor() {
    printf "\033[%d;%dH" "$1" "$2"
}

# Draw horizontal line
draw_line() {
    local char="${1:-─}"
    local length="${2:-$TERM_COLS}"
    printf "%${length}s" | tr ' ' "$char"
}

# Center text
center_text() {
    local text="$1"
    local width="${2:-$TERM_COLS}"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s%s" "" "$text"
}

# Truncate text to width
truncate_text() {
    local text="$1"
    local width="$2"
    if (( ${#text} > width )); then
        echo "${text:0:$((width-3))}..."
    else
        echo "$text"
    fi
}

# ============================================================================
# CONVERSION FUNCTIONS
# ============================================================================

# Convert text to Rivals format
convert_to_rivals() {
    local text="$1"
    local pattern="$2"
    local output=""

    # Get pattern sequence
    local sequence=(${(s: :)PATTERN_SEQUENCES[$pattern]})
    local seq_len=${#sequence[@]}

    if (( seq_len == 0 )); then
        sequence=(${(s: :)PATTERN_SEQUENCES[full]})
        seq_len=${#sequence[@]}
    fi

    local color_index=1
    local char

    for (( i=1; i<=${#text}; i++ )); do
        char="${text:$((i-1)):1}"

        # Skip spaces in color rotation but include them in output
        if [[ "$char" == " " ]]; then
            output+=" "
        else
            local color="${sequence[$color_index]}"
            output+="#${color}${char}"
            color_index=$(( (color_index % seq_len) + 1 ))
        fi
    done

    echo "$output"
}

# Convert text with word-based coloring
convert_word_rainbow() {
    local text="$1"
    local pattern="${2:-full}"
    local output=""

    local sequence=(${(s: :)PATTERN_SEQUENCES[$pattern]})
    local seq_len=${#sequence[@]}
    local color_index=1

    # Split by spaces
    local words=(${(s: :)text})

    for word in $words; do
        if [[ -n "$word" ]]; then
            local color="${sequence[$color_index]}"
            output+="#${color}${word} "
            color_index=$(( (color_index % seq_len) + 1 ))
        fi
    done

    echo "${output% }"  # Remove trailing space
}

# Convert with gradient between two colors
convert_gradient() {
    local text="$1"
    local start_color="$2"
    local end_color="$3"

    # Simple gradient implementation (alternate between colors for now)
    local output=""
    local use_start=1

    for (( i=1; i<=${#text}; i++ )); do
        char="${text:$((i-1)):1}"

        if [[ "$char" == " " ]]; then
            output+=" "
        else
            if (( use_start )); then
                output+="#${start_color}${char}"
            else
                output+="#${end_color}${char}"
            fi
            use_start=$(( 1 - use_start ))
        fi
    done

    echo "$output"
}

# ============================================================================
# RENDERING FUNCTIONS
# ============================================================================

# Render visual preview with ANSI colors
render_visual_preview() {
    local text="$1"
    local pattern="$2"
    local output=""

    local sequence=(${(s: :)PATTERN_SEQUENCES[$pattern]})
    local seq_len=${#sequence[@]}
    local color_index=1

    for (( i=1; i<=${#text}; i++ )); do
        char="${text:$((i-1)):1}"

        if [[ "$char" == " " ]]; then
            output+=" "
        else
            local color_code="${sequence[$color_index]}"
            local ansi_color="${RIVALS_COLORS[$color_code]}"
            output+="${ansi_color}${char}${RESET}"
            color_index=$(( (color_index % seq_len) + 1 ))
        fi
    done

    echo "$output"
}

# Render color legend
render_color_legend() {
    local pattern="$1"
    local sequence=(${(s: :)PATTERN_SEQUENCES[$pattern]})

    echo -n "Colors: "
    for color_code in $sequence; do
        local ansi_color="${RIVALS_COLORS[$color_code]}"
        echo -n "${ansi_color}■${RESET} "
    done
    echo ""
}

# Render pattern comparison
render_pattern_comparison() {
    local text="$1"
    local max_width=$((TERM_COLS - 4))
    local display_text=$(truncate_text "$text" $max_width)

    local patterns=("full" "warm" "cool" "wave")
    local row=1

    for pattern in $patterns; do
        move_cursor $row 2
        printf "${BOLD}%-12s${RESET} " "$pattern:"

        local preview=$(render_visual_preview "$display_text" "$pattern")
        echo "$preview"

        ((row++))
    done
}

# ============================================================================
# MAIN PREVIEW DISPLAY
# ============================================================================

render_preview() {
    local text="$1"
    local pattern="$2"

    # Performance optimization - skip if nothing changed
    if [[ "$text" == "$last_rendered_text" && "$pattern" == "$last_rendered_pattern" ]]; then
        return
    fi

    last_rendered_text="$text"
    last_rendered_pattern="$pattern"

    # Clear screen and hide cursor
    echo -ne "$HIDE_CURSOR$CLEAR_SCREEN"

    get_terminal_size

    local row=1

    # ========== HEADER ==========
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}╔═══════════════════════════════════════════════════════════════════════╗${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}║${RESET}"
    move_cursor $row 3
    echo -ne "${BOLD}${RIVALS_COLORS[Y]}MARVEL RIVALS RAINBOW CONVERTER${RESET} ${RIVALS_COLORS[U]}[LIVE PREVIEW]${RESET}"
    move_cursor $row 72
    echo -ne "${BOLD}${RIVALS_COLORS[M]}║${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}╚═══════════════════════════════════════════════════════════════════════╝${RESET}"
    ((row++))

    ((row++))

    # ========== INPUT SECTION ==========
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[A]}┌─ ORIGINAL TEXT ─────────────────────────────────────────────────────┐${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[A]}│${RESET} "
    if [[ -n "$text" ]]; then
        local display_text=$(truncate_text "$text" 69)
        echo -ne "$display_text"
    else
        echo -ne "${DIM}(type your message...)${RESET}"
    fi
    move_cursor $row 72
    echo -ne "${RIVALS_COLORS[A]}│${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[A]}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    ((row++))

    ((row++))

    # ========== VISUAL PREVIEW ==========
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[G]}┌─ VISUAL PREVIEW ────────────────────────────────────────────────────┐${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[G]}│${RESET} "
    if [[ -n "$text" ]]; then
        local visual=$(render_visual_preview "$text" "$pattern")
        local display_visual=$(truncate_text "$visual" 69)
        echo -ne "$display_visual"
    else
        echo -ne "${DIM}(preview will appear here)${RESET}"
    fi
    move_cursor $row 72
    echo -ne "${RIVALS_COLORS[G]}│${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[G]}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    ((row++))

    ((row++))

    # ========== RIVALS CODE ==========
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[O]}┌─ RIVALS CODE (copy this) ───────────────────────────────────────────┐${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[O]}│${RESET} "
    if [[ -n "$text" ]]; then
        local rivals_code=$(convert_to_rivals "$text" "$pattern")
        cached_output="$rivals_code"
        local display_code=$(truncate_text "$rivals_code" 69)
        echo -ne "${RIVALS_COLORS[K]}$display_code${RESET}"
    else
        echo -ne "${DIM}(code will appear here)${RESET}"
    fi
    move_cursor $row 72
    echo -ne "${RIVALS_COLORS[O]}│${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[O]}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    ((row++))

    ((row++))

    # ========== STATS & INFO ==========
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[U]}┌─ INFO ──────────────────────────────────────────────────────────────┐${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[U]}│${RESET} "
    local char_count=${#text}
    local pattern_name="${pattern:u}"
    echo -ne "Pattern: ${BOLD}${RIVALS_COLORS[P]}$pattern_name${RESET}  │  Characters: ${BOLD}${RIVALS_COLORS[Y]}$char_count${RESET}  │  "
    render_color_legend "$pattern"
    move_cursor $row 72
    echo -ne "${RIVALS_COLORS[U]}│${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${RIVALS_COLORS[U]}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    ((row++))

    ((row++))

    # ========== PATTERN COMPARISON ==========
    if (( show_help == 0 )); then
        move_cursor $row 1
        echo -ne "${BOLD}${RIVALS_COLORS[B]}┌─ PATTERN COMPARISON ────────────────────────────────────────────────┐${RESET}"
        ((row++))

        local patterns=("full" "warm" "cool" "wave")
        for comp_pattern in $patterns; do
            move_cursor $row 1
            echo -ne "${RIVALS_COLORS[B]}│${RESET} "

            local is_current=""
            if [[ "$comp_pattern" == "$pattern" ]]; then
                is_current="${BOLD}${RIVALS_COLORS[Y]}▶ ${RESET}"
            else
                is_current="  "
            fi

            printf "${is_current}${BOLD}%-10s${RESET} " "$comp_pattern:"

            if [[ -n "$text" ]]; then
                local comp_preview=$(render_visual_preview "$text" "$comp_pattern")
                local display_comp=$(truncate_text "$comp_preview" 54)
                echo -ne "$display_comp"
            fi

            move_cursor $row 72
            echo -ne "${RIVALS_COLORS[B]}│${RESET}"
            ((row++))
        done

        move_cursor $row 1
        echo -ne "${RIVALS_COLORS[B]}└─────────────────────────────────────────────────────────────────────┘${RESET}"
        ((row++))
    fi

    ((row++))

    # ========== CONTROLS ==========
    move_cursor $row 1
    echo -ne "${DIM}Controls: ${RESET}"
    echo -ne "${RIVALS_COLORS[G]}[1-6]${RESET} Change Pattern  "
    echo -ne "${RIVALS_COLORS[Y]}[c]${RESET} Copy  "
    echo -ne "${RIVALS_COLORS[R]}[x]${RESET} Clear  "
    echo -ne "${RIVALS_COLORS[M]}[h]${RESET} Help  "
    echo -ne "${RIVALS_COLORS[A]}[q]${RESET} Quit"
    ((row++))

    # ========== INPUT PROMPT ==========
    ((row++))
    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}>${RESET} "
}

# ============================================================================
# HELP SCREEN
# ============================================================================

render_help() {
    echo -ne "$CLEAR_SCREEN"

    local row=1

    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}╔═══════════════════════════════════════════════════════════════════════╗${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}║${RESET}"
    center_text "${BOLD}${RIVALS_COLORS[Y]}HELP & KEYBOARD SHORTCUTS${RESET}"
    move_cursor $row 72
    echo -ne "${BOLD}${RIVALS_COLORS[M]}║${RESET}"
    ((row++))

    move_cursor $row 1
    echo -ne "${BOLD}${RIVALS_COLORS[M]}╚═══════════════════════════════════════════════════════════════════════╝${RESET}"
    ((row++))

    ((row++))

    local -a help_lines=(
        "${BOLD}${RIVALS_COLORS[G]}PATTERN SELECTION:${RESET}"
        "  ${RIVALS_COLORS[Y]}[1]${RESET} Full Rainbow    - All colors in sequence"
        "  ${RIVALS_COLORS[O]}[2]${RESET} Warm Rainbow    - Warm colors only (Y→O→R→P→M)"
        "  ${RIVALS_COLORS[B]}[3]${RESET} Cool Rainbow    - Cool colors only (U→B→I→A→T→G)"
        "  ${RIVALS_COLORS[P]}[4]${RESET} Wave Pattern    - Forward & backward wave"
        "  ${RIVALS_COLORS[M]}[5]${RESET} Fire Pattern    - Hot fiery colors"
        "  ${RIVALS_COLORS[A]}[6]${RESET} Ocean Pattern   - Deep water colors"
        ""
        "${BOLD}${RIVALS_COLORS[G]}ACTIONS:${RESET}"
        "  ${RIVALS_COLORS[Y]}[c]${RESET} Copy to Clipboard - Copy the Rivals code"
        "  ${RIVALS_COLORS[R]}[x]${RESET} Clear Text       - Clear current input"
        "  ${RIVALS_COLORS[U]}[s]${RESET} Save to File     - Save current conversion"
        "  ${RIVALS_COLORS[G]}[w]${RESET} Word Mode        - Toggle word-based coloring"
        ""
        "${BOLD}${RIVALS_COLORS[G]}NAVIGATION:${RESET}"
        "  ${RIVALS_COLORS[Y]}[↑]${RESET} Previous History"
        "  ${RIVALS_COLORS[Y]}[↓]${RESET} Next History"
        ""
        "${BOLD}${RIVALS_COLORS[G]}OTHER:${RESET}"
        "  ${RIVALS_COLORS[M]}[h]${RESET} Toggle Help"
        "  ${RIVALS_COLORS[A]}[q]${RESET} Quit"
        ""
        "${DIM}Press any key to return to preview...${RESET}"
    )

    for line in "${help_lines[@]}"; do
        move_cursor $row 3
        echo -ne "$line"
        ((row++))
    done

    # Wait for key press
    read -k 1 -s
    show_help=0
}

# ============================================================================
# HISTORY MANAGEMENT
# ============================================================================

add_to_history() {
    local text="$1"
    local pattern="$2"

    if [[ -n "$text" ]]; then
        history_stack+=("$text|$pattern")

        # Limit history size
        if (( ${#history_stack[@]} > max_history )); then
            shift history_stack
        fi

        history_index=${#history_stack[@]}
    fi
}

get_from_history() {
    local direction="$1"

    if (( ${#history_stack[@]} == 0 )); then
        return
    fi

    if [[ "$direction" == "prev" ]]; then
        if (( history_index > 1 )); then
            ((history_index--))
        fi
    elif [[ "$direction" == "next" ]]; then
        if (( history_index < ${#history_stack[@]} )); then
            ((history_index++))
        fi
    fi

    local entry="${history_stack[$history_index]}"
    current_text="${entry%|*}"
    current_pattern="${entry#*|}"
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

copy_to_clipboard() {
    if [[ -n "$cached_output" ]]; then
        # Try different clipboard commands
        if command -v xclip &>/dev/null; then
            echo -n "$cached_output" | xclip -selection clipboard
            return 0
        elif command -v xsel &>/dev/null; then
            echo -n "$cached_output" | xsel --clipboard
            return 0
        elif command -v pbcopy &>/dev/null; then
            echo -n "$cached_output" | pbcopy
            return 0
        fi
    fi
    return 1
}

save_to_file() {
    local filename="rivals_output_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "=== Marvel Rivals Conversion ==="
        echo "Original: $current_text"
        echo "Pattern: $current_pattern"
        echo "Rivals Code: $cached_output"
        echo "Generated: $(date)"
    } > "$filename"

    echo "$filename"
}

# ============================================================================
# MAIN INTERACTIVE LOOP
# ============================================================================

interactive_mode() {
    # Initialize
    current_text=""
    current_pattern="full"

    # Initial render
    render_preview "$current_text" "$current_pattern"

    # Main loop
    while true; do
        # Read single character
        read -k 1 key

        case "$key" in
            # Quit
            q|Q)
                break
                ;;

            # Help toggle
            h|H)
                if (( show_help == 0 )); then
                    show_help=1
                    render_help
                    render_preview "$current_text" "$current_pattern"
                fi
                ;;

            # Clear text
            x|X)
                current_text=""
                render_preview "$current_text" "$current_pattern"
                ;;

            # Copy to clipboard
            c|C)
                if copy_to_clipboard; then
                    # Show brief notification
                    move_cursor $((TERM_ROWS - 1)) 1
                    echo -ne "${RIVALS_COLORS[G]}✓ Copied to clipboard!${RESET}"
                    sleep 0.5
                    render_preview "$current_text" "$current_pattern"
                fi
                ;;

            # Save to file
            s|S)
                local saved_file=$(save_to_file)
                move_cursor $((TERM_ROWS - 1)) 1
                echo -ne "${RIVALS_COLORS[G]}✓ Saved to $saved_file${RESET}"
                sleep 1
                render_preview "$current_text" "$current_pattern"
                ;;

            # Pattern selection
            1)
                current_pattern="full"
                render_preview "$current_text" "$current_pattern"
                ;;
            2)
                current_pattern="warm"
                render_preview "$current_text" "$current_pattern"
                ;;
            3)
                current_pattern="cool"
                render_preview "$current_text" "$current_pattern"
                ;;
            4)
                current_pattern="wave"
                render_preview "$current_text" "$current_pattern"
                ;;
            5)
                current_pattern="fire"
                render_preview "$current_text" "$current_pattern"
                ;;
            6)
                current_pattern="ocean"
                render_preview "$current_text" "$current_pattern"
                ;;

            # Backspace
            $'\x7f')
                if (( ${#current_text} > 0 )); then
                    current_text="${current_text:0:-1}"
                    render_preview "$current_text" "$current_pattern"
                fi
                ;;

            # Enter - add to history
            $'\n')
                add_to_history "$current_text" "$current_pattern"
                ;;

            # Regular character
            *)
                # Only add printable characters
                if [[ "$key" =~ [[:print:]] ]]; then
                    current_text+="$key"
                    render_preview "$current_text" "$current_pattern"
                fi
                ;;
        esac
    done
}

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup() {
    echo -ne "$SHOW_CURSOR$RESET"
    echo -ne "$CLEAR_SCREEN"
    move_cursor 1 1
    echo "Thanks for using Marvel Rivals Rainbow Converter!"
}

trap cleanup EXIT INT TERM

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

show_usage() {
    cat << EOF
${BOLD}${RIVALS_COLORS[M]}Marvel Rivals Rainbow Converter - Live Preview${RESET}

${BOLD}USAGE:${RESET}
    $0 [options] [text]

${BOLD}OPTIONS:${RESET}
    -i, --interactive    Launch interactive mode (default)
    -p, --pattern NAME   Set pattern (full, warm, cool, wave, fire, ocean)
    -h, --help          Show this help message

${BOLD}EXAMPLES:${RESET}
    $0                          # Interactive mode
    $0 -i                       # Interactive mode
    $0 "hello world"            # Quick convert with full rainbow
    $0 -p warm "gg ez"          # Quick convert with warm pattern

${BOLD}INTERACTIVE MODE KEYS:${RESET}
    [1-6]   Change pattern
    [c]     Copy to clipboard
    [x]     Clear text
    [h]     Toggle help
    [q]     Quit

EOF
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

main() {
    local interactive=1
    local quick_text=""

    # Parse arguments
    while (( $# > 0 )); do
        case "$1" in
            -i|--interactive)
                interactive=1
                shift
                ;;
            -p|--pattern)
                current_pattern="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                return 0
                ;;
            *)
                quick_text="$1"
                interactive=0
                shift
                ;;
        esac
    done

    # Quick mode or interactive mode
    if (( interactive == 1 )); then
        interactive_mode
    else
        # Quick conversion mode
        if [[ -n "$quick_text" ]]; then
            local output=$(convert_to_rivals "$quick_text" "$current_pattern")
            echo "$output"
        else
            show_usage
        fi
    fi
}

# Run main function
main "$@"
