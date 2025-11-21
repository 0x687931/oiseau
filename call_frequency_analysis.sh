#!/usr/bin/env bash
# Analyze actual _display_width call frequency in real widgets

source ./oiseau.sh

echo "=== CALL FREQUENCY ANALYSIS ==="
echo ""

# Instrumentation: wrap _display_width to count calls
_display_width_count=0
_display_width_original_func=$(declare -f _display_width)

_display_width() {
    _display_width_count=$((_display_width_count + 1))
    # Call original implementation
    eval "${_display_width_original_func#_display_width}"
    _display_width_impl "$@"
}

_display_width_impl() {
    local str="$1"
    local clean=$(_strip_ansi "$str")
    local width

    if [ "$OISEAU_HAS_PERL" = "1" ]; then
        local perl_width
        if perl_width=$(echo -n "$clean" | perl -C -ne '
            use utf8;
            binmode(STDIN, ":utf8");
            binmode(STDOUT, ":utf8");
            chomp;

            my $width;
            eval {
                require Text::VisualWidth::PP;
                Text::VisualWidth::PP->import("width");
                $width = width($_);
            };

            if (!defined $width) {
                $width = 0;
                for my $char (split //, $_) {
                    my $code = ord($char);
                    if (
                        $code == 0x2713 ||
                        $code == 0x2717 ||
                        $code == 0x26A0 ||
                        $code == 0x2139 ||
                        $code == 0x25CB ||
                        $code == 0x25CF ||
                        $code == 0x2298
                    ) {
                        $width += 1;
                    }
                    elsif (
                        ($code >= 0x3040 && $code <= 0x309F) ||
                        ($code >= 0x30A0 && $code <= 0x30FF) ||
                        ($code >= 0x3400 && $code <= 0x4DBF) ||
                        ($code >= 0x4E00 && $code <= 0x9FFF) ||
                        ($code >= 0xAC00 && $code <= 0xD7AF) ||
                        ($code >= 0xF900 && $code <= 0xFAFF) ||
                        ($code >= 0xFF00 && $code <= 0xFF60) ||
                        ($code >= 0xFFA0 && $code <= 0xFFDC) ||
                        ($code >= 0x1F300 && $code <= 0x1F9FF) ||
                        ($code >= 0x20000 && $code <= 0x2FFFF) ||
                        ($code >= 0x2600 && $code <= 0x26FF) ||
                        ($code >= 0x2700 && $code <= 0x27BF)
                    ) {
                        $width += 2;
                    } else {
                        $width += 1;
                    }
                }
            }
            print $width;
        ' 2>/dev/null) && [ -n "$perl_width" ]; then
            width="$perl_width"
            echo "$width"
            return
        fi
    fi

    local char_count=$(echo -n "$clean" | wc -m | tr -d ' ')
    local byte_count=$(LC_ALL=C printf %s "$clean" | wc -c | tr -d ' ')
    local estimated_wide=$(( (byte_count - char_count) / 2 ))

    local icon_count=0
    local temp="$clean"
    for icon in "✓" "✗" "⚠" "ℹ" "○" "●" "⊘"; do
        local without="${temp//$icon/}"
        icon_count=$((icon_count + ${#temp} - ${#without}))
        temp="$without"
    done
    estimated_wide=$((estimated_wide - icon_count))

    if [ "$estimated_wide" -lt 0 ]; then
        estimated_wide=0
    fi

    width=$((char_count + estimated_wide))
    echo "$width"
}

# Test individual widgets
test_widget() {
    local widget_name="$1"
    shift
    _display_width_count=0

    # Run widget silently
    "$@" >/dev/null 2>&1

    echo "$widget_name: $_display_width_count calls"
}

echo "=== Per-Widget Call Frequency ==="
echo ""

test_widget "show_box (error, 2 commands)" show_box error "Error" "Message" "cmd1" "cmd2"
test_widget "show_box (info, no commands)" show_box info "Info" "Message"
test_widget "show_header_box (title only)" show_header_box "Title"
test_widget "show_header_box (title+subtitle)" show_header_box "Title" "Subtitle text"
test_widget "print_step" print_step 1 "Step description"
test_widget "print_step_header" print_step_header "Title" 1 5 "Subtitle"
test_widget "show_progress_bar" show_progress_bar 50 100 "Task"
test_widget "show_success_box (3 items)" show_success_box "Success" "item1" "item2" "item3"

echo ""
echo "=== show_table Analysis ==="
_display_width_count=0
data=("Col1" "Col2" "Col3" "A" "B" "C" "D" "E" "F")
show_table data 3 "Test" >/dev/null 2>&1
echo "show_table (3x3): $_display_width_count calls"

_display_width_count=0
data=("C1" "C2" "C3" "C4" "C5" $(seq 1 25))
show_table data 5 "Test" >/dev/null 2>&1
echo "show_table (6x5): $_display_width_count calls"

echo ""
echo "=== Cumulative Scenario Analysis ==="
echo ""

# Scenario 1: Simple CLI output
echo "Scenario 1: Simple CLI (10 steps, 1 success)"
_display_width_count=0
for i in {1..10}; do
    print_step "$i" "Step $i description" >/dev/null 2>&1
done
show_success_box "Complete" "Task finished" >/dev/null 2>&1
echo "  Total calls: $_display_width_count"
echo ""

# Scenario 2: Progress bar updates
echo "Scenario 2: Progress updates (20 updates)"
_display_width_count=0
for i in {5..100..5}; do
    show_progress_bar "$i" 100 "Processing" >/dev/null 2>&1
done
echo "  Total calls: $_display_width_count"
echo ""

# Scenario 3: Complex deployment UI
echo "Scenario 3: Deployment UI (mixed widgets)"
_display_width_count=0
print_step_header "Deployment" 1 3 "Starting deployment" >/dev/null 2>&1
for i in {10..100..10}; do
    show_progress_bar "$i" 100 "Deploying" >/dev/null 2>&1
done
show_success_box "Deployed" "Service: api-server" "URL: https://example.com" >/dev/null 2>&1
show_box info "Next Steps" "Review logs" "run-command" >/dev/null 2>&1
echo "  Total calls: $_display_width_count"
echo ""

# Scenario 4: Table-heavy interface
echo "Scenario 4: Table-heavy interface (3 tables)"
_display_width_count=0
for t in {1..3}; do
    data=("Name" "Status" "Time" "task1" "✓ Done" "5s" "task2" "Running" "2s" "task3" "Pending" "0s")
    show_table data 3 "Table $t" >/dev/null 2>&1
done
echo "  Total calls: $_display_width_count"
echo ""

echo "=== Analysis Summary ==="
echo ""
echo "Call frequency by widget type:"
echo "  - Simple widgets (print_step): 0-1 calls"
echo "  - Header widgets (show_header_box): 0 calls (uses _pad_to_width)"
echo "  - Box widgets (show_box): 2-3 calls"
echo "  - Progress bars: 1 call per update"
echo "  - Tables: N×M calls (one per cell) + column width calculation"
echo ""
echo "Typical application profiles:"
echo "  - CLI tool (10 steps): ~10-20 calls"
echo "  - Progress animation (20 updates): ~20 calls"
echo "  - Complex UI (mixed): ~30-50 calls"
echo "  - Table-heavy (3 tables, 4x3 each): ~72+ calls"
echo ""
echo "Performance implications at 4ms/call:"
echo "  - 10 calls = 40ms (acceptable)"
echo "  - 50 calls = 200ms (noticeable)"
echo "  - 100 calls = 400ms (poor UX)"
echo "  - 500 calls = 2000ms (unacceptable)"
echo ""
