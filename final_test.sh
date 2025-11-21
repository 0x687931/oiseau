#!/usr/bin/env bash
cd "$(dirname "$0")"
export OISEAU_MODE=rich
source ./oiseau.sh 2>/dev/null

echo "=== FINAL ALIGNMENT TEST ==="
echo ""

show_header_box "Plain Text" "No special chars"
echo ""
show_header_box "📁 Emoji" "With emoji 📁"
echo ""
show_header_box "中文 CJK" "Japanese: 日本語"
echo ""
show_header_box "📁 Mixed 中文" "Everything: 📁 中文 text 🌿"
echo ""

echo "=== ALL BOXES SHOULD HAVE ALIGNED RIGHT BORDERS (┃) ==="
