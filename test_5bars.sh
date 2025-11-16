#!/bin/bash
# Test 5 progress bars to verify generic support

cd "$(dirname "$0")"
source ./oiseau.sh

echo "Testing with 5 progress bars..."
echo ""
echo ""  # Reserve 5 lines
echo ""
echo ""
echo ""
echo ""

# Pre-declare 5 progress bars (eliminates race conditions)
init_progress_bars 5

for i in {0..100}; do
  # Update all 5 bars simultaneously
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 2" 2
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 3" 3
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 4" 4
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Bar 5" 5
  sleep 0.03
done

# Move cursor past the progress bars
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Done!"
