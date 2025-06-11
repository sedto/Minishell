#!/bin/bash

# Script de test pour l'expander de variables de minishell
# Usage: ./test_expander.sh

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Vérifier que minishell existe
if [ ! -f "./minishell" ]; then
    echo -e "${RED}❌ Erreur: minishell non trouvé${NC}"
    echo "Compilez d'abord avec: make"
    exit 1
fi

echo -e "${BLUE}🧪 ===== TESTS DE L'EXPANDER DE VARIABLES =====${NC}\n"

# Fonction pour tester une commande avec expansion
test_expansion() {
    local input="$1"
    local description="$2"
    local expected_expansion="$3"
    
    echo -e "${PURPLE}--- $description ---${NC}"
    echo -e "${CYAN}Input:${NC} \"$input\""
    echo -e "${YELLOW}Expected expansion:${NC} $expected_expansion"
    echo "$input" | ./minishell | grep -A 15 "=== Test du lexer avec expansion ===" | head -10
    echo ""
}

# TESTS VARIABLES SIMPLES
echo -e "${GREEN}📌 TESTS VARIABLES SIMPLES${NC}"
test_expansion "echo \$USER" "Variable USER simple" "echo [USER_VALUE]"
test_expansion "echo \$HOME" "Variable HOME simple" "echo [HOME_VALUE]"
test_expansion "echo \$PWD" "Variable PWD simple" "echo [PWD_VALUE]"
test_expansion "echo \$PATH" "Variable PATH simple" "echo [PATH_VALUE]"

# TESTS VARIABLES SPÉCIALES
echo -e "${GREEN}📌 TESTS VARIABLES SPÉCIALES${NC}"
test_expansion "echo \$?" "Exit status" "echo 0"
test_expansion "echo \$\$" "Process ID" "echo [PID]"
test_expansion "echo \$0" "Program name" "echo minishell"

# TESTS VARIABLES DANS QUOTES
echo -e "${GREEN}📌 TESTS VARIABLES DANS QUOTES${NC}"
test_expansion "echo \"Hello \$USER\"" "Variable dans double quotes" "echo \"Hello [USER_VALUE]\""
test_expansion "echo 'Hello \$USER'" "Variable dans single quotes" "echo 'Hello \$USER' (PAS d'expansion)"
test_expansion "echo \"\$USER is at \$HOME\"" "Multiples variables dans double quotes" "echo \"[USER_VALUE] is at [HOME_VALUE]\""

# TESTS VARIABLES MULTIPLES
echo -e "${GREEN}📌 TESTS VARIABLES MULTIPLES${NC}"
test_expansion "echo \$USER \$HOME" "Variables séparées" "echo [USER_VALUE] [HOME_VALUE]"
test_expansion "echo \$USER\$HOME" "Variables concaténées" "echo [USER_VALUE][HOME_VALUE]"
test_expansion "echo \$USER/\$HOME/file" "Variables avec texte" "echo [USER_VALUE]/[HOME_VALUE]/file"

# TESTS VARIABLES INEXISTANTES
echo -e "${GREEN}📌 TESTS VARIABLES INEXISTANTES${NC}"
test_expansion "echo \$INEXISTANTE" "Variable inexistante" "echo \"\" (chaîne vide)"
test_expansion "echo \$NONEXISTENT_VAR" "Autre variable inexistante" "echo \"\" (chaîne vide)"
test_expansion "echo before\$INEXISTANTE" "Variable inexistante concaténée" "echo before"

# TESTS EDGE CASES
echo -e "${GREEN}📌 TESTS EDGE CASES${NC}"
test_expansion "echo \$" "Dollar seul" "echo \$ (pas d'expansion)"
test_expansion "echo \$USER\$" "Variable + dollar" "echo [USER_VALUE]\$"
test_expansion "echo \$USERtest" "Variable + texte direct" "echo [USERTEST_VALUE] ou [USER_VALUE]test"
test_expansion "echo \${USER}" "Variable avec accolades" "echo [USER_VALUE] (si supporté)"

# TESTS COMBINAISONS COMPLEXES
echo -e "${GREEN}📌 TESTS COMBINAISONS COMPLEXES${NC}"
test_expansion "ls \$HOME" "Commande avec variable" "ls [HOME_VALUE]"
test_expansion "cat \$HOME/file.txt" "Chemin avec variable" "cat [HOME_VALUE]/file.txt"
test_expansion "echo \$USER | grep \$USER" "Variable dans pipeline" "echo [USER_VALUE] | grep [USER_VALUE]"
test_expansion "echo \$USER > \$HOME/output" "Variable avec redirection" "echo [USER_VALUE] > [HOME_VALUE]/output"

# TESTS AVEC OPÉRATEURS
echo -e "${GREEN}📌 TESTS AVEC OPÉRATEURS${NC}"
test_expansion "echo \$USER | wc -l" "Variable + pipe" "Expansion puis pipe"
test_expansion "echo \$HOME > output" "Variable + redirection" "Expansion puis redirection"
test_expansion "cat < \$HOME/input" "Variable dans redirection" "cat < [HOME_VALUE]/input"

# TESTS QUOTES MIXTES
echo -e "${GREEN}📌 TESTS QUOTES MIXTES${NC}"
test_expansion "echo '\$USER' \"\$HOME\"" "Single + double quotes" "echo '\$USER' \"[HOME_VALUE]\""
test_expansion "echo \"\$USER's home is \$HOME\"" "Apostrophe dans double quotes" "echo \"[USER_VALUE]'s home is [HOME_VALUE]\""

# TESTS AVEC ESPACES
echo -e "${GREEN}📌 TESTS AVEC ESPACES${NC}"
test_expansion "echo   \$USER   \$HOME  " "Variables avec espaces" "Espaces normalisés + expansion"
test_expansion "echo \"\$USER   \$HOME\"" "Variables avec espaces dans quotes" "Espaces préservés + expansion"

# VALIDATION AUTOMATIQUE
echo -e "${GREEN}📌 VALIDATION AUTOMATIQUE${NC}"
echo -e "${CYAN}Vérification des variables d'environnement actuelles:${NC}"
echo -e "USER = $USER"
echo -e "HOME = $HOME"
echo -e "PWD = $PWD"
echo ""

# TEST FINAL AVEC COMMANDE RÉELLE
echo -e "${GREEN}📌 TEST FINAL${NC}"
test_expansion "echo \"Utilisateur \$USER dans \$HOME\"" "Test complet" "echo \"Utilisateur $USER dans $HOME\""

# RÉSUMÉ
echo -e "${BLUE}🎯 ===== RÉSUMÉ DES TESTS D'EXPANSION =====${NC}"
echo -e "${CYAN}Si tous les tests affichent les bonnes expansions:${NC}"
echo -e "${GREEN}✅ Votre expander fonctionne parfaitement !${NC}"
echo -e "${CYAN}Vérifiez particulièrement:${NC}"
echo -e "   • Les variables sont bien remplacées par leurs valeurs"
echo -e "   • Les single quotes empêchent l'expansion"
echo -e "   • Les double quotes permettent l'expansion"
echo -e "   • Les variables inexistantes deviennent des chaînes vides"
echo -e "   • Les variables spéciales (\$?, \$\$, \$0) fonctionnent"
echo ""
echo -e "${YELLOW}Prochaine étape: Implémenter l'executor ! 🚀${NC}"
