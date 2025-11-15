#!/bin/bash
# Better comparison showing actual visual difference with SAME box style

source ./oiseau.sh

# Force UTF-8 mode for consistent box drawing
export OISEAU_HAS_UTF8=1
export OISEAU_MODE="rich"

clear
echo ""
echo -e "${COLOR_HEADER}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
echo -e "${COLOR_HEADER}${BOLD}  PROOF: Before vs After CJK Character Width Fix${RESET}"
echo -e "${COLOR_HEADER}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
echo ""

echo -e "${COLOR_WARNING}${BOLD}TEST CASE: Box with mixed CJK and ASCII text${RESET}"
echo -e "${COLOR_MUTED}Text: \"你好世界 - Hello World\" (4 CJK chars + 13 ASCII = should be 21 columns)${RESET}"
echo ""
echo ""

# ============================================================================
# BEFORE - Manually create a box with WRONG padding (treating CJK as width 1)
# ============================================================================

echo -e "${COLOR_ERROR}${BOLD}BEFORE FIX (CJK counted as 1 column each):${RESET}"
echo ""

# The text "你好世界" has 4 characters but displays as 8 columns
# Old broken logic would treat it as 4 columns
text="  你好世界 - Hello World"

# Wrong calculation: ${#text} = 20 chars (2 spaces + 4 CJK + 14 ASCII)
# But actual display width should be: 2 + 8 + 14 = 24 columns
# If we pad to 58 total: 58 - 20 = 38 spaces (WRONG!)
char_count=${#text}
wrong_padding=$((56 - char_count))  # 56 because of ┃ ┃ borders

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃                                                          ┃"
printf "┃%s%${wrong_padding}s┃\n" "$text" ""
echo "┃                                                          ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

echo ""
echo -e "${COLOR_ERROR}👆 Notice the right border (┃) is pushed WAY to the right!${RESET}"
echo -e "${COLOR_ERROR}   The CJK characters take more visual space than calculated.${RESET}"
echo ""
echo ""

# ============================================================================
# AFTER - Use our fixed _pad_to_width function
# ============================================================================

echo -e "${COLOR_SUCCESS}${BOLD}AFTER FIX (CJK counted as 2 columns each):${RESET}"
echo ""

# Correct calculation using _display_width
inner_width=58
text2="  你好世界 - Hello World"
actual_width=$(_display_width "$text2")
correct_padding=$((inner_width - actual_width))

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃                                                          ┃"
printf "┃%s%${correct_padding}s┃\n" "$text2" ""
echo "┃                                                          ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

echo ""
echo -e "${COLOR_SUCCESS}👆 Perfect! All borders line up correctly!${RESET}"
echo ""
echo ""

# ============================================================================
# Show the math
# ============================================================================

echo -e "${COLOR_ACCENT}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${COLOR_ACCENT}${BOLD}  The Math Behind The Fix${RESET}"
echo -e "${COLOR_ACCENT}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

print_kv "Text" "\"  你好世界 - Hello World\""
echo ""
print_kv "Character count" "${#text2} characters"
print_kv "Display width (BEFORE)" "${#text2} columns (WRONG!)"
print_kv "Display width (AFTER)" "$actual_width columns (CORRECT!)"
echo ""
print_kv "Target inner width" "$inner_width columns"
print_kv "Padding needed (BEFORE)" "$wrong_padding spaces (WRONG!)"
print_kv "Padding needed (AFTER)" "$correct_padding spaces (CORRECT!)"
echo ""

echo -e "${COLOR_INFO}Breakdown:${RESET}"
print_item "Spaces: 2 × 1 = 2 columns"
print_item "CJK '你好世界': 4 × 2 = 8 columns"
print_item "ASCII ' - Hello World': 14 × 1 = 14 columns"
print_item "Total: 2 + 8 + 14 = 24 columns"
print_item "Padding: 58 - 24 = 34 spaces"

echo ""
echo -e "${COLOR_SUCCESS}${BOLD}✓ CJK characters now correctly counted as 2 columns each!${RESET}"
echo ""

