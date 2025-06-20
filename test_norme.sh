#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_norme_adapted.sh                              :+:      :+:    :+:    #
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

echo -e "${BLUE}📏 === TEST NORMINETTE ADAPTÉ ===${NC}"
echo ""

# Vérifier norminette
if ! command -v norminette > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Norminette non installé${NC}"
    echo "Installez avec: pip install norminette"
    echo ""
    echo -e "${BLUE}📋 Vérification manuelle des règles principales:${NC}"
    
    # Vérifications manuelles basiques
    echo -e "${YELLOW}🔍 Vérification nombre de lignes par fonction...${NC}"
    
    LONG_FUNCTIONS=0
    for file in $(find . -name "*.c" 2>/dev/null); do
        if [ -f "$file" ]; then
            # Chercher les fonctions avec plus de 25 lignes
            awk '/^[a-zA-Z_][a-zA-Z0-9_]*[ \t]*\([^)]*\)[ \t]*$/{start=NR; func=$0} /^}$/{if(start && NR-start > 25) print FILENAME":"start":"func":"(NR-start)" lines"}' "$file"
        fi
    done
    
    echo -e "${YELLOW}🔍 Vérification espaces avant noms de fonctions...${NC}"
    SPACE_ERRORS=$(grep -n "^ *[a-zA-Z_][a-zA-Z0-9_]*(" $(find . -name "*.c" 2>/dev/null) | wc -l)
    if [ $SPACE_ERRORS -gt 0 ]; then
        echo -e "${RED}❌ $SPACE_ERRORS fonction(s) avec espaces avant le nom${NC}"
        grep -n "^ *[a-zA-Z_][a-zA-Z0-9_]*(" $(find . -name "*.c" 2>/dev/null) | head -5
    else
        echo -e "${GREEN}✅ Pas d'espaces avant les noms de fonctions${NC}"
    fi
    
    echo -e "${YELLOW}💡 Pour une vérification complète, installez norminette${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Norminette installé${NC}"
echo ""

# Compteurs
total_files=0
error_files=0
total_errors=0

# Fonction pour tester des fichiers
test_files() {
    local pattern="$1"
    local description="$2"
    
    echo -e "${BLUE}📂 $description${NC}"
    
    for file in $(find . -name "$pattern" 2>/dev/null | sort); do
        if [ -f "$file" ]; then
            ((total_files++))
            echo -n "  $(basename $file): "
            
            # Exécuter norminette avec timeout
            OUTPUT=$(timeout 10s norminette "$file" 2>&1)
            
            if echo "$OUTPUT" | grep -q "Error"; then
                echo -e "${RED}❌ ERRORS${NC}"
                
                # Afficher les erreurs de manière lisible
                echo "$OUTPUT" | grep "Error" | while read line; do
                    echo "    $line"
                done
                
                ((error_files++))
                error_count=$(echo "$OUTPUT" | grep -c "Error")
                ((total_errors += error_count))
            else
                echo -e "${GREEN}✅ OK${NC}"
            fi
        fi
    done
    echo ""
}

# Tester tous les fichiers .c et .h
test_files "*.c" "Fichiers sources (.c)"
test_files "*.h" "Fichiers headers (.h)"

# Si on trouve un répertoire avec structure, le tester aussi
if [ -d "parsing" ]; then
    echo -e "${BLUE}📂 Répertoire parsing${NC}"
    for file in $(find parsing -name "*.c" -o -name "*.h" 2>/dev/null | sort); do
        if [ -f "$file" ]; then
            ((total_files++))
            echo -n "  $(echo $file | sed 's|.*/||'): "
            
            OUTPUT=$(timeout 10s norminette "$file" 2>&1)
            
            if echo "$OUTPUT" | grep -q "Error"; then
                echo -e "${RED}❌ ERRORS${NC}"
                echo "$OUTPUT" | grep "Error" | head -3 | while read line; do
                    echo "    $line"
                done
                ((error_files++))
                error_count=$(echo "$OUTPUT" | grep -c "Error")
                ((total_errors += error_count))
            else
                echo -e "${GREEN}✅ OK${NC}"
            fi
        fi
    done
    echo ""
fi

# Tester d'autres répertoires communs
for dir in src srcs sources; do
    if [ -d "$dir" ]; then
        echo -e "${BLUE}📂 Répertoire $dir${NC}"
        for file in $(find "$dir" -name "*.c" -o -name "*.h" 2>/dev/null | sort); do
            if [ -f "$file" ]; then
                ((total_files++))
                echo -n "  $(echo $file | sed 's|.*/||'): "
                
                OUTPUT=$(timeout 10s norminette "$file" 2>&1)
                
                if echo "$OUTPUT" | grep -q "Error"; then
                    echo -e "${RED}❌ ERRORS${NC}"
                    ((error_files++))
                    error_count=$(echo "$OUTPUT" | grep -c "Error")
                    ((total_errors += error_count))
                else
                    echo -e "${GREEN}✅ OK${NC}"
                fi
            fi
        done
        echo ""
    fi
done

# Vérifications supplémentaires
echo -e "${BLUE}📋 Vérifications supplémentaires${NC}"

# Vérifier les lignes trop longues (80 caractères)
echo -n "  Lignes > 80 caractères: "
LONG_LINES=$(find . -name "*.c" -o -name "*.h" 2>/dev/null | xargs wc -L 2>/dev/null | awk '$1 > 80 {count++} END {print count+0}')
if [ $LONG_LINES -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $LONG_LINES ligne(s) trop longue(s)${NC}"
else
    echo -e "${GREEN}✅ OK${NC}"
fi

# Vérifier les fonctions avec trop de paramètres (>4)
echo -n "  Fonctions > 4 paramètres: "
PARAM_COUNT=$(grep -r "^[a-zA-Z_][^(]*([^)]*,[^)]*,[^)]*,[^)]*,[^)]*)" . --include="*.c" --include="*.h" 2>/dev/null | wc -l)
if [ $PARAM_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $PARAM_COUNT fonction(s) avec >4 paramètres${NC}"
else
    echo -e "${GREEN}✅ OK${NC}"
fi

echo ""

# Résumé final
echo -e "${BLUE}📊 === RÉSUMÉ NORMINETTE ===${NC}"
echo "Fichiers testés: $total_files"
echo "Fichiers avec erreurs: $error_files"
echo "Total erreurs: $total_errors"
echo ""

if [ $total_files -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Aucun fichier .c ou .h trouvé${NC}"
    exit 1
elif [ $error_files -eq 0 ]; then
    echo -e "${GREEN}🎉 SUCCÈS: Tous les fichiers respectent la norme 42!${NC}"
    echo -e "${GREEN}✅ Code conforme pour l'évaluation${NC}"
    exit 0
else
    echo -e "${RED}❌ ÉCHEC: $error_files fichier(s) avec des erreurs${NC}"
    echo -e "${YELLOW}💡 Corrigez les erreurs ci-dessus${NC}"
    echo ""
    echo -e "${YELLOW}📖 Règles principales à vérifier:${NC}"
    echo "   • Max 25 lignes par fonction"
    echo "   • Max 5 fonctions par fichier"
    echo "   • Max 4 paramètres par fonction"
    echo "   • Max 80 caractères par ligne"
    echo "   • Pas d'espaces avant les noms de fonctions"
    exit 1
fi