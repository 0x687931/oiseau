#!/usr/bin/env bash
#===============================================================================
# TEXT WRAPPING VALIDATOR
#===============================================================================
# Validates that text wrapping doesn't break multi-byte characters and
# respects actual display width boundaries.
#
# Method:
# 1. Generate wrapped text with emoji/CJK
# 2. Check each line doesn't exceed max width (byte count)
# 3. Verify no broken UTF-8 sequences (multi-byte chars split)
# 4. Verify ANSI codes don't affect wrap position
#===============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$SCRIPT_DIR"

source ./oiseau.sh 2>/dev/null || true

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✓ $1"
}

fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✗ $1"
}

test_wrap() {
    local test_name="$1"
    local content="$2"
    local max_width="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "Test: $test_name"
    echo "Content: '$content'"
    echo "Max width: $max_width columns"

    # Generate wrapped output
    local wrapped
    if ! wrapped=$(wrap_text "$content" "$max_width" 2>&1); then
        fail "wrap_text failed to execute"
        return
    fi

    echo "Output:"
    echo "$wrapped" | sed 's/^/  | /'
    echo ""

    # Validation 1: Check UTF-8 validity (no broken multi-byte chars)
    local line_num=0
    local utf8_valid=true
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        if ! echo "$line" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
            fail "Line $line_num has broken UTF-8 sequence"
            utf8_valid=false
        fi
    done <<< "$wrapped"

    if [ "$utf8_valid" = true ]; then
        pass "All lines have valid UTF-8"
    fi

    # Validation 2: Check line width doesn't exceed maximum
    local width_valid=true
    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Strip ANSI codes
        local clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Count actual bytes
        local byte_count=$(printf '%s' "$clean" | wc -c | tr -d ' ')

        # Count display width using wc -L (should be <= max_width)
        local display_width=$(printf '%s' "$clean" | wc -L | tr -d ' ')

        if [ "$display_width" -gt "$max_width" ]; then
            fail "Line $line_num display width $display_width exceeds max $max_width"
            width_valid=false
        fi
    done <<< "$wrapped"

    if [ "$width_valid" = true ]; then
        pass "All lines within max width"
    fi

    # Validation 3: Verify content is preserved (no characters lost)
    local original_clean=$(echo "$content" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
    local wrapped_clean=$(echo "$wrapped" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n' | tr -d ' ')

    # Remove spaces for comparison (wrapping may add/change whitespace)
    original_clean=$(echo "$original_clean" | tr -d ' ')

    if [ "$original_clean" = "$wrapped_clean" ]; then
        pass "Content preserved (no chars lost)"
    else
        fail "Content changed during wrapping"
        echo "    Original: '$original_clean'"
        echo "    Wrapped:  '$wrapped_clean'"
    fi
}

echo "=== TEXT WRAPPING VALIDATION ==="
echo ""
echo "Testing wrap_text() function with various content types"

# Check if wrap_text exists
if ! type wrap_text >/dev/null 2>&1; then
    echo "❌ wrap_text function not found in oiseau.sh"
    echo "Skipping wrapping validation tests"
    exit 1
fi

# Test cases
test_wrap "Plain ASCII text" \
    "This is a long line of plain ASCII text that should wrap at the specified width boundary" \
    40

test_wrap "Text with single emoji" \
    "This is a long line with a 📁 folder emoji that should wrap correctly without breaking the emoji character" \
    40

test_wrap "Text with multiple emojis" \
    "This line has multiple emojis: 📁 file, 🌿 branch, 🎉 party and should wrap them all correctly" \
    40

test_wrap "Text with CJK characters" \
    "This line has CJK characters: 中文字符 and should wrap them correctly without splitting multi-byte sequences" \
    40

test_wrap "Mixed emoji and CJK" \
    "Mixed content: 📁 folder emoji and 中文 Chinese chars together in a long line that needs wrapping" \
    40

test_wrap "Emoji at boundary" \
    "Short text ending with emoji 📁" \
    25

test_wrap "Very long word" \
    "Supercalifragilisticexpialidocious" \
    20

echo ""
echo "=== SUMMARY ==="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo "✅ All wrapping validation tests passed"
    exit 0
else
    echo ""
    echo "❌ Some wrapping validation tests failed"
    exit 1
fi
