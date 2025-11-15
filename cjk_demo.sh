#!/bin/bash
# Demonstration of CJK and wide character support

source ./oiseau.sh

clear

echo ""
echo -e "${COLOR_HEADER}${BOLD}CJK Wide Character Support Demonstration${RESET}"
echo ""

# Show multiple examples with different languages
show_section_header "Chinese (中文)" 1 4 "Testing box alignment with Chinese characters"

echo ""
show_box success "成功" "数据库连接成功 - Database connection successful" \
    "这是一个测试命令"

echo ""
show_box info "信息" "处理文件: 你好世界.txt"

echo ""
show_section_header "Japanese (日本語)" 2 4 "Testing hiragana, katakana, and kanji"

echo ""
show_box warning "警告" "こんにちは - Hello in hiragana" \
    "カタカナテスト - Katakana test"

echo ""
show_section_header "Korean (한국어)" 3 4 "Testing Hangul characters"

echo ""
show_box error "오류" "연결 실패 - Connection failed" \
    "안녕하세요 - Hello in Korean"

echo ""
show_section_header "Mixed Content" 4 4 "Combining ASCII, CJK, and emoji"

echo ""
show_box info "Mixed Test 混合测试 🐦" "Hello 你好 こんにちは 안녕 🚀" \
    "Full-width: ＡＢＣ１２３"

echo ""
echo -e "${COLOR_SUCCESS}${BOLD}All boxes above should have perfectly aligned borders!${RESET}"
echo ""

# Show a detailed comparison
echo -e "${COLOR_ACCENT}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${COLOR_ACCENT}${BOLD}  Character Width Analysis${RESET}"
echo -e "${COLOR_ACCENT}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

print_kv "ASCII 'Hello'" "$(_display_width 'Hello') columns (5 chars × 1)"
print_kv "Chinese '你好'" "$(_display_width '你好') columns (2 chars × 2)"
print_kv "Japanese 'こんにちは'" "$(_display_width 'こんにちは') columns (5 chars × 2)"
print_kv "Korean '안녕하세요'" "$(_display_width '안녕하세요') columns (5 chars × 2)"
print_kv "Emoji '🐦'" "$(_display_width '🐦') columns (1 char × 2)"
print_kv "Full-width 'ＡＢＣ'" "$(_display_width 'ＡＢＣ') columns (3 chars × 2)"
print_kv "Mixed 'Hi 你好 🐦'" "$(_display_width 'Hi 你好 🐦') columns"

echo ""
