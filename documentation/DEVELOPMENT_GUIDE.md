# 🛠️ Guide de Développement - Minishell

## 🚀 Environnement de Développement

### 📋 Prérequis
```bash
# Système
- macOS 10.15+ ou Linux Ubuntu 18.04+
- GCC 8.0+ ou Clang 10.0+
- Make 4.0+
- Git 2.20+

# Outils de développement
- Valgrind (pour tests mémoire)
- Norminette (pour validation norme 42)
- gdb/lldb (pour debugging)
```

### 🔧 Installation Rapide
```bash
# Clone du projet
git clone <repository-url>
cd parsing

# Compilation
make
make bonus  # Si applicable

# Tests
make test   # Tests automatisés
make clean  # Nettoyage
make fclean # Nettoyage complet
make re     # Recompilation complète
```

## 📁 Structure de Projet Détaillée

```
parsing/
├── 📁 src/                          # Code source principal
│   ├── main.c                       # Point d'entrée
│   ├── main_utils.c                 # Utilitaires main
│   └── main_utils_helpers.c         # Helpers main
│
├── 📁 parsing/srcs/parser/          # Module de parsing
│   ├── parse_utils.c               # Utilitaires parsing
│   ├── parse_handlers.c            # Gestionnaires tokens
│   ├── parse_validation.c          # Validation syntaxe
│   ├── parse_commands.c            # Construction commandes
│   ├── parse_commands_utils.c      # Utilitaires commandes
│   ├── quote_remover.c             # Gestion quotes
│   ├── heredoc_utils.c             # Heredoc principal
│   ├── heredoc_helpers.c           # Helpers heredoc
│   ├── heredoc_read.c              # Lecture heredoc
│   ├── heredoc_support.c           # Support heredoc
│   ├── create_commande.c           # Création structures
│   ├── create_commande_utils.c     # Utilitaires création
│   └── create_commande_helpers.c   # Helpers création
│
├── 📁 execution/srcs/executor/      # Module d'exécution
│   ├── executors.c                 # Exécution principale
│   ├── executors_redirections.c   # Gestion redirections
│   └── executors_utils.c           # Utilitaires exécution
│
├── 📁 includes/                     # Headers
│   └── minishell.h                 # Header principal
│
├── 📁 libft/                        # Bibliothèque utilitaire
│   └── [fichiers libft]
│
├── 📁 documentation/                # Documentation projet
│   ├── README.md                   # Vue d'ensemble
│   ├── ARCHITECTURE.md             # Architecture détaillée
│   ├── TECHNICAL_DEEP_DIVE.md      # Analyse technique
│   ├── PERFORMANCE.md              # Métriques performance
│   ├── PRESENTATION_GUIDE.md       # Guide présentation
│   └── DEVELOPMENT_GUIDE.md        # Ce fichier
│
├── Makefile                         # Système de build
└── .gitignore                      # Fichiers ignorés Git
```

## 🏗️ Workflow de Développement

### 🔄 Cycle de Développement Standard

```bash
# 1. Nouvelle fonctionnalité
git checkout -b feature/nouvelle-fonction
git pull origin main

# 2. Développement
# - Modifier le code
# - Respecter la norme 42
# - Ajouter des tests

# 3. Validation continue
make                    # Compilation
norminette **/*.c **/*.h # Vérification norme
valgrind ./minishell    # Test mémoire
./test_suite.sh         # Tests automatisés

# 4. Commit et push
git add .
git commit -m "feat: nouvelle fonctionnalité

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin feature/nouvelle-fonction

# 5. Merge
git checkout main
git merge feature/nouvelle-fonction
git branch -d feature/nouvelle-fonction
```

### 🎯 Standards de Code

#### Norme 42 - Checklist
- [ ] **Fonctions** : Maximum 25 lignes
- [ ] **Fichiers** : Maximum 5 fonctions par fichier
- [ ] **Paramètres** : Maximum 4 paramètres par fonction
- [ ] **Variables** : Maximum 5 variables par fonction
- [ ] **Lignes** : Maximum 80 caractères par ligne
- [ ] **Indentation** : Tabs uniquement
- [ ] **Espaces** : Pas d'espaces en fin de ligne
- [ ] **Headers** : Header 42 obligatoire

#### Conventions de Nommage
```c
// Types
typedef struct s_example    t_example;
typedef enum e_token_type   t_token_type;

// Fonctions
int     function_name(int param);
void    free_structure(t_example *data);
char    *get_value(char *key);

// Variables
int     variable_name;
char    *string_ptr;
t_cmd   *command_list;

// Constantes
#define MAX_BUFFER_SIZE     1024
#define ERROR_CODE_SYNTAX   2
```

#### Structure des Fonctions
```c
// Template de fonction standard
static int	process_data(t_data *data, char *input, int flags)
{
	int		result;
	char	*processed;

	if (!data || !input)
		return (-1);
	processed = validate_input(input);
	if (!processed)
		return (-1);
	result = execute_process(data, processed, flags);
	free(processed);
	return (result);
}
```

### 🧪 Tests et Validation

#### Suite de Tests Complète
```bash
#!/bin/bash
# run_all_tests.sh

echo "🧪 Minishell - Suite de Tests Complète"

# Test 1: Compilation
echo "📦 Test compilation..."
make fclean && make
if [ $? -ne 0 ]; then
    echo "❌ Échec compilation"
    exit 1
fi
echo "✅ Compilation OK"

# Test 2: Norme 42
echo "📏 Test norme 42..."
norminette **/*.c **/*.h | grep -E "Error|Warning"
if [ $? -eq 0 ]; then
    echo "❌ Erreurs norminette détectées"
    exit 1
fi
echo "✅ Norme 42 OK"

# Test 3: Tests fonctionnels
echo "⚙️ Tests fonctionnels..."
./test_suite.sh
if [ $? -ne 0 ]; then
    echo "❌ Échec tests fonctionnels"
    exit 1
fi
echo "✅ Tests fonctionnels OK"

# Test 4: Tests mémoire (optionnel, long)
if [ "$1" = "--memory" ]; then
    echo "🧠 Tests mémoire Valgrind..."
    echo "exit" | valgrind --leak-check=full --error-exitcode=1 ./minishell
    if [ $? -ne 0 ]; then
        echo "❌ Memory leaks détectés"
        exit 1
    fi
    echo "✅ Mémoire OK"
fi

echo "🎉 Tous les tests passés avec succès!"
```

#### Tests Unitaires par Module
```c
// test_parser.c - Exemple de test unitaire
#include "minishell.h"

int test_parse_simple_command(void)
{
    char *input = "echo hello";
    t_token *tokens = tokenize(input);
    t_cmd *cmd = parse_tokens(tokens);
    
    if (!cmd || strcmp(cmd->args[0], "echo") != 0)
        return (0);
    if (!cmd->args[1] || strcmp(cmd->args[1], "hello") != 0)
        return (0);
    
    free_tokens(tokens);
    free_commands(cmd);
    return (1);
}

int main(void)
{
    int passed = 0;
    int total = 1;
    
    if (test_parse_simple_command())
        passed++;
    
    printf("Tests: %d/%d passés\n", passed, total);
    return (passed == total ? 0 : 1);
}
```

## 🔧 Debugging et Troubleshooting

### 🐛 Debugging avec GDB
```bash
# Compilation avec symboles debug
make CFLAGS="-g -O0"

# Lancement GDB
gdb ./minishell

# Commandes GDB utiles
(gdb) break main                    # Point d'arrêt
(gdb) run                          # Exécution
(gdb) next                         # Ligne suivante
(gdb) step                         # Entrer dans fonction
(gdb) print variable_name          # Afficher variable
(gdb) backtrace                    # Stack trace
(gdb) info locals                  # Variables locales
```

### 🔍 Debugging Valgrind Avancé
```bash
# Détection de leaks précise
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         ./minishell

# Profiling mémoire
valgrind --tool=massif ./minishell
ms_print massif.out.* > memory_profile.txt

# Détection d'erreurs mémoire
valgrind --tool=memcheck \
         --track-fds=yes \
         --trace-children=yes \
         ./minishell
```

### 🚨 Problèmes Courants et Solutions

#### Memory Leaks dans Child Processes
```c
// ❌ Problème
void exec_command(t_cmd *cmd) {
    pid_t pid = fork();
    if (pid == 0) {
        execve(cmd->path, cmd->args, environ);
        exit(127);  // Leak : pas de cleanup
    }
}

// ✅ Solution
void exec_command(t_minishell *shell, t_cmd *cmd) {
    pid_t pid = fork();
    if (pid == 0) {
        if (execve(cmd->path, cmd->args, environ) == -1) {
            child_exit(shell, 127);  // Cleanup avant exit
        }
    }
}

void child_exit(t_minishell *shell, int code) {
    free_minishell(shell);
    exit(code);
}
```

#### Gestion des File Descriptors
```c
// ❌ Problème : FD pas fermés
int setup_pipe(int *pipe_fd) {
    if (pipe(pipe_fd) == -1)
        return (-1);
    // Oubli de fermer pipe_fd[0] et pipe_fd[1]
}

// ✅ Solution : Tracking et fermeture systématique
typedef struct s_fd_tracker {
    int     fd;
    int     in_use;
} t_fd_tracker;

void close_unused_fds(t_fd_tracker *fds, int count) {
    for (int i = 0; i < count; i++) {
        if (fds[i].in_use && fds[i].fd >= 0) {
            close(fds[i].fd);
            fds[i].fd = -1;
            fds[i].in_use = 0;
        }
    }
}
```

#### Parsing d'Erreurs Complexes
```c
// Debugging des erreurs de parsing
void debug_tokens(t_token *tokens) {
    t_token *current = tokens;
    int i = 0;
    
    printf("=== DEBUG TOKENS ===\n");
    while (current) {
        printf("Token[%d]: type=%d, value='%s'\n", 
               i++, current->type, current->value);
        current = current->next;
    }
    printf("===================\n");
}
```

## 📚 Ressources et Documentation

### 🔗 Liens Utiles
- **Norme 42** : [Norminette officielle](https://github.com/42School/norminette)
- **Bash Manual** : [GNU Bash Reference](https://www.gnu.org/software/bash/manual/)
- **Valgrind** : [Documentation officielle](https://valgrind.org/docs/manual/)
- **GDB** : [Guide complet](https://www.gnu.org/software/gdb/documentation/)

### 📖 Documentation Interne
- `ARCHITECTURE.md` : Vue d'ensemble de l'architecture
- `TECHNICAL_DEEP_DIVE.md` : Analyse technique approfondie
- `PERFORMANCE.md` : Métriques et optimisations
- `PRESENTATION_GUIDE.md` : Guide pour présenter le projet

### 🎓 Formations Recommandées
- **Système Unix** : pipes, processus, signaux
- **Parsing** : lexers, parsers, AST
- **Memory Management** : allocation, pointeurs, leaks
- **Architecture Logicielle** : modularité, patterns

## 🤝 Contribution et Collaboration

### 📝 Template de Commit
```bash
git commit -m "type(scope): description courte

Description détaillée du changement si nécessaire.

- Point spécifique 1
- Point spécifique 2

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 🏷️ Types de Commits
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `refactor:` Refactoring sans changement fonctionnel
- `norm:` Correction norme 42
- `test:` Ajout/modification de tests
- `docs:` Documentation
- `style:` Formatage, style

### 🔍 Code Review Checklist
- [ ] Compilation sans warnings
- [ ] Norme 42 respectée
- [ ] Tests passants
- [ ] Pas de memory leaks
- [ ] Documentation à jour
- [ ] Performance acceptable

---

## 🎯 Best Practices Résumées

1. **Toujours** vérifier la norme 42 avant commit
2. **Jamais** laisser de memory leaks
3. **Systématiquement** tester les nouvelles fonctionnalités
4. **Documenter** les choix architecturaux importants
5. **Modulariser** le code pour faciliter la maintenance
6. **Optimiser** après avoir validé la fonctionnalité

**Happy coding ! 🚀**