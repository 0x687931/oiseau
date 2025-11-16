# Oiseau Widget Demo Planning

Planning document for VHS demo generation across all 32 widgets.

## Strategy

**Goal:** Create visual demos that showcase Oiseau's capabilities for the README.

**Approach:**
- Not every widget needs a separate demo
- Group related widgets into combined demos
- Focus on visual/interactive widgets (skip simple text formatters)
- All demos show 3 modes: rich, color, plain

## Widget Categorization

### Category 1: Status Messages (COMBINE INTO ONE DEMO)
Simple one-line status indicators - can be combined into single "messages" demo.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_success` | ✓ | Combine all 4 into "status_messages.tape" |
| `show_error` | ✓ | |
| `show_warning` | ✓ | |
| `show_info` | ✓ | |

**Demo name:** `status_messages.tape`
**What to show:** All 4 message types in sequence

---

### Category 2: Boxes (COMBINE INTO ONE DEMO)
Styled message boxes with optional commands.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_box` | ✓ | Show error, warning, info, success variants |
| `show_header_box` | ✓ | Show in same demo with emoji |

**Demo name:** `boxes.tape`
**What to show:** Box variants (error with commands, warning, info, success) + header_box

---

### Category 3: Progress & Animation (SEPARATE DEMOS)
Visual widgets with animation - need separate demos.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_progress_bar` | ✅ | DONE - already created |
| `show_spinner` | ✓ | Show all 5 spinner styles |
| `start_spinner` | ✓ | Part of spinner demo |
| `stop_spinner` | ✓ | Part of spinner demo |

**Demo name:** `spinner.tape`
**What to show:** Different spinner styles (dots, line, circle, pulse, arc)

---

### Category 4: Checklists & Summaries (COMBINE INTO ONE DEMO)
Status tracking widgets.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_checklist` | ✓ | Show done/active/pending/skip statuses |
| `show_summary` | ✓ | Show deployment summary example |
| `show_section_header` | ✓ | Show with step numbers |

**Demo name:** `status_tracking.tape`
**What to show:** Section header → checklist → summary (git workflow example)

---

### Category 5: Headers & Titles (COMBINE INTO ONE DEMO)
Text formatting for structure.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_header` | ✓ | Combine all 3 header types |
| `show_subheader` | ✓ | |
| `show_section_header` | Skip | Already in status_tracking demo |

**Demo name:** `headers.tape`
**What to show:** Header hierarchy (header → subheader)

---

### Category 6: Interactive Inputs (SEPARATE DEMOS)
User input widgets - need interaction.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `ask_input` | ✓ | Show text, password, email, number modes |
| `ask_list` | ✓ | Show single-select and multi-select |
| `ask_yes_no` | ✓ | Show y/n prompt |
| `prompt_confirm` | Skip | Similar to ask_yes_no |

**Demo name:** `input_text.tape`
**What to show:** Text input, password (masked), email validation, number validation

**Demo name:** `input_list.tape`
**What to show:** Single-select list, then multi-select list

**Demo name:** `input_confirm.tape`
**What to show:** yes/no and confirm prompts

---

### Category 7: Formatting Helpers (COMBINE INTO ONE DEMO)
Simple text formatters - minimal visual difference across modes.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `print_kv` | ✓ | Key-value pairs |
| `print_command` | ✓ | Command formatting |
| `print_item` | ✓ | Bulleted items |
| `print_step` | ✓ | Numbered steps |
| `print_next_steps` | ✓ | Next steps list |
| `print_section` | Skip | Similar to show_header |

**Demo name:** `formatters.tape`
**What to show:** All formatters in sequence (KV → commands → items → steps → next steps)

---

### Category 8: Tables & Pagers (SEPARATE DEMOS)
Complex layout widgets.

| Widget | Demo? | Notes |
|--------|-------|-------|
| `show_table` | ✓ | Show multi-column table |
| `show_pager` | ✓ | Show paginated content |

**Demo name:** `table.tape`
**What to show:** Multi-column table with headers and data

**Demo name:** `pager.tape`
**What to show:** Scrolling through paginated content (if interactive)

---

## Summary

### Demos to Create (11 total)

1. ✅ **progress_bar.tape** - DONE
2. **status_messages.tape** - Success, error, warning, info
3. **boxes.tape** - All box variants + header_box
4. **spinner.tape** - All spinner styles
5. **status_tracking.tape** - Checklist + summary + section header
6. **headers.tape** - Header hierarchy
7. **input_text.tape** - Text input with validation
8. **input_list.tape** - List selection (single + multi)
9. **input_confirm.tape** - Yes/no and confirm prompts
10. **formatters.tape** - All text formatters
11. **table.tape** - Multi-column table

**Optional:**
- **pager.tape** - Only if pager is interactive/animated

### Widgets Covered: 27 of 27 functional widgets

**Skipped widgets:**
- `prompt_confirm` - Redundant with ask_yes_no
- `print_section` - Redundant with show_header

---

## Demo Pattern

All demos follow this structure:
```tape
Output demos/{name}.gif
Set Width 800
Set Height 400
Set FontSize 14
Set Theme "Dracula"

# Rich mode demo
...

Hide
Type "clear"
Enter
Show
Sleep 1s

# Color mode demo
...

Hide
Type "clear"
Enter
Show
Sleep 1s

# Plain mode demo
...
```

## Next Steps

1. Review this plan with user
2. Create remaining 10 tape files
3. Generate GIFs
4. Update README with demo GIFs
