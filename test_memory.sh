#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_memory_adapted.sh                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 15:00:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/06/20 15:00:00 by dibsejra         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧠 === TEST MÉMOIRE MINISHELL ===${NC}"
echo ""

# Vérifier valgrind
if ! command -v valgrind > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Valgrind non installé${NC}"
    echo "Installez avec: sudo apt-get install valgrind"
    echo "Test mémoire basique sans valgrind..."
    
    # Test sans valgrind - juste vérifier pas de crash
    echo -e "${BLUE}🔍 Test sans crash...${NC}"
    TEST_FILE=$(mktemp)
    cat << 'EOF' > $TEST_FILE
echo hello world
echo "Variables: $USER $HOME"
echo 'Single quotes: $USER'
ls | cat | wc -l
echo test > /tmp/memory_test.txt
cat < /dev/null
echo "Parsing complex: 'single' \"double\" mixed"
exit
EOF

    if timeout 10s ./minishell < $TEST_FILE > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Pas de crash détecté${NC}"
        rm -f $TEST_FILE /tmp/memory_test.txt
        exit 0
    else
        echo -e "${RED}❌ Crash ou timeout${NC}"
        rm -f $TEST_FILE /tmp/memory_test.txt
        exit 1
    fi
fi

# Compiler en mode debug si possible
echo -e "${YELLOW}🔨 Compilation mode debug...${NC}"
make clean > /dev/null 2>&1

# Essayer compilation debug, sinon normale
if make debug > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Compilation debug réussie${NC}"
elif make > /dev/null 2>&1; then
    echo -e "${YELLOW}✅ Compilation normale (pas de mode debug)${NC}"
else
    echo -e "${RED}❌ Échec de compilation${NC}"
    exit 1
fi

echo ""

# Test 1: Commandes basiques
echo -e "${BLUE}🔍 Test 1: Commandes basiques${NC}"
TEST_BASIC=$(mktemp)
cat << 'EOF' > $TEST_BASIC
echo hello world
echo $USER
echo "Double quotes $HOME"
echo 'Single quotes $USER'
exit
EOF

VALGRIND_LOG=$(mktemp)
timeout 15s valgrind \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --error-exitcode=42 \
    --log-file=$VALGRIND_LOG \
    ./minishell < $TEST_BASIC > /dev/null 2>&1

RESULT=$?

if [ $RESULT -eq 42 ]; then
    echo -e "${RED}❌ Erreurs mémoire détectées${NC}"
    echo "Extrait du rapport:"
    grep -A 5 "ERROR SUMMARY\|lost:" $VALGRIND_LOG | head -20
    BASIC_OK=false
elif [ $RESULT -eq 124 ]; then
    echo -e "${YELLOW}⚠️  Timeout${NC}"
    BASIC_OK=false
else
    # Vérifier s'il y a des vrais leaks dans le LEAK SUMMARY
    # On extrait les valeurs des fuites réelles (pas "still reachable")
    DEFINITELY_LOST=$(grep "definitely lost:" $VALGRIND_LOG | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    INDIRECTLY_LOST=$(grep "indirectly lost:" $VALGRIND_LOG | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    POSSIBLY_LOST=$(grep "possibly lost:" $VALGRIND_LOG | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    
    TOTAL_LEAKED=$((DEFINITELY_LOST + INDIRECTLY_LOST + POSSIBLY_LOST))
    
    if [ $TOTAL_LEAKED -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Fuites détectées${NC}"
        echo "Definitely lost: $DEFINITELY_LOST bytes"
        echo "Indirectly lost: $INDIRECTLY_LOST bytes"
        echo "Possibly lost: $POSSIBLY_LOST bytes"
        echo "Total: $TOTAL_LEAKED bytes"
        BASIC_OK=false
    else
        echo -e "${GREEN}✅ Aucune fuite mémoire${NC}"
        BASIC_OK=true
    fi
fi

# Test 2: Pipes et redirections
echo -e "${BLUE}🔍 Test 2: Pipes et redirections${NC}"
TEST_PIPES=$(mktemp)
cat << 'EOF' > $TEST_PIPES
echo hello | cat
echo world | cat | cat
echo test > /tmp/valgrind_test.txt
cat < /dev/null
echo append >> /tmp/valgrind_test.txt
exit
EOF

VALGRIND_LOG2=$(mktemp)
timeout 15s valgrind \
    --leak-check=full \
    --error-exitcode=42 \
    --log-file=$VALGRIND_LOG2 \
    ./minishell < $TEST_PIPES > /dev/null 2>&1

RESULT2=$?

if [ $RESULT2 -eq 42 ]; then
    echo -e "${RED}❌ Erreurs mémoire détectées${NC}"
    PIPES_OK=false
elif [ $RESULT2 -eq 124 ]; then
    echo -e "${YELLOW}⚠️  Timeout${NC}"
    PIPES_OK=false
else
    # Vérifier s'il y a des vrais leaks dans le LEAK SUMMARY
    DEFINITELY_LOST2=$(grep "definitely lost:" $VALGRIND_LOG2 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    INDIRECTLY_LOST2=$(grep "indirectly lost:" $VALGRIND_LOG2 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    POSSIBLY_LOST2=$(grep "possibly lost:" $VALGRIND_LOG2 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    
    TOTAL_LEAKED2=$((DEFINITELY_LOST2 + INDIRECTLY_LOST2 + POSSIBLY_LOST2))
    
    if [ $TOTAL_LEAKED2 -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $TOTAL_LEAKED2 bytes de fuites détectées${NC}"
        PIPES_OK=false
    else
        echo -e "${GREEN}✅ Aucun leak détecté${NC}"
        PIPES_OK=true
    fi
fi

# Test 3: Variables complexes
echo -e "${BLUE}🔍 Test 3: Variables et parsing complexe${NC}"
TEST_COMPLEX=$(mktemp)
cat << 'EOF' > $TEST_COMPLEX
echo "Variables multiples: $USER $HOME $PWD"
echo "Concaténation: $USER$HOME"
echo "Variable inexistante: $UNKNOWN_VAR"
echo "Special: $?"
echo "Quotes: 'single $USER' \"double $HOME\""
echo "Complex parsing: echo\"no spaces\"here"
exit
EOF

VALGRIND_LOG3=$(mktemp)
timeout 15s valgrind \
    --leak-check=full \
    --error-exitcode=42 \
    --log-file=$VALGRIND_LOG3 \
    ./minishell < $TEST_COMPLEX > /dev/null 2>&1

RESULT3=$?

if [ $RESULT3 -eq 42 ]; then
    echo -e "${RED}❌ Erreurs mémoire détectées${NC}"
    COMPLEX_OK=false
elif [ $RESULT3 -eq 124 ]; then
    echo -e "${YELLOW}⚠️  Timeout${NC}"
    COMPLEX_OK=false
else
    # Vérifier s'il y a des vrais leaks dans le LEAK SUMMARY
    DEFINITELY_LOST3=$(grep "definitely lost:" $VALGRIND_LOG3 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    INDIRECTLY_LOST3=$(grep "indirectly lost:" $VALGRIND_LOG3 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    POSSIBLY_LOST3=$(grep "possibly lost:" $VALGRIND_LOG3 | grep -o '[0-9]\+ bytes' | head -1 | grep -o '[0-9]\+' || echo "0")
    
    TOTAL_LEAKED3=$((DEFINITELY_LOST3 + INDIRECTLY_LOST3 + POSSIBLY_LOST3))
    
    if [ $TOTAL_LEAKED3 -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $TOTAL_LEAKED3 bytes de fuites détectées${NC}"
        COMPLEX_OK=false
    else
        echo -e "${GREEN}✅ Aucun leak détecté${NC}"
        COMPLEX_OK=true
    fi
fi

# Test 4: Stress test
echo -e "${BLUE}🔍 Test 4: Test de stress${NC}"
TEST_STRESS=$(mktemp)
cat << 'EOF' > $TEST_STRESS
echo "Long pipeline:" | cat | cat | cat | cat | wc -l
echo "Multiple vars: $USER $HOME $PWD $USER $HOME $PWD"
echo "Complex: 'single' \"double $USER\" 'mixed'"
echo hello > /tmp/stress1.txt > /tmp/stress2.txt
echo "Variables in paths: $HOME/test $USER.txt"
exit
EOF

VALGRIND_LOG4=$(mktemp)
timeout 20s valgrind \
    --leak-check=summary \
    --error-exitcode=42 \
    --log-file=$VALGRIND_LOG4 \
    ./minishell < $TEST_STRESS > /dev/null 2>&1

RESULT4=$?

if [ $RESULT4 -eq 42 ]; then
    echo -e "${RED}❌ Erreurs sous stress${NC}"
    STRESS_OK=false
elif [ $RESULT4 -eq 124 ]; then
    echo -e "${YELLOW}⚠️  Timeout${NC}"
    STRESS_OK=false
else
    echo -e "${GREEN}✅ Test de stress réussi${NC}"
    STRESS_OK=true
fi

# Nettoyage
rm -f $TEST_BASIC $TEST_PIPES $TEST_COMPLEX $TEST_STRESS
rm -f $VALGRIND_LOG $VALGRIND_LOG2 $VALGRIND_LOG3 $VALGRIND_LOG4
rm -f /tmp/valgrind_test.txt /tmp/stress1.txt /tmp/stress2.txt

echo ""
echo -e "${BLUE}📊 === RÉSUMÉ MÉMOIRE ===${NC}"

if [ "$BASIC_OK" = true ]; then
    echo -e "${GREEN}✅ Commandes basiques: OK${NC}"
else
    echo -e "${RED}❌ Commandes basiques: ÉCHEC${NC}"
fi

if [ "$PIPES_OK" = true ]; then
    echo -e "${GREEN}✅ Pipes/redirections: OK${NC}"
else
    echo -e "${RED}❌ Pipes/redirections: ÉCHEC${NC}"
fi

if [ "$COMPLEX_OK" = true ]; then
    echo -e "${GREEN}✅ Variables complexes: OK${NC}"
else
    echo -e "${RED}❌ Variables complexes: ÉCHEC${NC}"
fi

if [ "$STRESS_OK" = true ]; then
    echo -e "${GREEN}✅ Test de stress: OK${NC}"
else
    echo -e "${RED}❌ Test de stress: ÉCHEC${NC}"
fi

echo ""

# Résultat final
if [ "$BASIC_OK" = true ] && [ "$PIPES_OK" = true ] && [ "$COMPLEX_OK" = true ] && [ "$STRESS_OK" = true ]; then
    echo -e "${GREEN}🎉 SUCCÈS: Aucune fuite mémoire détectée!${NC}"
    echo -e "${GREEN}✅ Votre parser gère parfaitement la mémoire${NC}"
    exit 0
else
    echo -e "${RED}❌ ÉCHEC: Problèmes mémoire détectés${NC}"
    echo -e "${YELLOW}💡 Vérifiez que tous les malloc() ont leur free() correspondant${NC}"
    echo -e "${YELLOW}💡 Attention aux ft_strdup, ft_substr dans vos fonctions${NC}"
    exit 1
fi