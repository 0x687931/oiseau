#!/usr/bin/env bash
# Oiseau Gallery - Showcase all available widgets
# Run this script to see all Oiseau UI components in action

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the Oiseau library
source "$SCRIPT_DIR/oiseau.sh"

# ==============================================================================
# GALLERY FUNCTIONS
# ==============================================================================


pause_between_sections() {
    if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
        echo ""
        echo -e "${COLOR_DIM}Press Enter to continue...${RESET}"
        read -r
    else
        sleep 1
    fi
}

# ==============================================================================
# MAIN GALLERY
# ==============================================================================

clear

# Header - demonstrates the new show_header_box widget with emoji
show_header_box "🐦  Oiseau - Modern Terminal UI Library for Bash" "A showcase of all available widgets and components"

echo -e "${COLOR_MUTED}Mode: ${OISEAU_MODE} | Colors: ${OISEAU_HAS_COLOR} | UTF-8: ${OISEAU_HAS_UTF8} | Width: ${OISEAU_WIDTH}${RESET}"

pause_between_sections

# ==============================================================================
# 1. SIMPLE MESSAGES
# ==============================================================================

print_section "1. Simple Status Messages"

echo -e "${COLOR_MUTED}Code:${RESET}"
echo -e "  ${COLOR_CODE}show_success \"Operation completed successfully\"${RESET}"
echo -e "  ${COLOR_CODE}show_error \"Failed to connect to server\"${RESET}"
echo -e "  ${COLOR_CODE}show_warning \"This action cannot be undone\"${RESET}"
echo -e "  ${COLOR_CODE}show_info \"Processing 50 files...\"${RESET}"
echo ""
echo -e "${COLOR_MUTED}Output:${RESET}"
show_success "Operation completed successfully"
show_error "Failed to connect to server"
show_warning "This action cannot be undone"
show_info "Processing 50 files..."

pause_between_sections

# ==============================================================================
# 2. HEADERS
# ==============================================================================

print_section "2. Headers & Titles"

echo -e "${COLOR_MUTED}Code: ${COLOR_CODE}show_header \"Project Setup\"${RESET}"
show_header "Project Setup"

echo -e "${COLOR_MUTED}Code: ${COLOR_CODE}show_subheader \"Configuring dependencies...\"${RESET}"
show_subheader "Configuring dependencies..."

echo ""
echo -e "${COLOR_MUTED}Code: ${COLOR_CODE}show_section_header \"Deploy Application\" 2 4 \"Building Docker image\"${RESET}"
show_section_header "Deploy Application" 2 4 "Building Docker image"

pause_between_sections

# ==============================================================================
# 3. BOXES
# ==============================================================================

print_section "3. Styled Boxes"

echo -e "${COLOR_MUTED}Error Box:${RESET}"
show_box error "Connection Failed" "Unable to connect to database at localhost:5432. Please check if the service is running."

echo ""
echo -e "${COLOR_MUTED}Warning Box with Commands:${RESET}"
show_box warning "Uncommitted Changes" "You have 3 uncommitted files in your working directory." \
    "git add ." \
    "git commit -m 'Save changes'" \
    "git push"

echo ""
echo -e "${COLOR_MUTED}Info Box:${RESET}"
show_box info "New Feature Available" "Version 2.0 includes improved performance and new debugging tools. Update to get the latest features."

echo ""
echo -e "${COLOR_MUTED}Success Box:${RESET}"
show_box success "Deployment Complete" "Your application has been successfully deployed to production. All health checks passed."

pause_between_sections

# ==============================================================================
# 4. PROGRESS BAR
# ==============================================================================

print_section "4. Progress Bar (Now with Animation!)"

echo -e "${COLOR_MUTED}Code:${RESET}"
echo -e "  ${COLOR_CODE}for i in {1..100}; do${RESET}"
echo -e "  ${COLOR_CODE}  show_progress_bar \$i 100 \"Downloading\"${RESET}"
echo -e "  ${COLOR_CODE}  sleep 0.05${RESET}"
echo -e "  ${COLOR_CODE}done${RESET}"
echo ""

echo -e "${COLOR_MUTED}Features:${RESET}"
print_item "Auto-animates in TTY (updates in place)"
print_item "Prints new line in pipes/redirects"
print_item "Customizable width and override controls"
print_item "Input validation and sanitization"
echo ""

echo -e "${COLOR_MUTED}Renders as:${RESET}"
for i in {1..50}; do
    show_progress_bar "$i" 50 "Processing"
    sleep 0.03
done
echo ""

pause_between_sections

# ==============================================================================
# 5. CHECKLIST
# ==============================================================================

print_section "5. Checklist with Status Indicators"

echo -e "${COLOR_MUTED}Code:${RESET}"
echo -e "${COLOR_CODE}  checklist=(${RESET}"
echo -e "${COLOR_CODE}    \"done|Build Docker image|Completed in 45s\"${RESET}"
echo -e "${COLOR_CODE}    \"done|Run unit tests|142 tests passed\"${RESET}"
echo -e "${COLOR_CODE}    \"active|Deploy to staging|In progress...\"${RESET}"
echo -e "${COLOR_CODE}    \"pending|Run integration tests|Waiting\"${RESET}"
echo -e "${COLOR_CODE}    \"pending|Deploy to production|Waiting\"${RESET}"
echo -e "${COLOR_CODE}  )${RESET}"
echo -e "${COLOR_CODE}  show_checklist checklist${RESET}"
echo ""

echo -e "${COLOR_MUTED}Output:${RESET}"
checklist=(
    "done|Build Docker image|Completed in 45s"
    "done|Run unit tests|142 tests passed"
    "active|Deploy to staging|In progress..."
    "pending|Run integration tests|Waiting"
    "pending|Deploy to production|Waiting"
)
show_checklist checklist

echo ""
echo -e "${COLOR_MUTED}With skip status:${RESET}"
checklist_skip=(
    "done|Install dependencies|npm install completed"
    "done|Compile TypeScript|No errors found"
    "skip|Run linter|Skipped (--no-lint flag)"
    "active|Build production bundle|Optimizing..."
)
show_checklist checklist_skip

pause_between_sections

# ==============================================================================
# 6. SUMMARY BOX
# ==============================================================================

print_section "6. Summary Box"

echo -e "${COLOR_MUTED}Code:${RESET}"
echo -e "${COLOR_CODE}  show_summary \"Deployment Summary\" \\${RESET}"
echo -e "${COLOR_CODE}    \"Environment: Production\" \\${RESET}"
echo -e "${COLOR_CODE}    \"Build: #432 (2f3a8c9)\" \\${RESET}"
echo -e "${COLOR_CODE}    \"Duration: 3m 45s\"${RESET}"
echo ""

echo -e "${COLOR_MUTED}Output:${RESET}"
show_summary "Deployment Summary" \
    "Environment: Production" \
    "Build: #432 (2f3a8c9)" \
    "Duration: 3m 45s" \
    "Status: All health checks passed"

pause_between_sections

# ==============================================================================
# 7. FORMATTING HELPERS
# ==============================================================================

print_section "7. Formatting Helpers"

echo -e "${COLOR_MUTED}Key-Value Pairs:${RESET}"
print_kv "Project" "my-awesome-app"
print_kv "Version" "1.2.3"
print_kv "Environment" "production"
print_kv "Status" "running"

echo ""
echo -e "${COLOR_MUTED}Commands:${RESET}"
print_command "npm install"
print_command "npm run build"
print_command "npm test"

echo ""
echo -e "${COLOR_MUTED}Bulleted Items:${RESET}"
print_item "Zero dependencies - pure bash"
print_item "256-color ANSI palette"
print_item "Smart degradation for all terminals"
print_item "30+ reusable widgets"

echo ""
echo -e "${COLOR_MUTED}Numbered Steps:${RESET}"
print_step 1 "Clone the repository"
print_step 2 "Source the oiseau.sh file"
print_step 3 "Start using widgets in your scripts"

echo ""
echo -e "${COLOR_MUTED}Section Titles:${RESET}"
print_section "Configuration"
echo "  Your configuration goes here..."
print_section "Installation"
echo "  Installation steps go here..."

pause_between_sections

# ==============================================================================
# 8. ENHANCED TEXT INPUT (INTERACTIVE)
# ==============================================================================

print_section "8. Enhanced Text Input with Validation"

echo -e "${COLOR_MUTED}Features:${RESET}"
print_item "4 input modes: text, password, email, number"
print_item "Auto-detects password fields from prompt keywords"
print_item "Password masking (• in UTF-8, * in ASCII/Plain)"
print_item "Email and number validation with error messages"
print_item "Input sanitization built-in"
print_item "Validation loops until valid input"
echo ""

echo -e "${COLOR_MUTED}Available modes:${RESET}"
echo ""

echo -e "${COLOR_MUTED}1. Text mode (default):${RESET}"
echo -e "  ${COLOR_CODE}name=\$(ask_input \"Your name\" \"John\")${RESET}"
if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    name=$(ask_input "Your name" "John")
    show_success "You entered: $name"
else
    echo "  (Interactive in real usage)"
fi
echo ""

echo -e "${COLOR_MUTED}2. Password mode (auto-detected):${RESET}"
echo -e "  ${COLOR_CODE}pass=\$(ask_input \"Enter password\")${RESET}"
echo "  Auto-detects keywords: password, pass, secret, token, key, api"
if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    pass=$(ask_input "Enter password")
    if [ "$OISEAU_MODE" = "rich" ]; then
        show_success "Password set (hidden as ••••)"
    else
        show_success "Password set (hidden as ****)"
    fi
else
    echo "  (Interactive - shows • in UTF-8, * in ASCII)"
fi
echo ""

echo -e "${COLOR_MUTED}3. Email validation:${RESET}"
echo -e "  ${COLOR_CODE}email=\$(ask_input \"Email\" \"\" \"email\")${RESET}"
if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    email=$(ask_input "Email address" "" "email")
    show_success "Email saved: $email"
else
    echo "  (Interactive - validates format, loops on error)"
fi
echo ""

echo -e "${COLOR_MUTED}4. Number validation:${RESET}"
echo -e "  ${COLOR_CODE}age=\$(ask_input \"Age\" \"\" \"number\")${RESET}"
if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    age=$(ask_input "Your age" "" "number")
    show_success "Age recorded: $age"
else
    echo "  (Interactive - validates numeric input)"
fi
echo ""

echo -e "${COLOR_MUTED}Security features:${RESET}"
print_item "All input is sanitized with _escape_input()"
print_item "Prompts are sanitized before display"
print_item "No ANSI injection or command substitution possible"

pause_between_sections

# ==============================================================================
# 9. INTERACTIVE LIST SELECTION
# ==============================================================================

print_section "9. Interactive List Selection"

echo -e "${COLOR_MUTED}Features:${RESET}"
print_item "Single-select and multi-select modes"
print_item "Arrow keys (↑↓) or vim keys (j/k) to navigate"
print_item "Space to toggle (multi-select), Enter to confirm"
print_item "Auto-detects TTY, falls back to numbered list"
print_item "Mode-aware: › (UTF-8) vs > (ASCII)"
echo ""

echo -e "${COLOR_MUTED}Single-select example:${RESET}"
echo -e "  ${COLOR_CODE}options=(\"Deploy to staging\" \"Deploy to production\" \"Rollback\")${RESET}"
echo -e "  ${COLOR_CODE}choice=\$(ask_list \"Select action:\" options)${RESET}"
echo ""

if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    options=("Deploy to staging" "Deploy to production" "Rollback" "Cancel")
    choice=$(ask_list "Select action:" options)
    show_success "You selected: $choice"
else
    echo "  (Interactive in real usage - try it yourself!)"
fi
echo ""

echo -e "${COLOR_MUTED}Multi-select example:${RESET}"
echo -e "  ${COLOR_CODE}files=(\"app.log\" \"error.log\" \"access.log\" \"debug.log\")${RESET}"
echo -e "  ${COLOR_CODE}selected=\$(ask_list \"Select files to delete:\" files \"multi\")${RESET}"
echo ""

if [ "${OISEAU_GALLERY_AUTO:-0}" != "1" ]; then
    files=("app.log" "error.log" "access.log" "debug.log")
    echo "Try multi-select (Space to toggle, Enter to confirm):"
    selected=$(ask_list "Select files to delete:" files "multi")
    echo ""
    echo -e "${COLOR_SUCCESS}Selected files:${RESET}"
    echo "$selected" | while IFS= read -r file; do
        echo "  - $file"
    done
else
    echo "  (Interactive - Space to toggle, Enter to confirm)"
fi
echo ""

echo -e "${COLOR_MUTED}Navigation:${RESET}"
print_item "↑↓ or j/k: Navigate through list"
print_item "Enter: Select item (single) or confirm (multi)"
print_item "Space: Toggle selection (multi-select only)"
print_item "q or Esc: Cancel selection"

pause_between_sections

# ==============================================================================
# 10. SPINNER WIDGET
# ==============================================================================

print_section "10. Spinner Widget (Loading Indicators)"

echo -e "${COLOR_MUTED}Code:${RESET}"
echo -e "  ${COLOR_CODE}start_spinner \"Loading data...\"${RESET}"
echo -e "  ${COLOR_CODE}# ... do work ...${RESET}"
echo -e "  ${COLOR_CODE}stop_spinner${RESET}"
echo ""

echo -e "${COLOR_MUTED}Renders as (showing 3 styles for 1.5 seconds each):${RESET}"
echo ""

# Demo all spinner styles with shorter duration
echo -e "${COLOR_MUTED}Style: dots (default)${RESET}"
export OISEAU_SPINNER_STYLE="dots"
start_spinner "Loading with dots spinner..."
sleep 1.5
stop_spinner
show_success "Done!"

echo ""
echo -e "${COLOR_MUTED}Style: circle${RESET}"
export OISEAU_SPINNER_STYLE="circle"
start_spinner "Loading with circle spinner..."
sleep 1.5
stop_spinner
show_success "Done!"

echo ""
echo -e "${COLOR_MUTED}Style: pulse${RESET}"
export OISEAU_SPINNER_STYLE="pulse"
start_spinner "Loading with pulse spinner..."
sleep 1.5
stop_spinner
show_success "Done!"

unset OISEAU_SPINNER_STYLE
echo ""

echo ""
echo -e "${COLOR_MUTED}Features:${RESET}"
print_item "5 spinner styles: dots, line, circle, pulse, arc"
print_item "Configurable FPS (frames per second)"
print_item "Auto-adapts to terminal (UTF-8, ASCII, Plain)"
print_item "Simple start/stop helpers"
print_item "Automatic cleanup on exit"

pause_between_sections

# ==============================================================================
# 10. COMPLEX EXAMPLE
# ==============================================================================

print_section "11. Real-World Example: Git Workflow"

show_section_header "Git Worktree Workflow" 3 5 "Creating Pull Request"

workflow_steps=(
    "done|Create feature branch|Branch: feature/user-auth"
    "done|Make code changes|12 files modified"
    "done|Run tests|All 156 tests passing"
    "active|Push to remote|Uploading..."
    "pending|Create pull request|Waiting"
)
show_checklist workflow_steps

echo ""
show_info "Pushing commits to origin/feature/user-auth..."

echo ""
show_success "Successfully pushed 3 commits"

echo ""
show_summary "Branch Summary" \
    "Feature: User authentication" \
    "Commits: 3" \
    "Tests: 156 passed" \
    "Ready for PR creation"

pause_between_sections

# ==============================================================================
# 11. DEGRADATION MODES
# ==============================================================================

print_section "12. Terminal Capability Detection"

echo -e "${COLOR_MUTED}Current Terminal Mode:${RESET}"
print_kv "OISEAU_MODE" "$OISEAU_MODE"
print_kv "Color Support" "$OISEAU_HAS_COLOR"
print_kv "UTF-8 Support" "$OISEAU_HAS_UTF8"
print_kv "Terminal Width" "$OISEAU_WIDTH"

echo ""
echo -e "${COLOR_MUTED}Oiseau automatically detects your terminal capabilities:${RESET}"
print_item "${BOLD}Rich mode${RESET}: Full 256-color + UTF-8 box drawing"
print_item "${BOLD}Color mode${RESET}: Colors with ASCII fallback characters"
print_item "${BOLD}Plain mode${RESET}: No colors, ASCII only (pipes/redirects)"

echo ""
show_info "Set UI_DISABLE=1 or NO_COLOR=1 to force plain mode"

pause_between_sections

# ==============================================================================
# 12. CJK & WIDE CHARACTER SUPPORT
# ==============================================================================

print_section "13. CJK & Wide Character Support"

echo -e "${COLOR_MUTED}Oiseau correctly handles wide characters (CJK, emoji, full-width):${RESET}"
echo ""

echo -e "${COLOR_MUTED}Chinese (中文):${RESET}"
show_box success "成功" "数据库连接成功 - Database connection successful"

echo ""
echo -e "${COLOR_MUTED}Japanese (日本語):${RESET}"
show_box info "情報" "こんにちは - Hello in Japanese (hiragana/katakana/kanji)"

echo ""
echo -e "${COLOR_MUTED}Korean (한국어):${RESET}"
show_box warning "경고" "안녕하세요 - Hello in Korean"

echo ""
echo -e "${COLOR_MUTED}Mixed content:${RESET}"
show_box info "Mixed 混合 🌏" "Hello 你好 こんにちは 안녕 🚀 World"

echo ""
echo -e "${COLOR_MUTED}Character width analysis:${RESET}"
print_kv "ASCII 'Hello'" "$(_display_width 'Hello') columns"
print_kv "Chinese '你好'" "$(_display_width '你好') columns"
print_kv "Japanese 'こんにちは'" "$(_display_width 'こんにちは') columns"
print_kv "Korean '안녕하세요'" "$(_display_width '안녕하세요') columns"
print_kv "Full-width 'ＡＢＣ'" "$(_display_width 'ＡＢＣ') columns"

echo ""
show_success "All wide characters are correctly measured at 2 columns each!"

pause_between_sections

# ==============================================================================
# FINALE
# ==============================================================================

print_section "Gallery Complete!"

echo -e "${COLOR_SUCCESS}${BOLD}"
echo "  You've seen all the widgets Oiseau has to offer!"
echo -e "${RESET}"

print_next_steps \
    "Read the README.md for installation instructions" \
    "Check out examples/ directory for real-world usage" \
    "Start using Oiseau in your bash scripts" \
    "Star the repo on GitHub if you find it useful!"

echo ""
show_summary "Oiseau Features" \
    "✓ 30+ widgets including new spinner!" \
    "✓ Zero dependencies (pure bash)" \
    "✓ 256-color ANSI palette" \
    "✓ Smart terminal detection" \
    "✓ Input sanitization built-in" \
    "✓ Works in all environments"

echo ""
echo -e "${COLOR_HEADER}${BOLD}Thank you for trying Oiseau! 🐦${RESET}"
echo ""
