#!/bin/bash

echo "🔍 VALIDATION INFRASTRUCTURE AVEC VALGRIND"
echo "=========================================="
echo

# Test avec Valgrind des fonctions de base
cat > test_valgrind_infra.c << 'EOF'
#include "libft/libft.h"
#include "parsing/includes/minishell.h"

int main(void)
{
    printf("🔍 Test Infrastructure avec Valgrind:\n");
    
    // Test simple et sûr des fonctions de base
    printf("1. Test is_builtin():\n");
    int echo_result = is_builtin("echo");
    int ls_result = is_builtin("ls");
    printf("   echo: %d, ls: %d\n", echo_result, ls_result);
    
    printf("2. Test create_env_node():\n");
    t_env *node = create_env_node("KEY", "VALUE");
    if (node) {
        printf("   Node créé: %s=%s\n", node->key, node->value);
        free(node->key);
        free(node->value);
        free(node);
        printf("   Node libéré\n");
    }
    
    printf("3. Test new_command():\n");
    t_cmd *cmd = new_command();
    if (cmd) {
        printf("   Commande créée\n");
        free_commands(cmd);
        printf("   Commande libérée\n");
    }
    
    printf("✅ Tests de base terminés\n");
    return (0);
}
EOF

echo "🔨 Compilation test Valgrind infrastructure..."
gcc -Wall -Wextra -Werror -g test_valgrind_infra.c \
    builtins.c env_utils.c \
    parsing/objs/parser/create_commande.o \
    -Llibft -lft -o test_valgrind_infra

if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie"
    echo
    echo "🔍 Test avec Valgrind..."
    echo
    
    if command -v valgrind >/dev/null 2>&1; then
        valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
                 --verbose --log-file=valgrind_infra.log \
                 ./test_valgrind_infra
        
        echo
        echo "📊 Résultats Valgrind:"
        echo "====================="
        
        if grep -q "All heap blocks were freed" valgrind_infra.log; then
            echo "✅ Aucun memory leak détecté"
        else
            echo "⚠️  Leaks potentiels détectés"
        fi
        
        if grep -q "ERROR SUMMARY: 0 errors" valgrind_infra.log; then
            echo "✅ Aucune erreur mémoire"
        else
            echo "⚠️  Erreurs mémoire détectées"
        fi
        
        echo
        echo "📄 Log Valgrind sauvé dans: valgrind_infra.log"
        
    else
        echo "⚠️  Valgrind non disponible, exécution normale..."
        ./test_valgrind_infra
    fi
else
    echo "❌ Erreur de compilation"
fi

echo
echo "🧹 Nettoyage..."
rm -f test_valgrind_infra.c test_valgrind_infra
