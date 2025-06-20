#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_all.sh                                        :+:      :+:    :+:    #
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
BOLD='\033[1m'
NC='\033[0m'

# Configuration
RUN_NORME=true
RUN_MEMORY=true
RUN_PARSER=true
VERBOSE=false

# Fonctions utilitaires
print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}    🚀 MINISHELL - TESTS COMPLETS 🚀${NC}"
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

print_result() {
    local test_name="$1"
    local status="$2"
    
    if [ "$status" = "SUCCESS" ]; then
        echo -e "${GREEN}✅ $test_name: SUCCÈS${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $test_name: AVERTISSEMENT${NC}"
    else
        echo -e "${RED}❌ $test_name: ÉCHEC${NC}"
    fi
}

# Aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Affiche cette aide"
    echo "  -n, --no-norme   Skip les tests norminette"
    echo "  -m, --no-memory  Skip les tests mémoire"
    echo "  -p, --no-parser  Skip les tests parser"
    echo "  -v, --verbose    Mode verbeux"
    echo "  --norme-only     Seulement les tests norminette"
    echo "  --memory-only    Seulement les tests mémoire"
    echo "  --parser-only    Seulement les tests parser"
    echo ""
    echo "Exemples:"
    echo "  $0                    # Tous les tests"
    echo "  $0 --norme-only       # Seulement norminette"
    echo "  $0 --no-memory        # Tout sauf mémoire"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -n|--no-norme)
            RUN_NORME=false
            shift
            ;;
        -m|--no-memory)
            RUN_MEMORY=false
            shift
            ;;
        -p|--no-parser)
            RUN_PARSER=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --norme-only)
            RUN_NORME=true
            RUN_MEMORY=false
            RUN_PARSER=false
            shift
            ;;
        --memory-only)
            RUN_NORME=false
            RUN_MEMORY=true
            RUN_PARSER=false
            shift
            ;;
        --parser-only)
            RUN_NORME=false
            RUN_MEMORY=false
            RUN_PARSER=true
            shift
            ;;
        *)
            echo "Option inconnue: $1"
            echo "Utilisez -h pour l'aide"
            exit 1
            ;;
    esac
done

# Header
print_header

# Vérifications préliminaires
print_section "📋 VÉRIFICATIONS PRÉLIMINAIRES"

echo -e "${CYAN}🔍 Vérification de l'environnement...${NC}"

# Vérifier les fichiers nécessaires
MISSING_FILES=false

if [ ! -f "parsing/includes/minishell.h" ]; then
    echo -e "${RED}❌ minishell.h manquant${NC}"
    MISSING_FILES=true
fi

if [ ! -f "Makefile" ]; then
    echo -e "${RED}❌ Makefile manquant${NC}"
    MISSING_FILES=true
fi

if [ ! -d "parsing/srcs" ]; then
    echo -e "${RED}❌ Répertoire parsing/srcs manquant${NC}"
    MISSING_FILES=true
fi

if [ "$MISSING_FILES" = true ]; then
    echo -e "${RED}❌ Fichiers manquants détectés${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Structure du projet OK${NC}"

# Compilation test
echo -e "${CYAN}🔨 Test de compilation...${NC}"
make fclean > /dev/null 2>&1
if make > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Compilation réussie${NC}"
else
    echo -e "${RED}❌ Échec de compilation${NC}"
    echo "Vérifiez vos erreurs de compilation avec: make"
    exit 1
fi

# Variables pour le résumé
NORME_STATUS=""
MEMORY_STATUS=""
PARSER_STATUS=""

# Tests norminette
if [ "$RUN_NORME" = true ]; then
    print_section "📏 TESTS NORMINETTE"
    
    if [ -f "./test_norme.sh" ]; then
        chmod +x ./test_norme.sh
        if [ "$VERBOSE" = true ]; then
            ./test_norme.sh
        else
            ./test_norme.sh > /dev/null 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            NORME_STATUS="SUCCESS"
        else
            NORME_STATUS="FAILED"
        fi
    else
        echo -e "${YELLOW}⚠️  Script test_norme.sh introuvable${NC}"
        NORME_STATUS="SKIPPED"
    fi
fi

# Tests mémoire
if [ "$RUN_MEMORY" = true ]; then
    print_section "🧠 TESTS MÉMOIRE"
    
    if [ -f "./test_memory.sh" ]; then
        chmod +x ./test_memory.sh
        if [ "$VERBOSE" = true ]; then
            ./test_memory.sh
        else
            ./test_memory.sh > /dev/null 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            MEMORY_STATUS="SUCCESS"
        else
            MEMORY_STATUS="FAILED"
        fi
    else
        echo -e "${YELLOW}⚠️  Script test_memory.sh introuvable${NC}"
        MEMORY_STATUS="SKIPPED"
    fi
fi

# Tests parser
if [ "$RUN_PARSER" = true ]; then
    print_section "⚙️  TESTS PARSER"
    
    if [ -f "./test_parser.sh" ]; then
        chmod +x ./test_parser.sh
        if [ "$VERBOSE" = true ]; then
            ./test_parser.sh
        else
            ./test_parser.sh > /dev/null 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            PARSER_STATUS="SUCCESS"
        else
            PARSER_STATUS="FAILED"
        fi
    else
        echo -e "${YELLOW}⚠️  Script test_parser.sh introuvable${NC}"
        PARSER_STATUS="SKIPPED"
    fi
fi

# Résumé final
print_section "📊 RÉSUMÉ GÉNÉRAL"

if [ "$RUN_NORME" = true ]; then
    print_result "Norminette" "$NORME_STATUS"
fi

if [ "$RUN_MEMORY" = true ]; then
    print_result "Tests mémoire" "$MEMORY_STATUS"
fi

if [ "$RUN_PARSER" = true ]; then
    print_result "Tests parser" "$PARSER_STATUS"
fi

echo ""

# Déterminer le statut global
GLOBAL_SUCCESS=true

if [ "$NORME_STATUS" = "FAILED" ] || [ "$MEMORY_STATUS" = "FAILED" ] || [ "$PARSER_STATUS" = "FAILED" ]; then
    GLOBAL_SUCCESS=false
fi

# Message final
if [ "$GLOBAL_SUCCESS" = true ]; then
    echo -e "${BOLD}${GREEN}🎉 TOUS LES TESTS SONT RÉUSSIS! 🎉${NC}"
    echo -e "${GREEN}✅ Votre parser minishell est prêt pour l'évaluation${NC}"
    echo ""
    echo -e "${CYAN}💡 Prochaines étapes:${NC}"
    echo "   • Intégrer avec l'executor de votre binôme"
    echo "   • Tests d'intégration complets"
    echo "   • Implémentation des builtins"
    exit 0
else
    echo -e "${BOLD}${RED}❌ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
    echo ""
    echo -e "${YELLOW}💡 Actions recommandées:${NC}"
    
    if [ "$NORME_STATUS" = "FAILED" ]; then
        echo "   • Corrigez les erreurs de norminette"
    fi
    
    if [ "$MEMORY_STATUS" = "FAILED" ]; then
        echo "   • Corrigez les fuites mémoire"
    fi
    
    if [ "$PARSER_STATUS" = "FAILED" ]; then
        echo "   • Corrigez les bugs du parser"
    fi
    
    echo ""
    echo -e "${CYAN}📖 Pour plus de détails, relancez en mode verbeux:${NC}"
    echo "   ./test_all.sh --verbose"
    
    exit 1
fi
