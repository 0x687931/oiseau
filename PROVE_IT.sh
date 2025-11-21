#!/usr/bin/env bash
#===============================================================================
# VISUAL PROOF: Does alignment actually work or not?
#===============================================================================
# This script generates actual terminal output with all combinations:
# - Plain ASCII
# - Emoji only
# - CJK only
# - Mixed emoji + CJK + ASCII
# - Edge cases
#
# YOU will see with your own eyes if borders align or not.
#===============================================================================

set -euo pipefail

cd "$(dirname "$0")"

# Use ORIGINAL code (before my "fix")
git show 2001b9f:oiseau.sh > oiseau_original.sh

echo "======================================================================"
echo "VISUAL PROOF TEST - ORIGINAL CODE (before PR#85)"
echo "======================================================================"
echo ""
echo "Look at the RIGHT BORDERS (┃ or |) - are they aligned vertically?"
echo ""

# Source original code
export OISEAU_MODE=rich
source ./oiseau_original.sh 2>/dev/null

echo "TEST 1: Plain ASCII text"
echo "----------------------------------------------------------------------"
show_header_box "Plain Title" "Plain subtitle text here"
echo ""

echo "TEST 2: Single emoji"
echo "----------------------------------------------------------------------"
show_header_box "📁 Title" "Subtitle with emoji"
echo ""

echo "TEST 3: Multiple emojis"
echo "----------------------------------------------------------------------"
show_header_box "📁 🌿 🎉 Title" "Multiple emojis in subtitle: 📁 🌿 🎉"
echo ""

echo "TEST 4: CJK characters"
echo "----------------------------------------------------------------------"
show_header_box "中文标题" "日本語のサブタイトル"
echo ""

echo "TEST 5: Mixed everything"
echo "----------------------------------------------------------------------"
show_header_box "Mixed: 📁 中文 ASCII 🌿" "Everything: 日本語 emoji 📁 text 中文"
echo ""

echo "TEST 6: Long text that wraps"
echo "----------------------------------------------------------------------"
show_header_box "Long Title" "This is a very long subtitle with emoji 📁 and CJK 中文 characters that should wrap to multiple lines and each line should be aligned"
echo ""

echo "TEST 7: Empty content"
echo "----------------------------------------------------------------------"
show_header_box "Title Only" ""
echo ""

echo "TEST 8: All emojis"
echo "----------------------------------------------------------------------"
show_header_box "📁 🌿 🎉 ⭐ 🔥" "📁 🌿 🎉 ⭐ 🔥 💡 ✨"
echo ""

echo "======================================================================"
echo "VISUAL INSPECTION QUESTIONS:"
echo "======================================================================"
echo ""
echo "1. Look at all the boxes above"
echo "2. Are the RIGHT borders (┃) in a straight vertical line?"
echo "3. Or do they zig-zag left/right?"
echo ""
echo "If they zig-zag → ALIGNMENT IS BROKEN"
echo "If they're straight → ALIGNMENT IS WORKING"
echo ""
echo "What do YOU see?"
echo ""
