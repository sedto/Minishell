#!/bin/bash

echo "🧪 TESTS POUSSES CLEAN_INPUT"
echo "Testeur de cas extrêmes pour clean_input.c"
echo

# Test des cas extrêmes
test_cases=(
    "echo   'test  with   spaces'   "
    "echo\"no spaces\"between\"quotes\""
    "echo 'single'\"double\"'mixed'"
    "echo \$USER\$HOME\$PATH"
    "echo \"  \$USER   \$HOME  \""
    "echo '\$USER should not expand'"
    "echo \"\$USER should expand\""
    "echo    with    multiple    spaces    "
    "    echo    starting    with    spaces    "
    "echo 'unmatched quote"
    "echo \"unmatched quote'"
    "echo nested'quotes\"inside'quotes"
    "echo very'long'string'with'many'quotes'and'variables\$USER\$HOME"
    "echo empty''\"\""
    "echo \$\$\$\$\$"
    "echo \$?\$0\$USER\$NONEXISTENT"
    "echo 'quote with spaces   inside'"
    "echo \"quote with \$USER inside\""
    "echo complex'string\"with\$USER'and\"more\$HOME\"stuff"
    "echo tabs\t\t\twith\ttabs\t"
)

echo "Tests de cas extrêmes pour clean_input:"
for i in "${!test_cases[@]}"; do
    echo "--- Test $((i+1)): ${test_cases[i]} ---"
    echo "${test_cases[i]}" | /Users/dibransejrani/Desktop/Minishelldib/minishell
    echo
done

echo "🏁 Tests terminés"
