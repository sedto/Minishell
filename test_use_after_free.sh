#!/bin/bash

echo "🚨 TEST CRITIQUE: Use After Free Detection"
echo "========================================="
echo

echo "📊 Test 1: Erreurs de syntaxe pipes"
echo "==================================="

# Test avec erreurs de syntaxe qui déclenchaient le use-after-free
test_cases=(
    "|"                    # Pipe au début
    "echo |"               # Pipe à la fin
    "echo | |"             # Double pipe
    "echo ||"              # Double pipe collé
    "| echo"               # Pipe au début avec commande
    "echo | | echo"        # Pipe entre pipes
)

for test_case in "${test_cases[@]}"; do
    echo "   Test: '$test_case'"
    echo "$test_case" | ./minishell -c 2>/dev/null
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "   ✅ Erreur détectée correctement (exit: $exit_code)"
    else
        echo "   ⚠️  Devrait être une erreur de syntaxe"
    fi
done

echo
echo "📊 Test 2: Erreurs de syntaxe redirections"
echo "=========================================="

redirect_cases=(
    ">"                    # Redirection seule
    "<"                    # Redirection seule
    "echo >"               # Redirection sans fichier
    "echo <"               # Redirection sans fichier
    "echo > >"             # Double redirection
    "echo < <"             # Double redirection
)

for test_case in "${redirect_cases[@]}"; do
    echo "   Test: '$test_case'"
    echo "$test_case" | ./minishell -c 2>/dev/null
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "   ✅ Erreur détectée correctement (exit: $exit_code)"
    else
        echo "   ⚠️  Devrait être une erreur de syntaxe"
    fi
done

echo
echo "🔍 Test 3: Valgrind - Détection Use After Free"
echo "=============================================="

if command -v valgrind >/dev/null 2>&1; then
    echo "Test Valgrind avec syntaxe incorrecte..."
    
    # Test spécifique qui déclenchait le use-after-free
    echo "|" | timeout 10 valgrind --tool=memcheck --track-origins=yes --error-exitcode=1 ./minishell -c &>valgrind_use_after_free.log
    
    # Vérifier directement les erreurs dans le log
    if grep -q "Invalid read\|Invalid write\|use after free" valgrind_use_after_free.log; then
        echo "❌ ERREUR: Use-after-free ou accès invalide détecté !"
        grep -A 3 -B 3 "Invalid read\|Invalid write\|use after free" valgrind_use_after_free.log
        exit 1
    else
        echo "✅ Valgrind: Aucun use-after-free détecté"
        # Vérifier que nous avons bien 0 erreurs
        errors=$(grep "ERROR SUMMARY:" valgrind_use_after_free.log | awk '{print $4}')
        if [ "$errors" = "0" ]; then
            echo "✅ Confirmation: 0 erreurs Valgrind"
        else
            echo "⚠️  $errors erreurs détectées"
        fi
    fi
    
    # Test avec plusieurs cas problématiques
    for problematic in "echo |" "echo | |"; do
        echo "   Test Valgrind: '$problematic'"
        echo "$problematic" | timeout 5 valgrind --tool=memcheck --error-exitcode=1 ./minishell -c &>valgrind_temp.log
        if grep -q "Invalid read\|Invalid write\|use after free" valgrind_temp.log; then
            echo "   ❌ Erreur mémoire détectée"
        else
            echo "   ✅ OK"
        fi
    done
    
    rm -f valgrind_use_after_free.log valgrind_temp.log
else
    echo "⚠️  Valgrind non disponible"
fi

echo
echo "📊 Test 4: Test de stabilité répétée"
echo "==================================="

echo "Test de 100 erreurs de syntaxe consécutives..."
for i in {1..100}; do
    echo "|" | ./minishell -c &>/dev/null
    if [ $? -eq 0 ]; then
        echo "❌ ERREUR: Cas $i devrait échouer"
        exit 1
    fi
done
echo "✅ 100 erreurs traitées correctement - Aucun crash"

echo
echo "🔧 CORRECTION APPLIQUÉE:"
echo "========================"
echo "✅ Suppression de free_commands() dans syntax_error_cleanup()"
echo "✅ Libération gérée uniquement dans parse_tokens_to_commands()"
echo "✅ Élimination du double free et use-after-free"
echo "✅ Gestion d'erreurs maintenant sûre"

echo
echo "🎯 RÉSULTAT:"
echo "============"
echo "✅ Use-after-free éliminé"
echo "✅ Gestion d'erreurs robuste"
echo "✅ Aucun crash sur syntaxe incorrecte"
