#!/usr/bin/env bash

cd "$(dirname "$0")"
source ./oiseau_original.sh 2>/dev/null

echo "=== DEBUGGING PRINTF BEHAVIOR ==="
echo ""

# Test 1: Plain text
plain="   Plain text"
padded_plain=$(_pad_to_width "$plain" 56)

echo "TEST 1: Plain text"
echo "  Content: '$plain'"
echo "  After _pad_to_width(56):"
echo "    Bytes: $(printf '%s' "$padded_plain" | wc -c | tr -d ' ')"
echo "    Chars: $(printf '%s' "$padded_plain" | wc -m | tr -d ' ')"
echo "    Display: $(_display_width "$padded_plain")"
echo ""

# Test 2: With emoji
emoji="   📁 Emoji"
padded_emoji=$(_pad_to_width "$emoji" 56)

echo "TEST 2: With emoji"
echo "  Content: '$emoji'"
echo "  After _pad_to_width(56):"
echo "    Bytes: $(printf '%s' "$padded_emoji" | wc -c | tr -d ' ')"
echo "    Chars: $(printf '%s' "$padded_emoji" | wc -m | tr -d ' ')"
echo "    Display: $(_display_width "$padded_emoji")"
echo ""

# Now add the borders
BOX_DV="┃"

echo "=== ADDING BORDERS WITH PRINTF ==="
echo ""

line_plain=$(printf '%s%s%s' "$BOX_DV" "$padded_plain" "$BOX_DV")
line_emoji=$(printf '%s%s%s' "$BOX_DV" "$padded_emoji" "$BOX_DV")

echo "Plain line bytes: $(printf '%s' "$line_plain" | wc -c | tr -d ' ')"
echo "Emoji line bytes: $(printf '%s' "$line_emoji" | wc -c | tr -d ' ')"
echo ""

echo "Plain line: |$line_plain|"
echo "Emoji line: |$line_emoji|"
echo ""

echo "=== THE PROBLEM ==="
echo ""
echo "Both padded to 56 DISPLAY WIDTH (correct)"
echo "But emoji content has MORE BYTES than plain"
echo "So final line: ┃ (3 bytes) + content (more bytes) + ┃ (3 bytes)"
echo "= Different total bytes = misaligned borders"
echo ""
echo "Printf doesn't cause the problem - it just exposes it!"
echo "The problem is we're padding to DISPLAY width but need BYTE width!"
