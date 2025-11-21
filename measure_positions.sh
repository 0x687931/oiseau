#!/usr/bin/env bash

cd "$(dirname "$0")"
OISEAU_MODE=rich source ./oiseau_original.sh 2>/dev/null

measure_box() {
    local title="$1"
    local subtitle="$2"
    local label="$3"

    echo "==================================="
    echo "Box: $label"
    echo "==================================="

    output=$(show_header_box "$title" "$subtitle")

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Skip empty lines
        [ -z "$line" ] && continue

        # Remove ANSI codes
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Find position of last ┃ character
        # Method: Find last occurrence position
        last_pos=0
        for ((i=0; i<${#clean}; i++)); do
            char="${clean:$i:1}"
            if [[ "$char" == "┃" ]]; then
                last_pos=$i
            fi
        done

        # Count bytes
        byte_count=$(printf '%s' "$clean" | wc -c | tr -d ' ')

        # Show analysis
        printf "  Line %d: last ┃ at position %d, total %d bytes\n" "$line_num" "$last_pos" "$byte_count"
    done <<< "$output"

    echo ""
}

measure_box "Plain ASCII" "No special chars" "PLAIN"
measure_box "📁 Emoji" "With emoji" "EMOJI"
measure_box "中文 CJK" "Chinese" "CJK"
measure_box "📁 Mix 中文" "Mixed 📁 中文 content" "MIXED"

echo "=========================================================="
echo "ANALYSIS:"
echo "=========================================================="
echo "If 'last ┃ at position X' is THE SAME for all boxes,"
echo "then alignment is PERFECT (visually aligned)"
echo ""
echo "If 'total bytes' DIFFERS between boxes,"
echo "that's EXPECTED (emoji/CJK use more bytes)"
echo ""
echo "VISUAL alignment = column position (should match)"
echo "BYTE count = storage size (will differ)"
echo "=========================================================="
