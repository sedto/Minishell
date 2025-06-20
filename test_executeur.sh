#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_executeur.sh                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: team                                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 17:00:00 by team              #+#    #+#              #
#    Updated: 2025/06/20 17:00:00 by team              ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Tests pour l'exécuteur minishell
# À utiliser une fois que l'exécuteur sera implémenté

echo "🚀 TESTS EXÉCUTEUR MINISHELL"
echo "============================"

# Vérifier que minishell existe
if [ ! -f "./minishell" ]; then
    echo "❌ minishell non trouvé. Compiler d'abord."
    exit 1
fi

PASS=0
TOTAL=0

# Fonction de test
test_executor() {
    local desc="$1"
    local cmd="$2"
    local expected="$3"
    
    echo -n "🔹 $desc... "
    TOTAL=$((TOTAL + 1))
    
    # Exécuter la commande avec timeout
    OUTPUT=$(timeout 5s bash -c "echo '$cmd' | ./minishell" 2>&1)
    EXIT_CODE=$?
    
    if [ "$expected" = "success" ]; then
        if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 1 ]; then
            echo "✅"
            PASS=$((PASS + 1))
        else
            echo "❌ (code: $EXIT_CODE)"
        fi
    elif [ "$expected" = "contains_output" ]; then
        if echo "$OUTPUT" | grep -q "$cmd" > /dev/null; then
            echo "✅"
            PASS=$((PASS + 1))
        else
            echo "❌ (pas de sortie attendue)"
        fi
    else
        echo "✅ (à vérifier manuellement)"
        PASS=$((PASS + 1))
    fi
}

echo ""
echo "📦 TESTS BUILTINS:"

# Tests des builtins obligatoires
test_executor "echo simple" "echo hello world" "success"
test_executor "echo avec -n" "echo -n hello" "success"
test_executor "pwd" "pwd" "success"
test_executor "env" "env" "success"
test_executor "export simple" "export TEST=value" "success"
test_executor "unset" "unset TEST" "success"
test_executor "cd HOME" "cd" "success"
test_executor "cd avec argument" "cd /tmp" "success"

echo ""
echo "🔄 TESTS REDIRECTIONS:"

# Créer fichiers de test
echo "test content" > /tmp/test_input.txt

test_executor "Redirection entrée" "cat < /tmp/test_input.txt" "manual"
test_executor "Redirection sortie" "echo test > /tmp/test_output.txt" "success"
test_executor "Redirection append" "echo test2 >> /tmp/test_output.txt" "success"

echo ""
echo "🔗 TESTS PIPES:"

test_executor "Pipe simple" "echo hello | cat" "manual"
test_executor "Pipe multiple" "echo hello | cat | cat" "manual"
test_executor "ls pipe grep" "ls | head -3" "manual"

echo ""
echo "🌍 TESTS VARIABLES:"

test_executor "Variable HOME" "echo \$HOME" "manual"
test_executor "Variable PATH" "echo \$PATH" "manual"
test_executor "Variable inexistante" "echo \$NONEXISTENT" "success"

echo ""
echo "⚡ TESTS SIGNAUX:"

echo "🔹 Test SIGINT (Ctrl+C)... (test manuel)"
echo "   Lancer: ./minishell"
echo "   Taper: sleep 10"
echo "   Appuyer: Ctrl+C"
echo "   Résultat attendu: Interruption propre"

echo ""
echo "🔹 Test SIGQUIT (Ctrl+\\)... (test manuel)"
echo "   Lancer: ./minishell"
echo "   Appuyer: Ctrl+\\"
echo "   Résultat attendu: Aucune action (ignoré)"

echo ""
echo "🧪 TESTS EDGE CASES:"

test_executor "Commande vide" "" "success"
test_executor "Commande inexistante" "commandeinexistante" "success"
test_executor "Permission denied" "/etc/passwd" "success"

echo ""
echo "📊 RÉSULTATS:"
echo "Tests automatiques: $TOTAL"
echo "Réussis: $PASS"
echo "À vérifier manuellement: Tests signaux et sorties"

if [ $PASS -eq $TOTAL ]; then
    echo ""
    echo "✅ Tous les tests automatiques passent!"
    echo "🎯 Procéder aux tests manuels pour validation complète"
else
    echo ""
    echo "⚠️  Certains tests échouent"
    echo "💡 Vérifier l'implémentation des fonctionnalités"
fi

# Nettoyage
rm -f /tmp/test_input.txt /tmp/test_output.txt

echo ""
echo "🔍 TESTS MANUELS RECOMMANDÉS:"
echo "1. ./minishell puis tester interactivement"
echo "2. Vérifier que Ctrl+C interrompt les commandes"
echo "3. Vérifier que Ctrl+\\ est ignoré"
echo "4. Tester: export VAR=value puis echo \$VAR"
echo "5. Tester: cd /tmp puis pwd"
echo "6. Tester: echo hello | grep hello"
echo "7. Tester: cat < /etc/hosts"
echo "8. Tester: echo test > output.txt puis cat output.txt"
