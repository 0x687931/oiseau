#!/bin/bash
# Interactive Menu Demo
# Shows interactive menus with arrow key navigation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/oiseau.sh"

clear

show_header_box "Interactive Menu Demo" "Arrow key navigation and selection"

echo ""
echo -e "${COLOR_MUTED}Demo 1: Single Select Menu${RESET}"
echo ""

# Demo 1: Single select
menu_items=(
    "View Project Status"
    "Build Application"
    "Run Tests"
    "Deploy to Staging"
    "View Logs"
    "Exit"
)

selected=$(ask_list "Choose an action:" menu_items)
if [ $? -eq 0 ]; then
    show_success "You selected: $selected"
else
    show_error "Selection cancelled"
    exit 1
fi

echo ""
echo -e "${COLOR_MUTED}Press Enter to continue to Demo 2...${RESET}"
read -r

clear

# Demo 2: Multi-select
show_header_box "Interactive Menu Demo - Part 2" "Multi-select with Space to toggle"

echo ""
echo -e "${COLOR_MUTED}Demo 2: Multi-Select Menu${RESET}"
echo ""

files=(
    "src/main.sh"
    "src/utils.sh"
    "tests/test_main.sh"
    "tests/test_utils.sh"
    "README.md"
    "LICENSE"
)

selected_files=($(ask_list "Select files to stage:" files "multi"))
if [ $? -eq 0 ] && [ ${#selected_files[@]} -gt 0 ]; then
    show_success "You selected ${#selected_files[@]} file(s):"
    for file in "${selected_files[@]}"; do
        echo "  • $file"
    done
else
    show_error "No files selected"
    exit 1
fi

echo ""
echo -e "${COLOR_MUTED}Press Enter to continue to Demo 3...${RESET}"
read -r

clear

# Demo 3: Choice menu
show_header_box "Interactive Menu Demo - Part 3" "Quick choice menus"

echo ""
echo -e "${COLOR_MUTED}Demo 3: Yes/No Choice${RESET}"
echo ""

if ask_choice "Do you want to continue?"; then
    show_success "You chose: Yes"
else
    show_info "You chose: No"
fi

echo ""
echo -e "${COLOR_MUTED}Press Enter to continue to Demo 4...${RESET}"
read -r

clear

show_header_box "Interactive Menu Demo - Part 4" "Multi-option choice"

echo ""
echo -e "${COLOR_MUTED}Demo 4: Multi-Option Choice${RESET}"
echo ""

options=("Save" "Discard" "Cancel")
choice=$(ask_choice "You have unsaved changes. What would you like to do?" options)

case "$choice" in
    "Save")
        show_success "Changes saved!"
        ;;
    "Discard")
        show_warning "Changes discarded"
        ;;
    "Cancel")
        show_info "Operation cancelled"
        ;;
esac

echo ""
echo ""
show_header_box "Demo Complete" "Interactive menus with arrow keys and quick choices"

echo ""
echo -e "${COLOR_SUCCESS}${BOLD}Summary:${RESET}"
echo ""
echo -e "  ${COLOR_SUCCESS}✓${RESET} ask_list() - Interactive single/multi-select with arrow keys"
echo -e "  ${COLOR_SUCCESS}✓${RESET} ask_choice() - Quick yes/no and multi-option menus"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Arrow keys (↑↓) or j/k for navigation"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Space to toggle checkboxes (multi-select)"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Enter to confirm, Q/Esc to cancel"
echo ""

echo -e "${COLOR_MUTED}Key features:${RESET}"
echo -e "  • Real-time visual feedback with cursor indicator"
echo -e "  • Mode-aware rendering (rich/color/plain)"
echo -e "  • Automatic TTY detection with numbered fallback"
echo -e "  • Input validation and error handling"
echo ""
