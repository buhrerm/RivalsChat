handle_manager_input() {
    char=$1
    local total_patterns=${#PATTERN_ORDER[@]}

    case "$char" in
        $'\x1b') # Escape or arrow keys
            IFS= read -r -s -t 0.1 -k 1 char2 2>/dev/null
            if [[ -z "$char2" ]]; then
                # Just escape - return to main
                state_handle_escape "pattern_manager"
                draw_ui
            elif [[ "$char2" == "[" ]]; then
                IFS= read -r -s -t 0.1 -k 1 char3 2>/dev/null
                case "$char3" in
                    "A") # Up arrow
                        if [[ $MANAGER_CURSOR -gt 1 ]]; then
                            ((MANAGER_CURSOR--))
                            draw_ui
                        fi
                        ;;
                    "B") # Down arrow
                        if [[ $MANAGER_CURSOR -lt $total_patterns ]]; then
                            ((MANAGER_CURSOR++))
                            draw_ui
                        fi
                        ;;
                esac
            fi
            ;;
        'n'|'N') # New pattern
            CURRENT_MODE="pattern_creator"
            CREATOR_MODE="name"
            CREATOR_NAME=""
            CREATOR_ICON=""
            CREATOR_COLORS=()
            CREATOR_CURSOR=1
            CREATOR_COLOR_CURSOR=1
            draw_ui
            ;;
        'e'|'E') # Edit pattern (only for custom patterns)
            local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"
            if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
                CURRENT_MODE="pattern_creator"
                CREATOR_MODE="name"
                CREATOR_NAME="$current_pattern"
                CREATOR_ICON="${ALL_ICONS[$current_pattern]}"
                # Parse colors from pattern string - properly expand into global array
                CREATOR_COLORS=()
                local -a parsed_colors
                parsed_colors=(${=ALL_PATTERNS[$current_pattern]})
                for color in "${parsed_colors[@]}"; do
                    CREATOR_COLORS+=("$color")
                done
                CREATOR_CURSOR=1
                CREATOR_COLOR_CURSOR=1
                draw_ui
            fi
            ;;
        'd'|'D') # Delete pattern (only for custom patterns)
            local current_pattern="${PATTERN_ORDER[$MANAGER_CURSOR]}"
            if [[ -z "${BUILTIN_PATTERNS[$current_pattern]}" ]]; then
                # Remove from arrays
                unset "ALL_PATTERNS[$current_pattern]"
                unset "ALL_ICONS[$current_pattern]"

                # Remove from order
                local new_order=()
                for p in "${PATTERN_ORDER[@]}"; do
                    if [[ "$p" != "$current_pattern" ]]; then
                        new_order+=("$p")
                    fi
                done
                PATTERN_ORDER=("${new_order[@]}")

                # Adjust cursor if needed
                if [[ $MANAGER_CURSOR -gt ${#PATTERN_ORDER[@]} ]]; then
                    MANAGER_CURSOR=${#PATTERN_ORDER[@]}
                fi

                # Save changes
                save_patterns

                SUCCESS_MSG="Pattern '$current_pattern' deleted!"
                SHOW_SUCCESS=1
                SUCCESS_TIME=$(date +%s)
                draw_ui
            fi
            ;;
        $'\n'|$'\r') # Enter - select pattern
            CURRENT_PATTERN_INDEX=$MANAGER_CURSOR
            CURRENT_MODE="main"
            draw_ui
            ;;
    esac
}
