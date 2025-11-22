#!/usr/bin/env bats
# BATS tests for vertical bar alignment in boxes
# Tests ensure that right edges of boxes align correctly regardless of emoji/CJK content

# Load test helpers
BATS_TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
PROJECT_ROOT="$(cd "$BATS_TEST_DIR/../.." && pwd)"

# Load independent width calculator (does NOT use oiseau's _display_width)
source "$BATS_TEST_DIR/helpers/independent_width.bash"

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
# Uses INDEPENDENT implementation, NOT oiseau's _display_width
measure_line_width() {
    local line="$1"
    local clean=$(strip_ansi "$line")
    # Use independent Python/Perl width calculator
    python_display_width "$clean"
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

@test "vertical alignment: emoji stripped from input" {
    # Emoji are now stripped by _escape_input, so "📁 file.txt" becomes " file.txt"
    output=$(show_header_box "Test" "📁 file.txt" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # Verify emoji was stripped
    [[ "$output" =~ "file.txt" ]]
    [[ ! "$output" =~ "📁" ]]
}

@test "vertical alignment: multiple emoji stripped (issue #68 fixed)" {
    # Multiple emoji are stripped, "📁 ynm  •  🌿" becomes " ynm    "
    output=$(show_header_box "Tild Menu" "📁 ynm  •  🌿" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # Verify emoji were stripped
    [[ "$output" =~ "ynm" ]]
    [[ ! "$output" =~ "📁" ]]
    [[ ! "$output" =~ "🌿" ]]
}

@test "vertical alignment: emoji stripped - three emojis" {
    box_output=$(show_header_box "Test" "📁 🌿 🎉 Three emojis" 2>&1)

    run check_box_width_consistency "$box_output" 60
    [ "$status" -eq 0 ]

    # Verify emoji stripped, ASCII kept
    [[ "$box_output" =~ "Three" ]]
    [[ "$box_output" =~ "emojis" ]]
}

@test "vertical alignment: CJK characters stripped" {
    output=$(show_header_box "Test" "中文字符测试" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # All CJK stripped, only empty padding remains
    [[ ! "$output" =~ "中文" ]]
}

@test "vertical alignment: mixed emoji and CJK stripped" {
    output=$(show_header_box "Test" "Mix 📁 emoji 中文 CJK" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # ASCII preserved, emoji/CJK stripped
    [[ "$output" =~ "Mix" ]]
    [[ "$output" =~ "emoji" ]]
    [[ "$output" =~ "CJK" ]]
    [[ ! "$output" =~ "📁" ]]
    [[ ! "$output" =~ "中文" ]]
}

@test "vertical alignment: emoji at end stripped" {
    output=$(show_header_box "Test" "Text ending with emoji 📁" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    [[ "$output" =~ "Text ending with emoji" ]]
    [[ ! "$output" =~ "📁" ]]
}

@test "vertical alignment: only emojis results in empty" {
    output=$(show_header_box "Test" "📁🌿🎉😀" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # All emoji stripped, box still renders (just empty content)
}

# ==============================================================================
# TEST GROUP: show_box Vertical Alignment
# ==============================================================================

@test "vertical alignment: show_box emoji stripped" {
    output=$(show_box info "Status" "📁 repo • 🌿 branch" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # Emoji stripped, ASCII kept
    [[ "$output" =~ "repo" ]]
    [[ "$output" =~ "branch" ]]
    [[ ! "$output" =~ "📁" ]]
    [[ ! "$output" =~ "🌿" ]]
}

@test "vertical alignment: show_box CJK stripped" {
    output=$(show_box warning "Chinese" "中文字符" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "vertical alignment: show_box mixed content stripped" {
    output=$(show_box success "Mixed" "Text 📁 emoji 中文 CJK" 2>&1)

    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]

    # ASCII preserved, emoji/CJK stripped
    [[ "$output" =~ "Text" ]]
    [[ "$output" =~ "emoji" ]]
    [[ "$output" =~ "CJK" ]]
    [[ ! "$output" =~ "📁" ]]
    [[ ! "$output" =~ "中文" ]]
}

# ==============================================================================
# TEST GROUP: _display_width Function Tests
# ==============================================================================

@test "_display_width: ASCII text returns correct width" {
    width=$(_display_width "Hello World")
    independent=$(python_display_width "Hello World")
    [ "$width" -eq "$independent" ]
    [ "$width" -eq 11 ]
}

@test "_display_width: single emoji counted as width 2" {
    width=$(_display_width "📁 test")
    independent=$(python_display_width "📁 test")
    [ "$width" -eq "$independent" ]
    # 📁 = 2, space = 1, test = 4, total = 7
    [ "$width" -eq 7 ]
}

@test "_display_width: two emojis counted correctly" {
    width=$(_display_width "📁 🌿 test")
    independent=$(python_display_width "📁 🌿 test")
    [ "$width" -eq "$independent" ]
    # 📁 = 2, space = 1, 🌿 = 2, space = 1, test = 4, total = 10
    [ "$width" -eq 10 ]
}

@test "_display_width: CJK characters counted as width 2" {
    width=$(_display_width "中文")
    independent=$(python_display_width "中文")
    [ "$width" -eq "$independent" ]
    # Each CJK character is width 2, so 2 chars = 4
    [ "$width" -eq 4 ]
}

@test "_display_width: handles ANSI escape codes" {
    # ANSI codes should be stripped before width calculation
    width=$(_display_width $'\e[31mRed\e[0m')
    independent=$(python_display_width $'\e[31mRed\e[0m')
    [ "$width" -eq "$independent" ]
    [ "$width" -eq 3 ]
}

# ==============================================================================
# TEST GROUP: _pad_to_width Function Tests
# ==============================================================================

@test "_pad_to_width: ASCII text padded correctly" {
    result=$(_pad_to_width "test" 10)
    width=$(python_display_width "$result")
    [ "$width" -eq 10 ]
}

@test "_pad_to_width: escaped emoji text padded correctly" {
    # _pad_to_width expects ASCII-only input (after _escape_input)
    # Test the full pipeline: escape then pad
    escaped=$(_escape_input "📁 test")
    result=$(_pad_to_width "$escaped" 15)
    width=$(python_display_width "$result")
    [ "$width" -eq 15 ]
}

@test "_pad_to_width: escaped CJK text padded correctly" {
    # _pad_to_width expects ASCII-only input (after _escape_input)
    # Test the full pipeline: escape then pad
    escaped=$(_escape_input "中文")
    result=$(_pad_to_width "$escaped" 10)
    width=$(python_display_width "$result")
    [ "$width" -eq 10 ]
}

@test "_pad_to_width: no padding when already at target width" {
    # "test" is 4 chars wide
    result=$(_pad_to_width "test" 4)
    width=$(python_display_width "$result")
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
