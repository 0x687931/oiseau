#!/usr/bin/env bash
#===============================================================================
# ORTHOGONAL VALIDATION: show_box()
#===============================================================================
# Independent byte-count validation for show_box alignment
# Tests: error, warning, info, success types with emoji/CJK
#===============================================================================

cd "$(dirname "$0")/../.."
export OISEAU_MODE=rich
source ./oiseau.sh 2>/dev/null

PASS=0
FAIL=0

validate_box() {
    local type="$1"
    local title="$2"
    local message="$3"
    local test_name="$4"

    echo "Test: $test_name"

    output=$(show_box "$type" "$title" "$message")
    clean=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')

    declare -a byte_counts
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [[ "$line" =~ ┃.*┃ ]]; then
            bytes=$(printf '%s' "$line" | wc -c | tr -d ' ')
            byte_counts+=("$bytes")
        fi
    done <<< "$clean"

    first_count="${byte_counts[0]}"
    all_equal=true
    for count in "${byte_counts[@]}"; do
        [ "$count" != "$first_count" ] && all_equal=false && break
    done

    if [ "$all_equal" = true ]; then
        echo "  ✅ PASS: All lines $first_count bytes"
        ((PASS++))
    else
        echo "  ❌ FAIL: Misaligned"
        ((FAIL++))
    fi
}

echo "═══════════════════════════════════════════"
echo " ORTHOGONAL VALIDATION: show_box()"
echo "═══════════════════════════════════════════"
echo ""

# Test all box types with various content
validate_box "error" "Plain error" "Message" "Error box - plain"
validate_box "error" "📁 Emoji error" "Error 📁" "Error box - emoji"
validate_box "warning" "中文 Warning" "警告信息" "Warning box - CJK"
validate_box "success" "📁 Success 中文" "Mixed 📁 中文 content" "Success - mixed"
validate_box "info" "Long title with emoji 📁 and CJK 中文 that wraps" "Also long message" "Info - wrapping"

# Test with commands
output=$(show_box "error" "📁 Error" "Fix needed" "command 1" "command 📁 2" "中文 command")
clean=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')
declare -a byte_counts
while IFS= read -r line; do
    [ -z "$line" ] && continue
    [[ "$line" =~ ┃.*┃ ]] && byte_counts+=($(printf '%s' "$line" | wc -c | tr -d ' '))
done <<< "$clean"
first="${byte_counts[0]}"
all_eq=true
for c in "${byte_counts[@]}"; do [ "$c" != "$first" ] && all_eq=false && break; done
if [ "$all_eq" = true ]; then
    echo "Test: Error with commands"
    echo "  ✅ PASS: All lines $first bytes"
    ((PASS++))
else
    echo "Test: Error with commands"
    echo "  ❌ FAIL: Misaligned"
    ((FAIL++))
fi

echo ""
echo "═══════════════════════════════════════════"
echo " RESULTS"
echo "═══════════════════════════════════════════"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

[ "$FAIL" -eq 0 ] && echo "✅ show_box() alignment: VALIDATED" && exit 0
echo "❌ show_box() alignment: BROKEN" && exit 1
