#!/bin/bash

# Tests manuels complexes pour minishell
echo "🔥 TESTS MANUELS COMPLEXES MINISHELL"
echo "===================================="
echo ""

TESTS=0
PASS=0

test_manual() {
    local desc="$1"
    local input="$2"
    local expect="$3"
    
    echo -n "🔹 $desc... "
    TESTS=$((TESTS + 1))
    
    if [ "$expect" = "syntax_error" ]; then
        OUTPUT=$(printf "%s\nexit\n" "$input" | timeout 3s ./minishell 2>&1)
        if echo "$OUTPUT" | grep -q "syntax error"; then
            echo "✅ PASS"
            PASS=$((PASS + 1))
        else
            echo "❌ FAIL - Pas d'erreur détectée"
        fi
    elif [ "$expect" = "no_crash" ]; then
        printf "%s\nexit\n" "$input" | timeout 3s ./minishell >/dev/null 2>&1
        local exit_code=$?
        if [ $exit_code -ne 139 ] && [ $exit_code -ne 124 ]; then
            echo "✅ PASS"
            PASS=$((PASS + 1))
        else
            echo "❌ FAIL - Crash détecté (code: $exit_code)"
        fi
    fi
}

echo "🚨 Tests erreurs de syntaxe:"
test_manual "Pipe en fin de ligne" "echo hello |" "syntax_error"
test_manual "Pipe en début de ligne" "| echo hello" "syntax_error"
test_manual "Double pipe" "echo hello || echo world" "syntax_error"
test_manual "Redirection sans fichier >" "echo >" "syntax_error"
test_manual "Redirection sans fichier <" "cat <" "syntax_error"
test_manual "Redirection sans fichier >>" "echo >>" "syntax_error"

echo ""
echo "🧪 Tests variables complexes:"
test_manual "Variable inexistante" "echo \$NONEXISTENT_VAR" "no_crash"
test_manual "Variable avec chiffres" "echo \$PATH1" "no_crash"
test_manual "Variables multiples" "echo \$USER \$HOME \$PWD" "no_crash"
test_manual "Variable dans quotes doubles" 'echo "Hello \$USER!"' "no_crash"
test_manual "Variable dans quotes simples" "echo '\$USER'" "no_crash"
test_manual "Expansion complexe" 'echo "\$USER lives in \$HOME"' "no_crash"

echo ""
echo "🔧 Tests parsing complexe:"
test_manual "Commande avec args multiples" "echo hello world test 123" "no_crash"
test_manual "Quotes imbriquées complexes" 'echo "He said '\''hello'\'' to me"' "no_crash"
test_manual "Redirection sortie" "echo test > /tmp/minishell_test" "no_crash"
test_manual "Redirection entrée" "cat < /etc/hostname" "no_crash"
test_manual "Redirection append" "echo test >> /tmp/minishell_test" "no_crash"
test_manual "Heredoc" "cat << EOF" "no_crash"

echo ""
echo "⚡ Tests edge cases:"
test_manual "Commande vide" "" "no_crash"
test_manual "Espaces multiples" "echo     hello     world" "no_crash"
test_manual "Tabs et espaces" "echo	hello   world" "no_crash"
test_manual "Dollar suivi d'espace" "echo \$ hello" "no_crash"
test_manual "Dollar en fin" "echo hello\$" "no_crash"
test_manual "Quotes vides" 'echo ""' "no_crash"
test_manual "Variables spéciales" "echo \$? \$\$ \$0" "no_crash"

echo ""
echo "🎯 Tests stress (boucles infinies potentielles):"
test_manual "Variable récursive potentielle" "echo \$\$\$\$\$" "no_crash"
test_manual "Quotes multiples" 'echo "a" "b" "c" "d" "e"' "no_crash"
test_manual "Arguments très longs" "echo $(python3 -c 'print(\"a\" * 100)')" "no_crash"

echo ""
echo "📊 RÉSULTATS FINAUX:"
echo "==================="
echo "Tests exécutés: $TESTS"
echo "Réussis: $PASS"
echo "Échoués: $((TESTS - PASS))"

if [ $PASS -eq $TESTS ]; then
    echo ""
    echo "🎉 PARFAIT ! Tous les tests complexes passent !"
    echo "✅ Le parser est ultra-robuste"
    exit 0
else
    echo ""
    echo "⚠️  $(( TESTS - PASS )) test(s) échoué(s)"
    echo "💡 Pourcentage de réussite: $(( PASS * 100 / TESTS ))%"
    exit 1
fi
