#!/usr/bin/env zsh

# app_state.zsh - Global application state management
# This module manages all application state in a centralized way

# Source constants
source "${0:A:h}/../utils/constants.zsh"

# UI State
typeset -g CURRENT_MODE="main"  # main, pattern_creator, pattern_manager
typeset -g SHOW_SUCCESS=0
typeset -g SUCCESS_MSG=""
typeset -g SUCCESS_TIME=0

# Input/Editor State
typeset -g INPUT_TEXT=""
typeset -g CURSOR_POS=0
typeset -g SELECTION_START=-1
typeset -g SELECTION_END=-1

# Pattern State
typeset -g CURRENT_PATTERN_INDEX=1
typeset -g REPEAT_MODE=0  # 0=continuous, 1=per word, 2=per phrase
typeset -g SYMMETRY_MODE=0  # 0=off, 1=mirror, 2=full

# Pattern Storage
typeset -gA ALL_PATTERNS
typeset -gA ALL_ICONS
typeset -ga PATTERN_ORDER

# Pattern Creator State
typeset -ga CREATOR_COLORS
typeset -g CREATOR_NAME=""
typeset -g CREATOR_ICON=""
typeset -g CREATOR_CURSOR=1
typeset -g CREATOR_COLOR_CURSOR=1
typeset -g CREATOR_MODE="name"  # name, icon, colors

# Pattern Manager State
typeset -g MANAGER_CURSOR=1
typeset -g MANAGER_ACTION=""

# System State
typeset -g CLIPBOARD_CMD=""

# State initialization
state_init() {
    INPUT_TEXT=""
    CURSOR_POS=0
    SELECTION_START=-1
    SELECTION_END=-1
    CURRENT_PATTERN_INDEX=1
    CURRENT_MODE="main"
    SHOW_SUCCESS=0
}

# State reset functions
state_reset_creator() {
    CREATOR_NAME=""
    CREATOR_ICON=""
    CREATOR_COLORS=()
    CREATOR_CURSOR=1
    CREATOR_COLOR_CURSOR=1
    CREATOR_MODE="name"
}

state_reset_selection() {
    SELECTION_START=-1
    SELECTION_END=-1
}

# Success message helpers
state_show_success() {
    local message=$1
    SUCCESS_MSG="$message"
    SHOW_SUCCESS=1
    SUCCESS_TIME=$(date +%s)
}

state_clear_success() {
    SHOW_SUCCESS=0
    SUCCESS_MSG=""
}

state_check_success_timeout() {
    if [[ $SHOW_SUCCESS -eq 1 ]]; then
        local current_time=$(date +%s)
        if [[ $((current_time - SUCCESS_TIME)) -ge $SUCCESS_DISPLAY_TIME ]]; then
            state_clear_success
            return 0
        fi
    fi
    return 1
}

# Centralized escape/cancel handling
state_handle_escape() {
    local from_mode=$1

    case "$from_mode" in
        "pattern_creator")
            # From pattern creator → go back to pattern manager
            CURRENT_MODE="pattern_manager"
            state_reset_creator
            ;;
        "pattern_manager")
            # From pattern manager → go back to main
            CURRENT_MODE="main"
            ;;
        *)
            # Default: go to main
            CURRENT_MODE="main"
            ;;
    esac
}
