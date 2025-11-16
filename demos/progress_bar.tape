# VHS Tape: Progress Bar Widget - All Three Modes Side-by-Side
# Shows rich, color, and plain modes rendering simultaneously

Output demos/progress_bar.gif

# Terminal settings
Set Width 800
Set Height 400
Set FontSize 14
Set Theme "Dracula"

# Show the demo description
Type "# Demo: Progress bar in all 3 modes"
Enter
Sleep 800ms

# Source the library (hidden)
Hide
Type "source ./oiseau.sh"
Enter
Show
Sleep 200ms

# Show the code (without exports)
Type "for i in {0..100}; do"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Rich mode'"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Color mode'"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Plain mode'"
Enter
Sleep 300ms

Type "  sleep 0.05"
Enter
Sleep 300ms

Type "done"
Enter
Sleep 1s

# Reserve lines for the three progress bars
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter
Sleep 500ms

# Now execute the actual loop with all 3 modes (hidden setup)
Hide
Type "for i in {0..100}; do"
Enter
Type "  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Rich mode' 1"
Enter
Type "  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Color mode' 2"
Enter
Type "  UI_DISABLE=1 OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Plain mode' 3"
Enter
Type "  sleep 0.05"
Enter
Type "done"
Enter
Show

# Wait for animation to complete
Sleep 6s

# Final pause to view all three completed bars
Sleep 3s
