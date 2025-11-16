#!/bin/bash
# Test script for progress_bar demo
# This mirrors what progress_bar.tape will execute

cd "$(dirname "$0")/.."
source ./oiseau.sh

echo "# Demo: Progress bar in all 3 modes"
sleep 1
echo ""
echo ""  # Reserve 3 lines
echo ""
echo ""

for i in {0..100}; do
  # Update all 3 bars simultaneously on different lines
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Rich mode" 1
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Color mode" 2
  UI_DISABLE=1 OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Plain mode" 3
  sleep 0.05
done

# Move past the 3 progress bars
echo ""
echo ""
echo ""
echo "Done!"
