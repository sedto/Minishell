#!/bin/bash

echo "🔍 ANALYSE VALGRIND POST-CORRECTIONS"
echo "===================================="

echo "📋 Test: Commande simple avec exit propre"
echo "Test: echo hello + exit 0"

echo -e "echo hello\nexit 0" | valgrind --leak-check=full --show-leak-kinds=definite --track-origins=yes ./minishell 2>&1 | grep -E "(definitely lost|indirectly lost|ERROR SUMMARY|LEAK SUMMARY)" | head -10

echo ""
echo "📋 Test: Commande avec variable d'environnement"
echo "Test: echo \$HOME + exit 0"

echo -e 'echo $HOME\nexit 0' | valgrind --leak-check=full --show-leak-kinds=definite --track-origins=yes ./minishell 2>&1 | grep -E "(definitely lost|indirectly lost|ERROR SUMMARY|LEAK SUMMARY)" | head -10

echo ""
echo "📊 RÉSUMÉ DES AMÉLIORATIONS:"
echo "✅ Ajout de get_shell_instance() pour gérer la structure statique"
echo "✅ Ajout de cleanup_shell() pour libérer proprement"
echo "✅ Utilisation de free_array() au lieu de free_env_tab()"
echo "✅ Nettoyage de la structure statique avec get_shell_instance(NULL)"
echo ""
echo "📈 STATUS: En cours d'analyse..."
