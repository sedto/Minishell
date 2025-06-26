#!/bin/bash

# ==================================================================================
# 🔥 NIVEAU 3: TESTS EXTRÊMES MINISHELL (PARSER/EXPANDER SEULEMENT)
# ==================================================================================
# Tests intensifs qui poussent le parser et l'expander dans leurs retranchements
# 
# ⚠️  IMPORTANT: Ces tests ne vérifient que le PARSING et l'EXPANSION
# ⚠️  Aucune exécution réelle de commandes n'est attendue (pas d'executor)
# ⚠️  Focus sur la robustesse du parser face aux cas extrêmes

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
RAPPORT_ERREURS="rapport_erreurs_extremes.md"

# Fonction pour tester la robustesse du parser sur des cas extrêmes
run_extreme_parsing_test() {
    local test_name="$1"
    local command="$2"
    local expected_behavior="$3"  # "no_crash", "SYNTAX_ERROR", "PARSE_OK"
    local description="$4"
    local timeout_duration="${5:-5}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test Extrême $TOTAL_TESTS: $test_name${NC}"
    echo -e "  Commande: ${YELLOW}${command:0:100}...${NC}" # Limiter l'affichage
    
    # Mesurer le temps d'exécution
    start_time=$(date +%s.%N)
    
    # Créer des fichiers temporaires pour captures
    local output_file="/tmp/minishell_extreme_output_$$"
    local error_file="/tmp/minishell_extreme_error_$$"
    
    # Exécuter avec timeout pour les tests extrêmes
    echo "$command" | timeout "$timeout_duration" ./minishell > "$output_file" 2> "$error_file"
    actual_exit=$?
    
    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "N/A")
    
    # Lire les sorties
    local output=$(cat "$output_file" 2>/dev/null || echo "")
    local error_output=$(cat "$error_file" 2>/dev/null || echo "")
    
    # Nettoyer les fichiers temporaires
    rm -f "$output_file" "$error_file"
    
    # Analyser le résultat selon le comportement attendu
    local test_passed=false
    local result_description=""
    
    case "$expected_behavior" in
        "no_crash")
            # Ne doit pas crasher même sur des entrées extrêmes
            if [ "$actual_exit" -ne 139 ] && [ "$actual_exit" -ne 124 ] && [ "$actual_exit" -ne 11 ]; then
                test_passed=true
                result_description="Pas de crash (exit: $actual_exit, temps: ${execution_time}s)"
            else
                result_description="Crash détecté (exit: $actual_exit, temps: ${execution_time}s)"
            fi
            ;;
        "SYNTAX_ERROR")
            # Doit détecter l'erreur de syntaxe
            if [ "$actual_exit" -eq 2 ] || [[ "$error_output" == *"syntax"* ]] || [[ "$error_output" == *"parse"* ]]; then
                test_passed=true
                result_description="Erreur de syntaxe détectée (exit: $actual_exit)"
            else
                result_description="Erreur de syntaxe non détectée (exit: $actual_exit)"
            fi
            ;;
        "PARSE_OK")
            # Parsing doit réussir
            if [ "$actual_exit" -eq 0 ] || [ "$actual_exit" -eq 1 ]; then
                test_passed=true
                result_description="Parsing réussi (exit: $actual_exit, temps: ${execution_time}s)"
            else
                result_description="Échec du parsing (exit: $actual_exit)"
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
            echo "## Erreur Test Extrême $TOTAL_TESTS: $test_name"
            echo "**Description:** $description"
            echo "**Commande:** \`${command:0:200}...\`"
            echo "**Comportement attendu:** $expected_behavior"
            echo "**Exit code reçu:** $actual_exit"
            echo "**Temps d'exécution:** ${execution_time}s"
            echo "**Résultat:** $result_description"
            echo "**Sortie:** \`${output:0:500}...\`"
            echo "**Erreurs:** \`${error_output:0:500}...\`"
            echo "**Catégorie:** Tests extrêmes (parser/expander)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
}

# Fonction pour générer des chaînes de test massives
generate_massive_string() {
    local pattern="$1"
    local count="$2"
    printf "${pattern}%.0s" $(seq 1 "$count")
}

# Fonction pour test de stress mémoire (robustesse parser)
run_memory_stress_test() {
    local test_name="$1"
    local command="$2"
    local description="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test Stress Mémoire $TOTAL_TESTS: $test_name${NC}"
    
    # Exécuter le test avec timeout court pour éviter les hangs
    echo "$command" | timeout 10s ./minishell > /dev/null 2>&1
    exit_code=$?
    
    # Test réussi si pas de crash majeur
    if [ "$exit_code" -ne 139 ] && [ "$exit_code" -ne 124 ] && [ "$exit_code" -ne 11 ]; then
        echo -e "  ${GREEN}✅ RÉUSSI${NC} (Pas de crash, exit: $exit_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ ÉCHOUÉ${NC} (Crash détecté, exit: $exit_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        {
            echo "## Erreur Test Stress Mémoire $TOTAL_TESTS: $test_name"
            echo "**Description:** $description"
            echo "**Exit code:** $exit_code"
            echo "**Catégorie:** Tests extrêmes (stress mémoire parser)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Initialiser le rapport d'erreurs
echo "# 🔥 RAPPORT D'ERREURS - TESTS EXTRÊMES" > "$RAPPORT_ERREURS"
echo "Date: $(date)" >> "$RAPPORT_ERREURS"
echo "Système: $(uname -a)" >> "$RAPPORT_ERREURS"
echo "" >> "$RAPPORT_ERREURS"

echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}🔥 NIVEAU 3: TESTS EXTRÊMES MINISHELL${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

# ==================================================================================
# 🌊 SECTION 1: SURCHARGE MASSIVE DE VARIABLES (EXPANSION)
# ==================================================================================
echo -e "${PURPLE}🌊 Section 1: Surcharge massive de variables${NC}"
echo "────────────────────────────────────────────────"

# Test avec énormément de variables
massive_vars=""
for i in {1..50}; do
    massive_vars="${massive_vars}\$VAR$i "
done
run_extreme_parsing_test "50 variables inexistantes" "echo $massive_vars" "no_crash" "Test avec 50 variables inexistantes"

# Variables concaténées massivement
concat_vars=""
for i in {1..30}; do
    concat_vars="${concat_vars}\$VAR$i"
done
run_extreme_parsing_test "30 variables concaténées" "echo $concat_vars" "no_crash" "Variables collées sans espaces"

# Variables avec des noms très longs
long_var_name=$(generate_massive_string "A" 100)
run_extreme_parsing_test "Variable nom très long" "echo \$$long_var_name" "no_crash" "Variable avec nom de 100 caractères"

# ==================================================================================
# 🎭 SECTION 2: QUOTES EXTREMES (PARSING)
# ==================================================================================
echo -e "${PURPLE}🎭 Section 2: Gestion extrême des quotes${NC}"
echo "─────────────────────────────────────────────"

# Quotes très longues
long_quote_content=$(generate_massive_string "test " 200)
run_extreme_parsing_test "Quote simple très longue" "echo '$long_quote_content'" "no_crash" "Quote simple avec 1000+ caractères"

# Quote double très longue avec variables
long_quote_with_vars="\"$long_quote_content \$USER \$HOME\""
run_extreme_parsing_test "Quote double longue + variables" "echo $long_quote_with_vars" "no_crash" "Quote double longue avec variables"

# Quotes imbriquées complexes
complex_quotes="echo 'test \"inner quote\" with \$VAR' \"outer quote 'inner single' end\""
run_extreme_parsing_test "Quotes complexes imbriquées" "$complex_quotes" "no_crash" "Quotes simples et doubles mélangées"

# ==================================================================================
# ⚠️ SECTION 3: ERREURS DE SYNTAXE EXTREMES
# ==================================================================================
echo -e "${PURPLE}⚠️ Section 3: Erreurs de syntaxe extrêmes${NC}"
echo "─────────────────────────────────────────────"

# Pipes multiples en chaîne
pipe_chain=""
for i in {1..20}; do
    pipe_chain="${pipe_chain} |"
done
run_extreme_parsing_test "20 pipes consécutifs" "echo hello$pipe_chain" "SYNTAX_ERROR" "Chaîne de 20 pipes"

# Redirections multiples impossibles
redir_chain=""
for i in {1..15}; do
    redir_chain="${redir_chain} >"
done
run_extreme_parsing_test "15 redirections >>" "echo hello$redir_chain" "SYNTAX_ERROR" "15 redirections output consécutives"

# Quote non fermée avec contenu massif
massive_unclosed_quote="echo 'cette quote n est jamais fermee $(generate_massive_string "content " 100)"
run_extreme_parsing_test "Quote non fermée massive" "$massive_unclosed_quote" "SYNTAX_ERROR" "Quote simple non fermée avec beaucoup de contenu"

# ==================================================================================
# 🔄 SECTION 4: REDIRECTIONS EXTREMES (PARSING SEULEMENT)
# ==================================================================================
echo -e "${PURPLE}🔄 Section 4: Redirections extrêmes${NC}"
echo "───────────────────────────────────────────"

run_extreme_parsing_test "Redirection fichier volumineux" "cat < /tmp/large_test_file.txt > /tmp/output_large.txt" "PARSE_OK" "Parsing redirection d'un gros fichier"

# Nom de fichier très long
long_filename="/tmp/$(generate_massive_string "a" 200).txt"
run_extreme_parsing_test "Nom fichier très long" "echo test > $long_filename" "PARSE_OK" "Parsing redirection vers fichier au nom très long"

# ==================================================================================
# 🌟 SECTION 5: CARACTERES SPECIAUX EXTREMES
# ==================================================================================
echo -e "${PURPLE}🌟 Section 5: Caractères spéciaux extrêmes${NC}"
echo "──────────────────────────────────────────────"

# Tous les caractères spéciaux
special_chars="!@#\$%^&*()_+-=[]{}|;:,.<>?/~\`"
run_extreme_parsing_test "Tous caractères spéciaux" "echo '$special_chars'" "PARSE_OK" "Tous les caractères spéciaux protégés"

# Caractères unicode/UTF-8 
unicode_test="echo 'Café 🚀 résumé naïve'"
run_extreme_parsing_test "Caractères Unicode" "$unicode_test" "PARSE_OK" "Caractères accentués et emojis"

# Séquences d'échappement
escape_sequences="echo 'test\\n\\t\\r\\\\'"
run_extreme_parsing_test "Séquences échappement" "$escape_sequences" "PARSE_OK" "Backslashes et séquences d'échappement"

# ==================================================================================
# 💾 SECTION 6: STRESS MEMOIRE INTENSE
# ==================================================================================
echo -e "${PURPLE}💾 Section 6: Stress mémoire intense${NC}"
echo "────────────────────────────────────────"

# Commande extrêmement longue
ultra_long_command="echo $(generate_massive_string "mot " 1000)"
run_memory_stress_test "Commande ultra-longue" "$ultra_long_command" "Commande avec 4000+ caractères"

# Variables nombreuses avec contenu
many_vars_command=""
for i in {1..100}; do
    many_vars_command="${many_vars_command}echo \$VAR$i; "
done
run_memory_stress_test "100 commandes variables" "$many_vars_command" "100 échos de variables différentes"

# Expansion massive
expansion_test="echo $(generate_massive_string '\$USER' 200)"
run_memory_stress_test "Expansion massive" "$expansion_test" "200 expansions de la même variable"

# ==================================================================================
# 🎲 SECTION 7: CAS LIMITES EXTREMES
# ==================================================================================
echo -e "${PURPLE}🎲 Section 7: Cas limites extrêmes${NC}"
echo "──────────────────────────────────────"

# Ligne vide avec beaucoup d'espaces
many_spaces="$(generate_massive_string " " 500)"
run_extreme_parsing_test "500 espaces" "$many_spaces" "PARSE_OK" "Ligne avec 500 espaces"

# Tabulations multiples
many_tabs="$(generate_massive_string "	" 100)"
run_extreme_parsing_test "100 tabulations" "${many_tabs}echo hello" "PARSE_OK" "Commande précédée de 100 tabs"

# Variables avec nombres
numbered_vars=""
for i in {1..50}; do
    numbered_vars="${numbered_vars}\$${i}VAR "
done
run_extreme_parsing_test "Variables numérotées" "echo $numbered_vars" "PARSE_OK" "50 variables commençant par un chiffre"

# ==================================================================================
# 🔧 SECTION 8: ROBUSTESSE EXTREME
# ==================================================================================
echo -e "${PURPLE}🔧 Section 8: Robustesse extrême${NC}"
echo "──────────────────────────────────────"

# Test avec entrée binaire simulée
binary_like="echo $(printf '\x00\x01\x02\x03\x04\x05')"
run_extreme_parsing_test "Caractères binaires" "$binary_like" "no_crash" "Caractères de contrôle binaires"

# Combinaison de tous les problèmes
nightmare_command="echo 'quote $(generate_massive_string '\$VAR' 50) not closed"
run_extreme_parsing_test "Cauchemar parsing" "$nightmare_command" "SYNTAX_ERROR" "Combinaison: quote non fermée + variables multiples"

# Récursion simulée dans l'expansion
recursive_like=""
for i in {1..20}; do
    recursive_like="${recursive_like}\$VAR\$USER"
done
run_extreme_parsing_test "Pseudo-récursion variables" "echo $recursive_like" "no_crash" "Variables imbriquées simulant une récursion"

# ==================================================================================
# ⚡ SECTION 9: PERFORMANCE EXTREME (PARSING)
# ==================================================================================
echo -e "${PURPLE}⚡ Section 9: Tests de performance extrême${NC}"
echo "──────────────────────────────────────────────"

# Test de vitesse avec commande simple répétée
simple_repeated=""
for i in {1..1000}; do
    simple_repeated="${simple_repeated}echo $i; "
done
run_extreme_parsing_test "1000 échos simples" "$simple_repeated" "no_crash" "1000 commandes echo numérotées (parsing seulement)"

# Variables multiples répétées
vars_repeated=""
for i in {1..500}; do
    vars_repeated="${vars_repeated}echo \$USER; "
done
run_extreme_parsing_test "500 expansions USER" "$vars_repeated" "no_crash" "500 expansions de \$USER"

# ==================================================================================
# 🧨 SECTION 10: CHAOS TOTAL (PARSER SEULEMENT)
# ==================================================================================
echo -e "${PURPLE}🧨 Section 10: Chaos total${NC}"
echo "─────────────────────────────"

# Le test ultime : tout mélangé
chaos_command="echo 'test $(generate_massive_string '\$VAR' 20) with' \"double quotes \$USER\" | | > && 'unclosed"
run_extreme_parsing_test "CHAOS TOTAL" "$chaos_command" "SYNTAX_ERROR" "Mélange de tous les problèmes possibles"

# Stress test final avec timeout court
final_stress="$(generate_massive_string 'echo hello; ' 200)"
run_extreme_parsing_test "Stress final" "$final_stress" "no_crash" "200 commandes echo en séquence (parsing)"

# ==================================================================================
# 📊 RÉSULTATS FINAUX
# ==================================================================================
echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}📊 RÉSULTATS TESTS EXTRÊMES${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

echo -e "${BOLD}Total des tests:${NC} $TOTAL_TESTS"
echo -e "${BOLD}${GREEN}Tests réussis:${NC} $PASSED_TESTS"
echo -e "${BOLD}${RED}Tests échoués:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🎉 TOUS LES TESTS EXTRÊMES SONT RÉUSSIS !${NC}"
    echo -e "${BOLD}${GREEN}🏆 VOTRE MINISHELL EST ULTRA-ROBUSTE !${NC}"
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
    echo "## 📊 Résumé des Tests Extrêmes"
    echo "- **Total des tests:** $TOTAL_TESTS"
    echo "- **Tests réussis:** $PASSED_TESTS"
    echo "- **Tests échoués:** $FAILED_TESTS"
    echo "- **Taux de réussite:** ${success_rate}%"
    echo ""
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🎉 **TOUS LES TESTS EXTRÊMES SONT RÉUSSIS !**"
        echo "🏆 **VOTRE MINISHELL EST ULTRA-ROBUSTE !**"
    else
        echo "❌ **Des erreurs ont été détectées dans les tests extrêmes.**"
    fi
    echo ""
    echo "### Sections testées:"
    echo "1. 🌊 Surcharge massive de variables"
    echo "2. 🎭 Gestion extrême des quotes"
    echo "3. ⚠️ Erreurs de syntaxe extrêmes"
    echo "4. 🔄 Redirections extrêmes"
    echo "5. 🌟 Caractères spéciaux extrêmes"
    echo "6. 💾 Stress mémoire intense"
    echo "7. 🎲 Cas limites extrêmes"
    echo "8. 🔧 Robustesse extrême"
    echo "9. ⚡ Tests de performance extrême"
    echo "10. 🧨 Chaos total"
} >> "$RAPPORT_ERREURS"

exit $FAILED_TESTS
