#!/usr/bin/env zsh

# text_converter.zsh - Text conversion library
# Handles conversion of plain text to Marvel Rivals color-coded format

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/../utils/constants.zsh"

# Convert text to Marvel Rivals format
text_to_rivals() {
    local text=$1
    local pattern_name=$2
    local result=""

    local -a pattern
    pattern=(${=ALL_PATTERNS[$pattern_name]})

    if [[ $REPEAT_MODE -eq 2 ]]; then
        result=$(convert_phrase_mode "$text" pattern)
    elif [[ $REPEAT_MODE -eq 1 ]]; then
        result=$(convert_word_mode "$text" pattern)
    else
        result=$(convert_continuous_mode "$text" pattern)
    fi

    echo -n "$result"
}

# Convert in continuous mode
convert_continuous_mode() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        result=$(apply_full_symmetry "$text" pattern_ref)
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        result=$(apply_mirror_symmetry "$text" pattern_ref)
    else
        result=$(apply_continuous "$text" pattern_ref)
    fi

    echo -n "$result"
}

# Convert in word mode
convert_word_mode() {
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
                result+=$(process_word "$word" pattern_ref)
                word=""
                in_word=0
            fi
            result+="$char"
        fi
    done

    # Process remaining word
    if [[ -n "$word" ]]; then
        result+=$(process_word "$word" pattern_ref)
    fi

    echo -n "$result"
}

# Convert in phrase mode
convert_phrase_mode() {
    local text=$1
    local -n pattern_ref=$2

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        echo -n "$(apply_full_symmetry "$text" pattern_ref)"
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        echo -n "$(apply_mirror_symmetry "$text" pattern_ref)"
    else
        echo -n "$(apply_continuous "$text" pattern_ref)"
    fi
}

# Apply continuous coloring (no symmetry)
apply_continuous() {
    local text=$1
    local -n pattern_ref=$2
    local result=""
    local color_idx=1

    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${pattern_ref[$(( ((color_idx - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="#${color}${char}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Apply mirror symmetry
apply_mirror_symmetry() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

    # Count total alphanumeric chars
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
            # Mirror for second half
            if [[ $char_count -gt $(( (total_chars + 1) / 2 )) ]]; then
                pos=$(( total_chars - char_count + 1 ))
            fi
            local color="${pattern_ref[$(( ((pos - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="#${color}${char}"
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Apply full symmetry (complete pattern)
apply_full_symmetry() {
    local text=$1
    local -n pattern_ref=$2
    local result=""

    # Build full symmetrical pattern
    local -a full_pattern=()
    for ((i=1; i<${#pattern_ref[@]}; i++)); do
        full_pattern+=("${pattern_ref[$i]}")
    done
    full_pattern+=("${pattern_ref[${#pattern_ref[@]}]}")
    for ((i=${#pattern_ref[@]}-1; i>=1; i--)); do
        full_pattern+=("${pattern_ref[$i]}")
    done

    # Apply pattern
    local color_idx=1
    for ((i=1; i<=${#text}; i++)); do
        local char="${text:$((i-1)):1}"
        if [[ "$char" =~ [[:alnum:]] ]]; then
            local color="${full_pattern[$(( ((color_idx - 1) % ${#full_pattern[@]}) + 1 ))]}"
            result+="#${color}${char}"
            ((color_idx++))
        else
            result+="$char"
        fi
    done

    echo -n "$result"
}

# Process a single word
process_word() {
    local word=$1
    local -n pattern_ref=$2
    local result=""
    local word_len=${#word}

    if [[ $SYMMETRY_MODE -eq 2 ]]; then
        # Full symmetry for word
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
            local color="${full_pattern[$(( ((j - 1) % ${#full_pattern[@]}) + 1 ))]}"
            result+="#${color}${wchar}"
        done
    elif [[ $SYMMETRY_MODE -eq 1 ]]; then
        # Mirror symmetry for word
        for ((j=1; j<=$word_len; j++)); do
            local wchar="${word:$((j-1)):1}"
            local pos=$j
            if [[ $j -gt $(( (word_len + 1) / 2 )) ]]; then
                pos=$(( word_len - j + 1 ))
            fi
            local color="${pattern_ref[$(( ((pos - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="#${color}${wchar}"
        done
    else
        # No symmetry
        for ((j=1; j<=$word_len; j++)); do
            local wchar="${word:$((j-1)):1}"
            local color="${pattern_ref[$(( ((j - 1) % ${#pattern_ref[@]}) + 1 ))]}"
            result+="#${color}${wchar}"
        done
    fi

    echo -n "$result"
}
