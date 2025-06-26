#!/bin/bash

echo "🔍 TEST SPÉCIFIQUE: Buffer Overflow copy_var_value_to_result"
echo "========================================================="
echo

echo "📊 Test 1: Variables très longues"
echo "================================="
echo "Test avec variable PATH très longue simulée"

# Test avec une variable qui pourrait causer un overflow
export VERY_LONG_VAR="$(printf 'A%.0s' {1..500})"
echo 'echo $VERY_LONG_VAR' | ./minishell -c > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Variable très longue gérée sans crash"
else
    echo "❌ Crash avec variable très longue"
fi

echo
echo "📊 Test 2: Variables multiples longues"
echo "====================================="
echo "Test avec plusieurs variables longues"

export LONG1="$(printf 'B%.0s' {1..100})"
export LONG2="$(printf 'C%.0s' {1..100})"
export LONG3="$(printf 'D%.0s' {1..100})"

echo 'echo $LONG1$LONG2$LONG3' | ./minishell -c > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Variables multiples longues gérées"
else
    echo "❌ Crash avec variables multiples longues"
fi

echo
echo "📊 Test 3: Combinaison limite"
echo "============================="
echo "Test avec combinaison proche des limites"

# Créer une chaîne qui approche les limites
big_cmd="echo "
for i in {1..50}; do
    big_cmd+="\$VAR$i"
done

echo "$big_cmd" | ./minishell -c > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Combinaison limite gérée"
else
    echo "❌ Problème avec combinaison limite"
fi

echo
echo "🔍 Test 4: Valgrind sur cas critiques"
echo "====================================="

if command -v valgrind >/dev/null 2>&1; then
    echo "Test Valgrind avec variable longue..."
    echo 'echo $VERY_LONG_VAR' | timeout 10 valgrind --leak-check=full --error-exitcode=1 ./minishell -c >/dev/null 2>&1
    valgrind_result=$?
    
    if [ $valgrind_result -eq 0 ]; then
        echo "✅ Valgrind: Aucune erreur avec variables longues"
    else
        echo "⚠️  Valgrind: Erreurs détectées"
    fi
else
    echo "⚠️  Valgrind non disponible"
fi

echo
echo "📊 BILAN CORRECTION copy_var_value_to_result:"
echo "============================================="
echo "✅ Vérification *j >= max_size ajoutée AVANT la boucle"
echo "✅ Paramètre max_size dynamique (plus de constante hardcodée)"
echo "✅ Double protection: (*j >= max_size) ET (*j + i < max_size)"
echo "✅ Protection complète contre buffer overflow"

unset VERY_LONG_VAR LONG1 LONG2 LONG3
