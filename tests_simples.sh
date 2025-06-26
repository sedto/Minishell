#!/bin/bash

# ==================================================================================
# 🟢 NIVEAU 1: TESTS SIMPLES MINISHELL
# ==================================================================================
# Tests basiques pour vérifier le bon fonctionnement des fonctionnalités de base

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables de comptage
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Fichier de rapport d'erreurs
RAPPORT_ERREURS="rapport_erreurs_simples.md"

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit="$3"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS: $test_name${NC}"
    echo -e "  Commande: ${YELLOW}$command${NC}"
    
    # Exécuter la commande et capturer le code de sortie
    echo "$command" | timeout 3s ./minishell > /dev/null 2>&1
    actual_exit=$?
    
    # Vérifier le résultat
    if [ "$actual_exit" = "$expected_exit" ]; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} (Exit code: $actual_exit)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} (Attendu: $expected_exit, Reçu: $actual_exit)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs
        {
            echo "## Erreur Test $TOTAL_TESTS: $test_name"
            echo "**Description:** $description"
            echo "**Commande:** \`$command\`"
            echo "**Exit code attendu:** $expected_exit"
            echo "**Exit code reçu:** $actual_exit"
            echo "**Catégorie:** Tests simples"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Fonction pour tester le parsing (sans exécution - pour parser seul)
run_parsing_test() {
    local test_name="$1"
    local input="$2"
    local expected_behavior="$3"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS: $test_name${NC}"
    echo -e "  Input: ${YELLOW}$input${NC}"
    
    # Exécuter et capturer uniquement le code de sortie et comportement
    echo "$input" | timeout 3s ./minishell > /dev/null 2>&1
    exit_code=$?
    
    # Analyser le comportement selon le contexte
    local test_passed=false
    case "$expected_behavior" in
        "PARSE_OK")
            # Le parsing doit réussir (exit code 0 ou pas de crash)
            if [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; then
                test_passed=true
            fi
            ;;
        "SYNTAX_ERROR")
            # Erreur de syntaxe attendue (exit code 2)
            if [ $exit_code -eq 2 ]; then
                test_passed=true
            fi
            ;;
        "NO_CRASH")
            # Ne doit pas crash (pas de segfault)
            if [ $exit_code -ne 139 ] && [ $exit_code -ne 124 ]; then
                test_passed=true
            fi
            ;;
    esac
    
    if $test_passed; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} (Parsing: $expected_behavior, Exit: $exit_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} (Attendu: $expected_behavior, Exit: $exit_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs
        {
            echo "## Erreur Test $TOTAL_TESTS: $test_name"
            echo "**Description:** $description"
            echo "**Input:** \`$input\`"
            echo "**Comportement attendu:** $expected_behavior"
            echo "**Exit code reçu:** $exit_code"
            echo "**Catégorie:** Tests simples (parsing)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Initialiser le rapport d'erreurs
echo "# 🟢 RAPPORT D'ERREURS - TESTS SIMPLES (PARSER UNIQUEMENT)" > "$RAPPORT_ERREURS"
echo "**Note:** Ces tests vérifient uniquement le parsing/expansion, pas l'exécution" >> "$RAPPORT_ERREURS"
echo "Date: $(date)" >> "$RAPPORT_ERREURS"
echo "" >> "$RAPPORT_ERREURS"

echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}🟢 NIVEAU 1: TESTS SIMPLES MINISHELL${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${CYAN}Mode: PARSER/EXPANDER UNIQUEMENT (sans executor)${NC}"
echo ""

# ==================================================================================
# 📝 SECTION 1: PARSING DE COMMANDES BASIQUES
# ==================================================================================
echo -e "${PURPLE}📝 Section 1: Parsing de commandes de base${NC}"
echo "────────────────────────────────────────"

run_parsing_test "Parse echo simple" "echo hello" "PARSE_OK" "Parser doit analyser echo sans crash"
run_parsing_test "Parse echo arguments" "echo hello world" "PARSE_OK" "Parser doit gérer les arguments multiples"
run_parsing_test "Parse echo vide" "echo" "PARSE_OK" "Parser doit gérer echo sans arguments"
run_parsing_test "Parse echo espaces" "echo    hello    world" "PARSE_OK" "Parser doit normaliser les espaces"

# ==================================================================================
# 🔤 SECTION 2: PARSING DE VARIABLES
# ==================================================================================
echo -e "${PURPLE}🔤 Section 2: Parsing des variables d'environnement${NC}"
echo "─────────────────────────────────────────────────"

run_parsing_test "Parse variable USER" "echo \$USER" "PARSE_OK" "Parser doit analyser l'expansion de \$USER"
run_parsing_test "Parse variable HOME" "echo \$HOME" "PARSE_OK" "Parser doit analyser l'expansion de \$HOME"
run_parsing_test "Parse variable inexistante" "echo \$INEXISTANT" "PARSE_OK" "Parser doit gérer les variables inexistantes"
run_parsing_test "Parse dollar seul" "echo \$" "PARSE_OK" "Parser doit gérer le dollar isolé"

# ==================================================================================
# 📋 SECTION 3: QUOTES SIMPLES
# ==================================================================================
echo -e "${PURPLE}📋 Section 3: Gestion des quotes de base${NC}"
echo "──────────────────────────────────────────────"

run_parsing_test "Quotes simples" "echo 'hello world'" "PARSE_OK" "Parser doit analyser les quotes simples"
run_parsing_test "Quotes doubles" "echo \"hello world\"" "PARSE_OK" "Parser doit analyser les quotes doubles"
run_parsing_test "Quotes simples avec variables" "echo '\$USER'" "PARSE_OK" "Parser doit analyser les quotes simples avec variables"
run_parsing_test "Quotes doubles avec variables" "echo \"\$USER\"" "PARSE_OK" "Parser doit analyser les quotes doubles avec variables"

# ==================================================================================
# ⚠️ SECTION 4: ERREURS DE SYNTAXE SIMPLES
# ==================================================================================
echo -e "${PURPLE}⚠️ Section 4: Erreurs de syntaxe basiques${NC}"
echo "────────────────────────────────────────────"

run_parsing_test "Pipe en fin" "echo hello |" "SYNTAX_ERROR" "Pipe à la fin de ligne (erreur de syntaxe)"
run_parsing_test "Pipe en début" "| echo hello" "SYNTAX_ERROR" "Pipe en début de ligne (erreur de syntaxe)"
run_parsing_test "Redirection sans fichier" "echo hello >" "SYNTAX_ERROR" "Redirection output sans fichier"
run_parsing_test "Double redirection" "echo hello >> " "SYNTAX_ERROR" "Redirection append sans fichier"

# ==================================================================================
# 🚪 SECTION 5: COMMANDES DE CONTRÔLE
# ==================================================================================
echo -e "${PURPLE}🚪 Section 5: Commandes de contrôle simples${NC}"
echo "────────────────────────────────────────────"

run_parsing_test "Exit simple" "exit" "PARSE_OK" "Commande exit basique"
run_parsing_test "Exit avec code" "exit 0" "PARSE_OK" "Exit avec code de sortie 0"
run_parsing_test "Exit avec code non-zero" "exit 1" "PARSE_OK" "Exit avec code de sortie 1"

# ==================================================================================
# 📁 SECTION 6: REDIRECTIONS SIMPLES
# ==================================================================================
echo -e "${PURPLE}📁 Section 6: Redirections de base${NC}"
echo "───────────────────────────────────────────"

# Créer un fichier temporaire pour les tests
echo "test content" > /tmp/test_input.txt

run_parsing_test "Redirection output" "echo hello > /tmp/test_output.txt" "PARSE_OK" "Redirection vers fichier"
run_parsing_test "Redirection append" "echo world >> /tmp/test_output.txt" "PARSE_OK" "Redirection en mode append"

# Nettoyer les fichiers temporaires
rm -f /tmp/test_input.txt /tmp/test_output.txt

# ==================================================================================
# 🔍 SECTION 7: CARACTÈRES SPÉCIAUX SIMPLES
# ==================================================================================
echo -e "${PURPLE}🔍 Section 7: Caractères spéciaux de base${NC}"
echo "────────────────────────────────────────────"

run_parsing_test "Caractères spéciaux dans quotes" "echo 'test@#\$%^&*()'" "PARSE_OK" "Parser doit analyser les caractères spéciaux protégés"
run_parsing_test "Espaces multiples" "echo hello     world" "PARSE_OK" "Parser doit analyser les espaces multiples"

# ==================================================================================
# 📊 RÉSULTATS FINAUX
# ==================================================================================
echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}📊 RÉSULTATS TESTS SIMPLES${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo ""

echo -e "${BOLD}Total des tests:${NC} $TOTAL_TESTS"
echo -e "${BOLD}${GREEN}Tests réussis:${NC} $PASSED_TESTS"
echo -e "${BOLD}${RED}Tests échoués:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🎉 TOUS LES TESTS SIMPLES SONT RÉUSSIS !${NC}"
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
    echo "## 📊 Résumé des Tests Simples"
    echo "- **Total des tests:** $TOTAL_TESTS"
    echo "- **Tests réussis:** $PASSED_TESTS"
    echo "- **Tests échoués:** $FAILED_TESTS"
    echo "- **Taux de réussite:** ${success_rate}%"
    echo ""
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🎉 **TOUS LES TESTS SIMPLES SONT RÉUSSIS !**"
    else
        echo "❌ **Des erreurs ont été détectées dans les tests simples.**"
    fi
} >> "$RAPPORT_ERREURS"

exit $FAILED_TESTS
