# Emoji/CJK Alignment: Quick Decision Guide

**Question**: How to handle emoji/CJK character alignment in box rendering?

**Current State**: Boxes look aligned visually, but have different byte counts per line.

---

## The 3 Options

```
┌─────────────────────────────────────────────────────────────┐
│ Option A: Strip Emoji/CJK                                   │
│ ----------------------------------------------------------- │
│ Time:   6 hours                                             │
│ Result: ASCII-only, perfect byte alignment                  │
│ Risk:   Low technical, HIGH user impact                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option B: Document the Limitation                           │
│ ----------------------------------------------------------- │
│ Time:   1.5 hours                                           │
│ Result: No code changes, clear expectations                 │
│ Risk:   Very low                                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option C: Fix Architecture                                  │
│ ----------------------------------------------------------- │
│ Time:   12 hours                                            │
│ Result: Proper validation, clear design                     │
│ Risk:   Low-medium, high educational value                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Visual Comparison

### What Users See (Terminal Output)

**All 3 options produce IDENTICAL visual output:**

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   Plain text                                             ┃  ← Looks aligned
┃   📁 One emoji                                           ┃  ← Looks aligned
┃   📁 🌿 Two emojis                                       ┃  ← Looks aligned
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### What Validation Tools See (Byte Counts)

**Option A: Strip Emoji/CJK**
```
Line 1: 64 bytes  ┃   Plain text       ┃
Line 2: 64 bytes  ┃   One emoji        ┃  ← Emoji stripped!
Line 3: 64 bytes  ┃   Two emojis       ┃  ← Emoji stripped!
                  ✓ Perfect byte alignment
                  ✗ Lost user content
```

**Option B: Accept Limitation**
```
Line 1: 64 bytes  ┃   Plain text                                             ┃
Line 2: 66 bytes  ┃   📁 One emoji                                           ┃
Line 3: 68 bytes  ┃   📁 🌿 Two emojis                                       ┃
                  ✗ Different byte counts
                  ✓ Visually aligned (what matters!)
                  ✓ User content preserved
```

**Option C: Fix Architecture**
```
Line 1: 58 display cols  ┃   Plain text                                             ┃
Line 2: 58 display cols  ┃   📁 One emoji                                           ┃
Line 3: 58 display cols  ┃   📁 🌿 Two emojis                                       ┃
                         ✓ Perfect display width alignment
                         ✓ Validates the right thing
                         ✓ User content preserved
```

---

## Effort vs Impact

```
Impact on Users
    ↑
    │
High│         A (BAD)
    │          x
    │
    │
    │
 Low│    B ●─────────────● C
    │   (GOOD)      (BEST)
    │
    └──────────────────────────→ Development Effort
      Low        Medium      High
    (1.5h)       (6h)      (12h)
```

**Key Insight**: Options B and C have same user impact (none), but C costs 8x more.

---

## Risk Matrix

| Risk Type | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| **Breaks user workflows** | 🔴 High | 🟢 None | 🟢 None |
| **Introduces bugs** | 🟡 Medium | 🟢 None | 🟡 Low |
| **Maintenance burden** | 🟢 Low | 🟢 None | 🟡 Medium |
| **User complaints** | 🔴 High | 🟡 Low | 🟢 None |
| **Technical debt** | 🟢 None | 🟡 Medium | 🟢 None |

---

## What's Actually Happening?

### The Fundamental Truth

Terminals render based on **visual columns**, not **bytes**:

```
Character | Bytes | Display Columns | Why?
----------|-------|-----------------|-------------------------
    A     |   1   |        1        | Basic ASCII
    中    |   3   |        2        | CJK characters are wide
    📁    |   4   |        2        | Emoji are wide
```

### Current Implementation

**Display Width Function** (143 lines of code):
```bash
_display_width() {
    # Calculates visual columns (CORRECT)
    # "📁 file" → returns 7 columns
    # Uses Perl wcwidth when available
    # Falls back to byte-count heuristic
}
```

**Padding Function** (12 lines of code):
```bash
_pad_to_width() {
    # Pads to visual columns (CORRECT)
    # If content is 7 cols, target is 58 cols
    # Adds 51 spaces (CORRECT)
}
```

**Result**:
- Visual: ✅ Perfectly aligned in terminal
- Bytes: ❌ Different byte counts per line

### The "Problem"

Validation script expects all lines to have equal **byte counts**.

**This expectation is wrong.**

Lines should have equal **display widths**, not equal byte counts.

---

## Detailed Cost Analysis

### Option A: Strip Emoji/CJK

**Development Costs**:
- Implementation: 2 hours
- Testing: 3 hours (24 tests to update)
- Documentation: 1 hour
- **Total: 6 hours**

**Ongoing Costs**:
- Support: Users complaining about missing emoji
- Workarounds: Users need ASCII alternatives
- Brand: Library looks legacy

**Technical**:
```diff
 _escape_input() {
     local input="$1"
     local result=$(_strip_ansi "$input")

+    # Strip emoji (4-byte UTF-8)
+    result=$(echo "$result" | sed 's/[\xF0-\xF7][\x80-\xBF]\{3\}//g')
+
+    # Strip CJK (3-byte UTF-8)
+    result=$(echo "$result" | sed 's/[\xE0-\xEF][\x80-\xBF]\{2\}//g')

     # Remove control characters
     # ...
 }
```

**Example Output**:
```bash
# User writes:
show_box info "Status" "📁 project • 🌿 main"

# Gets this:
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ℹ  Status                                               ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃   project  main                                          ┃  ← emoji gone!
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### Option B: Accept Limitation

**Development Costs**:
- Documentation: 1 hour
- Issue triage: 0.5 hours
- **Total: 1.5 hours**

**Ongoing Costs**:
- Minimal (well-documented behavior)

**Technical**:
```markdown
# Add to README.md

### Known Limitations

**Emoji and CJK Character Alignment**

Box borders may have varying byte counts when content contains emoji
or CJK characters. This is expected behavior.

**Why**: Emoji occupy 2 visual columns but use 4 bytes in memory.

**Impact**: None for users. Lines are visually aligned in terminals.

**Only affects**: Byte-level validation tools (not terminal rendering).

**Example**:
┏━━━━━━━━━━━━━━┓
┃ Plain text   ┃  ← 64 bytes
┃ 📁 With emoji┃  ← 66 bytes (but visually aligned!)
┗━━━━━━━━━━━━━━┛

Both lines appear aligned in terminal (which is what matters).
```

**Example Output**:
```bash
# User writes:
show_box info "Status" "📁 project • 🌿 main"

# Gets this:
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ℹ  Status                                               ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃  📁 project • 🌿 main                                     ┃  ← perfect!
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### Option C: Fix Architecture

**Development Costs**:
- Validation script: 4 hours
- Architecture docs: 3 hours
- Test updates: 3 hours
- Code review: 2 hours
- **Total: 12 hours**

**Ongoing Costs**:
- Maintenance: Medium (need to maintain docs)
- Benefit: Educational value for team

**Technical**:

New file: `tests/validation/validate_alignment_visual.sh`
```bash
#!/usr/bin/env bash
# Validate visual alignment (not byte count)

source "$(dirname "$0")/../../oiseau.sh"

validate_box_alignment() {
    local output="$1"

    # Extract content lines (between borders)
    while IFS= read -r line; do
        # Strip ANSI
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Extract content between ┃ borders
        content="${clean#*┃}"
        content="${content%┃*}"

        # Measure display width (not bytes!)
        width=$(_display_width "$content")

        # Validate consistency
        if [ "$width" -ne "$expected_width" ]; then
            echo "FAIL: Misaligned display width"
            return 1
        fi
    done <<< "$output"

    echo "PASS: All lines have display width $expected_width"
}
```

New file: `docs/DISPLAY_WIDTH_ARCHITECTURE.md`
```markdown
# Display Width Architecture

## Core Principle

Oiseau validates **visual alignment**, not **byte equality**.

## Why?

Terminals render by display columns:
- ASCII: 1 byte = 1 column
- CJK: 3 bytes = 2 columns
- Emoji: 4 bytes = 2 columns

## Validation Philosophy

✅ **Correct**: Display width equality
❌ **Incorrect**: Byte count equality

Byte count will vary with emoji/CJK. This is expected and correct.
```

**Example Output**: Same as Option B (users see no difference)

---

## Recommendation Logic

### Decision Tree

```
                    Does visual alignment work?
                            │
                   ┌────────┴────────┐
                  Yes               No
                   │                 │
                   │            Fix the bug!
                   │
         Are users complaining?
                   │
          ┌────────┴────────┐
         No                Yes
          │                 │
     Option B          Why complaining?
    (Document)              │
                   ┌────────┴────────┐
              About bytes       About visuals
                   │                 │
              Option B           Fix rendering
              (Not real)         (Real issue)
```

**Current State**: Visual alignment works, no user complaints, only byte-level validation "fails"

**Therefore**: Option B

---

## Why Option B is Best

### 1. Technical Correctness

The current code IS correct:
- ✅ Display width calculation: Correct
- ✅ Padding calculation: Correct
- ✅ Visual alignment: Correct
- ❌ Byte count validation: Wrong expectation

**Fixing the wrong expectation (validation) is better than changing correct code.**

### 2. Pragmatic Engineering

Time investment:
- Option A: 6 hours to make things worse
- Option B: 1.5 hours to clarify expectations
- Option C: 12 hours to be "perfect"

**Option B gives 90% of value for 10% of effort.**

### 3. User Impact

What users care about:
- ✅ Boxes look aligned in terminal
- ✅ Emoji/CJK work properly
- ❌ Byte count (invisible to users)

**Option B preserves what users care about.**

### 4. Reversibility

Can easily upgrade later:
- B → C: Add validation scripts (no breaking changes)
- B → A: Strip emoji if needed (breaking change)
- A → B/C: Hard to undo (user content already stripped)

**Option B keeps options open.**

---

## Implementation Plan (Option B)

### Step 1: Update README.md (30 min)

Add after line 100 (Customization section):

```markdown
### Known Limitations

#### Emoji and CJK Character Alignment

Box rendering optimizes for visual alignment in terminals. When content
contains emoji or CJK (Chinese/Japanese/Korean) characters, output
lines may have varying byte counts while appearing perfectly aligned
visually.

**Technical explanation**: Emoji and CJK characters occupy 2 display
columns but use 3-4 bytes in memory. Padding is calculated based on
display columns (correct for terminal rendering), resulting in different
byte counts per line.

**Impact**: None for terminal users. Lines appear aligned correctly.
Only affects byte-level validation tools.

**Example**:
┏━━━━━━━━━━━━━━┓
┃ Plain text   ┃  ← 64 bytes
┃ 📁 With emoji┃  ← 66 bytes
┗━━━━━━━━━━━━━━┛

Both lines are visually aligned in terminals (which is what matters for
user experience).

**Validation**: Use display width validation, not byte count validation.
See `tests/validation/` for examples.
```

### Step 2: Update VERTICAL_ALIGNMENT_ANALYSIS.md (15 min)

Update conclusion section:

```markdown
## Conclusion

### Status: ✅ Working Correctly

The vertical alignment implementation is correct. Visual alignment in
terminals is perfect for all content types including emoji and CJK.

### Byte Count Differences are Expected

Lines with emoji/CJK will have different byte counts while maintaining
visual alignment. This is correct behavior:

- Display width: Equal (✅ visually aligned)
- Byte count: Varies (✅ expected with wide characters)

### Validation Approach

- ✅ Validate display width equality
- ❌ Don't validate byte count equality

For validation examples, see `tests/validation/validate_alignment_visual.sh`.
```

### Step 3: Update check_actual_alignment.sh (15 min)

Add header note:

```bash
#!/usr/bin/env bash
# Display byte counts for educational purposes
#
# NOTE: Byte count differences are EXPECTED when content contains
# emoji or CJK characters. This is not a bug. Visual alignment in
# terminals is correct.
#
# What matters: Display width equality (visual columns)
# What doesn't: Byte count equality (invisible to users)

# ... rest of script
```

### Step 4: Close Issue #68 (15 min)

Comment:

```markdown
## Resolution: Working as Intended

After thorough investigation, the vertical alignment is **working correctly**.

### What's Happening

Lines with emoji/CJK have different byte counts but identical display widths:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   Plain text                                             ┃  64 bytes, 58 cols
┃   📁 One emoji                                           ┃  66 bytes, 58 cols
┃   📁 🌿 Two emojis                                       ┃  68 bytes, 58 cols
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

All lines are visually aligned in terminals (what users see and care about).

### Why Different Byte Counts?

- Emoji: 4 bytes, 2 display columns
- CJK: 3 bytes, 2 display columns
- ASCII: 1 byte, 1 display column

Padding is based on display columns (correct), so byte counts vary (expected).

### Documentation

Added "Known Limitations" section to README explaining this behavior.

### Validation

Use display width validation, not byte count validation. See:
- `VERTICAL_ALIGNMENT_ANALYSIS.md` (updated)
- `tests/validation/` (validation examples)

Closing as **working as intended**.
```

**Total Time**: 1.5 hours

---

## When to Reconsider

**Upgrade to Option C if**:

1. Need formal validation framework (CI/CD requirements)
2. Educational project (teaching best practices)
3. Multiple developers need clear architecture docs
4. Long-term maintenance (5+ years)

**Downgrade to Option A if**:

1. Only internal use (no external users)
2. ASCII-only requirement emerges
3. Byte-perfect output required (regulatory compliance)

**Stay with Option B if**:

1. Current implementation works for users ✓
2. Limited development time ✓
3. Want to ship quickly ✓
4. Can defer decision ✓

---

## Bottom Line

**Problem**: Byte count validation fails with emoji/CJK
**Root Cause**: Validation expectation is wrong
**Solution**: Update validation expectation, not code

**Recommendation**: Option B (1.5 hours)
**Alternative**: Option C if architectural purity matters (12 hours)
**Avoid**: Option A (breaks user expectations)

The current code is correct. Document it and move on.
