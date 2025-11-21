#!/usr/bin/env bash
#===============================================================================
# ORTHOGONAL VALIDATION: show_header_box()
#===============================================================================
# Independent byte-count validation for show_header_box alignment
# Method: Count bytes in each line, verify all content lines are equal
#===============================================================================

cd "$(dirname "$0")/../.."
export OISEAU_MODE=rich
source ./oiseau.sh 2>/dev/null

PASS=0
FAIL=0

validate_box() {
    local title="$1"
    local subtitle="$2"
    local test_name="$3"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Generate output
    output=$(show_header_box "$title" "$subtitle")

    # Strip ANSI codes
    clean=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')

    # Collect byte counts for content lines (skip borders)
    declare -a byte_counts
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue

        # Only check lines with vertical borders (┃)
        if [[ "$line" =~ ┃.*┃ ]]; then
            bytes=$(printf '%s' "$line" | wc -c | tr -d ' ')
            byte_counts+=("$bytes")
        fi
    done <<< "$clean"

    # Check if all byte counts are equal
    if [ ${#byte_counts[@]} -eq 0 ]; then
        echo "❌ FAIL: No content lines found"
        ((FAIL++))
        return
    fi

    first_count="${byte_counts[0]}"
    all_equal=true

    for count in "${byte_counts[@]}"; do
        if [ "$count" != "$first_count" ]; then
            all_equal=false
            break
        fi
    done

    if [ "$all_equal" = true ]; then
        echo "✅ PASS: All ${#byte_counts[@]} lines have $first_count bytes"
        ((PASS++))
    else
        echo "❌ FAIL: Byte counts differ:"
        for i in "${!byte_counts[@]}"; do
            echo "   Line $((i+1)): ${byte_counts[$i]} bytes"
        done
        ((FAIL++))
    fi

    echo ""
}

echo "═══════════════════════════════════════════"
echo " ORTHOGONAL VALIDATION: show_header_box()"
echo "═══════════════════════════════════════════"
echo ""

# Test all combinations
validate_box "Plain ASCII" "No special chars" "Plain text"
validate_box "📁 Single emoji" "Subtitle" "Single emoji in title"
validate_box "📁 🌿 🎉 Multiple" "Sub" "Multiple emojis"
validate_box "中文标题" "日本語" "CJK characters"
validate_box "📁 Mix 中文 text" "Everything: 📁 中文 🌿" "Mixed everything"
validate_box "A" "" "Short title, no subtitle"
validate_box "" "Just subtitle 📁" "No title"
validate_box "Very long title that should wrap to multiple lines with emoji 📁 and CJK 中文 mixed in" "Also a long subtitle" "Long wrapping text"

echo "═══════════════════════════════════════════"
echo " RESULTS"
echo "═══════════════════════════════════════════"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo "✅ show_header_box() alignment: VALIDATED"
    exit 0
else
    echo "❌ show_header_box() alignment: BROKEN"
    exit 1
fi
