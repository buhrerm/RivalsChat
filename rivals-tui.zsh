#!/usr/bin/env zsh
# Wrapper to run the modular TUI from root directory
exec "$(dirname $0)/src/rivals-tui-modular.zsh" "$@"
