#!/bin/bash

echo "🧪 TEST CTRL+C - GESTIONNAIRE SIGACTION AMÉLIORÉ"
echo "================================================"
echo
echo "✅ AMÉLIORATIONS APPORTÉES:"
echo "   - signal() remplacé par sigaction()"
echo "   - SA_RESTART: Redémarre automatiquement les appels système"
echo "   - Gestionnaire async-signal-safe (seulement write())"
echo "   - process_signals() gère readline proprement"
echo "   - Meilleure séparation des responsabilités"
echo
echo "Instructions de test:"
echo "1. Lancez ./minishell"
echo "2. Appuyez sur Ctrl+C pour tester l'interruption" 
echo "3. Tapez 'exit' pour quitter"
echo
echo "Comportement attendu avec Ctrl+C:"
echo "- Nouvelle ligne affichée"
echo "- Prompt réaffiché proprement"
echo "- Pas de crash/blocage"
echo "- Shell reste réactif"
echo
echo "Lancement du minishell avec gestionnaire sigaction..."
echo
exec ./minishell
