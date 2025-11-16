#!/bin/bash
# Test script for progress_bar demo
# This replicates exactly what the VHS tape will do

cd "$(dirname "$0")/.."

# Part 1: Echo example code (display only - not executed)
echo '# Demo: Progress bar in all 3 modes'
echo 'source ./oiseau.sh'
echo 'for i in {0..100}; do'
echo '  show_progress_bar $i 100 Processing'
echo '  sleep 0.05'
echo 'done'
echo ''
sleep 1

# Part 2: Source library and reserve space for progress bars
source ./oiseau.sh
echo ''
echo ''
echo ''
echo ''

# Part 3: Execute the multi-line progress bar demo
# Lines use RELATIVE positioning from current cursor location
# Line 1 prints on current line and saves cursor
# Lines 2+ restore cursor and move down relatively
for i in {0..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Rich mode" 1
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Color mode" 2
  OISEAU_MODE=plain OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Plain mode" 3
  sleep 0.05
done

# Move past the 3 progress bars
echo ""
echo ""
echo ""
echo "Done!"
