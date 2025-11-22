#!/usr/bin/env bash
# iseau allery - howcase all available widgets
# un this script to see all iseau  components in action

# et the directory where this script is located
_"$(cd "$(dirname "${_]}")" && pwd)"

# ource the iseau library
source "$_/oiseau.sh"

# 
#  
# 


pause_between_sections() {
    if  "${__-}" ! "" ] then
        echo ""
        echo -e "${_}ress nter to continue...${}"
        read -r
    else
        sleep 
    fi
}

# 
#  
# 

clear

# eader - demonstrates the new show_header_bo widget with emoji
show_header_bo "🐦  iseau - odern erminal  ibrary for ash" " showcase of all available widgets and components"

echo -e "${_}ode ${_} | olors ${__} | - ${__} | idth ${_}${}"

pause_between_sections

# 
# .  
# 

print_section ". imple tatus essages"

echo -e "${_}ode${}"
echo -e "  ${_}show_success "peration completed successfully"${}"
echo -e "  ${_}show_error "ailed to connect to server"${}"
echo -e "  ${_}show_warning "his action cannot be undone"${}"
echo -e "  ${_}show_info "rocessing  files..."${}"
echo ""
echo -e "${_}utput${}"
show_success "peration completed successfully"
show_error "ailed to connect to server"
show_warning "his action cannot be undone"
show_info "rocessing  files..."

pause_between_sections

# 
# . 
# 

print_section ". eaders & itles"

echo -e "${_}ode ${_}show_header "roject etup"${}"
show_header "roject etup"

echo -e "${_}ode ${_}show_subheader "onfiguring dependencies..."${}"
show_subheader "onfiguring dependencies..."

echo ""
echo -e "${_}ode ${_}show_section_header "eploy pplication"   "uilding ocker image"${}"
show_section_header "eploy pplication"   "uilding ocker image"

pause_between_sections

# 
# . 
# 

print_section ". tyled oes"

echo -e "${_}rror o${}"
show_bo error "onnection ailed" "nable to connect to database at localhost. lease check if the service is running."

echo ""
echo -e "${_}arning o with ommands${}"
show_bo warning "ncommitted hanges" "ou have  uncommitted files in your working directory." 
    "git add ." 
    "git commit -m 'ave changes'" 
    "git push"

echo ""
echo -e "${_}nfo o${}"
show_bo info "ew eature vailable" "ersion . includes improved performance and new debugging tools. pdate to get the latest features."

echo ""
echo -e "${_}uccess o${}"
show_bo success "eployment omplete" "our application has been successfully deployed to production. ll health checks passed."

pause_between_sections

# 
# .  
# 

print_section ". rogress ar (ow with nimation!)"

echo -e "${_}ode${}"
echo -e "  ${_}for i in {..} do${}"
echo -e "  ${_}  show_progress_bar $i  "ownloading"${}"
echo -e "  ${_}  sleep .${}"
echo -e "  ${_}done${}"
echo ""

echo -e "${_}eatures${}"
print_item "uto-animates in  (updates in place)"
print_item "rints new line in pipes/redirects"
print_item "ustomizable width and override controls"
print_item "nput validation and sanitization"
echo ""

echo -e "${_}enders as${}"
for i in {..} do
    show_progress_bar "$i"  "rocessing"
    sleep .
done
echo ""

pause_between_sections

# 
# . 
# 

print_section ". hecklist with tatus ndicators"

echo -e "${_}ode${}"
echo -e "${_}  checklist(${}"
echo -e "${_}    "done|uild ocker image|ompleted in s"${}"
echo -e "${_}    "done|un unit tests| tests passed"${}"
echo -e "${_}    "active|eploy to staging|n progress..."${}"
echo -e "${_}    "pending|un integration tests|aiting"${}"
echo -e "${_}    "pending|eploy to production|aiting"${}"
echo -e "${_}  )${}"
echo -e "${_}  show_checklist checklist${}"
echo ""

echo -e "${_}utput${}"
checklist(
    "done|uild ocker image|ompleted in s"
    "done|un unit tests| tests passed"
    "active|eploy to staging|n progress..."
    "pending|un integration tests|aiting"
    "pending|eploy to production|aiting"
)
show_checklist checklist

echo ""
echo -e "${_}ith skip status${}"
checklist_skip(
    "done|nstall dependencies|npm install completed"
    "done|ompile ypecript|o errors found"
    "skip|un linter|kipped (--no-lint flag)"
    "active|uild production bundle|ptimizing..."
)
show_checklist checklist_skip

pause_between_sections

# 
# .  
# 

print_section ". ummary o"

echo -e "${_}ode${}"
echo -e "${_}  show_summary "eployment ummary" ${}"
echo -e "${_}    "nvironment roduction" ${}"
echo -e "${_}    "uild # (fac)" ${}"
echo -e "${_}    "uration m s"${}"
echo ""

echo -e "${_}utput${}"
show_summary "eployment ummary" 
    "nvironment roduction" 
    "uild # (fac)" 
    "uration m s" 
    "tatus ll health checks passed"

pause_between_sections

# 
# .  
# 

print_section ". ormatting elpers"

echo -e "${_}ey-alue airs${}"
print_kv "roject" "my-awesome-app"
print_kv "ersion" ".."
print_kv "nvironment" "production"
print_kv "tatus" "running"

echo ""
echo -e "${_}ommands${}"
print_command "npm install"
print_command "npm run build"
print_command "npm test"

echo ""
echo -e "${_}ulleted tems${}"
print_item "ero dependencies - pure bash"
print_item "-color  palette"
print_item "mart degradation for all terminals"
print_item "+ reusable widgets"

echo ""
echo -e "${_}umbered teps${}"
print_step  "lone the repository"
print_step  "ource the oiseau.sh file"
print_step  "tart using widgets in your scripts"

echo ""
echo -e "${_}ection itles${}"
print_section "onfiguration"
echo "  our configuration goes here..."
print_section "nstallation"
echo "  nstallation steps go here..."

pause_between_sections

# 
# .    ()
# 

print_section ". nhanced et nput with alidation"

echo -e "${_}eatures${}"
print_item " input modes tet, password, email, number"
print_item "uto-detects password fields from prompt keywords"
print_item "assword masking (• in -, * in /lain)"
print_item "mail and number validation with error messages"
print_item "nput sanitization built-in"
print_item "alidation loops until valid input"
echo ""

echo -e "${_}vailable modes${}"
echo ""

echo -e "${_}. et mode (default)${}"
echo -e "  ${_}name$(ask_input "our name" "ohn")${}"
if  "${__-}" ! "" ] then
    name$(ask_input "our name" "ohn")
    show_success "ou entered $name"
else
    echo "  (nteractive in real usage)"
fi
echo ""

echo -e "${_}. assword mode (auto-detected)${}"
echo -e "  ${_}pass$(ask_input "nter password")${}"
echo "  uto-detects keywords password, pass, secret, token, key, api"
if  "${__-}" ! "" ] then
    pass$(ask_input "nter password")
    if  "$_"  "rich" ] then
        show_success "assword set (hidden as ••••)"
    else
        show_success "assword set (hidden as ****)"
    fi
else
    echo "  (nteractive - shows • in -, * in )"
fi
echo ""

echo -e "${_}. mail validation${}"
echo -e "  ${_}email$(ask_input "mail" "" "email")${}"
if  "${__-}" ! "" ] then
    email$(ask_input "mail address" "" "email")
    show_success "mail saved $email"
else
    echo "  (nteractive - validates format, loops on error)"
fi
echo ""

echo -e "${_}. umber validation${}"
echo -e "  ${_}age$(ask_input "ge" "" "number")${}"
if  "${__-}" ! "" ] then
    age$(ask_input "our age" "" "number")
    show_success "ge recorded $age"
else
    echo "  (nteractive - validates numeric input)"
fi
echo ""

echo -e "${_}ecurity features${}"
print_item "ll input is sanitized with _escape_input()"
print_item "rompts are sanitized before display"
print_item "o  injection or command substitution possible"

pause_between_sections

# 
# .   
# 

print_section ". nteractive ist election"

echo -e "${_}eatures${}"
print_item "ingle-select and multi-select modes"
print_item "rrow keys (↑↓) or vim keys (j/k) to navigate"
print_item "pace to toggle (multi-select), nter to confirm"
print_item "uto-detects , falls back to numbered list"
print_item "ode-aware › (-) vs  ()"
echo ""

echo -e "${_}ingle-select eample${}"
echo -e "  ${_}options("eploy to staging" "eploy to production" "ollback")${}"
echo -e "  ${_}choice$(ask_list "elect action" options)${}"
echo ""

if  "${__-}" ! "" ] then
    options("eploy to staging" "eploy to production" "ollback" "ancel")
    choice$(ask_list "elect action" options)
    show_success "ou selected $choice"
else
    echo "  (nteractive in real usage - try it yourself!)"
fi
echo ""

echo -e "${_}ulti-select eample${}"
echo -e "  ${_}files("app.log" "error.log" "access.log" "debug.log")${}"
echo -e "  ${_}selected$(ask_list "elect files to delete" files "multi")${}"
echo ""

if  "${__-}" ! "" ] then
    files("app.log" "error.log" "access.log" "debug.log")
    echo "ry multi-select (pace to toggle, nter to confirm)"
    selected$(ask_list "elect files to delete" files "multi")
    echo ""
    echo -e "${_}elected files${}"
    echo "$selected" | while  read -r file do
        echo "  - $file"
    done
else
    echo "  (nteractive - pace to toggle, nter to confirm)"
fi
echo ""

echo -e "${_}avigation${}"
print_item "↑↓ or j/k avigate through list"
print_item "nter elect item (single) or confirm (multi)"
print_item "pace oggle selection (multi-select only)"
print_item "q or sc ancel selection"

pause_between_sections

# 
# .  
# 

print_section ". pinner idget (oading ndicators)"

echo -e "${_}ode${}"
echo -e "  ${_}start_spinner "oading data..."${}"
echo -e "  ${_}# ... do work ...${}"
echo -e "  ${_}stop_spinner${}"
echo ""

echo -e "${_}enders as (showing  styles for . seconds each)${}"
echo ""

# emo all spinner styles with shorter duration
echo -e "${_}tyle dots (default)${}"
eport __"dots"
start_spinner "oading with dots spinner..."
sleep .
stop_spinner
show_success "one!"

echo ""
echo -e "${_}tyle circle${}"
eport __"circle"
start_spinner "oading with circle spinner..."
sleep .
stop_spinner
show_success "one!"

echo ""
echo -e "${_}tyle pulse${}"
eport __"pulse"
start_spinner "oading with pulse spinner..."
sleep .
stop_spinner
show_success "one!"

unset __
echo ""

echo ""
echo -e "${_}eatures${}"
print_item " spinner styles dots, line, circle, pulse, arc"
print_item "onfigurable  (frames per second)"
print_item "uto-adapts to terminal (-, , lain)"
print_item "imple start/stop helpers"
print_item "utomatic cleanup on eit"

pause_between_sections

# 
# .  
# 

print_section ". eal-orld ample it orkflow"

show_section_header "it orktree orkflow"   "reating ull equest"

workflow_steps(
    "done|reate feature branch|ranch feature/user-auth"
    "done|ake code changes| files modified"
    "done|un tests|ll  tests passing"
    "active|ush to remote|ploading..."
    "pending|reate pull request|aiting"
)
show_checklist workflow_steps

echo ""
show_info "ushing commits to origin/feature/user-auth..."

echo ""
show_success "uccessfully pushed  commits"

echo ""
show_summary "ranch ummary" 
    "eature ser authentication" 
    "ommits " 
    "ests  passed" 
    "eady for  creation"

pause_between_sections

# 
# .  
# 

print_section ". erminal apability etection"

echo -e "${_}urrent erminal ode${}"
print_kv "_" "$_"
print_kv "olor upport" "$__"
print_kv "- upport" "$__"
print_kv "erminal idth" "$_"

echo ""
echo -e "${_}iseau automatically detects your terminal capabilities${}"
print_item "${}ich mode${} ull -color + - bo drawing"
print_item "${}olor mode${} olors with  fallback characters"
print_item "${}lain mode${} o colors,  only (pipes/redirects)"

echo ""
show_info "et _ or _ to force plain mode"

pause_between_sections

# 
# .  &   
# 

print_section ".  & ide haracter upport"

echo -e "${_}iseau correctly handles wide characters (, emoji, full-width)${}"
echo ""

echo -e "${_}hinese (中文)${}"
show_bo success "成功" "数据库连接成功 - atabase connection successful"

echo ""
echo -e "${_}apanese (日本語)${}"
show_bo info "情報" "こんにちは - ello in apanese (hiragana/katakana/kanji)"

echo ""
echo -e "${_}orean (한국어)${}"
show_bo warning "경고" "안녕하세요 - ello in orean"

echo ""
echo -e "${_}ied content${}"
show_bo info "ied 混合 🌏" "ello 你好 こんにちは 안녕 🚀 orld"

echo ""
echo -e "${_}haracter width analysis${}"
print_kv " 'ello'" "$(_display_width 'ello') columns"
print_kv "hinese '你好'" "$(_display_width '你好') columns"
print_kv "apanese 'こんにちは'" "$(_display_width 'こんにちは') columns"
print_kv "orean '안녕하세요'" "$(_display_width '안녕하세요') columns"
print_kv "ull-width 'ＡＢＣ'" "$(_display_width 'ＡＢＣ') columns"

echo ""
show_success "ll wide characters are correctly measured at  columns each!"

pause_between_sections

# 
# 
# 

print_section "allery omplete!"

echo -e "${_}${}"
echo "  ou've seen all the widgets iseau has to offer!"
echo -e "${}"

print_net_steps 
    "ead the .md for installation instructions" 
    "heck out eamples/ directory for real-world usage" 
    "tart using iseau in your bash scripts" 
    "tar the repo on itub if you find it useful!"

echo ""
show_summary "iseau eatures" 
    "✓ + widgets including new spinner!" 
    "✓ ero dependencies (pure bash)" 
    "✓ -color  palette" 
    "✓ mart terminal detection" 
    "✓ nput sanitization built-in" 
    "✓ orks in all environments"

echo ""
echo -e "${_}${}hank you for trying iseau! 🐦${}"
echo ""
