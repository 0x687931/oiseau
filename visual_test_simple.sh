#!/usr/bin/env bash

cd "$(dirname "$0")"
OISEAU_MODE=rich source ./oiseau_original.sh 2>/dev/null

echo "Looking at RIGHT edge alignment - watch the right ┃ characters:"
echo ""

show_header_box "Plain ASCII" "No special chars" | while IFS= read -r line; do
    echo "$line                           <- Plain"
done

echo ""

show_header_box "📁 Emoji" "With emoji char" | while IFS= read -r line; do
    echo "$line                           <- Emoji"
done

echo ""

show_header_box "中文 CJK" "Chinese chars" | while IFS= read -r line; do
    echo "$line                           <- CJK"
done

echo ""
echo "================================================================"
echo "DO THE RIGHT BORDERS (┃) LINE UP VERTICALLY?"
echo "================================================================"
