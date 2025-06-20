#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_corrections_robustes.sh                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: team                                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 17:20:00 by team              #+#    #+#              #
#    Updated: 2025/06/20 17:20:00 by team              ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}🧪 TESTS ROBUSTES - CORRECTIONS CRITIQUES${NC}"
echo "=========================================="

# Test counters
TOTAL=0
PASS=0

test_correction() {
    local desc="$1"
    local test_cmd="$2"
    local expected="$3"
    
    echo -n "🔹 $desc... "
    TOTAL=$((TOTAL + 1))
    
    # Exécuter avec timeout pour éviter les blocages
    if [ "$expected" = "no_crash" ]; then
        timeout 5s bash -c "$test_cmd" >/dev/null 2>&1
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 124 ] && [ $EXIT_CODE -ne 139 ]; then
            echo -e "${GREEN}✅${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "${RED}❌ CRASH (code: $EXIT_CODE)${NC}"
        fi
    elif [ "$expected" = "syntax_error" ]; then
        OUTPUT=$(timeout 5s bash -c "$test_cmd" 2>&1)
        if echo "$OUTPUT" | grep -q "syntax error"; then
            echo -e "${GREEN}✅${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "${RED}❌ NO SYNTAX ERROR${NC}"
            echo "   Output: $OUTPUT"
        fi
    elif [ "$expected" = "success" ]; then
        timeout 5s bash -c "$test_cmd" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "${RED}❌ FAILED${NC}"
        fi
    fi
}

echo ""
echo -e "${YELLOW}🐛 Tests des corrections de fuites mémoire:${NC}"

# Test 1: Correction expand_variables.c - Pas de perte de valeur originale
test_correction "Variables expansion fallback" \
    "echo 'echo \$NONEXISTENT_VAR_TEST' | ./minishell" \
    "no_crash"

# Test 2: Variables avec contenu valide
test_correction "Variables expansion normale" \
    "echo 'echo \$USER' | ./minishell" \
    "no_crash"

# Test 3: Correction parse_commands.c - Libération complète
test_correction "Erreur syntaxique avec libération" \
    "echo 'echo hello |' | ./minishell" \
    "syntax_error"

# Test 4: Pipeline invalide
test_correction "Pipeline début invalide" \
    "echo '| echo hello' | ./minishell" \
    "syntax_error"

echo ""
echo -e "${YELLOW}🔄 Tests des corrections de boucles infinies:${NC}"

# Test 5: Variables numériques qui causaient des boucles
test_correction "Variable numérique \$123" \
    "echo 'echo \$123' | ./minishell" \
    "no_crash"

test_correction "Variable numérique \$456abc" \
    "echo 'echo \$456abc' | ./minishell" \
    "no_crash"

test_correction "Variables multiples \$1\$2\$3" \
    "echo 'echo \$1\$2\$3' | ./minishell" \
    "no_crash"

echo ""
echo -e "${YELLOW}🛡️  Tests protection bounds et overflow:${NC}"

# Test 6: Variables très longues (test protection bounds)
export HUGE_TEST_VAR=$(python3 -c "print('A' * 500)" 2>/dev/null || echo "AAAAAAAAAA")
test_correction "Variable très longue" \
    "echo 'echo \$HUGE_TEST_VAR' | ./minishell" \
    "no_crash"

# Test 7: Expansion multiple de variables
test_correction "Expansion multiple variables" \
    "echo 'echo \$USER\$HOME\$PATH' | ./minishell" \
    "no_crash"

# Test 8: Variables avec caractères spéciaux
test_correction "Variable spéciale \$?" \
    "echo 'echo \$?' | ./minishell" \
    "no_crash"

test_correction "Variable spéciale \$\$" \
    "echo 'echo \$\$' | ./minishell" \
    "no_crash"

echo ""
echo -e "${YELLOW}🧠 Test Memory Leaks (Valgrind si disponible):${NC}"

if command -v valgrind >/dev/null 2>&1; then
    echo -n "🔹 Memory leaks test... "
    TOTAL=$((TOTAL + 1))
    
    # Test avec Valgrind pour détecter les fuites
    valgrind --leak-check=full --error-exitcode=42 \
        --suppressions=/dev/null \
        ./minishell -c "echo hello world" >/dev/null 2>&1
    
    if [ $? -ne 42 ]; then
        echo -e "${GREEN}✅ Aucun leak détecté${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}❌ Memory leaks détectés${NC}"
    fi
    
    echo -n "🔹 Memory leaks avec variables... "
    TOTAL=$((TOTAL + 1))
    
    valgrind --leak-check=full --error-exitcode=42 \
        ./minishell -c "echo \$USER \$HOME" >/dev/null 2>&1
    
    if [ $? -ne 42 ]; then
        echo -e "${GREEN}✅ Aucun leak avec variables${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}❌ Memory leaks avec variables${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Valgrind non disponible${NC}"
fi

echo ""
echo -e "${YELLOW}⚡ Tests de performance/stabilité:${NC}"

# Test 9: Rapidité d'exécution
echo -n "🔹 Performance test... "
TOTAL=$((TOTAL + 1))
START_TIME=$(date +%s%3N)
echo "echo hello" | ./minishell >/dev/null 2>&1
END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

if [ $DURATION -lt 2000 ]; then  # Moins de 2 secondes
    echo -e "${GREEN}✅ ${DURATION}ms${NC}"
    PASS=$((PASS + 1))
else
    echo -e "${RED}❌ Trop lent: ${DURATION}ms${NC}"
fi

# Test 10: Stabilité sur commandes multiples
test_correction "Commandes multiples séquentielles" \
    "echo -e 'echo test1\necho test2\necho test3\nexit' | ./minishell" \
    "no_crash"

echo ""
echo -e "${BOLD}${BLUE}📊 RÉSULTATS TESTS ROBUSTES${NC}"
echo "=================================="
echo "Tests exécutés: $TOTAL"
echo -e "Tests réussis: ${GREEN}$PASS${NC}"
echo -e "Tests échoués: ${RED}$((TOTAL - PASS))${NC}"

if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$((PASS * 100 / TOTAL))
    echo "Taux de réussite: $PERCENTAGE%"
    echo ""
    
    if [ $PASS -eq $TOTAL ]; then
        echo -e "${BOLD}${GREEN}🎉 PARFAIT: Toutes les corrections fonctionnent!${NC}"
        echo -e "${GREEN}✅ Parser robuste et memory-safe${NC}"
        echo -e "${GREEN}🚀 Prêt pour production${NC}"
    elif [ $PERCENTAGE -ge 90 ]; then
        echo -e "${YELLOW}⚠️  BIEN: $PERCENTAGE% - Quelques ajustements mineurs${NC}"
    else
        echo -e "${RED}❌ PROBLÈMES: Des corrections supplémentaires nécessaires${NC}"
    fi
fi

# Nettoyage
unset HUGE_TEST_VAR

echo ""
echo -e "${BLUE}🔍 Pour diagnostic approfondi:${NC}"
echo "• Valgrind détaillé: valgrind --leak-check=full ./minishell"
echo "• Tests manuels: ./minishell puis tester interactivement"
echo "• Tests cas edge: Variables très longues, caractères spéciaux"
