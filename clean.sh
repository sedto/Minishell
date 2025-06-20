#!/bin/bash

# Script de nettoyage du projet minishell
echo "🧹 NETTOYAGE PROJET MINISHELL"
echo "=============================="

echo "🗑️  Suppression des fichiers temporaires..."

# Supprimer les fichiers de test temporaires
rm -f /tmp/minishell_test* 2>/dev/null
rm -f output.txt log.txt greeting.txt user.txt file1 file2 2>/dev/null
rm -f tmp*.txt 2>/dev/null

# Supprimer les fichiers système
rm -f .DS_Store 2>/dev/null
rm -f *~ 2>/dev/null

# Supprimer les fichiers de debug
rm -f core vgcore.* 2>/dev/null

echo "✅ Fichiers temporaires supprimés"

echo ""
echo "🔧 Nettoyage de la compilation..."
make fclean >/dev/null 2>&1

echo "✅ Compilation nettoyée"

echo ""
echo "📊 État final du projet:"
echo "------------------------"
echo "📁 Fichiers source: $(find parsing/srcs -name "*.c" | wc -l) fichiers"
echo "📋 Documentation: $(ls -1 *.md | wc -l) fichiers"
echo "🧪 Scripts de test: $(ls -1 test_*.sh | wc -l) scripts"

echo ""
echo "🎉 Nettoyage terminé ! Projet propre et prêt."
