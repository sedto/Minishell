
# 🏛️ Architecture du Projet Minishell

## 📁 Structure Détaillée des Dossiers

```
minishell/
├── src/                           # 🎯 Point d'entrée
│   ├── main.c                     # • Boucle principale et gestion shell
│   ├── main_utils.c               # • Parsing et traitement des commandes
│   └── main_utils_helpers.c       # • Fonctions utilitaires du main
│
├── parsing/                       # 🔍 Module de parsing complet
│   ├── utils/
│   │   ├── clean_input.c          # • Nettoyage et préparation input
│   │   └── clean_input_utils.c    # • Utilitaires de nettoyage
│   │
│   ├── lexer/                     # 📝 Analyse lexicale
│   │   ├── create_tokens.c        # • Création des tokens
│   │   ├── tokenize.c             # • Tokenisation principale
│   │   ├── tokenize_utils.c       # • Utilitaires de tokenisation
│   │   └── tokenize_operators.c   # • Gestion des opérateurs
│   │
│   ├── expander/                  # 🔧 Expansion des variables
│   │   ├── expand_variables.c     # • Expansion $VAR, $?, etc.
│   │   ├── expand_strings.c       # • Expansion dans les strings
│   │   ├── expand_process.c       # • Traitement des expansions
│   │   ├── expand_quotes.c        # • Gestion des quotes
│   │   ├── expand_utils.c         # • Utilitaires d'expansion
│   │   ├── expand_buffer.c        # • Gestion des buffers
│   │   ├── expand_helpers.c       # • Fonctions helper
│   │   └── expand_utils_extra.c   # • Utilitaires supplémentaires
│   │
│   └── parser/                    # 🏗️ Construction des commandes
│       ├── create_commande.c      # • Création des structures cmd
│       ├── create_commande_utils.c    # • Utilitaires de création
│       ├── create_commande_helpers.c  # • Helpers de création
│       ├── parse_commands.c       # • Parsing des commandes
│       ├── parse_commands_utils.c # • Utilitaires de parsing
│       ├── parse_handlers.c       # • Gestionnaires de parsing
│       ├── parse_validation.c     # • Validation syntaxique
│       ├── parse_utils.c          # • Utilitaires généraux
│       ├── quote_remover.c        # • Suppression des quotes
│       ├── heredoc_utils.c        # • Gestion heredoc principale
│       ├── heredoc_helpers.c      # • Helpers heredoc
│       ├── heredoc_read.c         # • Lecture heredoc
│       └── heredoc_support.c      # • Support heredoc
│
├── execution/                     # ⚡ Module d'exécution
│   ├── signals/
│   │   └── signals.c              # • Gestion Ctrl+C, Ctrl+\
│   │
│   ├── env/                       # 🌍 Variables d'environnement
│   │   ├── env_utils.c            # • Utilitaires environnement
│   │   ├── env_utils_extra.c      # • Utilitaires supplémentaires
│   │   └── env_conversion.c       # • Conversion env ↔ array
│   │
│   ├── builtins/                  # 🛠️ Commandes intégrées
│   │   ├── builtins.c             # • Dispatcher des builtins
│   │   ├── builtins_basic.c       # • echo, pwd, cd
│   │   ├── builtins_export.c      # • export, unset
│   │   └── builtins_exit.c        # • exit avec codes
│   │
│   ├── utils/                     # 🔧 Utilitaires d'exécution
│   │   ├── utils.c                # • Utilitaires généraux
│   │   ├── utils_extra.c          # • Utilitaires supplémentaires
│   │   └── utils_commands.c       # • Gestion des commandes
│   │
│   └── executor/                  # 🚀 Cœur de l'exécution
│       ├── executors.c            # • Exécution principale
│       ├── executors_redirections.c  # • Gestion redirections
│       ├── executors_utils.c      # • Utilitaires d'exécution
│       ├── get_path.c             # • Résolution des paths
│       └── errors_env.c           # • Gestion des erreurs
│
├── includes/
│   └── minishell.h                # 📋 Headers et structures
│
├── libft/                         # 📚 Bibliothèque personnelle
└── documentation/                 # 📖 Documentation projet
```

## 🔄 Flow d'Exécution Détaillé

### 1. 🎯 Phase d'Entrée (src/)
```
main() → setup_shell() → run_interactive_mode()
    ↓
readline("minishell$ ") → handle_input_line()
```

### 2. 🔍 Phase de Parsing (parsing/)

#### A. Nettoyage Initial
```
Input: "echo   'hello world'  |  cat"
    ↓ clean_input()
Clean: "echo 'hello world' | cat"
```

#### B. Lexing (lexer/)
```
Clean Input → tokenize() → Tokens
"echo 'hello world' | cat"
    ↓
[WORD: echo] [WORD: 'hello world'] [PIPE: |] [WORD: cat] [EOF]
```

#### C. Expansion (expander/)
```
Tokens → expand_all_tokens() → Expanded Tokens
[WORD: 'hello world'] → [WORD: hello world]  # Suppression quotes
$HOME → /Users/username                       # Expansion variables
```

#### D. Parsing Final (parser/)
```
Expanded Tokens → parse_tokens_to_commands() → Command Structures
    ↓
t_cmd {
    args: ["echo", "hello world"]
    files: NULL
    next: t_cmd {
        args: ["cat"]
        files: NULL
        next: NULL
    }
}
```

### 3. ⚡ Phase d'Exécution (execution/)

#### A. Préparation
```
Commands → execute_commands() → Setup pipes & processes
```

#### B. Exécution
```
Pour chaque commande:
1. fork() → Processus enfant
2. Setup redirections/pipes
3. execve() ou builtin
4. wait() → Récupération des résultats
```

## 🧠 Structures de Données Principales

### Token Structure
```c
typedef struct s_token {
    char            *value;     // Valeur du token
    t_token_type    type;       // WORD, PIPE, REDIR_IN, etc.
    struct s_token  *next;      // Token suivant
} t_token;
```

### Command Structure
```c
typedef struct s_cmd {
    char            **args;     // Arguments de la commande
    t_file          *files;     // Fichiers de redirection
    struct s_cmd    *next;      // Commande suivante (pipe)
} t_cmd;
```

### File Structure (Redirections)
```c
typedef struct s_file {
    char            *name;              // Nom du fichier
    char            *heredoc_content;   // Contenu heredoc
    int             fd;                 // File descriptor
    t_redir         type;               // INPUT, OUTPUT, APPEND, HEREDOC
    struct s_file   *next;              // Fichier suivant
} t_file;
```

### Shell Structure
```c
typedef struct s_minishell {
    t_env           *env;           // Variables d'environnement
    t_cmd           *commands;      // Commandes à exécuter
    int             exit_status;    // Code de sortie
    int             saved_stdin;    // Backup stdin
    int             saved_stdout;   // Backup stdout
} t_minishell;
```

## 🎯 Patterns Architecturaux Utilisés

### 1. **Pipeline Pattern**
Chaque phase transforme les données et les passe à la suivante :
```
Input → Lexing → Expansion → Parsing → Execution → Output
```

### 2. **Command Pattern**
Les commandes sont encapsulées dans des structures pour l'exécution différée.

### 3. **Strategy Pattern**
Différentes stratégies pour les builtins vs commandes externes.

### 4. **Chain of Responsibility**
Les tokens et commandes sont chaînés pour le traitement séquentiel.

## 🚀 Optimisations d'Architecture

### 1. **Modularité Stricte**
- Chaque module a une responsabilité claire
- Interfaces bien définies entre modules
- Couplage faible, cohésion forte

### 2. **Gestion Mémoire Centralisée**
- Fonctions de nettoyage dédiées par structure
- Libération systématique des ressources
- Zéro leak garanti

### 3. **Respect de la Norme 42**
- Maximum 5 fonctions par fichier
- Maximum 25 lignes par fonction
- Découpage intelligent des responsabilités

### 4. **Extensibilité**
- Ajout facile de nouveaux builtins
- Extension simple du lexer pour nouveaux opérateurs
- Architecture prête pour de nouvelles fonctionnalités

## 🔍 Points d'Attention Architecturaux

### 1. **Gestion des Erreurs**
Propagation cohérente des erreurs à travers tous les modules.

### 2. **Gestion des Signaux**
Intégration propre avec la boucle principale sans interférence.

### 3. **Performance**
Optimisation des allocations mémoire et des appels système.

### 4. **Maintenabilité**
Code auto-documenté avec nommage explicite des fonctions.

---

Cette architecture modulaire garantit la **maintenabilité**, **l'extensibilité** et le **respect strict de la norme 42**.