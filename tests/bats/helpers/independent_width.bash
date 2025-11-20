# Independent width calculator for testing
# Does NOT use oiseau's _display_width - uses external tools for validation

# Calculate display width using Python wcwidth (independent verification)
python_display_width() {
    local text="$1"

    # Try Python with wcwidth library
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import sys
try:
    from wcwidth import wcswidth
    text = '''$text'''
    # Strip ANSI codes first
    import re
    text = re.sub(r'\x1b\[[0-9;]*m', '', text)
    width = wcswidth(text)
    print(width if width >= 0 else len(text))
except ImportError:
    # Fallback: count manually
    text = '''$text'''
    import re
    text = re.sub(r'\x1b\[[0-9;]*m', '', text)
    width = 0
    for char in text:
        code = ord(char)
        # Emoji ranges
        if 0x1F300 <= code <= 0x1F9FF or 0x2600 <= code <= 0x26FF:
            width += 2
        # CJK ranges
        elif 0x3040 <= code <= 0x9FFF or 0xAC00 <= code <= 0xD7AF:
            width += 2
        # Full-width ranges
        elif 0xFF00 <= code <= 0xFF60 or 0xFFA0 <= code <= 0xFFDC:
            width += 2
        else:
            width += 1
    print(width)
" 2>/dev/null
        return 0
    fi

    # Fallback to Perl with independent implementation
    if command -v perl >/dev/null 2>&1; then
        echo -n "$text" | perl -C -ne '
            use utf8;
            binmode(STDIN, ":utf8");

            # Strip ANSI codes
            s/\x1b\[[0-9;]*m//g;

            my $width = 0;
            for my $char (split //, $_) {
                my $code = ord($char);

                # Emoji ranges
                if (($code >= 0x1F300 && $code <= 0x1F9FF) ||
                    ($code >= 0x2600 && $code <= 0x26FF)) {
                    $width += 2;
                }
                # CJK ranges
                elsif (($code >= 0x3040 && $code <= 0x309F) ||
                       ($code >= 0x30A0 && $code <= 0x30FF) ||
                       ($code >= 0x3400 && $code <= 0x4DBF) ||
                       ($code >= 0x4E00 && $code <= 0x9FFF) ||
                       ($code >= 0xAC00 && $code <= 0xD7AF)) {
                    $width += 2;
                }
                # Full-width
                elsif (($code >= 0xFF00 && $code <= 0xFF60) ||
                       ($code >= 0xFFA0 && $code <= 0xFFDC)) {
                    $width += 2;
                }
                # Narrow symbols (override)
                elsif ($code == 0x2713 || $code == 0x2717 ||
                       $code == 0x26A0 || $code == 0x2139) {
                    $width += 1;
                }
                else {
                    $width += 1;
                }
            }
            print $width;
        ' 2>/dev/null
        return 0
    fi

    # Last resort: basic heuristic (independent of oiseau implementation)
    local clean=$(echo "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local char_count=$(echo -n "$clean" | wc -m | tr -d ' ')
    local byte_count=$(LC_ALL=C printf %s "$clean" | wc -c | tr -d ' ')

    # Estimate wide chars from byte overhead
    local estimated_wide=$(( (byte_count - char_count) / 2 ))

    echo $((char_count + estimated_wide))
}

# Export for use in tests
export -f python_display_width
