#!/bin/bash
# Test script for progress_bar demo
# This mirrors what progress_bar.tape will execute

cd "$(dirname "$0")/.."
source ./oiseau.sh

echo "# Demo: Progress bar in all 3 modes"
sleep 1

for i in {0..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Rich mode'
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Color mode'
  UI_DISABLE=1 OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Plain mode'
  sleep 0.05
done

echo ""
echo "Done!"
