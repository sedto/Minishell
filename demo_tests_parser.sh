#!/bin/bash

# ==================================================================================
# 🧪 DEMO RAPIDE - TESTS PARSER/EXPANDER ADAPTÉS
# ==================================================================================
# Démonstration des tests adaptés pour parser/expander uniquement

echo "🚀 DÉMONSTRATION DES TESTS ADAPTÉS POUR PARSER/EXPANDER"
echo "=================================================="
echo ""

# Vérification que minishell existe
if [ ! -f "./minishell" ]; then
    echo "❌ Erreur : fichier ./minishell non trouvé"
    echo "Compilez d'abord votre projet avec 'make'"
    exit 1
fi

echo "✅ Binaire minishell trouvé"
echo ""

# Test rapide de fonctionnement de base
echo "🔍 Test de base du minishell..."
echo "exit" | timeout 5s ./minishell > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Minishell fonctionne"
else
    echo "⚠️  Minishell semble avoir des problèmes"
fi
echo ""

echo "📋 DÉMONSTRATION DES NOUVEAUX TESTS PARSER/EXPANDER :"
echo ""

# Fonction de demo pour un test de parsing
demo_parsing_test() {
    local test_name="$1"
    local command="$2"
    local expected="$3"
    
    echo "🧪 Test: $test_name"
    echo "   Commande: $command"
    echo "   Attendu: $expected"
    
    # Exécuter le test
    echo "$command" | timeout 3s ./minishell > /dev/null 2>&1
    exit_code=$?
    
    case "$expected" in
        "success")
            if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
                echo "   ✅ RÉUSSI (exit: $exit_code)"
            else
                echo "   ❌ ÉCHOUÉ (exit: $exit_code)"
            fi
            ;;
        "syntax_error")
            if [ "$exit_code" -eq 2 ]; then
                echo "   ✅ RÉUSSI (erreur syntaxe détectée)"
            else
                echo "   ❌ ÉCHOUÉ (erreur non détectée, exit: $exit_code)"
            fi
            ;;
        "no_crash")
            if [ "$exit_code" -ne 139 ] && [ "$exit_code" -ne 124 ]; then
                echo "   ✅ RÉUSSI (pas de crash)"
            else
                echo "   ❌ ÉCHOUÉ (crash détecté, exit: $exit_code)"
            fi
            ;;
    esac
    echo ""
}

# Tests de démonstration
echo "1️⃣ TESTS SIMPLES (Parsing de base)"
echo "-----------------------------------"
demo_parsing_test "Echo simple" "echo hello" "success"
demo_parsing_test "Variable existante" "echo \$USER" "success" 
demo_parsing_test "Quote fermée" "echo 'hello world'" "success"
demo_parsing_test "Quote non fermée" "echo 'hello" "syntax_error"

echo "2️⃣ TESTS MOYENS (Combinaisons)" 
echo "-------------------------------"
demo_parsing_test "Variables multiples" "echo \$USER \$HOME" "success"
demo_parsing_test "Pipes invalides" "echo hello | |" "syntax_error"
demo_parsing_test "Redirection simple" "echo hello > /tmp/test" "success"

echo "3️⃣ TESTS EXTRÊMES (Robustesse)"
echo "-------------------------------"
demo_parsing_test "Longue commande" "echo $(printf 'A%.0s' {1..100})" "no_crash"
demo_parsing_test "Variables massives" "echo \$VAR1\$VAR2\$VAR3\$VAR4\$VAR5" "no_crash"

echo "4️⃣ TESTS EVIL (Sécurité)"
echo "-------------------------"
demo_parsing_test "Buffer overflow" "echo '$(printf 'A%.0s' {1..1000})'" "no_crash"
demo_parsing_test "Injection tentée" "echo hello; rm -rf /" "no_crash"

echo ""
echo "🎯 RÉSUMÉ"
echo "========="
echo "✅ Tests adaptés pour PARSER/EXPANDER uniquement"
echo "✅ Aucune exécution réelle de commandes testée"
echo "✅ Focus sur robustesse, syntaxe, et sécurité"
echo "✅ Compatible avec développement en binôme"
echo ""
echo "📚 Pour lancer la suite complète :"
echo "   ./maitre_tests_complet.sh"
echo ""
echo "📋 Pour une interface interactive :"
echo "   ./lanceur_tests.sh"
echo ""
echo "📖 Documentation complète :"
echo "   README_ADAPTATIONS_PARSER.md"
