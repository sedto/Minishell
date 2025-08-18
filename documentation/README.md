# 🐚 Minishell - École 42

![Minishell Banner](https://img.shields.io/badge/42-Minishell-blue?style=for-the-badge&logo=42)
![C](https://img.shields.io/badge/C-00599C?style=for-the-badge&logo=c&logoColor=white)
![Memory Safe](https://img.shields.io/badge/Memory-Safe-green?style=for-the-badge)
![Norme 42](https://img.shields.io/badge/Norme-42%20✓-success?style=for-the-badge)

## 📋 Description

**Minishell** est une reproduction simplifiée mais robuste de bash, développée dans le cadre du cursus de l'École 42. Ce projet implémente un shell fonctionnel avec parsing avancé, gestion des processus, pipes, redirections et heredocs.

## ⚡ Fonctionnalités Principales

### 🔧 Fonctionnalités Core
- ✅ **Parsing robuste** avec gestion d'erreurs syntaxiques
- ✅ **Pipes multiples** (`cmd1 | cmd2 | cmd3`)
- ✅ **Redirections complètes** (`>`, `>>`, `<`, `<<`)
- ✅ **Variables d'environnement** avec expansion (`$VAR`, `$?`)
- ✅ **Heredocs** avec délimiteurs personnalisés
- ✅ **Gestion des quotes** simples et doubles
- ✅ **Historique des commandes** (flèches haut/bas)

### 🛠️ Builtins Implémentés
- `echo` (avec option -n)
- `cd` (avec gestion de `~` et `-`)
- `pwd`
- `export` / `unset`
- `env`
- `exit` (avec code de sortie)

### 🎯 Gestion des Signaux
- **Ctrl+C** : Interruption propre
- **Ctrl+\\** : Quit (ignoré en mode interactif)
- **Ctrl+D** : EOF, sortie propre

## 🚀 Installation et Utilisation

### Compilation
```bash
make
```

### Lancement
```bash
./minishell
```

### Mode Command-line
```bash
./minishell -c "echo hello | cat"
```

## 🧪 Tests et Validation

### Tests Valgrind
```bash
# Tests automatisés complets
./test_valgrind.sh

# Résultats attendus :
# definitely lost: 0 bytes ✅
# possibly lost: 0 bytes ✅
# ERROR SUMMARY: 0 errors ✅
```

### Tests Manuels Recommandés
```bash
# Tests de base
echo "Hello World"
pwd && ls -la

# Tests pipes
echo "test" | cat | wc -l
ls | grep minishell | head -3

# Tests redirections
echo "content" > file.txt
cat < file.txt
echo "append" >> file.txt

# Tests heredoc
cat << EOF
Hello
World
EOF

# Tests variables
export TEST="42"
echo $TEST $HOME $?

# Tests complexes
echo "start" && pwd || echo "error"
```

## 📊 Métriques du Projet

| Métrique | Valeur |
|----------|--------|
| **Fichiers C** | 45+ |
| **Lignes de Code** | ~3000 |
| **Fonctions/Fichier** | ≤ 5 (norme 42) |
| **Lignes/Fonction** | ≤ 25 (norme 42) |
| **Memory Leaks** | 0 (Valgrind clean) |
| **Norminette** | 100% ✅ |

## 🏗️ Architecture

```
minishell/
├── src/                    # Point d'entrée et boucle principale
├── parsing/               # Module de parsing complet
│   ├── lexer/            # Tokenisation et analyse lexicale
│   ├── expander/         # Expansion des variables
│   └── parser/           # Construction des commandes
├── execution/            # Module d'exécution
│   ├── executor/         # Gestion des processus et pipes
│   ├── builtins/         # Commandes intégrées
│   └── env/              # Variables d'environnement
├── includes/             # Headers et structures
└── documentation/        # Documentation du projet
```

## 🎯 Flow d'Exécution

```
Input → Lexing → Expansion → Parsing → Execution → Output
  ↓       ↓        ↓         ↓         ↓         ↓
stdin → tokens → expanded → commands → process → stdout
```

## 👥 Équipe

- **Développeur Principal** : dibsejra
- **École** : 42 Lausanne
- **Projet** : Minishell

## 📚 Documentation Complète

- [🏛️ Architecture Détaillée](ARCHITECTURE.md)
- [🔬 Analyse Technique](TECHNICAL_DEEP_DIVE.md)
- [⚡ Performance et Tests](PERFORMANCE.md)
- [🎤 Guide de Présentation](PRESENTATION_GUIDE.md)
- [🚀 Guide de Développement](DEVELOPMENT_GUIDE.md)

## 🏆 Statut du Projet

✅ **Fonctionnel** - Toutes les fonctionnalités requises implémentées  
✅ **Norme 42** - 100% conforme  
✅ **Memory Safe** - 0 leaks Valgrind  
✅ **Testé** - Batteries de tests complètes  
✅ **Documenté** - Documentation technique complète  

---

*Développé avec ❤️ à l'École 42*