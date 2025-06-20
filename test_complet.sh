#!/bin/bash

# Script de test principal pour le parser minishell
echo "🧪 TESTS PARSER MINISHELL - VALIDATION COMPLÈTE"
echo "================================================"
echo ""

TOTAL_TESTS=0
TOTAL_PASS=0

echo "🚀 Phase 1: Tests exhaustifs (78 tests)..."
if ./test_exhaustif.sh >/dev/null 2>&1; then
    echo "✅ Tests exhaustifs: RÉUSSI (78/78)"
    TOTAL_PASS=$((TOTAL_PASS + 78))
else
    echo "❌ Tests exhaustifs: ÉCHOUÉ"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 78))

echo ""
echo "🔧 Phase 2: Tests complexes manuels..."
./test_complexe_manuel.sh >/dev/null 2>&1
complexe_result=$?
if [ $complexe_result -eq 0 ]; then
    echo "✅ Tests complexes: RÉUSSI (28/28)"
    TOTAL_PASS=$((TOTAL_PASS + 28))
else
    echo "❌ Tests complexes: ÉCHOUÉ"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 28))

echo ""
echo "🎯 Phase 3: Validation finale..."
if ./test_validation_finale.sh >/dev/null 2>&1; then
    echo "✅ Validation finale: RÉUSSI (13/13)"
    TOTAL_PASS=$((TOTAL_PASS + 13))
else
    echo "❌ Validation finale: ÉCHOUÉ"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 13))

echo ""
echo "🧠 Phase 4: Test memory leaks..."
if command -v valgrind >/dev/null 2>&1; then
    timeout 10s valgrind --leak-check=full --error-exitcode=1 ./minishell -c "echo test" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Memory leaks: AUCUN LEAK DÉTECTÉ"
        TOTAL_PASS=$((TOTAL_PASS + 1))
    else
        echo "❌ Memory leaks: LEAKS DÉTECTÉS"
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
else
    echo "⚠️  Valgrind non disponible, skip test memory"
fi

echo ""
echo "📏 Phase 5: Vérification norme 42..."
norm_errors=$(find parsing/srcs -name "*.c" -exec norminette {} \; 2>/dev/null | grep -c "Error")
if [ "$norm_errors" -eq 0 ]; then
    echo "✅ Norme 42: CONFORME (0 erreurs)"
    TOTAL_PASS=$((TOTAL_PASS + 1))
else
    echo "❌ Norme 42: $norm_errors erreur(s) détectée(s)"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo ""
echo "📊 === RÉSULTATS FINAUX ==="
echo "Tests exécutés: $TOTAL_TESTS"
echo "Tests réussis: $TOTAL_PASS"
echo "Tests échoués: $((TOTAL_TESTS - TOTAL_PASS))"
echo "Taux de réussite: $(( TOTAL_PASS * 100 / TOTAL_TESTS ))%"

if [ $TOTAL_PASS -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 PARFAIT ! Tous les tests passent !"
    echo "✅ Le parser minishell est 100% fonctionnel"
    echo "🚀 Prêt pour l'implémentation de l'exécuteur"
    exit 0
else
    echo ""
    echo "⚠️  $(( TOTAL_TESTS - TOTAL_PASS )) test(s) échoué(s)"
    echo "💡 Vérifiez les erreurs ci-dessus"
    exit 1
fi
