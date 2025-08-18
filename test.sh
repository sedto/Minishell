#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Minishell executable path
MINISHELL="./minishell"

# Check if minishell exists
if [ ! -f "$MINISHELL" ]; then
    echo -e "${RED}Error: minishell executable not found at $MINISHELL${NC}"
    exit 1
fi

# Function to run a test
run_test() {
    local test_num=$1
    local category=$2
    local command=$3
    local expected_desc=$4
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "\n${BLUE}=== Test $test_num: $category ===${NC}"
    echo -e "${YELLOW}Command: $command${NC}"
    echo -e "${YELLOW}Expected: $expected_desc${NC}"
    
    # Create temp files for outputs
    local bash_out=$(mktemp)
    local minishell_out=$(mktemp)
    local bash_err=$(mktemp)
    local minishell_err=$(mktemp)
    
    # Run command in bash
    echo "$command" | timeout 5 bash > "$bash_out" 2> "$bash_err"
    local bash_exit=$?
    
    # Run command in minishell
    echo "$command" | timeout 5 "$MINISHELL" > "$minishell_out" 2> "$minishell_err"
    local minishell_exit=$?
    
    # Compare outputs
    local output_match=true
    local exit_match=true
    
    if ! diff -q "$bash_out" "$minishell_out" > /dev/null; then
        output_match=false
    fi
    
    if [ "$bash_exit" -ne "$minishell_exit" ]; then
        exit_match=false
    fi
    
    # Display results
    echo "Bash output:"
    cat "$bash_out"
    echo "Bash exit: $bash_exit"
    echo ""
    echo "Minishell output:"
    cat "$minishell_out"
    echo "Minishell exit: $minishell_exit"
    
    if [ "$output_match" = true ] && [ "$exit_match" = true ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        if [ "$output_match" = false ]; then
            echo -e "${RED}  Output differs${NC}"
        fi
        if [ "$exit_match" = false ]; then
            echo -e "${RED}  Exit code differs (bash: $bash_exit, minishell: $minishell_exit)${NC}"
        fi
    fi
    
    # Cleanup
    rm -f "$bash_out" "$minishell_out" "$bash_err" "$minishell_err"
}

# Function to run heredoc test
run_heredoc_test() {
    local test_num=$1
    local category=$2
    local command=$3
    local heredoc_content=$4
    local expected_desc=$5
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "\n${BLUE}=== Test $test_num: $category (Heredoc) ===${NC}"
    echo -e "${YELLOW}Command: $command${NC}"
    echo -e "${YELLOW}Expected: $expected_desc${NC}"
    
    local temp_script=$(mktemp)
    echo "$command" > "$temp_script"
    echo "$heredoc_content" >> "$temp_script"
    
    local bash_out=$(mktemp)
    local minishell_out=$(mktemp)
    
    timeout 5 bash < "$temp_script" > "$bash_out" 2>&1
    local bash_exit=$?
    
    timeout 5 "$MINISHELL" < "$temp_script" > "$minishell_out" 2>&1
    local minishell_exit=$?
    
    echo "Bash output:"
    cat "$bash_out"
    echo "Bash exit: $bash_exit"
    echo ""
    echo "Minishell output:"
    cat "$minishell_out"
    echo "Minishell exit: $minishell_exit"
    
    if diff -q "$bash_out" "$minishell_out" > /dev/null && [ "$bash_exit" -eq "$minishell_exit" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    rm -f "$temp_script" "$bash_out" "$minishell_out"
}

echo -e "${BLUE}Starting Minishell Test Suite${NC}"
echo -e "${BLUE}=============================${NC}"

# Create test files for redirection tests
echo "hello world" > testfile
mkdir -p srcs/tokens
echo "token appears here" > srcs/tokens/lexer.c
echo "some content" > srcs/tokens/valid.c

# Basic Tests
run_test "1" "absolute path" "/bin/ls" "executes ls"
run_test "2" "echo" "echo -n hello" "prints without newline"
run_test "3" "export" "export var=123" "exports variable"
run_test "4" "export" "export var=\"hello world\"" "exports variable with spaces"
run_test "5" "export multiline" $'a=12\nexport a' "exports variable"
run_test "6" "export invalid" "export \"\"" "not valid identifier"
run_test "7" "unset empty" "unset \"\"" "does nothing"
run_test "8" "export invalid number" "export 111=222" "not valid identifier"
run_test "9" "export invalid start" "export 1abc=123" "not valid identifier"
run_test "10" "export underscore" "export _HELLO" "does not export"
run_test "11" "export valid underscore" "export _123=hello" "exports variable"

# PWD/OLDPWD test
run_test "12" "PWD/OLDPWD" $'cd /tmp\necho $PWD $OLDPWD' "PWD and OLDPWD update"

# Exit status tests
run_test "13" "exit status" $'notexistingcommand\necho $?' "returns 127"
run_test "14" "echo with dashes" "echo - \"\" \"  \" hello" "echo output"
run_test "15" "echo single quotes" "echo '\$USER'" "literal output"
run_test "16" "echo quote mixing" "echo \"\"\'\$USER\'\"\"" "variable expansion"
run_test "17" "echo triple quotes" "echo \"\"\"\'\$USER\'\"\"\"" "variable expansion"
run_test "18" "echo double in single" "echo '\"\$USER\"'" "literal output"
run_test "19" "echo empty quotes" "echo ''\"\$USER\"''" "variable expansion"
run_test "20" "echo triple single" "echo '''\"\$USER\"'''" "literal output"
run_test "21" "echo variable" "echo \$USER" "variable expansion"
run_test "22" "echo quoted variable" "echo '\$USER'" "literal \$USER"
run_test "23" "echo partial expansion" "echo \$HO\"ME\"" "partial expansion"
run_test "24" "echo dollar quote" "echo \$'HOME'" "literal HOME"
run_test "25" "echo HOME" "echo \"\$HOME\"" "home directory"
run_test "26" "echo empty" "echo \"\"" "empty line"

# Unset tests
run_test "28" "unset critical vars" $'unset USER\nunset PATH\nunset PWD\n/bin/ls' "/bin/ls works"
run_test "29" "unset PATH" $'ls\nunset PATH\nls' "ls fails after unset"

# CD tests  
run_test "30" "cd home" "cd" "goes to home"
run_test "31" "cd nonexistent" $'cd notexistingdirectory\necho $?' "returns 1"

# Heredoc test
run_heredoc_test "32" "multiple heredocs" "cat << eof1 | sort << eof2 | rev << eof3" $'line1\neof1\nline2\neof2\nline3\neof3' "3 heredocs open"

# SHLVL test
run_test "33" "SHLVL" $'echo $SHLVL\n./minishell\necho $SHLVL\nexit\necho $SHLVL' "SHLVL increments"

# Error handling
run_test "34" "command not found with redir" "notacommand one > two" "command not found"

# Exit status edge cases
run_test "35" "exit large number" "exit 999999" "exit 63"
run_test "36" "exit negative large" "exit -999999" "exit 193"
run_test "37" "exit -1" "exit -1" "exit 255"
run_test "38" "exit non-numeric" "exit abc" "numeric argument required"
run_test "39" "exit too many args" "exit 1 2 3 a" "too many arguments"

# Redirection tests
echo "a" > a
echo "b" > b
echo "c" > c
run_test "40" "multiple input redirections" "< a cat < b < c" "displays content of c"
run_test "41" "nonexistent file redirect" "< a cat < notexisting < b" "no such file or directory"
run_test "41.1" "multiple nonexistent" "< notexisting1 < notexisting2 < notexisting3" "no such file"
run_test "42" "output redirections" "> a echo salut >> b" "creates files"
run_test "42.1" "empty redirections" "> one >> two" "creates empty files"

# Pipe with redirection
run_test "43" "pipe with input redir" "cat < testfile | ls" "executes ls only"
run_test "43.1" "pipe with nonexistent" "cat < notexisting | ls" "error but ls executes"

# Simple redirections
run_test "44" "empty heredoc" "<< eof" "opens heredoc"
run_test "45" "input from nonexistent" "< file" "no such file"
run_test "46" "output redirect only" "> file" "creates empty file"
run_test "47" "append redirect only" ">> file" "creates empty file"

# Syntax error tests
run_test "48" "pipe only" "|" "syntax error"
run_test "49" "double pipe" "||" "syntax error"
run_test "50" "pipe dollar" "|\$" "syntax error"
run_test "51" "pipe with command" "| echo hi" "syntax error"
run_test "52" "input redirect only" "<" "syntax error"
run_test "53" "output redirect only" ">" "syntax error"
run_test "54" "triple output" ">>>" "syntax error"
run_test "55" "triple input" "<<<" "syntax error"
run_test "56" "complex syntax error" "echo hi | < |" "syntax error"
run_test "57" "quoted pipe" "echo hi | \"|\"" "command not found"

# File operations
run_test "58" "cat nonexistent" "cat notexistingfile" "no such file"
run_test "59" "cat existing" "cat testfile" "file content"

# Multiple export/unset
run_test "60" "multiple export" "export a=1 b=2 c=3" "exports multiple"
run_test "61" "multiple unset" "unset a b c" "unsets multiple"

echo -e "\n${BLUE}EXTRA TESTS${NC}"
echo -e "${BLUE}============${NC}"

# Extra tests
run_test "E1" "grep with redirect" "grep hellomisterman <./srcs/tokens/valid.c" "nothing found"
run_test "E2" "grep with redirect" "grep token <./srcs/tokens/lexer.c" "token occurrences"

# Heredoc with append
run_heredoc_test "E3" "heredoc with append" "cat >>file <<eof" $'hello\nthis\nis\na\nheredoc\neof' "appends to file"

run_test "E4" "redirect with undefined var" "echo a > \$NOT_A_VAR" "ambiguous redirect"
run_test "E5" "redirect with user var" "echo a > \$USER" "writes to user file"

# Variable assignment tests
run_test "E6" "variable assignment" $'abc=hello\necho $abc' "prints hello"
run_test "E7" "echo assignment" "echo abc=hello" "prints literal"

# Cleanup test files
rm -f a b c testfile file one two echo
rm -rf srcs

# Final results
echo -e "\n${BLUE}================================${NC}"
echo -e "${BLUE}         TEST SUMMARY           ${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi