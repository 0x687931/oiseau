#!/usr/bin/env bash

export OISEAU_MODE="rich"
source "$(dirname "$0")/oiseau.sh"

# Generate a box with emoji
output=$(show_header_box "Test" "📁 file")

# Strip ANSI and check each line
echo "NOTE: This shows CHARACTER COUNT (not display width)"
echo "      For emoji/CJK content, char count will be LESS than display width"
echo "      This is EXPECTED - emojis are 1 char but 2 cols wide"
echo ""

echo "$output" | sed 's/\x1b\[[0-9;]*m//g' | while IFS= read -r line; do
    if [[ "$line" =~ ┃ ]]; then
        char_count=$(echo -n "$line" | wc -m | tr -d ' ')
        display_width=$(_display_width "$line")
        echo "Char count: $char_count, Display width: $display_width - Line: $line"
    fi
done
