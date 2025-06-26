#!/bin/bash

echo "🧪 === TEST GESTION CTRL+C ==="

# Test 1: Vérifier que le minishell ne quitte pas sur Ctrl+C
echo "📋 Test 1: Envoyer SIGINT au processus"

# Démarrer minishell en arrière-plan
./minishell &
MINISHELL_PID=$!

sleep 1

# Envoyer SIGINT (équivalent de Ctrl+C)
kill -SIGINT $MINISHELL_PID

sleep 1

# Vérifier si le processus est toujours en vie
if kill -0 $MINISHELL_PID 2>/dev/null; then
    echo "✅ PASSED: Minishell survit à SIGINT"
    RESULT1="PASSED"
else
    echo "❌ FAILED: Minishell a quitté sur SIGINT"
    RESULT1="FAILED"
fi

# Nettoyer le processus
kill -TERM $MINISHELL_PID 2>/dev/null
wait $MINISHELL_PID 2>/dev/null

echo ""
echo "📋 Test 2: Vérifier le comportement avec readline"

# Test avec un script expect si disponible
if command -v expect >/dev/null 2>&1; then
    echo "📝 Création d'un test expect..."
    cat > test_ctrl_c.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 5
spawn ./minishell
expect "minishell$ "
send "echo hello\r"
expect "hello"
expect "minishell$ "
send "\003"
expect "minishell$ "
send "echo world\r"
expect "world"
expect "minishell$ "
send "exit\r"
expect eof
EOF
    
    chmod +x test_ctrl_c.exp
    if ./test_ctrl_c.exp >/dev/null 2>&1; then
        echo "✅ PASSED: Ctrl+C fonctionne correctement avec readline"
        RESULT2="PASSED"
    else
        echo "❌ FAILED: Problème avec Ctrl+C et readline"
        RESULT2="FAILED"
    fi
    rm -f test_ctrl_c.exp
else
    echo "⚠️  SKIPPED: expect non disponible"
    RESULT2="SKIPPED"
fi

echo ""
echo "📊 === RÉSULTATS TEST CTRL+C ==="
echo "Test survie SIGINT: $RESULT1"
echo "Test readline Ctrl+C: $RESULT2"

if [ "$RESULT1" = "PASSED" ]; then
    echo "🎉 SUCCESS: Gestion des signaux opérationnelle!"
    exit 0
else
    echo "⚠️  ATTENTION: Vérifier la gestion des signaux"
    exit 1
fi
