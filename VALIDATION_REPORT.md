# Oiseau Widget Validation Report

**Generated**: 2025-11-15
**Overall Compliance**: 56% (9/16 widgets compliant)
**Critical Issues**: 3 widgets broken

---

## Executive Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Widgets | 16 | 100% |
| Fully Compliant | 9 | 56% |
| Partially Compliant (fixable) | 4 | 25% |
| Non-Compliant (broken) | 3 | 19% |
| **Critical Issues** | **3** | High priority |
| Medium Issues | 4 | Edge cases, alignment |
| Low Issues | 5 | Input sanitization |

**Status**: 3 widgets are visually broken and require immediate fixes.

---

## Critical Issues (High Priority)

### 0. `oiseau.sh` Initialization - `local` Used at Top Level ✅ FIXED

**Problem**:
- Lines 39 and 54 used `local` keyword outside of function scope
- `bash -c 'source oiseau.sh'` failed with error: `local: can only be used in a function`
- Terminal detection variables (`colors`, `locale_check`) incorrectly scoped

**Impact**:
- Library fails to source in certain bash execution contexts
- Terminal capability detection failed before variables were assigned
- Broke `OISEAU_HAS_COLOR` and `OISEAU_HAS_UTF8` initialization

**Fix**:
```bash
# Line 39 - BEFORE:
local colors=$(tput colors 2>/dev/null || echo 0)
# AFTER:
colors=$(tput colors 2>/dev/null || echo 0)

# Line 54 - BEFORE:
local locale_check="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
# AFTER:
locale_check="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
```

**Status**: ✅ FIXED
**File**: oiseau.sh:39, 54
**Credit**: Found by code review on PR#5

---

### 1. `show_summary` - Missing Right Borders & No Wrapping

**Problem**:
- Title line (L535) and item lines (L539) missing right border `│`
- Long items overflow box width (no text wrapping)
- Not using `_pad_to_width()` for content lines

**Impact**:
- Boxes appear broken, misaligned
- Long text breaks box structure entirely

**Fix**:
```bash
# Replace lines 535, 539 with:
echo -e "${COLOR_BORDER}${BOX_V}${RESET}$(_pad_to_width "  ${ICON_SUCCESS}  ${title}" "$inner_width")${COLOR_BORDER}${BOX_V}${RESET}"

# Wrap items:
for item in "${items[@]}"; do
    echo "$item" | fold -s -w $((inner_width - 4)) | while IFS= read -r line; do
        echo -e "${COLOR_BORDER}${BOX_V}${RESET}$(_pad_to_width "  $line" "$inner_width")${COLOR_BORDER}${BOX_V}${RESET}"
    done
done
```

**Effort**: 45 minutes
**File**: oiseau.sh:527-543

---

### 2. `show_section_header` - Missing Right Borders

**Problem**:
- Title line (L349) and step counter line (L357) missing right border `│`
- Not using `_pad_to_width()` for content lines

**Impact**:
- Boxes appear broken, misaligned with other widgets

**Fix**:
```bash
# Replace lines 349, 357 with:
echo -e "${COLOR_BORDER}${BOX_V}${RESET}$(_pad_to_width "  ${title}" "$inner_width")${COLOR_BORDER}${BOX_V}${RESET}"
echo -e "${COLOR_BORDER}${BOX_V}${RESET}$(_pad_to_width "  ${step_text}" "$inner_width")${COLOR_BORDER}${BOX_V}${RESET}"
```

**Effort**: 30 minutes
**File**: oiseau.sh:336-361

---

### 3. `print_kv` - Broken CJK/Emoji Alignment

**Problem**:
- Uses `printf "%-${width}s"` which counts bytes, not display width
- CJK characters (2 columns) and emoji break column alignment

**Impact**:
- Key-value pairs misaligned when using CJK/emoji
- Example: `项目` (2 chars, 4 columns) gets wrong padding

**Fix**:
```bash
print_kv() {
    local key="$(_escape_input "$1")"
    local value="$(_escape_input "$2")"
    local key_width="${3:-20}"

    local key_display_width=$(_display_width "$key")
    local padding=$((key_width - key_display_width))
    [ "$padding" -lt 0 ] && padding=0

    printf "  ${COLOR_MUTED}%s${RESET}%${padding}s %s\n" "$key" "" "$value"
}
```

**Effort**: 20 minutes
**File**: oiseau.sh:594-600

---

## Medium Priority Issues

### 4. `show_progress_bar` - Division by Zero

**Problem**: No protection for `total=0`, causes crash at line 484

**Impact**: Script crashes if called with invalid args

**Fix**: Add check: `[ "$total" -eq 0 ] && percent=0 || percent=$((current * 100 / total))`

**Effort**: 10 minutes
**File**: oiseau.sh:479-492

---

### 5. `show_checklist` - CJK/Emoji Column Alignment

**Problem**: No column width enforcement, CJK/emoji breaks alignment

**Impact**: Labels and details misaligned with wide characters

**Fix**: Use `_display_width()` to calculate padding for 24-char label column

**Effort**: 30 minutes
**File**: oiseau.sh:497-519

---

## Low Priority Issues

### 6-10. Missing Input Sanitization (Security)

**Problem**: 8 widgets don't use `_escape_input()` on user input

**Affected Widgets**:
- show_header, show_subheader, print_item, print_step (L288-623)
- show_section_header, show_summary, show_checklist (already listed above)

**Impact**: Potential ANSI injection attacks

**Fix**: Wrap all user input with `_escape_input()`

**Effort**: 15 minutes total (1-2 min per widget)

---

## Current vs Proposed Customization

| Capability | Current | Proposed | Complexity |
|------------|---------|----------|------------|
| Change border style globally | ❌ No | ✅ `OISEAU_BORDER_STYLE` | 1 env var |
| Change colors globally | ⚠️ `NO_COLOR=1` only | ✅ Existing `COLOR_*` vars | 0 changes |
| Change box width globally | ❌ No | ✅ `OISEAU_BOX_WIDTH` | 1 env var |
| Works with zero config | ✅ Yes | ✅ Yes | All optional |

**Proposed Customization** (3 environment variables):

```bash
# Optional customization
export OISEAU_BORDER_STYLE="rounded"  # rounded|double|ascii
export OISEAU_BOX_WIDTH="80"          # Override default 60
export COLOR_ERROR="196"              # Override any color
```

**Implementation Effort**: 30 minutes (add env var checks to existing code)

---

## Action Items (Priority Order)

### Critical (Do First)
1. **Fix `show_summary` right borders and wrapping** - 45 min
2. **Fix `show_section_header` right borders** - 30 min
3. **Fix `print_kv` CJK alignment** - 20 min

### Medium (Do Next)
4. **Add `show_progress_bar` division by zero check** - 10 min
5. **Fix `show_checklist` column alignment** - 30 min

### Low (Do Last)
6. **Add input sanitization to 8 widgets** - 15 min total

### Enhancement (Optional)
7. **Implement 3-variable customization system** - 30 min
8. **Update documentation** - 30 min

**Total Critical Fix Time**: 1.5 hours
**Total All Fixes**: 3.5 hours

---

## Validation Summary

**What's Broken?**
- 3 widgets have missing right borders (visual break)
- 1 widget has broken CJK/emoji alignment
- 1 widget can crash with edge case input
- 8 widgets missing input sanitization

**What Needs to Be Fixed?**
- Add `_pad_to_width()` and right borders to 2 widgets
- Replace `printf` width calculation with `_display_width()` in 1 widget
- Add bounds checking to 1 widget
- Add `_escape_input()` to 8 widgets

**How Long Will It Take?**
- Critical fixes: 1.5 hours
- All fixes: 3.5 hours
- With enhancements: 4.5 hours
