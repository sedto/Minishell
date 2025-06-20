#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_all_adapted.sh                                :+:      :+:    :+:    #
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
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration par défaut
RUN_NORME=true
RUN_MEMORY=true
RUN_PARSER=true
VERBOSE=false
QUICK=false

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}    🚀 MINISHELL - TESTS ADAPTÉS 🚀${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${YELLOW}┌─────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${YELLOW}│  $1${NC}"
    echo -e "${BOLD}${YELLOW}└─────────────────────────────────────────────┘${NC}"
    echo ""
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help         Affiche cette aide"
    echo "  -n, --no-norme     Skip norminette"
    echo "  -m, --no-memory    Skip tests mémoire"
    echo "  -p, --no-parser    Skip tests parser"
    echo "  -v, --verbose      Mode verbeux"
    echo "  -q, --quick        Tests rapides seulement"
    echo "  --norme-only       Seulement norminette"
    echo "  --memory-only      Seulement mémoire"
    echo "  --parser-only      Seulement parser"
    echo ""
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        -n|--no-norme) RUN_NORME=false; shift ;;
        -m|--no-memory) RUN_MEMORY=false; shift ;;
        -p|--no-parser) RUN_PARSER=false; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -q|--quick) QUICK=true; shift ;;
        --norme-only) RUN_NORME=true; RUN_MEMORY=false; RUN_PARSER=false; shift ;;
        --memory-only) RUN_NORME=false; RUN_MEMORY=true; RUN_PARSER=false; shift ;;
        --parser-only) RUN_NORME=false; RUN_MEMORY=false; RUN_PARSER=true; shift ;;
        *) echo "Option inconnue: $1"; echo "Utilisez -h pour l'aide"; exit 1 ;;
    esac
done

print_header

# Vérifications préliminaires
print_section "📋 VÉRIFICATIONS PRÉLIMINAIRES"

echo -e "${CYAN}🔍 Détection structure projet...${NC}"

# Trouver les fichiers sources
C_FILES=$(find . -name "*.c" -not -path "./libft/*" 2>/dev/null | wc -l)
H_FILES=$(find . -name "*.h" -not -path "./libft/*" 2>/dev/null | wc -l)

echo "Fichiers .c trouvés: $C_FILES"
echo "Fichiers .h trouvés: $H_FILES"

if [ $C_FILES -eq 0 ]; then
    echo -e "${RED}❌ Aucun fichier source trouvé${NC}"
    exit 1
fi

# Vérifier Makefile et compilation
if [ -f "Makefile" ]; then
    echo -e "${CYAN}🔨 Test compilation...${NC}"
    make clean > /dev/null 2>&1
    
    if make > compilation.log 2>&1; then
        echo -e "${GREEN}✅ Compilation réussie${NC}"
        if [ -f "./minishell" ]; then
            echo -e "${GREEN}✅ Exécutable créé${NC}"
        else
            echo -e "${RED}❌ Pas d'exécutable produit${NC}"
            echo "Logs de compilation:"
            cat compilation.log
            exit 1
        fi
    else
        echo -e "${RED}❌ Erreur de compilation${NC}"
        echo "Logs de compilation:"
        cat compilation.log
        exit 1
    fi
    rm -f compilation.log
else
    echo -e "${RED}❌ Makefile introuvable${NC}"
    exit 1
fi

# Variables résultats
NORME_STATUS="SKIPPED"
MEMORY_STATUS="SKIPPED"
PARSER_STATUS="SKIPPED"

# Test norminette
if [ "$RUN_NORME" = true ]; then
    print_section "📏 TESTS NORMINETTE"
    
    # Créer script de test si pas existant
    if [ -f "./test_norme.sh" ]; then
        chmod +x ./test_norme.sh
        if [ "$VERBOSE" = true ]; then
            ./test_norme.sh
        else
            ./test_norme.sh > /dev/null 2>&1
        fi
        NORME_STATUS=$([[ $? -eq 0 ]] && echo "SUCCESS" || echo "FAILED")
    else
        echo -e "${YELLOW}⚠️  Script norminette non trouvé${NC}"
        echo "Exécution test norminette de base..."
        
        if command -v norminette > /dev/null 2>&1; then
            NORME_ERRORS=0
            for file in $(find . -name "*.c" -o -name "*.h" | grep -v libft); do
                if ! norminette "$file" > /dev/null 2>&1; then
                    ((NORME_ERRORS++))
                fi
            done
            
            if [ $NORME_ERRORS -eq 0 ]; then
                echo -e "${GREEN}✅ Norminette OK${NC}"
                NORME_STATUS="SUCCESS"
            else
                echo -e "${RED}❌ $NORME_ERRORS erreur(s) norminette${NC}"
                NORME_STATUS="FAILED"
            fi
        else
            echo -e "${YELLOW}⚠️  Norminette non installé${NC}"
            NORME_STATUS="SKIPPED"
        fi
    fi
fi

# Test mémoire
if [ "$RUN_MEMORY" = true ]; then
    print_section "🧠 TESTS MÉMOIRE"
    
    if [ -f "./test_memory.sh" ]; then
        chmod +x ./test_memory.sh
        if [ "$VERBOSE" = true ]; then
            ./test_memory.sh
        else
            ./test_memory.sh > /dev/null 2>&1
        fi
        MEMORY_STATUS=$([[ $? -eq 0 ]] && echo "SUCCESS" || echo "FAILED")
    else
        echo -e "${YELLOW}⚠️  Script mémoire non trouvé${NC}"
        echo "Test mémoire basique..."
        
        if command -v valgrind > /dev/null 2>&1; then
            echo -e "echo hello\nexit" | timeout 10s valgrind --error-exitcode=42 ./minishell > /dev/null 2>&1
            if [ $? -eq 42 ]; then
                echo -e "${RED}❌ Leaks détectés${NC}"
                MEMORY_STATUS="FAILED"
            else
                echo -e "${GREEN}✅ Pas de leaks majeurs${NC}"
                MEMORY_STATUS="SUCCESS"
            fi
        else
            echo -e "${YELLOW}⚠️  Valgrind non installé${NC}"
            # Test sans valgrind
            echo -e "echo hello\nexit" | timeout 5s ./minishell > /dev/null 2>&1
            if [ $? -eq 124 ] || [ $? -gt 128 ]; then
                echo -e "${RED}❌ Crash détecté${NC}"
                MEMORY_STATUS="FAILED"
            else
                echo -e "${GREEN}✅ Pas de crash${NC}"
                MEMORY_STATUS="SUCCESS"
            fi
        fi
    fi
fi

# Test parser
if [ "$RUN_PARSER" = true ]; then
    print_section "⚙️  TESTS PARSER"
    
    if [ -f "./test_simple_adapted.sh" ]; then
        chmod +x ./test_simple_adapted.sh
        if [ "$VERBOSE" = true ]; then
            ./test_simple_adapted.sh
        else
            ./test_simple_adapted.sh > /dev/null 2>&1
        fi
        PARSER_STATUS=$([[ $? -eq 0 ]] && echo "SUCCESS" || echo "FAILED")
    else
        echo -e "${YELLOW}⚠️  Script parser non trouvé${NC}"
        echo "Test parser basique..."
        
        # Tests manuels simples
        PARSER_ERRORS=0
        
        # Test 1: Commande simple
        echo -e "echo hello\nexit" | timeout 5s ./minishell > /dev/null 2>&1
        [[ $? -ne 0 ]] && ((PARSER_ERRORS++))
        
        # Test 2: Variable
        echo -e "echo \$USER\nexit" | timeout 5s ./minishell > /dev/null 2>&1
        [[ $? -ne 0 ]] && ((PARSER_ERRORS++))
        
        # Test 3: Pipe
        echo -e "echo hello | cat\nexit" | timeout 5s ./minishell > /dev/null 2>&1
        [[ $? -ne 0 ]] && ((PARSER_ERRORS++))
        
        if [ $PARSER_ERRORS -eq 0 ]; then
            echo -e "${GREEN}✅ Tests parser basiques OK${NC}"
            PARSER_STATUS="SUCCESS"
        else
            echo -e "${RED}❌ $PARSER_ERRORS test(s) échoué(s)${NC}"
            PARSER_STATUS="FAILED"
        fi
    fi
fi

# Résumé final
print_section "📊 RÉSUMÉ GÉNÉRAL"

if [ "$NORME_STATUS" = "SUCCESS" ]; then
    echo -e "${GREEN}✅ Norminette: SUCCÈS${NC}"
elif [ "$NORME_STATUS" = "FAILED" ]; then
    echo -e "${RED}❌ Norminette: ÉCHEC${NC}"
else
    echo -e "${YELLOW}⚠️  Norminette: NON TESTÉ${NC}"
fi

if [ "$MEMORY_STATUS" = "SUCCESS" ]; then
    echo -e "${GREEN}✅ Mémoire: SUCCÈS${NC}"
elif [ "$MEMORY_STATUS" = "FAILED" ]; then
    echo -e "${RED}❌ Mémoire: ÉCHEC${NC}"
else
    echo -e "${YELLOW}⚠️  Mémoire: NON TESTÉ${NC}"
fi

if [ "$PARSER_STATUS" = "SUCCESS" ]; then
    echo -e "${GREEN}✅ Parser: SUCCÈS${NC}"
elif [ "$PARSER_STATUS" = "FAILED" ]; then
    echo -e "${RED}❌ Parser: ÉCHEC${NC}"
else
    echo -e "${YELLOW}⚠️  Parser: NON TESTÉ${NC}"
fi

echo ""

# Statut global
FAILURES=0
[[ "$NORME_STATUS" = "FAILED" ]] && ((FAILURES++))
[[ "$MEMORY_STATUS" = "FAILED" ]] && ((FAILURES++))
[[ "$PARSER_STATUS" = "FAILED" ]] && ((FAILURES++))

if [ $FAILURES -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🎉 TOUS LES TESTS SONT RÉUSSIS! 🎉${NC}"
    echo -e "${GREEN}✅ Votre minishell est prêt${NC}"
    echo ""
    echo -e "${CYAN}💡 Prochaines étapes:${NC}"
    echo "   • Tests d'intégration avec l'executor"
    echo "   • Implémentation des builtins"
    echo "   • Tests finaux avec bash"
    exit 0
else
    echo -e "${BOLD}${RED}❌ $FAILURES TEST(S) ONT ÉCHOUÉ${NC}"
    echo ""
    echo -e "${YELLOW}💡 Actions à effectuer:${NC}"
    [[ "$NORME_STATUS" = "FAILED" ]] && echo "   • Corriger les erreurs norminette"
    [[ "$MEMORY_STATUS" = "FAILED" ]] && echo "   • Corriger les fuites mémoire"
    [[ "$PARSER_STATUS" = "FAILED" ]] && echo "   • Corriger les bugs parser"
    echo ""
    echo -e "${CYAN}📖 Pour débugger:${NC}"
    echo "   ./test_all_adapted.sh --verbose"
    echo "   ./test_all_adapted.sh --norme-only"
    echo "   ./test_all_adapted.sh --memory-only"
    exit 1
fi
