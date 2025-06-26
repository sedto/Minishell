#!/bin/bash

# ==================================================================================
# 🟡 NIVEAU 2: TESTS MOYENNEMENT POUSSÉS MINISHELL (PARSER/EXPANDER SEULEMENT)
# ==================================================================================
# Tests intermédiaires qui testent des combinaisons et cas plus complexes
# 
# ⚠️  IMPORTANT: Ces tests ne vérifient que le PARSING et l'EXPANSION
# ⚠️  Aucune exécution réelle de commandes n'est attendue (pas d'executor)
# ⚠️  On teste seulement que le parser ne crash pas et gère la syntaxe

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Variables de comptage
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Fichier de rapport d'erreurs
RAPPORT_ERREURS="rapport_erreurs_moyens.md"

# Fonction pour exécuter un test de parsing uniquement
run_parsing_test() {
    local test_name="$1"
    local command="$2"
    local expected_result="$3"  # "PARSE_OK", "SYNTAX_ERROR", ou "NO_CRASH"
    local description="$4"
    local timeout_duration="${5:-3}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS: $test_name${NC}"
    echo -e "  Commande: ${YELLOW}$command${NC}"
    
    # Créer un fichier temporaire pour la sortie
    local output_file="/tmp/minishell_test_output_$$"
    local error_file="/tmp/minishell_test_error_$$"
    
    # Exécuter la commande avec timeout
    echo "$command" | timeout "$timeout_duration" ./minishell > "$output_file" 2> "$error_file"
    actual_exit=$?
    
    # Lire la sortie et les erreurs
    local output=$(cat "$output_file" 2>/dev/null || echo "")
    local error_output=$(cat "$error_file" 2>/dev/null || echo "")
    
    # Nettoyer les fichiers temporaires
    rm -f "$output_file" "$error_file"
    
    # Analyser le résultat selon le type attendu
    local test_passed=false
    local result_description=""
    
    case "$expected_result" in
        "PARSE_OK")
            # Parsing réussi : exit code 0 ou 1, pas de crash
            if [ "$actual_exit" -eq 0 ] || [ "$actual_exit" -eq 1 ]; then
                test_passed=true
                result_description="Parsing réussi (exit: $actual_exit)"
            else
                result_description="Crash ou erreur inattendue (exit: $actual_exit)"
            fi
            ;;
        "SYNTAX_ERROR")
            # Erreur de syntaxe attendue : exit code 2 généralement
            if [ "$actual_exit" -eq 2 ] || [[ "$error_output" == *"syntax"* ]] || [[ "$error_output" == *"parse"* ]]; then
                test_passed=true
                result_description="Erreur de syntaxe détectée correctement"
            else
                result_description="Erreur de syntaxe non détectée (exit: $actual_exit)"
            fi
            ;;
        "NO_CRASH")
            # Test de robustesse : ne doit PAS crasher
            if [ "$actual_exit" -ne 139 ] && [ "$actual_exit" -ne 124 ]; then
                test_passed=true
                result_description="Pas de crash (exit: $actual_exit)"
            else
                result_description="Crash détecté (exit: $actual_exit)"
            fi
            ;;
    esac
    
    # Afficher le résultat
    if [ "$test_passed" = true ]; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} ($result_description)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} ($result_description)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs
        {
            echo "## Erreur Test $TOTAL_TESTS: $test_name"
            echo "**Description:** $description"
            echo "**Commande:** \`$command\`"
            echo "**Résultat attendu:** $expected_result"
            echo "**Exit code reçu:** $actual_exit"
            echo "**Résultat:** $result_description"
            echo "**Sortie:** \`$output\`"
            echo "**Erreurs:** \`$error_output\`"
            echo "**Catégorie:** Tests moyennement poussés (parser/expander)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Fonction pour test de variables d'environnement (expansion)
run_env_expansion_test() {
    local test_name="$1"
    local command="$2"
    local description="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS: $test_name (Expansion variables)${NC}"
    echo -e "  Commande: ${YELLOW}$command${NC}"
    
    # Test simple : le parser ne doit pas crasher sur l'expansion
    echo "$command" | timeout 3s ./minishell >/dev/null 2>&1
    exit_code=$?
    
    if [ "$exit_code" -ne 139 ] && [ "$exit_code" -ne 124 ]; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} (Pas de crash sur expansion, exit: $exit_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} (Crash sur expansion, exit: $exit_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs
        {
            echo "## Erreur Test $TOTAL_TESTS: $test_name (Expansion)"
            echo "**Description:** $description"
            echo "**Commande:** \`$command\`"
            echo "**Erreur:** Crash lors de l'expansion (exit: $exit_code)"
            echo "**Catégorie:** Tests moyennement poussés (expansion)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Fonction pour test de mémoire avec Valgrind (si disponible)
run_memory_test() {
    local test_name="$1"
    local command="$2"
    local description="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS: $test_name (Mémoire)${NC}"
    echo -e "  Commande: ${YELLOW}$command${NC}"
    
    # Vérifier si Valgrind est disponible
    if ! command -v valgrind &> /dev/null; then
        echo -e "  ${YELLOW}⚠️ IGNORÉ${NC} (Valgrind non disponible)"
        return
    fi
    
    # Exécuter avec Valgrind
    valgrind_output=$(echo "$command" | timeout 10s valgrind --leak-check=no --error-exitcode=42 ./minishell 2>&1)
    valgrind_exit=$?
    
    if [ "$valgrind_exit" -ne 42 ]; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} (Pas d'erreur mémoire critique)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} (Erreur mémoire détectée)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs
        {
            echo "## Erreur Test $TOTAL_TESTS: $test_name (Mémoire)"
            echo "**Description:** $description"
            echo "**Commande:** \`$command\`"
            echo "**Erreur:** Erreur mémoire détectée par Valgrind"
            echo "**Sortie Valgrind:** \`$valgrind_output\`"
            echo "**Catégorie:** Tests moyennement poussés (mémoire)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Initialiser le rapport d'erreurs
echo "# 🟡 RAPPORT D'ERREURS - TESTS MOYENNEMENT POUSSÉS" > "$RAPPORT_ERREURS"
echo "Date: $(date)" >> "$RAPPORT_ERREURS"
echo "" >> "$RAPPORT_ERREURS"

echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}🟡 NIVEAU 2: TESTS MOYENNEMENT POUSSÉS${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

# ==================================================================================
# 🔗 SECTION 1: COMBINAISONS DE VARIABLES (EXPANSION)
# ==================================================================================
echo -e "${PURPLE}🔗 Section 1: Combinaisons de variables${NC}"
echo "──────────────────────────────────────────"

run_env_expansion_test "Variables multiples" "echo \$USER \$HOME \$PWD" "Expansion de plusieurs variables"
run_env_expansion_test "Variables concaténées" "echo \$USER\$HOME" "Variables collées sans espace"
run_env_expansion_test "Variables avec texte" "echo Hello \$USER!" "Variable mélangée avec du texte"
run_env_expansion_test "Variables inexistantes multiples" "echo \$VAR1\$VAR2\$VAR3" "Plusieurs variables inexistantes"

# ==================================================================================
# 🎭 SECTION 2: QUOTES COMPLEXES (PARSING)
# ==================================================================================
echo -e "${PURPLE}🎭 Section 2: Gestion avancée des quotes${NC}"
echo "─────────────────────────────────────────────"

run_parsing_test "Quotes imbriquées simulées" "echo 'Il dit \"bonjour\"'" "PARSE_OK" "Quotes doubles dans quotes simples"
run_parsing_test "Variables dans quotes doubles" "echo \"Utilisateur: \$USER\"" "PARSE_OK" "Expansion dans quotes doubles"
run_parsing_test "Variables protégées" "echo '\$USER ne sera pas expansé'" "PARSE_OK" "Variable protégée par quotes simples"
run_parsing_test "Quotes vides" "echo '' \"\"" "PARSE_OK" "Quotes vides multiples"

# ==================================================================================
# ⚠️ SECTION 3: ERREURS DE SYNTAXE COMPLEXES
# ==================================================================================
echo -e "${PURPLE}⚠️ Section 3: Erreurs de syntaxe avancées${NC}"
echo "────────────────────────────────────────────"

run_parsing_test "Quotes non fermées simple" "echo 'hello" "SYNTAX_ERROR" "Quote simple non fermée"
run_parsing_test "Quotes non fermées double" "echo \"hello" "SYNTAX_ERROR" "Quote double non fermée"
run_parsing_test "Pipes multiples consécutifs" "echo hello | | echo world" "SYNTAX_ERROR" "Deux pipes consécutifs"
run_parsing_test "Redirection invalide" "echo hello > > file" "SYNTAX_ERROR" "Double redirection invalide"

# ==================================================================================
# 🔄 SECTION 4: REDIRECTIONS AVANCÉES (PARSING SEULEMENT)
# ==================================================================================
echo -e "${PURPLE}🔄 Section 4: Redirections complexes${NC}"
echo "────────────────────────────────────────────"

run_parsing_test "Redirection input" "cat < /tmp/test_input_medium.txt" "PARSE_OK" "Parsing redirection depuis un fichier"
run_parsing_test "Redirections multiples" "echo hello > /tmp/out1.txt && echo world > /tmp/out2.txt" "PARSE_OK" "Parsing redirections multiples séparées"
run_parsing_test "Redirection vers fichier" "echo hello > /tmp/nonexistent/file.txt" "PARSE_OK" "Parsing redirection (exécution non testée)"

# ==================================================================================
# 🌟 SECTION 5: CARACTÈRES SPÉCIAUX AVANCÉS
# ==================================================================================
echo -e "${PURPLE}🌟 Section 5: Caractères spéciaux avancés${NC}"
echo "──────────────────────────────────────────────"

run_parsing_test "Caractères échappés" "echo hello\\nworld" "PARSE_OK" "Backslash dans parsing"
run_parsing_test "Caractères de contrôle" "echo 'test\$@#%^&*()'" "PARSE_OK" "Caractères spéciaux protégés"
run_parsing_test "Espaces dans quotes" "echo 'hello    world'" "PARSE_OK" "Préservation des espaces dans quotes"

# ==================================================================================
# 🧠 SECTION 6: LOGIQUE ET CONDITIONS (PARSING)
# ==================================================================================
echo -e "${PURPLE}🧠 Section 6: Tests logiques${NC}"
echo "───────────────────────────────────────"

run_parsing_test "Commande vide" "" "PARSE_OK" "Entrée vide"
run_parsing_test "Espaces seulement" "   " "PARSE_OK" "Espaces uniquement"
run_parsing_test "Tabulations" "	echo hello	" "PARSE_OK" "Commande avec tabulations"

# ==================================================================================
# 🔍 SECTION 7: VARIABLES SPÉCIALES (EXPANSION)
# ==================================================================================
echo -e "${PURPLE}🔍 Section 7: Variables spéciales${NC}"
echo "──────────────────────────────────────"

run_env_expansion_test "Variable exit status" "echo \$?" "Code de sortie de la dernière commande"
run_env_expansion_test "Variable avec chiffres" "echo \$0" "Variable numérotée (non supportée normalement)"
run_env_expansion_test "Variable dollar" "echo \$\$" "PID du processus (comportement peut varier)"

# ==================================================================================
# 💾 SECTION 8: TESTS MÉMOIRE (ROBUSTESSE)
# ==================================================================================
echo -e "${PURPLE}💾 Section 8: Tests de mémoire${NC}"
echo "──────────────────────────────────────"

run_parsing_test "Longue commande" "echo $(printf 'A%.0s' {1..100})" "NO_CRASH" "Test avec une très longue ligne (pas de crash attendu)"
run_env_expansion_test "Variables multiples" "echo \$USER \$HOME \$PATH \$PWD \$SHELL" "Test avec plusieurs variables"
run_parsing_test "Quotes longues" "echo '$(printf 'test%.0s' {1..50})'" "PARSE_OK" "Test avec de longues quotes"

# ==================================================================================
# 🎲 SECTION 9: CAS LIMITES
# ==================================================================================
echo -e "${PURPLE}🎲 Section 9: Cas limites${NC}"
echo "─────────────────────────────────"

run_env_expansion_test "Variable au début" "\$USER echo hello" "Variable en première position"
run_env_expansion_test "Variable seule" "\$USER" "Seulement une variable"
run_parsing_test "Commande inexistante" "commandeinexistante" "PARSE_OK" "Parsing de commande qui n'existe pas"

# ==================================================================================
# 🔧 SECTION 10: ROBUSTESSE
# ==================================================================================
echo -e "${PURPLE}🔧 Section 10: Tests de robustesse${NC}"
echo "───────────────────────────────────────"

run_parsing_test "Caractères non-ASCII" "echo café" "PARSE_OK" "Caractères accentués"
run_env_expansion_test "Nombres dans variables" "echo \$123VAR" "Variable commençant par un chiffre"
run_env_expansion_test "Underscores" "echo \$USER_VAR" "Variable avec underscore"

# ==================================================================================
# 📊 RÉSULTATS FINAUX
# ==================================================================================
echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}📊 RÉSULTATS TESTS MOYENNEMENT POUSSÉS${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

echo -e "${BOLD}Total des tests:${NC} $TOTAL_TESTS"
echo -e "${BOLD}${GREEN}Tests réussis:${NC} $PASSED_TESTS"
echo -e "${BOLD}${RED}Tests échoués:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🎉 TOUS LES TESTS MOYENNEMENT POUSSÉS SONT RÉUSSIS !${NC}"
    success_rate=100
else
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${BOLD}${YELLOW}📋 Taux de réussite: ${success_rate}%${NC}"
    echo -e "${BOLD}${RED}❌ Voir le rapport d'erreurs: $RAPPORT_ERREURS${NC}"
fi

echo ""
echo -e "${CYAN}Fichier de rapport généré: $RAPPORT_ERREURS${NC}"

# Compléter le rapport avec les résultats finaux
{
    echo "---"
    echo ""
    echo "## 📊 Résumé des Tests Moyennement Poussés"
    echo "- **Total des tests:** $TOTAL_TESTS"
    echo "- **Tests réussis:** $PASSED_TESTS"
    echo "- **Tests échoués:** $FAILED_TESTS"
    echo "- **Taux de réussite:** ${success_rate}%"
    echo ""
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🎉 **TOUS LES TESTS MOYENNEMENT POUSSÉS SONT RÉUSSIS !**"
    else
        echo "❌ **Des erreurs ont été détectées dans les tests moyennement poussés.**"
    fi
    echo ""
    echo "### Sections testées:"
    echo "1. 🔗 Combinaisons de variables"
    echo "2. 🎭 Gestion avancée des quotes"
    echo "3. ⚠️ Erreurs de syntaxe avancées"
    echo "4. 🔄 Redirections complexes"
    echo "5. 🌟 Caractères spéciaux avancés"
    echo "6. 🧠 Tests logiques"
    echo "7. 🔍 Variables spéciales"
    echo "8. 💾 Tests de mémoire"
    echo "9. 🎲 Cas limites"
    echo "10. 🔧 Tests de robustesse"
} >> "$RAPPORT_ERREURS"

exit $FAILED_TESTS
