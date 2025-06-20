#!/bin/bash

# Test ultra-rapide en 30 secondes
echo "🚀 TEST EXPRESS MINISHELL (30 secondes)"
echo "========================================"

# Test 1: Compilation (5s)
echo -n "1. Compilation... "
if make clean > /dev/null 2>&1 && make > /dev/null 2>&1 && [ -f "./minishell" ]; then
    echo "✅"
else
    echo "❌ ÉCHEC"
    exit 1
fi

# Test 2: Pas de crash (5s)
echo -n "2. Pas de crash... "
if echo -e "echo hello\nexit" | timeout 3s ./minishell > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌ CRASH"
    exit 1
fi

# Test 3: Variables (5s)
echo -n "3. Variables... "
if echo -e "echo \$USER\nexit" | timeout 3s ./minishell > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌ ÉCHEC"
fi

# Test 4: Pipes (5s)
echo -n "4. Pipes... "
if echo -e "echo hello | cat\nexit" | timeout 3s ./minishell > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌ ÉCHEC"
fi

# Test 5: Redirections (5s)
echo -n "5. Redirections... "
if echo -e "echo test > /tmp/minishell_test.txt\nexit" | timeout 3s ./minishell > /dev/null 2>&1; then
    echo "✅"
    rm -f /tmp/minishell_test.txt
else
    echo "❌ ÉCHEC"
fi

echo ""
echo "🎯 TEST EXPRESS TERMINÉ"
echo "📋 Pour tests complets: ./test_all.sh"
