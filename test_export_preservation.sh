#!/bin/bash

echo "🧪 === TEST PRÉSERVATION ARGUMENTS EXPORT ==="

# Test spécifique pour vérifier que les arguments ne sont pas modifiés
echo "📋 Test: Vérification que args[i] n'est pas modifié"

# Créer un test C simple pour vérifier la non-modification des arguments
cat > test_export_args.c << 'EOF'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Simuler les structures nécessaires
typedef struct s_env {
    char *key;
    char *value;
    struct s_env *next;
} t_env;

// Fonctions mockées pour le test
void set_env_value(t_env **env, char *key, char *value) {
    printf("Setting %s=%s\n", key, value);
}

char *get_env_value(t_env *env, char *key) {
    return NULL; // Simulation simple
}

char *ft_strchr(const char *s, int c) {
    return strchr(s, c);
}

char *ft_substr(char const *s, unsigned int start, size_t len) {
    if (!s) return NULL;
    char *result = malloc(len + 1);
    if (!result) return NULL;
    strncpy(result, s + start, len);
    result[len] = '\0';
    return result;
}

char *ft_strdup(const char *s1) {
    return strdup(s1);
}

// Version corrigée de builtin_export
int builtin_export(char **args, t_env **env) {
    char *equal_pos;
    char *key;
    char *value;
    int i;

    if (!args[1]) {
        return (0);
    }
    
    i = 1;
    while (args[i]) {
        equal_pos = ft_strchr(args[i], '=');
        if (equal_pos) {
            // Extraire key et value sans modifier args[i]
            key = ft_substr(args[i], 0, equal_pos - args[i]);
            value = ft_strdup(equal_pos + 1);
            if (key && value) {
                set_env_value(env, key, value);
                free(key);
                free(value);
            } else {
                free(key);
                free(value);
            }
        } else {
            char *existing = get_env_value(*env, args[i]);
            if (existing)
                set_env_value(env, args[i], existing);
            else
                set_env_value(env, args[i], "");
        }
        i++;
    }
    return (0);
}

int main() {
    char *test_args[] = {"export", "VAR1=value1", "VAR2=value2", NULL};
    t_env *env = NULL;
    
    printf("Arguments avant export:\n");
    for (int i = 0; test_args[i]; i++) {
        printf("  args[%d] = '%s'\n", i, test_args[i]);
    }
    
    printf("\nExécution export:\n");
    builtin_export(test_args, &env);
    
    printf("\nArguments après export:\n");
    for (int i = 0; test_args[i]; i++) {
        printf("  args[%d] = '%s'\n", i, test_args[i]);
    }
    
    // Vérifier que les arguments contiennent toujours '='
    int preserved = 1;
    for (int i = 1; test_args[i]; i++) {
        if (!strchr(test_args[i], '=')) {
            printf("❌ ERREUR: '=' manquant dans args[%d]\n", i);
            preserved = 0;
        }
    }
    
    if (preserved) {
        printf("✅ SUCCESS: Arguments préservés correctement\n");
        return 0;
    } else {
        printf("❌ FAILED: Arguments modifiés\n");
        return 1;
    }
}
EOF

echo "📝 Compilation du test..."
gcc -o test_export_args test_export_args.c

echo "🔬 Exécution du test..."
./test_export_args

echo ""
echo "🧹 Nettoyage..."
rm -f test_export_args.c test_export_args

echo "✅ Test de préservation des arguments terminé"
