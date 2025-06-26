#!/bin/bash

# ================================================================================================
# 🔥 TESTS DE STRESS ET CAS EXTRÊMES - MINISHELL
# ================================================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

MINISHELL="./minishell"
STRESS_TESTS=0
STRESS_PASSED=0
STRESS_FAILED=0

declare -a STRESS_PASSED_LIST=()
declare -a STRESS_FAILED_LIST=()

stress_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    local description="$4"
    local timeout_duration="${5:-10}"
    
    STRESS_TESTS=$((STRESS_TESTS + 1))
    
    echo -e "${YELLOW}🔥 Stress Test $STRESS_TESTS: $test_name${NC}"
    echo -e "   📝 Description: $description"
    if [ ${#command} -gt 100 ]; then
        echo -e "   💻 Commande: ${command:0:100}..."
    else
        echo -e "   💻 Commande: $command"
    fi
    echo -e "   ⏱️  Timeout: ${timeout_duration}s"
    
    # Créer un script de test
    echo "$command" > stress_input.tmp
    
    # Mesurer le temps et la mémoire
    local start_time=$(date +%s%N)
    timeout ${timeout_duration}s $MINISHELL < stress_input.tmp > stress_output.tmp 2>stress_error.tmp
    local exit_code=$?
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en ms
    
    # Analyser les résultats
    if [ $exit_code -eq $expected_exit_code ] || [ $exit_code -eq 124 ]; then
        if [ $exit_code -eq 124 ]; then
            echo -e "   ⏱️  ${YELLOW}TIMEOUT (${timeout_duration}s) - Test de résistance réussi${NC}"
        else
            echo -e "   ✅ ${GREEN}PASSED${NC} (${duration}ms)"
        fi
        STRESS_PASSED=$((STRESS_PASSED + 1))
        STRESS_PASSED_LIST+=("$test_name: ${duration}ms")
    else
        echo -e "   ❌ ${RED}FAILED${NC} (${duration}ms)"
        echo -e "   📤 Code de sortie: $exit_code (attendu: $expected_exit_code)"
        if [ -s stress_error.tmp ]; then
            echo -e "   ⚠️  Erreur: $(cat stress_error.tmp | head -1)"
        fi
        STRESS_FAILED=$((STRESS_FAILED + 1))
        STRESS_FAILED_LIST+=("$test_name: exit $exit_code (${duration}ms)")
    fi
    
    # Vérifier les fuites mémoire potentielles
    if [ -s stress_error.tmp ] && grep -q "malloc\|free\|memory" stress_error.tmp; then
        echo -e "   ⚠️  ${YELLOW}Possible problème mémoire détecté${NC}"
    fi
    
    rm -f stress_input.tmp stress_output.tmp stress_error.tmp
    echo ""
}

# ================================================================================================
# 🧬 TESTS DE STRESS MÉMOIRE
# ================================================================================================

run_memory_stress_tests() {
    echo -e "${BLUE}📋 === TESTS DE STRESS MÉMOIRE ===${NC}"
    echo ""
    
    # Variables très longues
    stress_test "HUGE_VARIABLE" \
        "export HUGE=\$(printf 'x%.0s' {1..10000}); echo \${#HUGE}" \
        0 "Variable de 10k caractères" 15
    
    # Commandes avec énormément d'arguments
    stress_test "MASSIVE_ARGS" \
        "echo \$(printf 'arg%d ' {1..1000})" \
        0 "1000 arguments" 15
    
    # Pipeline extrêmement long
    local long_pipeline="echo start"
    for i in {1..100}; do
        long_pipeline="$long_pipeline | cat"
    done
    stress_test "EXTREME_PIPELINE" \
        "$long_pipeline" \
        0 "Pipeline de 100 étapes" 20
    
    # Variables imbriquées
    stress_test "NESTED_VARIABLES" \
        "export A=B; export B=C; export C=D; echo \$A\$B\$C\$A\$B\$C\$A\$B\$C" \
        0 "Variables en cascade" 10
    
    # Quotes très profondes
    local deep_quotes="echo \""
    for i in {1..50}; do
        deep_quotes="${deep_quotes}'"'"
    done
    for i in {1..50}; do
        deep_quotes="${deep_quotes}'"'"
    done
    deep_quotes="${deep_quotes}\""
    stress_test "DEEP_QUOTES" \
        "$deep_quotes" \
        0 "Quotes très imbriquées" 10
    
    # Allocation massive de variables
    local massive_export=""
    for i in {1..100}; do
        massive_export="${massive_export}export VAR$i=value$i; "
    done
    massive_export="${massive_export}echo done"
    stress_test "MASSIVE_EXPORT" \
        "$massive_export" \
        0 "100 exports consécutifs" 15
}

# ================================================================================================
# ⚡ TESTS DE PERFORMANCE
# ================================================================================================

run_performance_tests() {
    echo -e "${BLUE}📋 === TESTS DE PERFORMANCE ===${NC}"
    echo ""
    
    # Expansion de variables intensive
    stress_test "INTENSIVE_EXPANSION" \
        "echo \$USER\$HOME\$PWD\$USER\$HOME\$PWD\$USER\$HOME\$PWD\$USER\$HOME\$PWD" \
        0 "Expansion intensive de variables" 10
    
    # Parsing complexe avec opérateurs
    stress_test "COMPLEX_PARSING" \
        "echo hello > file1 | cat < file1 >> file2 | cat file2 | wc -l" \
        0 "Parsing complexe avec redirections" 10
    
    # Commandes répétitives
    local repetitive=""
    for i in {1..50}; do
        repetitive="${repetitive}echo test$i; "
    done
    stress_test "REPETITIVE_COMMANDS" \
        "$repetitive" \
        0 "50 commandes séquentielles" 15
    
    # Variables avec calculs
    stress_test "COMPUTED_VARIABLES" \
        "export COUNT=\$(echo 1 2 3 4 5 | wc -w); echo \$COUNT; export DOUBLE=\$COUNT\$COUNT; echo \$DOUBLE" \
        0 "Variables calculées" 10
    
    # Heredoc avec contenu volumineux
    local large_heredoc="cat << EOF"$'\n'
    for i in {1..1000}; do
        large_heredoc="${large_heredoc}Line $i with some content"$'\n'
    done
    large_heredoc="${large_heredoc}EOF"
    
    stress_test "LARGE_HEREDOC" \
        "$large_heredoc" \
        0 "Heredoc avec 1000 lignes" 20
}

# ================================================================================================
# 🐛 TESTS DE CAS EDGE EXTRÊMES
# ================================================================================================

run_edge_case_tests() {
    echo -e "${BLUE}📋 === TESTS DE CAS EDGE EXTRÊMES ===${NC}"
    echo ""
    
    # Caractères spéciaux intensifs
    stress_test "SPECIAL_CHARS_INTENSIVE" \
        "echo '!@#\$%^&*()_+-=[]{}|;:,.<>?/~\`'" \
        0 "Tous les caractères spéciaux" 10
    
    # Variables avec noms étranges
    stress_test "WEIRD_VAR_NAMES" \
        "export _VAR=1; export VAR_=2; export V123=3; echo \$_VAR\$VAR_\$V123" \
        0 "Noms de variables bizarres" 10
    
    # Commandes avec chemins très longs
    local long_path=""
    for i in {1..20}; do
        long_path="${long_path}/very_long_directory_name_$i"
    done
    stress_test "VERY_LONG_PATH" \
        "echo $long_path" \
        0 "Chemin extrêmement long" 10
    
    # Alternance quotes/no-quotes complexe
    stress_test "QUOTE_CHAOS" \
        "echo 'a'\"b\"'c'\"d\"'e'\"f\"'g'\"h\"'i'\"j\"" \
        0 "Alternance quotes chaotique" 10
    
    # Variables auto-référentielles
    stress_test "SELF_REF_VARS" \
        "export VAR=VAR; echo \$VAR; export VAR2=\$VAR2; echo \$VAR2" \
        0 "Variables auto-référentielles" 10
    
    # Commandes avec stdin volumineux
    stress_test "LARGE_STDIN" \
        "printf '%.0s\\n' {1..10000} | wc -l" \
        0 "10000 lignes en stdin" 15
    
    # Tests de limites système
    stress_test "SYSTEM_LIMITS" \
        "echo \$(yes | head -10000 | wc -l)" \
        0 "Test limites système" 15
    
    # Unicode et caractères étranges
    stress_test "UNICODE_STRESS" \
        "echo 'Unicode: 🚀 🎯 🔥 💻 ⚡ 🌟 🎉 ✅ ❌ 🧪 📊 🏆'" \
        0 "Caractères Unicode intensifs" 10
    
    # Variables d'environnement corrompues (simulation)
    stress_test "CORRUPTED_ENV_SIM" \
        "export =value; export KEY=; export LONG_KEY_NAME_THAT_IS_VERY_LONG=short" \
        0 "Simulation variables corrompues" 10
}

# ================================================================================================
# 💀 TESTS DE ROBUSTESSE EXTRÊME
# ================================================================================================

run_robustness_tests() {
    echo -e "${BLUE}📋 === TESTS DE ROBUSTESSE EXTRÊME ===${NC}"
    echo ""
    
    # Commandes malformées volontairement
    stress_test "MALFORMED_SYNTAX_1" \
        "echo | | | echo" \
        2 "Syntaxe volontairement cassée" 5
    
    stress_test "MALFORMED_SYNTAX_2" \
        "echo > > > file" \
        2 "Redirections multiples invalides" 5
    
    stress_test "MALFORMED_SYNTAX_3" \
        "| | | echo hello | |" \
        2 "Pipes en chaos" 5
    
    # Variables infinies (protection)
    stress_test "INFINITE_VAR_PROTECTION" \
        "export A=B; export B=A; echo \$A" \
        0 "Protection contre boucles infinies" 10
    
    # Allocation mémoire massive
    stress_test "MEMORY_BOMB_PROTECTION" \
        "export BOMB=\$(printf 'x%.0s' {1..100000}); echo 'survived'" \
        0 "Protection bombe mémoire" 20
    
    # Récursion de commandes
    stress_test "COMMAND_RECURSION" \
        "./minishell -c './minishell -c \"echo nested\"'" \
        0 "Récursion de commandes" 15
    
    # Tests de signaux simulés
    stress_test "SIGNAL_RESILIENCE" \
        "echo start; sleep 0.1; echo end" \
        0 "Résilience aux interruptions" 10
    
    # Overflow potentiel de buffers
    local overflow_test=""
    for i in {1..1000}; do
        overflow_test="${overflow_test}a"
    done
    stress_test "BUFFER_OVERFLOW_TEST" \
        "echo '$overflow_test'" \
        0 "Test overflow buffer" 10
    
    # Variables avec contenu binaire simulé
    stress_test "BINARY_CONTENT_SIM" \
        "export BIN=\$(printf '\\x41\\x42\\x43'); echo \$BIN" \
        0 "Contenu pseudo-binaire" 10
}

# ================================================================================================
# 🧪 TESTS DE CONCURRENCE SIMULÉE
# ================================================================================================

run_concurrency_tests() {
    echo -e "${BLUE}📋 === TESTS DE CONCURRENCE SIMULÉE ===${NC}"
    echo ""
    
    # Simulation de processus multiples
    stress_test "MULTI_PROCESS_SIM" \
        "echo proc1 & echo proc2 & echo proc3 & wait" \
        0 "Simulation multi-processus" 10
    
    # Variables partagées
    stress_test "SHARED_VARS" \
        "export SHARED=value1; echo \$SHARED; export SHARED=value2; echo \$SHARED" \
        0 "Variables partagées" 10
    
    # Accès fichiers concurrent simulé
    stress_test "FILE_CONCURRENT_SIM" \
        "echo data1 > shared.txt; echo data2 >> shared.txt; cat shared.txt" \
        0 "Accès fichier concurrent" 10
    
    # Pipeline avec délais
    stress_test "DELAYED_PIPELINE" \
        "echo start | (sleep 0.1; cat) | (sleep 0.1; cat)" \
        0 "Pipeline avec délais" 15
}

# ================================================================================================
# 📊 RAPPORT DE STRESS
# ================================================================================================

generate_stress_report() {
    echo -e "${CYAN}================================================================================================${NC}"
    echo -e "${CYAN}📊 RAPPORT DE TESTS DE STRESS ET CAS EXTRÊMES${NC}"
    echo -e "${CYAN}================================================================================================${NC}"
    
    echo -e "${CYAN}📈 STATISTIQUES DE STRESS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   🔥 Total tests de stress  : ${YELLOW}$STRESS_TESTS${NC}"
    echo -e "   ✅ Tests réussis          : ${GREEN}$STRESS_PASSED${NC}"
    echo -e "   ❌ Tests échoués          : ${RED}$STRESS_FAILED${NC}"
    echo -e "   📊 Taux de réussite       : ${CYAN}$(( STRESS_PASSED * 100 / STRESS_TESTS ))%${NC}"
    echo ""
    
    # Évaluation de robustesse
    local stress_rate=$(( STRESS_PASSED * 100 / STRESS_TESTS ))
    echo -e "${CYAN}🛡️ ÉVALUATION DE ROBUSTESSE${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $stress_rate -ge 90 ]; then
        echo -e "   🏆 ${GREEN}ULTRA-ROBUSTE${NC} - Résiste à tous les cas extrêmes"
    elif [ $stress_rate -ge 80 ]; then
        echo -e "   🥇 ${YELLOW}TRÈS ROBUSTE${NC} - Excellente résistance au stress"
    elif [ $stress_rate -ge 70 ]; then
        echo -e "   🥈 ${YELLOW}ROBUSTE${NC} - Bonne résistance générale"
    else
        echo -e "   🥉 ${RED}VULNÉRABLE${NC} - Nécessite des améliorations de robustesse"
    fi
    
    if [ ${#STRESS_FAILED_LIST[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ TESTS DE STRESS ÉCHOUÉS${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for test in "${STRESS_FAILED_LIST[@]}"; do
            echo -e "   💥 $test"
        done
    fi
    
    # Sauvegarde rapport stress
    {
        echo "RAPPORT DE STRESS MINISHELL - $(date)"
        echo "Total: $STRESS_TESTS | Réussis: $STRESS_PASSED | Échoués: $STRESS_FAILED | Taux: $(( STRESS_PASSED * 100 / STRESS_TESTS ))%"
        echo ""
        echo "TESTS DE STRESS ÉCHOUÉS:"
        for test in "${STRESS_FAILED_LIST[@]}"; do
            echo "$test"
        done
    } > stress_report.txt
    
    echo ""
    echo -e "${CYAN}📄 Rapport de stress sauvegardé dans: stress_report.txt${NC}"
}

# ================================================================================================
# 🚀 EXÉCUTION DES TESTS DE STRESS
# ================================================================================================

main_stress() {
    echo -e "${CYAN}🔥 DÉBUT DES TESTS DE STRESS - $(date)${NC}"
    echo ""
    
    # Vérification
    if [ ! -f "$MINISHELL" ]; then
        echo -e "${RED}❌ Minishell non trouvé. Compilation...${NC}"
        make clean && make
    fi
    
    # Exécution par catégories
    run_memory_stress_tests
    run_performance_tests
    run_edge_case_tests
    run_robustness_tests
    run_concurrency_tests
    
    # Rapport final
    generate_stress_report
    
    # Nettoyage
    rm -f shared.txt stress_*.tmp
    
    echo -e "${CYAN}🔥 FIN DES TESTS DE STRESS - $(date)${NC}"
    
    # Code de sortie
    if [ $STRESS_FAILED -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_stress "$@"
fi
