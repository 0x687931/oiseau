# Oiseau Widget Reference

**Philosophy**: Zero config by default, 3 env vars for global customization:
- `OISEAU_BORDER_STYLE` - Global border style (rounded/double/ascii)
- `OISEAU_BOX_WIDTH` - Default box width (60)
- `COLOR_*` - Standard color variables for theming

## Border Styles

**ROUNDED** (default): `╭─╮ │ ╰─╯`
**DOUBLE**: `╔═╗ ║ ╚═╝`
**SQUARE**: `┌─┐ │ └─┘`
**ASCII**: `+--+ | +--+`

## Widget Reference

### Bordered Box Widgets

#### `show_box <type> <title> <message> [commands...]`
Display important messages in a bordered container.

**Parameters**:
- `type`: error, warning, info, success
- `title`: Box title (displays with icon)
- `message`: Main message content (word-wrapped)
- `commands`: Optional command suggestions (prefixed, code-styled)

**Border**: DOUBLE (`╔═╗`)
**Width**: 60 cols (respects OISEAU_BOX_WIDTH)
**Colors**: error=red, warning=orange, info=blue, success=green
**Padding**: 2 spaces horizontal, 1 line vertical

```
╔══════════════════════════════════════════════════════════╗
║  [icon]  Title                                           ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Message content here                                    ║
║                                                          ║
║  To resolve:                                             ║
║    command one                                           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

---

#### `show_header_box <title> [subtitle]`
Display prominent page/section header.

**Parameters**:
- `title`: Main header text (word-wrapped)
- `subtitle`: Optional subtitle (word-wrapped)

**Border**: ROUNDED (`╭─╮`)
**Width**: 60 cols (respects OISEAU_BOX_WIDTH)
**Color**: Bold cyan/blue
**Padding**: 3 spaces horizontal, 1 line vertical

```
  ╭──────────────────────────────────────────────────────────╮
  │                                                          │
  │   Title Text Here                                       │
  │                                                          │
  │   Subtitle text here                                    │
  │                                                          │
  ╰──────────────────────────────────────────────────────────╯
```

---

#### `show_section_header <title> [step] [total] [subtitle]`
Display section header with optional step counter.

**Parameters**:
- `title`: Section title
- `step`: Current step number (optional)
- `total`: Total steps (optional)
- `subtitle`: Subtitle text (optional)

**Border**: ROUNDED (`╭─╮`)
**Width**: 60 cols (respects OISEAU_BOX_WIDTH)
**Color**: Muted/dim
**Format**: `Step X of Y › subtitle`

```
╭────────────────────────────────────────────────────────────╮
│  Title                                                     │
│  Step 2 of 4 › Subtitle text                               │
╰────────────────────────────────────────────────────────────╯
```

---

#### `show_summary <title> <items...>`
Display summary information in a bordered list.

**Parameters**:
- `title`: Summary title
- `items`: List items (one per line)

**Border**: SQUARE (`┌─┐`)
**Width**: 60 cols (respects OISEAU_BOX_WIDTH)
**Color**: Muted
**Padding**: 2 spaces horizontal

```
  ┌──────────────────────────────────────────────────────────┐
  │  Title                                                   │
  ├──────────────────────────────────────────────────────────┤
  │  Item 1                                                  │
  │  Item 2                                                  │
  └──────────────────────────────────────────────────────────┘
```

---

### Status Message Widgets

#### `show_success <message>`
#### `show_error <message>`
#### `show_warning <message>`
#### `show_info <message>`

Display inline status messages with icons.

**Parameters**:
- `message`: Status message text (word-wrapped)

**Icons**: ✓ (success), ✗ (error), ⚠ (warning), ℹ (info)
**Colors**: green, red, orange, blue
**Format**: `  [icon]  Message text`

```
  ✓  Operation completed successfully
  ✗  Failed to connect
  ⚠  This action cannot be undone
  ℹ  Processing 50 files...
```

---

### Progress Widgets

#### `show_progress_bar <current> <total> [label]`
Display progress bar with percentage.

**Parameters**:
- `current`: Current progress value
- `total`: Total value (100%)
- `label`: Optional label text

**Bar Width**: 20 characters
**Fill**: `█` (rich), `#` (plain)
**Empty**: `░` (rich), `-` (plain)
**Format**: `Label: ████████░░░░░░░░░░ 40% (4/10)`

```
Installation: ████████████░░░░░░░░ 60% (6/10)
```

---

#### `show_checklist <array_name>`
Display task checklist with status indicators.

**Parameters**:
- `array_name`: Name of bash array containing "status|label|detail" items

**Statuses**: done (✓), active (●), pending (○), skip (—)
**Colors**: done=green, active=blue, pending=dim, skip=yellow
**Columns**: Label width 24 chars, detail fills remaining

```
  ✓  Build Docker image     Completed in 45s
  ●  Run tests              156 tests running...
  ○  Deploy to staging      Waiting
  —  Run linter             Skipped (--no-lint flag)
```

---

### Header Widgets

#### `show_header <title>`
Simple bold header without borders.

**Parameters**:
- `title`: Header text

**Format**: Bold text with blank lines before/after

```

Title Text Here

```

---

#### `show_subheader <title>`
Secondary header, muted style.

**Parameters**:
- `title`: Subheader text

**Format**: Muted/dim text, no blank lines

```
Subtitle Text Here
```

---

### Formatting Helpers

#### `print_kv <key> <value> [width]`
Display key-value pairs in aligned columns.

**Parameters**:
- `key`: Key name
- `value`: Value text
- `width`: Key column width (default: 20)

**Format**: `  Key:     Value`

```
  Project:              my-awesome-app
  Version:              1.2.3
```

---

#### `print_command <command>`
Display command in code/monospace style.

**Parameters**:
- `command`: Command text

**Format**: `  command text` (dim/code color)

---

#### `print_item <text>`
Display bulleted list item.

**Parameters**:
- `text`: Item text

**Format**: `  • Text` (rich), `  - Text` (plain)

---

#### `print_step <number> <text>`
Display numbered step.

**Parameters**:
- `number`: Step number
- `text`: Step text

**Format**: `  1. Text`

---

#### `print_section <title>`
Display section divider.

**Parameters**:
- `title`: Section title

**Format**: Bold title with decorative line

---

#### `print_next_steps <items...>`
Display numbered list of next steps.

**Parameters**:
- `items`: Step items

**Format**: Numbered list in styled block

---

## Implementation Requirements

### Width Calculations
- **Always use `_display_width()`** for measuring text (handles CJK, emoji, full-width chars)
- **Never use** `${#string}`, `wc -c`, `wc -m` for display width

### Padding
- **Always use `_pad_to_width()`** for padding content to exact width
- **All bordered lines must have right borders** (no missing borders)

### Security
- **Always use `_escape_input()`** on user-provided strings
- Strips ANSI codes, control characters, prevents injection

### Border Box Rules
1. Inner width = `box_width - 2` (subtract left/right borders)
2. Content padding = `inner_width - left_padding - right_padding`
3. Word wrap at content padding width using `fold -s`
4. Every content line padded to exact inner_width
5. Every line has both left AND right borders

### Wide Character Support
Test all widgets with:
- ASCII text
- Emoji (2-column width)
- CJK characters (2-column width)
- Full-width characters
- Mixed content

### Fallback Modes
- **Rich mode**: UTF-8 + color (default)
- **Color mode**: ASCII + color
- **Plain mode**: ASCII only
