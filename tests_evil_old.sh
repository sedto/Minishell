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
    local strace_file="/tmp/minishell_evil_strace_$$"
    
    # Exécuter avec surveillance strace si disponible
    if command -v strace >/dev/null 2>&1; then
        # Avec strace pour détecter les appels système dangereux
        echo "$command" | timeout "$timeout_duration" strace -o "$strace_file" -e trace=write,read,open,execve,mmap,brk ./minishell > "$output_file" 2> "$error_file"
    else
        # Sans strace
        echo "$command" | timeout "$timeout_duration" ./minishell > "$output_file" 2> "$error_file"
    fi
    
    local actual_exit=$?
    local end_time=$(date +%s.%N)
    local execution_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    # Surveillance système après
    local mem_after=$(free -m | awk 'NR==2{printf "%d", $3}')
    local mem_diff=$((mem_after - mem_before))
    
    # Lire les résultats
    local output=$(cat "$output_file" 2>/dev/null || echo "")
    local error_output=$(cat "$error_file" 2>/dev/null || echo "")
    local strace_output=$(cat "$strace_file" 2>/dev/null || echo "")
    
    # Analyser les appels système suspects
    local suspicious_calls=""
    if [ -f "$strace_file" ]; then
        # Chercher des patterns suspects
        if grep -q "execve.*sh" "$strace_file"; then
            suspicious_calls="$suspicious_calls SHELL_EXEC"
        fi
        if grep -q "write.*AAAA" "$strace_file"; then
            suspicious_calls="$suspicious_calls BUFFER_OVERFLOW"
        fi
        if grep -q "mmap.*PROT_EXEC" "$strace_file"; then
            suspicious_calls="$suspicious_calls EXEC_MEMORY"
        fi
    fi
    
    # Nettoyer les fichiers
    rm -f "$output_file" "$error_file" "$strace_file"
    
    # Analyser le comportement
    local test_passed=false
    local failure_reason=""
    
    case "$expected_behavior" in
        "no_crash")
            if [ "$actual_exit" -ne 139 ] && [ "$actual_exit" -ne 124 ] && [ "$actual_exit" -ne 136 ]; then
                test_passed=true
            else
                failure_reason="Process crashed or was killed (exit $actual_exit)"
            fi
            ;;
        "no_crash")
            if [ "$actual_exit" -ne 124 ]; then
                test_passed=true
            else
                failure_reason="Process hung and was killed by timeout"
            fi
            ;;
        "no_crash")
            if [ "$actual_exit" -ne 139 ] && [ "$mem_diff" -lt 500 ]; then
                test_passed=true
            else
                failure_reason="Memory issues detected (exit $actual_exit, mem +${mem_diff}MB)"
            fi
            ;;
        "security_safe")
            if [ -z "$suspicious_calls" ]; then
                test_passed=true
            else
                failure_reason="Suspicious system calls detected: $suspicious_calls"
            fi
            ;;
        "syntax_error")
            if [ "$actual_exit" -eq 2 ] && [ "$actual_exit" -ne 139 ]; then
                test_passed=true
            else
                failure_reason="Should return syntax error (2) without crashing"
            fi
            ;;
        *)
            # Exit code spécifique
            if [ "$actual_exit" -eq "$expected_behavior" ]; then
                test_passed=true
            else
                failure_reason="Wrong exit code (expected $expected_behavior, got $actual_exit)"
            fi
            ;;
    esac
    
    if $test_passed; then
        echo -e "  ${GREEN}✅ SURVIVED${NC} (Exit: $actual_exit, Time: ${execution_time}s, Mem: +${mem_diff}MB)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}💥 FAILED${NC} (Exit: $actual_exit, Time: ${execution_time}s, Mem: +${mem_diff}MB)"
        echo -e "  ${RED}Reason: $failure_reason${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Ajouter au rapport d'erreurs avec détails de sécurité
        {
            echo "## 💀 Test Evil $TOTAL_TESTS: $test_name"
            echo "**Severity:** $severity"
            echo "**Description:** $description"
            echo "**Command:** \`${command:0:300}...\`"
            echo "**Expected behavior:** $expected_behavior"
            echo "**Failure reason:** $failure_reason"
            echo "**Exit code:** $actual_exit"
            echo "**Execution time:** ${execution_time}s"
            echo "**Memory usage:** +${mem_diff}MB"
            echo "**Suspicious calls:** $suspicious_calls"
            echo "**Output:** \`${output:0:200}...\`"
            echo "**Errors:** \`${error_output:0:200}...\`"
            echo "**Category:** Evil Tests"
            echo ""
        } >> "$RAPPORT_ERREURS"
    fi
    echo ""
}

# Fonction pour générer des payloads malveillants
generate_evil_payload() {
    local type="$1"
    local size="$2"
    
    case "$type" in
        "BUFFER_OVERFLOW")
            printf 'A%.0s' $(seq 1 "$size")
            ;;
        "FORMAT_STRING")
            printf '%%s%%p%%x%%n%.0s' $(seq 1 "$size")
            ;;
        "NULL_BYTES")
            printf '\x00%.0s' $(seq 1 "$size")
            ;;
        "CONTROL_CHARS")
            printf '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f%.0s' $(seq 1 "$size")
            ;;
        "UNICODE_BOMB")
            printf '💣🔥💀👹😈🧨⚠️🚨%.0s' $(seq 1 "$size")
            ;;
    esac
}

# Initialiser le rapport d'erreurs avec avertissements de sécurité
cat > "$RAPPORT_ERREURS" << 'EOF'
# 💀 RAPPORT D'ERREURS - TESTS EVIL

⚠️ **AVERTISSEMENT DE SÉCURITÉ** ⚠️
Ce rapport contient des informations sur des tests de sécurité malveillants.
Les commandes listées peuvent être dangereuses et ne doivent pas être exécutées 
dans un environnement de production.

EOF

echo "Date: $(date)" >> "$RAPPORT_ERREURS"
echo "System: $(uname -a)" >> "$RAPPORT_ERREURS"
echo "User: $(whoami)" >> "$RAPPORT_ERREURS"
echo "" >> "$RAPPORT_ERREURS"

echo -e "${BOLD}${RED}================================================${NC}"
echo -e "${BOLD}${RED}💀 NIVEAU 4: TESTS EVIL MINISHELL 💀${NC}"
echo -e "${BOLD}${RED}================================================${NC}"
echo -e "${BOLD}${YELLOW}⚠️  ATTENTION: Tests de sécurité malveillants ⚠️${NC}"
echo ""

# ==================================================================================
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
# 🌊 SECTION 4: DENIAL OF SERVICE
# ==================================================================================
echo -e "${PURPLE}🌊 Section 4: Déni de service${NC}"
echo "──────────────────────────────────"

# Bombe de récursion simulée
recursion_bomb=""
for i in {1..1000}; do
    recursion_bomb="${recursion_bomb}echo \$USER; "
done
run_evil_parsing_test "Variable Bomb" "$recursion_bomb" "no_crash" "1000 expansions de variables" 20 "HIGH"

# Bombe de mémoire
memory_bomb="echo $(printf 'X%.0s' {1..10000})"
run_evil_parsing_test "Memory Bomb" "$memory_bomb" "no_crash" "Allocation massive de mémoire" 15 "HIGH"

# Fork bomb simulé (sans réel fork)
fake_fork_bomb=""
for i in {1..500}; do
    fake_fork_bomb="${fake_fork_bomb}echo process$i & "
done
run_evil_parsing_test "Fake Fork Bomb" "$fake_fork_bomb" "no_crash" "Simulation de fork bomb" 20 "MEDIUM"

# ==================================================================================
# 🔐 SECTION 5: PRIVILEGE ESCALATION
# ==================================================================================
echo -e "${PURPLE}🔐 Section 5: Escalade de privilèges${NC}"
echo "───────────────────────────────────────────"

# Tentative d'accès à des fichiers sensibles
sensitive_files="echo \$HOME; cat /etc/shadow; echo done"
run_evil_parsing_test "Sensitive File Access" "$sensitive_files" "security_safe" "Tentative lecture /etc/shadow" 10 "CRITICAL"

# Tentative de modification de PATH
path_manipulation="echo \$PATH; export PATH=/tmp:\$PATH; echo hacked"
run_evil_parsing_test "PATH Manipulation" "$path_manipulation" "security_safe" "Manipulation variable PATH" 10 "HIGH"

# Tentative d'exécution de binaires système
system_binary="echo test; /usr/bin/id; echo done"
run_evil_parsing_test "System Binary Exec" "$system_binary" "security_safe" "Exécution binaire système" 10 "HIGH"

# ==================================================================================
# 💀 SECTION 6: NULL BYTES ET CONTROLE
# ==================================================================================
echo -e "${PURPLE}💀 Section 6: Octets null et caractères de contrôle${NC}"
echo "──────────────────────────────────────────────────────"

# Injection d'octets null
null_injection="echo 'test\x00evil\x00payload'"
run_evil_parsing_test "Null Byte Injection" "$null_injection" "no_crash" "Injection d'octets null" 10 "MEDIUM"

# Caractères de contrôle
control_chars=$(generate_evil_payload "CONTROL_CHARS" 50)
run_evil_parsing_test "Control Characters" "echo '$control_chars'" "no_crash" "Caractères de contrôle ASCII" 10 "MEDIUM"

# Séquences d'échappement ANSI malveillantes
ansi_evil="echo '\033[2J\033[H\033[?25l Evil ANSI'"
run_evil_parsing_test "ANSI Escape Evil" "$ansi_evil" "no_crash" "Séquences ANSI malveillantes" 10 "LOW"

# ==================================================================================
# 🌍 SECTION 7: UNICODE ET ENCODAGE
# ==================================================================================
echo -e "${PURPLE}🌍 Section 7: Attaques Unicode et encodage${NC}"
echo "──────────────────────────────────────────────"

# Bombe Unicode
unicode_bomb=$(generate_evil_payload "UNICODE_BOMB" 100)
run_evil_parsing_test "Unicode Bomb" "echo '$unicode_bomb'" "no_crash" "Bombe avec caractères Unicode" 15 "MEDIUM"

# Caractères de direction Unicode (pour confusion)
unicode_direction="echo 'normal\u202Eevil\u202Dnormal'"
run_evil_parsing_test "Unicode Direction" "$unicode_direction" "no_crash" "Caractères de direction Unicode" 10 "LOW"

# Overlong UTF-8
overlong_utf8="echo '\xC0\x80\xE0\x80\x80\xF0\x80\x80\x80'"
run_evil_parsing_test "Overlong UTF-8" "$overlong_utf8" "no_crash" "Encodage UTF-8 overlong" 10 "MEDIUM"

# ==================================================================================
# 🧠 SECTION 8: LOGIQUE MALVEILLANTE
# ==================================================================================
echo -e "${PURPLE}🧠 Section 8: Logique malveillante${NC}"
echo "──────────────────────────────────────"

# Boucle infinie simulée
infinite_loop_sim=""
for i in {1..2000}; do
    infinite_loop_sim="${infinite_loop_sim}echo $i; "
done
run_evil_parsing_test "Infinite Loop Simulation" "$infinite_loop_sim" "no_crash" "Simulation boucle infinie" 25 "HIGH"

# Récursion via variables
recursive_var="echo \$USER\$USER\$USER\$USER\$USER\$USER\$USER\$USER\$USER\$USER"
run_evil_parsing_test "Variable Recursion" "$recursive_var" "no_crash" "Variables imbriquées récursivement" 10 "MEDIUM"

# ==================================================================================
# 🔥 SECTION 9: RACE CONDITIONS
# ==================================================================================
echo -e "${PURPLE}🔥 Section 9: Conditions de course${NC}"
echo "──────────────────────────────────────────"

# Création/suppression rapide de fichiers
race_condition="echo test > /tmp/race_test_$$; cat /tmp/race_test_$$; rm /tmp/race_test_$$"
run_evil_parsing_test "File Race Condition" "$race_condition" "no_crash" "Race condition sur fichiers" 10 "MEDIUM"

# Variables d'environnement simultanées
env_race=""
for i in {1..100}; do
    env_race="${env_race}echo \$HOME\$USER\$PWD; "
done
run_evil_parsing_test "Environment Race" "$env_race" "no_crash" "Race sur variables d'environnement" 15 "MEDIUM"

# ==================================================================================
# 💥 SECTION 10: CHAOS EVIL FINAL
# ==================================================================================
echo -e "${PURPLE}💥 Section 10: Chaos evil final${NC}"
echo "──────────────────────────────────"

# Le test evil ultime : combinaison de toutes les attaques
ultimate_evil="echo '$(generate_evil_payload "BUFFER_OVERFLOW" 1000)'; \$USER; cat /etc/passwd; echo '%s%p%x%n'; /bin/sh -c 'echo pwned'; echo done"
run_evil_parsing_test "ULTIMATE EVIL TEST" "$ultimate_evil" "syntax_error" "Combinaison de toutes les attaques" 20 "MAXIMUM"

# Test de résistance finale
final_resistance=""
for i in {1..50}; do
    final_resistance="${final_resistance}echo '$(generate_evil_payload "BUFFER_OVERFLOW" 100)' \$USER%s%p; "
done
run_evil_parsing_test "Final Resistance Test" "$final_resistance" "no_crash" "Test de résistance finale" 25 "CRITICAL"

# ==================================================================================
# 📊 RÉSULTATS FINAUX AVEC ANALYSE DE SÉCURITÉ
# ==================================================================================
echo -e "${BOLD}${RED}================================================${NC}"
echo -e "${BOLD}${RED}📊 RÉSULTATS TESTS EVIL 💀${NC}"
echo -e "${BOLD}${RED}================================================${NC}"
echo ""

echo -e "${BOLD}Total des tests evil:${NC} $TOTAL_TESTS"
echo -e "${BOLD}${GREEN}Tests survivés:${NC} $PASSED_TESTS"
echo -e "${BOLD}${RED}Tests échoués:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🛡️  FÉLICITATIONS ! VOTRE MINISHELL A SURVÉCU À TOUS LES TESTS EVIL !${NC}"
    echo -e "${BOLD}${GREEN}🔒 SÉCURITÉ: EXCELLENTE${NC}"
    echo -e "${BOLD}${GREEN}🏆 ROBUSTESSE: MAXIMALE${NC}"
    security_rating="EXCELLENT"
    success_rate=100
else
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${BOLD}${YELLOW}📋 Taux de survie: ${success_rate}%${NC}"
    
    if [ $success_rate -ge 90 ]; then
        security_rating="TRÈS BONNE"
        echo -e "${BOLD}${GREEN}🔒 SÉCURITÉ: TRÈS BONNE${NC}"
    elif [ $success_rate -ge 75 ]; then
        security_rating="BONNE"
        echo -e "${BOLD}${YELLOW}🔒 SÉCURITÉ: BONNE${NC}"
    elif [ $success_rate -ge 50 ]; then
        security_rating="MOYENNE"
        echo -e "${BOLD}${YELLOW}🔒 SÉCURITÉ: MOYENNE${NC}"
    else
        security_rating="FAIBLE"
        echo -e "${BOLD}${RED}🔒 SÉCURITÉ: FAIBLE${NC}"
    fi
    
    echo -e "${BOLD}${RED}💀 Voir le rapport de sécurité: $RAPPORT_ERREURS${NC}"
fi

echo ""
echo -e "${CYAN}Rapport de sécurité généré: $RAPPORT_ERREURS${NC}"

# Compléter le rapport avec analyse de sécurité complète
{
    echo "---"
    echo ""
    echo "## 📊 Analyse de Sécurité Finale"
    echo ""
    echo "### Résumé des Tests Evil"
    echo "- **Total des tests evil:** $TOTAL_TESTS"
    echo "- **Tests survivés:** $PASSED_TESTS"
    echo "- **Tests échoués:** $FAILED_TESTS"
    echo "- **Taux de survie:** ${success_rate}%"
    echo "- **Évaluation sécurité:** $security_rating"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🛡️ **FÉLICITATIONS !** Votre minishell a survécu à tous les tests malveillants."
        echo "🔒 **SÉCURITÉ EXCELLENTE** - Aucune vulnérabilité détectée."
        echo "🏆 **ROBUSTESSE MAXIMALE** - Résistance parfaite aux attaques."
    else
        echo "💀 **VULNÉRABILITÉS DÉTECTÉES** - Voir les détails ci-dessus."
        echo ""
        echo "### Recommandations de Sécurité:"
        echo "1. Corriger les vulnérabilités identifiées"
        echo "2. Renforcer la validation des entrées"
        echo "3. Implémenter des limites de ressources"
        echo "4. Améliorer la gestion des erreurs"
    fi
    
    echo ""
    echo "### Catégories Testées:"
    echo "1. 🧨 Buffer Overflow Attacks"
    echo "2. 🎭 Format String Attacks"
    echo "3. 🔄 Code Injection Attempts"
    echo "4. 🌊 Denial of Service"
    echo "5. 🔐 Privilege Escalation"
    echo "6. 💀 Null Bytes & Control Chars"
    echo "7. 🌍 Unicode & Encoding Attacks"
    echo "8. 🧠 Malicious Logic"
    echo "9. 🔥 Race Conditions"
    echo "10. 💥 Chaos Evil Tests"
    echo ""
    echo "---"
    echo "*Rapport généré automatiquement par le système de tests de sécurité*"
} >> "$RAPPORT_ERREURS"

# Code de sortie basé sur le niveau de sécurité
if [ $success_rate -ge 90 ]; then
    exit 0
elif [ $success_rate -ge 75 ]; then
    exit 1
else
    exit 2
fi
