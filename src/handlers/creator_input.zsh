# Handle pattern creator input
handle_creator_input() {
    char=$1

    case "$CREATOR_MODE" in
        "name")
            case "$char" in
                $'\t') # Tab - move to icon selection
                    if [[ -n "$CREATOR_NAME" ]]; then
                        CREATOR_MODE="icon"
                        draw_ui
                    fi
                    ;;
                $'\x7f'|$'\b') # Backspace
                    if [[ ${#CREATOR_NAME} -gt 0 ]]; then
                        CREATOR_NAME="${CREATOR_NAME:0:-1}"
                        draw_ui
                    fi
                    ;;
                $'\x1b') # Escape sequences for arrow keys or ESC
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to pattern manager
                        CURRENT_MODE="pattern_manager"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        CREATOR_CURSOR=1
                        CREATOR_COLOR_CURSOR=1
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "B") # Down arrow - move to icon selection
                                if [[ -n "$CREATOR_NAME" ]]; then
                                    CREATOR_MODE="icon"
                                    draw_ui
                                fi
                                ;;
                        esac
                    fi
                    ;;
                $'\x12') # Ctrl+R - Cycle through repeat modes
                    REPEAT_MODE=$(( (REPEAT_MODE + 1) % 3 ))
                    draw_ui
                    ;;
                $'\x13') # Ctrl+S - Cycle through symmetry modes
                    SYMMETRY_MODE=$(( (SYMMETRY_MODE + 1) % 3 ))
                    draw_ui
                    ;;
                *) # Regular character
                    if [[ ${#CREATOR_NAME} -lt 20 ]]; then
                        CREATOR_NAME+="$char"
                        draw_ui
                    fi
                    ;;
            esac
            ;;

        "icon")
            case "$char" in
                $'\t') # Tab - move to color selection
                    if [[ -n "$CREATOR_ICON" ]]; then
                        CREATOR_MODE="colors"
                        draw_ui
                    fi
                    ;;
                $'\x1b') # Escape sequences for arrow keys or ESC
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to pattern manager
                        CURRENT_MODE="pattern_manager"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        CREATOR_CURSOR=1
                        CREATOR_COLOR_CURSOR=1
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "C") # Right arrow
                                local icons_count=12
                                CREATOR_CURSOR=$(( (CREATOR_CURSOR % icons_count) + 1 ))
                                draw_ui
                                ;;
                            "D") # Left arrow
                                local icons_count=12
                                CREATOR_CURSOR=$(( ((CREATOR_CURSOR - 2 + icons_count) % icons_count) + 1 ))
                                draw_ui
                                ;;
                            "A") # Up arrow - go back to name
                                CREATOR_MODE="name"
                                draw_ui
                                ;;
                            "B") # Down arrow - move to colors
                                if [[ -n "$CREATOR_ICON" ]]; then
                                    CREATOR_MODE="colors"
                                    draw_ui
                                fi
                                ;;
                        esac
                    fi
                    ;;
                ' ') # Space - select icon
                    local icons=("🎨" "🌟" "💎" "🔥" "❄️" "⚡" "🌈" "🌸" "🍀" "🎭" "🎪" "🎯")
                    CREATOR_ICON="${icons[$CREATOR_CURSOR]}"
                    draw_ui
                    ;;
                $'\x12') # Ctrl+R - Cycle through repeat modes
                    REPEAT_MODE=$(( (REPEAT_MODE + 1) % 3 ))
                    draw_ui
                    ;;
                $'\x13') # Ctrl+S - Cycle through symmetry modes
                    SYMMETRY_MODE=$(( (SYMMETRY_MODE + 1) % 3 ))
                    draw_ui
                    ;;
            esac
            ;;

        "colors")
            case "$char" in
                $'\x1b') # Escape or arrow keys
                    IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
                    if [[ -z "$char2" ]]; then
                        # Just ESC - cancel and return to main
                        CURRENT_MODE="main"
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()
                        draw_ui
                    elif [[ "$char2" == "[" ]]; then
                        IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                        case "$char3" in
                            "C") # Right arrow
                                CREATOR_COLOR_CURSOR=$(( (CREATOR_COLOR_CURSOR % 13) + 1 ))
                                draw_ui
                                ;;
                            "D") # Left arrow
                                CREATOR_COLOR_CURSOR=$(( ((CREATOR_COLOR_CURSOR - 2 + 13) % 13) + 1 ))
                                draw_ui
                                ;;
                            "A") # Up arrow - navigate up in grid or go to icon mode
                                if [[ $CREATOR_COLOR_CURSOR -gt 6 ]]; then
                                    CREATOR_COLOR_CURSOR=$((CREATOR_COLOR_CURSOR - 6))
                                    # Ensure cursor is within valid range
                                    if [[ $CREATOR_COLOR_CURSOR -lt 1 ]]; then
                                        CREATOR_COLOR_CURSOR=1
                                    fi
                                else
                                    # Go back to icon mode
                                    CREATOR_MODE="icon"
                                fi
                                draw_ui
                                ;;
                            "B") # Down arrow - navigate down in grid
                                if [[ $CREATOR_COLOR_CURSOR -le 7 ]]; then
                                    CREATOR_COLOR_CURSOR=$((CREATOR_COLOR_CURSOR + 6))
                                    if [[ $CREATOR_COLOR_CURSOR -gt 13 ]]; then
                                        CREATOR_COLOR_CURSOR=13
                                    fi
                                fi
                                draw_ui
                                ;;
                        esac
                    fi
                    ;;
                ' ') # Space - add color (allows duplicates)
                    # Define color codes array locally
                    local -a color_codes
                    color_codes=(Y O R P M U B I A T G E K)

                    # Ensure CREATOR_COLOR_CURSOR is within valid range
                    if [[ $CREATOR_COLOR_CURSOR -ge 1 && $CREATOR_COLOR_CURSOR -le ${#color_codes[@]} ]]; then
                        local selected_code="${color_codes[$CREATOR_COLOR_CURSOR]}"

                        # Only add if we got a valid color code
                        if [[ -n "$selected_code" ]]; then
                            # Add the color (allows duplicates)
                            CREATOR_COLORS+=("$selected_code")
                        fi
                    fi

                    draw_ui
                    ;;
                $'\x7f'|$'\x08') # Backspace/Delete - remove last color
                    if [[ ${#CREATOR_COLORS[@]} -gt 0 ]]; then
                        # FIX: Use proper Zsh array removal syntax (not Bash)
                        local array_len=${#CREATOR_COLORS[@]}
                        CREATOR_COLORS[${array_len}]=()
                        draw_ui
                    fi
                    ;;
                's'|'S') # Save pattern
                    if [[ ${#CREATOR_COLORS[@]} -gt 0 && -n "$CREATOR_NAME" && -n "$CREATOR_ICON" ]]; then
                        # Add to patterns
                        ALL_PATTERNS[$CREATOR_NAME]="${CREATOR_COLORS[*]}"
                        ALL_ICONS[$CREATOR_NAME]="$CREATOR_ICON"

                        # Add to order if new
                        local exists=0
                        for p in "${PATTERN_ORDER[@]}"; do
                            if [[ "$p" == "$CREATOR_NAME" ]]; then
                                exists=1
                                break
                            fi
                        done

                        if [[ $exists -eq 0 ]]; then
                            PATTERN_ORDER+=("$CREATOR_NAME")
                        fi

                        # Save to file
                        save_patterns

                        # Return to main mode
                        CURRENT_MODE="main"
                        SUCCESS_MSG="Pattern '$CREATOR_NAME' saved!"
                        SHOW_SUCCESS=1
                        SUCCESS_TIME=$(date +%s)

                        # Find and select the new pattern
                        for ((i=1; i<=${#PATTERN_ORDER[@]}; i++)); do
                            if [[ "${PATTERN_ORDER[$i]}" == "$CREATOR_NAME" ]]; then
                                CURRENT_PATTERN_INDEX=$i
                                break
                            fi
                        done

                        # Reset creator state
                        CREATOR_NAME=""
                        CREATOR_ICON=""
                        CREATOR_COLORS=()

                        draw_ui
                    fi
                    ;;
                $'\x12') # Ctrl+R - Cycle through repeat modes
                    REPEAT_MODE=$(( (REPEAT_MODE + 1) % 3 ))
                    draw_ui
                    ;;
                $'\x13') # Ctrl+S - Cycle through symmetry modes
                    SYMMETRY_MODE=$(( (SYMMETRY_MODE + 1) % 3 ))
                    draw_ui
                    ;;
            esac
            ;;
    esac
}
