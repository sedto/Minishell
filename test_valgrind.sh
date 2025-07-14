#!/bin/bash

# Script pour tester les fuites mémoire avec Valgrind
# Usage: ./test_valgrind.sh

echo "🧪 Tests Valgrind pour Minishell"
echo "================================"

# Options Valgrind recommandées pour les shells
VALGRIND_OPTS="--leak-check=full --show-leak-kinds=all --track-origins=yes --suppressions=.valgrind.supp"

# Créer un fichier de suppression pour readline (connu pour avoir des "faux positifs")
cat > .valgrind.supp << 'EOF'
{
   readline_leak_1
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:malloc
   ...
   fun:rl_*
}

{
   readline_leak_2
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:calloc
   ...
   fun:rl_*
}

{
   readline_leak_3
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:realloc
   ...
   fun:rl_*
}

{
   readline_history
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:malloc
   ...
   fun:add_history
}
EOF

echo "📋 Fichier de suppression créé (.valgrind.supp)"
echo ""

# Test 1: Commande simple
echo "🔍 Test 1: Commande simple (echo hello)"
echo "echo hello" | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Test 2: Pipeline simple
echo "🔍 Test 2: Pipeline simple (echo hello | cat)"
echo "echo hello | cat" | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Test 3: Redirection
echo "🔍 Test 3: Redirection (echo hello > /tmp/test_valgrind)"
echo "echo hello > /tmp/test_valgrind" | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Test 4: Variables d'environnement
echo "🔍 Test 4: Variables d'environnement (echo \$HOME)"
echo 'echo $HOME' | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Test 5: Builtin cd
echo "🔍 Test 5: Builtin cd (cd /tmp)"
echo "cd /tmp" | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Test 6: Exit
echo "🔍 Test 6: Exit normal (exit 0)"
echo "exit 0" | valgrind $VALGRIND_OPTS ./minishell 2>&1 | grep -E "(ERROR SUMMARY|definitely lost|indirectly lost|possibly lost)"
echo ""

# Nettoyage
rm -f /tmp/test_valgrind .valgrind.supp

echo "✅ Tests terminés"
echo ""
echo "💡 Pour un test plus détaillé, utilisez:"
echo "   valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./minishell"
echo ""
echo "📝 Légende des fuites:"
echo "   - definitely lost: Fuites confirmées à corriger"
echo "   - indirectly lost: Fuites indirectes (souvent liées aux definitely lost)"
echo "   - possibly lost: Fuites possibles (à investiguer)"
echo "   - still reachable: Mémoire non libérée mais encore accessible (souvent OK)"
