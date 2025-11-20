#!/usr/bin/env bash

# Test alignment when Perl is disabled (fallback mode)

export OISEAU_MODE="rich"
export OISEAU_HAS_PERL=0  # Force disable Perl

source "$(dirname "$0")/oiseau.sh"

echo "Testing vertical alignment WITHOUT Perl (fallback mode)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OISEAU_HAS_PERL=$OISEAU_HAS_PERL"
echo ""

show_header_box "No Perl Test 1" "No emojis"
show_header_box "No Perl Test 2" "📁 One emoji"
show_header_box "No Perl Test 3" "📁 🌿 Two emojis"
show_header_box "No Perl Test 4" "中文 CJK text"

echo ""
echo "If right edges are misaligned, the fallback width calculation is broken"
