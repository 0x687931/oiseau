#!/usr/bin/env bash

export OISEAU_MODE="rich"
source "$(dirname "$0")/oiseau.sh"

# Generate boxes
output=$(show_header_box "Test" "📁 file")

# Check display width of each line
echo "$output" | sed 's/\x1b\[[0-9;]*m//g' | while IFS= read -r line; do
    if [[ "$line" =~ ┃ ]]; then
        dw=$(_display_width "$line")
        cc=$(echo -n "$line" | wc -m | tr -d ' ')
        echo "Display width: $dw, Char count: $cc - Line: $line"
    fi
done