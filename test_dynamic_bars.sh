#!/bin/bash
# Test dynamically adding bars mid-execution to check for race conditions

cd "$(dirname "$0")"
source ./oiseau.sh

echo "=== TEST: Adding bars dynamically ==="
echo ""
echo ""
echo ""
echo ""

# Pre-declare 3 bars (eliminates the 1-frame glitch from Race Condition #2)
init_progress_bars 3

# Start with 2 bars
for i in {0..30}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 2" 2
  sleep 0.05
done

# Add a 3rd bar mid-execution
for i in {31..70}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 2" 2
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 3" 3
  sleep 0.05
done

# Complete all 3 bars
for i in {71..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 2" 2
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 3" 3
  sleep 0.05
done

echo ""
echo ""
echo ""
echo ""
echo "Done! Did Bar 3 appear correctly at i=31?"
