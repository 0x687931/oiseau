#!/usr/bin/env bash
#===============================================================================
# MASTER VALIDATION RUNNER
#===============================================================================
# Runs all orthogonal validation tests for emoji/CJK alignment
# Each validator uses independent byte-counting (no shared code with impl)
#===============================================================================

cd "$(dirname "$0")/.."

TOTAL=0
PASSED=0
FAILED=0

run_validator() {
    local script="$1"
    local name=$(basename "$script" .sh | sed 's/validate_//')

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " Running: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    ((TOTAL++))

    if "$script"; then
        ((PASSED++))
        echo "✅ $name: PASSED"
    else
        ((FAILED++))
        echo "❌ $name: FAILED"
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo " OISEAU EMOJI/CJK ALIGNMENT VALIDATION SUITE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Method: Independent byte-count validation"
echo "No shared code paths with implementation"
echo ""

# Run all validators
for validator in tests/validation/validate_*.sh; do
    [ -f "$validator" ] && run_validator "$validator"
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " FINAL RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Total validators:  $TOTAL"
echo "Passed:            $PASSED"
echo "Failed:            $FAILED"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "✅ ALL VALIDATIONS PASSED"
    echo ""
    echo "Emoji/CJK alignment is working correctly across all UI elements."
    echo "All borders are byte-aligned for consistent visual rendering."
    exit 0
else
    echo "❌ SOME VALIDATIONS FAILED"
    echo ""
    echo "$FAILED out of $TOTAL validators failed."
    echo "Review the output above for details."
    exit 1
fi
