#!/usr/bin/env bash
# Debug the padding calculation

cd "$(dirname "$0")"
source ./oiseau.sh 2>/dev/null

test_padding() {
    local content="$1"
    local target=56  # Target width for box content area

    echo "Testing: '$content'"

    # Calculate display width
    local display_width=$(_display_width "$content")
    echo "  Display width: $display_width"

    # Pad to target
    local padded=$(_pad_to_width "$content" "$target")

    # Count actual bytes
    local padded_bytes=$(printf '%s' "$padded" | wc -c | tr -d ' ')
    echo "  Padded byte count: $padded_bytes (should be $target)"

    # Show the padded string with border
    echo "  Result: |$padded|"

    echo ""
}

echo "=== PADDING DEBUG ==="
echo ""

test_padding "Plain text"
test_padding "📁 One emoji"
test_padding "📁 🌿 Two emojis"
test_padding "中文 CJK"
