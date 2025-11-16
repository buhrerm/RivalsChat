#!/usr/bin/env zsh
# Marvel Rivals Theme System - Complete UI Customization
# Customize colors, layouts, fonts, and create shareable themes

setopt extended_glob
setopt local_options
setopt local_traps

#########################
# Theme Configuration   #
#########################

CONFIG_DIR="${HOME}/.config/rivals"
THEMES_DIR="${CONFIG_DIR}/themes"
CACHE_DIR="${CONFIG_DIR}/cache"

# Initialize directories
init_theme_dirs() {
    mkdir -p "$CONFIG_DIR" "$THEMES_DIR" "$CACHE_DIR"
}

#########################
# Default Themes        #
#########################

typeset -gA THEMES

# Dark Theme (Default)
THEMES[dark]='
THEME_NAME="Dark"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=24
HEADER_FG=15
SIDEBAR_BG=236
SIDEBAR_FG=252
SIDEBAR_SELECTED_BG=240
SIDEBAR_SELECTED_FG=15
PREVIEW_BG=232
PREVIEW_FG=15
INPUT_BG=234
INPUT_FG=15
STATUS_BG=240
STATUS_FG=15
BORDER=240
ACCENT=33
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# Light Theme
THEMES[light]='
THEME_NAME="Light"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=255
HEADER_FG=0
SIDEBAR_BG=254
SIDEBAR_FG=235
SIDEBAR_SELECTED_BG=250
SIDEBAR_SELECTED_FG=0
PREVIEW_BG=255
PREVIEW_FG=0
INPUT_BG=253
INPUT_FG=0
STATUS_BG=250
STATUS_FG=0
BORDER=248
ACCENT=27
ERROR=160
SUCCESS=28
WARNING=172
INFO=24

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# High Contrast Theme
THEMES[high_contrast]='
THEME_NAME="High Contrast"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=0
HEADER_FG=15
SIDEBAR_BG=0
SIDEBAR_FG=15
SIDEBAR_SELECTED_BG=15
SIDEBAR_SELECTED_FG=0
PREVIEW_BG=0
PREVIEW_FG=15
INPUT_BG=0
INPUT_FG=15
STATUS_BG=15
STATUS_FG=0
BORDER=15
ACCENT=11
ERROR=9
SUCCESS=10
WARNING=11
INFO=14

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=0
USE_DIM_BORDERS=0

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# Cyberpunk Theme
THEMES[cyberpunk]='
THEME_NAME="Cyberpunk"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=53
HEADER_FG=201
SIDEBAR_BG=16
SIDEBAR_FG=51
SIDEBAR_SELECTED_BG=53
SIDEBAR_SELECTED_FG=201
PREVIEW_BG=16
PREVIEW_FG=201
INPUT_BG=16
INPUT_FG=51
STATUS_BG=53
STATUS_FG=201
BORDER=201
ACCENT=201
ERROR=196
SUCCESS=51
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=32
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=0

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=50
'

# Synthwave Theme
THEMES[synthwave]='
THEME_NAME="Synthwave"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=53
HEADER_FG=219
SIDEBAR_BG=16
SIDEBAR_FG=213
SIDEBAR_SELECTED_BG=53
SIDEBAR_SELECTED_FG=219
PREVIEW_BG=16
PREVIEW_FG=219
INPUT_BG=17
INPUT_FG=213
STATUS_BG=53
STATUS_FG=219
BORDER=141
ACCENT=213
ERROR=196
SUCCESS=51
WARNING=220
INFO=141

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=0

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=100
'

# Ocean Theme
THEMES[ocean]='
THEME_NAME="Ocean"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=24
HEADER_FG=159
SIDEBAR_BG=17
SIDEBAR_FG=117
SIDEBAR_SELECTED_BG=24
SIDEBAR_SELECTED_FG=159
PREVIEW_BG=17
PREVIEW_FG=159
INPUT_BG=17
INPUT_FG=117
STATUS_BG=24
STATUS_FG=159
BORDER=31
ACCENT=51
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# Forest Theme
THEMES[forest]='
THEME_NAME="Forest"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=22
HEADER_FG=228
SIDEBAR_BG=16
SIDEBAR_FG=150
SIDEBAR_SELECTED_BG=22
SIDEBAR_SELECTED_FG=228
PREVIEW_BG=16
PREVIEW_FG=228
INPUT_BG=16
INPUT_FG=150
STATUS_BG=22
STATUS_FG=228
BORDER=28
ACCENT=46
ERROR=196
SUCCESS=46
WARNING=220
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# Sunset Theme
THEMES[sunset]='
THEME_NAME="Sunset"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=166
HEADER_FG=231
SIDEBAR_BG=52
SIDEBAR_FG=223
SIDEBAR_SELECTED_BG=166
SIDEBAR_SELECTED_FG=231
PREVIEW_BG=52
PREVIEW_FG=231
INPUT_BG=52
INPUT_FG=223
STATUS_BG=166
STATUS_FG=231
BORDER=208
ACCENT=214
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

# Minimal Theme
THEMES[minimal]='
THEME_NAME="Minimal"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=239
HEADER_FG=255
SIDEBAR_BG=234
SIDEBAR_FG=250
SIDEBAR_SELECTED_BG=238
SIDEBAR_SELECTED_FG=255
PREVIEW_BG=233
PREVIEW_FG=255
INPUT_BG=233
INPUT_FG=250
STATUS_BG=239
STATUS_FG=255
BORDER=238
ACCENT=245
ERROR=203
SUCCESS=114
WARNING=221
INFO=117

# Layout
SIDEBAR_WIDTH=25
PREVIEW_HEIGHT=8
INPUT_HEIGHT=10
PADDING=1

# Typography
USE_BOLD_HEADERS=0
USE_ITALIC_HINTS=0
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=0
ANIMATION_SPEED=0
'

# Compact Theme
THEMES[compact]='
THEME_NAME="Compact"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=235
HEADER_FG=15
SIDEBAR_BG=234
SIDEBAR_FG=252
SIDEBAR_SELECTED_BG=238
SIDEBAR_SELECTED_FG=15
PREVIEW_BG=232
PREVIEW_FG=15
INPUT_BG=233
INPUT_FG=15
STATUS_BG=238
STATUS_FG=15
BORDER=238
ACCENT=33
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=22
PREVIEW_HEIGHT=6
INPUT_HEIGHT=8
PADDING=1

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=0
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=0
ANIMATION_SPEED=0
'

# Matrix Theme
THEMES[matrix]='
THEME_NAME="Matrix"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=0
HEADER_FG=46
SIDEBAR_BG=0
SIDEBAR_FG=40
SIDEBAR_SELECTED_BG=22
SIDEBAR_SELECTED_FG=46
PREVIEW_BG=0
PREVIEW_FG=46
INPUT_BG=0
INPUT_FG=40
STATUS_BG=22
STATUS_FG=46
BORDER=40
ACCENT=46
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=0
USE_DIM_BORDERS=0

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=150
'

# Vaporwave Theme
THEMES[vaporwave]='
THEME_NAME="Vaporwave"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=225
HEADER_FG=177
SIDEBAR_BG=189
SIDEBAR_FG=99
SIDEBAR_SELECTED_BG=219
SIDEBAR_SELECTED_FG=135
PREVIEW_BG=189
PREVIEW_FG=135
INPUT_BG=225
INPUT_FG=99
STATUS_BG=219
STATUS_FG=177
BORDER=183
ACCENT=177
ERROR=196
SUCCESS=121
WARNING=226
INFO=123

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=0

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=75
'

# Monochrome Theme
THEMES[monochrome]='
THEME_NAME="Monochrome"
THEME_AUTHOR="Rivals Team"
THEME_VERSION="1.0"

# UI Colors
HEADER_BG=0
HEADER_FG=15
SIDEBAR_BG=232
SIDEBAR_FG=250
SIDEBAR_SELECTED_BG=238
SIDEBAR_SELECTED_FG=15
PREVIEW_BG=232
PREVIEW_FG=15
INPUT_BG=233
INPUT_FG=15
STATUS_BG=238
STATUS_FG=15
BORDER=240
ACCENT=248
ERROR=243
SUCCESS=250
WARNING=246
INFO=245

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=0
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
'

#########################
# Theme Management      #
#########################

# Load a theme
load_theme() {
    local theme_name=$1

    # Check built-in themes first
    if [[ -n "${THEMES[$theme_name]}" ]]; then
        eval "${THEMES[$theme_name]}"
        export CURRENT_THEME="$theme_name"
        save_active_theme "$theme_name"
        return 0
    fi

    # Check custom themes
    local theme_file="${THEMES_DIR}/${theme_name}.theme"
    if [[ -f "$theme_file" ]]; then
        source "$theme_file"
        export CURRENT_THEME="$theme_name"
        save_active_theme "$theme_name"
        return 0
    fi

    echo "Error: Theme '$theme_name' not found" >&2
    return 1
}

# Save current theme as active
save_active_theme() {
    local theme_name=$1
    init_theme_dirs
    echo "$theme_name" > "${CONFIG_DIR}/active_theme"
}

# Get active theme
get_active_theme() {
    local theme_file="${CONFIG_DIR}/active_theme"
    if [[ -f "$theme_file" ]]; then
        cat "$theme_file"
    else
        echo "dark"
    fi
}

# Create custom theme
create_theme() {
    local theme_name=$1

    echo -e "\n\e[1m=== CREATE CUSTOM THEME: $theme_name ===\e[0m\n"

    # Default values
    local header_bg=24 header_fg=15
    local sidebar_bg=236 sidebar_fg=252
    local sidebar_sel_bg=240 sidebar_sel_fg=15
    local preview_bg=232 preview_fg=15
    local input_bg=234 input_fg=15
    local status_bg=240 status_fg=15
    local border=240 accent=33

    echo "Theme Wizard - Press Enter to use default values"
    echo ""

    echo -n "Header Background Color [$header_bg]: "
    read input
    [[ -n "$input" ]] && header_bg=$input

    echo -n "Header Foreground Color [$header_fg]: "
    read input
    [[ -n "$input" ]] && header_fg=$input

    echo -n "Sidebar Background Color [$sidebar_bg]: "
    read input
    [[ -n "$input" ]] && sidebar_bg=$input

    echo -n "Sidebar Foreground Color [$sidebar_fg]: "
    read input
    [[ -n "$input" ]] && sidebar_fg=$input

    echo -n "Border Color [$border]: "
    read input
    [[ -n "$input" ]] && border=$input

    echo -n "Accent Color [$accent]: "
    read input
    [[ -n "$input" ]] && accent=$input

    echo -n "Theme Description: "
    read theme_desc

    init_theme_dirs
    local theme_file="${THEMES_DIR}/${theme_name}.theme"

    cat > "$theme_file" <<EOF
# Marvel Rivals Custom Theme: $theme_name
# Created: $(date)
# Description: $theme_desc

THEME_NAME="$theme_name"
THEME_AUTHOR="$USER"
THEME_VERSION="1.0"
THEME_DESCRIPTION="$theme_desc"

# UI Colors
HEADER_BG=$header_bg
HEADER_FG=$header_fg
SIDEBAR_BG=$sidebar_bg
SIDEBAR_FG=$sidebar_fg
SIDEBAR_SELECTED_BG=$sidebar_sel_bg
SIDEBAR_SELECTED_FG=$sidebar_sel_fg
PREVIEW_BG=$preview_bg
PREVIEW_FG=$preview_fg
INPUT_BG=$input_bg
INPUT_FG=$input_fg
STATUS_BG=$status_bg
STATUS_FG=$status_fg
BORDER=$border
ACCENT=$accent
ERROR=196
SUCCESS=46
WARNING=226
INFO=51

# Layout
SIDEBAR_WIDTH=30
PREVIEW_HEIGHT=10
INPUT_HEIGHT=12
PADDING=2

# Typography
USE_BOLD_HEADERS=1
USE_ITALIC_HINTS=1
USE_DIM_BORDERS=1

# Behavior
AUTO_COPY=1
SHOW_LIVE_PREVIEW=1
SHOW_COLOR_CODES=1
ANIMATION_SPEED=0
EOF

    echo -e "\n\e[32m✓\e[0m Theme '$theme_name' created and saved!"
    echo "File: $theme_file"
}

# List all themes
list_themes() {
    echo -e "\n\e[1m=== AVAILABLE THEMES ===\e[0m\n"

    echo -e "\e[1mBuilt-in Themes:\e[0m"
    for theme_name in ${(k)THEMES}; do
        eval "${THEMES[$theme_name]}"
        local indicator=""
        [[ "$(get_active_theme)" == "$theme_name" ]] && indicator=" \e[32m★\e[0m"
        printf "  %-20s : %s%s\n" "$theme_name" "$THEME_NAME" "$indicator"
    done

    echo ""
    echo -e "\e[1mCustom Themes:\e[0m"
    local found=0
    for theme_file in "$THEMES_DIR"/*.theme(N); do
        found=1
        local name="${theme_file:t:r}"
        source "$theme_file"
        local indicator=""
        [[ "$(get_active_theme)" == "$name" ]] && indicator=" \e[32m★\e[0m"
        printf "  %-20s : %s%s\n" "$name" "${THEME_NAME:-Custom Theme}" "$indicator"
    done

    if [[ $found -eq 0 ]]; then
        echo "  No custom themes found."
    fi

    echo ""
    echo "★ = Currently active theme"
}

# Preview theme
preview_theme() {
    local theme_name=$1

    if [[ -z "${THEMES[$theme_name]}" ]]; then
        local theme_file="${THEMES_DIR}/${theme_name}.theme"
        if [[ ! -f "$theme_file" ]]; then
            echo "Error: Theme '$theme_name' not found" >&2
            return 1
        fi
        source "$theme_file"
    else
        eval "${THEMES[$theme_name]}"
    fi

    echo -e "\n\e[1m=== THEME PREVIEW: $THEME_NAME ===\e[0m\n"

    # Show color swatches
    echo "Header:"
    echo -ne "  BG: \e[48;5;${HEADER_BG}m    \e[0m  FG: \e[38;5;${HEADER_FG}m████\e[0m\n"

    echo "Sidebar:"
    echo -ne "  BG: \e[48;5;${SIDEBAR_BG}m    \e[0m  FG: \e[38;5;${SIDEBAR_FG}m████\e[0m\n"
    echo -ne "  Selected BG: \e[48;5;${SIDEBAR_SELECTED_BG}m    \e[0m  FG: \e[38;5;${SIDEBAR_SELECTED_FG}m████\e[0m\n"

    echo "Preview Area:"
    echo -ne "  BG: \e[48;5;${PREVIEW_BG}m    \e[0m  FG: \e[38;5;${PREVIEW_FG}m████\e[0m\n"

    echo "Input Area:"
    echo -ne "  BG: \e[48;5;${INPUT_BG}m    \e[0m  FG: \e[38;5;${INPUT_FG}m████\e[0m\n"

    echo "Status Bar:"
    echo -ne "  BG: \e[48;5;${STATUS_BG}m    \e[0m  FG: \e[38;5;${STATUS_FG}m████\e[0m\n"

    echo "Accents:"
    echo -ne "  Border: \e[38;5;${BORDER}m████\e[0m  Accent: \e[38;5;${ACCENT}m████\e[0m\n"
    echo -ne "  Error: \e[38;5;${ERROR}m████\e[0m  Success: \e[38;5;${SUCCESS}m████\e[0m  Warning: \e[38;5;${WARNING}m████\e[0m\n"

    echo ""
    echo "Layout Settings:"
    echo "  Sidebar Width: $SIDEBAR_WIDTH"
    echo "  Preview Height: $PREVIEW_HEIGHT"
    echo "  Input Height: $INPUT_HEIGHT"
    echo ""
}

# Delete theme
delete_theme() {
    local theme_name=$1

    if [[ -n "${THEMES[$theme_name]}" ]]; then
        echo "Error: Cannot delete built-in theme" >&2
        return 1
    fi

    local theme_file="${THEMES_DIR}/${theme_name}.theme"
    if [[ -f "$theme_file" ]]; then
        rm "$theme_file"
        echo "Theme '$theme_name' deleted"
    else
        echo "Error: Theme '$theme_name' not found" >&2
        return 1
    fi
}

# Export theme to JSON
export_theme() {
    local theme_name=$1
    local output_file=${2:-"${theme_name}.theme.json"}

    if [[ -z "${THEMES[$theme_name]}" ]]; then
        local theme_file="${THEMES_DIR}/${theme_name}.theme"
        if [[ ! -f "$theme_file" ]]; then
            echo "Error: Theme '$theme_name' not found" >&2
            return 1
        fi
        source "$theme_file"
    else
        eval "${THEMES[$theme_name]}"
    fi

    cat > "$output_file" <<EOF
{
  "theme": {
    "name": "$THEME_NAME",
    "version": "$THEME_VERSION",
    "author": "${THEME_AUTHOR:-Unknown}",
    "description": "${THEME_DESCRIPTION:-}",
    "created": "$(date -Iseconds)"
  },
  "colors": {
    "header": {
      "background": $HEADER_BG,
      "foreground": $HEADER_FG
    },
    "sidebar": {
      "background": $SIDEBAR_BG,
      "foreground": $SIDEBAR_FG,
      "selectedBackground": $SIDEBAR_SELECTED_BG,
      "selectedForeground": $SIDEBAR_SELECTED_FG
    },
    "preview": {
      "background": $PREVIEW_BG,
      "foreground": $PREVIEW_FG
    },
    "input": {
      "background": $INPUT_BG,
      "foreground": $INPUT_FG
    },
    "status": {
      "background": $STATUS_BG,
      "foreground": $STATUS_FG
    },
    "ui": {
      "border": $BORDER,
      "accent": $ACCENT,
      "error": $ERROR,
      "success": $SUCCESS,
      "warning": $WARNING,
      "info": $INFO
    }
  },
  "layout": {
    "sidebarWidth": $SIDEBAR_WIDTH,
    "previewHeight": $PREVIEW_HEIGHT,
    "inputHeight": $INPUT_HEIGHT,
    "padding": $PADDING
  },
  "typography": {
    "boldHeaders": $USE_BOLD_HEADERS,
    "italicHints": $USE_ITALIC_HINTS,
    "dimBorders": $USE_DIM_BORDERS
  },
  "behavior": {
    "autoCopy": $AUTO_COPY,
    "livePreview": $SHOW_LIVE_PREVIEW,
    "showColorCodes": $SHOW_COLOR_CODES,
    "animationSpeed": $ANIMATION_SPEED
  }
}
EOF

    echo "Theme exported to $output_file"
}

# Import theme from JSON
import_theme() {
    local json_file=$1
    local theme_name=${2:-$(basename "$json_file" .theme.json)}

    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file not found" >&2
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "Error: jq is required for JSON import" >&2
        return 1
    fi

    init_theme_dirs
    local theme_file="${THEMES_DIR}/${theme_name}.theme"

    # Extract values using jq
    local name=$(jq -r '.theme.name' "$json_file")
    local version=$(jq -r '.theme.version' "$json_file")
    local author=$(jq -r '.theme.author' "$json_file")
    local description=$(jq -r '.theme.description' "$json_file")

    cat > "$theme_file" <<EOF
# Marvel Rivals Theme: $name (Imported)
# Author: $author
# Version: $version
# Description: $description

THEME_NAME="$name"
THEME_VERSION="$version"
THEME_AUTHOR="$author"
THEME_DESCRIPTION="$description"

# UI Colors
HEADER_BG=$(jq -r '.colors.header.background' "$json_file")
HEADER_FG=$(jq -r '.colors.header.foreground' "$json_file")
SIDEBAR_BG=$(jq -r '.colors.sidebar.background' "$json_file")
SIDEBAR_FG=$(jq -r '.colors.sidebar.foreground' "$json_file")
SIDEBAR_SELECTED_BG=$(jq -r '.colors.sidebar.selectedBackground' "$json_file")
SIDEBAR_SELECTED_FG=$(jq -r '.colors.sidebar.selectedForeground' "$json_file")
PREVIEW_BG=$(jq -r '.colors.preview.background' "$json_file")
PREVIEW_FG=$(jq -r '.colors.preview.foreground' "$json_file")
INPUT_BG=$(jq -r '.colors.input.background' "$json_file")
INPUT_FG=$(jq -r '.colors.input.foreground' "$json_file")
STATUS_BG=$(jq -r '.colors.status.background' "$json_file")
STATUS_FG=$(jq -r '.colors.status.foreground' "$json_file")
BORDER=$(jq -r '.colors.ui.border' "$json_file")
ACCENT=$(jq -r '.colors.ui.accent' "$json_file")
ERROR=$(jq -r '.colors.ui.error' "$json_file")
SUCCESS=$(jq -r '.colors.ui.success' "$json_file")
WARNING=$(jq -r '.colors.ui.warning' "$json_file")
INFO=$(jq -r '.colors.ui.info' "$json_file")

# Layout
SIDEBAR_WIDTH=$(jq -r '.layout.sidebarWidth' "$json_file")
PREVIEW_HEIGHT=$(jq -r '.layout.previewHeight' "$json_file")
INPUT_HEIGHT=$(jq -r '.layout.inputHeight' "$json_file")
PADDING=$(jq -r '.layout.padding' "$json_file")

# Typography
USE_BOLD_HEADERS=$(jq -r '.typography.boldHeaders' "$json_file")
USE_ITALIC_HINTS=$(jq -r '.typography.italicHints' "$json_file")
USE_DIM_BORDERS=$(jq -r '.typography.dimBorders' "$json_file")

# Behavior
AUTO_COPY=$(jq -r '.behavior.autoCopy' "$json_file")
SHOW_LIVE_PREVIEW=$(jq -r '.behavior.livePreview' "$json_file")
SHOW_COLOR_CODES=$(jq -r '.behavior.showColorCodes' "$json_file")
ANIMATION_SPEED=$(jq -r '.behavior.animationSpeed' "$json_file")
EOF

    echo "Theme '$theme_name' imported successfully!"
}

#########################
# Auto Theme Scheduler  #
#########################

get_time_based_theme() {
    local hour=$(date +%H)

    if [[ $hour -ge 6 && $hour -lt 9 ]]; then
        echo "sunrise"
    elif [[ $hour -ge 9 && $hour -lt 17 ]]; then
        echo "light"
    elif [[ $hour -ge 17 && $hour -lt 20 ]]; then
        echo "sunset"
    else
        echo "dark"
    fi
}

enable_auto_theme() {
    local auto_theme=$(get_time_based_theme)
    echo "Auto-selecting theme: $auto_theme (based on time)"
    load_theme "$auto_theme"
}

#########################
# Theme Marketplace     #
#########################

list_marketplace_themes() {
    cat <<'EOF'

=== THEME MARKETPLACE (Concept) ===

Popular Community Themes:
  • Dracula         - Popular dark theme with purple accents
  • Nord            - Arctic, north-bluish color palette
  • Gruvbox         - Retro groove color scheme
  • Monokai Pro     - Professional coding theme
  • Tokyo Night     - Clean, dark theme inspired by Tokyo
  • One Dark Pro    - Atom's iconic One Dark theme
  • Material        - Google Material Design colors
  • Catppuccin      - Soothing pastel theme

To download themes, visit:
  https://github.com/rivals-themes (concept)

Share your theme:
  rivals-themes.zsh export <name> <name>.theme.json
  Then submit to the marketplace repository!

EOF
}

#########################
# CLI Interface         #
#########################

show_help() {
    cat <<'EOF'
Marvel Rivals Theme System - Complete UI Customization

USAGE:
    rivals-themes.zsh [command] [options]

COMMANDS:
    list                           List all themes
    preview <theme>                Preview theme colors
    load <theme>                   Load/activate theme
    active                         Show currently active theme
    create <name>                  Create custom theme (wizard)
    delete <name>                  Delete custom theme
    export <name> [file]           Export theme to JSON
    import <file> [name]           Import theme from JSON
    auto                           Enable auto-theme by time of day
    marketplace                    Browse community themes

BUILT-IN THEMES:
    dark             - Default dark theme
    light            - Clean light theme
    high_contrast    - High contrast for accessibility
    cyberpunk        - Neon cyberpunk aesthetic
    synthwave        - Retro 80s synthwave
    ocean            - Calming ocean blues
    forest           - Natural woodland greens
    sunset           - Warm sunset colors
    minimal          - Minimalist clean design
    compact          - Space-efficient layout
    matrix           - Classic Matrix green
    vaporwave        - Nostalgic vaporwave aesthetic
    monochrome       - Pure black and white

EXAMPLES:
    rivals-themes.zsh list
    rivals-themes.zsh load cyberpunk
    rivals-themes.zsh preview synthwave
    rivals-themes.zsh create mytheme
    rivals-themes.zsh export dark dark-custom.json
    rivals-themes.zsh auto

THEME VARIABLES:
    Colors: HEADER_BG, HEADER_FG, SIDEBAR_BG, etc.
    Layout: SIDEBAR_WIDTH, PREVIEW_HEIGHT, INPUT_HEIGHT
    Typography: USE_BOLD_HEADERS, USE_ITALIC_HINTS
    Behavior: AUTO_COPY, SHOW_LIVE_PREVIEW, ANIMATION_SPEED

EOF
}

#########################
# Main Entry Point      #
#########################

main() {
    local command=${1:-help}
    shift

    init_theme_dirs

    case "$command" in
        help|--help|-h)
            show_help
            ;;
        list)
            list_themes
            ;;
        preview)
            preview_theme "$1"
            ;;
        load)
            load_theme "$1"
            echo "Theme '$1' activated!"
            ;;
        active)
            local active=$(get_active_theme)
            echo "Currently active theme: $active"
            ;;
        create)
            create_theme "$1"
            ;;
        delete)
            delete_theme "$1"
            ;;
        export)
            export_theme "$1" "${2:-$1.theme.json}"
            ;;
        import)
            import_theme "$1" "$2"
            ;;
        auto)
            enable_auto_theme
            ;;
        marketplace)
            list_marketplace_themes
            ;;
        *)
            echo "Unknown command: $command"
            echo "Use 'rivals-themes.zsh help' for usage information"
            return 1
            ;;
    esac
}

# Run if executed directly
if [[ "${(%):-%N}" == "${0}" ]] || [[ "${0}" == *"rivals-themes.zsh" ]]; then
    main "$@"
fi
