#!/bin/bash

# ==================================================================================
# 🎯 MAÎTRE DES TESTS - SUITE COMPLÈTE MINISHELL
# ==================================================================================
# Orchestrateur principal qui exécute tous les niveaux de tests et génère le rapport final

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
MINISHELL="./minishell"
START_TIME=$(date +%s)
RAPPORT_FINAL="RAPPORT_FINAL_COMPLET_$(date +%Y%m%d_%H%M%S).md"

# Variables globales de comptage
TOTAL_TESTS_GLOBAL=0
PASSED_TESTS_GLOBAL=0
FAILED_TESTS_GLOBAL=0

# Tableaux pour stocker les résultats par niveau
declare -a NIVEAU_NAMES=("SIMPLES" "MOYENS" "EXTRÊMES" "EVIL")
declare -a NIVEAU_TOTAL=(0 0 0 0)
declare -a NIVEAU_PASSED=(0 0 0 0)
declare -a NIVEAU_FAILED=(0 0 0 0)
declare -a NIVEAU_STATUS=("" "" "" "")

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}🎯 MAÎTRE DES TESTS - MINISHELL BOMBARDMENT SUITE${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}Analyse complète et progressive de votre parser/expander${NC}"
    echo -e "${BOLD}${YELLOW}Niveaux: Simples → Moyens → Extrêmes → Evil${NC}"
    echo ""
    echo -e "${CYAN}Projet:${NC} Minishell Parser/Expander"
    echo -e "${CYAN}Date:${NC} $(date)"
    echo -e "${CYAN}Système:${NC} $(uname -a)"
    echo ""
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    echo -e "${PURPLE}🔍 Vérification des prérequis...${NC}"
    
    # Vérifier que minishell existe
    if [ ! -f "$MINISHELL" ]; then
        echo -e "${RED}❌ Erreur: $MINISHELL introuvable${NC}"
        echo -e "${YELLOW}💡 Assurez-vous de compiler votre projet avec 'make'${NC}"
        exit 1
    fi
    
    # Vérifier que minishell est exécutable
    if [ ! -x "$MINISHELL" ]; then
        echo -e "${RED}❌ Erreur: $MINISHELL n'est pas exécutable${NC}"
        chmod +x "$MINISHELL"
        echo -e "${GREEN}✅ Permissions corrigées${NC}"
    fi
    
    # Vérifier les scripts de test
    local test_scripts=("tests_simples.sh" "tests_moyens.sh" "tests_extremes.sh" "tests_evil.sh")
    for script in "${test_scripts[@]}"; do
        if [ ! -f "$script" ]; then
            echo -e "${RED}❌ Erreur: Script $script introuvable${NC}"
            exit 1
        fi
        if [ ! -x "$script" ]; then
            chmod +x "$script"
        fi
    done
    
    echo -e "${GREEN}✅ Tous les prérequis sont satisfaits${NC}"
    echo ""
}

# Fonction pour exécuter un niveau de tests
run_test_level() {
    local level_index="$1"
    local level_name="$2"
    local script_name="$3"
    local description="$4"
    local emoji="$5"
    
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$emoji NIVEAU $((level_index + 1)): TESTS $level_name${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$description${NC}"
    echo ""
    
    # Mesurer le temps d'exécution du niveau
    local start_level=$(date +%s)
    
    # Exécuter le script de test
    echo -e "${YELLOW}🚀 Lancement de $script_name...${NC}"
    echo ""
    
    ./"$script_name"
    local exit_code=$?
    
    local end_level=$(date +%s)
    local duration_level=$((end_level - start_level))
    
    # Extraire les résultats depuis le rapport d'erreurs
    local rapport_niveau=""
    case "$level_index" in
        0) rapport_niveau="rapport_erreurs_simples.md" ;;
        1) rapport_niveau="rapport_erreurs_moyens.md" ;;
        2) rapport_niveau="rapport_erreurs_extremes.md" ;;
        3) rapport_niveau="rapport_erreurs_evil.md" ;;
    esac
    
    # Parser les résultats si le rapport existe
    if [ -f "$rapport_niveau" ]; then
        local total_niveau=$(grep "Total des tests" "$rapport_niveau" | grep -o '[0-9]*' | head -1)
        local passed_niveau=$(grep "Tests réussis\\|Tests survivés" "$rapport_niveau" | grep -o '[0-9]*' | head -1)
        local failed_niveau=$(grep "Tests échoués" "$rapport_niveau" | grep -o '[0-9]*' | head -1)
        
        # Si on n'arrive pas à parser, utiliser des valeurs par défaut
        total_niveau=${total_niveau:-0}
        passed_niveau=${passed_niveau:-0}
        failed_niveau=${failed_niveau:-0}
        
        NIVEAU_TOTAL[$level_index]=$total_niveau
        NIVEAU_PASSED[$level_index]=$passed_niveau
        NIVEAU_FAILED[$level_index]=$failed_niveau
        
        # Calculer le taux de réussite
        local success_rate=0
        if [ "$total_niveau" -gt 0 ]; then
            success_rate=$((passed_niveau * 100 / total_niveau))
        fi
        
        # Déterminer le statut
        if [ "$failed_niveau" -eq 0 ]; then
            NIVEAU_STATUS[$level_index]="🏆 PARFAIT"
        elif [ "$success_rate" -ge 90 ]; then
            NIVEAU_STATUS[$level_index]="🥇 EXCELLENT"
        elif [ "$success_rate" -ge 75 ]; then
            NIVEAU_STATUS[$level_index]="🥈 TRÈS BIEN"
        elif [ "$success_rate" -ge 50 ]; then
            NIVEAU_STATUS[$level_index]="🥉 BIEN"
        else
            NIVEAU_STATUS[$level_index]="❌ À AMÉLIORER"
        fi
        
        # Mettre à jour les totaux globaux
        TOTAL_TESTS_GLOBAL=$((TOTAL_TESTS_GLOBAL + total_niveau))
        PASSED_TESTS_GLOBAL=$((PASSED_TESTS_GLOBAL + passed_niveau))
        FAILED_TESTS_GLOBAL=$((FAILED_TESTS_GLOBAL + failed_niveau))
    else
        NIVEAU_STATUS[$level_index]="⚠️ ERREUR"
    fi
    
    echo ""
    echo -e "${BOLD}${PURPLE}📊 Résumé Niveau $level_name:${NC}"
    echo -e "  Total: ${NIVEAU_TOTAL[$level_index]} tests"
    echo -e "  Réussis: ${NIVEAU_PASSED[$level_index]} tests"
    echo -e "  Échoués: ${NIVEAU_FAILED[$level_index]} tests"
    echo -e "  Statut: ${NIVEAU_STATUS[$level_index]}"
    echo -e "  Durée: ${duration_level}s"
    echo ""
    
    # Pause entre les niveaux (sauf pour le dernier)
    if [ "$level_index" -lt 3 ]; then
        echo -e "${YELLOW}⏸️  Pause de 3 secondes avant le niveau suivant...${NC}"
        sleep 3
        echo ""
    fi
}

# Fonction pour générer le rapport final complet
generate_final_report() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    local global_success_rate=0
    
    if [ "$TOTAL_TESTS_GLOBAL" -gt 0 ]; then
        global_success_rate=$((PASSED_TESTS_GLOBAL * 100 / TOTAL_TESTS_GLOBAL))
    fi
    
    # Déterminer l'évaluation globale
    local evaluation_globale=""
    local recommendation=""
    
    if [ "$FAILED_TESTS_GLOBAL" -eq 0 ]; then
        evaluation_globale="🏆 ULTRA-ROBUSTE - PARFAIT"
        recommendation="Votre minishell est parfait ! Prêt pour l'intégration avec l'executor."
    elif [ "$global_success_rate" -ge 95 ]; then
        evaluation_globale="🥇 EXCELLENT - QUASI-PARFAIT"
        recommendation="Excellent travail ! Quelques détails mineurs à corriger."
    elif [ "$global_success_rate" -ge 85 ]; then
        evaluation_globale="🥈 TRÈS BIEN - ROBUSTE"
        recommendation="Très bon travail ! Quelques améliorations recommandées."
    elif [ "$global_success_rate" -ge 70 ]; then
        evaluation_globale="🥉 BIEN - SOLIDE"
        recommendation="Bon travail ! Plusieurs points à améliorer."
    else
        evaluation_globale="❌ À AMÉLIORER - PROBLÉMATIQUE"
        recommendation="Des corrections importantes sont nécessaires."
    fi
    
    # Créer le rapport final
    cat > "$RAPPORT_FINAL" << EOF
# 🎯 RAPPORT FINAL COMPLET - TESTS MINISHELL

## 📋 Informations Générales

**Date d'exécution:** $(date)  
**Durée totale:** ${total_duration} secondes  
**Système:** $(uname -a)  
**Projet:** Minishell Parser/Expander  
**Utilisateur:** $(whoami)  

---

## 📊 RÉSULTATS GLOBAUX

### 🎯 Vue d'ensemble
- **Total des tests exécutés:** $TOTAL_TESTS_GLOBAL
- **Tests réussis:** $PASSED_TESTS_GLOBAL
- **Tests échoués:** $FAILED_TESTS_GLOBAL
- **Taux de réussite global:** ${global_success_rate}%

### 🏆 Évaluation finale
**$evaluation_globale**

### 💡 Recommandation
$recommendation

---

## 📈 DÉTAIL PAR NIVEAU

EOF

    # Ajouter les détails de chaque niveau
    for i in {0..3}; do
        local level_name="${NIVEAU_NAMES[$i]}"
        local level_success_rate=0
        
        if [ "${NIVEAU_TOTAL[$i]}" -gt 0 ]; then
            level_success_rate=$((NIVEAU_PASSED[$i] * 100 / NIVEAU_TOTAL[$i]))
        fi
        
        cat >> "$RAPPORT_FINAL" << EOF
### 📋 Niveau $((i + 1)): Tests $level_name

- **Status:** ${NIVEAU_STATUS[$i]}
- **Total:** ${NIVEAU_TOTAL[$i]} tests
- **Réussis:** ${NIVEAU_PASSED[$i]} tests
- **Échoués:** ${NIVEAU_FAILED[$i]} tests
- **Taux de réussite:** ${level_success_rate}%

EOF
    done
    
    # Ajouter l'analyse détaillée
    cat >> "$RAPPORT_FINAL" << EOF
---

## 🔍 ANALYSE DÉTAILLÉE

### ✅ Points forts identifiés
EOF

    # Analyser les points forts
    for i in {0..3}; do
        if [ "${NIVEAU_FAILED[$i]}" -eq 0 ] && [ "${NIVEAU_TOTAL[$i]}" -gt 0 ]; then
            echo "- 🏆 **Tests ${NIVEAU_NAMES[$i]}:** Parfaitement maîtrisés (${NIVEAU_TOTAL[$i]}/${NIVEAU_TOTAL[$i]})" >> "$RAPPORT_FINAL"
        fi
    done
    
    cat >> "$RAPPORT_FINAL" << EOF

### ⚠️ Points d'amélioration
EOF

    # Analyser les points faibles
    for i in {0..3}; do
        if [ "${NIVEAU_FAILED[$i]}" -gt 0 ]; then
            echo "- ⚠️ **Tests ${NIVEAU_NAMES[$i]}:** ${NIVEAU_FAILED[$i]} échecs sur ${NIVEAU_TOTAL[$i]} tests" >> "$RAPPORT_FINAL"
        fi
    done
    
    cat >> "$RAPPORT_FINAL" << EOF

---

## 📄 RAPPORTS DÉTAILLÉS

Les rapports détaillés de chaque niveau sont disponibles dans :
- 🟢 Tests simples: \`rapport_erreurs_simples.md\`
- 🟡 Tests moyens: \`rapport_erreurs_moyens.md\`
- 🔥 Tests extrêmes: \`rapport_erreurs_extremes.md\`
- 💀 Tests evil: \`rapport_erreurs_evil.md\`

---

## 🎯 CONCLUSION

EOF

    if [ "$FAILED_TESTS_GLOBAL" -eq 0 ]; then
        cat >> "$RAPPORT_FINAL" << EOF
🎉 **FÉLICITATIONS !** 

Votre minishell a passé TOUS les tests avec succès !

### Accomplissements:
- ✅ Parsing parfait
- ✅ Expansion de variables robuste  
- ✅ Gestion d'erreurs excellente
- ✅ Résistance aux attaques
- ✅ Performance optimale

### Status: PRÊT POUR PRODUCTION
Votre parser/expander est prêt pour l'intégration avec l'executor.
EOF
    else
        cat >> "$RAPPORT_FINAL" << EOF
### Prochaines étapes recommandées:

1. **Corriger les erreurs identifiées** dans les rapports détaillés
2. **Renforcer la robustesse** pour les cas extrêmes
3. **Améliorer la gestion des erreurs** pour les cas problématiques
4. **Re-exécuter les tests** après corrections

### Priorités:
EOF
        
        # Prioriser les corrections selon le niveau
        if [ "${NIVEAU_FAILED[0]}" -gt 0 ]; then
            echo "- 🔴 **HAUTE:** Corriger les tests simples (bases du parsing)" >> "$RAPPORT_FINAL"
        fi
        if [ "${NIVEAU_FAILED[1]}" -gt 0 ]; then
            echo "- 🟡 **MOYENNE:** Améliorer les tests moyens (robustesse)" >> "$RAPPORT_FINAL"
        fi
        if [ "${NIVEAU_FAILED[2]}" -gt 0 ]; then
            echo "- 🟠 **BASSE:** Optimiser pour les cas extrêmes (performance)" >> "$RAPPORT_FINAL"
        fi
        if [ "${NIVEAU_FAILED[3]}" -gt 0 ]; then
            echo "- 🟣 **OPTIONNELLE:** Renforcer la sécurité (tests evil)" >> "$RAPPORT_FINAL"
        fi
    fi
    
    cat >> "$RAPPORT_FINAL" << EOF

---

*Rapport généré automatiquement par la Suite de Tests Complète Minishell*  
*Temps d'exécution: ${total_duration} secondes*  
*Date: $(date)*
EOF
}

# Fonction pour afficher le résumé final
show_final_summary() {
    local global_success_rate=$((PASSED_TESTS_GLOBAL * 100 / TOTAL_TESTS_GLOBAL))
    
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}📊 RÉSUMÉ FINAL - SUITE COMPLÈTE DE TESTS${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${BOLD}${CYAN}🎯 STATISTIQUES GLOBALES${NC}"
    echo -e "  Total des tests: ${BOLD}$TOTAL_TESTS_GLOBAL${NC}"
    echo -e "  Tests réussis: ${BOLD}${GREEN}$PASSED_TESTS_GLOBAL${NC}"
    echo -e "  Tests échoués: ${BOLD}${RED}$FAILED_TESTS_GLOBAL${NC}"
    echo -e "  Taux de réussite: ${BOLD}${global_success_rate}%${NC}"
    echo ""
    
    echo -e "${BOLD}${PURPLE}📈 RÉSULTATS PAR NIVEAU${NC}"
    for i in {0..3}; do
        local level_name="${NIVEAU_NAMES[$i]}"
        local level_emoji=""
        case "$i" in
            0) level_emoji="🟢" ;;
            1) level_emoji="🟡" ;;
            2) level_emoji="🔥" ;;
            3) level_emoji="💀" ;;
        esac
        
        echo -e "  $level_emoji $level_name: ${NIVEAU_PASSED[$i]}/${NIVEAU_TOTAL[$i]} - ${NIVEAU_STATUS[$i]}"
    done
    echo ""
    
    # Afficher l'évaluation finale
    if [ "$FAILED_TESTS_GLOBAL" -eq 0 ]; then
        echo -e "${BOLD}${GREEN}🏆 ÉVALUATION: PARFAIT - ULTRA-ROBUSTE${NC}"
        echo -e "${BOLD}${GREEN}🎉 FÉLICITATIONS ! Votre minishell est parfait !${NC}"
        echo -e "${BOLD}${GREEN}✅ Prêt pour l'intégration avec l'executor${NC}"
    elif [ "$global_success_rate" -ge 95 ]; then
        echo -e "${BOLD}${GREEN}🥇 ÉVALUATION: EXCELLENT - QUASI-PARFAIT${NC}"
        echo -e "${BOLD}${GREEN}👏 Excellent travail ! Quelques détails mineurs${NC}"
    elif [ "$global_success_rate" -ge 85 ]; then
        echo -e "${BOLD}${YELLOW}🥈 ÉVALUATION: TRÈS BIEN - ROBUSTE${NC}"
        echo -e "${BOLD}${YELLOW}👍 Très bon travail ! Quelques améliorations${NC}"
    elif [ "$global_success_rate" -ge 70 ]; then
        echo -e "${BOLD}${YELLOW}🥉 ÉVALUATION: BIEN - SOLIDE${NC}"
        echo -e "${BOLD}${YELLOW}⚡ Bon travail ! Plusieurs points à améliorer${NC}"
    else
        echo -e "${BOLD}${RED}❌ ÉVALUATION: À AMÉLIORER${NC}"
        echo -e "${BOLD}${RED}🔧 Des corrections importantes sont nécessaires${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}📄 Rapport détaillé généré: $RAPPORT_FINAL${NC}"
    echo ""
}

# ==================================================================================
# 🚀 EXÉCUTION PRINCIPALE
# ==================================================================================

# Afficher le header
show_header

# Vérifier les prérequis
check_prerequisites

echo -e "${BOLD}${YELLOW}🚀 DÉMARRAGE DE LA SUITE COMPLÈTE DE TESTS${NC}"
echo -e "${YELLOW}Cette suite va exécuter 4 niveaux de tests progressifs:${NC}"
echo -e "${GREEN}  🟢 Niveau 1: Tests simples (fonctionnalités de base)${NC}"
echo -e "${YELLOW}  🟡 Niveau 2: Tests moyens (cas complexes)${NC}"
echo -e "${RED}  🔥 Niveau 3: Tests extrêmes (stress et limites)${NC}"
echo -e "${PURPLE}  💀 Niveau 4: Tests evil (sécurité et malveillance)${NC}"
echo ""
echo -e "${CYAN}⏱️  Temps estimé: 5-10 minutes selon la performance${NC}"
echo ""

read -p "Appuyez sur Entrée pour commencer les tests..."
echo ""

# Exécuter chaque niveau de tests
run_test_level 0 "SIMPLES" "tests_simples.sh" "Tests de base: commandes simples, variables, quotes basiques" "🟢"
run_test_level 1 "MOYENS" "tests_moyens.sh" "Tests intermédiaires: combinaisons, cas complexes" "🟡"
run_test_level 2 "EXTRÊMES" "tests_extremes.sh" "Tests intensifs: stress, limites, performance" "🔥"
run_test_level 3 "EVIL" "tests_evil.sh" "Tests malveillants: sécurité, vulnérabilités" "💀"

# Générer le rapport final
echo -e "${PURPLE}📝 Génération du rapport final...${NC}"
generate_final_report

# Afficher le résumé final
show_final_summary

# Code de sortie basé sur les résultats
if [ "$FAILED_TESTS_GLOBAL" -eq 0 ]; then
    exit 0  # Parfait
elif [ "$((PASSED_TESTS_GLOBAL * 100 / TOTAL_TESTS_GLOBAL))" -ge 85 ]; then
    exit 1  # Très bien
else
    exit 2  # À améliorer
fi
