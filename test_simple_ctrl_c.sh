#!/bin/bash

echo "🧪 TEST SIMPLE CTRL+C"
echo "===================="
echo
echo "Test: Lancer minishell puis tester Ctrl+C manuellement"
echo
echo "CONSIGNES:"
echo "1. Le shell va se lancer"
echo "2. Appuyez sur Ctrl+C plusieurs fois"
echo "3. Vérifiez que le prompt réapparaît"
echo "4. Tapez 'exit' pour quitter"
echo
echo "Si Ctrl+C ne fonctionne toujours pas, le problème peut venir de:"
echo "- La configuration du terminal"
echo "- La version de readline"
echo "- L'environnement qui bloque les signaux"
echo
read -p "Appuyez sur Entrée pour lancer minishell..."
echo
./minishell
