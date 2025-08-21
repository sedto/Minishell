# 🏗️ Fonctionnement Global - Minishell

## 1. Vue d'ensemble du système

Minishell implémente un interpréteur de commandes complet qui reproduit le comportement de bash. Le système se compose de quatre modules principaux :

- **Interface utilisateur** : Gestion du prompt, historique, signaux
- **Module Parsing** : Analyse et traitement de la ligne de commande
- **Module Execution** : Exécution des commandes et gestion des processus
- **Module Environment** : Gestion des variables d'environnement et built-ins

---

## 2. Architecture des modules

```
┌─────────────────────────────────────────────────────────────────┐
│                         MINISHELL CORE                         │
├─────────────────────────────────────────────────────────────────┤
│  INPUT  →  PARSING  →  EXPANSION  →  EXECUTION  →  OUTPUT     │
└─────────────────────────────────────────────────────────────────┘
```

### **src/** : Module Principal
- **main.c** : Point d'entrée, boucle interactive principale
- **main_utils.c** : Gestion des signaux, initialisation environnement
- **main_utils_helpers.c** : Fonctions auxiliaires de démarrage

### **parsing/** : Module Parsing
- **lexer/** : Découpage en tokens (mots, opérateurs, redirections)
- **expander/** : Expansion variables ($VAR) et gestion quotes
- **parser/** : Construction structure de commandes
- **utils/** : Nettoyage et validation de l'input

### **execution/** : Module Execution  
- **executor/** : Gestion processus, pipes, redirections
- **builtins/** : Commandes intégrées (cd, echo, export...)
- **env/** : Variables d'environnement et manipulation
- **signals/** : Gestion signaux système (Ctrl-C, Ctrl-D...)
- **utils/** : Utilitaires execution et gestion erreurs

---

## 3. Structures de données principales

### Structure Centrale : `t_minishell`
```c
typedef struct s_minishell {
    t_env       *env;           // Variables d'environnement
    t_cmd       *commands;      // Liste des commandes à exécuter
    char        **envp;         // Array environnement pour execve
    int         exit_code;      // Code de sortie ($?)
    int         in_heredoc;     // Flag heredoc en cours
} t_minishell;
```

### Structure Commande : `t_cmd`
```c
typedef struct s_cmd {
    char        **args;         // Arguments de la commande
    char        *path;          // Chemin exécutable résolu
    t_file      *files;         // Redirections (input/output)
    t_cmd       *next;          // Commande suivante (pipe)
    int         builtin_type;   // Type builtin si applicable
} t_cmd;
```

### Structure Token : `t_token`
```c
typedef struct s_token {
    char            *value;     // Contenu du token
    t_token_type    type;       // Type (WORD, PIPE, REDIRECT...)
    t_token         *next;      // Token suivant
    int             quoted;     // Flag si était entre quotes
} t_token;
```

---

## 4. Flux d'exécution détaillé

### Phase 1 : Initialisation
```c
// main.c - Démarrage du shell
1. Initialisation environnement (env, signaux)
2. Configuration readline et historique
3. Entrée dans la boucle interactive
```

### Phase 2 : Lecture Input
```c
// Interface utilisateur
1. Affichage prompt "minishell$ "
2. Lecture ligne avec readline()
3. Ajout à l'historique si non vide
4. Vérification signaux (Ctrl-C, Ctrl-D)
```

### Phase 3 : Preprocessing
```c
// parsing/srcs/utils/clean_input.c
1. Suppression espaces superflus
2. Validation quotes fermées
3. Gestion cas particuliers (ligne vide, commentaires)
```

### Phase 4 : Tokenisation
```c
// parsing/srcs/lexer/tokenize.c
1. Découpage en tokens selon délimiteurs
2. Identification types (WORD, PIPE, REDIRECT_IN, REDIRECT_OUT...)
3. Gestion quotes (préservation contenu)
4. Construction liste chaînée de tokens
```

### Phase 5 : Expansion
```c
// parsing/srcs/expander/expand_process.c
1. Expansion variables ($HOME, $USER, $?, etc.)
2. Gestion quotes (simple vs double)
3. Échappement caractères spéciaux
4. Résolution chemins relatifs/absolus
```

### Phase 6 : Parsing Structure
```c
// parsing/srcs/parser/parse_commands.c
1. Analyse syntaxique des tokens
2. Construction commandes avec arguments
3. Association redirections à commandes
4. Gestion pipes et séparation commandes
5. Validation finale syntaxe
```

### Phase 7 : Exécution
```c
// execution/srcs/executor/executors.c
1. Résolution chemins exécutables (PATH)
2. Détection built-ins vs externes
3. Setup pipes pour commandes multiples
4. Fork processus enfants si nécessaire
5. Application redirections (dup2)
6. Exécution commandes (execve ou builtin)
7. Attente processus enfants et récupération codes
```

### Phase 8 : Nettoyage
```c
// Gestion mémoire et cleanup
1. Libération structures (tokens, commandes)
2. Fermeture file descriptors
3. Mise à jour variables ($?, PWD...)
4. Préparation iteration suivante
```

---

## 5. Gestion des cas spéciaux

### Pipes et Redirections
```bash
# Exemple: echo hello | cat > output.txt
1. Tokenisation: [WORD:echo] [WORD:hello] [PIPE:|] [WORD:cat] [REDIRECT:>] [WORD:output.txt]
2. Parsing: CMD1{echo hello} → PIPE → CMD2{cat > output.txt}
3. Execution: 
   - Fork pour echo, stdout → pipe[1]
   - Fork pour cat, stdin ← pipe[0], stdout → output.txt
   - Coordination des file descriptors
   - Attente des deux processus
```

### Heredoc (`<<`)
```bash
# Exemple: cat << EOF
1. Détection token HEREDOC avec délimiteur "EOF"
2. Mode interactif: lecture lignes jusqu'à "EOF"
3. Stockage contenu dans fichier temporaire ou pipe
4. Redirection stdin vers contenu heredoc
5. Expansion variables dans contenu si entre doubles quotes
```

### Variables d'Environnement
```bash
# Exemple: echo "Hello $USER"
1. Détection "$USER" dans expansion
2. Recherche dans liste environnement
3. Remplacement par valeur ou chaîne vide
4. Préservation de la structure des quotes
```

### Built-ins Spéciaux
```c
// Built-ins exécutés dans processus parent (cd, export, unset, exit)
if (is_builtin(cmd)) {
    run_builtin(shell, cmd);  // Pas de fork()
} else {
    run_external_command(shell, cmd);  // Fork + execve
}
```

---

## 6. Gestion des erreurs et signaux

### Codes d'Erreur Standard
- **0** : Succès
- **1** : Erreur générale
- **2** : Erreur syntaxe
- **126** : Permission refusée
- **127** : Commande introuvable

### Signaux Système
```c
// execution/srcs/signals/signals.c
- SIGINT (Ctrl-C): Interrupt → nouveau prompt
- SIGQUIT (Ctrl-\): Ignoré en mode interactif  
- EOF (Ctrl-D): Sortie propre du shell
```

### Gestion Mémoire
```c
// Pattern de nettoyage systématique
void cleanup_all(t_minishell *shell) {
    free_commands(shell->commands);
    free_env_list(shell->env);
    free_envp_array(shell->envp);
    // Toujours nettoyer avant exit
}
```

---

## 7. Optimisations et patterns

### Memory Pooling
- Réutilisation structures tokens fréquentes
- Buffers dynamiques pour parsing
- Cache variables environnement

### Error Propagation  
- Codes d'erreur cohérents dans tout le système
- Nettoyage systématique en cas d'erreur
- Messages d'erreur informatifs

### Modularité
- Séparation claire responsabilités
- Interfaces bien définies entre modules  
- Extensibilité pour futures fonctionnalités

---

## 8. Points d'attention critiques

### Norme 42 Compliance
- Maximum 25 lignes par fonction
- Maximum 5 fonctions par fichier  
- Maximum 4 paramètres par fonction
- Structures de données pour passer paramètres multiples

### Memory Safety
- Libération systématique mémoire allouée
- Vérification pointeurs avant déréférencement
- Cleanup des processus enfants

### Signal Safety
- Variable globale unique pour signaux
- Gestion atomique des signaux
- Pas d'accès structures principales depuis handlers

---

## 9. Flux de données complet

```
INPUT: "export VAR=hello && echo $VAR | cat > output"

1. CLEAN:     "export VAR=hello && echo $VAR | cat > output"
2. TOKENIZE:  [WORD:export] [WORD:VAR=hello] [AND:&&] [WORD:echo] [VAR:$VAR] [PIPE:|] [WORD:cat] [REDIRECT:>] [WORD:output]
3. EXPAND:    [WORD:export] [WORD:VAR=hello] [AND:&&] [WORD:echo] [WORD:hello] [PIPE:|] [WORD:cat] [REDIRECT:>] [WORD:output]
4. PARSE:     CMD1{export VAR=hello} AND CMD2{echo hello | cat > output}
5. EXECUTE:   
   - Builtin export dans parent
   - Pipeline: fork echo → pipe → fork cat → redirect output
6. CLEANUP:   Libération mémoire, fermeture FDs, update $?
```

---

## 10. Pour aller plus loin

### Debugging
- **GDB** : Points d'arrêt sur fonctions clés
- **Valgrind** : Détection leaks et erreurs mémoire
- **Logs** : Printf debugging ciblé

### Tests
- **Conformité bash** : Comparaison comportements
- **Edge cases** : Quotes imbriquées, redirections multiples
- **Performance** : Commandes longues, pipes complexes

### Extensions Possibles
- **Job control** : Background processes (&)
- **Command substitution** : $(command)
- **Wildcards** : Expansion * et ?
- **Advanced redirection** : &>, <&, etc.

---

Ce document décrit le fonctionnement complet du système minishell, de l'input utilisateur à l'output final, en passant par toutes les transformations et traitements intermédiaires.