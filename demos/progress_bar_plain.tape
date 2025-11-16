# VHS Tape: Progress Bar Widget - Plain Mode (ASCII only, no colors)
# Demonstrates show_progress_bar in plain text mode (pipes/redirects)

Output demos/progress_bar_plain.gif

# Terminal settings
Set Width 800
Set Height 300
Set FontSize 14
Set Theme "Dracula"

# Force plain mode (no colors, no UTF-8)
Type "export UI_DISABLE=1"
Enter
Sleep 500ms

# Source oiseau library
Type "source ./oiseau.sh"
Enter
Sleep 500ms

# Show the progress bar animation
Type "for i in {0..100}; do show_progress_bar $i 100 'Downloading data'; sleep 0.05; done"
Enter

# Wait for completion
Sleep 6s

# Screenshot final state
Sleep 500ms
