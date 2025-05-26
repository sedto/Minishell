#!/bin/bash

echo "=== Test du nettoyage de chaînes ==="
echo ""

# Test 1: Espaces multiples
echo "Test 1: Espaces multiples"
echo "  hello    world  " | ./minishell

echo ""

# Test 2: Guillemets simples
echo "Test 2: Guillemets simples"
echo "'hello  world'" | ./minishell

echo ""

# Test 3: Guillemets doubles
echo "Test 3: Guillemets doubles"
echo '"hello  world"' | ./minishell

echo ""

# Test 4: Mélange
echo "Test 4: Mélange guillemets et espaces"
echo "hello   'test   avec   espaces'   world" | ./minishell

echo ""

# Test 5: Guillemets collés
echo "Test 5: Guillemets collés (echo\"hello\"world)"
echo 'echo"hello"world' | ./minishell

echo ""

# Test 6: Guillemets simples collés
echo "Test 6: Guillemets simples collés (ls'test'file)"
echo "ls'test'file" | ./minishell

echo ""

# Test 7: Chaîne déjà espacée
echo "Test 7: Chaîne déjà espacée"
echo 'echo "already spaced"' | ./minishell

echo ""

# Test 8: Redirection collée
echo "Test 8: Redirection collée (cat<file.txt)"
echo "cat<file.txt" | ./minishell

echo ""

# Test 9: Espaces multiples dans guillemets
echo "Test 9: Espaces multiples dans guillemets"
echo 'echo    "multiple   spaces"' | ./minishell
