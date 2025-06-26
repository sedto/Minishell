#!/bin/bash

# ==================================================================================
# 🎮 LANCEUR RAPIDE - TESTS MINISHELL
# ==================================================================================
# Interface simple pour lancer les tests individuellement ou tous ensemble

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║           🎮 LANCEUR RAPIDE TESTS MINISHELL              ║${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Choisissez le niveau de tests à exécuter:${NC}"
    echo ""
    echo -e "${GREEN}  1) 🟢 Tests SIMPLES          (rapide, ~30 tests)${NC}"
    echo -e "${YELLOW}  2) 🟡 Tests MOYENS           (moyen, ~40 tests)${NC}"
    echo -e "${RED}  3) 🔥 Tests EXTRÊMES         (long, ~50 tests)${NC}"
    echo -e "${PURPLE}  4) 💀 Tests EVIL             (sécurité, ~30 tests)${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}  5) 🚀 SUITE COMPLÈTE         (tous les niveaux)${NC}"
    echo ""
    echo -e "${BLUE}  6) 📊 Voir les derniers résultats${NC}"
    echo -e "${BLUE}  7) 🧹 Nettoyer les rapports${NC}"
    echo ""
    echo -e "${RED}  0) ❌ Quitter${NC}"
    echo ""
}

run_single_level() {
    local level="$1"
    local script="$2"
    local name="$3"
    local emoji="$4"
    
    echo -e "${BOLD}${BLUE}Lancement des tests $name $emoji${NC}"
    echo ""
    
    if [ ! -f "$script" ]; then
        echo -e "${RED}❌ Erreur: Script $script introuvable${NC}"
        return 1
    fi
    
    ./"$script"
    local exit_code=$?
    
    echo ""
    echo -e "${CYAN}Tests $name terminés avec le code: $exit_code${NC}"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont réussis !${NC}"
    else
        echo -e "${YELLOW}⚠️ Certains tests ont échoué. Voir le rapport d'erreurs.${NC}"
    fi
    
    return $exit_code
}

show_last_results() {
    echo -e "${BOLD}${CYAN}📊 Derniers résultats disponibles:${NC}"
    echo ""
    
    # Chercher le dernier rapport final
    local last_report=$(ls -t RAPPORT_FINAL_COMPLET_*.md 2>/dev/null | head -1)
    if [ -n "$last_report" ]; then
        echo -e "${GREEN}📄 Rapport final: $last_report${NC}"
        echo ""
        
        # Extraire les résultats principaux
        if grep -q "Total des tests exécutés" "$last_report"; then
            local total=$(grep "Total des tests exécutés" "$last_report" | grep -o '[0-9]*')
            local passed=$(grep "Tests réussis" "$last_report" | grep -o '[0-9]*' | head -1)
            local failed=$(grep "Tests échoués" "$last_report" | grep -o '[0-9]*' | head -1)
            local rate=$(grep "Taux de réussite global" "$last_report" | grep -o '[0-9]*%')
            
            echo -e "  Total: $total tests"
            echo -e "  Réussis: $passed tests"
            echo -e "  Échoués: $failed tests"
            echo -e "  Taux: $rate"
            echo ""
        fi
    fi
    
    # Vérifier les rapports individuels
    echo -e "${CYAN}Rapports individuels:${NC}"
    for rapport in rapport_erreurs_*.md; do
        if [ -f "$rapport" ]; then
            local age=$(stat -c %Y "$rapport" 2>/dev/null)
            local now=$(date +%s)
            local diff=$((now - age))
            local time_desc=""
            
            if [ $diff -lt 3600 ]; then
                time_desc="$(($diff / 60)) min"
            elif [ $diff -lt 86400 ]; then
                time_desc="$(($diff / 3600)) h"
            else
                time_desc="$(($diff / 86400)) j"
            fi
            
            echo -e "  📋 $rapport (il y a $time_desc)"
        fi
    done
}

clean_reports() {
    echo -e "${YELLOW}🧹 Nettoyage des rapports...${NC}"
    
    local cleaned=0
    
    # Supprimer les rapports d'erreurs
    for rapport in rapport_erreurs_*.md; do
        if [ -f "$rapport" ]; then
            rm "$rapport"
            echo -e "  🗑️ Supprimé: $rapport"
            cleaned=$((cleaned + 1))
        fi
    done
    
    # Supprimer les anciens rapports finaux (garder le plus récent)
    local reports=($(ls -t RAPPORT_FINAL_COMPLET_*.md 2>/dev/null))
    if [ ${#reports[@]} -gt 1 ]; then
        for ((i=1; i<${#reports[@]}; i++)); do
            rm "${reports[$i]}"
            echo -e "  🗑️ Supprimé: ${reports[$i]}"
            cleaned=$((cleaned + 1))
        done
    fi
    
    if [ $cleaned -eq 0 ]; then
        echo -e "${CYAN}  ✨ Aucun fichier à nettoyer${NC}"
    else
        echo -e "${GREEN}  ✅ $cleaned fichier(s) nettoyé(s)${NC}"
    fi
}

# Vérifier les prérequis
check_requirements() {
    if [ ! -f "./minishell" ]; then
        echo -e "${RED}❌ Erreur: ./minishell introuvable${NC}"
        echo -e "${YELLOW}💡 Compilez votre projet avec 'make' avant de lancer les tests${NC}"
        return 1
    fi
    
    if [ ! -x "./minishell" ]; then
        chmod +x "./minishell"
    fi
    
    return 0
}

# ==================================================================================
# BOUCLE PRINCIPALE
# ==================================================================================

while true; do
    show_menu
    read -p "Votre choix [0-7]: " choice
    echo ""
    
    case $choice in
        1)
            if check_requirements; then
                run_single_level "1" "tests_simples.sh" "SIMPLES" "🟢"
            fi
            ;;
        2)
            if check_requirements; then
                run_single_level "2" "tests_moyens.sh" "MOYENS" "🟡"
            fi
            ;;
        3)
            if check_requirements; then
                run_single_level "3" "tests_extremes.sh" "EXTRÊMES" "🔥"
            fi
            ;;
        4)
            if check_requirements; then
                run_single_level "4" "tests_evil.sh" "EVIL" "💀"
            fi
            ;;
        5)
            if check_requirements; then
                echo -e "${BOLD}${CYAN}🚀 Lancement de la suite complète...${NC}"
                echo ""
                ./maitre_tests_complet.sh
            fi
            ;;
        6)
            show_last_results
            ;;
        7)
            clean_reports
            ;;
        0)
            echo -e "${CYAN}👋 Au revoir !${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Choix invalide. Veuillez entrer un nombre entre 0 et 7.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
done
