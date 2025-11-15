#!/bin/bash
# Simple benchmark to measure performance improvements

source ./oiseau.sh

echo "=== Oiseau Performance Benchmark ==="
echo "Bash version: ${BASH_VERSION}"
echo "Caching enabled: ${OISEAU_HAS_CACHE:-0}"
echo "Perl available: ${OISEAU_HAS_PERL:-0}"
echo ""

# Test 1: Repeated character generation (common in boxes)
echo "Test 1: _repeat_char (1000 iterations of 60-char line)"
start=$(date +%s%N)
for i in {1..1000}; do
    _repeat_char "-" 60 >/dev/null
done
end=$(date +%s%N)
elapsed=$(( (end - start) / 1000000 ))
echo "  Time: ${elapsed}ms"
echo ""

# Test 2: Display width calculations (used in padding)
echo "Test 2: _display_width (500 iterations on varied strings)"
start=$(date +%s%N)
for i in {1..100}; do
    _display_width "Simple ASCII text" >/dev/null
    _display_width "Text with icon ✓ check" >/dev/null
    _display_width "Deployment Complete" >/dev/null
    _display_width "Error: Failed to connect" >/dev/null
    _display_width "Step 2 of 4 › Building Docker image" >/dev/null
done
end=$(date +%s%N)
elapsed=$(( (end - start) / 1000000 ))
echo "  Time: ${elapsed}ms"
echo ""

# Test 3: Complete box rendering (real-world scenario)
echo "Test 3: show_box (100 complete box renders)"
start=$(date +%s%N)
for i in {1..100}; do
    show_box error "Test Error" "This is a test error message" "command 1" "command 2" >/dev/null
done
end=$(date +%s%N)
elapsed=$(( (end - start) / 1000000 ))
echo "  Time: ${elapsed}ms"
echo ""

# Test 4: Progress bar updates (animation scenario)
echo "Test 4: show_progress_bar (100 updates)"
start=$(date +%s%N)
for i in {1..100}; do
    show_progress_bar "$i" 100 "Testing" >/dev/null
done
end=$(date +%s%N)
elapsed=$(( (end - start) / 1000000 ))
echo "  Time: ${elapsed}ms"
echo ""

echo "=== Benchmark Complete ==="
