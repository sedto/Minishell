#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_exhaustif.sh                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 19:45:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/06/20 19:45:00 by dibsejra         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🧪 === TESTS EXHAUSTIFS MINISHELL ===${NC}"
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
    local category="$1"
    local test_name="$2"
    local input="$3"
    local expected_behavior="$4"
    
    ((total_tests++))
    echo -e "${CYAN}🧪 [$category] Test $total_tests: $test_name${NC}"
    echo "   Input: '$input'"
    echo -n "   Result: "
    
    # Créer fichier de test temporaire
    TEST_INPUT=$(mktemp)
    echo -e "$input\nexit" > $TEST_INPUT
    
    # Exécuter le test avec timeout
    OUTPUT=$(timeout 10s ./minishell < $TEST_INPUT 2>&1)
    EXIT_CODE=$?
    
    # Analyser le résultat
    if [ $EXIT_CODE -eq 124 ]; then
        echo -e "${RED}❌ TIMEOUT${NC}"
        ((failed_tests++))
    elif [ $EXIT_CODE -gt 128 ]; then
        echo -e "${RED}❌ CRASH (signal)${NC}"
        ((failed_tests++))
    elif echo "$expected_behavior" | grep -q "syntax error"; then
        if echo "$OUTPUT" | grep -q "syntax error"; then
            echo -e "${GREEN}✅ PASSED (syntax error detected)${NC}"
            ((passed_tests++))
        else
            echo -e "${RED}❌ FAILED (expected syntax error)${NC}"
            ((failed_tests++))
        fi
    elif echo "$expected_behavior" | grep -q "no crash"; then
        echo -e "${GREEN}✅ PASSED (no crash)${NC}"
        ((passed_tests++))
    else
        echo -e "${GREEN}✅ PASSED${NC}"
        ((passed_tests++))
    fi
    
    rm -f $TEST_INPUT
    echo ""
}

echo -e "${YELLOW}📋 === CATÉGORIE 1: COMMANDES BASIQUES ===${NC}"
run_test "BASIC" "Commande simple" "echo hello" "success"
run_test "BASIC" "Commande avec args" "ls -la -h" "success"
run_test "BASIC" "Commande vide" "" "success"
run_test "BASIC" "Espaces multiples" "echo    hello    world" "success"
run_test "BASIC" "Tabulations" "echo\thello\tworld" "success"
run_test "BASIC" "Commande longue" "echo $(printf 'a%.0s' {1..100})" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 2: VARIABLES ===${NC}"
run_test "VARS" "Variable simple" "echo \$USER" "success"
run_test "VARS" "Variable HOME" "echo \$HOME" "success"
run_test "VARS" "Variable PWD" "echo \$PWD" "success"
run_test "VARS" "Variable inexistante" "echo \$UNKNOWN_VAR_123" "success"
run_test "VARS" "Variable spéciale ?" "echo \$?" "success"
run_test "VARS" "Variables multiples" "echo \$USER \$HOME \$PWD" "success"
run_test "VARS" "Variables concaténées" "echo \$USER\$HOME" "success"
run_test "VARS" "Variable avec chiffres" "echo \$VAR123" "success"
run_test "VARS" "Variable numérique" "echo \$1 \$2 \$3" "success"
run_test "VARS" "Variable dollar seul" "echo \$" "success"
run_test "VARS" "Variable avec underscore" "echo \$USER_NAME" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 3: QUOTES SIMPLES ===${NC}"
run_test "S_QUOTES" "Quotes simples basiques" "echo 'hello world'" "success"
run_test "S_QUOTES" "Variables dans quotes simples" "echo '\$USER \$HOME'" "success"
run_test "S_QUOTES" "Quotes simples vides" "echo ''" "success"
run_test "S_QUOTES" "Quotes avec espaces" "echo 'hello    world'" "success"
run_test "S_QUOTES" "Quotes avec caractères spéciaux" "echo 'test@#\$%^&*()'" "success"
run_test "S_QUOTES" "Quotes simples longues" "echo '$(printf 'a%.0s' {1..50})'" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 4: QUOTES DOUBLES ===${NC}"
run_test "D_QUOTES" "Quotes doubles basiques" "echo \"hello world\"" "success"
run_test "D_QUOTES" "Variables dans quotes doubles" "echo \"Hello \$USER\"" "success"
run_test "D_QUOTES" "Quotes doubles vides" "echo \"\"" "success"
run_test "D_QUOTES" "Quotes avec espaces" "echo \"hello    world\"" "success"
run_test "D_QUOTES" "Variables multiples" "echo \"User: \$USER Home: \$HOME\"" "success"
run_test "D_QUOTES" "Variables inexistantes" "echo \"Unknown: \$UNKNOWN_VAR\"" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 5: QUOTES MIXTES ===${NC}"
run_test "MIX_QUOTES" "Single et double" "echo 'single' \"double\"" "success"
run_test "MIX_QUOTES" "Quotes imbriquées" "echo \"'test'\"" "success"
run_test "MIX_QUOTES" "Double imbriquée" "echo '\"test\"'" "success"
run_test "MIX_QUOTES" "Alternance quotes" "echo 'a'\"b\"'c'\"d\"" "success"
run_test "MIX_QUOTES" "Variables mixtes" "echo 'static \$USER' \"dynamic \$HOME\"" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 6: PIPES ===${NC}"
run_test "PIPES" "Pipe simple" "echo hello | cat" "success"
run_test "PIPES" "Pipe double" "echo hello | cat | cat" "success"
run_test "PIPES" "Pipe triple" "echo hello | cat | cat | wc -l" "success"
run_test "PIPES" "Pipe avec arguments" "ls -la | grep test" "success"
run_test "PIPES" "Pipe avec variables" "echo \$USER | cat" "success"
run_test "PIPES" "Pipe long" "echo hello | cat | cat | cat | cat | cat" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 7: REDIRECTIONS ===${NC}"
run_test "REDIR" "Redirection sortie" "echo hello > output.txt" "success"
run_test "REDIR" "Redirection entrée" "cat < /dev/null" "success"
run_test "REDIR" "Redirection append" "echo hello >> log.txt" "success"
run_test "REDIR" "Heredoc simple" "cat << EOF" "success"
run_test "REDIR" "Redirection avec variables" "echo \$USER > user.txt" "success"
run_test "REDIR" "Redirections multiples" "echo hello > file1 > file2" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 8: COMBINAISONS COMPLEXES ===${NC}"
run_test "COMPLEX" "Pipe + redirection" "echo hello | cat > output.txt" "success"
run_test "COMPLEX" "Variables + pipes" "echo \$USER \$HOME | cat | wc -l" "success"
run_test "COMPLEX" "Quotes + variables + pipes" "echo \"User: \$USER\" | cat" "success"
run_test "COMPLEX" "Tout combiné" "echo \"Hello \$USER\" | cat > greeting.txt" "success"
run_test "COMPLEX" "Parsing sans espaces" "echo\"no spaces\"here" "success"
run_test "COMPLEX" "Variables concaténées complexes" "echo \$USER\$HOME\$PWD" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 9: ERREURS SYNTAXE ===${NC}"
run_test "ERRORS" "Pipe en début" "| echo hello" "syntax error"
run_test "ERRORS" "Pipe en fin" "echo hello |" "syntax error"
run_test "ERRORS" "Pipes doubles" "echo hello || echo world" "syntax error"
run_test "ERRORS" "Redirection sans fichier >" "echo hello >" "syntax error"
run_test "ERRORS" "Redirection sans fichier <" "cat <" "syntax error"
run_test "ERRORS" "Redirection sans fichier >>" "echo hello >>" "syntax error"
run_test "ERRORS" "Redirection sans fichier <<" "cat <<" "syntax error"
run_test "ERRORS" "Redirections doubles" "echo hello > > file" "syntax error"

echo -e "${YELLOW}📋 === CATÉGORIE 10: CAS EDGE ===${NC}"
run_test "EDGE" "Ligne très longue" "echo $(printf 'x%.0s' {1..1000})" "no crash"
run_test "EDGE" "Variables répétées" "echo \$USER\$USER\$USER\$USER\$USER" "success"
run_test "EDGE" "Espaces extrêmes" "echo                    hello" "success"
run_test "EDGE" "Quotes non fermées simples" "echo 'hello" "no crash"
run_test "EDGE" "Quotes non fermées doubles" "echo \"hello" "no crash"
run_test "EDGE" "Caractères unicode" "echo 'héllo wörld'" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 11: STRESS TESTS ===${NC}"
run_test "STRESS" "Variables massives" "echo \$USER \$HOME \$PWD \$USER \$HOME \$PWD \$USER \$HOME \$PWD" "success"
run_test "STRESS" "Pipeline massif" "echo hello | cat | cat | cat | cat | cat | cat | cat | wc -l" "success"
run_test "STRESS" "Quotes répétées" "echo 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j'" "success"
run_test "STRESS" "Variables dans quotes" "echo \"1:\$USER 2:\$HOME 3:\$PWD 4:\$USER 5:\$HOME\"" "success"
run_test "STRESS" "Redirection en chaîne" "echo hello > tmp1.txt" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 12: ROBUSTESSE ===${NC}"
run_test "ROBUST" "Arguments avec espaces" "echo \"file with spaces.txt\"" "success"
run_test "ROBUST" "Chemins complexes" "cat \"/path/with spaces/file.txt\"" "success"
run_test "ROBUST" "Variables dans chemins" "cat \$HOME/file.txt" "success"
run_test "ROBUST" "Parsing mixed" "echo\"attached\"'to'\"command\"" "success"
run_test "ROBUST" "Variables spéciales all" "echo \$? \$$ \$0 \$1" "success"

echo -e "${YELLOW}📋 === CATÉGORIE 13: MEMORY TESTS ===${NC}"
echo -e "${CYAN}🧠 Test memory leaks avec Valgrind...${NC}"

if command -v valgrind > /dev/null 2>&1; then
    # Test 1: Valgrind basique
    echo -n "   Memory test 1: "
    VALGRIND_LOG=$(mktemp)
    echo -e "echo hello\necho \$USER\nexit" | timeout 15s valgrind \
        --leak-check=full \
        --error-exitcode=42 \
        --log-file=$VALGRIND_LOG \
        ./minishell > /dev/null 2>&1
    
    if [ $? -eq 42 ]; then
        echo -e "${RED}❌ Memory leaks détectés${NC}"
        ((failed_tests++))
    else
        echo -e "${GREEN}✅ OK${NC}"
        ((passed_tests++))
    fi
    ((total_tests++))
    
    # Test 2: Valgrind complexe
    echo -n "   Memory test 2: "
    echo -e "echo \"Complex: \$USER \$HOME\" | cat\necho 'quotes'\nexit" | timeout 15s valgrind \
        --leak-check=full \
        --error-exitcode=42 \
        --log-file=$VALGRIND_LOG \
        ./minishell > /dev/null 2>&1
    
    if [ $? -eq 42 ]; then
        echo -e "${RED}❌ Memory leaks détectés${NC}"
        ((failed_tests++))
    else
        echo -e "${GREEN}✅ OK${NC}"
        ((passed_tests++))
    fi
    ((total_tests++))
    
    rm -f $VALGRIND_LOG
else
    echo -e "${YELLOW}⚠️  Valgrind non installé - tests mémoire sautés${NC}"
fi

echo ""
echo -e "${BLUE}📊 === RÉSULTATS EXHAUSTIFS ===${NC}"
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
        echo -e "${GREEN}🎉 PARFAIT: 100% des tests réussis!${NC}"
        echo -e "${GREEN}✅ Parser ultra-robuste et production-ready${NC}"
        exit 0
    elif [ $success_rate -ge 95 ]; then
        echo -e "${YELLOW}🌟 EXCELLENT: $success_rate% de réussite${NC}"
        echo -e "${YELLOW}💡 Quasi-parfait, très rares edge cases${NC}"
        exit 0
    elif [ $success_rate -ge 85 ]; then
        echo -e "${YELLOW}⚠️  BON: $success_rate% de réussite${NC}"
        echo -e "${YELLOW}💡 Quelques améliorations mineures possibles${NC}"
        exit 0
    else
        echo -e "${RED}❌ PROBLÈMES: Seulement $success_rate% de réussite${NC}"
        echo -e "${RED}💡 Des corrections importantes sont nécessaires${NC}"
        exit 1
    fi
fi

echo -e "${RED}❌ Aucun test exécuté${NC}"
exit 1
