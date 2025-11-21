# Generate rainbow preview
generate_rainbow() {
    local text=$1
    local pattern_name=$2
    local result=""

    local -a pattern
    pattern=(${=ALL_PATTERNS[$pattern_name]})

    if [[ ${#text} -eq 0 ]]; then
        echo ""
        return
    fi

    if [[ $REPEAT_MODE -eq 1 ]]; then
        # Per word mode
        local word=""
        local in_word=0

        for ((i=1; i<=${#text}; i++)); do
            local char="${text:$((i-1)):1}"
            if [[ "$char" =~ [[:alnum:]] ]]; then
                word+="$char"
                in_word=1
            else
                if [[ $in_word -eq 1 && -n "$word" ]]; then
                    local word_len=${#word}

                    if [[ $SYMMETRY_MODE -eq 2 ]]; then
                        # FULL mode - distribute pattern evenly across the word
                        local pattern_len=${#pattern[@]}
                        local chars_per_color=$(( (word_len + pattern_len - 1) / pattern_len ))

                        local char_idx=0
                        for ((color_idx=1; color_idx<=pattern_len && char_idx<word_len; color_idx++)); do
                            local color_code="${pattern[$color_idx]}"
                            local chars_to_color=$chars_per_color

                            # Last color gets remaining characters
                            if [[ $color_idx -eq $pattern_len ]]; then
                                chars_to_color=$((word_len - char_idx))
                            fi

                            for ((j=0; j<chars_to_color && char_idx<word_len; j++)); do
                                local wchar="${word:$char_idx:1}"
                                result+="${COLORS[$color_code]}${wchar}${RESET}"
                                ((char_idx++))
                            done
                        done
                    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
                        # MIRROR mode - Word with symmetry
                        for ((j=1; j<=$word_len; j++)); do
                            local wchar="${word:$((j-1)):1}"
                            local pos=$j
                            if [[ $j -gt $(( (word_len + 1) / 2 )) ]]; then
                                pos=$(( word_len - j + 1 ))
                            fi
                            local color_code="${pattern[$(( ((pos - 1) % ${#pattern[@]}) + 1 ))]}"
                            result+="${COLORS[$color_code]}${wchar}${RESET}"
                        done
                    else
                        # No symmetry - Word without symmetry
                        for ((j=1; j<=$word_len; j++)); do
                            local wchar="${word:$((j-1)):1}"
                            local color_code="${pattern[$(( ((j - 1) % ${#pattern[@]}) + 1 ))]}"
                            result+="${COLORS[$color_code]}${wchar}${RESET}"
                        done
                    fi

                    word=""
                    in_word=0
                fi
                result+="$char"
            fi
        done

        # Handle last word if text doesn't end with non-alphanumeric
        if [[ -n "$word" ]]; then
            local word_len=${#word}

            if [[ $SYMMETRY_MODE -eq 2 ]]; then
                # FULL mode - distribute pattern evenly across the word
                local pattern_len=${#pattern[@]}
                local chars_per_color=$(( (word_len + pattern_len - 1) / pattern_len ))

                local char_idx=0
                for ((color_idx=1; color_idx<=pattern_len && char_idx<word_len; color_idx++)); do
                    local color_code="${pattern[$color_idx]}"
                    local chars_to_color=$chars_per_color

                    # Last color gets remaining characters
                    if [[ $color_idx -eq $pattern_len ]]; then
                        chars_to_color=$((word_len - char_idx))
                    fi

                    for ((j=0; j<chars_to_color && char_idx<word_len; j++)); do
                        local wchar="${word:$char_idx:1}"
                        result+="${COLORS[$color_code]}${wchar}${RESET}"
                        ((char_idx++))
                    done
                done
            elif [[ $SYMMETRY_MODE -eq 1 ]]; then
                # MIRROR mode
                for ((j=1; j<=$word_len; j++)); do
                    local wchar="${word:$((j-1)):1}"
                    local pos=$j
                    if [[ $j -gt $(( (word_len + 1) / 2 )) ]]; then
                        pos=$(( word_len - j + 1 ))
                    fi
                    local color_code="${pattern[$(( ((pos - 1) % ${#pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${wchar}${RESET}"
                done
            else
                # No symmetry
                for ((j=1; j<=$word_len; j++)); do
                    local wchar="${word:$((j-1)):1}"
                    local color_code="${pattern[$(( ((j - 1) % ${#pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${wchar}${RESET}"
                done
            fi
        fi
    else
        # Continuous mode
        if [[ $SYMMETRY_MODE -eq 2 ]]; then
            # FULL mode - distribute pattern evenly across entire text (only alphanumeric chars)
            # First, count total alphanumeric characters
            local total_chars=0
            for ((i=1; i<=${#text}; i++)); do
                local c="${text:$((i-1)):1}"
                if [[ "$c" =~ [[:alnum:]] ]]; then
                    ((total_chars++))
                fi
            done

            # Calculate characters per color
            local pattern_len=${#pattern[@]}
            local chars_per_color=$(( (total_chars + pattern_len - 1) / pattern_len ))

            # Apply colors
            local char_count=0
            local current_color_idx=1
            local chars_in_current_color=0

            for ((i=1; i<=${#text}; i++)); do
                local char="${text:$((i-1)):1}"
                if [[ "$char" =~ [[:alnum:]] ]]; then
                    ((char_count++))

                    # Determine which color this character should be
                    local color_idx=$(( (char_count - 1) / chars_per_color + 1 ))
                    if [[ $color_idx -gt $pattern_len ]]; then
                        color_idx=$pattern_len
                    fi

                    local color_code="${pattern[$color_idx]}"
                    result+="${COLORS[$color_code]}${char}${RESET}"
                else
                    result+="$char"
                fi
            done
        elif [[ $SYMMETRY_MODE -eq 1 ]]; then
            # MIRROR mode - Continuous with symmetry
            local total_chars=0
            for ((i=1; i<=${#text}; i++)); do
                local c="${text:$((i-1)):1}"
                if [[ "$c" =~ [[:alnum:]] ]]; then
                    ((total_chars++))
                fi
            done

            local char_count=0
            for ((i=1; i<=${#text}; i++)); do
                local char="${text:$((i-1)):1}"
                if [[ "$char" =~ [[:alnum:]] ]]; then
                    ((char_count++))
                    local pos=$char_count
                    if [[ $char_count -gt $(( (total_chars + 1) / 2 )) ]]; then
                        pos=$(( total_chars - char_count + 1 ))
                    fi
                    local color_code="${pattern[$(( ((pos - 1) % ${#pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${char}${RESET}"
                else
                    result+="$char"
                fi
            done
        else
            # No symmetry - Continuous without symmetry
            local color_idx=1
            for ((i=1; i<=${#text}; i++)); do
                local char="${text:$((i-1)):1}"
                if [[ "$char" =~ [[:alnum:]] ]]; then
                    local color_code="${pattern[$(( ((color_idx - 1) % ${#pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${char}${RESET}"
                    ((color_idx++))
                else
                    result+="$char"
                fi
            done
        fi
    fi

    echo -n "$result"
}

# Wrapper function to match expected name
generate_rainbow_preview() {
    generate_rainbow "$@"
}
