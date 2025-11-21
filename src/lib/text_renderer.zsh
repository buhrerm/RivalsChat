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

    if [[ $REPEAT_MODE -eq 2 ]]; then
        # Per phrase mode
        if [[ $SYMMETRY_MODE -eq 2 ]]; then
            # Full symmetry - ensure complete pattern
            local -a full_pattern=()
            for ((i=1; i<${#pattern[@]}; i++)); do
                full_pattern+=("${pattern[$i]}")
            done
            full_pattern+=("${pattern[${#pattern[@]}]}")
            for ((i=${#pattern[@]}-1; i>=1; i--)); do
                full_pattern+=("${pattern[$i]}")
            done

            local color_idx=1
            for ((i=1; i<=${#text}; i++)); do
                local char="${text:$((i-1)):1}"
                if [[ "$char" =~ [[:alnum:]] ]]; then
                    local color_code="${full_pattern[$(( ((color_idx - 1) % ${#full_pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${char}${RESET}"
                    ((color_idx++))
                else
                    result+="$char"
                fi
            done
        elif [[ $SYMMETRY_MODE -eq 1 ]]; then
            # Phrase with symmetry
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
            # Per phrase without symmetry
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
    elif [[ $REPEAT_MODE -eq 1 ]]; then
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
                        # Full symmetry for word - ensure complete pattern
                        local -a full_pattern=()
                        # Build full symmetrical pattern
                        for ((j=1; j<${#pattern[@]}; j++)); do
                            full_pattern+=("${pattern[$j]}")
                        done
                        # Add rightmost color as center
                        full_pattern+=("${pattern[${#pattern[@]}]}")
                        # Add reversed colors
                        for ((j=${#pattern[@]}-1; j>=1; j--)); do
                            full_pattern+=("${pattern[$j]}")
                        done

                        # Apply full pattern to word
                        for ((j=1; j<=$word_len; j++)); do
                            local wchar="${word:$((j-1)):1}"
                            local color_code="${full_pattern[$(( ((j - 1) % ${#full_pattern[@]}) + 1 ))]}"
                            result+="${COLORS[$color_code]}${wchar}${RESET}"
                        done
                    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
                        # Word with symmetry
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
                        # Word without symmetry
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

        if [[ -n "$word" ]]; then
            local word_len=${#word}

            if [[ $SYMMETRY_MODE -eq 2 ]]; then
                # Full symmetry for word
                local -a full_pattern=()
                for ((j=1; j<${#pattern[@]}; j++)); do
                    full_pattern+=("${pattern[$j]}")
                done
                full_pattern+=("${pattern[${#pattern[@]}]}")
                for ((j=${#pattern[@]}-1; j>=1; j--)); do
                    full_pattern+=("${pattern[$j]}")
                done

                for ((j=1; j<=$word_len; j++)); do
                    local wchar="${word:$((j-1)):1}"
                    local color_code="${full_pattern[$(( ((j - 1) % ${#full_pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${wchar}${RESET}"
                done
            elif [[ $SYMMETRY_MODE -eq 1 ]]; then
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
            # Full symmetry - ensure complete pattern
            local -a full_pattern=()
            for ((i=1; i<${#pattern[@]}; i++)); do
                full_pattern+=("${pattern[$i]}")
            done
            full_pattern+=("${pattern[${#pattern[@]}]}")
            for ((i=${#pattern[@]}-1; i>=1; i--)); do
                full_pattern+=("${pattern[$i]}")
            done

            local color_idx=1
            for ((i=1; i<=${#text}; i++)); do
                local char="${text:$((i-1)):1}"
                if [[ "$char" =~ [[:alnum:]] ]]; then
                    local color_code="${full_pattern[$(( ((color_idx - 1) % ${#full_pattern[@]}) + 1 ))]}"
                    result+="${COLORS[$color_code]}${char}${RESET}"
                    ((color_idx++))
                else
                    result+="$char"
                fi
            done
        elif [[ $SYMMETRY_MODE -eq 1 ]]; then
            # Continuous with symmetry
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
            # Continuous without symmetry
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

