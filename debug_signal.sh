#!/bin/bash

echo "🧪 === DEBUG TEST CTRL+C ==="

# Créer un script temporaire qui envoie des commandes
cat > test_input.txt << 'EOF'
echo hello
echo world
exit
EOF

echo "📋 Test avec script d'entrée..."

# Lancer minishell avec entrée prédéfinie  
./minishell < test_input.txt

echo ""
echo "📋 Test avec timeout et entrée interactive..."

# Test simple avec timeout
timeout 3s bash -c '
    echo "echo test" | ./minishell
    echo "Status: $?"
'

echo ""
echo "📋 Test signal direct..."

# Test avec signal PID
{
    echo "echo starting"
    sleep 2
} | timeout 5s ./minishell &

PID=$!
sleep 1
echo "Processus PID: $PID"

if kill -0 $PID 2>/dev/null; then
    echo "Processus actif, envoi SIGINT..."
    kill -SIGINT $PID
    sleep 1
    
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Processus survit à SIGINT"
        kill -TERM $PID
    else
        echo "❌ Processus mort après SIGINT"
    fi
else
    echo "❌ Processus déjà mort"
fi

# Nettoyer
rm -f test_input.txt
wait 2>/dev/null
