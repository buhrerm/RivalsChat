#!/bin/zsh

stty -echo -icanon min 0 2>/dev/null

while true; do
    local char
    if ! IFS= read -r -s -t 0.5 -k 1 char 2>/dev/null; then
        echo "timeout"
    else
        echo "got: $char"
    fi
    echo "char=$char"
done