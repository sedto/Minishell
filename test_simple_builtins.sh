#!/bin/bash

echo "=== Test Simple des Builtins ==="
echo

# Test de la fonction is_builtin avec un mini programme
cat > test_simple.c << 'EOF'
#include "libft/libft.h"
#include "parsing/includes/minishell.h"

int main(void)
{
    printf("Test is_builtin:\n");
    printf("echo: %d\n", is_builtin("echo"));
    printf("pwd: %d\n", is_builtin("pwd"));
    printf("env: %d\n", is_builtin("env"));
    printf("export: %d\n", is_builtin("export"));
    printf("unset: %d\n", is_builtin("unset"));
    printf("exit: %d\n", is_builtin("exit"));
    printf("cd: %d\n", is_builtin("cd"));
    printf("ls: %d\n", is_builtin("ls"));
    
    printf("\nTest builtin_echo:\n");
    char *args[] = {"echo", "Hello", "World", NULL};
    builtin_echo(args);
    
    printf("Test builtin_pwd:\n");
    builtin_pwd();
    
    return 0;
}
EOF

echo "Compilation du test simple..."
gcc -Wall -Wextra -Werror -Wno-unused-variable test_simple.c builtins.c env_utils.c utils.c -Llibft -lft -o test_simple

if [ $? -eq 0 ]; then
    echo "Exécution du test simple..."
    ./test_simple
    echo
    echo "✅ Test simple terminé"
else
    echo "❌ Erreur de compilation"
fi

rm -f test_simple.c test_simple
