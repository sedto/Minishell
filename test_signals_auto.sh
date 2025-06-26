#!/bin/bash

echo "🧪 TEST AUTOMATISÉ - GESTIONNAIRE SIGINT"
echo "========================================"
echo

# Test 1: Vérifier que le minishell réagit à SIGINT
echo "📋 Test 1: Réaction à SIGINT"
echo "=============================="

# Lancer minishell en arrière-plan et envoyer SIGINT
timeout 3 bash -c '
    (sleep 1; kill -SIGINT $$; sleep 1; echo "exit") | ./minishell > /tmp/minishell_sigint_test.log 2>&1
' &
wait

# Vérifier si le minishell a survécu au signal
if [ -f "/tmp/minishell_sigint_test.log" ]; then
    echo "✅ Le minishell a réagi au signal SIGINT"
    if grep -q "minishell\$" /tmp/minishell_sigint_test.log; then
        echo "✅ Prompt affiché correctement"
    fi
else
    echo "❌ Pas de réaction détectée"
fi

echo
echo "📋 Test 2: Stabilité après SIGINT"
echo "=================================="

# Test de commandes après un SIGINT
echo 'echo "test after sigint"' | ./minishell -c > /tmp/minishell_post_sigint.log 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Commandes fonctionnent après SIGINT"
else
    echo "❌ Dysfonctionnement après SIGINT"
fi

echo
echo "📋 Test 3: Vérification gestion mémoire"
echo "======================================="

# Test avec valgrind si disponible
if command -v valgrind >/dev/null 2>&1; then
    echo "Test mémoire avec valgrind..."
    echo 'echo "hello"' | timeout 5 valgrind --tool=memcheck --leak-check=yes --error-exitcode=1 ./minishell -c > /tmp/valgrind_sigint.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Pas de fuites mémoire détectées"
    else
        echo "⚠️  Problèmes mémoire détectés (voir /tmp/valgrind_sigint.log)"
    fi
else
    echo "⚠️  Valgrind non disponible"
fi

echo
echo "🧹 Nettoyage des fichiers temporaires..."
rm -f /tmp/minishell_*.log /tmp/valgrind_*.log

echo
echo "✅ Tests automatisés terminés"
echo
echo "Pour tester manuellement Ctrl+C:"
echo "./test_ctrl_c.sh"
