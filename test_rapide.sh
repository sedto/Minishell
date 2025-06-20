#!/bin/bash

# Test rapide et direct
echo "🧪 Tests manuels directs..."

echo "Test 1: Commande simple"
echo -e "echo hello\nexit" | ./minishell

echo "Test 2: Variable"
echo -e "echo \$USER\nexit" | ./minishell

echo "Test 3: Quotes"
echo -e "echo 'hello world'\nexit" | ./minishell

echo "Test 4: Pipe"
echo -e "echo hello | cat\nexit" | ./minishell

echo "Test 5: Erreur syntaxe (pipe fin)"
echo -e "echo hello |\nexit" | ./minishell

echo "Test 6: Erreur syntaxe (redirection)"
echo -e "echo hello >\nexit" | ./minishell

echo "Tous les tests terminés!"
