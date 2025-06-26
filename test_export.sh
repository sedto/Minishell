#!/bin/bash

echo "🧪 === TESTS BUILTIN EXPORT ==="

# Test 1: Export simple avec valeur
echo "📋 Test 1: Export avec valeur"
echo 'export TEST_VAR="hello world"' | ./minishell
echo "Status: $?"

echo ""

# Test 2: Export sans valeur
echo "📋 Test 2: Export sans valeur"
echo 'export TEST_VAR2' | ./minishell
echo "Status: $?"

echo ""

# Test 3: Export multiple
echo "📋 Test 3: Export multiple"
echo 'export VAR1="value1" VAR2="value2" VAR3="value3"' | ./minishell
echo "Status: $?"

echo ""

# Test 4: Export puis affichage
echo "📋 Test 4: Export puis affichage avec echo"
{
    echo 'export TEST_DISPLAY="visible"'
    echo 'echo $TEST_DISPLAY'
    echo 'exit'
} | ./minishell

echo ""

# Test 5: Lister les exports (export sans arguments)
echo "📋 Test 5: Liste des exports"
{
    echo 'export TEST_LIST="example"'
    echo 'export | head -5'
    echo 'exit'
} | ./minishell

echo ""

# Test 6: Export avec caractères spéciaux
echo "📋 Test 6: Export avec caractères spéciaux"
echo 'export SPECIAL="value with spaces and $symbols"' | ./minishell
echo "Status: $?"

echo ""
echo "✅ Tests export terminés"
