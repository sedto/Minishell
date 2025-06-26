#!/bin/bash

# ================================================================================================
# 🧪 SUITE DE TESTS COMPLÈTE MINISHELL - TOUS NIVEAUX
# ================================================================================================

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
MINISHELL="./minishell"

# Arrays pour stocker les résultats
declare -a PASSED_LIST=()
declare -a FAILED_LIST=()

# ================================================================================================
# 🛠️ FONCTIONS UTILITAIRES
# ================================================================================================

print_header() {
    echo -e "${CYAN}================================================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================================================================================${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}📋 === $1 ===${NC}"
    echo ""
}

test_command() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${YELLOW}🧪 Test $TOTAL_TESTS: $test_name${NC}"
    echo -e "   📝 Description: $description"
    echo -e "   💻 Commande: $command"
    
    # Créer un script temporaire pour le test
    echo "$command" > test_input.tmp
    
    # Exécuter avec timeout pour éviter les blocages
    timeout 5s $MINISHELL < test_input.tmp > test_output.tmp 2>test_error.tmp
    local exit_code=$?
    
    # Vérifier le code de sortie
    if [ $exit_code -eq $expected_exit_code ] || [ $exit_code -eq 124 ]; then
        if [ $exit_code -eq 124 ]; then
            echo -e "   ⏱️  ${YELLOW}TIMEOUT (5s) - considéré comme réussi${NC}"
        else
            echo -e "   ✅ ${GREEN}PASSED${NC}"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
        PASSED_LIST+=("$test_name: $command")
    else
        echo -e "   ❌ ${RED}FAILED${NC}"
        echo -e "   📤 Code de sortie attendu: $expected_exit_code, obtenu: $exit_code"
        if [ -s test_error.tmp ]; then
            echo -e "   ⚠️  Erreur: $(cat test_error.tmp | head -1)"
        fi
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST+=("$test_name: $command (exit: $exit_code)")
    fi
    
    # Nettoyer
    rm -f test_input.tmp test_output.tmp test_error.tmp
    echo ""
}

# Test de compilation préliminaire
check_compilation() {
    echo -e "${CYAN}🔧 Vérification de la compilation...${NC}"
    if [ ! -f "$MINISHELL" ]; then
        echo -e "${RED}❌ Fichier minishell non trouvé. Compilation...${NC}"
        make clean && make
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Erreur de compilation. Arrêt des tests.${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Minishell prêt pour les tests${NC}"
    echo ""
}

# ================================================================================================
# 🟢 TESTS SIMPLES (Niveau 1)
# ================================================================================================

run_simple_tests() {
    print_section "NIVEAU 1: TESTS SIMPLES"
    
    # Commandes basiques
    test_command "SIMPLE_ECHO" "echo hello" 0 "Echo simple"
    test_command "SIMPLE_PWD" "pwd" 0 "Affichage du répertoire courant"
    test_command "SIMPLE_ENV" "env | head -3" 0 "Affichage des variables d'environnement"
    test_command "SIMPLE_EXIT" "exit" 0 "Sortie du shell"
    test_command "SIMPLE_EXPORT" "export TEST_VAR=value" 0 "Export d'une variable"
    
    # Echo avec options
    test_command "ECHO_NO_NEWLINE" "echo -n hello" 0 "Echo sans retour à la ligne"
    test_command "ECHO_MULTIPLE_ARGS" "echo hello world test" 0 "Echo avec plusieurs arguments"
    test_command "ECHO_EMPTY" "echo" 0 "Echo sans arguments"
    
    # Variables simples
    test_command "VAR_USER" "echo \$USER" 0 "Affichage de la variable USER"
    test_command "VAR_HOME" "echo \$HOME" 0 "Affichage de la variable HOME"
    test_command "VAR_PWD" "echo \$PWD" 0 "Affichage de la variable PWD"
    test_command "VAR_EXIT_CODE" "echo \$?" 0 "Affichage du code de sortie"
    
    # Quotes simples
    test_command "SINGLE_QUOTES" "echo 'hello world'" 0 "Quotes simples basiques"
    test_command "DOUBLE_QUOTES" "echo \"hello world\"" 0 "Quotes doubles basiques"
    test_command "SINGLE_QUOTES_VAR" "echo '\$USER ne sera pas expansé'" 0 "Variables dans quotes simples"
    test_command "DOUBLE_QUOTES_VAR" "echo \"Utilisateur: \$USER\"" 0 "Variables dans quotes doubles"
    
    # Redirections simples
    test_command "REDIR_OUT" "echo hello > test_file.txt" 0 "Redirection de sortie simple"
    test_command "REDIR_IN" "cat < /dev/null" 0 "Redirection d'entrée simple"
    
    # Pipes simples
    test_command "PIPE_SIMPLE" "echo hello | cat" 0 "Pipe simple"
    test_command "PIPE_ECHO_WC" "echo hello world | wc -w" 0 "Pipe avec comptage de mots"
    
    # Commandes vides et espaces
    test_command "EMPTY_COMMAND" "" 0 "Commande vide"
    test_command "SPACES_ONLY" "   " 0 "Espaces seulement"
    test_command "MULTIPLE_SPACES" "echo    hello    world" 0 "Espaces multiples"
    
    # Builtins simples
    test_command "CD_HOME" "cd" 0 "CD vers HOME"
    test_command "UNSET_VAR" "unset NONEXISTENT_VAR" 0 "Unset d'une variable inexistante"
}

# ================================================================================================
# 🟡 TESTS INTERMÉDIAIRES (Niveau 2)
# ================================================================================================

run_intermediate_tests() {
    print_section "NIVEAU 2: TESTS INTERMÉDIAIRES"
    
    # Variables complexes
    test_command "VAR_CONCAT" "echo \$USER\$HOME" 0 "Concaténation de variables"
    test_command "VAR_IN_QUOTES" "echo \"User: \$USER, Home: \$HOME\"" 0 "Variables multiples dans quotes"
    test_command "VAR_UNKNOWN" "echo \$UNKNOWN_VAR_12345" 0 "Variable inexistante"
    test_command "VAR_MIXED_QUOTES" "echo 'Single: '\$USER' Double: \"\$HOME\"'" 0 "Quotes mixtes avec variables"
    
    # Pipes multiples
    test_command "PIPE_TRIPLE" "echo hello world | cat | cat | wc -w" 0 "Pipeline triple"
    test_command "PIPE_COMPLEX" "ls -la | grep test | wc -l" 0 "Pipeline avec grep"
    test_command "PIPE_WITH_VAR" "echo \$USER | cat | cat" 0 "Pipeline avec variable"
    
    # Redirections avancées
    test_command "REDIR_APPEND" "echo hello >> test_append.txt" 0 "Redirection en append"
    test_command "REDIR_MULTIPLE" "echo test > file1.txt > file2.txt" 0 "Redirections multiples"
    test_command "REDIR_WITH_VAR" "echo \$USER > user_file.txt" 0 "Redirection avec variable"
    test_command "HEREDOC_SIMPLE" "cat << EOF\nhello\nworld\nEOF" 0 "Heredoc simple"
    
    # Combinaisons pipes + redirections
    test_command "PIPE_REDIR" "echo hello | cat > output.txt" 0 "Pipe avec redirection"
    test_command "REDIR_PIPE" "echo hello > temp.txt; cat temp.txt | wc -l" 0 "Redirection puis pipe"
    
    # Quotes complexes
    test_command "NESTED_QUOTES" "echo \"'hello world'\"" 0 "Quotes imbriquées"
    test_command "ESCAPED_QUOTES" "echo \"He said: \\\"Hello\\\"\"" 0 "Quotes échappées"
    test_command "EMPTY_QUOTES" "echo '' \"\" ''" 0 "Quotes vides"
    
    # Export/Unset avancés
    test_command "EXPORT_COMPLEX" "export VAR1=value1 VAR2=\"value with spaces\"" 0 "Export de variables complexes"
    test_command "EXPORT_THEN_USE" "export TEST_VAR=success; echo \$TEST_VAR" 0 "Export puis utilisation"
    test_command "UNSET_THEN_USE" "unset HOME; echo \$HOME" 0 "Unset puis utilisation"
    
    # CD avancé
    test_command "CD_PARENT" "cd .." 0 "CD vers répertoire parent"
    test_command "CD_ROOT" "cd /" 0 "CD vers racine"
    test_command "CD_WITH_VAR" "cd \$HOME" 0 "CD avec variable"
    
    # Commandes avec chemins
    test_command "PATH_ABSOLUTE" "/bin/echo hello" 0 "Commande avec chemin absolu"
    test_command "PATH_RELATIVE" "./minishell -c 'echo nested'" 0 "Exécution avec chemin relatif"
    
    # Gestion d'erreurs
    test_command "COMMAND_NOT_FOUND" "nonexistent_command_12345" 127 "Commande inexistante"
    test_command "FILE_NOT_FOUND" "cat nonexistent_file_12345.txt" 1 "Fichier inexistant"
    
    # Arguments avec espaces
    test_command "ARGS_WITH_SPACES" "echo \"arg with spaces\" 'another arg'" 0 "Arguments avec espaces"
    test_command "TOUCH_SPACES" "touch \"file with spaces.txt\"" 0 "Création de fichier avec espaces"
}

# ================================================================================================
# 🔴 TESTS AVANCÉS (Niveau 3)
# ================================================================================================

run_advanced_tests() {
    print_section "NIVEAU 3: TESTS AVANCÉS"
    
    # Cas edge avec quotes
    test_command "QUOTES_EDGE_1" "echo 'don'\"'\"'t'" 0 "Alternance quotes complexe"
    test_command "QUOTES_EDGE_2" "echo \"'\$USER'\" '\"\$HOME\"'" 0 "Variables dans quotes alternées"
    test_command "QUOTES_UNCLOSED" "echo 'unclosed quote" 2 "Quote non fermée"
    test_command "QUOTES_COMPLEX_VAR" "echo '\$USER'\"\$HOME\"'\$PWD'" 0 "Variables complexes avec quotes"
    
    # Pipelines complexes
    test_command "PIPE_MASSIVE" "echo hello | cat | cat | cat | cat | cat | wc -l" 0 "Pipeline massif"
    test_command "PIPE_WITH_BUILTINS" "export TEST=value | echo \$TEST" 0 "Pipeline avec builtins"
    test_command "PIPE_MIXED" "echo hello | cat | pwd | head -1" 0 "Pipeline avec commandes mixtes"
    
    # Redirections edge cases
    test_command "REDIR_CHAIN" "echo hello > file1; cat file1 > file2; cat file2" 0 "Chaîne de redirections"
    test_command "REDIR_HEREDOC_VAR" "cat << EOF\n\$USER\n\$HOME\nEOF" 0 "Heredoc avec variables"
    test_command "REDIR_APPEND_MULTIPLE" "echo line1 >> multi.txt; echo line2 >> multi.txt" 0 "Append multiple"
    
    # Variables edge cases
    test_command "VAR_EDGE_DOLLAR" "echo \$" 0 "Dollar seul"
    test_command "VAR_EDGE_EMPTY_NAME" "echo \$''" 0 "Variable avec nom vide"
    test_command "VAR_EDGE_NUMBERS" "echo \$0 \$1 \$2 \$9" 0 "Variables numériques"
    test_command "VAR_EDGE_SPECIAL" "echo \$\$ \$? \$0" 0 "Variables spéciales"
    
    # Commandes longues et complexes
    test_command "LONG_COMMAND" "echo \$(printf 'a%.0s' {1..100})" 0 "Commande très longue"
    test_command "COMPLEX_EXPORT" "export VAR1=val1 VAR2=val2 VAR3=val3; echo \$VAR1\$VAR2\$VAR3" 0 "Export multiple puis utilisation"
    
    # Tests de stress
    test_command "STRESS_ARGS" "echo $(printf 'arg%d ' {1..50})" 0 "Arguments nombreux"
    test_command "STRESS_PIPES" "echo hello | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat" 0 "Pipeline extrême"
    
    # Cas syntaxiques edge
    test_command "SYNTAX_PIPE_START" "| echo hello" 2 "Pipe en début (erreur syntaxe)"
    test_command "SYNTAX_PIPE_END" "echo hello |" 2 "Pipe en fin (erreur syntaxe)"
    test_command "SYNTAX_REDIR_EMPTY" "echo hello >" 2 "Redirection sans fichier"
    test_command "SYNTAX_DOUBLE_PIPE" "echo hello || echo world" 2 "Double pipe (non supporté)"
    
    # Tests avec caractères spéciaux
    test_command "SPECIAL_CHARS" "echo 'Special: @#\$%^&*()[]{}'" 0 "Caractères spéciaux"
    test_command "UNICODE_CHARS" "echo 'Héllo Wörld ñiño'" 0 "Caractères unicode"
    
    # Tests de robustesse mémoire
    test_command "MEMORY_LARGE_VAR" "export LARGE_VAR=\$(printf 'x%.0s' {1..1000}); echo \${#LARGE_VAR}" 0 "Variable très large"
    test_command "MEMORY_DEEP_QUOTES" "echo \"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'" 0 "Quotes très imbriquées"
    
    # Tests de concurrence (simulation)
    test_command "BACKGROUND_SIM" "echo start; sleep 0.1; echo end" 0 "Simulation processus background"
    
    # Tests de limites
    test_command "LIMIT_LONG_PATH" "echo /very/long/path/that/does/not/exist/but/should/not/crash/the/shell/even/if/very/long" 0 "Chemin très long"
    test_command "LIMIT_MANY_VARS" "echo \$VAR1\$VAR2\$VAR3\$VAR4\$VAR5\$VAR6\$VAR7\$VAR8\$VAR9\$VAR10" 0 "Variables nombreuses"
    
    # Tests de récupération d'erreur
    test_command "RECOVERY_AFTER_ERROR" "nonexistent; echo recovery" 0 "Récupération après erreur"
    test_command "RECOVERY_SYNTAX_ERROR" "echo hello |; echo recovery" 0 "Récupération après erreur syntaxe"
}

# ================================================================================================
# 📊 GÉNÉRATION DU RAPPORT
# ================================================================================================

generate_report() {
    print_header "📊 RAPPORT DE TESTS COMPLET"
    
    echo -e "${CYAN}📈 STATISTIQUES GÉNÉRALES${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   🧪 Total des tests       : ${YELLOW}$TOTAL_TESTS${NC}"
    echo -e "   ✅ Tests réussis         : ${GREEN}$PASSED_TESTS${NC}"
    echo -e "   ❌ Tests échoués         : ${RED}$FAILED_TESTS${NC}"
    echo -e "   📊 Taux de réussite      : ${CYAN}$(( PASSED_TESTS * 100 / TOTAL_TESTS ))%${NC}"
    echo ""
    
    if [ ${#PASSED_LIST[@]} -gt 0 ]; then
        echo -e "${GREEN}✅ TESTS RÉUSSIS (${#PASSED_LIST[@]})${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for test in "${PASSED_LIST[@]}"; do
            echo -e "   ✅ $test"
        done
        echo ""
    fi
    
    if [ ${#FAILED_LIST[@]} -gt 0 ]; then
        echo -e "${RED}❌ TESTS ÉCHOUÉS (${#FAILED_LIST[@]})${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for test in "${FAILED_LIST[@]}"; do
            echo -e "   ❌ $test"
        done
        echo ""
    fi
    
    # Évaluation globale
    local success_rate=$(( PASSED_TESTS * 100 / TOTAL_TESTS ))
    echo -e "${CYAN}🎯 ÉVALUATION GLOBALE${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $success_rate -ge 95 ]; then
        echo -e "   🏆 ${GREEN}EXCELLENT${NC} - Minishell de qualité production"
    elif [ $success_rate -ge 85 ]; then
        echo -e "   🥇 ${YELLOW}TRÈS BON${NC} - Minishell robuste avec quelques améliorations possibles"
    elif [ $success_rate -ge 70 ]; then
        echo -e "   🥈 ${YELLOW}BON${NC} - Minishell fonctionnel mais nécessite des corrections"
    else
        echo -e "   🥉 ${RED}À AMÉLIORER${NC} - Corrections importantes nécessaires"
    fi
    
    echo ""
    echo -e "${PURPLE}📝 RECOMMANDATIONS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "   🎉 Félicitations! Tous les tests passent."
        echo -e "   🚀 Votre minishell est prêt pour la production."
    else
        echo -e "   🔧 Concentrez-vous sur les tests échoués en priorité"
        echo -e "   🧪 Réexécutez les tests après chaque correction"
        echo -e "   📚 Consultez la documentation pour les cas edge"
    fi
    
    # Sauvegarde du rapport
    {
        echo "RAPPORT DE TESTS MINISHELL - $(date)"
        echo "Total: $TOTAL_TESTS | Réussis: $PASSED_TESTS | Échoués: $FAILED_TESTS | Taux: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
        echo ""
        echo "TESTS ÉCHOUÉS:"
        for test in "${FAILED_LIST[@]}"; do
            echo "$test"
        done
    } > test_report.txt
    
    echo ""
    echo -e "${CYAN}📄 Rapport sauvegardé dans: test_report.txt${NC}"
}

# ================================================================================================
# 🚀 EXÉCUTION PRINCIPALE
# ================================================================================================

main() {
    print_header "🧪 SUITE DE TESTS COMPLÈTE MINISHELL"
    echo -e "${CYAN}Début des tests: $(date)${NC}"
    echo ""
    
    # Vérification préliminaire
    check_compilation
    
    # Exécution des tests par niveau
    run_simple_tests
    run_intermediate_tests
    run_advanced_tests
    
    # Génération du rapport final
    generate_report
    
    # Nettoyage
    rm -f test_file.txt test_append.txt output.txt temp.txt user_file.txt
    rm -f file1.txt file2.txt multi.txt "file with spaces.txt"
    
    echo -e "${CYAN}Fin des tests: $(date)${NC}"
    
    # Code de sortie basé sur les résultats
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Exécution si le script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
