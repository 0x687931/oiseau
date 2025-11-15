# Oiseau Widget Enhancement - Design Specification

**Philosophy:** Convention over configuration. Zero setup, smart defaults, simple overrides.

---

## Table of Contents

1. [Naming Convention](#naming-convention)
2. [Design Principles](#design-principles)
3. [Widget Specifications](#widget-specifications)
   - [Phase 1: Spinner](#phase-1-spinner)
   - [Phase 2: Animated Progress Bar](#phase-2-animated-progress-bar)
   - [Phase 3: Enhanced Text Input](#phase-3-enhanced-text-input)
   - [Phase 4: Interactive List](#phase-4-interactive-list)
   - [Phase 5: Choice Menu](#phase-5-choice-menu)
   - [Phase 6: Table Widget](#phase-6-table-widget)
   - [Phase 7: Help Menu](#phase-7-help-menu)
   - [Phase 8: Window Resize Handler](#phase-8-window-resize-handler)
   - [Phase 9: Pager Widget](#phase-9-pager-widget)
   - [Phase 10: Quit Confirmation](#phase-10-quit-confirmation)
4. [Testing Strategy](#testing-strategy)
5. [Implementation Order](#implementation-order)

---

## Naming Convention

All Oiseau functions follow a consistent pattern:

### Function Prefixes

| Prefix | Purpose | Returns | Example |
|--------|---------|---------|---------|
| `show_` | Display non-interactive widget | void (prints to stdout) | `show_spinner` |
| `ask_` | Interactive widget, gets user input | string/value | `ask_choice` |
| `print_` | Formatting helper | void (prints to stdout) | `print_kv` |
| `_` | Internal/private function | varies | `_escape_input` |

### Widget Naming Standards

**Existing (keep as-is):**
- `show_success`, `show_error`, `show_warning`, `show_info`
- `show_header`, `show_subheader`, `show_section_header`, `show_header_box`
- `show_box`
- `show_progress_bar`
- `show_checklist`
- `show_summary`
- `ask_input`, `ask_yes_no` (alias: `prompt_confirm`)
- `print_kv`, `print_command`, `print_item`, `print_step`, `print_next_steps`

**New (following convention):**
- `show_spinner` - Loading spinner (replaces need for new name)
- `show_progress` - Enhanced animated progress (upgrade `show_progress_bar`)
- `ask_text` - Enhanced text input (upgrade `ask_input`, keep old for compatibility)
- `ask_choice` - Enhanced choice menu (upgrade `ask_yes_no`, keep old for compatibility)
- `show_list` - Interactive list (upgrade `show_checklist`, keep old for compatibility)
- `show_table` - Table display
- `show_help` - Help menu
- `show_pager` - Pager for long content
- `ask_quit` - Quit confirmation (off by default)

### Environment Variable Naming

Pattern: `OISEAU_<FEATURE>_<PROPERTY>`

Examples:
- `OISEAU_SPINNER_STYLE` (dots, line, arc, circle)
- `OISEAU_PROGRESS_ANIMATE` (0 or 1)
- `OISEAU_TABLE_BORDERS` (0 or 1)
- `OISEAU_QUIT_CONFIRM` (0 or 1)

---

## Design Principles

Every widget must follow these principles:

### 1. Zero Configuration Default
```bash
# Must work beautifully with NO configuration
show_spinner "Loading data..."
```

### 2. Smart Terminal Detection
```bash
# Automatically adapt to terminal capabilities
# Rich mode: UTF-8 animated spinner ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
# Color mode: ASCII rotating |/-\
# Plain mode: Static "Loading data..."
```

### 3. Simple Global Overrides
```bash
# Override AFTER sourcing (not before)
source oiseau.sh
export OISEAU_SPINNER_STYLE="dots"  # Change globally
```

### 4. Consistent API
```bash
# Same patterns across all widgets
show_widget [required] [optional]
ask_widget "prompt" [default]
```

### 5. Graceful Degradation
```bash
# Works in pipes, redirects, non-TTY
./script.sh | tee log.txt  # Spinners become static text
```

---

## Widget Specifications

---

## Phase 1: Spinner

**Purpose:** Show loading/processing state for async operations

### API Design

```bash
# Basic usage (blocking)
show_spinner "Loading data..."

# Background usage (non-blocking)
show_spinner "Processing..." &
SPINNER_PID=$!
# ... do work ...
kill $SPINNER_PID

# With cleanup helper
start_spinner "Building project..."
# ... do work ...
stop_spinner
```

### Function Signatures

```bash
show_spinner() {
  local message="${1:-Loading...}"
  # Auto-detects mode, runs until killed or Ctrl+C
}

start_spinner() {
  local message="${1:-Loading...}"
  # Starts in background, stores PID in OISEAU_SPINNER_PID
}

stop_spinner() {
  # Kills spinner at OISEAU_SPINNER_PID, clears line
}
```

### Visual Design

**Rich Mode (UTF-8):**
```
⠋ Loading data...
⠙ Loading data...
⠹ Loading data...
```

**Color Mode (ASCII):**
```
| Loading data...
/ Loading data...
- Loading data...
\ Loading data...
```

**Plain Mode:**
```
Loading data...
```

### Environment Variables

```bash
OISEAU_SPINNER_STYLE="dots"    # dots, line, arc, circle, pulse
OISEAU_SPINNER_FPS="10"        # Frames per second (default: 10)
```

### Spinner Styles

| Style | Rich (UTF-8) | Color (ASCII) |
|-------|--------------|---------------|
| dots | ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏ | `\|/-` |
| line | ⎯⎼⎽⎼ | `-=≡=` |
| circle | ◐◓◑◒ | `\|/-` |
| pulse | ●○●○ | `*o*o` |

### Behavior

- **TTY:** Animates, updates in place
- **Non-TTY:** Prints message once, no animation
- **Ctrl+C:** Cleans up properly, restores cursor
- **Background:** Must be manually stopped with `stop_spinner`

### Implementation Notes

- Use `tput` for cursor control
- Frame rate: 10 FPS (100ms sleep)
- Must trap EXIT/INT/TERM for cleanup
- Must hide cursor during animation
- Must clear line and restore cursor when done

---

## Phase 2: Animated Progress Bar

**Purpose:** Upgrade `show_progress_bar` with animation support

### API Design

```bash
# Static (current behavior, default)
show_progress 5 10 "Installing"
# Installing: ██████████░░░░░░░░░░ 50% (5/10)

# Animated (smoothly fills)
export OISEAU_PROGRESS_ANIMATE=1
for i in {1..100}; do
  show_progress $i 100 "Downloading"
  sleep 0.1
done
```

### Function Signatures

```bash
show_progress() {
  local current="$1"
  local total="$2"
  local label="${3:-Progress}"
  # If OISEAU_PROGRESS_ANIMATE=1, updates in place
  # Otherwise prints new line each time (current behavior)
}

# Keep old name as alias for compatibility
show_progress_bar() {
  show_progress "$@"
}
```

### Visual Design

**Rich Mode (UTF-8):**
```
Downloading: ████████████░░░░░░░░ 60% (60/100)
```

**Color Mode (ASCII):**
```
Downloading: [============        ] 60% (60/100)
```

**Plain Mode:**
```
Downloading: 60% (60/100)
```

### Environment Variables

```bash
OISEAU_PROGRESS_ANIMATE=1      # Enable in-place updates (default: 0)
OISEAU_PROGRESS_WIDTH=20       # Bar width in characters (default: 20)
OISEAU_PROGRESS_SHOW_PERCENT=1 # Show percentage (default: 1)
OISEAU_PROGRESS_SHOW_COUNT=1   # Show count (default: 1)
```

### Behavior

- **Static (default):** Prints new line each call (current behavior)
- **Animated:** Updates in place using `\r` (carriage return)
- **Non-TTY:** Always static (one line per call)
- **Complete:** Prints newline when 100% reached

### Implementation Notes

- Detect TTY before enabling animation
- Use `\r` to return to start of line
- Print newline when progress reaches 100%
- Must clear to end of line to avoid artifacts

---

## Phase 3: Enhanced Text Input

**Purpose:** Upgrade `ask_input` with cursor control, editing, masking

### API Design

```bash
# Basic (same as current ask_input)
name=$(ask_text "Enter your name")

# With default value
email=$(ask_text "Email address" "user@example.com")

# Password masking
password=$(ask_text "Password" "" "password")

# Validation (optional)
age=$(ask_text "Age" "" "number")
```

### Function Signatures

```bash
ask_text() {
  local prompt="$1"
  local default="${2:-}"
  local mode="${3:-text}"  # text, password, number
  # Returns sanitized user input
}

# Keep old name as alias for compatibility
ask_input() {
  ask_text "$@"
}
```

### Visual Design

**Text Mode:**
```
ℹ  Enter your name: John Doe█
```

**Password Mode:**
```
ℹ  Password: ••••••••█
```

**With Default:**
```
ℹ  Email address [user@example.com]: █
```

### Features

- **Inline editing:** Left/right arrow, backspace, delete
- **History:** Up/down for history (optional, complex)
- **Cursor:** Visual cursor position
- **Masking:** Password mode shows bullets (••••)
- **Validation:** Number mode allows only digits
- **Default:** Pre-fill with default value

### Environment Variables

```bash
OISEAU_INPUT_HISTORY=0     # Enable input history (default: 0, complex)
```

### Behavior

- **TTY:** Full editing with cursor
- **Non-TTY:** Falls back to simple `read`
- **Empty + default:** Returns default value
- **Validation:** Loops until valid input

### Implementation Notes

- Use `read -e` for readline support (if available)
- Fallback to simple `read` if `-e` not supported
- Password mode: `read -s`, print bullets as typed
- Number validation: regex `^[0-9]+$`

---

## Phase 4: Interactive List

**Purpose:** Upgrade `show_checklist` to interactive selection list

### API Design

```bash
# Non-interactive (current behavior, default)
tasks=("done|Build|Complete" "active|Test|Running")
show_list tasks

# Interactive (returns selected item)
options=("Option 1" "Option 2" "Option 3")
selected=$(ask_list "Choose an option:" options)
echo "You selected: $selected"

# Multi-select
selected=($(ask_list "Select files:" files "multi"))
```

### Function Signatures

```bash
show_list() {
  local array_name="$1"
  # Non-interactive, displays list with status icons
  # Same as current show_checklist
}

ask_list() {
  local prompt="$1"
  local array_name="$2"
  local mode="${3:-single}"  # single, multi
  # Returns selected item(s)
}

# Keep old name as alias for compatibility
show_checklist() {
  show_list "$@"
}
```

### Visual Design

**Non-interactive (show_list):**
```
  ✓  Build            Complete
  ●  Test             Running
  ○  Deploy           Pending
```

**Interactive (ask_list):**
```
Choose an option:
  > Option 1
    Option 2
    Option 3

[↑↓: Navigate | Enter: Select | Q: Cancel]
```

**Multi-select:**
```
Select files:
  [✓] file1.txt
  [ ] file2.txt
  [✓] file3.txt

[↑↓: Navigate | Space: Toggle | Enter: Confirm | Q: Cancel]
```

### Environment Variables

```bash
OISEAU_LIST_STYLE="arrow"  # arrow, highlight (default: arrow)
```

### Behavior

- **show_list:** Non-interactive display (current behavior)
- **ask_list:** Interactive selection with arrow keys
- **Single select:** Enter confirms, returns one item
- **Multi select:** Space toggles, Enter confirms, returns array
- **Q:** Cancel, returns empty

### Implementation Notes

- Use `read_key` from TUI guide
- Arrow up/down to navigate
- Clear and redraw on each key
- Return selected index/indices
- Must handle terminal resize

---

## Phase 5: Choice Menu

**Purpose:** Upgrade `ask_yes_no` to multi-choice menu

### API Design

```bash
# Yes/No (current behavior, default)
if ask_choice "Continue?"; then
  echo "Yes"
fi

# Multi-choice
options=("Yes" "No" "Cancel")
choice=$(ask_choice "Save changes?" options)

# With default
choice=$(ask_choice "Save changes?" options "Yes")
```

### Function Signatures

```bash
ask_choice() {
  local prompt="$1"
  local options_array="${2:-}"
  local default="${3:-}"

  # If no options array: yes/no mode (current ask_yes_no behavior)
  # If options array: multi-choice mode
  # Returns selected option text or 0/1 for yes/no
}

# Keep old names as aliases for compatibility
ask_yes_no() {
  ask_choice "$@"
}

prompt_confirm() {
  ask_choice "$@"
}
```

### Visual Design

**Yes/No Mode:**
```
ℹ  Continue? [Y/n]: _
```

**Multi-choice Mode:**
```
ℹ  Save changes?
  1) Yes
  2) No
  3) Cancel
Enter choice [1-3] (default: 1): _
```

**Or interactive:**
```
ℹ  Save changes?
  > Yes
    No
    Cancel
```

### Environment Variables

```bash
OISEAU_CHOICE_INTERACTIVE=0  # Use arrow keys (default: 0, use numbers)
```

### Behavior

- **No array:** Y/n prompt (current behavior)
- **With array + INTERACTIVE=0:** Number selection
- **With array + INTERACTIVE=1:** Arrow key selection
- **Default:** Highlight default option

### Implementation Notes

- Yes/no: case-insensitive y/n
- Numbers: validate input is 1-N
- Interactive: use arrow keys + enter
- Return selected option text (not index)

---

## Phase 6: Table Widget

**Purpose:** Display tabular data with headers, borders, alignment

### API Design

```bash
# Simple table (array of rows)
rows=(
  "Name|Age|City"
  "John|25|NYC"
  "Jane|30|LA"
)
show_table rows

# With custom column widths
show_table rows "15,5,10"

# No borders
export OISEAU_TABLE_BORDERS=0
show_table rows
```

### Function Signatures

```bash
show_table() {
  local array_name="$1"
  local col_widths="${2:-auto}"  # auto, or "10,20,15"
  # First row is header
  # Remaining rows are data
}
```

### Visual Design

**With Borders (Rich Mode):**
```
╭────────┬─────┬────────╮
│ Name   │ Age │ City   │
├────────┼─────┼────────┤
│ John   │  25 │ NYC    │
│ Jane   │  30 │ LA     │
╰────────┴─────┴────────╯
```

**Without Borders:**
```
Name      Age   City
John       25   NYC
Jane       30   LA
```

**ASCII Mode:**
```
+--------+-----+--------+
| Name   | Age | City   |
+--------+-----+--------+
| John   |  25 | NYC    |
| Jane   |  30 | LA     |
+--------+-----+--------+
```

### Environment Variables

```bash
OISEAU_TABLE_BORDERS=1     # Show borders (default: 1)
OISEAU_TABLE_HEADER_BOLD=1 # Bold header (default: 1)
OISEAU_TABLE_ALIGN="left"  # left, right, center (default: left)
```

### Behavior

- **Auto-width:** Calculate from longest value in each column
- **Custom width:** Use specified widths, truncate overflow
- **Header:** First row, bold + separator
- **Alignment:** All cells aligned consistently

### Implementation Notes

- Parse rows by `|` delimiter
- Calculate max width per column
- Use box drawing characters (UTF-8 or ASCII)
- Truncate with `...` if too wide
- Center header text in cells

---

## Phase 7: Help Menu

**Purpose:** Standard help screen template with key bindings

### API Design

```bash
# Simple help (key=description pairs)
help_items=(
  "Q|Quit application"
  "R|Refresh display"
  "↑↓|Navigate items"
)
show_help "My App v1.0" help_items

# With sections
show_help "My App v1.0" help_items "Navigation:1-3,Actions:4-6"
```

### Function Signatures

```bash
show_help() {
  local title="$1"
  local array_name="$2"
  local sections="${3:-}"  # Optional section headers
  # Displays formatted help menu
}
```

### Visual Design

```
╭────────────────────────────────────────╮
│           My App v1.0                  │
╰────────────────────────────────────────╯

Navigation:
  ↑↓        Navigate items
  ←→        Switch tabs

Actions:
  Space     Toggle selection
  Enter     Confirm
  Q         Quit application
  R         Refresh display

[Press any key to continue]
```

### Environment Variables

```bash
OISEAU_HELP_COLS=2  # Number of columns (default: 1)
```

### Behavior

- **Centered title** in header box
- **Sections:** Group related commands
- **Two-column layout:** Key on left, description on right
- **Wait for key:** Pause until user presses key

### Implementation Notes

- Use `show_header_box` for title
- Format as two columns: key (10 chars) + description
- Support multi-column if needed
- Use `read -n1` to wait for keypress

---

## Phase 8: Window Resize Handler

**Purpose:** Detect and respond to terminal resize events

### API Design

```bash
# In TUI main loop
on_resize() {
  # Re-render UI with new dimensions
  render_ui
}

# Register handler
register_resize_handler on_resize

# Or manual check
if terminal_resized; then
  OISEAU_WIDTH=$(tput cols)
  OISEAU_HEIGHT=$(tput lines)
  render_ui
fi
```

### Function Signatures

```bash
register_resize_handler() {
  local callback="$1"
  # Sets up SIGWINCH trap to call callback
}

terminal_resized() {
  # Returns 0 if terminal size changed since last check
}

update_terminal_size() {
  # Updates OISEAU_WIDTH and OISEAU_HEIGHT
  export OISEAU_WIDTH=$(tput cols)
  export OISEAU_HEIGHT=$(tput lines)
}
```

### Environment Variables

```bash
OISEAU_WIDTH   # Terminal width (auto-updated)
OISEAU_HEIGHT  # Terminal height (auto-updated)
```

### Behavior

- **Auto-detect:** Trap SIGWINCH signal
- **Update globals:** Update OISEAU_WIDTH/HEIGHT
- **Callback:** Call user-provided function
- **Graceful:** Don't crash if tput unavailable

### Implementation Notes

```bash
trap 'update_terminal_size; on_resize_callback' WINCH
```

- Store callback function name
- Update width/height on SIGWINCH
- Call callback if registered
- Provide helper to check if resized

---

## Phase 9: Pager Widget

**Purpose:** Display long content with scrolling (like `less`)

### API Design

```bash
# From file
show_pager "README.md"

# From variable
content="$(cat long_output.txt)"
show_pager <<< "$content"

# From command
git log | show_pager
```

### Function Signatures

```bash
show_pager() {
  local file_or_content="${1:-}"
  # If file exists: read from file
  # If stdin: read from pipe
  # Otherwise: treat as content
}
```

### Visual Design

```
╭────────────────────────────────────────╮
│ README.md                      [1/150] │
╰────────────────────────────────────────╯

Line 1 of content...
Line 2 of content...
...
Line 20 of content...

[↑↓: Scroll | PgUp/PgDn: Page | Q: Quit]
```

### Environment Variables

```bash
OISEAU_PAGER_LINES=20  # Lines per page (default: terminal height - 5)
```

### Behavior

- **Up/Down:** Scroll one line
- **PgUp/PgDn:** Scroll one page
- **Home/End:** Jump to start/end
- **Q:** Quit pager
- **Non-TTY:** Falls back to `less` or `more`

### Implementation Notes

- Read all content into array (one line per element)
- Track current line number
- Render visible window (20 lines)
- Update on key press
- Show line counter in header

---

## Phase 10: Quit Confirmation

**Purpose:** Confirm before quitting (off by default)

### API Design

```bash
# Enable globally
export OISEAU_QUIT_CONFIRM=1

# In TUI
while true; do
  render
  key=$(read_key)

  if [ "$key" = "q" ]; then
    if ask_quit; then
      break
    fi
  fi
done
```

### Function Signatures

```bash
ask_quit() {
  local message="${1:-Are you sure you want to quit?}"
  # If OISEAU_QUIT_CONFIRM=0: return 0 (always allow)
  # If OISEAU_QUIT_CONFIRM=1: ask confirmation
}
```

### Visual Design

```
╭────────────────────────────────────────╮
│  ⚠  Quit Confirmation                  │
├────────────────────────────────────────┤
│                                        │
│  Are you sure you want to quit?       │
│                                        │
├────────────────────────────────────────┤
│  [Y]es  [N]o                           │
╰────────────────────────────────────────╯
```

### Environment Variables

```bash
OISEAU_QUIT_CONFIRM=0  # Ask before quit (default: 0 = no confirmation)
```

### Behavior

- **QUIT_CONFIRM=0:** Always return 0 (allow quit)
- **QUIT_CONFIRM=1:** Show confirmation dialog
- **Y:** Return 0 (allow quit)
- **N/Esc:** Return 1 (cancel quit)

### Implementation Notes

- Use `show_box warning` for confirmation
- Use `ask_yes_no` for Y/N prompt
- If disabled, immediately return 0
- Don't block if non-interactive

---

## Testing Strategy

For each widget, test in **4 modes**:

### 1. Rich Mode (UTF-8 + Colors)
```bash
# Terminal with UTF-8 and 256-color support
./test_widget.sh
```

### 2. Color Mode (ASCII + Colors)
```bash
# Force ASCII mode
export OISEAU_HAS_UTF8=0
./test_widget.sh
```

### 3. Plain Mode (ASCII only)
```bash
# No colors, ASCII only
export NO_COLOR=1
./test_widget.sh
```

### 4. Non-TTY (Piped/Redirected)
```bash
# Piped output
./test_widget.sh | cat

# Redirected output
./test_widget.sh > output.txt
```

### Test Checklist

For each widget:

- [ ] Works in all 4 modes
- [ ] Zero-config default works beautifully
- [ ] Environment variable overrides work
- [ ] Handles malicious input (security)
- [ ] Respects terminal width
- [ ] Documented in README
- [ ] Added to gallery.sh
- [ ] Backward compatible (old names aliased)

---

## Implementation Order

Implement in this sequence (easiest to hardest):

### Quick Wins (1-2 days each)
1. **Spinner** - Simplest, high impact
2. **Animated Progress** - Upgrade existing widget
3. **Window Resize** - Infrastructure improvement
4. **Quit Confirmation** - Simple dialog

### Medium Complexity (2-3 days each)
5. **Choice Menu** - Upgrade existing widget
6. **Help Menu** - Standard template
7. **Enhanced Text Input** - Editing features

### Complex (3-5 days each)
8. **Interactive List** - Keyboard navigation
9. **Table** - Layout calculation
10. **Pager** - Scrolling + navigation

### Workflow for Each Widget

1. **Design Review** (30 min)
   - Review spec
   - Validate API design
   - Confirm visual design

2. **Create Worktree** (2 min)
   ```bash
   bin/worktree-new widget-spinner
   ```

3. **Implement** (1-5 days)
   - Write function(s)
   - Add environment variables
   - Add to oiseau.sh

4. **Test** (30 min)
   - Test all 4 modes
   - Test security
   - Test edge cases

5. **Document** (30 min)
   - Update README.md
   - Add example to gallery.sh
   - Update TUI_GUIDE.md if applicable

6. **PR & Review** (1 day)
   ```bash
   bin/worktree-pr "Add spinner widget"
   # Wait for review
   bin/worktree-complete widget-spinner
   ```

---

## Success Criteria

**After all 10 phases:**

✅ Oiseau has feature parity with Bubble Tea basics
✅ All widgets follow consistent naming
✅ Zero configuration works perfectly
✅ Environment variable overrides available
✅ Full test coverage (4 modes each)
✅ Comprehensive documentation
✅ Backward compatibility maintained

**Timeline:** ~4-6 weeks total (working part-time)

---

**Next Step:** Review this spec, approve designs, then start Phase 1 (Spinner)
