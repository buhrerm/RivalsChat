#!/usr/bin/env zsh

# main_page.zsh - Main application page
# Handles the main text input and preview screen

source "${0:A:h}/../components/ui_header.zsh"
source "${0:A:h}/../components/ui_input.zsh"
source "${0:A:h}/../components/ui_preview.zsh"
source "${0:A:h}/../components/ui_pattern_selector.zsh"
source "${0:A:h}/../components/ui_footer.zsh"

# Draw the complete main page
main_page_draw() {
    draw_header
    draw_input
    draw_preview
    draw_pattern_selector
    draw_footer
}
