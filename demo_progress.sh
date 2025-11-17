#!/usr/bin/env bash
# Demo: Multiline progress bars with race condition mitigations

cd "$(dirname "$0")"
source ./oiseau.sh

# Pre-declare 3 progress bars (eliminates race conditions)
init_progress_bars 3

# Reserve 3 lines
echo ""
echo ""
echo ""

for i in $(seq 0 10 100); do
  # Update all 3 bars simultaneously in different modes
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Rich mode" 1
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Color mode" 2
  OISEAU_MODE=plain OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Plain mode" 3
  sleep 0.3
done

# Move cursor past the progress bars
echo ""
echo ""
echo ""
