#!/usr/bin/env bash
export OISEAU_MODE=rich
source ./oiseau.sh

echo "Testing terminal-agnostic box alignment"
echo "========================================="
echo ""

# Test 1: ASCII content
show_header_box "Test 1" "ASCII content only"

# Test 2: User tries to pass emoji (should be stripped)
show_header_box "Test 2" "User passed emoji but stripped"

# Test 3: Multiple boxes to verify vertical alignment
show_box info "Short" "A"
show_box success "Medium length" "AB"
show_box warning "Very long title here" "ABC"
show_box error "X" "Very long message content here"

echo ""
echo "All boxes above should have perfectly aligned right borders"
echo "Regardless of terminal (macOS Terminal, iTerm2, Linux, etc.)"
