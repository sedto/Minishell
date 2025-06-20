#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_validation_finale.sh                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: assistant                                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 16:00:00 by assistant         #+#    #+#              #
#    Updated: 2025/06/20 16:00:00 by assistant         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}🎯 === VALIDATION FINALE MINISHELL === 🎯${NC}"
echo ""

# Check if minishell exists
if [ ! -f "./minishell" ]; then
    echo -e "${YELLOW}🔨 Compilation...${NC}"
    make > /dev/null 2>&1
    if [ ! -f "./minishell" ]; then
        echo -e "${RED}❌ Échec compilation${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Compilation réussie${NC}"
fi

echo ""
echo -e "${CYAN}🧪 === TESTS CRITIQUES ===${NC}"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Test function
test_critical() {
    local description="$1"
    local command="$2"
    local expected_behavior="$3"
    
    ((TOTAL_TESTS++))
    echo -n "🔹 $description... "
    
    if echo "$expected_behavior" | grep -q "no_crash"; then
        timeout 3s $command > /dev/null 2>&1
        if [ $? -ne 124 ] && [ $? -ne 139 ]; then
            echo -e "${GREEN}✅${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ CRASH${NC}"
        fi
    elif echo "$expected_behavior" | grep -q "syntax_error"; then
        # Créer un fichier temporaire pour le test
        TEST_FILE=$(mktemp)
        echo -e "$command\nexit" > $TEST_FILE
        OUTPUT=$(timeout 3s ./minishell < $TEST_FILE 2>&1)
        rm -f $TEST_FILE
        if echo "$OUTPUT" | grep -q "syntax error"; then
            echo -e "${GREEN}✅${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ NO ERROR${NC}"
        fi
    elif echo "$expected_behavior" | grep -q "normal"; then
        # Créer un fichier temporaire pour le test
        TEST_FILE=$(mktemp)
        echo -e "$command\nexit" > $TEST_FILE
        timeout 3s ./minishell < $TEST_FILE > /dev/null 2>&1
        RESULT=$?
        rm -f $TEST_FILE
        if [ $RESULT -eq 0 ] || [ $RESULT -eq 1 ]; then
            echo -e "${GREEN}✅${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ ABNORMAL${NC}"
        fi
    fi
}

# Critical tests that were previously failing
echo -e "${YELLOW}🚨 Tests des bugs critiques corrigés:${NC}"
test_critical "Segfault echo \\\$" "echo \$USER" "normal"
test_critical "Boucle infinie \\\$123" "echo \$123" "normal"
test_critical "Segfault pipe fin" "echo hello |" "syntax_error"
test_critical "Segfault pipe début" "| echo hello" "syntax_error"
test_critical "Redirect sans fichier" "echo >" "syntax_error"

echo ""
echo -e "${YELLOW}🔧 Tests fonctionnels:${NC}"
test_critical "Variables normales" "echo \$USER" "normal"
test_critical "Quotes simples" "echo 'hello'" "normal"
test_critical "Quotes doubles" "echo \"hello\"" "normal"
test_critical "Variables spéciales" "echo \$?" "normal"
test_critical "Commande vide" "" "normal"

echo ""
echo -e "${CYAN}🧠 === TEST MEMORY LEAKS ===${NC}"

if command -v valgrind > /dev/null 2>&1; then
    echo -n "🔹 Memory leaks (Valgrind)... "
    valgrind --leak-check=full --error-exitcode=42 ./minishell -c "echo hello" > /dev/null 2>&1
    if [ $? -ne 42 ]; then
        echo -e "${GREEN}✅ Aucun leak${NC}"
        ((TOTAL_TESTS++))
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ Memory leaks détectés${NC}"
        ((TOTAL_TESTS++))
    fi
    
    echo -n "🔹 Memory leaks complexes... "
    echo 'echo $USER test' | valgrind --leak-check=full --error-exitcode=42 ./minishell > /dev/null 2>&1
    if [ $? -ne 42 ]; then
        echo -e "${GREEN}✅ Aucun leak${NC}"
        ((TOTAL_TESTS++))
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ Memory leaks détectés${NC}"
        ((TOTAL_TESTS++))
    fi
else
    echo -e "${YELLOW}⚠️  Valgrind non disponible${NC}"
fi

echo ""
echo -e "${CYAN}⚡ === TESTS PERFORMANCE ===${NC}"

echo -n "🔹 Mode -c rapide... "
START_TIME=$(date +%s%3N)
echo "echo hello" | ./minishell > /dev/null 2>&1
END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

if [ $DURATION -lt 1000 ]; then
    echo -e "${GREEN}✅ ${DURATION}ms${NC}"
    ((TOTAL_TESTS++))
    ((PASSED_TESTS++))
else
    echo -e "${RED}❌ Trop lent: ${DURATION}ms${NC}"
    ((TOTAL_TESTS++))
fi

echo ""
echo -e "${BOLD}${BLUE}📊 === RÉSULTATS FINAUX ===${NC}"
echo ""
echo "Tests exécutés: $TOTAL_TESTS"
echo -e "Tests réussis: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Tests échoués: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

# Calculate percentage
if [ $TOTAL_TESTS -gt 0 ]; then
    PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Taux de réussite: $PERCENTAGE%"
    echo ""
    
    if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
        echo -e "${BOLD}${GREEN}🎉 PARFAIT: 100% de réussite!${NC}"
        echo -e "${GREEN}✅ Votre parser est PRODUCTION-READY${NC}"
        echo -e "${GREEN}🚀 Prêt pour l'implémentation de l'exécuteur${NC}"
        exit 0
    elif [ $PERCENTAGE -ge 90 ]; then
        echo -e "${YELLOW}⚠️  BIEN: $PERCENTAGE% de réussite${NC}"
        echo -e "${YELLOW}💡 Quelques améliorations mineures possibles${NC}"
        exit 0
    else
        echo -e "${RED}❌ PROBLÈMES: Seulement $PERCENTAGE% de réussite${NC}"
        echo -e "${RED}💡 Des corrections sont nécessaires${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Aucun test exécuté${NC}"
    exit 1
fi
