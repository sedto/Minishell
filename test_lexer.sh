#!/bin/bash

# Script de test pour le lexer de minishell
# Usage: ./test_lexer.sh

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

echo -e "${BLUE}🧪 ===== TESTS DU LEXER MINISHELL =====${NC}\n"

# Fonction pour tester une commande
test_command() {
    local input="$1"
    local description="$2"
    local category="$3"
    
    echo -e "${PURPLE}--- $description ---${NC}"
    echo -e "${CYAN}Input:${NC} \"$input\""
    echo -e "${YELLOW}Expected behavior:${NC} $category"
    echo "$input" | ./minishell | grep -A 10 "=== Test du lexer ===" | head -4
    echo ""
}

# TESTS BASIQUES
echo -e "${GREEN}📌 TESTS BASIQUES${NC}"
test_command "echo hello" "Commande simple" "2 mots"
test_command "ls -la" "Commande avec option" "2 mots"
test_command "pwd" "Commande seule" "1 mot"

# TESTS AVEC QUOTES
echo -e "${GREEN}📌 TESTS AVEC QUOTES${NC}"
test_command 'echo "hello world"' "Quotes doubles" "2 tokens (echo + string quotée)"
test_command "echo 'single quotes'" "Quotes simples" "2 tokens (echo + string quotée)"
test_command 'echo "hello" world' "Quotes + mot normal" "3 tokens"
test_command 'echo "test with spaces   inside"' "Espaces dans quotes" "Espaces préservés"

# TESTS OPÉRATEURS SIMPLES
echo -e "${GREEN}📌 TESTS OPÉRATEURS SIMPLES${NC}"
test_command "ls | grep test" "Pipe simple" "4 tokens (ls, |, grep, test)"
test_command "cat < input.txt" "Redirection entrée" "3 tokens (cat, <, file)"
test_command "echo hello > output.txt" "Redirection sortie" "4 tokens (echo, hello, >, file)"

# TESTS OPÉRATEURS DOUBLES  
echo -e "${GREEN}📌 TESTS OPÉRATEURS DOUBLES${NC}"
test_command "echo test >> log.txt" "Append" "4 tokens avec >>"
test_command "cat << EOF" "Heredoc" "3 tokens avec <<"
test_command "wc < input >> output" "< et >> combinés" "5 tokens"

# TESTS COMPLEXES
echo -e "${GREEN}📌 TESTS COMPLEXES${NC}"
test_command 'ls -la | grep ".txt" > results' "Pipeline + redirection" "7 tokens"
test_command "cat file1 file2 | sort | uniq" "Pipeline multiple" "7 tokens"
test_command 'echo "pipe | inside quotes"' "Pipe dans quotes" "Pipe doit être dans le string"

# TESTS EDGE CASES
echo -e "${GREEN}📌 TESTS EDGE CASES${NC}"
test_command 'echo"hello"world' "Mots collés avec quotes" "Gestion quotes collées"
test_command "ls>output" "Opérateur collé" "3 tokens (ls, >, output)"
test_command "cat<<EOF" "Heredoc collé" "2 tokens (cat, <<, EOF)"
test_command "  echo   hello  " "Espaces multiples" "Espaces normalisés"

# TESTS AVEC VARIABLES (si implémenté)
echo -e "${GREEN}📌 TESTS AVEC VARIABLES${NC}"
test_command 'echo $HOME' "Variable simple" "TOKEN_WORD avec \$"
test_command 'echo "$USER is home"' "Variable dans quotes" "Expansion à venir"
test_command 'echo $?' "Exit status" "Variable spéciale"

# TESTS FICHIERS ET CHEMINS
echo -e "${GREEN}📌 TESTS FICHIERS ET CHEMINS${NC}"
test_command "./program arg1 arg2" "Chemin relatif" "3 tokens"
test_command "/bin/ls -la" "Chemin absolu" "2 tokens"
test_command 'cat "file with spaces.txt"' "Fichier avec espaces" "Nom de fichier quoté"

# TESTS COMBINAISONS AVANCÉES
echo -e "${GREEN}📌 TESTS COMBINAISONS AVANCÉES${NC}"
test_command 'echo "start" | cat | wc -l > "count file"' "Combinaison complète" "Multiples opérateurs"
test_command "< input.txt grep pattern | sort >> output.txt" "Redirection complexe" "6 tokens"
test_command 'cat << "EOF" > output' "Heredoc + redirection" "Combinaison <<  et >"

# TESTS LIMITES
echo -e "${GREEN}📌 TESTS LIMITES${NC}"
test_command "" "String vide" "Pas de tokens (sauf EOF)"
test_command "   " "Que des espaces" "Pas de tokens (sauf EOF)"
test_command "|" "Pipe seul" "1 token PIPE"
test_command "<>" "Redirections collées" "2 tokens < et >"

# TESTS QUOTES SPÉCIAUX
echo -e "${GREEN}📌 TESTS QUOTES SPÉCIAUX${NC}"
test_command 'echo ""' "Quotes vides" "String vide quotée"
test_command "echo ''" "Single quotes vides" "String vide quotée"
test_command 'echo "test'"'"'more"' "Quotes imbriquées" "Gestion complexe quotes"

# RÉSUMÉ
echo -e "${BLUE}🎯 ===== RÉSUMÉ DES TESTS =====${NC}"
echo -e "${CYAN}Si tous les tests affichent correctement leurs tokens:${NC}"
echo -e "${GREEN}✅ Votre lexer fonctionne parfaitement !${NC}"
echo -e "${CYAN}Vérifiez particulièrement:${NC}"
echo -e "   • Les quotes sont préservées dans les tokens"
echo -e "   • Les opérateurs doubles (<<, >>) sont bien détectés" 
echo -e "   • Les espaces dans les quotes sont conservés"
echo -e "   • Chaque test se termine par [EOF:\"\"]"
echo ""
echo -e "${YELLOW}Prochaine étape: Implémenter le parser ! 🚀${NC}"