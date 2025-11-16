# VHS Tape: Progress Bar Widget - All Three Modes Side-by-Side
# Shows rich, color, and plain modes rendering simultaneously

Output demos/progress_bar.gif

# Terminal settings
Set Width 800
Set Height 500
Set FontSize 14
Set Theme "Dracula"

# Show the demo script
Type "# Demo: Progress bar in all 3 modes simultaneously"
Enter
Sleep 800ms

Type "source ./oiseau.sh"
Enter
Sleep 500ms

Type ""
Enter
Type "for i in {0..100}; do"
Enter
Sleep 300ms

Type "  # Rich mode (UTF-8 + colors)"
Enter
Sleep 200ms

Type "  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 \\"
Enter
Sleep 200ms

Type "    show_progress_bar $i 100 'Rich mode'"
Enter
Sleep 300ms

Type ""
Enter
Type "  # Color mode (ASCII + colors)"
Enter
Sleep 200ms

Type "  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 \\"
Enter
Sleep 200ms

Type "    show_progress_bar $i 100 'Color mode'"
Enter
Sleep 300ms

Type ""
Enter
Type "  # Plain mode (ASCII only)"
Enter
Sleep 200ms

Type "  UI_DISABLE=1 OISEAU_PROGRESS_ANIMATE=1 \\"
Enter
Sleep 200ms

Type "    show_progress_bar $i 100 'Plain mode'"
Enter
Sleep 300ms

Type ""
Enter
Type "  sleep 0.05"
Enter
Sleep 300ms

Type "done"
Enter

# Wait for animation to complete
Sleep 6s

# Final pause to view all three completed bars
Sleep 3s
