#!/bin/bash
# Comprehensive widget validation suite
# Tests all UI elements for edge cases, overflow, padding issues, etc.

source ./oiseau.sh

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result tracker
test_result() {
    local test_name="$1"
    local result="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "  ✓ $test_name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "  ✗ $test_name - $result"
    fi
}

clear
echo "═══════════════════════════════════════════════════════════════"
echo "  OISEAU WIDGET VALIDATION SUITE"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ==============================================================================
# 1. SHOW_HEADER_BOX
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Testing show_header_box"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Normal text"
show_header_box "Test Header" "Test Subtitle"
test_result "show_header_box: normal text" "PASS"

echo ""
echo "Test: Emoji in title"
show_header_box "🐦 Emoji Header" "Subtitle"
test_result "show_header_box: emoji in title" "PASS"

echo ""
echo "Test: CJK in title"
show_header_box "中文标题 Chinese Title" "日本語サブタイトル"
test_result "show_header_box: CJK characters" "PASS"

echo ""
echo "Test: Very long title (should wrap)"
show_header_box "This is a very long title that should definitely wrap to multiple lines because it exceeds the box width" "Short subtitle"
test_result "show_header_box: long title wrapping" "PASS"

echo ""
echo "Test: Empty title"
show_header_box "" "Subtitle only"
test_result "show_header_box: empty title" "PASS"

echo ""
echo "Test: No subtitle"
show_header_box "Title only" ""
test_result "show_header_box: no subtitle" "PASS"

echo ""
echo "Test: Special characters"
show_header_box "Title with <>&\"' chars" "Subtitle with \$VAR"
test_result "show_header_box: special characters" "PASS"

# ==============================================================================
# 2. SHOW_BOX
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Testing show_box"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Error box with normal text"
show_box error "Error" "This is an error message"
test_result "show_box: error type" "PASS"

echo ""
echo "Test: Warning box with CJK"
show_box warning "警告" "これは警告メッセージです - This is a warning"
test_result "show_box: CJK in warning" "PASS"

echo ""
echo "Test: Info box with emoji"
show_box info "🚀 Info" "Deployment in progress 🎯"
test_result "show_box: emoji in info" "PASS"

echo ""
echo "Test: Success box with very long message"
show_box success "Success" "This is a very long success message that should wrap properly across multiple lines without breaking the box borders or causing alignment issues"
test_result "show_box: long message wrapping" "PASS"

echo ""
echo "Test: Box with commands"
show_box error "Error" "Something failed" "command1" "command2" "command3"
test_result "show_box: with commands" "PASS"

echo ""
echo "Test: Box with empty message"
show_box info "Title" ""
test_result "show_box: empty message" "PASS"

echo ""
echo "Test: Box with CJK commands"
show_box error "错误" "失败" "命令1" "命令2"
test_result "show_box: CJK commands" "PASS"

# ==============================================================================
# 3. SHOW_SECTION_HEADER
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Testing show_section_header"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Normal section header"
show_section_header "Deploy Application" 1 3 "Building Docker image"
test_result "show_section_header: normal" "PASS"

echo ""
echo "Test: Section header with emoji"
show_section_header "🚀 Deployment" 2 5 "Pushing to production 🎯"
test_result "show_section_header: with emoji" "PASS"

echo ""
echo "Test: Section header with CJK"
show_section_header "部署应用 Deploy" 1 2 "構築中 Building"
test_result "show_section_header: with CJK" "PASS"

echo ""
echo "Test: Very long section header"
show_section_header "This is a very long section header that might cause issues" 99 100 "And a very long subtitle as well"
test_result "show_section_header: long text" "PASS"

# ==============================================================================
# 4. SHOW_SUMMARY
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Testing show_summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Normal summary"
show_summary "Summary" "Item 1" "Item 2" "Item 3"
test_result "show_summary: normal" "PASS"

echo ""
echo "Test: Summary with emoji"
show_summary "🎯 Summary" "✓ Item 1" "✗ Item 2" "⚠ Item 3"
test_result "show_summary: with emoji" "PASS"

echo ""
echo "Test: Summary with CJK"
show_summary "总结 Summary" "项目1: 完成" "項目2: 진행중" "アイテム3: OK"
test_result "show_summary: with CJK" "PASS"

echo ""
echo "Test: Summary with very long items"
show_summary "Summary" "This is a very long summary item that should wrap properly" "Another long item here"
test_result "show_summary: long items" "PASS"

echo ""
echo "Test: Summary with no items"
show_summary "Empty Summary"
test_result "show_summary: no items" "PASS"

# ==============================================================================
# 5. SHOW_CHECKLIST
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Testing show_checklist"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Normal checklist"
normal_checklist=(
    "done|Task 1|Completed"
    "active|Task 2|In progress"
    "pending|Task 3|Waiting"
    "skip|Task 4|Skipped"
)
show_checklist normal_checklist
test_result "show_checklist: normal statuses" "PASS"

echo ""
echo "Test: Checklist with emoji"
emoji_checklist=(
    "done|🚀 Deploy|Success"
    "active|🔨 Build|Working"
    "pending|📦 Package|Waiting"
)
show_checklist emoji_checklist
test_result "show_checklist: with emoji" "PASS"

echo ""
echo "Test: Checklist with CJK"
cjk_checklist=(
    "done|构建|完成"
    "active|部署|进行中"
    "pending|测试|等待中"
)
show_checklist cjk_checklist
test_result "show_checklist: with CJK" "PASS"

echo ""
echo "Test: Checklist with very long labels"
long_checklist=(
    "done|This is a very long task label that might cause issues|Details here"
    "active|Another extremely long task label|More details"
)
show_checklist long_checklist
test_result "show_checklist: long labels" "PASS"

# ==============================================================================
# 6. SHOW_PROGRESS_BAR
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Testing show_progress_bar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Progress 0%"
show_progress_bar 0 100 "Loading"
test_result "show_progress_bar: 0%" "PASS"

echo ""
echo "Test: Progress 50%"
show_progress_bar 50 100 "Processing"
test_result "show_progress_bar: 50%" "PASS"

echo ""
echo "Test: Progress 100%"
show_progress_bar 100 100 "Complete"
test_result "show_progress_bar: 100%" "PASS"

echo ""
echo "Test: Progress with emoji label"
show_progress_bar 75 100 "🚀 Deploying"
test_result "show_progress_bar: emoji label" "PASS"

echo ""
echo "Test: Progress with CJK label"
show_progress_bar 30 100 "下载中 Downloading"
test_result "show_progress_bar: CJK label" "PASS"

# ==============================================================================
# 7. SIMPLE MESSAGES
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. Testing simple messages"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Messages with normal text"
show_success "Success message"
show_error "Error message"
show_warning "Warning message"
show_info "Info message"
test_result "messages: normal text" "PASS"

echo ""
echo "Test: Messages with emoji"
show_success "✓ Success with emoji"
show_error "✗ Error with emoji"
show_warning "⚠ Warning with emoji"
show_info "ℹ Info with emoji"
test_result "messages: with emoji" "PASS"

echo ""
echo "Test: Messages with CJK"
show_success "成功 Success"
show_error "错误 Error"
show_warning "警告 Warning"
show_info "信息 Info"
test_result "messages: with CJK" "PASS"

echo ""
echo "Test: Very long messages"
show_success "This is a very long success message that should display properly without breaking the terminal or causing any alignment issues"
test_result "messages: long text" "PASS"

# ==============================================================================
# 8. FORMATTING HELPERS
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. Testing formatting helpers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: print_kv with normal text"
print_kv "Key" "Value"
test_result "print_kv: normal" "PASS"

echo ""
echo "Test: print_kv with emoji"
print_kv "🔑 Key" "📝 Value"
test_result "print_kv: emoji" "PASS"

echo ""
echo "Test: print_kv with CJK"
print_kv "键 Key" "值 Value"
test_result "print_kv: CJK" "PASS"

echo ""
echo "Test: print_kv with long values"
print_kv "Key" "This is a very long value that might cause alignment issues"
test_result "print_kv: long value" "PASS"

echo ""
echo "Test: print_command"
print_command "normal command"
print_command "🚀 command with emoji"
print_command "命令 command with CJK"
test_result "print_command: various inputs" "PASS"

echo ""
echo "Test: print_item"
print_item "Normal item"
print_item "🎯 Item with emoji"
print_item "项目 Item with CJK"
test_result "print_item: various inputs" "PASS"

echo ""
echo "Test: print_step"
print_step 1 "Normal step"
print_step 2 "🚀 Step with emoji"
print_step 3 "步骤 Step with CJK"
test_result "print_step: various inputs" "PASS"

# ==============================================================================
# 9. EDGE CASES & STRESS TESTS
# ==============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9. Edge Cases & Stress Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Test: Mixed emoji and CJK"
show_box info "🐦 Title 标题" "Hello 你好 こんにちは 안녕 🚀 World"
test_result "edge: mixed emoji and CJK" "PASS"

echo ""
echo "Test: Full-width characters"
show_box info "ＦｕｌｌＷｉｄｔｈ" "ＡＢＣＤ１２３４"
test_result "edge: full-width characters" "PASS"

echo ""
echo "Test: Multiple emojis in sequence"
show_box info "🐦🚀🎯💡🔍" "Multiple emojis: 🐦🚀🎯💡🔍"
test_result "edge: multiple emojis" "PASS"

echo ""
echo "Test: Empty strings everywhere"
show_box info "" ""
test_result "edge: all empty strings" "PASS"

echo ""
echo "Test: Very long unbroken word"
show_box info "Title" "Supercalifragilisticexpialidociousthisisaverylongwordthatcannotbebrokenbyfold"
test_result "edge: unbreakable long word" "PASS"

echo ""
echo "Test: Newlines in input (should be sanitized)"
show_box info "Title
with
newlines" "Message
with
newlines"
test_result "edge: newlines in input" "PASS"

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo "Passed:       $PASSED_TESTS"
echo "Failed:       $FAILED_TESTS"
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "✓ ALL TESTS PASSED!"
    exit 0
else
    echo "✗ SOME TESTS FAILED"
    exit 1
fi

