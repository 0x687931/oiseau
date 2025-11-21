#!/usr/bin/env bash
#===============================================================================
# INDEPENDENT VERTICAL ALIGNMENT VALIDATOR
#===============================================================================
# This script validates vertical alignment by counting actual padding characters
# from the right border, NOT by using the same width calculation functions.
#
# Method: Count the number of space characters between last content char and
# the right border character (┃ or │), which should be the same for all lines.
#===============================================================================

set -euo pipefail

# Source oiseau.sh with required environment variables
export OISEAU_HEIGHT=24
export OISEAU_WIDTH=80
source ./oiseau.sh

echo "=== INDEPENDENT ALIGNMENT VALIDATION ==="
echo ""
echo "Method: Count padding spaces before right border on each line"
echo "All lines should have SAME number of padding spaces"
echo ""

# Test cases
test_cases=(
    "Plain text"
    "📁 One emoji"
    "📁 🌿 Two emojis"
    "中文 CJK chars"
    "📁 Mixed 中文 content"
)

for test_content in "${test_cases[@]}"; do
    echo "----------------------------------------"
    echo "Testing: $test_content"
    echo ""

    # Generate box
    output=$(show_box "Test" "$test_content")

    # Show the actual output
    echo "$output"
    echo ""

    # Analyze each line
    echo "Line analysis:"
    line_num=0
    declare -A padding_counts

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Skip empty lines
        [ -z "$line" ] && continue

        # Find the right border character (┃ or │)
        if [[ "$line" =~ ┃ ]] || [[ "$line" =~ │ ]]; then
            # Remove ANSI codes
            clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

            # Get everything before the last ┃ or │
            content_part="${clean_line%┃*}"
            content_part="${content_part%│*}"

            # Count trailing spaces in content_part
            trailing_spaces="${content_part##*[^ ]}"
            padding_count=${#trailing_spaces}

            # Get the actual content (without padding)
            actual_content="${content_part%"$trailing_spaces"}"

            echo "  Line $line_num: padding=$padding_count spaces | content='$actual_content'"
            padding_counts[$line_num]=$padding_count
        fi
    done <<< "$output"

    # Check if all padding counts are the same
    echo ""
    unique_paddings=($(printf '%s\n' "${padding_counts[@]}" | sort -u))

    if [ ${#unique_paddings[@]} -eq 1 ]; then
        echo "✅ PASS: All lines have ${unique_paddings[0]} padding spaces"
    else
        echo "❌ FAIL: Different padding counts found:"
        for line_num in "${!padding_counts[@]}"; do
            echo "     Line $line_num: ${padding_counts[$line_num]} spaces"
        done
    fi

    echo ""
done

echo "=== VALIDATION COMPLETE ==="
