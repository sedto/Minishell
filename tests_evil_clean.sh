#!/bin/bash

# ==================================================================================
# 💀 NIVEAU 4: TESTS EVIL MINISHELL (PARSER/EXPANDER SEULEMENT)
# ==================================================================================
# Tests malveillants conçus pour tester la robustesse du parser/expander
# 
# ⚠️  IMPORTANT: Ces tests ne vérifient que le PARSING et l'EXPANSION
# ⚠️  Aucune exécution réelle de commandes n'est attendue (pas d'executor)
# ⚠️  Focus sur la sécurité et robustesse du parser face aux attaques

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
RAPPORT_ERREURS="rapport_erreurs_evil.md"

# Fonction pour tester la sécurité du parser face aux entrées malveillantes
run_evil_parsing_test() {
    local test_name="$1"
    local command="$2"
    local expected_behavior="$3"  # "no_crash", "syntax_error", "security_safe"
    local description="$4"
    local timeout_duration="${5:-10}"
    local severity="${6:-HIGH}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}💀 Test Evil $TOTAL_TESTS: $test_name${NC}"
    echo -e "  Severity: ${RED}$severity${NC}"
    echo -e "  Command: ${YELLOW}${command:0:80}...${NC}"
    
    # Mesurer le temps
    local start_time=$(date +%s.%N)
    
    # Créer des fichiers temporaires pour surveillance
    local output_file="/tmp/minishell_evil_output_$$"
    local error_file="/tmp/minishell_evil_error_$$"
    
    # Exécuter avec timeout strict pour les tests evil
    echo "$command" | timeout "$timeout_duration" ./minishell > "$output_file" 2> "$error_file"
    local actual_exit=$?
    
    local end_time=$(date +%s.%N)
    local execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "N/A")
    
    # Lire les sorties
    local output=$(cat "$output_file" 2>/dev/null || echo "")
    local error_output=$(cat "$error_file" 2>/dev/null || echo "")
    
    # Nettoyer les fichiers temporaires
    rm -f "$output_file" "$error_file"
    
    # Analyser le résultat selon le comportement attendu
    local test_passed=false
    local result_description=""
    local security_issue=""
    
    case "$expected_behavior" in
        "no_crash")
            # Ne doit absolument pas crasher malgré l'input malveillant
            if [ "$actual_exit" -ne 139 ] && [ "$actual_exit" -ne 124 ] && [ "$actual_exit" -ne 11 ]; then
                test_passed=true
                result_description="Résistance au crash (exit: $actual_exit, temps: ${execution_time}s)"
            else
                result_description="VULNÉRABILITÉ: Crash causé par input malveillant (exit: $actual_exit)"
                security_issue="CRITICAL"
            fi
            ;;
        "syntax_error")
            # Doit détecter et rejeter l'input malveillant
            if [ "$actual_exit" -eq 2 ] || [[ "$error_output" == *"syntax"* ]] || [[ "$error_output" == *"parse"* ]]; then
                test_passed=true
                result_description="Input malveillant correctement rejeté"
            else
                result_description="VULNÉRABILITÉ: Input malveillant non détecté (exit: $actual_exit)"
                security_issue="HIGH"
            fi
            ;;
        "security_safe")
            # Test de sécurité général : pas de crash ET comportement sûr
            if [ "$actual_exit" -ne 139 ] && [ "$actual_exit" -ne 124 ] && [ "$actual_exit" -ne 11 ]; then
                # Vérifier qu'il n'y a pas de comportement suspect dans la sortie
                if [[ ! "$output" == *"segmentation"* ]] && [[ ! "$error_output" == *"buffer overflow"* ]]; then
                    test_passed=true
                    result_description="Comportement sécurisé (exit: $actual_exit)"
                else
                    result_description="VULNÉRABILITÉ: Comportement suspect détecté"
                    security_issue="HIGH"
                fi
            else
                result_description="VULNÉRABILITÉ: Crash sécuritaire (exit: $actual_exit)"
                security_issue="CRITICAL"
            fi
            ;;
    esac
    
    # Afficher le résultat avec indicateur de sécurité
    if [ "$test_passed" = true ]; then
        echo -e "  ${GREEN}✅ SÉCURISÉ${NC} ($result_description)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}🚨 VULNÉRABILITÉ${NC} ($result_description)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs avec niveau de sécurité
        {
            echo "## 🚨 VULNÉRABILITÉ Test Evil $TOTAL_TESTS: $test_name"
            echo "**Niveau de sécurité:** $security_issue"
            echo "**Sévérité:** $severity"
            echo "**Description:** $description"
            echo "**Commande:** \`${command:0:200}...\`"
            echo "**Comportement attendu:** $expected_behavior"
            echo "**Exit code reçu:** $actual_exit"
            echo "**Temps d'exécution:** ${execution_time}s"
            echo "**Résultat:** $result_description"
            echo "**Sortie:** \`${output:0:500}...\`"
            echo "**Erreurs:** \`${error_output:0:500}...\`"
            echo "**Catégorie:** Tests evil (sécurité parser/expander)"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Initialiser le rapport d'erreurs de sécurité
echo "# 💀 RAPPORT D'ERREURS - TESTS EVIL (SÉCURITÉ PARSER/EXPANDER)" > "$RAPPORT_ERREURS"
echo "Date: $(date)" >> "$RAPPORT_ERREURS"
echo "Système: $(uname -a)" >> "$RAPPORT_ERREURS"
echo "**ATTENTION:** Ce rapport concerne la sécurité du parser/expander uniquement" >> "$RAPPORT_ERREURS"
echo "Les tests vérifient la robustesse face aux entrées malveillantes" >> "$RAPPORT_ERREURS"
echo "" >> "$RAPPORT_ERREURS"

echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}💀 NIVEAU 4: TESTS EVIL MINISHELL (SÉCURITÉ)${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

# ==================================================================================
# 🧨 SECTION 1: BUFFER OVERFLOW ATTACKS (PARSER SEULEMENT)
# ==================================================================================
echo -e "${PURPLE}🧨 Section 1: Attaques par débordement de buffer${NC}"
echo "──────────────────────────────────────────────────────"

# Test classique de buffer overflow sur le parser
buffer_overflow_1k=$(printf 'A%.0s' {1..1000})
run_evil_parsing_test "Buffer Overflow 1K" "echo '$buffer_overflow_1k'" "no_crash" "Buffer overflow avec 1000 caractères A sur parser" 10 "CRITICAL"

# Buffer overflow dans les variables d'expansion
buffer_overflow_var="echo \$(printf 'A%.0s' {1..2000})"
run_evil_parsing_test "Buffer Overflow Variable" "$buffer_overflow_var" "no_crash" "Overflow via expansion de variable" 10 "CRITICAL"

# Buffer overflow dans les quotes
massive_quote="echo '$(printf 'A%.0s' {1..5000})'"
run_evil_parsing_test "Buffer Overflow Quotes" "$massive_quote" "no_crash" "Overflow dans quotes avec 5000 chars" 15 "CRITICAL"

# ==================================================================================
# 🎭 SECTION 2: FORMAT STRING ATTACKS (PARSING)
# ==================================================================================
echo -e "${PURPLE}🎭 Section 2: Attaques format string${NC}"
echo "───────────────────────────────────────────"

# Format string classique dans le parsing
format_string=$(printf '%%s%%p%%x%%n%.0s' {1..20})
run_evil_parsing_test "Format String Attack" "echo '$format_string'" "no_crash" "Attaque format string avec %s%p%x%n" 10 "HIGH"

# Format string dans variables
run_evil_parsing_test "Format String in Var" "echo \"\$USER %s %p %x %n\"" "no_crash" "Format string mélangé avec variables" 10 "HIGH"

# ==================================================================================
# 🔄 SECTION 3: INJECTION D'EXECUTION (PARSING SEULEMENT)
# ==================================================================================
echo -e "${PURPLE}🔄 Section 3: Tentatives d'injection${NC}"
echo "────────────────────────────────────────────"

# Tentative d'injection de commande - parser doit détecter ou résister
command_injection="echo 'test'; rm -rf /tmp/evil_test; echo 'done'"
run_evil_parsing_test "Command Injection" "$command_injection" "security_safe" "Tentative d'injection de commande rm (parsing)" 10 "CRITICAL"

# Injection via variables - tester l'expansion sécurisée
var_injection="echo \$USER; cat /etc/passwd; echo done"
run_evil_parsing_test "Variable Injection" "$var_injection" "security_safe" "Injection via séparateur de commandes (parsing)" 10 "CRITICAL"

# Tentative d'échappement de quotes - parser doit gérer correctement
quote_escape="echo 'test'; /bin/sh -c 'echo pwned'; echo 'end'"
run_evil_parsing_test "Quote Escape Injection" "$quote_escape" "security_safe" "Échappement quotes + exécution shell (parsing)" 10 "CRITICAL"

# ==================================================================================
# 🌊 SECTION 4: DENIAL OF SERVICE (PARSER)
# ==================================================================================
echo -e "${PURPLE}🌊 Section 4: Déni de service${NC}"
echo "─────────────────────────────────────"

# Récursion dans l'expansion de variables
recursion_bomb=""
for i in {1..1000}; do
    recursion_bomb="${recursion_bomb}\$VAR$i"
done
run_evil_parsing_test "Variable Bomb" "$recursion_bomb" "no_crash" "1000 expansions de variables" 20 "HIGH"

# Allocation mémoire massive via parsing
memory_bomb="echo '$(printf 'MEMORY_BOMB%.0s' {1..10000})'"
run_evil_parsing_test "Memory Bomb" "$memory_bomb" "no_crash" "Allocation massive de mémoire" 15 "HIGH"

# Simulation de fork bomb (parsing seulement)
fake_fork_bomb="echo 'bomb() { bomb | bomb & }; bomb'"
run_evil_parsing_test "Fake Fork Bomb" "$fake_fork_bomb" "no_crash" "Simulation de fork bomb" 20 "MEDIUM"

# ==================================================================================
# 🔐 SECTION 5: PRIVILEGE ESCALATION (PARSING)
# ==================================================================================
echo -e "${PURPLE}🔐 Section 5: Escalade de privilèges${NC}"
echo "─────────────────────────────────────"

# Tentative d'accès à des fichiers sensibles
sensitive_files="echo \$HOME; cat /etc/shadow; echo done"
run_evil_parsing_test "Sensitive File Access" "$sensitive_files" "security_safe" "Tentative lecture /etc/shadow" 10 "CRITICAL"

# Manipulation de PATH
path_manipulation="echo \$PATH; export PATH=/tmp:\$PATH; echo hacked"
run_evil_parsing_test "PATH Manipulation" "$path_manipulation" "security_safe" "Manipulation variable PATH" 10 "HIGH"

# Exécution de binaires système
system_binary="echo test; /usr/bin/id; echo done"
run_evil_parsing_test "System Binary Exec" "$system_binary" "security_safe" "Exécution binaire système" 10 "HIGH"

# ==================================================================================
# 💀 SECTION 6: NULL BYTES ET CONTROLE
# ==================================================================================
echo -e "${PURPLE}💀 Section 6: Octets null et caractères de contrôle${NC}"
echo "────────────────────────────────────────────────────"

# Injection d'octets null
null_injection="echo 'test$(printf '\x00')hidden'"
run_evil_parsing_test "Null Byte Injection" "$null_injection" "no_crash" "Injection d'octets null" 10 "MEDIUM"

# Caractères de contrôle
control_chars=$(printf '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0b\x0c\x0e\x0f')
run_evil_parsing_test "Control Characters" "echo '$control_chars'" "no_crash" "Caractères de contrôle ASCII" 10 "MEDIUM"

# Séquences ANSI malveillantes
ansi_evil="echo '\x1b[2J\x1b[H\x1b[31mHACKED\x1b[0m'"
run_evil_parsing_test "ANSI Escape Evil" "$ansi_evil" "no_crash" "Séquences ANSI malveillantes" 10 "LOW"

# ==================================================================================
# 🌍 SECTION 7: UNICODE ET ENCODAGE
# ==================================================================================
echo -e "${PURPLE}🌍 Section 7: Attaques Unicode et encodage${NC}"
echo "──────────────────────────────────────────────"

# Bombe Unicode
unicode_bomb="$(printf '\u202e%.0s' {1..100})\u202d"
run_evil_parsing_test "Unicode Bomb" "echo '$unicode_bomb'" "no_crash" "Bombe avec caractères Unicode" 15 "MEDIUM"

# Caractères de direction Unicode
unicode_direction="echo '\u202e\u202d\u202a\u202b\u202c'"
run_evil_parsing_test "Unicode Direction" "$unicode_direction" "no_crash" "Caractères de direction Unicode" 10 "LOW"

# Encodage UTF-8 overlong
overlong_utf8="echo '$(printf '\xc0\x80\xc1\x81')'"
run_evil_parsing_test "Overlong UTF-8" "$overlong_utf8" "no_crash" "Encodage UTF-8 overlong" 10 "MEDIUM"

# ==================================================================================
# 🧠 SECTION 8: LOGIQUE MALVEILLANTE
# ==================================================================================
echo -e "${PURPLE}🧠 Section 8: Logique malveillante${NC}"
echo "──────────────────────────────────────"

# Simulation de boucle infinie dans le parsing
infinite_loop_sim=""
for i in {1..100}; do
    infinite_loop_sim="${infinite_loop_sim}echo 'loop$i'; "
done
run_evil_parsing_test "Infinite Loop Simulation" "$infinite_loop_sim" "no_crash" "Simulation boucle infinie" 25 "HIGH"

# Variables récursives
recursive_var="\$A\$B\$A\$B\$A\$B\$A\$B\$A\$B"
run_evil_parsing_test "Variable Recursion" "$recursive_var" "no_crash" "Variables imbriquées récursivement" 10 "MEDIUM"

# ==================================================================================
# 🔥 SECTION 9: RACE CONDITIONS (PARSING)
# ==================================================================================
echo -e "${PURPLE}🔥 Section 9: Conditions de course${NC}"
echo "──────────────────────────────────────"

# Race condition sur fichiers
race_condition="echo test > /tmp/race_file && cat /tmp/race_file"
run_evil_parsing_test "File Race Condition" "$race_condition" "no_crash" "Race condition sur fichiers" 10 "MEDIUM"

# Race sur variables d'environnement
env_race="export TEST_VAR=value1; echo \$TEST_VAR; export TEST_VAR=value2"
run_evil_parsing_test "Environment Race" "$env_race" "no_crash" "Race sur variables d'environnement" 15 "MEDIUM"

# ==================================================================================
# 💥 SECTION 10: CHAOS EVIL FINAL
# ==================================================================================
echo -e "${PURPLE}💥 Section 10: Chaos evil final${NC}"
echo "─────────────────────────────────"

# Test ultime combinant tous les problèmes
ultimate_evil="echo '$(printf 'A%.0s' {1..500})'; \$USER; cat /etc/passwd; echo 'done'"
run_evil_parsing_test "ULTIMATE EVIL TEST" "$ultimate_evil" "syntax_error" "Combinaison de toutes les attaques" 20 "MAXIMUM"

# Test final de résistance
final_resistance="$(printf 'echo evil%.0s; ' {1..200})"
run_evil_parsing_test "Final Resistance Test" "$final_resistance" "no_crash" "Test de résistance finale" 25 "CRITICAL"

# ==================================================================================
# 📊 RÉSULTATS FINAUX
# ==================================================================================
echo -e "${BOLD}${BLUE}================================================${NC}"
echo -e "${BOLD}${BLUE}📊 RÉSULTATS TESTS EVIL (SÉCURITÉ)${NC}"
echo -e "${BOLD}${BLUE}================================================${NC}"
echo ""

echo -e "${BOLD}Total des tests:${NC} $TOTAL_TESTS"
echo -e "${BOLD}${GREEN}Tests sécurisés:${NC} $PASSED_TESTS"
echo -e "${BOLD}${RED}Vulnérabilités détectées:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🛡️ VOTRE PARSER EST ULTRA-SÉCURISÉ !${NC}"
    echo -e "${BOLD}${GREEN}🏆 AUCUNE VULNÉRABILITÉ DÉTECTÉE !${NC}"
    success_rate=100
else
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${BOLD}${YELLOW}📋 Taux de sécurité: ${success_rate}%${NC}"
    echo -e "${BOLD}${RED}🚨 Voir le rapport de sécurité: $RAPPORT_ERREURS${NC}"
fi

echo ""
echo -e "${CYAN}Fichier de rapport généré: $RAPPORT_ERREURS${NC}"

# Compléter le rapport avec les résultats finaux
{
    echo "---"
    echo ""
    echo "## 📊 Résumé des Tests Evil (Sécurité)"
    echo "- **Total des tests:** $TOTAL_TESTS"
    echo "- **Tests sécurisés:** $PASSED_TESTS"
    echo "- **Vulnérabilités détectées:** $FAILED_TESTS"
    echo "- **Taux de sécurité:** ${success_rate}%"
    echo ""
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🛡️ **VOTRE PARSER EST ULTRA-SÉCURISÉ !**"
        echo "🏆 **AUCUNE VULNÉRABILITÉ DÉTECTÉE !**"
    else
        echo "🚨 **Des vulnérabilités ont été détectées dans le parser/expander.**"
        echo "⚠️ **Vérifiez le rapport de sécurité pour les détails.**"
    fi
    echo ""
    echo "### Sections de sécurité testées:"
    echo "1. 🧨 Attaques par débordement de buffer"
    echo "2. 🎭 Attaques format string"
    echo "3. 🔄 Injection d'exécution"
    echo "4. 🌊 Déni de service"
    echo "5. 🔐 Escalade de privilèges"
    echo "6. 💀 Octets null et caractères de contrôle"
    echo "7. 🌍 Attaques Unicode et encodage"
    echo "8. 🧠 Logique malveillante"
    echo "9. 🔥 Conditions de course"
    echo "10. 💥 Chaos evil final"
} >> "$RAPPORT_ERREURS"

exit $FAILED_TESTS
