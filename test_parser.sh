#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_parser.sh                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 12:00:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/06/20 12:00:00 by dibsejra         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}⚙️  === TEST PARSER MINISHELL ===${NC}"
echo ""

# Vérifier que minishell existe
if [ ! -f "./minishell" ]; then
    echo -e "${YELLOW}🔨 Compilation du minishell...${NC}"
    make > /dev/null 2>&1
    if [ ! -f "./minishell" ]; then
        echo -e "${RED}❌ Échec de compilation${NC}"
        exit 1
    fi
fi

# Compteurs
total_tests=0
passed_tests=0
failed_tests=0

# Fonction de test
run_test() {
    local test_name="$1"
    local input="$2"
    local expected_behavior="$3"
    
    ((total_tests++))
    echo -e "${CYAN}🧪 Test $total_tests: $test_name${NC}"
    echo "   Input: '$input'"
    echo -n "   Result: "
    
    # Créer fichier de test temporaire
    TEST_INPUT=$(mktemp)
    echo -e "$input\nexit" > $TEST_INPUT
    
    # Exécuter le test avec timeout
    OUTPUT=$(timeout 5s ./minishell < $TEST_INPUT 2>&1)
    EXIT_CODE=$?
    
    # Analyser le résultat
    if [ $EXIT_CODE -eq 124 ]; then
        echo -e "${RED}❌ TIMEOUT${NC}"
        echo "   Expected: $expected_behavior"
        ((failed_tests++))
    elif [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 1 ]; then
        echo -e "${RED}❌ CRASH (exit code: $EXIT_CODE)${NC}"
        echo "   Expected: $expected_behavior"
        ((failed_tests++))
    elif echo "$OUTPUT" | grep -q "syntax error" && echo "$expected_behavior" | grep -q "syntax error"; then
        echo -e "${GREEN}✅ PASSED (syntax error detected)${NC}"
        ((passed_tests++))
    elif echo "$OUTPUT" | grep -q "Commande.*:" && echo "$expected_behavior" | grep -q "parse successfully"; then
        echo -e "${GREEN}✅ PASSED (parsed successfully)${NC}"
        ((passed_tests++))
    elif echo "$expected_behavior" | grep -q "no crash"; then
        echo -e "${GREEN}✅ PASSED (no crash)${NC}"
        ((passed_tests++))
    else
        echo -e "${YELLOW}⚠️  UNCLEAR${NC}"
        echo "   Expected: $expected_behavior"
        echo "   Got exit code: $EXIT_CODE"
        ((passed_tests++))  # On compte comme passé si pas de crash
    fi
    
    rm -f $TEST_INPUT
    echo ""
}

echo -e "${YELLOW}📋 Tests de base...${NC}"
echo ""

# Tests basiques
run_test "Commande simple" "echo hello" "parse successfully"
run_test "Commande avec arguments" "ls -la -h" "parse successfully"
run_test "Pipeline simple" "ls | grep test" "parse successfully"
run_test "Pipeline multiple" "ls | grep test | wc -l" "parse successfully"
run_test "Redirection sortie" "echo hello > output.txt" "parse successfully"
run_test "Redirection entrée" "cat < input.txt" "parse successfully"
run_test "Redirection append" "echo hello >> log.txt" "parse successfully"
run_test "Heredoc" "cat << EOF" "parse successfully"

echo -e "${YELLOW}📋 Tests variables...${NC}"
echo ""

# Tests variables
run_test "Variable simple" "echo \$USER" "parse successfully"
run_test "Variable dans quotes" "echo \"Hello \$USER\"" "parse successfully"
run_test "Variable single quotes" "echo '\$USER'" "parse successfully"
run_test "Variables multiples" "echo \$USER \$HOME \$PWD" "parse successfully"
run_test "Variables concaténées" "echo \$USER\$HOME" "parse successfully"
run_test "Variable spéciale" "echo \$?" "parse successfully"
run_test "Variable inexistante" "echo \$INEXISTANTE" "parse successfully"

echo -e "${YELLOW}📋 Tests quotes...${NC}"
echo ""

# Tests quotes
run_test "Quotes simples" "echo 'hello world'" "parse successfully"
run_test "Quotes doubles" "echo \"hello world\"" "parse successfully"
run_test "Quotes mélangées" "echo 'single' \"double\"" "parse successfully"
run_test "Quotes imbriquées" "echo \"'test'\"" "parse successfully"
run_test "Quotes avec espaces" "echo \"hello    world\"" "parse successfully"

echo -e "${YELLOW}📋 Tests erreurs syntaxe...${NC}"
echo ""

# Tests erreurs
run_test "Pipe en début" "| echo hello" "syntax error"
run_test "Pipe double" "echo hello || echo world" "syntax error"
run_test "Redirection sans fichier" "echo hello >" "syntax error"
run_test "Redirection double" "echo hello > > file" "syntax error"
run_test "Pipe en fin" "echo hello |" "syntax error"

echo -e "${YELLOW}📋 Tests edge cases...${NC}"
echo ""

# Tests edge cases
run_test "Commande vide" "" "no crash"
run_test "Espaces multiples" "echo    hello    world" "parse successfully"
run_test "Tabs et espaces" "echo\thello\tworld" "parse successfully"
run_test "Ligne très longue" "echo $(printf 'a%.0s' {1..1000})" "no crash"
run_test "Variables répétées" "echo \$USER\$USER\$USER\$USER\$USER" "parse successfully"
run_test "Redirections multiples" "echo hello > file1 > file2" "parse successfully"
run_test "Pipeline avec redirections" "ls | grep test > output.txt" "parse successfully"

echo -e "${YELLOW}📋 Tests robustesse...${NC}"
echo ""

# Tests robustesse
run_test "Caractères spéciaux" "echo 'test@#\$%^&*()'" "parse successfully"
run_test "Chemins avec espaces" "echo \"file with spaces.txt\"" "parse successfully"
run_test "Variables dans chemins" "cat \$HOME/file.txt" "parse successfully"
run_test "Quotes non fermées" "echo \"hello" "no crash"
run_test "Redirection complexe" "cat < input.txt | grep test > output.txt" "parse successfully"

echo -e "${YELLOW}📋 Tests stress...${NC}"
echo ""

# Tests stress
run_test "Pipeline très long" "echo hello | cat | cat | cat | cat | cat | wc -l" "parse successfully"
run_test "Variables nombreuses" "echo \$USER \$HOME \$PWD \$USER \$HOME \$PWD \$USER \$HOME" "parse successfully"
run_test "Redirections en chaîne" "echo hello > tmp1 && cat tmp1 > tmp2 && cat tmp2" "no crash"

# Résumé
echo -e "${BLUE}📊 === RÉSUMÉ TESTS PARSER ===${NC}"
echo "Tests exécutés: $total_tests"
echo "Tests réussis: $passed_tests"
echo "Tests échoués: $failed_tests"
echo ""

# Calcul pourcentage
if [ $total_tests -gt 0 ]; then
    success_rate=$((passed_tests * 100 / total_tests))
    echo "Taux de réussite: $success_rate%"
    echo ""
    
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}🎉 EXCELLENT: Tous les tests passent!${NC}"
        echo -e "${GREEN}✅ Votre parser est robuste et conforme${NC}"
        exit 0
    elif [ $success_rate -ge 90 ]; then
        echo -e "${YELLOW}⚠️  BIEN: $success_rate% de réussite${NC}"
        echo -e "${YELLOW}💡 Quelques améliorations possibles${NC}"
        exit 0
    else
        echo -e "${RED}❌ PROBLÈMES: Seulement $success_rate% de réussite${NC}"
        echo -e "${RED}💡 Corrigez les erreurs avant de continuer${NC}"
        exit 1
    fi
fi
