#!/bin/bash

echo "🔍 DIAGNOSTIC APRÈS CORRECTIONS BUFFER"
echo "======================================"
echo

# Test spécifique des cas de variables
echo "Test 1: Variable inexistante simple"
echo 'echo $INEXISTANT' | ./minishell -c

echo
echo "Test 2: Variables multiples"
echo 'echo $A$B$C' | ./minishell -c

echo
echo "Test 3: Variable dans quotes"
echo 'echo "$TEST"' | ./minishell -c

echo
echo "Test 4: Variable spéciale ?"
echo 'echo $?' | ./minishell -c

echo
echo "Test 5: Mélange quotes et variables"
echo "echo 'test' \$VAR \"other\"" | ./minishell -c

echo "✅ Tests diagnostiques terminés"
