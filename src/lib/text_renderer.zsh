#!/usr/bin/env zsh

# text_renderer.zsh - Text rendering library
# Handles colored preview rendering with ANSI codes

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

# Generate colored preview of text
generate_rainbow_preview() {
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
        result=$(render_phrase_mode "$text" pattern)
    elif [[ $REPEAT_MODE -eq 1 ]]; then
        result=$(render_word_mode "$text" pattern)
    else
        result=$(render_continuous_mode "$text" pattern)
    fi

    echo -n "$result"
}

# Render in continuous mode
render_continuous_mode() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        result=$(render_full_symmetry "$text" pattern_ref)
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        result=$(render_mirror_symmetry "$text" pattern_ref)
    else
        result=$(render_continuous "$text" pattern_ref)
    fi

    echo -n "$result"
}

# Render in word mode
render_word_mode() {
    local text=$1
    local -n pattern_ref=$2
    local result=""
    local word=""
    local in_word=0

    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            word+="$char"
            in_word=1
        else
            if [[ $in_word -eq 1 && -n "$word" ]]; then
                result+=$(render_word "$word" pattern_ref)
                word=""
                in_word=0
            fi
            result+="$char"
        fi
    done

    if [[ -n "$word" ]]; then
        result+=$(render_word "$word" pattern_ref)
    fi

    echo -n "$result"
}

# Render in phrase mode
render_phrase_mode() {
    local text=$1
    local -n pattern_ref=$2

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        echo -n "$(render_full_symmetry "$text" pattern_ref)"
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        echo -n "$(render_mirror_symmetry "$text" pattern_ref)"
    else
        echo -n "$(render_continuous "$text" pattern_ref)"
    fi
}

# Render continuous (no symmetry)
render_continuous() {
    local text=$1
    local -n pattern_ref=$2
    local result=""
    local color_idx=1

    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color_code="${pattern_ref[$(( ((color_idx - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${char}${UI_COLORS[RESET]}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Render with mirror symmetry
render_mirror_symmetry() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

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
            local color_code="${pattern_ref[$(( ((pos - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${char}${UI_COLORS[RESET]}"
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Render with full symmetry
render_full_symmetry() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

    local -a full_pattern=()
    for ((i=1; i<${#pattern_ref[@]}; i++)); do
        full_pattern+=("${pattern_ref[$i]}")
    done
    full_pattern+=("${pattern_ref[${#pattern_ref[@]}]}")
    for ((i=${#pattern_ref[@]}-1; i>=1; i--)); do
        full_pattern+=("${pattern_ref[$i]}")
    done

    local color_idx=1
    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color_code="${full_pattern[$(( ((color_idx - 1) % ${#full_pattern[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${char}${UI_COLORS[RESET]}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Render a single word
render_word() {
    local word=$1
    local -n pattern_ref=$2
    local result=""
    local word_len=${#word}

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        local -a full_pattern=()
        for ((j=1; j<${#pattern_ref[@]}; j++)); do
            full_pattern+=("${pattern_ref[$j]}")
        done
        full_pattern+=("${pattern_ref[${#pattern_ref[@]}]}")
        for ((j=${#pattern_ref[@]}-1; j>=1; j--)); do
            full_pattern+=("${pattern_ref[$j]}")
        done

        for ((j=1; j<=$word_len; j++)); do
            local wchar="${word:$((j-1)):1}"
            local color_code="${full_pattern[$(( ((j - 1) % ${#full_pattern[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${wchar}${UI_COLORS[RESET]}"
        done
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        for ((j=1; j<=$word_len; j++)); do
            local wchar="${word:$((j-1)):1}"
            local pos=$j
            if [[ $j -gt $(( (word_len + 1) / 2 )) ]]; then
                pos=$(( word_len - j + 1 ))
            fi
            local color_code="${pattern_ref[$(( ((pos - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${wchar}${UI_COLORS[RESET]}"
        done
    else
        for ((j=1; j<=$word_len; j++)); do
            local wchar="${word:$((j-1)):1}"
            local color_code="${pattern_ref[$(( ((j - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="${COLORS[$color_code]}${wchar}${UI_COLORS[RESET]}"
        done
    fi

    echo -n "$result"
}

# Strip ANSI color codes
strip_ansi() {
    local text=$1
    echo -n "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Get visible length of colored text
visible_length() {
    local text=$1
    local stripped=$(strip_ansi "$text")
    echo ${#stripped}
}
