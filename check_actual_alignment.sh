#!/usr/bin/env bash
# Direct character count from right border

cd "$(dirname "$0")"

echo "=== CHARACTER-BY-CHARACTER ALIGNMENT CHECK ==="
echo ""
echo "Method: Measure each line length in bytes, should all be equal"
echo ""

for content in "Plain text" "📁 One emoji" "📁 🌿 Two emojis" "中文 CJK"; do
    echo "Testing: $content"

    # Force rich mode for Unicode borders
    output=$(OISEAU_MODE=rich bash -c "source ./oiseau.sh 2>/dev/null; show_header_box 'Test' '$content' 2>/dev/null")

    # Show the box
    echo "$output"
    echo ""

    # Analyze line by line - count bytes and check for misalignment
    echo "Line length analysis (each line should be same byte count):"

    line_num=0
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue

        line_num=$((line_num + 1))

        # Remove ANSI escape codes
        clean=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Get byte length
        byte_len=$(printf '%s' "$clean" | wc -c | tr -d ' ')

        # Show line with its length
        printf "  Line %2d: %3d bytes | %s\n" "$line_num" "$byte_len" "$clean"
    done <<< "$output"

    echo ""
done
