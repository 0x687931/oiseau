# VHS Tape: Progress Bar Widget - All Three Modes Side-by-Side
# Shows rich, color, and plain modes rendering simultaneously

Output demos/progress_bar.gif

# Terminal settings
Set Width 800
Set Height 400
Set FontSize 14
Set Theme "Dracula"

# Display example code as comments (not executed)
Type "# Demo: Progress bar in all 3 modes"
Enter
Sleep 500ms

Type "# source ./oiseau.sh"
Enter
Sleep 200ms

Type "# for i in {0..100}; do"
Enter
Sleep 200ms

Type "#   show_progress_bar \$i 100 'Processing'"
Enter
Sleep 200ms

Type "#   sleep 0.05"
Enter
Sleep 200ms

Type "# done"
Enter
Sleep 1s

# Now execute the actual demo code (hidden)
Hide
Type "source ./oiseau.sh"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "for i in {0..100}; do"
Enter
Type "  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar \$i 100 'Rich mode' 1"
Enter
Type "  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar \$i 100 'Color mode' 2"
Enter
Type "  OISEAU_MODE=plain OISEAU_PROGRESS_ANIMATE=1 show_progress_bar \$i 100 'Plain mode' 3"
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
