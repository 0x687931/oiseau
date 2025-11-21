#!/usr/bin/env bash
#===============================================================================
# SIMPLE ALIGNMENT VALIDATOR
#===============================================================================
# Counts padding spaces from right border - they should all be equal
#===============================================================================

cd "$(dirname "$0")"

test_case() {
    local content="$1"
    echo "Testing: $content"

    # Generate a simple box with show_header_box
    output=$(bash -c "source ./oiseau.sh 2>/dev/null; show_header_box 'Test' '$content' 2>/dev/null")

    echo "$output"
    echo ""

    # Count padding on each line by looking for pattern: (content)(spaces)(border)
    echo "Padding analysis:"
    echo "$output" | while IFS= read -r line; do
        # Remove ANSI codes
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Check if line has a right border
        if [[ "$clean" =~ ┃$ ]] || [[ "$clean" =~ ┓$ ]] || [[ "$clean" =~ ┛$ ]]; then
            # Count spaces before the last border character
            # Remove last char, then count trailing spaces
            without_border="${clean%?}"
            trailing="${without_border##*[^ ]}"
            count=${#trailing}

            # Show the line with padding count
            echo "  Padding: $count spaces | Line: $clean"
        fi
    done
    echo ""
}

echo "=== SIMPLE ALIGNMENT VALIDATION ==="
echo ""

test_case "Plain text"
test_case "📁 One emoji"
test_case "📁 🌿 Two emojis"
test_case "中文 CJK"

echo "=== If all padding counts are the same, alignment is correct ==="
