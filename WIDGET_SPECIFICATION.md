# Oiseau Widget Specification & Design Reference

This document establishes the design principles and implementation standards for all Oiseau UI widgets based on industry-standard terminal UI libraries (Rich, Lip Gloss, Textual, Bubbletea).

## Design Philosophy

### Core Principles

1. **Consistency First**: All widgets should follow the same patterns for borders, padding, alignment, and sizing
2. **Graceful Degradation**: Support rich mode (UTF-8 + color), color mode (color + ASCII), and plain mode (ASCII only)
3. **Wide Character Support**: Properly handle emoji, CJK characters, and full-width characters (2-column display width)
4. **Security**: All user input must be sanitized to prevent ANSI injection and control character exploits
5. **Flexibility**: Widgets should adapt to terminal width with sensible defaults

### Industry Standards (from Rich, Lip Gloss, Textual)

**Border Design Patterns:**
- **ROUNDED**: `╭─╮ │ ╰─╯` - Default for modern panels, friendly appearance
- **SQUARE**: `┌─┐ │ └─┘` - Traditional box drawing, widely compatible
- **DOUBLE**: `╔═╗ ║ ╚═╝` - Heavy emphasis, used for important containers
- **HEAVY**: `┏━┓ ┃ ┗━┛` - Bold emphasis, headers and critical messages
- **ASCII**: `+--+ | +--+` - Maximum compatibility, fallback mode

**Padding Conventions (CSS-like):**
- Internal spacing inside borders
- Minimum 1 space on each side for readability
- Consistent horizontal padding (typically 2 spaces)
- Vertical padding for breathing room (blank lines)

**Alignment Standards:**
- Left-aligned content by default
- Centered titles/headers
- Right-aligned metadata (step counters, percentages)
- Full-width boxes extend to fill available space (with margins)

**Text Wrapping:**
- Word-aware wrapping (`fold -s` behavior)
- Respect max width minus padding
- Preserve alignment after wrapping
- No mid-word breaks

---

## Widget Catalog & Specifications

### 1. Bordered Box Widgets

#### 1.1 `show_box <type> <title> <message> [commands...]`

**Purpose**: Display important messages in a bordered container with optional action commands.

**Design Reference**: Rich Panel, Lip Gloss Box
- **Border Style**: DOUBLE (`╔═╗ ║ ╚═╝`)
- **Color by Type**: error (red), warning (orange), info (blue), success (green)
- **Internal Padding**: 1 blank line top/bottom, 2 spaces left/right
- **Width**: Default 60 columns, clamped to terminal width - 4

**Required Structure**:
```
╔══════════════════════════════════════════════════════════╗
║  [icon]  Title                                           ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Message content here (wrapped if long)                  ║
║                                                          ║
║  To resolve:                                             ║
║    command one                                           ║
║    command two                                           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

**Critical Requirements**:
- ✅ All lines MUST have both left AND right borders
- ✅ Title line includes icon, styled bold
- ✅ Divider line separates title from content
- ✅ Message text word-wrapped at inner_width - 4
- ✅ Commands prefixed with 4 spaces, styled as code
- ✅ Empty lines above/below message and commands
- ✅ All content padded to exact inner_width

**Validation Checklist**:
- [ ] Right border present on title line
- [ ] Right border present on all empty lines
- [ ] Right border present on all message lines
- [ ] Right border present on all command lines
- [ ] Right border present on "To resolve:" line
- [ ] Text wrapping maintains borders
- [ ] CJK/emoji correctly measured for padding
- [ ] Long text doesn't overflow box width
- [ ] Empty message doesn't break structure

---

#### 1.2 `show_header_box <title> [subtitle]`

**Purpose**: Display prominent page/section header in decorative bordered box.

**Design Reference**: Lip Gloss styled header, Textual header widget
- **Border Style**: ROUNDED (`╭─╮ │ ╰─╯`)
- **Color**: Header color (bold cyan/blue)
- **Internal Padding**: 1 blank line top, 1 blank line bottom, 3 spaces left/right
- **Width**: Default 60 columns, clamped to terminal width - 4

**Required Structure**:
```
  ╭──────────────────────────────────────────────────────────╮
  │                                                          │
  │   Title Text Here (wrapped if needed)                   │
  │                                                          │
  │   Subtitle text here (optional, wrapped if needed)      │
  │                                                          │
  ╰──────────────────────────────────────────────────────────╯
```

**Critical Requirements**:
- ✅ All lines MUST have both left AND right borders
- ✅ Title text word-wrapped at inner_width - 6
- ✅ Subtitle text word-wrapped at inner_width - 6
- ✅ Empty line before title
- ✅ Empty line between title and subtitle (if subtitle exists)
- ✅ Empty line after content
- ✅ All content lines indented 3 spaces
- ✅ All content padded to exact inner_width

**Validation Checklist**:
- [ ] Right border on all lines
- [ ] Title wrapping works correctly
- [ ] Subtitle wrapping works correctly
- [ ] Works without subtitle
- [ ] Empty title doesn't break box
- [ ] CJK/emoji in title measured correctly
- [ ] Long title wraps without overflow

---

#### 1.3 `show_section_header <title> [step] [total] [subtitle]`

**Purpose**: Display section header with optional step counter for multi-step workflows.

**Design Reference**: Rich Panel with title/subtitle, Progress step indicators
- **Border Style**: ROUNDED (`╭─╮ │ ╰─╯`)
- **Color**: Muted/dim
- **Width**: Default 60 columns, clamped to terminal width - 4
- **Step Counter**: "Step X of Y › subtitle" format

**Required Structure**:
```
╭────────────────────────────────────────────────────────────╮
│  Title                                                     │
│  Step 2 of 4 › Subtitle text                               │
╰────────────────────────────────────────────────────────────╯
```

**Critical Requirements**:
- ✅ Title line padded to inner_width with right border
- ✅ Step counter line padded to inner_width with right border
- ✅ Step counter only shown if step and total provided
- ✅ Subtitle only shown if provided
- ✅ All content indented 2 spaces
- ✅ No wrapping (single-line title/subtitle expected)

**Validation Checklist**:
- [ ] Right border on title line
- [ ] Right border on step counter line
- [ ] Works without step counter
- [ ] Works without subtitle
- [ ] Works with just title
- [ ] CJK/emoji measured correctly
- [ ] Long text clamped or wrapped

---

#### 1.4 `show_summary <title> <items...>`

**Purpose**: Display summary information in a clean bordered list.

**Design Reference**: Rich Panel with list items
- **Border Style**: SQUARE (`┌─┐ │ └─┘`)
- **Color**: Muted
- **Width**: Default 60 columns, clamped to terminal width - 4

**Required Structure**:
```
  ┌──────────────────────────────────────────────────────────┐
  │  Title                                                   │
  ├──────────────────────────────────────────────────────────┤
  │  Item 1                                                  │
  │  Item 2                                                  │
  │  Item 3                                                  │
  └──────────────────────────────────────────────────────────┘
```

**Critical Requirements**:
- ✅ All lines have both left AND right borders
- ✅ Title line padded to inner_width
- ✅ Divider after title
- ✅ Each item padded to inner_width
- ✅ Items indented 2 spaces
- ✅ No empty lines between items

**Validation Checklist**:
- [ ] Right border on title line
- [ ] Right border on all item lines
- [ ] Divider correctly sized
- [ ] Empty items handled
- [ ] CJK/emoji measured correctly
- [ ] Long items wrapped or truncated

---

### 2. Status Message Widgets

#### 2.1 `show_success <message>`
#### 2.2 `show_error <message>`
#### 2.3 `show_warning <message>`
#### 2.4 `show_info <message>`

**Purpose**: Display inline status messages with icons.

**Design Reference**: Rich console.print with icons/styles
- **Format**: `  [icon]  Message text`
- **Icons**: ✓ (success), ✗ (error), ⚠ (warning), ℹ (info)
- **Colors**: Green, red, orange, blue respectively
- **Indentation**: 2 spaces prefix, 2 spaces after icon

**Required Structure**:
```
  ✓  Operation completed successfully
  ✗  Failed to connect
  ⚠  This action cannot be undone
  ℹ  Processing 50 files...
```

**Critical Requirements**:
- ✅ Icon displayed in rich/color mode, text marker in plain mode
- ✅ Message text wraps at terminal width
- ✅ Color applied to icon and message (rich/color mode)
- ✅ Input sanitized

**Validation Checklist**:
- [ ] Icons display correctly in UTF-8 mode
- [ ] Fallback to ASCII in plain mode
- [ ] Long messages wrap correctly
- [ ] CJK/emoji measured correctly
- [ ] Empty message handled

---

### 3. Progress Widgets

#### 3.1 `show_progress_bar <current> <total> [label]`

**Purpose**: Display progress bar with percentage.

**Design Reference**: Rich Progress, Textual ProgressBar
- **Format**: `Label: ████████░░░░░░░░░░ 40% (4/10)`
- **Bar Width**: 20 characters default
- **Fill Character**: `█` (rich), `#` (plain)
- **Empty Character**: `░` (rich), `-` (plain)

**Required Structure**:
```
Installation: ████████████░░░░░░░░ 60% (6/10)
```

**Critical Requirements**:
- ✅ Percentage calculated as (current/total * 100)
- ✅ Bar filled proportionally
- ✅ Label optional
- ✅ Current/total counts shown
- ✅ Handle edge cases: 0%, 100%, divide by zero

**Validation Checklist**:
- [ ] 0% shows empty bar
- [ ] 100% shows full bar
- [ ] 50% shows half-filled bar
- [ ] Label with emoji/CJK works
- [ ] Handles total=0 gracefully
- [ ] Handles current > total gracefully

---

#### 3.2 `show_checklist <array_name>`

**Purpose**: Display task checklist with status indicators.

**Design Reference**: GitHub markdown task lists, Rich tree with status
- **Format**: `  [icon]  Task name     Status detail`
- **Statuses**: done (✓), active (●), pending (○), skip (—)
- **Colors**: done (green), active (blue), pending (dim), skip (yellow)

**Required Structure**:
```
  ✓  Build Docker image     Completed in 45s
  ●  Run tests              156 tests running...
  ○  Deploy to staging      Waiting
  —  Run linter             Skipped (--no-lint flag)
```

**Critical Requirements**:
- ✅ Each item: "status|label|detail" format
- ✅ Icon and color based on status
- ✅ Label and detail columns aligned
- ✅ Label column width: 24 characters
- ✅ Detail column fills remaining space

**Validation Checklist**:
- [ ] All four statuses render correctly
- [ ] Column alignment with CJK labels
- [ ] Column alignment with emoji labels
- [ ] Long labels truncated or wrapped
- [ ] Long details wrapped
- [ ] Empty details handled

---

### 4. Header Widgets

#### 4.1 `show_header <title>`

**Purpose**: Simple bold header without borders.

**Design Reference**: Markdown H1, Rich heading
- **Format**: Bold text with spacing
- **No borders**: Just styled text

**Required Structure**:
```

Title Text Here

```

**Critical Requirements**:
- ✅ Blank line before
- ✅ Bold styling applied
- ✅ Blank line after
- ✅ No wrapping

---

#### 4.2 `show_subheader <title>`

**Purpose**: Secondary header, muted style.

**Design Reference**: Markdown H2
- **Format**: Muted/dim text
- **No borders**: Just styled text

**Required Structure**:
```
Subtitle Text Here
```

**Critical Requirements**:
- ✅ Muted color
- ✅ No blank lines
- ✅ No wrapping

---

### 5. Formatting Helper Widgets

#### 5.1 `print_kv <key> <value> [width]`

**Purpose**: Display key-value pairs in aligned columns.

**Design Reference**: Configuration displays, property lists
- **Format**: `  Key:     Value`
- **Default Width**: 20 characters for key column

**Required Structure**:
```
  Project:              my-awesome-app
  Version:              1.2.3
  Environment:          production
```

**Critical Requirements**:
- ✅ Key column right-padded to width
- ✅ Colon after key
- ✅ Value starts at fixed column
- ✅ CJK in key/value measured correctly

---

#### 5.2 `print_command <command>`

**Purpose**: Display command in code/monospace style.

**Design Reference**: Markdown code blocks, Rich syntax
- **Format**: `  command text`
- **Styling**: Dim/code color

---

#### 5.3 `print_item <text>`

**Purpose**: Display bulleted list item.

**Design Reference**: Markdown lists
- **Format**: `  • Text` (rich), `  - Text` (plain)

---

#### 5.4 `print_step <number> <text>`

**Purpose**: Display numbered step.

**Design Reference**: Ordered lists, tutorials
- **Format**: `  1. Text`

---

#### 5.5 `print_section <title>`

**Purpose**: Display section divider.

**Design Reference**: Markdown headers, section breaks
- **Format**: Bold title with decorative line

---

#### 5.6 `print_next_steps <items...>`

**Purpose**: Display numbered list of next steps.

**Design Reference**: GitHub issue templates, workflow guides
- **Format**: Numbered list in a styled block

---

## Cross-Widget Requirements

### Universal Padding & Alignment Rules

1. **Inner Width Calculation**: `box_width - 2` (for left/right borders)
2. **Content Padding**: All content must be padded to exact inner_width
3. **Right Borders**: EVERY content line must have a right border
4. **Text Wrapping**: Use `fold -s` at `inner_width - left_padding - right_padding`
5. **Empty Lines**: Must be padded to inner_width with borders

### Wide Character Support Requirements

1. **Display Width Function**: Use `_display_width()` for ALL width calculations
2. **Padding Function**: Use `_pad_to_width()` for ALL content line padding
3. **Never Use**: `${#string}`, `wc -c`, or `wc -m` for display width
4. **Test Coverage**: All widgets must be tested with emoji, CJK, full-width chars

### Security Requirements

1. **Input Sanitization**: Use `_escape_input()` on ALL user-provided strings
2. **Strip ANSI**: Remove existing ANSI codes from input
3. **Strip Control**: Remove control characters (newlines, tabs, etc.)
4. **No Injection**: User input cannot inject colors, formatting, or commands

---

## Validation Matrix

| Widget | Right Borders | Padding | Wrapping | CJK/Emoji | Empty Input | Long Input |
|--------|---------------|---------|----------|-----------|-------------|------------|
| show_box | ✅ | ✅ | ✅ | ✅ | ⚠️  | ⚠️  |
| show_header_box | ✅ | ✅ | ✅ | ⚠️  | ⚠️  | ⚠️  |
| show_section_header | ✅ | ✅ | ❌ | ⚠️  | ⚠️  | ⚠️  |
| show_summary | ⚠️  | ⚠️  | ❌ | ⚠️  | ⚠️  | ⚠️  |
| show_progress_bar | N/A | N/A | N/A | ⚠️  | ⚠️  | N/A |
| show_checklist | N/A | ⚠️  | ❌ | ⚠️  | ⚠️  | ⚠️  |
| Status messages | N/A | N/A | ✅ | ⚠️  | ⚠️  | ⚠️  |

**Legend**:
- ✅ Implemented and validated
- ⚠️  Needs validation
- ❌ Not implemented
- N/A Not applicable

---

## Implementation Checklist

For each widget implementation:

- [ ] Function signature matches specification
- [ ] Border style matches specification
- [ ] Color scheme matches specification
- [ ] Width/sizing behavior matches specification
- [ ] Padding follows specification
- [ ] Text wrapping implemented (if applicable)
- [ ] Right borders on ALL content lines
- [ ] Uses `_display_width()` for width calculations
- [ ] Uses `_pad_to_width()` for padding
- [ ] Uses `_escape_input()` for sanitization
- [ ] Tested with ASCII text
- [ ] Tested with emoji
- [ ] Tested with CJK characters
- [ ] Tested with full-width characters
- [ ] Tested with empty input
- [ ] Tested with very long input
- [ ] Tested with special characters
- [ ] Tested in rich mode
- [ ] Tested in color mode
- [ ] Tested in plain mode
- [ ] Documented in README.md
- [ ] Demonstrated in gallery.sh
- [ ] Included in validate_widgets.sh

---

## Next Steps

1. ✅ Research industry standards (Rich, Lip Gloss, Textual) - COMPLETED
2. ✅ Document widget specifications - COMPLETED
3. ⚠️  Validate current implementation against specification
4. ⚠️  Document inconsistencies and missing features
5. ⚠️  Fix all validation failures
6. ⚠️  Update README.md examples to match actual output
7. ⚠️  Expand validate_widgets.sh with specification tests
