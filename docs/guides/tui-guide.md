# Building TUIs with Oiseau

This guide explains how to build **non-scrolling Terminal User Interfaces (TUIs)** with Oiseau - interfaces that refresh in place like `htop`, `vim`, or `less`.

## Table of Contents

1. [Scrolling vs Non-Scrolling UIs](#scrolling-vs-non-scrolling)
2. [Terminal Control Sequences](#terminal-control-sequences)
3. [Key Binding Implementation](#key-binding-implementation)
4. [TUI Architecture Patterns](#tui-architecture-patterns)
5. [Examples](#examples)

---

## Scrolling vs Non-Scrolling

### Scrolling CLI (like `gallery.sh`)
```bash
echo "Line 1"  # Prints and scrolls down
echo "Line 2"  # Prints and scrolls down
# Terminal scrolls, previous content remains visible
```

**Characteristics:**
- Output accumulates
- Terminal scrolls as content is added
- Simple but not interactive
- Good for logs, reports, installation output

### Non-Scrolling TUI (like `htop`)
```bash
clear_screen       # Clear entire display
move_cursor 1 1    # Position at top-left
render_ui          # Draw interface
# Screen stays fixed, content updates in place
```

**Characteristics:**
- Screen taken over completely
- Updates happen in place
- Highly interactive
- Good for dashboards, monitors, editors

---

## Terminal Control Sequences

TUIs use **ANSI escape codes** to control the terminal:

### Essential Control Functions

```bash
# Clear screen and move to top-left
clear_screen() {
    echo -en "\033[2J\033[H"
}

# Hide cursor (cleaner display)
hide_cursor() {
    echo -en "\033[?25l"
}

# Show cursor (before exit)
show_cursor() {
    echo -en "\033[?25h"
}

# Move cursor to specific position (row, col)
move_cursor() {
    echo -en "\033[${1};${2}H"
}

# Save/restore cursor position
save_cursor() { echo -en "\033[s"; }
restore_cursor() { echo -en "\033[u"; }

# Clear from cursor to end of screen
clear_to_bottom() {
    echo -en "\033[J"
}
```

### Common ANSI Codes

| Code | Effect |
|------|--------|
| `\033[2J` | Clear entire screen |
| `\033[H` | Move cursor to home (1,1) |
| `\033[{row};{col}H` | Move cursor to row, col |
| `\033[?25l` | Hide cursor |
| `\033[?25h` | Show cursor |
| `\033[K` | Clear line from cursor to end |
| `\033[J` | Clear screen from cursor to end |
| `\033[s` | Save cursor position |
| `\033[u` | Restore cursor position |

---

## Key Binding Implementation

### Reading Single Keys

The key to TUI interactivity is reading single keystrokes without waiting for Enter:

```bash
# Basic: Read one character with timeout
read_key() {
    local key=""
    IFS= read -rsn1 -t 1 key 2>/dev/null
    echo "$key"
}
```

**Flags explained:**
- `-r` - Raw mode (don't interpret backslash)
- `-s` - Silent (don't echo input)
- `-n1` - Read exactly 1 character
- `-t 1` - Timeout after 1 second (allows auto-refresh)

### Handling Special Keys

Arrow keys, function keys, and other special keys send **multi-byte escape sequences**:

```bash
read_key() {
    local key=""

    # Read first character
    IFS= read -rsn1 -t 1 key 2>/dev/null

    # If it's ESC, might be arrow key or special key
    if [ "$key" = $'\x1b' ]; then
        # Read next 2 chars to get full sequence
        local next
        IFS= read -rsn2 -t 0.1 next 2>/dev/null
        if [ -n "$next" ]; then
            key="${key}${next}"
        fi
    fi

    echo "$key"
}
```

### Common Key Codes

| Key | Code | Detection Pattern |
|-----|------|-------------------|
| Tab | `$'\t'` | `$'\t'` |
| Enter | `$'\n'` | `$'\n'` |
| Escape | `$'\x1b'` | `$'\x1b'` (alone) |
| Space | `' '` | `' '` |
| Up Arrow | `ESC[A` | `$'\x1b[A'` |
| Down Arrow | `ESC[B` | `$'\x1b[B'` |
| Right Arrow | `ESC[C` | `$'\x1b[C'` |
| Left Arrow | `ESC[D` | `$'\x1b[D'` |
| Home | `ESC[H` | `$'\x1b[H'` |
| End | `ESC[F` | `$'\x1b[F'` |
| Page Up | `ESC[5~` | `$'\x1b[5~'` |
| Page Down | `ESC[6~` | `$'\x1b[6~'` |

### Standard Key Bindings

Here are recommended key bindings for TUIs:

| Key | Purpose | Example Use |
|-----|---------|-------------|
| **Q** | Quit | Exit application |
| **R** | Refresh | Force screen refresh |
| **Tab** | Next | Cycle forward through views/items |
| **Shift+Tab** | Previous | Cycle backward (sends `ESC[Z`) |
| **Esc** | Back/Cancel | Return to previous view |
| **↑↓** | Navigate | Move through lists |
| **←→** | Horizontal | Switch tabs, adjust values |
| **Space** | Select/Toggle | Toggle checkboxes, select items |
| **Enter** | Confirm | Submit, open item |
| **1-9** | Jump | Quick navigation to numbered items |
| **/** | Search | Open search/filter |
| **?** | Help | Show help screen |

### Implementation Example

```bash
handle_key() {
    local key="$1"

    case "$key" in
        # Quit
        q|Q)
            return 1  # Signal to exit
            ;;

        # Refresh
        r|R)
            # Force re-render
            ;;

        # Tab - cycle forward
        $'\t')
            next_view
            ;;

        # Escape - go back
        $'\x1b')
            previous_view
            ;;

        # Arrow keys - navigation
        A|$'\x1b[A')  # Up
            move_selection_up
            ;;
        B|$'\x1b[B')  # Down
            move_selection_down
            ;;
        C|$'\x1b[C')  # Right
            next_tab
            ;;
        D|$'\x1b[D')  # Left
            previous_tab
            ;;

        # Space - toggle
        ' ')
            toggle_selected_item
            ;;

        # Enter - confirm
        $'\n')
            confirm_action
            ;;

        # Number keys - quick jump
        [1-9])
            jump_to_view "$key"
            ;;
    esac

    return 0  # Continue running
}
```

---

## TUI Architecture Patterns

### Pattern 1: Simple State Loop

Basic TUI with global state:

```bash
#!/bin/bash
source oiseau.sh

# State
COUNTER=0
SELECTED=0

# Render
render() {
    clear_screen
    show_header "My TUI"
    echo "Counter: $COUNTER"
    echo "Selected: $SELECTED"
}

# Main loop
main() {
    hide_cursor
    trap 'show_cursor; clear_screen' EXIT

    while true; do
        render
        key=$(read_key)

        case "$key" in
            q|Q) break ;;
            ' ') COUNTER=$((COUNTER + 1)) ;;
        esac
    done
}

main
```

### Pattern 2: MVC (Model-View-Controller)

Clean separation of concerns:

```bash
#!/bin/bash
source oiseau.sh

# MODEL - State and data
declare -A MODEL=(
    [view]="home"
    [counter]=0
)

model::increment() {
    MODEL[counter]=$((MODEL[counter] + 1))
}

# VIEW - Rendering (no logic)
view::render() {
    clear_screen
    show_header "Counter: ${MODEL[counter]}"
}

# CONTROLLER - Input and logic
controller::handle_key() {
    case "$1" in
        q|Q) return 1 ;;
        ' ') model::increment ;;
    esac
    return 0
}

# MAIN LOOP
main() {
    hide_cursor
    trap 'show_cursor; clear_screen' EXIT

    while true; do
        view::render
        key=$(read_key)
        controller::handle_key "$key" || break
    done
}

main
```

### Pattern 3: Event-Driven

Using callbacks and event handlers:

```bash
#!/bin/bash
source oiseau.sh

# Event handlers
declare -A HANDLERS

on() {
    local event="$1"
    local handler="$2"
    HANDLERS["$event"]="$handler"
}

emit() {
    local event="$1"
    shift
    local handler="${HANDLERS[$event]}"
    if [ -n "$handler" ]; then
        $handler "$@"
    fi
}

# Setup
on "key_q" "exit 0"
on "key_space" "increment_counter"

# Main loop
while true; do
    render
    key=$(read_key)
    emit "key_${key}"
done
```

---

## Examples

### 1. `tui_demo.sh` - Basic TUI

A simple multi-view TUI demonstrating:
- Screen refresh
- View switching
- Auto-updating content
- Basic key bindings

**Run it:**
```bash
./examples/tui_demo.sh
```

**Key bindings:**
- `D` - Dashboard view
- `M` - Monitor view
- `T` - Tasks view
- `Q` - Quit

### 2. `tui_mvc.sh` - MVC Pattern

A clean MVC implementation showing:
- Separation of concerns
- State management
- Navigation with arrow keys
- Interactive task list

**Run it:**
```bash
./examples/tui_mvc.sh
```

**Key bindings:**
- `Tab` - Cycle through views
- `1, 2, 3` - Jump to specific view
- `↑ / ↓` - Navigate items (Tasks view)
- `Space` - Toggle item status
- `R` - Force refresh
- `Esc` - Return to home
- `Q` - Quit

---

## Best Practices

### 1. Always Cleanup

Always restore terminal state on exit:

```bash
cleanup() {
    show_cursor
    clear_screen
    move_cursor 1 1
}

trap cleanup EXIT INT TERM
```

### 2. Check for Interactive Terminal

TUIs require an interactive terminal:

```bash
if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo "Error: This requires an interactive terminal"
    exit 1
fi
```

### 3. Use Timeouts for Auto-Refresh

Non-blocking reads with timeout allow auto-refresh:

```bash
# Read with 1s timeout
key=$(IFS= read -rsn1 -t 1 key 2>/dev/null; echo "$key")

# If no key pressed, key is empty
# Loop continues, screen refreshes
```

### 4. Optimize Rendering

Only redraw what changed:

```bash
# Full redraw
render_all() {
    clear_screen
    render_header
    render_body
    render_footer
}

# Partial update
update_counter() {
    move_cursor 5 10
    echo -n "Count: $COUNTER"
}
```

### 5. Handle Window Resize

Detect terminal resize:

```bash
trap 'COLUMNS=$(tput cols); LINES=$(tput lines)' WINCH
```

---

## Troubleshooting

### Cursor Still Visible After Crash

If your script crashes and the cursor stays hidden:

```bash
# Manually restore
echo -e "\033[?25h"
# Or use tput
tput cnorm
```

### Arrow Keys Not Working

Make sure you're reading escape sequences:

```bash
# Bad - only reads first byte
IFS= read -rsn1 key

# Good - reads full escape sequence
IFS= read -rsn1 key
if [ "$key" = $'\x1b' ]; then
    IFS= read -rsn2 next
    key="${key}${next}"
fi
```

### Screen Flickering

Reduce flicker by:
1. Only redrawing changed parts
2. Using double buffering (render to variable, then output)
3. Increasing update interval

```bash
# Render to variable first
output=$(render_all)
clear_screen
echo "$output"
```

---

## Further Reading

- [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
- [Bash Manual - Read Builtin](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-read)
- [Terminal Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html)

---

**Happy TUI building with Oiseau! 🐦**
