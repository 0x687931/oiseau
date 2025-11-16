#!/bin/bash
# Test multiple sequential progress bar groups to verify auto-reset

cd "$(dirname "$0")"
source ./oiseau.sh

echo "=== GROUP 1: 3 Progress Bars ==="
echo ""
echo ""
echo ""
echo ""

init_progress_bars 3

for i in {0..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 1 - Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 1 - Bar 2" 2
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 1 - Bar 3" 3
  sleep 0.02
done

sleep 0.1  # Let terminal finish rendering final frame
echo ""
echo ""
echo ""
echo "Group 1 Complete!"
echo ""
sleep 1

echo "=== GROUP 2: 2 Progress Bars ==="
echo ""
echo ""
echo ""

init_progress_bars 2

for i in {0..100}; do
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 2 - Bar 1" 1
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 2 - Bar 2" 2
  sleep 0.02
done

sleep 0.1  # Let terminal finish rendering final frame
echo ""
echo ""
echo "Group 2 Complete!"
echo ""
sleep 1

echo "=== GROUP 3: 5 Progress Bars ==="
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

init_progress_bars 5

for i in {0..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 3 - Bar 1" 1
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 3 - Bar 2" 2
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 3 - Bar 3" 3
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 3 - Bar 4" 4
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar "$i" 100 "Group 3 - Bar 5" 5
  sleep 0.01
done

sleep 0.1  # Let terminal finish rendering final frame
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Group 3 Complete!"
echo ""
echo "✓ All groups completed successfully!"
