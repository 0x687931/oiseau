# Bubble Tea Examples vs Oiseau - Widget Comparison

This document compares the 48 Bubble Tea examples with Oiseau's current implementation to identify which widgets/features we should implement.

---

## Summary

**Oiseau Current Capabilities:**
- ✅ Simple status messages (success, error, warning, info)
- ✅ Styled boxes with titles and commands
- ✅ Progress bars
- ✅ Checklists with status indicators
- ✅ Headers (simple, section, boxed)
- ✅ Summary boxes
- ✅ Interactive prompts (yes/no, text input)
- ✅ Formatting helpers (key-value, commands, steps)
- ✅ Basic TUI support (terminal control, key reading, MVC pattern)

**Bubble Tea Capabilities Oiseau is Missing:**
- ❌ Spinner/loading indicators (multiple styles)
- ❌ File picker widget
- ❌ Textarea (multi-line text editing)
- ❌ Text input (single-line editing with cursor)
- ❌ Table widget (with sorting, filtering, resize)
- ❌ Paginator widget
- ❌ List widget (with selection, filtering)
- ❌ Timer/stopwatch components
- ❌ Tabs navigation
- ❌ Help menu system
- ❌ Viewport/pager (scrolling content)
- ❌ Form validation system
- ❌ Autocomplete

---

## Detailed Comparison

### Category: Basic UI Components

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **simple** | `show_success`, `show_info` | ✅ Complete | - | Basic messages work well |
| **spinner** | ❌ None | 🔴 Missing | **HIGH** | Essential for loading states |
| **spinners** | ❌ None | 🔴 Missing | MEDIUM | Multiple spinner styles |
| **progress-static** | `show_progress_bar` | ✅ Complete | - | Works well |
| **progress-animated** | `show_progress_bar` | ⚠️ Partial | MEDIUM | No animation, just static bar |
| **progress-download** | `show_progress_bar` | ⚠️ Partial | LOW | Could add download-specific formatting |

**Recommendation:** Implement **spinner** widget as HIGH priority - it's essential for any async operations.

---

### Category: Input & Forms

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **textinput** | `ask_input` | ⚠️ Basic | **HIGH** | Need cursor positioning, inline editing |
| **textinputs** | ❌ None | 🔴 Missing | MEDIUM | Multiple inputs with focus management |
| **textarea** | ❌ None | 🔴 Missing | **HIGH** | Multi-line editing is common |
| **credit-card-form** | ❌ None | 🔴 Missing | LOW | Complex forms with validation |
| **autocomplete** | ❌ None | 🔴 Missing | MEDIUM | Useful for CLI tools |

**Recommendation:**
1. **HIGH**: Enhanced `textinput` with cursor control, editing, masking
2. **HIGH**: `textarea` for multi-line editing
3. MEDIUM: Form validation helpers

---

### Category: Navigation & Selection

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **list-default** | `show_checklist` | ⚠️ Basic | **HIGH** | No selection, filtering, or navigation |
| **list-fancy** | ❌ None | 🔴 Missing | MEDIUM | Styled lists with selection |
| **list-simple** | `show_checklist` | ⚠️ Partial | LOW | Basic version exists |
| **file-picker** | ❌ None | 🔴 Missing | **HIGH** | Very common use case |
| **tabs** | ❌ None | 🔴 Missing | MEDIUM | Tab navigation for multi-view |
| **paginator** | ❌ None | 🔴 Missing | MEDIUM | For paginated content |
| **pager** | ❌ None | 🔴 Missing | LOW | Like `less` command |
| **result** | `ask_yes_no` | ⚠️ Basic | LOW | Choice menu |

**Recommendation:**
1. **HIGH**: Interactive `list` widget with arrow key navigation, selection
2. **HIGH**: `file_picker` - extremely useful for scripts
3. MEDIUM: `tabs` for multi-view TUIs

---

### Category: Data Display

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **table** | ❌ None | 🔴 Missing | **HIGH** | Essential for data display |
| **table-resize** | ❌ None | 🔴 Missing | MEDIUM | Resizable columns |
| **help** | ❌ None | 🔴 Missing | MEDIUM | Help menu system |
| **glamour** | ❌ None | 🔴 Missing | LOW | Markdown rendering (complex) |

**Recommendation:**
1. **HIGH**: Basic `table` widget with borders, headers, alignment
2. MEDIUM: Table sorting/filtering
3. MEDIUM: Built-in help menu template

---

### Category: Time & Monitoring

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **timer** | ❌ None | 🔴 Missing | MEDIUM | Countdown timer |
| **stopwatch** | ❌ None | 🔴 Missing | MEDIUM | Elapsed time tracking |
| **realtime** | ❌ None | 🔴 Missing | LOW | Real-time updates (Go channels) |

**Recommendation:** MEDIUM priority - `timer` and `stopwatch` widgets for monitoring scripts

---

### Category: Advanced TUI Features

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **views** | TUI examples (`tui_demo.sh`) | ✅ Complete | - | View switching works |
| **composable-views** | TUI MVC pattern | ✅ Complete | - | MVC pattern supports this |
| **split-editors** | ❌ None | 🔴 Missing | LOW | Multiple focused areas |
| **focus-blur** | ❌ None | 🔴 Missing | MEDIUM | Focus management |
| **viewport** | ❌ None | 🔴 Missing | MEDIUM | Scrollable content area |
| **mouse** | ❌ None | 🔴 Missing | LOW | Mouse event handling |
| **window-size** | Partial (tput cols/lines) | ⚠️ Basic | LOW | Auto-resize handling |

**Recommendation:**
1. MEDIUM: `viewport` for scrolling content
2. MEDIUM: Focus management helpers
3. LOW: Mouse support (not critical for bash scripts)

---

### Category: System Integration

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **exec** | ❌ None | 🔴 Missing | MEDIUM | Launch external editors |
| **http** | ❌ None | ✅ N/A | - | HTTP in bash is `curl` |
| **pipe** | ❌ None | ✅ N/A | - | Shell pipes work natively |
| **package-manager** | ❌ None | 🔴 Missing | LOW | Tea-specific feature |
| **tui-daemon-combo** | ❌ None | 🔴 Missing | LOW | Advanced pattern |

**Recommendation:** MEDIUM priority - helpers for launching external editors ($EDITOR integration)

---

### Category: UI Behavior & Polish

| Bubble Tea Example | Oiseau Equivalent | Status | Priority | Notes |
|-------------------|-------------------|--------|----------|-------|
| **fullscreen** | TUI examples | ✅ Complete | - | Works with `clear_screen` |
| **altscreen-toggle** | ❌ None | 🔴 Missing | LOW | Alternate screen buffer |
| **prevent-quit** | ❌ None | 🔴 Missing | LOW | Confirmation before quit |
| **debounce** | ❌ None | 🔴 Missing | LOW | Throttle key input |
| **sequence** | ❌ None | ✅ N/A | - | Go-specific (command chaining) |
| **send-msg** | ❌ None | ✅ N/A | - | Go-specific (messaging) |
| **set-window-title** | ❌ None | 🔴 Missing | LOW | Set terminal title |
| **suspend** | ❌ None | 🔴 Missing | LOW | Ctrl+Z handling |
| **cellbuffer** | ❌ None | ✅ N/A | - | Low-level rendering |
| **eyes** | ❌ None | ✅ N/A | - | Fun demo, not useful |
| **chat** | ❌ None | 🔴 Missing | LOW | Chat UI pattern |

**Recommendation:** LOW priority - polish features for mature library

---

## Priority Recommendations

### 🔴 HIGH Priority - Core Missing Widgets

These should be implemented ASAP as they're fundamental to any TUI framework:

1. **Spinner Widget** (`show_spinner`)
   - Essential for loading states
   - Multiple styles (dots, line, arc, etc.)
   - Auto-animation support
   - Example: `show_spinner "Loading data..." &`

2. **Interactive List** (`show_list`)
   - Arrow key navigation
   - Selection (single/multiple)
   - Filtering/search
   - Example: File selection, menu navigation

3. **File Picker** (`ask_file`)
   - Navigate directories
   - File filtering by extension
   - Preview pane (optional)
   - Example: `file=$(ask_file "Select config file" "*.json")`

4. **Table Widget** (`show_table`)
   - Column headers
   - Auto-sizing columns
   - Borders and alignment
   - Example: Display structured data

5. **Enhanced Text Input** (`ask_text`)
   - Cursor positioning
   - Inline editing (insert, delete)
   - Password masking
   - Example: Better than current `ask_input`

6. **Textarea** (`ask_textarea`)
   - Multi-line editing
   - Scrolling
   - Line numbers (optional)
   - Example: Commit messages, code input

---

### 🟡 MEDIUM Priority - Enhanced Functionality

Implement these after HIGH priority items:

7. **Timer/Stopwatch** (`show_timer`, `show_stopwatch`)
   - Countdown timers
   - Elapsed time tracking
   - Auto-updating display

8. **Tabs** (`show_tabs`)
   - Tab navigation
   - Active tab highlighting
   - Keyboard shortcuts (1-9)

9. **Paginator** (`show_paginator`)
   - Page navigation
   - Page indicators
   - Next/prev controls

10. **Viewport** (`show_viewport`)
    - Scrollable content area
    - Scroll indicators
    - Keyboard scrolling

11. **Focus Management**
    - Focus ring for multiple widgets
    - Tab navigation between inputs
    - Visual focus indicators

12. **Help Menu** (`show_help`)
    - Standard help screen template
    - Key binding display
    - Multi-column layout

---

### 🟢 LOW Priority - Nice to Have

Implement these later for completeness:

13. **Alternate Screen Buffer**
    - Switch to alt screen (like vim)
    - Restore original screen on exit

14. **Window Title** (`set_window_title`)
    - Update terminal title
    - Progress in title bar

15. **Mouse Support**
    - Click events
    - Scroll events
    - Hover states

16. **Advanced Animations**
    - Animated progress bars
    - Transitions between views
    - Loading animations

---

## Implementation Strategy

### Phase 1: Core Widgets (HIGH Priority)
**Goal:** Make Oiseau competitive with basic TUI frameworks

```bash
# Implement in this order:
1. show_spinner (most requested, easiest)
2. show_table (data display is critical)
3. ask_file (file picker - common use case)
4. show_list (interactive selection)
5. ask_text (enhanced input)
6. ask_textarea (multi-line input)
```

**Timeline:** 2-3 weeks
**Impact:** Covers 80% of use cases

---

### Phase 2: Enhanced Features (MEDIUM Priority)
**Goal:** Add polish and advanced TUI capabilities

```bash
7. show_timer / show_stopwatch
8. show_tabs
9. show_paginator
10. show_viewport
11. Focus management helpers
12. show_help
```

**Timeline:** 2-3 weeks
**Impact:** Professional-grade TUI framework

---

### Phase 3: Polish & Completeness (LOW Priority)
**Goal:** Feature parity with Bubble Tea

```bash
13. Alternate screen buffer
14. Window title control
15. Mouse support
16. Advanced animations
```

**Timeline:** 1-2 weeks
**Impact:** Best-in-class bash TUI library

---

## Design Principles for New Widgets

Following Oiseau's philosophy:

### 1. Zero Configuration
```bash
# Should work beautifully with no setup
show_spinner "Loading..."  # Uses sensible defaults
```

### 2. Simple Global Overrides
```bash
# Override via environment variables AFTER sourcing
source oiseau.sh
export SPINNER_STYLE="dots"  # Change spinner style globally
```

### 3. Automatic Degradation
```bash
# Rich mode: Animated spinner with UTF-8 characters
# Color mode: Rotating ASCII characters
# Plain mode: Static "Loading..." text
```

### 4. Consistent API
```bash
# All widgets follow same patterns:
show_<widget>      # Display widget
ask_<widget>       # Interactive widget (returns value)
print_<helper>     # Formatting helper
```

### 5. Security First
```bash
# All input sanitized automatically
user_file=$(ask_file "Select file")  # Safe, no injection risk
```

---

## Validation & Testing Plan

### For Each New Widget:

1. **Functionality Test**
   - Works in rich mode (UTF-8 + colors)
   - Works in color mode (ASCII + colors)
   - Works in plain mode (ASCII only)
   - Works when piped (`script.sh | cat`)

2. **Integration Test**
   - Combines well with existing widgets
   - Doesn't break layout/alignment
   - Respects terminal width

3. **Security Test**
   - Handles malicious input
   - Prevents code injection
   - Sanitizes user data

4. **Documentation**
   - Add to README.md widget reference
   - Add example to gallery.sh
   - Add to TUI_GUIDE.md if applicable

---

## Conclusion

**Immediate Action Items:**

1. ✅ **Document current state** (this file)
2. 🔴 **Implement Phase 1** - Start with `show_spinner`
3. 🟡 **Update README** - Document new widgets
4. 🟢 **Add to gallery** - Showcase new features

**Success Metrics:**
- Cover 90% of Bubble Tea use cases
- Maintain zero-dependency philosophy
- Keep API simple and consistent
- Ensure automatic degradation works

**Next Steps:**
1. Review this comparison with stakeholders
2. Prioritize Phase 1 widgets based on user feedback
3. Create implementation tickets for each widget
4. Start with `show_spinner` (easiest, highest impact)

---

**Note:** This is a living document. Update as we implement widgets and discover new requirements.
