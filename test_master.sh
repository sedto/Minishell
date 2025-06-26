#!/bin/bash

# ================================================================================================
# 🎯 MAÎTRE DE TESTS - SUITE COMPLÈTE MINISHELL
# ================================================================================================

# Couleurs
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
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# ================================================================================================
# 🎨 INTERFACE UTILISATEUR
# ================================================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                      ║"
    echo "║                    🧪 SUITE COMPLÈTE DE TESTS MINISHELL 🧪                         ║"
    echo "║                                                                                      ║"
    echo "║  🟢 Niveau 1: Tests Simples        🟡 Niveau 2: Tests Intermédiaires              ║"
    echo "║  🔴 Niveau 3: Tests Avancés        🔥 Tests de Stress Extrêmes                    ║"
    echo "║                                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_separator() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ================================================================================================
# 🔧 FONCTIONS UTILITAIRES
# ================================================================================================

check_prerequisites() {
    echo -e "${CYAN}🔍 Vérification des prérequis...${NC}"
    
    # Vérifier la compilation
    if [ ! -f "$MINISHELL" ]; then
        echo -e "${YELLOW}⚠️  Minishell non trouvé. Compilation en cours...${NC}"
        make clean && make
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Erreur de compilation. Arrêt des tests.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Compilation réussie${NC}"
    else
        echo -e "${GREEN}✅ Minishell trouvé${NC}"
    fi
    
    # Vérifier les scripts de test
    local test_scripts=("test_suite_complete.sh" "test_stress_extreme.sh")
    for script in "${test_scripts[@]}"; do
        if [ ! -f "$script" ]; then
            echo -e "${RED}❌ Script de test manquant: $script${NC}"
            exit 1
        fi
        chmod +x "$script"
    done
    echo -e "${GREEN}✅ Scripts de test prêts${NC}"
    
    echo ""
}

# ================================================================================================
# 🧪 EXÉCUTION DES SUITES DE TESTS
# ================================================================================================

run_complete_test_suite() {
    echo -e "${BOLD}${BLUE}🧪 EXÉCUTION DE LA SUITE COMPLÈTE DE TESTS${NC}"
    print_separator
    echo ""
    
    echo -e "${CYAN}📊 Lancement des tests standards (niveaux 1-3)...${NC}"
    ./test_suite_complete.sh > complete_test_output.log 2>&1
    local complete_exit_code=$?
    
    if [ $complete_exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Suite complète terminée avec succès${NC}"
    else
        echo -e "${YELLOW}⚠️  Suite complète terminée avec des échecs${NC}"
    fi
    
    echo ""
}

run_stress_test_suite() {
    echo -e "${BOLD}${RED}🔥 EXÉCUTION DES TESTS DE STRESS EXTRÊMES${NC}"
    print_separator
    echo ""
    
    echo -e "${CYAN}⚡ Lancement des tests de stress...${NC}"
    ./test_stress_extreme.sh > stress_test_output.log 2>&1
    local stress_exit_code=$?
    
    if [ $stress_exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Tests de stress terminés avec succès${NC}"
    else
        echo -e "${YELLOW}⚠️  Tests de stress terminés avec des échecs${NC}"
    fi
    
    echo ""
}

# ================================================================================================
# 📊 ANALYSE ET CONSOLIDATION DES RÉSULTATS
# ================================================================================================

analyze_results() {
    echo -e "${BOLD}${PURPLE}📊 ANALYSE CONSOLIDÉE DES RÉSULTATS${NC}"
    print_separator
    echo ""
    
    # Extraction des statistiques de la suite complète
    local complete_stats=""
    local complete_total=0
    local complete_passed=0
    local complete_failed=0
    
    if [ -f "test_report.txt" ]; then
        complete_stats=$(head -2 test_report.txt | tail -1)
        complete_total=$(echo "$complete_stats" | grep -o 'Total: [0-9]*' | grep -o '[0-9]*')
        complete_passed=$(echo "$complete_stats" | grep -o 'Réussis: [0-9]*' | grep -o '[0-9]*')
        complete_failed=$(echo "$complete_stats" | grep -o 'Échoués: [0-9]*' | grep -o '[0-9]*')
    fi
    
    # Extraction des statistiques de stress
    local stress_stats=""
    local stress_total=0
    local stress_passed=0
    local stress_failed=0
    
    if [ -f "stress_report.txt" ]; then
        stress_stats=$(head -2 stress_report.txt | tail -1)
        stress_total=$(echo "$stress_stats" | grep -o 'Total: [0-9]*' | grep -o '[0-9]*')
        stress_passed=$(echo "$stress_stats" | grep -o 'Réussis: [0-9]*' | grep -o '[0-9]*')
        stress_failed=$(echo "$stress_stats" | grep -o 'Échoués: [0-9]*' | grep -o '[0-9]*')
    fi
    
    # Calculs consolidés
    local total_tests=$((complete_total + stress_total))
    local total_passed=$((complete_passed + stress_passed))
    local total_failed=$((complete_failed + stress_failed))
    local success_rate=0
    
    if [ $total_tests -gt 0 ]; then
        success_rate=$(( total_passed * 100 / total_tests ))
    fi
    
    # Affichage des résultats consolidés
    echo -e "${CYAN}📈 STATISTIQUES CONSOLIDÉES${NC}"
    echo "┌─────────────────────────────────────────────────────────────────────────────────────┐"
    echo "│                                RÉSULTATS GLOBAUX                                   │"
    echo "├─────────────────────────────────────────────────────────────────────────────────────┤"
    printf "│ %-30s │ %10s │ %10s │ %10s │ %10s │\n" "CATÉGORIE" "TOTAL" "RÉUSSIS" "ÉCHOUÉS" "TAUX"
    echo "├─────────────────────────────────────────────────────────────────────────────────────┤"
    
    if [ $complete_total -gt 0 ]; then
        local complete_rate=$(( complete_passed * 100 / complete_total ))
        printf "│ %-30s │ %10d │ %10d │ %10d │ %9d%% │\n" "Tests Standards" $complete_total $complete_passed $complete_failed $complete_rate
    fi
    
    if [ $stress_total -gt 0 ]; then
        local stress_rate=$(( stress_passed * 100 / stress_total ))
        printf "│ %-30s │ %10d │ %10d │ %10d │ %9d%% │\n" "Tests de Stress" $stress_total $stress_passed $stress_failed $stress_rate
    fi
    
    echo "├─────────────────────────────────────────────────────────────────────────────────────┤"
    printf "│ %-30s │ %10d │ %10d │ %10d │ %9d%% │\n" "TOTAL CONSOLIDÉ" $total_tests $total_passed $total_failed $success_rate
    echo "└─────────────────────────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Évaluation globale
    echo -e "${CYAN}🎯 ÉVALUATION GLOBALE DU MINISHELL${NC}"
    echo "┌─────────────────────────────────────────────────────────────────────────────────────┐"
    if [ $success_rate -ge 95 ]; then
        echo -e "│ 🏆 ${GREEN}EXCELLENCE${NC} - Minishell de qualité industrielle                          │"
        echo -e "│ 🚀 Prêt pour la production                                                     │"
        echo -e "│ ⭐ Robustesse exceptionnelle                                                  │"
    elif [ $success_rate -ge 90 ]; then
        echo -e "│ 🥇 ${GREEN}TRÈS HAUTE QUALITÉ${NC} - Minishell robuste et fiable                     │"
        echo -e "│ ✅ Excellent niveau de conformité                                             │"
        echo -e "│ 🔧 Quelques optimisations mineures possibles                                 │"
    elif [ $success_rate -ge 85 ]; then
        echo -e "│ 🥈 ${YELLOW}HAUTE QUALITÉ${NC} - Minishell bien implémenté                            │"
        echo -e "│ 👍 Bon niveau de fonctionnalité                                              │"
        echo -e "│ 🔨 Améliorations recommandées pour les cas edge                              │"
    elif [ $success_rate -ge 70 ]; then
        echo -e "│ 🥉 ${YELLOW}QUALITÉ ACCEPTABLE${NC} - Fonctionnalités de base solides                 │"
        echo -e "│ ⚠️  Corrections nécessaires pour la robustesse                               │"
        echo -e "│ 📚 Révision des cas complexes recommandée                                    │"
    else
        echo -e "│ 💥 ${RED}NÉCESSITE DES AMÉLIORATIONS${NC} - Corrections importantes requises         │"
        echo -e "│ 🔧 Révision approfondie nécessaire                                           │"
        echo -e "│ 📖 Consultation de la documentation recommandée                              │"
    fi
    echo "└─────────────────────────────────────────────────────────────────────────────────────┘"
    echo ""
    
    return $total_failed
}

# ================================================================================================
# 📄 GÉNÉRATION DU RAPPORT FINAL
# ================================================================================================

generate_final_report() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    echo -e "${BOLD}${CYAN}📄 GÉNÉRATION DU RAPPORT FINAL${NC}"
    print_separator
    echo ""
    
    # Créer le rapport final consolidé
    cat > rapport_final_${TIMESTAMP}.md << EOF
# 📊 RAPPORT FINAL - TESTS MINISHELL

**Date d'exécution :** $(date)  
**Durée totale :** ${duration}s  
**Version :** Complète (Standards + Stress)

## 🎯 Résumé Exécutif

$(analyze_results > /dev/null 2>&1; echo "Tests exécutés avec $([ $? -eq 0 ] && echo "succès" || echo "échecs partiels")")

## 📈 Détails des Tests Standards

EOF
    
    # Ajouter les détails des tests standards
    if [ -f "complete_test_output.log" ]; then
        echo "### Sortie complète des tests standards" >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        tail -50 complete_test_output.log >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        echo "" >> rapport_final_${TIMESTAMP}.md
    fi
    
    # Ajouter les résultats de stress
    if [ -f "stress_test_output.log" ]; then
        echo "### Sortie des tests de stress" >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        tail -30 stress_test_output.log >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        echo "" >> rapport_final_${TIMESTAMP}.md
    fi
    
    # Ajouter les échecs détaillés
    echo "## ❌ Tests Échoués (Analyse détaillée)" >> rapport_final_${TIMESTAMP}.md
    echo "" >> rapport_final_${TIMESTAMP}.md
    
    if [ -f "test_report.txt" ]; then
        echo "### Tests Standards Échoués" >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        grep -A 1000 "TESTS ÉCHOUÉS:" test_report.txt >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        echo "" >> rapport_final_${TIMESTAMP}.md
    fi
    
    if [ -f "stress_report.txt" ]; then
        echo "### Tests de Stress Échoués" >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        grep -A 1000 "TESTS DE STRESS ÉCHOUÉS:" stress_report.txt >> rapport_final_${TIMESTAMP}.md
        echo '```' >> rapport_final_${TIMESTAMP}.md
        echo "" >> rapport_final_${TIMESTAMP}.md
    fi
    
    # Recommandations
    cat >> rapport_final_${TIMESTAMP}.md << EOF

## 🎯 Recommandations

### Actions Prioritaires
1. **Corriger les tests échoués** listés ci-dessus
2. **Vérifier la gestion mémoire** pour les tests de stress
3. **Améliorer la robustesse** pour les cas edge

### Tests de Régression
- Réexécuter cette suite après chaque correction
- Valider que les corrections n'introduisent pas de régressions
- Monitorer les performances sur les tests de stress

### Prochaines Étapes
- Intégration continue avec cette suite de tests
- Tests de charge en conditions réelles
- Validation avec des scripts shell complexes

---
*Rapport généré automatiquement par la suite de tests Minishell*
EOF
    
    echo -e "${GREEN}✅ Rapport final sauvegardé : rapport_final_${TIMESTAMP}.md${NC}"
    echo -e "${CYAN}📊 Logs disponibles :${NC}"
    echo -e "   📝 complete_test_output.log - Sortie complète des tests standards"
    echo -e "   🔥 stress_test_output.log - Sortie des tests de stress"
    echo -e "   📄 test_report.txt - Rapport détaillé tests standards"
    echo -e "   📄 stress_report.txt - Rapport détaillé tests stress"
    echo ""
}

# ================================================================================================
# 🧹 NETTOYAGE
# ================================================================================================

cleanup() {
    echo -e "${CYAN}🧹 Nettoyage des fichiers temporaires...${NC}"
    
    # Nettoyer les fichiers de test
    rm -f test_file.txt test_append.txt output.txt temp.txt user_file.txt
    rm -f file1.txt file2.txt multi.txt "file with spaces.txt" shared.txt
    rm -f *.tmp
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# ================================================================================================
# 🚀 FONCTION PRINCIPALE
# ================================================================================================

main() {
    # Gestion des signaux pour nettoyage propre
    trap cleanup EXIT
    
    print_banner
    echo -e "${CYAN}🕐 Début de l'exécution : $(date)${NC}"
    echo ""
    
    # Vérifications préliminaires
    check_prerequisites
    
    # Exécution des suites de tests
    run_complete_test_suite
    run_stress_test_suite
    
    # Analyse des résultats
    analyze_results
    local analysis_exit_code=$?
    
    # Génération du rapport final
    generate_final_report
    
    # Conclusion
    print_separator
    echo -e "${BOLD}${CYAN}🎉 TESTS TERMINÉS${NC}"
    echo -e "${CYAN}🕐 Fin de l'exécution : $(date)${NC}"
    echo -e "${CYAN}⏱️  Durée totale : $(($(date +%s) - START_TIME))s${NC}"
    
    if [ $analysis_exit_code -eq 0 ]; then
        echo -e "${GREEN}🏆 Tous les tests sont passés avec succès !${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Des tests ont échoué. Consultez les rapports pour plus de détails.${NC}"
        exit 1
    fi
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
