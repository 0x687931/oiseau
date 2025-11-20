#!/usr/bin/env bash

export OISEAU_MODE="rich"
source "$(dirname "$0")/oiseau.sh"

# Generate a box with emoji
output=$(show_header_box "Test" "📁 file")

# Strip ANSI and check each line
echo "$output" | sed 's/\x1b\[[0-9;]*m//g' | while IFS= read -r line; do
    if [[ "$line" =~ ┃ ]]; then
        char_count=$(echo -n "$line" | wc -m | tr -d ' ')
        echo "Width: $char_count - Line: $line"
    fi
done
