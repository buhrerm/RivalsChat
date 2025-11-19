#!/bin/zsh
set +x
stty -echo -icanon min 0 2>/dev/null
while true; do
    local myinput
    if ! IFS= read -r -s -t 0.5 -k 1 myinput 2>/dev/null; then
        :  # Do nothing
    else
        :  # Do nothing
    fi
done