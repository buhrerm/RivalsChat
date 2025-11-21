#!/usr/bin/env zsh

# config.zsh - Configuration file management
# Handles reading and writing configuration and pattern files

source "${0:A:h}/../state/app_state.zsh"
source "${0:A:h}/constants.zsh"

# Initialize configuration directory
config_init() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi

    if [[ ! -f "$PATTERNS_FILE" ]]; then
        echo '{"patterns": {}}' > "$PATTERNS_FILE"
    fi
}

# Load patterns from built-ins and file
config_load_patterns() {
    ALL_PATTERNS=()
    ALL_ICONS=()
    PATTERN_ORDER=()

    # Load built-in patterns first
    for name in Rainbow Warm Cool Neon Sunset Ocean Psychedelic Spring Cherry Matrix; do
        ALL_PATTERNS[$name]="${BUILTIN_PATTERNS[$name]}"
        ALL_ICONS[$name]="${BUILTIN_ICONS[$name]}"
        PATTERN_ORDER+=("$name")
    done

    # Load custom patterns from file
    if [[ -f "$PATTERNS_FILE" ]] && command -v jq &>/dev/null; then
        local json=$(cat "$PATTERNS_FILE")
        local names=$(echo "$json" | jq -r '.patterns | keys[]' 2>/dev/null)

        while IFS= read -r name; do
            if [[ -n "$name" ]]; then
                local pattern=$(echo "$json" | jq -r ".patterns[\"$name\"].pattern" 2>/dev/null)
                local icon=$(echo "$json" | jq -r ".patterns[\"$name\"].icon" 2>/dev/null)

                if [[ -n "$pattern" ]]; then
                    ALL_PATTERNS[$name]="$pattern"
                    ALL_ICONS[$name]="${icon:-🎨}"
                    PATTERN_ORDER+=("$name")
                fi
            fi
        done <<< "$names"
    elif [[ -f "$PATTERNS_FILE" ]]; then
        # Fallback: simple text parsing if jq not available
        while IFS='|' read -r name pattern icon; do
            if [[ -n "$name" && -n "$pattern" ]]; then
                ALL_PATTERNS[$name]="$pattern"
                ALL_ICONS[$name]="${icon:-🎨}"
                PATTERN_ORDER+=("$name")
            fi
        done < <(grep -E '^[^#]' "$PATTERNS_FILE" 2>/dev/null || true)
    fi
}

# Save custom patterns to file
config_save_patterns() {
    local json='{"patterns": {'
    local first=1

    for name in "${PATTERN_ORDER[@]}"; do
        # Skip built-in patterns
        if [[ -n "${BUILTIN_PATTERNS[$name]}" ]]; then
            continue
        fi

        if [[ $first -eq 0 ]]; then
            json+=', '
        fi
        first=0

        local escaped_name=$(echo "$name" | sed 's/"/\\"/g')
        local escaped_pattern="${ALL_PATTERNS[$name]}"
        local escaped_icon="${ALL_ICONS[$name]}"

        json+="\"$escaped_name\": {\"pattern\": \"$escaped_pattern\", \"icon\": \"$escaped_icon\"}"
    done

    json+='}}'
    echo "$json" > "$PATTERNS_FILE"
}
