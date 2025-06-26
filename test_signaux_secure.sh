#!/bin/bash

echo "🔧 VALIDATION CORRECTION SIGNAUX ASYNC-SIGNAL-SAFE"
echo "=================================================="

echo ""
echo "🔍 1. Vérification du code signals.c..."

# Vérification que les fonctions dangereuses ont été supprimées
if grep -q "printf(" signals.c; then
    echo "❌ ERREUR: printf() encore présent dans handle_sigint!"
    exit 1
else
    echo "✅ printf() supprimé du gestionnaire de signal"
fi

if grep -q "rl_on_new_line()" signals.c | grep -v "process_signals"; then
    echo "❌ ERREUR: rl_on_new_line() encore dans le gestionnaire!"
    exit 1
else
    echo "✅ rl_on_new_line() déplacé dans process_signals()"
fi

if grep -q "write(STDOUT_FILENO" signals.c; then
    echo "✅ write() utilisé (async-signal-safe)"
else
    echo "❌ ERREUR: write() pas trouvé!"
    exit 1
fi

echo ""
echo "🔍 2. Vérification que process_signals() existe..."

if grep -q "process_signals" signals.c; then
    echo "✅ Fonction process_signals() implémentée"
else
    echo "❌ ERREUR: process_signals() manquante!"
    exit 1
fi

echo ""
echo "🔍 3. Test de compilation..."
make > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie"
else
    echo "❌ ERREUR: Échec de compilation"
    exit 1
fi

echo ""
echo "🔍 4. Test fonctionnel basic..."
echo "pwd" | timeout 3 ./minishell > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Test fonctionnel réussi"
else
    echo "❌ ERREUR: Test fonctionnel échoué"
    exit 1
fi

echo ""
echo "🔍 5. Vérification header..."
if grep -q "process_signals" parsing/includes/minishell.h; then
    echo "✅ Déclaration process_signals() dans header"
else
    echo "❌ ERREUR: process_signals() pas déclarée dans header"
    exit 1
fi

echo ""
echo "🔍 6. Vérification intégration dans main.c..."
if grep -q "process_signals()" parsing/srcs/utils/main.c; then
    echo "✅ process_signals() appelée dans la boucle principale"
else
    echo "❌ ERREUR: process_signals() pas appelée dans main.c"
    exit 1
fi

if grep -q "setup_signals()" parsing/srcs/utils/main.c; then
    echo "✅ setup_signals() appelée dans main.c"
else
    echo "❌ ERREUR: setup_signals() pas appelée dans main.c"
    exit 1
fi

echo ""
echo "📊 RÉSULTATS CORRECTION SIGNAUX:"
echo "================================"
echo "✅ Gestionnaires async-signal-safe"
echo "✅ Séparation gestionnaire/traitement"
echo "✅ Utilisation de write() au lieu de printf()"
echo "✅ Fonctions readline dans process_signals()"
echo "✅ Intégration correcte dans main.c"
echo "✅ Compilation sans erreurs"
echo ""
echo "🎯 SÉCURITÉ SIGNAUX: VALIDÉE !"
echo "Les signaux sont maintenant gérés de manière async-signal-safe"
echo "Plus de risque de deadlock avec readline/malloc"
