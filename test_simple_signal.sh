#!/bin/bash

echo "🧪 === TEST SIGNAL RÉEL ==="

# Créer un processus minishell en background et lui envoyer SIGINT
{
    echo "test" 
    sleep 10  # Garder le processus ouvert
} | ./minishell &

PID=$!
echo "Processus PID: $PID"
sleep 2

echo "Envoi SIGINT au processus..."
kill -SIGINT $PID

sleep 2

if kill -0 $PID 2>/dev/null; then
    echo "✅ Processus encore vivant après SIGINT"
    kill -TERM $PID  # Terminer proprement
    wait $PID 2>/dev/null
else
    echo "❌ Processus mort après SIGINT"
fi
