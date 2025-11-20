#!/usr/bin/env bats
# BATS tests for vertical bar alignment in boxes
# Tests ensure that right edges of boxes align correctly regardless of emoji/CJK content

# Load test helpers
BATS_TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
PROJECT_ROOT="$(cd "$BATS_TEST_DIR/../.." && pwd)"

# Helper function to strip ANSI codes
strip_ansi() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Helper function to extract lines with vertical bars
extract_box_lines() {
    local output="$1"
    strip_ansi "$output" | grep -E '[┃|]'
}

# Helper function to measure line width (DISPLAY width, not character count)
measure_line_width() {
    local line="$1"
    local clean=$(strip_ansi "$line")
    # Must use _display_width to account for emoji/CJK double-width characters
    source "$PROJECT_ROOT/oiseau.sh" 2>/dev/null
    _display_width "$clean"
}

# Helper function to check if all box lines have same width
check_box_width_consistency() {
    local output="$1"
    local expected_width="${2:-60}"

    local lines=$(extract_box_lines "$output")
    local inconsistent=0

    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local width=$(measure_line_width "$line")
            if [ "$width" -ne "$expected_width" ]; then
                echo "Line width $width != expected $expected_width: $line" >&2
                inconsistent=1
            fi
        fi
    done <<< "$lines"

    return $inconsistent
}

# Setup
setup() {
    source "$PROJECT_ROOT/oiseau.sh"
    export OISEAU_MODE="rich"
}

# ==============================================================================
# TEST GROUP: Vertical Alignment with Various Content Types
# ==============================================================================

@test "vertical alignment: plain ASCII text" {
    output=$(show_header_box "Test" "Plain ASCII text" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: single emoji at start" {
    output=$(show_header_box "Test" "📁 file.txt" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: two emojis (issue #68 example)" {
    output=$(show_header_box "Tild Menu" "📁 ynm  •  🌿" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: three emojis" {
    output=$(show_header_box "Test" "📁 🌿 🎉 Three emojis" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: CJK characters" {
    output=$(show_header_box "Test" "中文字符测试" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: mixed emoji and CJK" {
    output=$(show_header_box "Test" "Mix 📁 emoji 中文 CJK" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: emoji at end of line" {
    output=$(show_header_box "Test" "Text ending with emoji 📁" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: only emojis" {
    output=$(show_header_box "Test" "📁🌿🎉😀" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

# ==============================================================================
# TEST GROUP: show_box Vertical Alignment
# ==============================================================================

@test "vertical alignment: show_box with emoji" {
    output=$(show_box info "Status" "📁 repo • 🌿 branch" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: show_box with CJK" {
    output=$(show_box warning "Chinese" "中文字符" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: show_box with mixed content" {
    output=$(show_box success "Mixed" "Text 📁 emoji 中文 CJK" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

# ==============================================================================
# TEST GROUP: _display_width Function Tests
# ==============================================================================

@test "_display_width: ASCII text returns correct width" {
    width=$(_display_width "Hello World")
    [ "$width" -eq 11 ]
}

@test "_display_width: single emoji counted as width 2" {
    width=$(_display_width "📁 test")
    # 📁 = 2, space = 1, test = 4, total = 7
    [ "$width" -eq 7 ]
}

@test "_display_width: two emojis counted correctly" {
    width=$(_display_width "📁 🌿 test")
    # 📁 = 2, space = 1, 🌿 = 2, space = 1, test = 4, total = 10
    [ "$width" -eq 10 ]
}

@test "_display_width: CJK characters counted as width 2" {
    width=$(_display_width "中文")
    # Each CJK character is width 2, so 2 chars = 4
    [ "$width" -eq 4 ]
}

@test "_display_width: handles ANSI escape codes" {
    # ANSI codes should be stripped before width calculation
    width=$(_display_width $'\e[31mRed\e[0m')
    [ "$width" -eq 3 ]
}

# ==============================================================================
# TEST GROUP: _pad_to_width Function Tests
# ==============================================================================

@test "_pad_to_width: ASCII text padded correctly" {
    result=$(_pad_to_width "test" 10)
    width=$(_display_width "$result")
    [ "$width" -eq 10 ]
}

@test "_pad_to_width: emoji text padded correctly" {
    result=$(_pad_to_width "📁 test" 15)
    width=$(_display_width "$result")
    [ "$width" -eq 15 ]
}

@test "_pad_to_width: CJK text padded correctly" {
    result=$(_pad_to_width "中文" 10)
    width=$(_display_width "$result")
    [ "$width" -eq 10 ]
}

@test "_pad_to_width: no padding when already at target width" {
    # "test" is 4 chars wide
    result=$(_pad_to_width "test" 4)
    width=$(_display_width "$result")
    [ "$width" -eq 4 ]
}

@test "_pad_to_width: handles text wider than target" {
    # Should return text as-is without truncation
    result=$(_pad_to_width "very long text" 5)
    # Should contain the original text
    [[ "$result" == *"very long text"* ]]
}

# ==============================================================================
# TEST GROUP: Edge Cases
# ==============================================================================

@test "vertical alignment: empty subtitle" {
    output=$(show_header_box "Title" "" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: very long emoji line (wrapping)" {
    output=$(show_header_box "Test" "📁 🌿 🎉 😀 😁 😂 🤣 😃 😄 😅 Long line with many emojis that should wrap" 2>&1)

    # Should still have consistent width even with wrapping
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: special symbols that render as width 1" {
    # These should be counted as width 1 (not width 2)
    output=$(show_header_box "Test" "✓ ✗ ⚠ ℹ Symbols" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}
