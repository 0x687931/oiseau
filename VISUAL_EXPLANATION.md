# Visual Explanation: Display Width vs Byte Count

## The Three Metrics Visualized

### Example Text: "📁 emoji"

```
Visual rendering in terminal (what you see):
┌──────────────┐
│ 📁 emoji    │  ← 8 display columns total
└──────────────┘
  ↑↑ ↑↑↑↑↑
  2  1 1111
  cols per char
```

### Byte-level representation (UTF-8):

```
Character:  📁       (space)   e       m       o       j       i
Bytes:      F0 9F    20        65      6D      6F      6A      69
            93 81
Count:      4 bytes  1 byte    1 byte  1 byte  1 byte  1 byte  1 byte
Total: 10 bytes
```

### Character count (codepoints):

```
Characters: 📁 (space) e m o j i
Count:      1 + 1 + 1 + 1 + 1 + 1 + 1 = 7 characters
```

### Summary Table

| Text | Display Width | Character Count | Byte Count |
|------|---------------|-----------------|------------|
| "📁 emoji" | 8 columns | 7 chars | 10 bytes |
| Difference | — | -1 | +2 |

**Key Point**: Display width (8) ≠ byte count (10)

---

## Why Padding by Display Width Produces Different Byte Counts

### Scenario: Pad to 20 display columns

```
Plain text: "hello world"
  Display width:  11 columns
  Byte count:     11 bytes
  Padding needed: 9 spaces (to reach 20 columns)
  Result:         "hello world         " (11 + 9 = 20 bytes)

Emoji text: "📁 emoji"
  Display width:  8 columns
  Byte count:     10 bytes
  Padding needed: 12 spaces (to reach 20 columns)
  Result:         "📁 emoji            " (10 + 12 = 22 bytes!)
```

### The Formula

```
padded_bytes = text_bytes + (target_display - text_display)
```

For plain text:
```
padded_bytes = 11 + (20 - 11) = 11 + 9 = 20 bytes ✓
```

For emoji text:
```
padded_bytes = 10 + (20 - 8) = 10 + 12 = 22 bytes ✗
```

**Result**: Both texts are 20 columns wide visually, but different byte lengths!

---

## Visual Box Alignment Test

### Box with plain text (all lines 60 bytes):

```
+==========================================================+
|                                                          |  60 bytes
|   Plain text                                             |  60 bytes
|                                                          |  60 bytes
+==========================================================+
```

### Box with emoji (line 3 is 62 bytes):

```
+==========================================================+
|                                                          |  60 bytes
|   📁 One emoji                                           |  62 bytes ← 2 extra!
|                                                          |  60 bytes
+==========================================================+
     ↑                                                    ↑
     Both borders align perfectly on screen (display width)
     But line 2 has 2 extra bytes due to emoji encoding
```

### The Question

Is this a bug? **NO!**

The borders align visually because terminals render by DISPLAY WIDTH, not bytes.

The byte count difference is an artifact of UTF-8 encoding, not a rendering problem.

---

## PR#85 "Fix" — Why It's Wrong

### What PR#85 Does

Changes padding formula from:
```bash
padding = target_display - text_display
```

To:
```bash
padding = target_bytes - text_bytes
```

### Result with emoji text

```
Text: "📁 emoji" (8 display cols, 10 bytes)
Target: 64 bytes

Old formula: padding = 64 - 8 = 56 spaces
  Result: 10 bytes + 56 spaces = 66 bytes
  Display: 8 + 56 = 64 columns ✓

New formula: padding = 64 - 10 = 54 spaces
  Result: 10 bytes + 54 spaces = 64 bytes ✓
  Display: 8 + 54 = 62 columns ✗ (2 columns SHORT!)
```

### Visual Result with PR#85

```
+==========================================================+
|                                                          |  64 bytes
|   📁 One emoji                                         |  64 bytes ← 2 cols short!
|                                                          |  64 bytes
+==========================================================+
                                                          ↑↑
                                           Border misaligned by 2 columns!
```

**Conclusion**: PR#85 equalizes bytes but BREAKS visual alignment!

---

## The Correct Understanding

### Terminal Rendering Reality

Terminals position cursors by DISPLAY WIDTH (columns), not bytes:

```
Terminal escape code: \033[30C  ← Move cursor 30 COLUMNS right
Not: Move cursor 30 BYTES right
```

### What Matters for Alignment

```
✓ CORRECT: All lines 64 display columns (borders align on screen)
✗ WRONG:   All lines 64 bytes (borders misalign on screen with emoji)
```

### The Architectural Truth

`_pad_to_width(text, N)` should pad to N **display columns**, not N bytes.

This is what the function does, and it's correct.

The byte count variation is a natural consequence of Unicode encoding and should be accepted, not "fixed."
