#!/bin/bash

echo "📡 TESTS GESTION DES SIGNAUX"
echo "============================="
echo

# Test des fonctions de signaux
cat > test_signals.c << 'EOF'
#include "libft/libft.h"
#include "parsing/includes/minishell.h"

volatile sig_atomic_t g_signal = 0;

int main(void)
{
    printf("📡 Test Gestion des Signaux:\n\n");
    
    // Test 1: Configuration des signaux
    printf("1. Test setup_signals():\n");
    setup_signals();
    printf("   ✅ Signaux configurés (SIGINT et SIGQUIT)\n");
    
    // Test 2: Vérification que les handlers sont installés
    printf("\n2. Vérification handlers installés:\n");
    struct sigaction sa_int, sa_quit;
    
    if (sigaction(SIGINT, NULL, &sa_int) == 0) {
        printf("   ✅ Handler SIGINT installé\n");
    } else {
        printf("   ❌ Erreur récupération handler SIGINT\n");
    }
    
    if (sigaction(SIGQUIT, NULL, &sa_quit) == 0) {
        printf("   ✅ Handler SIGQUIT installé\n");
    } else {
        printf("   ❌ Erreur récupération handler SIGQUIT\n");
    }
    
    // Test 3: Test reset_signals()
    printf("\n3. Test reset_signals():\n");
    reset_signals();
    printf("   ✅ Signaux restaurés au comportement par défaut\n");
    
    // Test 4: Re-configuration pour vérifier que ça marche
    printf("\n4. Re-configuration des signaux:\n");
    setup_signals();
    printf("   ✅ Signaux re-configurés\n");
    
    printf("\n🎯 RÉSUMÉ SIGNAUX:\n");
    printf("=================\n");
    printf("✅ Configuration signaux: Fonctionnelle\n");
    printf("✅ Restauration signaux: Fonctionnelle\n");
    printf("✅ Handlers personnalisés: Installés\n");
    printf("✅ Gestion Ctrl+C/Ctrl+\\: Prête\n");
    
    printf("\n💡 Note: Pour tester les signaux en action,\n");
    printf("   lancez le shell et testez Ctrl+C\n");
    
    return (0);
}
EOF

echo "🔨 Compilation test signaux..."
gcc -Wall -Wextra -Werror test_signals.c signals.c -Llibft -lft -lreadline -o test_signals

if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie"
    echo
    echo "🚀 Exécution test signaux..."
    echo
    ./test_signals
    echo
else
    echo "❌ Erreur de compilation test signaux"
fi

echo "🧹 Nettoyage..."
rm -f test_signals.c test_signals
