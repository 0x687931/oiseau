# Oiseau Widget Enhancement - Design Specification

**Philosophy:** Convention over configuration. Zero setup, smart defaults, simple overrides.

---

## Table of Contents

1. [Visual Consistency Guidelines](#visual-consistency-guidelines)
2. [Naming Convention](#naming-convention)
3. [Design Principles](#design-principles)
4. [Widget Specifications](#widget-specifications)
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
5. [Validation Framework](#validation-framework)
6. [Implementation Guidelines](#implementation-guidelines)
7. [Testing Strategy](#testing-strategy)
8. [Implementation Order](#implementation-order)

---

## Visual Consistency Guidelines

**Critical:** All widgets must maintain visual consistency within each mode.

### Three Rendering Modes

Oiseau automatically detects terminal capabilities and selects the appropriate mode:

| Mode | Trigger | Characters | Colors | Use Case |
|------|---------|------------|--------|----------|
| **Rich** | UTF-8 + 256-color | UTF-8 box drawing, Unicode icons | Full 256-color ANSI | Modern terminals (iTerm2, Alacritty, VS Code) |
| **Color** | 256-color only | ASCII box drawing, ASCII icons | Full 256-color ANSI | Older terminals without UTF-8 |
| **Plain** | No TTY or NO_COLOR | ASCII only | No colors | Pipes, redirects, CI/CD, logs |

### Character Sets by Mode

#### Rich Mode (UTF-8 + Color)

**Box Drawing Characters:**
```
Rounded (default):  ╭─╮ │ ╰─╯ ├─┤
Double (emphasis):  ┏━┓ ┃ ┗━┛ ┣━┫
Single:             ┌─┐ │ └─┘ ├─┤
```

**Status Icons:**
```
Success: ✓    Error: ✗    Warning: ⚠    Info: ℹ
Active:  ●    Pending: ○   Done: ✓      Skip: ⊘
```

**Progress Characters:**
```
Filled: █  Partial: ▓▒░  Empty: ░
```

**Spinner Styles:**
```
Dots:   ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
Line:   ⎯⎼⎽⎼
Circle: ◐◓◑◒
Pulse:  ●○●○
Arc:    ◜◝◞◟
```

**Selection/Navigation:**
```
Selected: ▸  Unselected: ·  Checkbox: ☐☑  Radio: ○●
```

#### Color Mode (ASCII + Color)

**Box Drawing Characters:**
```
Rounded equivalent: +--+ | +--+ |--|
Double equivalent:  +==+ | +==+ |==|
Single:             +--+ | +--+ |--|
```

**Status Icons:**
```
Success: [OK]  Error: [X]   Warning: [!]  Info: [i]
Active:  [*]   Pending: [ ] Done: [+]     Skip: [-]
```

**Progress Characters:**
```
Filled: #  Partial: =~-  Empty: -
```

**Spinner Styles:**
```
Dots:   | / - \
Line:   - = ≡ =
Circle: | / - \
Pulse:  * o * o
Arc:    . o O o
```

**Selection/Navigation:**
```
Selected: >  Unselected: ·  Checkbox: [ ][X]  Radio: ( )(*)
```

#### Plain Mode (ASCII only, no color)

**Box Drawing Characters:**
```
All styles: +--+ | +--+ |--|
```

**Status Icons:**
```
Success: [OK]  Error: [X]   Warning: [!]  Info: [i]
Active:  [*]   Pending: [ ] Done: [+]     Skip: [-]
```

**Progress Characters:**
```
Filled: #  Empty: -
```

**Spinner:**
```
Static text only: "Loading..."
```

**Selection/Navigation:**
```
Selected: >  Unselected: -  Checkbox: [ ][X]  Radio: ( )(*)
```

### Visual Consistency Rules

**1. Border Style Consistency**

All widgets in the same rendering session must use consistent borders:

```bash
# Rich mode - all widgets use UTF-8
show_header_box "Title"    # Uses ┏━┓
show_box error "Error"     # Uses ┏━┓
show_table data            # Uses ╭─╮ or ┏━┓

# Color mode - all widgets use ASCII
show_header_box "Title"    # Uses +==+
show_box error "Error"     # Uses +==+
show_table data            # Uses +--+ or +==+
```

**2. Icon Consistency**

All status icons within the same mode must match:

```bash
# Rich mode
show_success "Done"        # ✓
show_checklist tasks       # ✓ ● ○
show_list items            # ✓ ✗ ⚠

# Color mode
show_success "Done"        # [OK]
show_checklist tasks       # [+] [*] [ ]
show_list items            # [OK] [X] [!]
```

**3. Spacing Consistency**

All widgets must maintain consistent internal spacing:

```bash
# 2-space padding inside boxes
┏━━━━━━━━━━━━━━━━━━━━┓
┃  Content here      ┃   # 2 spaces before, fill to right border
┗━━━━━━━━━━━━━━━━━━━━┛

# 2-space indent for list items
  ✓  Item 1             # 2 spaces, icon, 2 spaces, text
  ●  Item 2
  ○  Item 3
```

**4. Width Consistency**

All widgets must respect terminal width and use consistent clamping:

```bash
# Max width: terminal width - 4
local max_width=$((OISEAU_WIDTH - 4))

# Default box width: 60 columns (or max_width if smaller)
local width=$(_clamp_width 60)
```

**5. Color Palette Consistency**

Use the same color codes across all widgets (from oiseau.sh):

```bash
# Status colors (consistent across all widgets)
COLOR_SUCCESS='\033[38;5;40m'    # Bright green
COLOR_ERROR='\033[38;5;196m'     # Bright red
COLOR_WARNING='\033[38;5;214m'   # Orange
COLOR_INFO='\033[38;5;39m'       # Bright blue

# UI colors
COLOR_ACCENT='\033[38;5;99m'     # Purple
COLOR_HEADER='\033[38;5;117m'    # Light blue
COLOR_BORDER='\033[38;5;240m'    # Gray
COLOR_MUTED='\033[38;5;246m'     # Light gray
COLOR_DIM='\033[38;5;238m'       # Dark gray
```

### Mode Detection Logic

```bash
# Already implemented in oiseau.sh
if [ "$OISEAU_HAS_COLOR" = "1" ] && [ "$OISEAU_HAS_UTF8" = "1" ]; then
    OISEAU_MODE="rich"      # UTF-8 + Colors
elif [ "$OISEAU_HAS_COLOR" = "1" ]; then
    OISEAU_MODE="color"     # ASCII + Colors
else
    OISEAU_MODE="plain"     # ASCII only
fi
```

### Widget-Specific Consistency

**Borders:**
- Headers: Rounded (`╭─╮` or `+--+`)
- Errors/Warnings: Double (`┏━┓` or `+==+`)
- Info boxes: Rounded (`╭─╮` or `+--+`)
- Tables: Rounded (`╭─╮` or `+--+`)

**Icons:**
- Success messages: Always `✓` / `[OK]`
- Error messages: Always `✗` / `[X]`
- Warning messages: Always `⚠` / `[!]`
- Info messages: Always `ℹ` / `[i]`

**Progress indicators:**
- Filled: `█` / `#`
- Empty: `░` / `-`
- Partial: Not used in plain mode

### Testing Visual Consistency

For each widget, verify:

```bash
# 1. Rich mode uses only UTF-8 characters
LANG=en_US.UTF-8 ./test.sh | grep -P '[^\x00-\x7F]' # Should find UTF-8

# 2. Color mode uses only ASCII + ANSI codes
export OISEAU_HAS_UTF8=0
./test.sh | grep -P '[^\x00-\x7F]' # Should find nothing except ANSI codes

# 3. Plain mode uses only printable ASCII
export NO_COLOR=1
./test.sh | grep -P '[^\x20-\x7E\n\t]' # Should find nothing
```

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

## Validation Framework

Every widget must pass comprehensive validation before merging.

### Input Validation

All user input must be sanitized to prevent security vulnerabilities:

#### 1. Escape User Input

**Required for all display functions:**

```bash
show_custom_widget() {
    local user_input="$1"

    # ALWAYS escape before displaying
    local safe_input="$(_escape_input "$user_input")"

    echo -e "  ${COLOR_INFO}${safe_input}${RESET}"
}
```

**What `_escape_input` does:**
- Removes ANSI escape sequences (`\033[...m`)
- Strips control characters (`\x00-\x1F`, `\x7F`)
- Prevents code injection attacks
- Allows safe display of untrusted data

#### 2. Validate Input Types

For interactive widgets, validate input matches expected type:

```bash
ask_number() {
    local prompt="$1"
    local input=""

    while true; do
        input=$(ask_text "$prompt")

        # Validate: only digits allowed
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            echo "$input"
            return 0
        fi

        show_error "Please enter a valid number"
    done
}
```

**Common validation patterns:**

```bash
# Number (integer)
[[ "$input" =~ ^[0-9]+$ ]]

# Number (float)
[[ "$input" =~ ^[0-9]+\.?[0-9]*$ ]]

# Email (basic)
[[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]

# Filename (safe characters)
[[ "$input" =~ ^[a-zA-Z0-9._-]+$ ]]

# Path (exists)
[[ -e "$input" ]]

# Yes/No
[[ "$input" =~ ^[YyNn]$ ]]
```

#### 3. Validate Array Inputs

For widgets that accept arrays, validate array structure:

```bash
show_table() {
    local array_name="$1"

    # Check array exists
    if ! declare -p "$array_name" &>/dev/null; then
        show_error "Array '$array_name' does not exist"
        return 1
    fi

    # Check array has elements
    eval "local count=\${#${array_name}[@]}"
    if [ "$count" -eq 0 ]; then
        show_warning "Table has no rows"
        return 0
    fi

    # Validate format (pipe-delimited)
    eval "local first_row=\"\${${array_name}[0]}\""
    if [[ ! "$first_row" =~ \| ]]; then
        show_error "Table rows must be pipe-delimited (Name|Age|City)"
        return 1
    fi

    # Proceed with rendering
    # ...
}
```

#### 4. Validate Terminal State

Before interactive operations, ensure terminal is suitable:

```bash
ask_list() {
    # Check if running in TTY
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        show_error "Interactive list requires a terminal (not piped/redirected)"
        return 1
    fi

    # Check terminal size is adequate
    if [ "$OISEAU_WIDTH" -lt 20 ] || [ "$OISEAU_HEIGHT" -lt 5 ]; then
        show_error "Terminal too small for interactive list"
        return 1
    fi

    # Proceed with interactive mode
    # ...
}
```

#### 5. Validate Environment Variables

For widgets with configuration, validate environment variable values:

```bash
# In spinner implementation
validate_spinner_style() {
    local style="${OISEAU_SPINNER_STYLE:-dots}"

    case "$style" in
        dots|line|circle|pulse|arc)
            return 0
            ;;
        *)
            show_warning "Invalid OISEAU_SPINNER_STYLE='$style', using 'dots'"
            export OISEAU_SPINNER_STYLE="dots"
            return 1
            ;;
    esac
}
```

### Output Validation

Ensure output is correct in all modes:

#### 1. Character Set Validation

**UTF-8 mode must only output UTF-8:**

```bash
test_utf8_output() {
    local output=$(show_widget_test)

    # Should contain UTF-8 characters
    if echo "$output" | grep -qP '[^\x00-\x7F]'; then
        echo "✓ UTF-8 output detected"
    else
        echo "✗ FAIL: No UTF-8 in rich mode"
        return 1
    fi
}
```

**Color mode must only output ASCII + ANSI:**

```bash
test_color_output() {
    export OISEAU_HAS_UTF8=0
    local output=$(show_widget_test)

    # Remove ANSI codes
    local clean=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')

    # Should contain only ASCII
    if echo "$clean" | grep -qP '[^\x00-\x7F]'; then
        echo "✗ FAIL: Non-ASCII in color mode"
        return 1
    else
        echo "✓ ASCII output only"
    fi
}
```

**Plain mode must only output printable ASCII:**

```bash
test_plain_output() {
    export NO_COLOR=1
    local output=$(show_widget_test)

    # Should contain only printable ASCII (no ANSI codes)
    if echo "$output" | grep -qP '[^\x20-\x7E\n\t\r]'; then
        echo "✗ FAIL: Non-printable characters in plain mode"
        return 1
    else
        echo "✓ Printable ASCII only"
    fi
}
```

#### 2. Width Validation

Ensure output respects terminal width:

```bash
test_width_compliance() {
    export OISEAU_WIDTH=80
    local output=$(show_widget_test)

    # Check each line doesn't exceed terminal width
    while IFS= read -r line; do
        # Remove ANSI codes
        local clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local len=${#clean}

        if [ "$len" -gt 80 ]; then
            echo "✗ FAIL: Line exceeds terminal width ($len > 80)"
            echo "Line: $clean"
            return 1
        fi
    done <<< "$output"

    echo "✓ All lines within terminal width"
}
```

#### 3. Visual Consistency Validation

Ensure consistent use of characters:

```bash
test_border_consistency() {
    local output=$(show_widget_test)

    if [ "$OISEAU_MODE" = "rich" ]; then
        # Should use UTF-8 box drawing
        if echo "$output" | grep -q '[+|=-]'; then
            echo "✗ FAIL: ASCII borders in UTF-8 mode"
            return 1
        fi

        if echo "$output" | grep -qP '[╭╮╯╰─│┏┓┛┗━┃]'; then
            echo "✓ UTF-8 borders consistent"
        else
            echo "✗ FAIL: No UTF-8 borders found"
            return 1
        fi
    fi
}
```

### Security Validation

Critical security checks for all widgets:

#### 1. Code Injection Prevention

```bash
test_code_injection() {
    # Malicious input attempts
    local malicious_inputs=(
        "$(echo -e '\033[2J\033[H')hacked"    # Screen clear
        "; rm -rf /"                           # Command injection
        "\$(echo pwned)"                       # Command substitution
        "\`whoami\`"                           # Backtick substitution
        "foo\nbar"                            # Newline injection
    )

    for input in "${malicious_inputs[@]}"; do
        local output=$(show_widget "$input")

        # Check that malicious code was escaped
        if echo "$output" | grep -q "pwned\|hacked"; then
            echo "✗ FAIL: Code injection vulnerability"
            echo "Input: $input"
            echo "Output: $output"
            return 1
        fi
    done

    echo "✓ Code injection prevented"
}
```

#### 2. ANSI Escape Injection

```bash
test_ansi_injection() {
    # Try to inject color codes
    local input="Red text \033[31mINJECTED\033[0m normal"
    local output=$(show_success "$input")

    # Should not contain the injected ANSI codes
    if echo "$output" | grep -F "INJECTED" | grep -qF $'\033[31m'; then
        echo "✗ FAIL: ANSI injection not escaped"
        return 1
    else
        echo "✓ ANSI injection prevented"
    fi
}
```

#### 3. Control Character Injection

```bash
test_control_chars() {
    # Try to inject control characters
    local input=$(printf "Text\x00NULL\x01SOH\x02STX")
    local output=$(show_info "$input")

    # Should not contain control characters
    if echo "$output" | tr -d '\n\t\r' | grep -qP '[\x00-\x1F\x7F]'; then
        echo "✗ FAIL: Control characters not stripped"
        return 1
    else
        echo "✓ Control characters stripped"
    fi
}
```

### Functional Validation

Test widget behavior and features:

#### 1. Zero-Config Test

```bash
test_zero_config() {
    # Unset all OISEAU overrides
    unset OISEAU_SPINNER_STYLE
    unset OISEAU_PROGRESS_ANIMATE
    # etc...

    # Should work with no configuration
    local output=$(show_spinner "Loading..." &)
    local pid=$!
    sleep 1
    kill $pid 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Zero-config works"
    else
        echo "✗ FAIL: Widget requires configuration"
        return 1
    fi
}
```

#### 2. Override Test

```bash
test_overrides() {
    # Test environment variable override
    export OISEAU_SPINNER_STYLE="circle"

    local output=$(show_spinner_frame)

    # Should use circle spinner (◐◓◑◒)
    if echo "$output" | grep -qP '[◐◓◑◒]'; then
        echo "✓ Environment override works"
    else
        echo "✗ FAIL: Override not applied"
        return 1
    fi

    unset OISEAU_SPINNER_STYLE
}
```

#### 3. Error Handling Test

```bash
test_error_handling() {
    # Test with invalid input
    local result

    # Empty array
    result=$(show_table "" 2>&1)
    if [ $? -ne 0 ]; then
        echo "✓ Handles empty array"
    else
        echo "✗ FAIL: Should reject empty array"
        return 1
    fi

    # Non-existent array
    result=$(show_table "nonexistent_array" 2>&1)
    if [ $? -ne 0 ]; then
        echo "✓ Handles missing array"
    else
        echo "✗ FAIL: Should reject non-existent array"
        return 1
    fi
}
```

### Validation Test Script Template

For each widget, create a `test_<widget>.sh` script:

```bash
#!/bin/bash
# Test script for show_spinner

source oiseau.sh

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    local test_func="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "━━━ Test: $test_name ━━━"

    if $test_func; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        show_success "$test_name"
    else
        show_error "$test_name"
    fi
}

# Define test functions
test_utf8_output() { ... }
test_color_output() { ... }
test_plain_output() { ... }
test_code_injection() { ... }
test_zero_config() { ... }
test_overrides() { ... }

# Run all tests
run_test "UTF-8 Output" test_utf8_output
run_test "Color Mode Output" test_color_output
run_test "Plain Mode Output" test_plain_output
run_test "Code Injection Prevention" test_code_injection
run_test "Zero Configuration" test_zero_config
run_test "Environment Overrides" test_overrides

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    show_success "All tests passed!"
    exit 0
else
    show_error "Some tests failed"
    exit 1
fi
```

---

## Implementation Guidelines

Detailed implementation patterns and best practices.

### Code Structure

Every widget function should follow this structure:

```bash
show_widget_name() {
    # 1. PARAMETER VALIDATION
    local param1="$1"
    local param2="${2:-default}"

    if [ -z "$param1" ]; then
        show_error "show_widget_name: parameter required"
        return 1
    fi

    # 2. INPUT SANITIZATION
    local safe_param1="$(_escape_input "$param1")"

    # 3. MODE DETECTION (if needed)
    local char_set
    if [ "$OISEAU_MODE" = "rich" ]; then
        char_set="UTF8"
    elif [ "$OISEAU_MODE" = "color" ]; then
        char_set="ASCII"
    else
        char_set="PLAIN"
    fi

    # 4. DIMENSION CALCULATION
    local width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    # 5. CONTENT PREPARATION
    local display_text="$(_pad_to_width "$safe_param1" "$inner_width")"

    # 6. RENDERING
    echo -e "${COLOR_BORDER}${BOX_RTL}...${BOX_RTR}${RESET}"
    echo -e "${COLOR_BORDER}${BOX_V}${display_text}${BOX_V}${RESET}"
    echo -e "${COLOR_BORDER}${BOX_RBL}...${BOX_RBR}${RESET}"

    # 7. CLEANUP (if needed)
    # Return cursor, etc.

    return 0
}
```

### Error Handling

Consistent error handling across all widgets:

```bash
# Use show_error for user-facing errors
if [ ! -f "$config_file" ]; then
    show_error "Configuration file not found: $config_file"
    return 1
fi

# Use stderr for programmer errors
if [ $# -lt 1 ]; then
    echo "ERROR: show_widget requires at least 1 argument" >&2
    return 1
fi

# Fail gracefully in non-interactive contexts
if [ ! -t 0 ]; then
    # Fallback to simple output
    echo "$message"
    return 0
fi
```

### Performance Considerations

#### 1. Minimize Subprocess Calls

```bash
# BAD: Multiple subprocess calls in loop
for item in "${items[@]}"; do
    len=$(echo "$item" | wc -c)  # Slow!
done

# GOOD: Use bash built-ins
for item in "${items[@]}"; do
    len=${#item}  # Fast!
done
```

#### 2. Cache Terminal Dimensions

```bash
# GOOD: Cache at start of function
local term_width=$OISEAU_WIDTH
local term_height=$OISEAU_HEIGHT

# Don't call tput repeatedly in loops
```

#### 3. Use Built-in String Operations

```bash
# BAD: External commands
trimmed=$(echo "$str" | sed 's/^ *//')

# GOOD: Bash parameter expansion
trimmed="${str#"${str%%[![:space:]]*}"}"

# Or simply:
read -r trimmed <<< "$str"
```

### Cursor Management

For interactive widgets:

```bash
# Hide cursor at start
hide_cursor() {
    echo -en "\033[?25l"
}

# Show cursor at end
show_cursor() {
    echo -en "\033[?25h"
}

# Always restore cursor on exit
cleanup() {
    show_cursor
    clear_screen
}
trap cleanup EXIT INT TERM

# Main widget function
interactive_widget() {
    hide_cursor

    # ... interactive code ...

    show_cursor
}
```

### Key Reading

Consistent key reading for interactive widgets:

```bash
# Standard key reading function (already in TUI guide)
read_key() {
    local key=""
    IFS= read -rsn1 -t 0.1 key 2>/dev/null

    # Handle escape sequences (arrow keys, etc.)
    if [ "$key" = $'\x1b' ]; then
        local next
        IFS= read -rsn2 -t 0.1 next 2>/dev/null
        if [ -n "$next" ]; then
            key="${key}${next}"
        fi
    fi

    echo "$key"
}

# Key code constants
readonly KEY_UP=$'\x1b[A'
readonly KEY_DOWN=$'\x1b[B'
readonly KEY_LEFT=$'\x1b[D'
readonly KEY_RIGHT=$'\x1b[C'
readonly KEY_ENTER=$'\n'
readonly KEY_ESC=$'\x1b'
readonly KEY_SPACE=' '
readonly KEY_TAB=$'\t'
```

### Screen Refresh

For TUI widgets that update in place:

```bash
# Clear screen and reset cursor
refresh_screen() {
    echo -en "\033[2J\033[H"
}

# Update single line (for progress bars, spinners)
update_line() {
    local text="$1"
    echo -en "\r${text}\033[K"  # \r = return, \033[K = clear to end
}

# Save/restore cursor position
save_cursor() { echo -en "\033[s"; }
restore_cursor() { echo -en "\033[u"; }
```

### Animation Framework

For animated widgets (spinner, progress):

```bash
# Animation loop template
animate_widget() {
    local message="$1"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local fps=10
    local delay=$(awk "BEGIN {print 1/$fps}")  # 0.1 for 10 FPS

    local frame_idx=0
    local num_frames=${#frames[@]}

    while true; do
        local frame="${frames[$frame_idx]}"
        echo -en "\r${frame} ${message}\033[K"

        frame_idx=$(( (frame_idx + 1) % num_frames ))
        sleep "$delay"
    done
}

# Background animation with PID tracking
start_animation() {
    animate_widget "$1" &
    OISEAU_ANIMATION_PID=$!
}

stop_animation() {
    if [ -n "$OISEAU_ANIMATION_PID" ]; then
        kill "$OISEAU_ANIMATION_PID" 2>/dev/null
        wait "$OISEAU_ANIMATION_PID" 2>/dev/null
        echo -en "\r\033[K"  # Clear line
        unset OISEAU_ANIMATION_PID
    fi
}
```

### Array Handling

Consistent array handling for widgets that accept arrays:

```bash
process_array_widget() {
    local array_name="$1"

    # Method 1: eval (works in bash 3.x+)
    eval "local items=(\"\${${array_name}[@]}\")"

    # Method 2: nameref (bash 4.3+ only, avoid for compatibility)
    # local -n items="$array_name"

    # Iterate over items
    for item in "${items[@]}"; do
        # Process each item
        echo "$item"
    done
}
```

### Compatibility Notes

Ensure compatibility with bash 3.2+ (macOS default):

```bash
# AVOID: nameref (bash 4.3+)
local -n arr_ref="$array_name"

# USE: eval (bash 3.x+)
eval "local arr=(\"\${${array_name}[@]}\")"

# AVOID: associative arrays (bash 4.0+)
declare -A assoc_arr

# USE: indexed arrays (bash 3.x+)
declare -a indexed_arr

# AVOID: ${var,,} lowercase (bash 4.0+)
lowercase="${var,,}"

# USE: tr for case conversion
lowercase=$(echo "$var" | tr '[:upper:]' '[:lower:]')
```

### Documentation Standards

Every widget function must have a header comment:

```bash
#===============================================================================
# FUNCTION: show_spinner
# DESCRIPTION: Display an animated loading spinner
# PARAMETERS:
#   $1 - message (string, required): Message to display next to spinner
# ENVIRONMENT VARIABLES:
#   OISEAU_SPINNER_STYLE - Spinner animation style (dots|line|circle|pulse|arc)
#   OISEAU_SPINNER_FPS   - Animation frame rate (default: 10)
# RETURNS: 0 on success, 1 on error
# MODES:
#   Rich:  Animated UTF-8 spinner (⠋⠙⠹⠸...)
#   Color: Animated ASCII spinner (|/-\)
#   Plain: Static message only
# EXAMPLE:
#   show_spinner "Loading data..." &
#   SPINNER_PID=$!
#   # ... do work ...
#   kill $SPINNER_PID
#===============================================================================
show_spinner() {
    # Implementation...
}
```

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

- [ ] Works in all 4 modes (Rich, Color, Plain, Non-TTY)
- [ ] Zero-config default works beautifully
- [ ] Environment variable overrides work
- [ ] Handles malicious input (security tests pass)
- [ ] Respects terminal width (no overflow)
- [ ] Visual consistency within mode (UTF-8/ASCII/Plain)
- [ ] Documented in README.md widget reference
- [ ] Added to gallery.sh with examples
- [ ] Validation tests pass (test_<widget>.sh)

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
