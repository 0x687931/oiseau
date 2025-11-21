# Validation Framework Design

## Philosophy: Independent Byte-Level Validation

**Core Principle**: Never validate code using the same functions it uses internally.

### The Problem We Solved

- ❌ **Bad**: Tests that call `_display_width()` to validate padding that uses `_display_width()`
- ✅ **Good**: Byte-count validation that measures actual output length

### The Pattern

1. **What we're validating**: Visual alignment (right border position)
2. **Internal implementation**: Uses `_display_width()` and `_pad_to_width()`
3. **Independent validation**: Count actual bytes in output, compare line-by-line

## Validation Categories Needed

### 1. Vertical Alignment (✅ DONE)
**What**: All box lines should be same byte length
**Method**: Count bytes in each line, verify all equal
**Script**: `check_actual_alignment.sh`

### 2. Text Wrapping (🔴 TODO)
**What**: Long text should wrap at correct column boundaries
**Issues to catch**:
- Wrapping in middle of emoji (emoji gets split incorrectly)
- Wrapping in middle of CJK character
- Wrapping that doesn't account for ANSI codes
- Off-by-one errors in wrap position

**Independent validation method**:
```bash
# Generate wrapped text with emoji/CJK
output=$(wrap_text "Long text with 📁 emoji and 中文 chars..." 40)

# For each line:
# 1. Strip ANSI codes
# 2. Count actual display columns (visually in terminal)
# 3. Verify no line exceeds max width
# 4. Verify no multi-byte chars are split

# Check for broken multi-byte sequences
echo "$output" | while read line; do
    # A broken emoji/CJK will fail UTF-8 validation
    if ! echo "$line" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
        echo "FAIL: Line has broken UTF-8 sequence"
    fi
done
```

### 3. Column Calculations (🔴 TODO)
**What**: Terminal column usage should be accurate
**Issues to catch**:
- Progress bars that overflow terminal width
- Multi-column layouts that don't align
- Width calculations that ignore emoji width

**Independent validation method**:
```bash
# Use ANSI cursor position reporting to get actual column
# Send: \e[6n (request cursor position)
# Receive: \e[{row};{col}R

# Or: Use tput to save/restore cursor and measure actual position
```

### 4. Box Rendering (🔴 TODO)
**What**: Box corners should connect properly
**Issues to catch**:
- Missing corners
- Mismatched Unicode/ASCII box drawing chars
- Width miscalculations causing broken boxes

**Independent validation method**:
```bash
# Pattern matching for box structure
# Top line:    ┏━━━┓ or +---+
# Middle line: ┃   ┃ or |   |
# Bottom line: ┗━━━┛ or +---+

# Verify:
# 1. First char of line 1 matches box drawing set (┏ or +)
# 2. All horizontal chars are same type (━ or -)
# 3. Corners change appropriately (┏→┓, ┗→┛)
```

### 5. ANSI Code Handling (🔴 TODO)
**What**: ANSI codes shouldn't affect width calculations
**Issues to catch**:
- Width calculations that count ANSI escape sequences
- Color codes breaking alignment
- Bold/italic codes affecting padding

**Independent validation method**:
```bash
# Generate same content with/without colors
plain=$(OISEAU_MODE=plain show_box "Test" "Content")
rich=$(OISEAU_MODE=rich show_box "Test" "Content")

# Strip ANSI from rich, compare to plain
rich_stripped=$(echo "$rich" | sed 's/\x1b\[[0-9;]*m//g')

# Byte lengths should match
if [ "$(echo "$plain" | wc -c)" != "$(echo "$rich_stripped" | wc -c)" ]; then
    echo "FAIL: ANSI codes affecting output structure"
fi
```

### 6. Progress Bar Alignment (🔴 TODO)
**What**: Multi-line progress bars should stack vertically aligned
**Issues to catch**:
- Race conditions causing misalignment
- Cursor positioning errors
- Width calculation errors with emoji in progress text

**Independent validation method**:
```bash
# Capture progress bar output to file
# Parse line by line
# For each progress bar line, extract:
#   - Starting column (should be same for all in group)
#   - Total width (should be consistent)
#   - Bar elements alignment ([=====>   ])

# Check vertical alignment by comparing starting positions
```

### 7. Emoji/CJK Width Calculations (🔴 TODO)
**What**: All emoji/CJK chars counted as 2-column width
**Issues to catch**:
- Emoji variants that are 1 column
- Combining characters
- Zero-width joiners
- Regional indicators (flags)

**Independent validation method**:
```bash
# Test known characters with known widths
test_chars=(
    "A"              # 1 column
    "中"             # 2 columns (CJK)
    "📁"             # 2 columns (emoji)
    "👨‍👩‍👧‍👦"           # Family emoji with ZWJ (varies: 2 or 8)
    "🇺🇸"             # Flag (2 regional indicators = 4 cols? or 2?)
)

for char in "${test_chars[@]}"; do
    # Render in a controlled box of known width
    # Measure actual output
    # Compare to expected
done
```

## Validation Scripts Architecture

### Structure
```
tests/
├── validation/                    # Independent validators
│   ├── validate_alignment.sh     # Vertical alignment (✅)
│   ├── validate_wrapping.sh      # Text wrapping (TODO)
│   ├── validate_columns.sh       # Column calculations (TODO)
│   ├── validate_boxes.sh         # Box rendering (TODO)
│   ├── validate_ansi.sh          # ANSI handling (TODO)
│   ├── validate_progress.sh      # Progress bars (TODO)
│   └── validate_widths.sh        # Character widths (TODO)
│
├── validation_lib.sh             # Shared utilities
│   ├── strip_ansi()
│   ├── count_bytes()
│   ├── count_display_columns()
│   ├── check_utf8_valid()
│   └── compare_outputs()
│
└── run_all_validations.sh        # Master runner
```

### Validation Library Functions

```bash
# Strip ANSI escape codes
strip_ansi() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Count actual bytes (not characters, not display width)
count_bytes() {
    printf '%s' "$1" | wc -c | tr -d ' '
}

# Count display columns using actual terminal rendering
# (not using _display_width - that's what we're validating!)
count_display_columns() {
    local text="$1"
    # Method 1: Use wc -L (max line length)
    printf '%s' "$text" | wc -L | tr -d ' '
}

# Check if string is valid UTF-8
check_utf8_valid() {
    echo "$1" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1
}

# Compare two outputs line by line
compare_line_lengths() {
    local output1="$1"
    local output2="$2"

    local len1=$(count_bytes "$output1")
    local len2=$(count_bytes "$output2")

    [ "$len1" = "$len2" ]
}
```

## Testing Strategy

### 1. Positive Tests (Should Pass)
- Plain ASCII text
- Single emoji
- Multiple emojis
- CJK characters
- Mixed content
- ANSI codes present

### 2. Negative Tests (Should Fail Gracefully)
- Invalid UTF-8 sequences
- Extremely long text
- Zero-width content
- Empty strings
- Special control characters

### 3. Edge Cases
- Text exactly at width boundary
- Text one character over boundary
- Emoji at wrap boundary
- ANSI codes at line boundaries
- Multiple spaces (should preserve or collapse?)

## Continuous Validation

### Git Hook Integration
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Run validation suite before allowing commit

if ! ./tests/run_all_validations.sh; then
    echo "❌ Validation failed - commit blocked"
    exit 1
fi
```

### CI Integration
```yaml
# .github/workflows/validation.yml
name: Validation Suite
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run validation suite
        run: ./tests/run_all_validations.sh
```

## Next Steps

1. **Immediate**: Create `validate_wrapping.sh` (text wrapping is critical)
2. **Short term**: Create validation library with shared utilities
3. **Medium term**: Cover all 7 validation categories
4. **Long term**: Integrate into CI/CD pipeline

## Success Metrics

- ✅ Every visual rendering function has independent byte-level validation
- ✅ No validation uses the same code path as implementation
- ✅ All validations run in <5 seconds total
- ✅ Zero false positives in validation suite
- ✅ Validations catch real bugs (proven with alignment bug)
