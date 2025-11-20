#!/usr/bin/env bash

# Test script to reproduce issue #68 - emoji alignment in boxes

# Enable rich mode to use Unicode box characters
export OISEAU_MODE="rich"

# Source oiseau library
source "$(dirname "$0")/oiseau.sh"

# Test case from issue #68
echo "Test 1: Header box with emojis (from issue example)"
show_header_box "Tild Menu" "📁 ynm  •  🌿"

echo ""
echo "Test 2: Regular box with emojis"
show_box info "Status" "📁 repo • 🌿 branch"

echo ""
echo "Test 3: Box with various emojis"
show_box success "Complete" "✓ Success with emoji 🎉"

echo ""
echo "Test 4: Box with CJK characters"
show_box info "Chinese" "中文字符测试"

echo ""
echo "Test 5: Multiple lines with emojis"
print_kv "Key 1" "📁 Value with emoji"
print_kv "Key 2" "🌿 Another value"
print_kv "Key 3" "Regular text"

echo ""
echo "Test 6: Mixed emoji and text in longer box"
show_box warning "Mixed Content" "This has 📁 folder, 🌿 branch, and 🎉 party emojis embedded in longer text to test alignment."

echo ""
echo "Test 7: Double-width emoji stress test"
show_box info "Emoji Test" "😀😁😂🤣😃😄😅😆😉😊😋😎😍"
