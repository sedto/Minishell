#!/bin/bash

# Test des builtins de minishell
# Ce script teste chaque builtin individuellement

echo "=== Test des Builtins de Minishell ==="
echo

# Compilation
echo "📦 Compilation..."
make > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation"
    exit 1
fi
echo "✅ Compilation réussie"
echo

# Test des fonctions individuelles en créant un mini testeur
cat > test_builtins_simple.c << 'EOF'
#include "libft/libft.h"
#include "parsing/includes/minishell.h"

int main(void)
{
    t_env *env;
    char *envp[] = {"PATH=/usr/bin:/bin", "HOME=/home/user", "USER=test", NULL};
    char *args1[] = {"echo", "Hello", "World", NULL};
    char *args2[] = {"echo", "-n", "No newline", NULL};
    char *args3[] = {"pwd", NULL};
    char *args4[] = {"env", NULL};
    char *args5[] = {"export", "TEST=value", NULL};
    char *args6[] = {"export", NULL};
    char *args7[] = {"unset", "TEST", NULL};
    
    printf("=== Test des Builtins ===\n\n");
    
    // Initialiser l'environnement
    env = init_env(envp);
    
    // Test echo
    printf("1. Test echo:\n");
    printf("   echo Hello World: ");
    builtin_echo(args1);
    printf("   echo -n No newline: ");
    builtin_echo(args2);
    printf("(fin)\n\n");
    
    // Test pwd
    printf("2. Test pwd:\n");
    printf("   pwd: ");
    builtin_pwd();
    printf("\n");
    
    // Test env
    printf("3. Test env (premières variables):\n");
    printf("   ");
    builtin_env(env);
    printf("\n");
    
    // Test export
    printf("4. Test export:\n");
    printf("   export TEST=value\n");
    builtin_export(args5, &env);
    printf("   Vérification (env | grep TEST):\n");
    t_env *current = env;
    while (current) {
        if (ft_strncmp(current->key, "TEST", 4) == 0) {
            printf("   %s=%s\n", current->key, current->value);
        }
        current = current->next;
    }
    printf("\n");
    
    // Test export sans arguments
    printf("5. Test export (affichage):\n");
    builtin_export(args6, &env);
    printf("\n");
    
    // Test unset
    printf("6. Test unset:\n");
    printf("   unset TEST\n");
    builtin_unset(args7, &env);
    printf("   Vérification (TEST doit disparaître):\n");
    current = env;
    int found = 0;
    while (current) {
        if (ft_strncmp(current->key, "TEST", 4) == 0) {
            printf("   ERREUR: %s=%s (toujours présent)\n", current->key, current->value);
            found = 1;
        }
        current = current->next;
    }
    if (!found) {
        printf("   ✅ TEST supprimé avec succès\n");
    }
    printf("\n");
    
    // Test is_builtin
    printf("7. Test is_builtin:\n");
    printf("   echo: %s\n", is_builtin("echo") ? "✅ builtin" : "❌ non-builtin");
    printf("   pwd: %s\n", is_builtin("pwd") ? "✅ builtin" : "❌ non-builtin");
    printf("   ls: %s\n", is_builtin("ls") ? "❌ builtin" : "✅ non-builtin");
    printf("\n");
    
    free_env(env);
    printf("✅ Tous les tests terminés\n");
    return (0);
}
EOF

# Compiler le testeur
echo "🧪 Compilation du testeur..."
gcc -Wall -Wextra -Werror -Wno-unused-variable test_builtins_simple.c builtins.c env_utils.c utils.c -Llibft -lft -o test_builtins_simple

if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation du testeur"
    exit 1
fi

echo "🚀 Exécution des tests..."
echo
./test_builtins_simple

echo
echo "🧹 Nettoyage..."
rm -f test_builtins_simple.c test_builtins_simple

echo "✅ Tests des builtins terminés!"
