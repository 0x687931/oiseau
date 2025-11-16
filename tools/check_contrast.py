#!/usr/bin/env python3
"""
WCAG 2.0 Contrast Ratio Checker for ANSI 256 colors
Checks if our Oiseau color palette meets accessibility standards
"""

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def relative_luminance(rgb):
    """
    Calculate relative luminance per WCAG formula
    https://www.w3.org/TR/WCAG20/#relativeluminancedef
    """
    r, g, b = [x / 255.0 for x in rgb]
    
    # Apply gamma correction
    def adjust(channel):
        if channel <= 0.03928:
            return channel / 12.92
        return ((channel + 0.055) / 1.055) ** 2.4
    
    r, g, b = adjust(r), adjust(g), adjust(b)
    
    # Calculate luminance
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def contrast_ratio(rgb1, rgb2):
    """
    Calculate contrast ratio between two colors
    https://www.w3.org/TR/WCAG20/#contrast-ratiodef
    """
    l1 = relative_luminance(rgb1)
    l2 = relative_luminance(rgb2)
    
    lighter = max(l1, l2)
    darker = min(l1, l2)
    
    return (lighter + 0.05) / (darker + 0.05)

# ANSI 256 color palette (standard xterm colors)
# Mapping common ANSI codes to RGB values
ANSI_256_COLORS = {
    # Our palette colors
    33: (0, 135, 215),      # Blue (colorblind success)
    40: (0, 215, 0),        # Green (old default)
    45: (0, 215, 255),      # Cyan (colorblind info)
    46: (0, 255, 0),        # Bright green (highcontrast success)
    51: (0, 255, 255),      # Bright cyan (highcontrast info)
    75: (95, 175, 255),     # Blue (default info)
    76: (95, 215, 135),     # Green (new default success)
    117: (135, 215, 255),   # Light blue (header)
    196: (255, 0, 0),       # Red (error)
    208: (255, 135, 0),     # Orange (colorblind error)
    214: (255, 175, 0),     # Orange (default warning)
    220: (255, 215, 0),     # Gold (colorblind warning)
    226: (255, 255, 0),     # Yellow (highcontrast warning)
    240: (88, 88, 88),      # Dark gray
    244: (128, 128, 128),   # Medium gray
}

# Test against common backgrounds
BACKGROUNDS = {
    'Black (dark terminal)': (0, 0, 0),
    'White (light terminal)': (255, 255, 255),
    'Dark gray (Solarized Dark)': (0, 43, 54),
    'Light gray (Solarized Light)': (253, 246, 227),
}

print("=" * 80)
print("WCAG 2.0 CONTRAST RATIO ANALYSIS FOR OISEAU COLOR PALETTES")
print("=" * 80)
print()
print("Standards:")
print("  - WCAG AA (normal text): 4.5:1 minimum")
print("  - WCAG AAA (normal text): 7:1 minimum")
print("  - Apple HIG: 4.5:1 minimum, 7:1 preferred")
print()

palettes = {
    'DEFAULT': {
        'Success': 76,
        'Error': 196,
        'Warning': 214,
        'Info': 75,
    },
    'COLORBLIND': {
        'Success': 33,
        'Error': 208,
        'Warning': 220,
        'Info': 45,
    },
    'HIGHCONTRAST': {
        'Success': 46,
        'Error': 196,
        'Warning': 226,
        'Info': 51,
    }
}

for palette_name, colors in palettes.items():
    print(f"\n{'=' * 80}")
    print(f"{palette_name} PALETTE")
    print('=' * 80)
    
    for color_name, ansi_code in colors.items():
        rgb = ANSI_256_COLORS.get(ansi_code)
        if not rgb:
            print(f"\n{color_name} (ANSI #{ansi_code}): RGB not mapped")
            continue
            
        print(f"\n{color_name} (ANSI #{ansi_code}): RGB{rgb}")
        print("-" * 80)
        
        for bg_name, bg_rgb in BACKGROUNDS.items():
            ratio = contrast_ratio(rgb, bg_rgb)
            
            # Determine pass/fail
            aa_pass = "✓" if ratio >= 4.5 else "✗"
            aaa_pass = "✓" if ratio >= 7.0 else "✗"
            
            print(f"  vs {bg_name:30s} {ratio:5.2f}:1  "
                  f"[AA: {aa_pass}] [AAA: {aaa_pass}]")

print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print("✓ = Passes standard")
print("✗ = Fails standard")
print()
print("Recommendations:")
print("1. DEFAULT palette works best on dark backgrounds")
print("2. COLORBLIND palette needs verification on light backgrounds")
print("3. HIGHCONTRAST palette should pass on both (uses brightest colors)")
print()
