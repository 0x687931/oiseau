#!/usr/bin/env bash

source "$(dirname "$0")/oiseau.sh"

# Test the exact scenario
line="📁 file"
inner_width=58  # 60 - 2 for borders
padded_line="   $line"

echo "Input line: '$line'"
echo "With 3-space prefix: '$padded_line'"
echo ""

# Check display width
display_width=$(_display_width "$padded_line")
echo "Display width of '   $line': $display_width"
echo "Target inner_width: $inner_width"
echo ""

# Apply padding
padded=$(_pad_to_width "$padded_line" "$inner_width")
echo "After _pad_to_width: '$padded'"

# Check result width
result_width=$(_display_width "$padded")
echo "Result display width: $result_width"
echo ""

# Check character count vs display width
char_count=${#padded}
echo "Character count: $char_count"
echo "Display width: $result_width"

# Create the full line with borders
full_line="┃${padded}┃"
echo ""
echo "Full line: '$full_line'"
char_count=$(echo -n "$full_line" | wc -m | tr -d ' ')
display_width=$(_display_width "$full_line")
echo "Full line character count: $char_count"
echo "Full line display width: $display_width (should be 60)"
echo ""
echo "NOTE: Character count ≠ display width for emoji/CJK."
echo "      Emojis are 1 char but 2 cols wide (expected difference)."
