#!/usr/bin/env bash

# Simple visual test - if you see misalignment, there's a problem

export OISEAU_MODE="rich"
source "$(dirname "$0")/oiseau.sh"

echo "Visual Alignment Test - Look for misaligned right edges (┃)"
echo ""
echo "All boxes below should have their right edges perfectly aligned:"
echo ""

# Create boxes with different emoji counts
show_header_box "Box 1" "No emojis - just plain text here"
show_header_box "Box 2" "📁 One emoji at start"
show_header_box "Box 3" "📁 🌿 Two emojis together"
show_header_box "Box 4" "📁 emoji 🌿 separated 🎉 by text"
show_header_box "Box 5" "Back to plain text"
show_header_box "Box 6" "中文字符 CJK characters"
show_header_box "Box 7" "Mix of 📁 emoji and 中文 CJK"

echo ""
echo "┌────────────────────────────────────────────────────────────┐"
echo "│ If ALL right edges (┃) line up vertically above, SUCCESS  │"
echo "│ If ANY right edge is offset, there's a BUG                 │"
echo "└────────────────────────────────────────────────────────────┘"
