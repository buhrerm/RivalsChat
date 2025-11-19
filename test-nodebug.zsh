#!/bin/zsh
set +x  # Ensure debug mode is off

stty -echo -icanon min 0 2>/dev/null

while true; do
    local char
    if ! IFS= read -r -s -t 0.5 -k 1 char 2>/dev/null; then
        echo "timeout" >&2
    else
        echo "got: $char" >&2
    fi
done