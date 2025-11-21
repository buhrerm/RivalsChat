#!/usr/bin/env zsh

# constants.zsh - Application constants and configuration
# This file contains all constant values used throughout the application

VERSION="2.0.0"

# Marvel Rivals Color Codes (matching the game)
typeset -gA RIVALS=(
    Y "Gold" O "Orange" R "Red" P "Pink" M "Really Pink"
    U "Purple" B "Blue" I "Dark Blue" A "Teal"
    T "Blue Green" G "Green" E "Green Yellow" K "Yellow"
)

# ANSI colors for preview
typeset -gA COLORS=(
    Y '\033[38;5;226m' O '\033[38;5;208m' R '\033[38;5;196m'
    P '\033[38;5;205m' M '\033[38;5;199m' U '\033[38;5;135m'
    B '\033[38;5;33m'  I '\033[38;5;27m'  A '\033[38;5;51m'
    T '\033[38;5;45m'  G '\033[38;5;46m'  E '\033[38;5;154m'
    K '\033[38;5;190m'
)

# UI Colors
typeset -gA UI_COLORS=(
    RESET '\033[0m'
    BOLD '\033[1m'
    DIM '\033[2m'
    ACCENT '\033[38;2;0;255;255m'
    SUCCESS '\033[38;2;0;255;0m'
    BORDER '\033[38;2;100;100;255m'
    TEXT '\033[38;2;200;200;255m'
    HIGHLIGHT '\033[38;2;255;255;0m'
    ERROR '\033[38;2;255;0;0m'
    SELECTED '\033[48;2;50;50;150m'
)

# Box drawing characters
typeset -gA BOX=(
    TL '╔' TR '╗' BL '╚' BR '╝'
    H '═' V '║'
    VR '╠' VL '╣' HU '╩' HD '╦' CROSS '╬'
)

# Configuration paths
typeset -g CONFIG_DIR="${HOME}/.config/rivals"
typeset -g PATTERNS_FILE="${CONFIG_DIR}/custom_patterns.json"

# Built-in patterns
typeset -gA BUILTIN_PATTERNS=(
    "Rainbow" "Y O R P M U B I A T G E K"
    "Warm" "Y O R P M"
    "Cool" "U B I A T G"
    "Neon" "E G T A B U"
    "Sunset" "Y E O R P M"
    "Ocean" "B I A T G"
    "Psychedelic" "M U E O A R"
    "Spring" "G E Y O P"
    "Cherry" "P M R O Y"
    "Matrix" "G T A"
    "Fire" "R R O Y O R R"
    "Ice" "B B I A I B B"
    "Electric" "B U B U E Y E"
    "Candy" "P P M Y Y O P P"
    "Pulse" "R R R B B B R R R"
)

typeset -gA BUILTIN_ICONS=(
    "Rainbow" "🌈"
    "Warm" "🔥"
    "Cool" "❄️"
    "Neon" "⚡"
    "Sunset" "🌅"
    "Ocean" "🌊"
    "Psychedelic" "🎨"
    "Spring" "🌸"
    "Cherry" "🍒"
    "Matrix" "💚"
    "Fire" "🔥"
    "Ice" "🧊"
    "Electric" "⚡"
    "Candy" "🍬"
    "Pulse" "💗"
)

# UI Constants
typeset -g UI_WIDTH=70
typeset -g INPUT_MAX_LENGTH=59
typeset -g PREVIEW_MAX_LENGTH=60
typeset -g SUCCESS_DISPLAY_TIME=2

# Available icons for custom patterns
typeset -ga AVAILABLE_ICONS=(
    "🎨" "🌟" "💎" "🔥" "❄️" "⚡"
    "🌈" "🌸" "🍀" "🎭" "🎪" "🎯"
)
