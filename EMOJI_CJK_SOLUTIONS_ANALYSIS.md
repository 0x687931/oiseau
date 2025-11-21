# Emoji/CJK Handling: Three Architectural Approaches

**Context**: Issue #68 - Vertical alignment breaks when box content contains emoji or CJK characters

**Current Status**:
- Main branch (2001b9f): Has broken alignment with emoji/CJK
- Feature branch (36a499c): Has "fix" that breaks display width contract
- Repository: 5,729 lines of code, 190 usages of box functions

---

## The Core Problem

### Display Width vs Byte Count Mismatch

```
String           | Chars | Bytes | Display Cols | Problem
-----------------|-------|-------|--------------|------------------
"Plain text"     |   10  |  10   |     10       | ✓ All equal
"📁 One emoji"   |   11  |  14   |     12       | ✗ 3 different values!
"📁 🌿 Two"      |   14  |  20   |     14       | ✗ 6 byte overhead
"中文 CJK"       |    6  |  10   |      8       | ✗ 4 byte overhead
```

### Current Implementation

**Display width function** (`_display_width()`): Lines 437-580 in oiseau.sh
- ✅ Correctly calculates visual columns (emoji = 2 cols, CJK = 2 cols)
- Uses Perl with wcwidth when available
- Falls back to byte-count heuristic
- 143 lines of complex code

**Padding function** (`_pad_to_width()`): Lines 585-597
- ✅ Uses display width for padding calculation
- ❌ Doesn't account for byte count differences
- Result: Lines with emoji are 2-6 bytes longer than plain text lines

### Why the "Fix" is Problematic

Commit 36a499c changes `_pad_to_width()`:
```bash
# OLD (correct contract):
local padding=$((target_width - current_width))

# NEW (breaks contract):
local padding=$((target_width - current_width + (current_width - byte_count)))
```

**Problem**: The contract of `_pad_to_width()` is "pad to display width", not "pad to byte count"
- All callers expect display width behavior
- Mixing display width and byte count concerns violates single responsibility
- Creates confusing API where "width" sometimes means bytes

---

## Option A: Drop Emoji/CJK Support

**Approach**: Strip all emoji/CJK characters from user input before rendering

### Implementation

```bash
# Add to _escape_input() function (lines 401-425)
_escape_input() {
    local input="$1"
    local result
    result=$(_strip_ansi "$input")

    # Remove emoji and CJK characters
    # Emoji ranges: U+1F300-1F9FF, U+2600-26FF, U+2700-27BF
    # CJK ranges: U+3040-D7AF, U+F900-FFDC
    result=$(echo "$result" | LC_CTYPE=C sed '
        s/[\xF0-\xF7][\x80-\xBF]\{3\}//g  # 4-byte UTF-8 (most emoji)
        s/[\xE0-\xEF][\x80-\xBF]\{2\}//g  # 3-byte UTF-8 (CJK, some emoji)
    ')

    # Remove control characters
    # ... rest of existing code
}
```

### Changes Required

| File | Lines Changed | Risk |
|------|---------------|------|
| `oiseau.sh` | +10 lines to `_escape_input()` | Low |
| `tests/*` | Update 24 tests to expect stripped output | Low |
| Documentation | Add "ASCII-only" limitation | Low |

**Total**: ~50 lines changed across 5 files

### Pros

✅ **Simplicity**: Eliminates the entire problem class
✅ **Performance**: No complex width calculations needed
✅ **Reliability**: byte count = char count = display width (always)
✅ **Fast**: 1-2 hours implementation, 2-3 hours testing
✅ **Zero edge cases**: No more emoji variants, ZWJ, flags, etc.

### Cons

❌ **User experience**: Silently strips content (confusing)
❌ **Modern expectations**: Emoji/CJK are standard in 2025
❌ **Limited use cases**: Can't use for international projects
❌ **Brand perception**: Looks like legacy software

### Effort Estimate

- **Implementation**: 2 hours
- **Testing**: 3 hours (update 24 tests + visual verification)
- **Documentation**: 1 hour
- **Total**: 6 hours (0.75 days)

### Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| User complaints | Medium | High | Document clearly |
| Regex bugs | Low | Medium | Extensive testing |
| Edge cases | Low | Low | ASCII-only is simple |

**Overall Risk**: Low

---

## Option B: Accept the Limitation

**Approach**: Document that emoji/CJK may cause slight alignment issues

### Implementation

```markdown
# In README.md (after line 100)

### Known Limitations

**Emoji and CJK Character Alignment**

Box borders may appear slightly misaligned when content contains emoji
or CJK (Chinese/Japanese/Korean) characters. This is due to the
fundamental difference between:
- **Display width**: How many terminal columns a character occupies (emoji = 2)
- **Byte count**: How many bytes the character uses in memory (emoji = 4)

Alignment is visually correct but lines have varying byte counts.

**Example**:
┏━━━━━━━━━━━━━━┓
┃ Plain text   ┃  ← 20 bytes
┃ 📁 With emoji┃  ← 22 bytes (but looks aligned!)
┗━━━━━━━━━━━━━━┛

**Impact**: Minimal. Most terminals render correctly. Only affects
byte-level validation tools.

**Workaround**: Use ASCII alternatives (folder → [DIR])
```

### Changes Required

| File | Lines Changed | Risk |
|------|---------------|------|
| `README.md` | +20 lines documentation | None |
| `VERTICAL_ALIGNMENT_ANALYSIS.md` | Update conclusion | None |
| Issue #68 | Close with explanation | None |

**Total**: ~30 lines documentation

### Pros

✅ **Zero code changes**: No bugs introduced
✅ **Zero regression risk**: Nothing breaks
✅ **Honest**: Acknowledges technical reality
✅ **Fast**: 1 hour documentation
✅ **Correct**: Display alignment IS working properly

### Cons

❌ **Perception**: Looks like giving up
❌ **Validation**: Can't validate alignment with byte counts
❌ **OCD users**: Will still complain about "misalignment"
❌ **Technical debt**: Problem remains in codebase

### Effort Estimate

- **Documentation**: 1 hour
- **Issue triage**: 0.5 hours
- **Total**: 1.5 hours (0.2 days)

### Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| User complaints | Low | Medium | Clear docs + examples |
| Future bugs | Low | Low | Issue is documented |
| Validation fails | Medium | High | Document validation approach |

**Overall Risk**: Very Low

---

## Option C: Fix Properly at Architectural Level

**Approach**: Separate display rendering from byte-level validation

### The Core Insight

The problem is a **contract mismatch**:
- `_display_width()` returns **visual columns** (correct)
- `_pad_to_width()` expects **visual columns** (correct)
- But box validation expects **byte count equality** (incorrect assumption)

**Solution**: The validation is wrong, not the code.

### Implementation

#### 1. Keep current display width logic (no changes)

Lines 437-580 in `oiseau.sh` remain unchanged.

#### 2. Keep current padding logic (no changes)

Lines 585-597 in `oiseau.sh` remain unchanged.

#### 3. Fix validation approach

Create `tests/validation/validate_alignment_visual.sh`:

```bash
#!/usr/bin/env bash
# Validate alignment by DISPLAY WIDTH, not byte count

validate_box_alignment() {
    local output="$1"

    # Extract all content lines (skip borders)
    local lines=()
    while IFS= read -r line; do
        # Strip ANSI codes
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Skip empty lines
        [ -z "$clean" ] && continue

        # Extract content between borders
        # For "┃   content   ┃", get "   content   "
        content="${clean#*┃}"  # Remove up to first ┃
        content="${content%┃*}" # Remove from last ┃

        lines+=("$content")
    done <<< "$output"

    # Validate all lines have same DISPLAY WIDTH
    local target_width=0
    local line_num=0
    for line in "${lines[@]}"; do
        line_num=$((line_num + 1))

        # Use SAME _display_width function as implementation
        # (This is OK - we're validating consistency, not correctness)
        local width=$(_display_width "$line")

        if [ "$line_num" -eq 1 ]; then
            target_width="$width"
        elif [ "$width" -ne "$target_width" ]; then
            echo "FAIL: Line $line_num has width $width, expected $target_width"
            return 1
        fi
    done

    echo "PASS: All $line_num lines have display width $target_width"
    return 0
}
```

#### 4. Document the design decision

Create `docs/DISPLAY_WIDTH_ARCHITECTURE.md`:

```markdown
# Display Width Architecture

## Core Principle

Oiseau optimizes for **visual alignment**, not **byte count equality**.

### Why?

Terminal rendering is based on **display columns**, not bytes:
- Emoji: 4 bytes, 2 display columns
- CJK: 3 bytes, 2 display columns
- ASCII: 1 byte, 1 display column

### Implementation

- `_display_width()`: Returns visual column count
- `_pad_to_width()`: Pads to visual column count
- Result: Visually aligned output (correct)
- Side effect: Lines have different byte counts (expected)

### Validation

✅ **Correct**: Validate display width equality
❌ **Incorrect**: Validate byte count equality

Byte count validation will always fail with emoji/CJK and should be
replaced with display width validation.
```

### Changes Required

| File | Lines Changed | Risk |
|------|---------------|------|
| `tests/validation/validate_alignment_visual.sh` | +80 new | Low |
| `docs/DISPLAY_WIDTH_ARCHITECTURE.md` | +100 new | None |
| `check_actual_alignment.sh` | Delete or update | Low |
| `VERTICAL_ALIGNMENT_ANALYSIS.md` | Update conclusion | None |

**Total**: ~200 lines added/changed across 4 files

### Pros

✅ **Architecturally correct**: Validates right thing
✅ **No code changes**: Display logic stays clean
✅ **Educational**: Documents design decisions
✅ **Extensible**: Pattern applies to other validations
✅ **Future-proof**: Works with any Unicode

### Cons

❌ **Conceptual overhead**: Team must understand distinction
❌ **Documentation**: Requires clear explanation
❌ **Time**: 1-2 days for full implementation

### Effort Estimate

- **Validation script**: 4 hours
- **Architecture docs**: 3 hours
- **Test updates**: 3 hours
- **Code review**: 2 hours
- **Total**: 12 hours (1.5 days)

### Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Confusion | Medium | Medium | Clear documentation |
| Over-engineering | Low | Low | Simple implementation |
| Maintenance | Low | Low | Well-documented pattern |

**Overall Risk**: Low-Medium

---

## Side-by-Side Comparison

| Criterion | Option A: Drop Support | Option B: Accept | Option C: Fix Properly |
|-----------|----------------------|------------------|----------------------|
| **Effort** | 6 hours (0.75 days) | 1.5 hours (0.2 days) | 12 hours (1.5 days) |
| **Code Changes** | 50 lines | 0 lines | 200 lines |
| **Risk** | Low | Very Low | Low-Medium |
| **User Impact** | High (breaks workflows) | Low (docs only) | None (transparent) |
| **Technical Debt** | None (problem eliminated) | Medium (remains) | None (resolved) |
| **Maintenance** | Simple (ASCII-only) | None | Medium (docs needed) |
| **Future-Proof** | No (legacy) | No (workaround) | Yes (correct design) |
| **Education** | None | None | High (teaches concepts) |
| **Reversible** | Difficult | Easy | Easy |

## Complexity Analysis

### Current Codebase Stats
- **Total lines**: 5,729
- **Display width function**: 143 lines (2.5% of codebase)
- **Box function calls**: 190 usages across 35 files
- **Test coverage**: 24 tests for alignment

### Change Impact

| Option | Files Modified | Lines Changed | Test Updates | Risk Factor |
|--------|---------------|---------------|--------------|-------------|
| A | 5 | +50 | 24 tests | 1.5x |
| B | 2 | +30 | 0 tests | 1.0x |
| C | 4 | +200 | 3 tests | 1.2x |

---

## Recommendation: Option B (Accept the Limitation)

### Why Option B?

**1. Technical Reality**
- The current implementation IS correct for terminal rendering
- Display width alignment is what users see and experience
- Byte count equality is an artificial constraint from validation

**2. Pragmatic Engineering**
- Zero code changes = zero new bugs
- 1.5 hours vs 6-12 hours
- Can reassess later if needed

**3. User Impact**
- Visual alignment works correctly
- Emoji/CJK users are already using the library successfully
- Only validation tools see "misalignment"

**4. Strategic Value**
- Engineering time better spent on features
- Documentation improves understanding
- Keeps codebase simple

### When Option B Becomes Insufficient

Reconsider if:
- Multiple users report visual misalignment (not just byte count)
- Terminal compatibility issues emerge
- Need byte-perfect validation for compliance

Then pivot to **Option C** (not Option A).

### Implementation Plan for Option B

**Week 1: Documentation** (1.5 hours)
1. Add "Known Limitations" section to README.md
2. Update VERTICAL_ALIGNMENT_ANALYSIS.md conclusion
3. Close issue #68 with explanation and examples

**Week 1: Validation** (optional, +2 hours)
4. Update `check_actual_alignment.sh` to note byte count differences are expected
5. Add visual verification screenshots to docs

**Total**: 1.5-3.5 hours

### Why NOT Option A?

Dropping emoji/CJK support:
- ❌ Breaks modern user expectations (emoji are standard in 2025)
- ❌ Limits internationalization (CJK users excluded)
- ❌ Doesn't match library's "graceful degradation" philosophy
- ❌ Feels like giving up rather than understanding

### Why NOT Option C?

While architecturally elegant:
- ⚠️ 8x more effort (12 hours vs 1.5 hours)
- ⚠️ Solves a problem that doesn't affect users
- ⚠️ The "problem" is in validation expectations, not code
- ⚠️ Can always do this later if truly needed

**Option C is correct but not urgent.**

---

## Alternative Recommendation: Option C (for learning)

### If Goal is Architectural Excellence

If the project's purpose is educational or to demonstrate best practices:

**Choose Option C** because:
1. ✅ Teaches proper separation of concerns
2. ✅ Documents design decisions
3. ✅ Creates reusable validation patterns
4. ✅ Future-proofs the architecture

### Implementation Path

**Phase 1: Documentation** (3 hours)
- Write `docs/DISPLAY_WIDTH_ARCHITECTURE.md`
- Explain byte count vs display width distinction
- Document validation philosophy

**Phase 2: Validation Script** (4 hours)
- Create `tests/validation/validate_alignment_visual.sh`
- Implement display-width-based validation
- Test with emoji/CJK edge cases

**Phase 3: Integration** (3 hours)
- Update existing tests to use new validation
- Remove or update byte-count-based validation
- Add CI integration

**Phase 4: Polish** (2 hours)
- Code review
- Documentation review
- Close issue #68 with architectural explanation

**Total**: 12 hours over 1.5 days

---

## Decision Framework

**Choose Option A if:**
- Library is for internal use only
- No international users
- Simplicity > features

**Choose Option B if:**
- Need quick resolution
- Current implementation works visually
- Want to defer decision

**Choose Option C if:**
- Educational project
- Demonstrating best practices
- Long-term maintenance planned

---

## Final Recommendation

**Primary: Option B** (1.5 hours, pragmatic)

**Fallback: Option C** (12 hours, if architectural purity matters)

**Avoid: Option A** (breaks user expectations)

### Next Steps

1. **Discuss with stakeholders**: Which goal matters more - shipping fast or architectural excellence?
2. **Make decision**: Based on project goals
3. **Execute**: Follow implementation plan
4. **Close issue #68**: With clear explanation

**Key insight**: This isn't a bug - it's a contract clarification issue. The code works correctly for what terminals need. The validation expectations need updating, not the code.
