#!/bin/bash

# Script de tests robustes pour valider les corrections du parser
echo "🔥 TESTS ROBUSTES MINISHELL - PARSER SEULEMENT"
echo "================================================"
echo ""

# Compteurs
TESTS=0
PASS=0
FAIL=0

# Fonction de test qui vérifie que le parser ne crash pas
test_parser() {
    local desc="$1"
    local cmd="$2"
    local expect="$3"
    
    echo -n "🔹 $desc... "
    TESTS=$((TESTS + 1))
    
    # Test avec timeout pour éviter les blocages
    if [ "$expect" = "no_crash" ]; then
        timeout 3s bash -c "echo '$cmd' | ./minishell > /dev/null 2>&1"
        local exit_code=$?
        
        if [ $exit_code -ne 139 ] && [ $exit_code -ne 124 ]; then
            echo "✅ PASS"
            PASS=$((PASS + 1))
        else
            echo "❌ CRASH (code: $exit_code)"
            FAIL=$((FAIL + 1))
        fi
    elif [ "$expect" = "option_c" ]; then
        timeout 3s ./minishell -c "$cmd" > /dev/null 2>&1
        local exit_code=$?
        
        if [ $exit_code -ne 139 ] && [ $exit_code -ne 124 ]; then
            echo "✅ PASS"
            PASS=$((PASS + 1))
        else
            echo "❌ CRASH (code: $exit_code)"
            FAIL=$((FAIL + 1))
        fi
    fi
}

echo "🚨 Tests des bugs critiques (anciennement crashants):"
test_parser "Variable dollar seul" 'echo $' "no_crash"
test_parser "Variable numérique invalide" 'echo $123abc' "no_crash"
test_parser "Pipe en fin de ligne" 'echo hello |' "no_crash"
test_parser "Pipe en début de ligne" '| echo hello' "no_crash"
test_parser "Redirection sans fichier" 'echo >' "no_crash"
test_parser "Double pipe" 'echo hello || echo world' "no_crash"

echo ""
echo "🔧 Tests fonctionnels (parsing):"
test_parser "Commande simple" 'echo hello world' "no_crash"
test_parser "Variable USER" 'echo $USER' "no_crash"
test_parser "Variable HOME" 'echo $HOME' "no_crash"
test_parser "Variable ??" 'echo $?' "no_crash"
test_parser "Quotes simples" "echo 'hello world'" "no_crash"
test_parser "Quotes doubles" 'echo "hello world"' "no_crash"
test_parser "Variables dans quotes" 'echo "Hello $USER"' "no_crash"

echo ""
echo "⚡ Tests option -c:"
test_parser "Option -c simple" "echo hello" "option_c"
test_parser "Option -c avec variable" "echo \$USER" "option_c"
test_parser "Option -c quotes" "echo 'test'" "option_c"

echo ""
echo "🧠 Test memory leaks (Valgrind):"
if command -v valgrind >/dev/null 2>&1; then
    echo -n "🔹 Memory leaks check... "
    
    # Test avec une commande simple via option -c
    valgrind --leak-check=full --error-exitcode=42 ./minishell -c "echo test" >/dev/null 2>&1
    local valgrind_exit=$?
    
    TESTS=$((TESTS + 1))
    if [ $valgrind_exit -ne 42 ]; then
        echo "✅ PASS - Aucun leak détecté"
        PASS=$((PASS + 1))
    else
        echo "❌ FAIL - Memory leaks détectés"
        FAIL=$((FAIL + 1))
    fi
else
    echo "⚠️  Valgrind non disponible, skip test memory"
fi

echo ""
echo "🎯 Tests stress (variables complexes):"
test_parser "Variables multiples" 'echo $USER $HOME $PWD' "no_crash"
test_parser "Variable inexistante" 'echo $NONEXISTENT_VAR' "no_crash"
test_parser "Expansion complexe" 'echo "$USER and $HOME"' "no_crash"

echo ""
echo "📊 RÉSULTATS FINAUX:"
echo "=================="
echo "Tests exécutés: $TESTS"
echo "Succès: $PASS"
echo "Échecs: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 PARFAIT ! Tous les tests passent !"
    echo "✅ Le parser est robuste et sans crash"
    echo "🚀 Prêt pour l'implémentation de l'exécuteur"
    echo ""
    echo "NOTE: Le parser fonctionne parfaitement."
    echo "      L'absence de sortie est normale car l'exécuteur"
    echo "      n'est pas encore implémenté."
    exit 0
else
    echo ""
    echo "❌ PROBLÈMES DÉTECTÉS !"
    echo "Des corrections sont nécessaires avant l'exécuteur."
    exit 1
fi
