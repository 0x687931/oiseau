#!/usr/bin/env bash
# Spinner Widget Demo
# Demonstrates all spinner styles and usage patterns

source "$(dirname "$0")/../oiseau.sh"

show_header_box "Spinner Widget Demo" "Showcasing all spinner styles and modes"

echo ""
show_header "Basic Usage"
echo ""

# Demo 1: Simple spinner
show_info "Starting a 3-second task..."
start_spinner "Processing data..."
sleep 3
stop_spinner
show_success "Task completed!"

echo ""

# Demo 2: All spinner styles
show_header "All Spinner Styles"
echo ""

styles=("dots" "line" "circle" "pulse" "arc")

for style in "${styles[@]}"; do
    export OISEAU_SPINNER_STYLE="$style"
    show_info "Style: $style"
    start_spinner "Loading with $style spinner..."
    sleep 2
    stop_spinner
    echo ""
done

unset OISEAU_SPINNER_STYLE

echo ""

# Demo 3: Different FPS
show_header "Frame Rate Demonstration"
echo ""

show_info "Slow spinner (5 FPS)"
export OISEAU_SPINNER_FPS=5
start_spinner "Slow animation..."
sleep 2
stop_spinner

echo ""

show_info "Fast spinner (20 FPS)"
export OISEAU_SPINNER_FPS=20
start_spinner "Fast animation..."
sleep 2
stop_spinner

unset OISEAU_SPINNER_FPS

echo ""
echo ""

# Demo 4: Real-world example
show_header "Real-World Example: Build Process"
echo ""

tasks=(
    "Cleaning build directory|2"
    "Compiling source files|3"
    "Running tests|2"
    "Generating documentation|2"
    "Creating distribution package|1"
)

for task in "${tasks[@]}"; do
    IFS='|' read -r name duration <<< "$task"

    start_spinner "$name..."
    sleep "$duration"
    stop_spinner
    show_success "$name complete"
done

echo ""
show_success "Build process finished successfully!"

echo ""
echo ""

# Demo 5: Error handling
show_header "Error Handling Example"
echo ""

start_spinner "Attempting risky operation..."
sleep 2
stop_spinner
show_error "Operation failed! (but spinner cleaned up properly)"

echo ""
echo ""

# Summary
show_summary "Spinner Features" \
    "✓ 5 spinner styles (dots, line, circle, pulse, arc)" \
    "✓ Configurable FPS (frames per second)" \
    "✓ Auto-adapts to terminal (UTF-8, ASCII, Plain)" \
    "✓ Simple start/stop helpers" \
    "✓ Automatic cleanup on exit" \
    "✓ Input sanitization for security"

echo ""
show_info "Try different modes:"
print_command "OISEAU_MODE=color ./examples/spinner_demo.sh"
print_command "NO_COLOR=1 ./examples/spinner_demo.sh"

echo ""
