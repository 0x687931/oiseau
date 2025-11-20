#!/usr/bin/env bash

# MANUAL DIAGNOSTIC TOOL (not automated test)
# Comprehensive analysis for vertical bar alignment
# This script displays detailed width measurements for visual inspection
# For automated testing, use: bats tests/bats/test_vertical_alignment.bats

export OISEAU_MODE="rich"
source "$(dirname "$0")/oiseau.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "VERTICAL ALIGNMENT TEST - Detailed Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to count actual characters in a line
count_line_width() {
    local line="$1"
    # Strip ANSI codes
    local clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
    # Use _display_width if available
    if type _display_width >/dev/null 2>&1; then
        _display_width "$clean"
    else
        echo ${#clean}
    fi
}

# Function to check if vertical bars align
check_alignment() {
    local test_name="$1"
    local output="$2"

    echo "Testing: $test_name"
    echo "Output:"
    echo "$output"
    echo ""

    # Extract each line and measure
    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        # Strip ANSI codes for measurement
        local clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local width=$(echo -n "$clean" | wc -m | tr -d ' ')
        local display_width=$(_display_width "$clean" 2>/dev/null || echo "$width")

        # Check for vertical bar at end
        if [[ "$clean" =~ ┃$ ]] || [[ "$clean" =~ \|$ ]]; then
            local visual_width=${#clean}
            echo "  Line $line_num: char_count=$width, display_width=$display_width, visual=${visual_width}"

            # Check if it ends at the expected position
            local expected_pos=60
            if [ "$display_width" -ne "$expected_pos" ]; then
                echo "    ⚠️  MISALIGNMENT: Expected $expected_pos, got $display_width"
            else
                echo "    ✓ ALIGNED"
            fi
        fi
    done <<< "$output"
    echo ""
}

echo "Test 1: ASCII text (baseline)"
output1=$(show_header_box "Test" "Regular ASCII text")
check_alignment "ASCII baseline" "$output1"

echo "Test 2: Single emoji at start"
output2=$(show_header_box "Test" "📁 file.txt")
check_alignment "Single emoji at start" "$output2"

echo "Test 3: Two emojis (from issue)"
output3=$(show_header_box "Tild Menu" "📁 ynm  •  🌿")
check_alignment "Two emojis (issue example)" "$output3"

echo "Test 4: Multiple emojis"
output4=$(show_box info "Status" "📁 🌿 🎉 ✓ Multiple emojis in one line")
check_alignment "Multiple emojis" "$output4"

echo "Test 5: CJK characters"
output5=$(show_box info "Chinese" "中文字符测试")
check_alignment "CJK characters" "$output5"

echo "Test 6: Mixed ASCII and emojis"
output6=$(show_box warning "Mixed" "Normal text 📁 then emoji 🌿 then more text")
check_alignment "Mixed content" "$output6"

echo "Test 7: Long line with emoji"
output7=$(show_box info "Long" "This is a very long line with emoji 📁 in the middle of the text")
check_alignment "Long line with emoji" "$output7"

echo "Test 8: Emoji at end of line"
output8=$(show_box success "End" "Text ending with emoji 📁")
check_alignment "Emoji at end" "$output8"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MANUAL VISUAL INSPECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Check if all right vertical bars (┃) align vertically below:"
echo ""

show_header_box "Line 1" "No emojis here"
echo ""
show_header_box "Line 2" "📁 One emoji"
echo ""
show_header_box "Line 3" "📁 🌿 Two emojis"
echo ""
show_header_box "Line 4" "📁 🌿 🎉 Three emojis"
echo ""
show_header_box "Line 5" "Regular text again"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "If the right edges (┃) are NOT aligned, vertical alignment is broken."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
