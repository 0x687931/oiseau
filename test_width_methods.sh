#!/usr/bin/env bash

# Test different width calculation methods

source "$(dirname "$0")/oiseau.sh"

test_string() {
    local label="$1"
    local str="$2"

    # Strip ANSI for testing
    local clean=$(echo "$str" | sed 's/\x1b\[[0-9;]*m//g')

    # Method 1: Character count
    local char_count=${#clean}

    # Method 2: wc -m (multibyte character count)
    local mb_count=$(echo -n "$clean" | wc -m | tr -d ' ')

    # Method 3: wc -L (longest line display width)
    local wc_width=$(echo -n "$clean" | wc -L | tr -d ' ')

    # Method 4: Our _display_width function
    local our_width=$(_display_width "$clean")

    printf "%-30s | char=%2d | wc-m=%2d | wc-L=%2d | _display_width=%2d\n" \
        "$label" "$char_count" "$mb_count" "$wc_width" "$our_width"
}

echo "Width Calculation Comparison"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-30s | %-7s | %-7s | %-7s | %-16s\n" "Test Case" "char" "wc-m" "wc-L" "_display_width"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_string "ASCII text" "Hello World"
test_string "📁 Single emoji" "📁 file.txt"
test_string "📁 🌿 Two emojis" "📁 ynm  •  🌿"
test_string "📁 🌿 🎉 Three emojis" "📁 🌿 🎉 test"
test_string "中文 CJK characters" "中文字符"
test_string "Mixed ASCII+emoji" "Text 📁 emoji 🌿 text"
test_string "Only emojis" "📁🌿🎉😀"
test_string "✓ Symbol" "✓ checkmark"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Expected: wc-L and _display_width should match for proper terminal display"
echo "If they differ significantly, that could indicate alignment issues."
