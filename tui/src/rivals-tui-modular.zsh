#!/usr/bin/env zsh

# rivals-tui-modular.zsh - Modular TUI entry point
# Main application orchestrator using component-based architecture

# Get script directory for relative imports
SCRIPT_DIR="${0:A:h}"

# Source utilities
source "${SCRIPT_DIR}/utils/constants.zsh"
source "${SCRIPT_DIR}/utils/clipboard.zsh"
source "${SCRIPT_DIR}/utils/config.zsh"

# Source state management
source "${SCRIPT_DIR}/state/app_state.zsh"

# Source libraries
source "${SCRIPT_DIR}/lib/text_converter.zsh"
source "${SCRIPT_DIR}/lib/text_renderer.zsh"

# Source pages
source "${SCRIPT_DIR}/pages/main_page.zsh"
source "${SCRIPT_DIR}/pages/pattern_creator_page.zsh"
source "${SCRIPT_DIR}/pages/pattern_manager_page.zsh"

# Source input handlers
source "${SCRIPT_DIR}/handlers/creator_input.zsh"
source "${SCRIPT_DIR}/handlers/manager_input.zsh"

# Draw complete UI based on current mode
draw_ui() {
    # Check if success message should be cleared
    state_check_success_timeout && draw_ui_needed=1

    tput cup 0 0
    tput ed

    case "$CURRENT_MODE" in
        "main")
            main_page_draw
            ;;
        "pattern_creator")
            pattern_creator_page_draw
            ;;
        "pattern_manager")
            pattern_manager_page_draw
            ;;
    esac
}

# Copy current text with pattern to clipboard
copy_to_clipboard() {
    if [[ -z "$CLIPBOARD_CMD" || -z "$INPUT_TEXT" ]]; then
        return 1
    fi

    local current_pattern="${PATTERN_ORDER[$CURRENT_PATTERN_INDEX]}"
    local rivals_code=$(text_to_rivals "$INPUT_TEXT" "$current_pattern")
    clipboard_copy "$rivals_code"
    return $?
}

# Handle main mode input
handle_main_input() {
    local char=$1

    case "$char" in
        $'\x1b') # Escape sequences
            IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
            if [[ -z "$char2" ]]; then
                return 1  # Exit signal
            elif [[ "$char2" == "[" ]]; then
                IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                case "$char3" in
                    "C") # Right arrow - next pattern
                        local total=${#PATTERN_ORDER[@]}
                        CURRENT_PATTERN_INDEX=$(( (CURRENT_PATTERN_INDEX % total) + 1 ))
                        draw_ui
                        ;;
                    "D") # Left arrow - previous pattern
                        local total=${#PATTERN_ORDER[@]}
                        CURRENT_PATTERN_INDEX=$(( ((CURRENT_PATTERN_INDEX - 2 + total) % total) + 1 ))
                        draw_ui
                        ;;
                    "1") # Special keys (Ctrl+Arrow, Ctrl+Shift+Arrow, Shift+Arrow, Ctrl+Shift+C)
                        IFS= read -r -s -t 0.1 -k 1 char4 2>/dev/null
                        if [[ "$char4" == ";" ]]; then
                            IFS= read -r -s -t 0.1 -k 1 char5 2>/dev/null
                            case "$char5" in
                                "2") # Shift+Arrow
                                    IFS= read -r -s -t 0.1 -k 1 char6 2>/dev/null
                                    case "$char6" in
                                        "C") # Shift+Right - select right
                                            if [[ $SELECTION_START -lt 0 ]]; then
                                                SELECTION_START=$CURSOR_POS
                                            fi
                                            if [[ $CURSOR_POS -lt ${#INPUT_TEXT} ]]; then
                                                ((CURSOR_POS++))
                                                SELECTION_END=$CURSOR_POS
                                                draw_ui
                                            fi
                                            ;;
                                        "D") # Shift+Left - select left
                                            if [[ $SELECTION_START -lt 0 ]]; then
                                                SELECTION_START=$CURSOR_POS
                                            fi
                                            if [[ $CURSOR_POS -gt 0 ]]; then
                                                ((CURSOR_POS--))
                                                SELECTION_END=$CURSOR_POS
                                                draw_ui
                                            fi
                                            ;;
                                    esac
                                    ;;
                                "5") # Ctrl+Arrow
                                    IFS= read -r -s -t 0.1 -k 1 char6 2>/dev/null
                                    case "$char6" in
                                        "C") # Ctrl+Right - move cursor to next word
                                            local new_pos=$(state_find_word_end "$CURSOR_POS" "$INPUT_TEXT")
                                            CURSOR_POS=$new_pos
                                            state_reset_selection
                                            draw_ui
                                            ;;
                                        "D") # Ctrl+Left - move cursor to previous word
                                            local new_pos=$(state_find_word_start "$CURSOR_POS" "$INPUT_TEXT")
                                            CURSOR_POS=$new_pos
                                            state_reset_selection
                                            draw_ui
                                            ;;
                                    esac
                                    ;;
                                "6") # Ctrl+Shift+Arrow
                                    IFS= read -r -s -t 0.1 -k 1 char6 2>/dev/null
                                    case "$char6" in
                                        "C") # Ctrl+Shift+Right - select to end of next word
                                            if [[ $SELECTION_START -lt 0 ]]; then
                                                SELECTION_START=$CURSOR_POS
                                            fi
                                            local new_pos=$(state_find_word_end "$CURSOR_POS" "$INPUT_TEXT")
                                            CURSOR_POS=$new_pos
                                            SELECTION_END=$new_pos
                                            draw_ui
                                            ;;
                                        "D") # Ctrl+Shift+Left - select to start of previous word
                                            if [[ $SELECTION_START -lt 0 ]]; then
                                                SELECTION_START=$CURSOR_POS
                                            fi
                                            local new_pos=$(state_find_word_start "$CURSOR_POS" "$INPUT_TEXT")
                                            CURSOR_POS=$new_pos
                                            SELECTION_END=$new_pos
                                            draw_ui
                                            ;;
                                    esac
                                    ;;
                            esac
                        fi
                        ;;
                esac
            fi
            ;;
        $'\t') # Tab - cycle forward
            local total=${#PATTERN_ORDER[@]}
            CURRENT_PATTERN_INDEX=$(( (CURRENT_PATTERN_INDEX % total) + 1 ))
            draw_ui
            ;;
        $'\x10') # Ctrl+P - Pattern manager
            CURRENT_MODE="pattern_manager"
            MANAGER_CURSOR=$CURRENT_PATTERN_INDEX
            draw_ui
            ;;
        $'\n'|$'\r') # Enter - copy
            if copy_to_clipboard; then
                state_show_success "Copied to clipboard!"
                draw_ui
            fi
            ;;
        $'\x7f'|$'\b') # Backspace
            if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
                # Delete selection
                local sel_start=$SELECTION_START
                local sel_end=$SELECTION_END
                if [[ $sel_start -gt $sel_end ]]; then
                    local tmp=$sel_start
                    sel_start=$sel_end
                    sel_end=$tmp
                fi
                INPUT_TEXT="${INPUT_TEXT:0:$sel_start}${INPUT_TEXT:$sel_end}"
                CURSOR_POS=$sel_start
                state_reset_selection
                draw_ui
            elif [[ $CURSOR_POS -gt 0 ]]; then
                INPUT_TEXT="${INPUT_TEXT:0:$(($CURSOR_POS - 1))}${INPUT_TEXT:$CURSOR_POS}"
                ((CURSOR_POS--))
                draw_ui
            fi
            ;;
        $'\x01') # Ctrl+A - Select all
            if [[ ${#INPUT_TEXT} -gt 0 ]]; then
                SELECTION_START=0
                SELECTION_END=${#INPUT_TEXT}
                CURSOR_POS=${#INPUT_TEXT}
                draw_ui
            fi
            ;;
        $'\x03') # Ctrl+C - Exit
            return 1
            ;;
        $'\x0b') # Ctrl+K - Copy selection
            if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
                local sel_start=$SELECTION_START
                local sel_end=$SELECTION_END
                if [[ $sel_start -gt $sel_end ]]; then
                    local tmp=$sel_start
                    sel_start=$sel_end
                    sel_end=$tmp
                fi
                local selected_text="${INPUT_TEXT:$sel_start:$((sel_end - sel_start))}"
                echo -n "$selected_text" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    state_show_success "Copied selection!"
                    draw_ui
                fi
            fi
            ;;
        $'\x16') # Ctrl+V - Paste
            local pasted=$(clipboard_paste)
            if [[ -n "$pasted" ]]; then
                # Delete selection if exists
                if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
                    local sel_start=$SELECTION_START
                    local sel_end=$SELECTION_END
                    if [[ $sel_start -gt $sel_end ]]; then
                        local tmp=$sel_start
                        sel_start=$sel_end
                        sel_end=$tmp
                    fi
                    INPUT_TEXT="${INPUT_TEXT:0:$sel_start}${INPUT_TEXT:$sel_end}"
                    CURSOR_POS=$sel_start
                    state_reset_selection
                fi
                # Insert pasted text at cursor
                INPUT_TEXT="${INPUT_TEXT:0:$CURSOR_POS}${pasted}${INPUT_TEXT:$CURSOR_POS}"
                CURSOR_POS=$((CURSOR_POS + ${#pasted}))
                draw_ui
            fi
            ;;
        $'\x18') # Ctrl+X - Cut
            if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
                local sel_start=$SELECTION_START
                local sel_end=$SELECTION_END
                if [[ $sel_start -gt $sel_end ]]; then
                    local tmp=$sel_start
                    sel_start=$sel_end
                    sel_end=$tmp
                fi
                local selected_text="${INPUT_TEXT:$sel_start:$((sel_end - sel_start))}"
                echo -n "$selected_text" | eval "$CLIPBOARD_CMD" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    INPUT_TEXT="${INPUT_TEXT:0:$sel_start}${INPUT_TEXT:$sel_end}"
                    CURSOR_POS=$sel_start
                    state_reset_selection
                    state_show_success "Cut selection to clipboard!"
                    draw_ui
                fi
            fi
            ;;
        $'\x12') # Ctrl+R - Toggle repeat modes
            REPEAT_MODE=$(( (REPEAT_MODE + 1) % 2 ))
            case $REPEAT_MODE in
                0) state_show_success "Continuous mode - Pattern flows through text" ;;
                1) state_show_success "Per word mode - Pattern resets each word" ;;
            esac
            draw_ui
            ;;
        $'\x13') # Ctrl+S - Cycle symmetry modes
            SYMMETRY_MODE=$(( (SYMMETRY_MODE + 1) % 3 ))
            case $SYMMETRY_MODE in
                0) state_show_success "Symmetry OFF - Normal pattern flow" ;;
                1) state_show_success "Mirror symmetry - Text mirrors from center" ;;
                2) state_show_success "Full symmetry - Complete pattern always shown" ;;
            esac
            draw_ui
            ;;
        *) # Regular character
            # Delete selection if exists
            if [[ $SELECTION_START -ge 0 && $SELECTION_END -ge 0 ]]; then
                local sel_start=$SELECTION_START
                local sel_end=$SELECTION_END
                if [[ $sel_start -gt $sel_end ]]; then
                    local tmp=$sel_start
                    sel_start=$sel_end
                    sel_end=$tmp
                fi
                INPUT_TEXT="${INPUT_TEXT:0:$sel_start}${INPUT_TEXT:$sel_end}"
                CURSOR_POS=$sel_start
                state_reset_selection
            fi

            if [[ ${#INPUT_TEXT} -lt $INPUT_MAX_LENGTH ]]; then
                INPUT_TEXT="${INPUT_TEXT:0:$CURSOR_POS}${char}${INPUT_TEXT:$CURSOR_POS}"
                ((CURSOR_POS++))
                draw_ui
            fi
            ;;
    esac

    return 0
}

# Cleanup on exit
cleanup() {
    {
        tput cnorm 2>/dev/null
        tput rmcup 2>/dev/null
        stty echo ixon 2>/dev/null
        echo -e "\n${UI_COLORS[ACCENT]}${UI_COLORS[BOLD]}Thanks for using Rivals Rainbow TUI v${VERSION}!${UI_COLORS[RESET]}\n"
    } 2>/dev/null
    exit 0
}

# Show help
show_help() {
    cat << EOF
Rivals Rainbow TUI v${VERSION} (Modular Edition)
Marvel Rivals Rainbow Text Converter

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help message
  -v, --version  Show version information

This is the modular, component-based version of Rivals TUI.

For more information, visit:
  https://github.com/yourusername/rivals-rainbow-tui

EOF
    exit 0
}

# Show version
show_version() {
    echo "Rivals Rainbow TUI v${VERSION} (Modular)"
    echo "Marvel Rivals Rainbow Text Converter"
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help ;;
            -v|--version) show_version ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
}

# Main application loop
main() {
    # Initialize
    config_init
    config_load_patterns
    clipboard_detect
    state_init

    # Setup terminal
    trap cleanup EXIT INT TERM
    tput smcup 2>/dev/null
    clear
    tput civis 2>/dev/null
    stty -echo -icanon -ixon min 0 2>/dev/null

    # Initial draw
    draw_ui

    # Input loop
    while true; do
        unset char
        if ! IFS= read -r -s -t 0.5 -k 1 char 2>/dev/null; then
            if state_check_success_timeout; then
                draw_ui
            fi
            continue
        fi

        {
            case "$CURRENT_MODE" in
                "main")
                    if ! handle_main_input "$char"; then
                        break  # Exit requested
                    fi
                    ;;
                "pattern_creator")
                    handle_creator_input "$char"
                    ;;
                "pattern_manager")
                    handle_manager_input "$char"
                    ;;
            esac
        } 2>/dev/null
    done
}

# Parse arguments and run
parse_args "$@"
main

exit 0
