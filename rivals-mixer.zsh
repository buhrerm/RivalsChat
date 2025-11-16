#!/usr/bin/env zsh
# Marvel Rivals Pattern Mixer - Advanced Pattern Creation & Management
# Create, combine, and customize rainbow patterns with precision control

setopt extended_glob
setopt local_options
setopt local_traps

#########################
# Color Definitions     #
#########################

typeset -gA RIVALS_COLORS
RIVALS_COLORS=(
    [Y]="Gold"           [Y_CODE]=220
    [O]="Orange"         [O_CODE]=208
    [R]="Red"            [R_CODE]=196
    [P]="Pink"           [P_CODE]=213
    [M]="Really Pink"    [M_CODE]=201
    [U]="Purple"         [U_CODE]=141
    [B]="Blue"           [B_CODE]=75
    [I]="Dark Blue"      [I_CODE]=27
    [A]="Teal"           [A_CODE]=51
    [T]="Blue Green"     [T_CODE]=49
    [G]="Green"          [G_CODE]=46
    [E]="Green Yellow"   [E_CODE]=154
    [K]="Yellow"         [K_CODE]=226
)

typeset -ga COLOR_KEYS
COLOR_KEYS=(Y O R P M U B I A T G E K)

#########################
# Pattern Library       #
#########################

typeset -gA PATTERN_LIBRARY
typeset -gA PATTERN_DESCRIPTIONS

# Core Patterns
PATTERN_LIBRARY[full]="Y O R P M U B I A T G E K"
PATTERN_DESCRIPTIONS[full]="Complete rainbow spectrum - all 13 colors"

PATTERN_LIBRARY[warm]="Y O R P M"
PATTERN_DESCRIPTIONS[warm]="Warm colors - fiery and energetic"

PATTERN_LIBRARY[cool]="U B I A T G"
PATTERN_DESCRIPTIONS[cool]="Cool colors - calm and serene"

PATTERN_LIBRARY[wave]="Y O R P M U B I A T G E K E G T A I B U M P R O"
PATTERN_DESCRIPTIONS[wave]="Wave pattern - forward and backward"

PATTERN_LIBRARY[alternating]="Y R M B A G"
PATTERN_DESCRIPTIONS[alternating]="High contrast alternating colors"

# Holiday Themes
PATTERN_LIBRARY[christmas]="R G R G"
PATTERN_DESCRIPTIONS[christmas]="Christmas - red and green festive colors"

PATTERN_LIBRARY[halloween]="O P K O P K"
PATTERN_DESCRIPTIONS[halloween]="Halloween - orange, pink, and yellow spooky"

PATTERN_LIBRARY[valentines]="P R M P R M"
PATTERN_DESCRIPTIONS[valentines]="Valentine's Day - romantic pinks and reds"

PATTERN_LIBRARY[stpatricks]="G E G E"
PATTERN_DESCRIPTIONS[stpatricks]="St. Patrick's Day - lucky greens"

PATTERN_LIBRARY[4thofjuly]="R B R B"
PATTERN_DESCRIPTIONS[4thofjuly]="Independence Day - patriotic red and blue"

PATTERN_LIBRARY[easter]="P M U B"
PATTERN_DESCRIPTIONS[easter]="Easter - pastel celebration colors"

# Pride Patterns
PATTERN_LIBRARY[pride]="R O Y G B U"
PATTERN_DESCRIPTIONS[pride]="Pride - classic rainbow flag colors"

PATTERN_LIBRARY[trans]="B P B"
PATTERN_DESCRIPTIONS[trans]="Trans Pride - blue, pink, blue"

PATTERN_LIBRARY[bi]="P M U"
PATTERN_DESCRIPTIONS[bi]="Bisexual Pride - pink, magenta, purple"

PATTERN_LIBRARY[pan]="P Y B"
PATTERN_DESCRIPTIONS[pan]="Pansexual Pride - pink, yellow, blue"

PATTERN_LIBRARY[ace]="K P U"
PATTERN_DESCRIPTIONS[ace]="Asexual Pride - yellow, pink, purple"

PATTERN_LIBRARY[nb]="Y P U"
PATTERN_DESCRIPTIONS[nb]="Non-Binary Pride - yellow, pink, purple"

# Retro/Aesthetic Themes
PATTERN_LIBRARY[synthwave]="M U B A"
PATTERN_DESCRIPTIONS[synthwave]="Synthwave - retro 80s neon aesthetic"

PATTERN_LIBRARY[vaporwave]="P M U B A"
PATTERN_DESCRIPTIONS[vaporwave]="Vaporwave - nostalgic aesthetic vibes"

PATTERN_LIBRARY[cyberpunk]="P M B A"
PATTERN_DESCRIPTIONS[cyberpunk]="Cyberpunk - neon dystopian future"

PATTERN_LIBRARY[outrun]="M P O Y"
PATTERN_DESCRIPTIONS[outrun]="Outrun - vibrant sunset drive"

PATTERN_LIBRARY[matrix]="G E G E"
PATTERN_DESCRIPTIONS[matrix]="Matrix - digital rain effect greens"

PATTERN_LIBRARY[neon]="P M U B"
PATTERN_DESCRIPTIONS[neon]="Neon Lights - bright electric colors"

# Nature Themes
PATTERN_LIBRARY[sunset]="O R P M U"
PATTERN_DESCRIPTIONS[sunset]="Sunset - warm evening sky transition"

PATTERN_LIBRARY[sunrise]="Y O R P"
PATTERN_DESCRIPTIONS[sunrise]="Sunrise - morning dawn colors"

PATTERN_LIBRARY[ocean]="B I A T"
PATTERN_DESCRIPTIONS[ocean]="Ocean - deep water blues"

PATTERN_LIBRARY[forest]="G E T"
PATTERN_DESCRIPTIONS[forest]="Forest - natural woodland greens"

PATTERN_LIBRARY[fire]="Y O R M"
PATTERN_DESCRIPTIONS[fire]="Fire - burning flame colors"

PATTERN_LIBRARY[ice]="B I A"
PATTERN_DESCRIPTIONS[ice]="Ice - frozen crystal blues"

PATTERN_LIBRARY[galaxy]="U M P R O"
PATTERN_DESCRIPTIONS[galaxy]="Galaxy - cosmic space colors"

PATTERN_LIBRARY[aurora]="G B U M P"
PATTERN_DESCRIPTIONS[aurora]="Aurora Borealis - northern lights"

# Team Colors (Esports)
PATTERN_LIBRARY[team_blue]="B I A"
PATTERN_DESCRIPTIONS[team_blue]="Team Blue - competitive esports"

PATTERN_LIBRARY[team_red]="R O Y"
PATTERN_DESCRIPTIONS[team_red]="Team Red - competitive esports"

PATTERN_LIBRARY[team_green]="G E T"
PATTERN_DESCRIPTIONS[team_green]="Team Green - competitive esports"

PATTERN_LIBRARY[team_purple]="U M P"
PATTERN_DESCRIPTIONS[team_purple]="Team Purple - competitive esports"

# Monochrome Variations
PATTERN_LIBRARY[reds]="R O Y"
PATTERN_DESCRIPTIONS[reds]="Red Spectrum - warm monochrome"

PATTERN_LIBRARY[blues]="B I A T"
PATTERN_DESCRIPTIONS[blues]="Blue Spectrum - cool monochrome"

PATTERN_LIBRARY[greens]="G E T"
PATTERN_DESCRIPTIONS[greens]="Green Spectrum - nature monochrome"

PATTERN_LIBRARY[purples]="U M P"
PATTERN_DESCRIPTIONS[purples]="Purple Spectrum - royal monochrome"

# Special Effects
PATTERN_LIBRARY[strobe]="Y K Y K"
PATTERN_DESCRIPTIONS[strobe]="Strobe - high contrast flashing"

PATTERN_LIBRARY[pulse]="R P M U B I"
PATTERN_DESCRIPTIONS[pulse]="Pulse - rhythmic color wave"

PATTERN_LIBRARY[sparkle]="K Y O R P M U B I A T G E"
PATTERN_DESCRIPTIONS[sparkle]="Sparkle - bright shimmering effect"

#########################
# Configuration Storage #
#########################

CONFIG_DIR="${HOME}/.config/rivals"
PATTERNS_DIR="${CONFIG_DIR}/patterns"
TEMPLATES_DIR="${CONFIG_DIR}/templates"

init_config_dirs() {
    mkdir -p "$CONFIG_DIR" "$PATTERNS_DIR" "$TEMPLATES_DIR"
}

#########################
# Pattern Operations    #
#########################

# Mix two patterns with a specified ratio
mix_patterns() {
    local pattern1=$1
    local pattern2=$2
    local ratio1=${3:-50}
    local ratio2=$((100 - ratio1))

    local colors1=(${(z)PATTERN_LIBRARY[$pattern1]})
    local colors2=(${(z)PATTERN_LIBRARY[$pattern2]})

    if [[ -z "${colors1[*]}" ]] || [[ -z "${colors2[*]}" ]]; then
        echo "Error: Invalid pattern names" >&2
        return 1
    fi

    local result=()
    local total_len=$((ratio1 + ratio2))
    local chars1=$((ratio1 * 13 / 100))
    local chars2=$((ratio2 * 13 / 100))

    # Alternate between patterns based on ratio
    local idx1=1 idx2=1
    for ((i=0; i<chars1+chars2; i++)); do
        if [[ $i -lt $chars1 ]]; then
            result+=("${colors1[$(( (idx1 - 1) % ${#colors1[@]} + 1 ))]}")
            ((idx1++))
        else
            result+=("${colors2[$(( (idx2 - 1) % ${#colors2[@]} + 1 ))]}")
            ((idx2++))
        fi
    done

    echo "${result[*]}"
}

# Create a custom gradient between any number of colors
create_gradient() {
    local -a gradient_colors=("$@")
    local steps=${#gradient_colors[@]}

    if [[ $steps -lt 2 ]]; then
        echo "Error: Need at least 2 colors for gradient" >&2
        return 1
    fi

    # For simplicity, just interpolate between colors
    local result=()
    local colors_per_step=$((13 / (steps - 1)))

    for ((i=0; i<steps; i++)); do
        for ((j=0; j<colors_per_step; j++)); do
            result+=("${gradient_colors[$((i+1))]}")
        done
    done

    # Fill remaining with last color
    while [[ ${#result[@]} -lt 13 ]]; do
        result+=("${gradient_colors[-1]}")
    done

    echo "${result[*]}"
}

# Pattern sequencer - change patterns over text length
create_sequenced_pattern() {
    local -a sequences=("$@")
    local result=()

    for seq in "${sequences[@]}"; do
        local pattern_colors=(${(z)PATTERN_LIBRARY[$seq]})
        result+=("${pattern_colors[@]}")
    done

    echo "${result[*]}"
}

# Generate random pattern with constraints
generate_random_pattern() {
    local min_colors=${1:-5}
    local max_colors=${2:-13}
    local color_pool=${3:-"all"}

    local -a available_colors

    case $color_pool in
        warm)
            available_colors=(Y O R P M)
            ;;
        cool)
            available_colors=(U B I A T G)
            ;;
        bright)
            available_colors=(Y O R P M G E K)
            ;;
        dark)
            available_colors=(I B U)
            ;;
        *)
            available_colors=(${COLOR_KEYS[@]})
            ;;
    esac

    local num_colors=$((RANDOM % (max_colors - min_colors + 1) + min_colors))
    local -a result

    for ((i=0; i<num_colors; i++)); do
        local idx=$((RANDOM % ${#available_colors[@]} + 1))
        result+=("${available_colors[$idx]}")
    done

    echo "${result[*]}"
}

# Reverse a pattern
reverse_pattern() {
    local pattern=$1
    local colors=(${(z)PATTERN_LIBRARY[$pattern]})
    local reversed=(${(Oa)colors})
    echo "${reversed[*]}"
}

# Mirror a pattern (forward then reverse)
mirror_pattern() {
    local pattern=$1
    local colors=(${(z)PATTERN_LIBRARY[$pattern]})
    local reversed=(${(Oa)colors})
    echo "${colors[*]} ${reversed[*]}"
}

# Rotate a pattern by N positions
rotate_pattern() {
    local pattern=$1
    local positions=${2:-1}
    local colors=(${(z)PATTERN_LIBRARY[$pattern]})

    # Normalize positions
    positions=$((positions % ${#colors[@]}))
    if [[ $positions -lt 0 ]]; then
        positions=$((${#colors[@]} + positions))
    fi

    local -a result
    for ((i=0; i<${#colors[@]}; i++)); do
        local idx=$(( (i + positions) % ${#colors[@]} + 1 ))
        result+=("${colors[$idx]}")
    done

    echo "${result[*]}"
}

#########################
# Save/Load Patterns    #
#########################

save_pattern() {
    local name=$1
    local pattern=$2
    local description=${3:-"Custom pattern"}

    init_config_dirs

    local pattern_file="${PATTERNS_DIR}/${name}.pattern"

    cat > "$pattern_file" <<EOF
# Marvel Rivals Custom Pattern
# Name: $name
# Created: $(date)

PATTERN="$pattern"
DESCRIPTION="$description"
EOF

    echo "Pattern '$name' saved to $pattern_file"
}

load_pattern() {
    local name=$1
    local pattern_file="${PATTERNS_DIR}/${name}.pattern"

    if [[ ! -f "$pattern_file" ]]; then
        echo "Error: Pattern '$name' not found" >&2
        return 1
    fi

    source "$pattern_file"
    PATTERN_LIBRARY[$name]="$PATTERN"
    PATTERN_DESCRIPTIONS[$name]="$DESCRIPTION"

    echo "Pattern '$name' loaded: $PATTERN"
}

list_saved_patterns() {
    init_config_dirs

    echo "Saved Custom Patterns:"
    echo "====================="

    local found=0
    for pattern_file in "$PATTERNS_DIR"/*.pattern(N); do
        found=1
        local name="${pattern_file:t:r}"
        source "$pattern_file"
        printf "  %-20s %s\n" "$name" "$DESCRIPTION"
    done

    if [[ $found -eq 0 ]]; then
        echo "  No saved patterns found."
    fi
}

delete_pattern() {
    local name=$1
    local pattern_file="${PATTERNS_DIR}/${name}.pattern"

    if [[ -f "$pattern_file" ]]; then
        rm "$pattern_file"
        echo "Pattern '$name' deleted"
    else
        echo "Error: Pattern '$name' not found" >&2
        return 1
    fi
}

#########################
# Export/Import JSON    #
#########################

export_pattern_json() {
    local name=$1
    local pattern=$2
    local description=${3:-""}
    local output_file=${4:-"${name}.json"}

    cat > "$output_file" <<EOF
{
  "name": "$name",
  "pattern": "$pattern",
  "description": "$description",
  "version": "1.0",
  "created": "$(date -Iseconds)",
  "colors": [
$(
    local colors=(${(z)pattern})
    for i in {1..$#colors}; do
        local color="${colors[$i]}"
        local color_name="${RIVALS_COLORS[$color]}"
        local color_code="${RIVALS_COLORS[${color}_CODE]}"
        printf '    { "code": "%s", "name": "%s", "ansi": %d }' "$color" "$color_name" "$color_code"
        [[ $i -lt ${#colors[@]} ]] && echo "," || echo ""
    done
)
  ]
}
EOF

    echo "Pattern exported to $output_file"
}

import_pattern_json() {
    local json_file=$1

    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file not found" >&2
        return 1
    fi

    # Simple JSON parsing (requires jq if available)
    if command -v jq &>/dev/null; then
        local name=$(jq -r '.name' "$json_file")
        local pattern=$(jq -r '.pattern' "$json_file")
        local description=$(jq -r '.description' "$json_file")

        PATTERN_LIBRARY[$name]="$pattern"
        PATTERN_DESCRIPTIONS[$name]="$description"

        echo "Pattern '$name' imported successfully"
        echo "Pattern: $pattern"
    else
        echo "Error: jq is required for JSON import" >&2
        return 1
    fi
}

#########################
# Text Conversion       #
#########################

convert_with_pattern() {
    local text=$1
    local pattern_name=$2
    local mode=${3:-"char"}  # char or word

    local pattern="${PATTERN_LIBRARY[$pattern_name]}"
    if [[ -z "$pattern" ]]; then
        echo "Error: Pattern '$pattern_name' not found" >&2
        return 1
    fi

    local colors=(${(z)pattern})
    local result=""
    local color_idx=0

    if [[ "$mode" == "word" ]]; then
        # Word-based coloring
        local words=(${(z)text})
        for word in "${words[@]}"; do
            local color="${colors[$(( color_idx % ${#colors[@]} + 1 ))]}"
            result+="#${color}${word} "
            ((color_idx++))
        done
        result="${result% }"  # Remove trailing space
    else
        # Character-based coloring
        for ((i=1; i<=${#text}; i++)); do
            local char="${text[$i]}"
            if [[ "$char" == " " ]]; then
                result+=" "
            else
                local color="${colors[$(( color_idx % ${#colors[@]} + 1 ))]}"
                result+="#${color}${char}"
                ((color_idx++))
            fi
        done
    fi

    echo "$result"
}

# Preview pattern with ANSI colors
preview_pattern() {
    local pattern_name=$1
    local text=${2:-"Marvel Rivals Rainbow"}

    local pattern="${PATTERN_LIBRARY[$pattern_name]}"
    if [[ -z "$pattern" ]]; then
        echo "Error: Pattern '$pattern_name' not found" >&2
        return 1
    fi

    local colors=(${(z)pattern})
    local result=""
    local color_idx=0

    for ((i=1; i<=${#text}; i++)); do
        local char="${text[$i]}"
        if [[ "$char" != " " ]]; then
            local color="${colors[$(( color_idx % ${#colors[@]} + 1 ))]}"
            local ansi_code="${RIVALS_COLORS[${color}_CODE]}"
            result+="\e[38;5;${ansi_code}m${char}\e[0m"
            ((color_idx++))
        else
            result+=" "
        fi
    done

    echo -e "$result"
}

#########################
# Interactive Editor    #
#########################

launch_pattern_editor() {
    echo -e "\n\e[1m=== MARVEL RIVALS PATTERN EDITOR ===\e[0m\n"

    local editing=true
    local current_pattern=()

    while $editing; do
        echo "Current Pattern: ${current_pattern[*]}"
        if [[ ${#current_pattern[@]} -gt 0 ]]; then
            local preview_text="Sample Preview"
            local preview=""
            for ((i=0; i<${#preview_text}; i++)); do
                local char="${preview_text:$i:1}"
                if [[ "$char" != " " ]]; then
                    local color="${current_pattern[$(( i % ${#current_pattern[@]} + 1 ))]}"
                    local ansi_code="${RIVALS_COLORS[${color}_CODE]}"
                    preview+="\e[38;5;${ansi_code}m${char}\e[0m"
                else
                    preview+=" "
                fi
            done
            echo -e "Preview: $preview"
        fi

        echo ""
        echo "Commands:"
        echo "  [color] - Add color (Y,O,R,P,M,U,B,I,A,T,G,E,K)"
        echo "  [d]     - Delete last color"
        echo "  [c]     - Clear pattern"
        echo "  [s]     - Save pattern"
        echo "  [t]     - Test with custom text"
        echo "  [q]     - Quit editor"
        echo ""
        echo -n "Command: "
        read -k 1 cmd
        echo ""

        case "${cmd:u}" in
            Y|O|R|P|M|U|B|I|A|T|G|E|K)
                current_pattern+=("$cmd")
                echo "Added $cmd (${RIVALS_COLORS[$cmd]})"
                ;;
            D)
                if [[ ${#current_pattern[@]} -gt 0 ]]; then
                    current_pattern=("${current_pattern[@]:0:${#current_pattern[@]}-1}")
                    echo "Deleted last color"
                else
                    echo "Pattern is empty"
                fi
                ;;
            C)
                current_pattern=()
                echo "Pattern cleared"
                ;;
            S)
                echo -n "Pattern name: "
                read pattern_name
                echo -n "Description: "
                read pattern_desc
                save_pattern "$pattern_name" "${current_pattern[*]}" "$pattern_desc"
                ;;
            T)
                echo -n "Test text: "
                read test_text
                local temp_name="temp_$$"
                PATTERN_LIBRARY[$temp_name]="${current_pattern[*]}"
                echo -n "Preview: "
                preview_pattern "$temp_name" "$test_text"
                echo "Rivals Code: $(convert_with_pattern "$test_text" "$temp_name")"
                unset "PATTERN_LIBRARY[$temp_name]"
                ;;
            Q)
                editing=false
                ;;
            *)
                echo "Invalid command"
                ;;
        esac

        echo ""
    done

    echo "Editor closed."
}

#########################
# CLI Interface         #
#########################

show_help() {
    cat <<'EOF'
Marvel Rivals Pattern Mixer - Advanced Pattern Creation

USAGE:
    rivals-mixer.zsh [command] [options]

COMMANDS:
    list                           List all available patterns
    preview <pattern> [text]       Preview pattern with sample text
    convert <pattern> <text>       Convert text with pattern
    mix <p1> <p2> [ratio]         Mix two patterns (default 50/50)
    gradient <c1> <c2> [c3...]    Create gradient pattern
    sequence <p1> <p2> [p3...]    Combine patterns in sequence
    random [min] [max] [pool]      Generate random pattern
    reverse <pattern>              Reverse a pattern
    mirror <pattern>               Mirror a pattern
    rotate <pattern> [n]           Rotate pattern by n positions

    save <name> <pattern> [desc]   Save custom pattern
    load <name>                    Load custom pattern
    delete <name>                  Delete custom pattern
    saved                          List saved patterns

    export <name> [file]           Export pattern to JSON
    import <file>                  Import pattern from JSON

    editor                         Launch interactive pattern editor

EXAMPLES:
    rivals-mixer.zsh list
    rivals-mixer.zsh preview synthwave "Neon Dreams"
    rivals-mixer.zsh mix warm cool 60
    rivals-mixer.zsh gradient Y M U
    rivals-mixer.zsh random 5 10 bright
    rivals-mixer.zsh save mystic "Y U M P B" "Custom mystic colors"

COLOR CODES:
    Y=Gold  O=Orange  R=Red  P=Pink  M=Really Pink  U=Purple
    B=Blue  I=Dark Blue  A=Teal  T=Blue Green  G=Green
    E=Green Yellow  K=Yellow

PATTERN CATEGORIES:
    Core: full, warm, cool, wave, alternating
    Holiday: christmas, halloween, valentines, stpatricks, 4thofjuly
    Pride: pride, trans, bi, pan, ace, nb
    Retro: synthwave, vaporwave, cyberpunk, outrun, matrix, neon
    Nature: sunset, sunrise, ocean, forest, fire, ice, galaxy, aurora
    Teams: team_blue, team_red, team_green, team_purple

EOF
}

list_all_patterns() {
    echo -e "\n\e[1m=== AVAILABLE PATTERNS ===\e[0m\n"

    local -a categories
    categories=(
        "Core Patterns"
        "Holiday Themes"
        "Pride Patterns"
        "Retro/Aesthetic"
        "Nature Themes"
        "Team Colors"
        "Monochrome"
        "Special Effects"
    )

    local -A category_patterns
    category_patterns=(
        ["Core Patterns"]="full warm cool wave alternating"
        ["Holiday Themes"]="christmas halloween valentines stpatricks 4thofjuly easter"
        ["Pride Patterns"]="pride trans bi pan ace nb"
        ["Retro/Aesthetic"]="synthwave vaporwave cyberpunk outrun matrix neon"
        ["Nature Themes"]="sunset sunrise ocean forest fire ice galaxy aurora"
        ["Team Colors"]="team_blue team_red team_green team_purple"
        ["Monochrome"]="reds blues greens purples"
        ["Special Effects"]="strobe pulse sparkle"
    )

    for category in "${categories[@]}"; do
        echo -e "\e[1;36m$category:\e[0m"
        local patterns=(${(z)category_patterns[$category]})
        for pattern in $patterns; do
            printf "  %-15s : %s\n" "$pattern" "${PATTERN_DESCRIPTIONS[$pattern]}"
            printf "  %-15s   " ""
            preview_pattern "$pattern" "Sample"
            echo ""
        done
        echo ""
    done
}

#########################
# Main Entry Point      #
#########################

main() {
    local command=${1:-help}
    shift

    case "$command" in
        help|--help|-h)
            show_help
            ;;
        list)
            list_all_patterns
            ;;
        preview)
            preview_pattern "$1" "${2:-Marvel Rivals Rainbow}"
            ;;
        convert)
            convert_with_pattern "$2" "$1"
            ;;
        mix)
            local result=$(mix_patterns "$1" "$2" "${3:-50}")
            echo "Mixed Pattern: $result"
            PATTERN_LIBRARY[mixed]="$result"
            preview_pattern mixed "Sample Mix"
            ;;
        gradient)
            local result=$(create_gradient "$@")
            echo "Gradient Pattern: $result"
            PATTERN_LIBRARY[gradient_custom]="$result"
            preview_pattern gradient_custom "Gradient Sample"
            ;;
        sequence)
            local result=$(create_sequenced_pattern "$@")
            echo "Sequenced Pattern: $result"
            PATTERN_LIBRARY[sequenced]="$result"
            preview_pattern sequenced "Sequenced Sample"
            ;;
        random)
            local result=$(generate_random_pattern "$@")
            echo "Random Pattern: $result"
            PATTERN_LIBRARY[random_gen]="$result"
            preview_pattern random_gen "Random Sample"
            ;;
        reverse)
            local result=$(reverse_pattern "$1")
            echo "Reversed Pattern: $result"
            PATTERN_LIBRARY[reversed]="$result"
            preview_pattern reversed "Reversed Sample"
            ;;
        mirror)
            local result=$(mirror_pattern "$1")
            echo "Mirrored Pattern: $result"
            PATTERN_LIBRARY[mirrored]="$result"
            preview_pattern mirrored "Mirrored Sample"
            ;;
        rotate)
            local result=$(rotate_pattern "$1" "${2:-1}")
            echo "Rotated Pattern: $result"
            PATTERN_LIBRARY[rotated]="$result"
            preview_pattern rotated "Rotated Sample"
            ;;
        save)
            save_pattern "$@"
            ;;
        load)
            load_pattern "$1"
            ;;
        delete)
            delete_pattern "$1"
            ;;
        saved)
            list_saved_patterns
            ;;
        export)
            local pattern="${PATTERN_LIBRARY[$1]}"
            export_pattern_json "$1" "$pattern" "${PATTERN_DESCRIPTIONS[$1]}" "${2:-$1.json}"
            ;;
        import)
            import_pattern_json "$1"
            ;;
        editor)
            launch_pattern_editor
            ;;
        *)
            echo "Unknown command: $command"
            echo "Use 'rivals-mixer.zsh help' for usage information"
            return 1
            ;;
    esac
}

# Run if executed directly
if [[ "${(%):-%N}" == "${0}" ]] || [[ "${0}" == *"rivals-mixer.zsh" ]]; then
    main "$@"
fi
