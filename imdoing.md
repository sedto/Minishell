# Modifications apportées au Minishell

## Vue d'ensemble
Ce document explique les corrections apportées pour résoudre 3 tests qui échouaient dans le minishell.

## Tests corrigés

### Test 40: `cd $PWD hi` - Erreur "too many arguments"
**Problème:** La fonction `builtin_cd` ne vérifiait pas si l'utilisateur passait trop d'arguments.
**Localisation:** `/home/heartmetal/Desktop/V42/execution/srcs/builtins/builtins.c:28-56`

**Modification apportée:**
```c
// Avant (ligne 33):
cmd = s->commands;
if (!cmd->args[1])

// Après (lignes 33-38):
cmd = s->commands;
if (cmd->args[1] && cmd->args[2])
{
    write(STDERR_FILENO, "cd: too many arguments\n", 24);
    return (1);
}
if (!cmd->args[1])
```

**Explication:** J'ai ajouté une vérification au début de la fonction pour détecter si `args[1]` (premier argument) et `args[2]` (deuxième argument) existent simultanément. Si c'est le cas, cela signifie que l'utilisateur a passé trop d'arguments à la commande `cd`, et on affiche l'erreur appropriée.

### Test 50: `exit hello` - Validation des arguments numériques
**Problème:** La fonction `builtin_exit` retournait un code d'erreur incorrect (255) au lieu du code d'erreur standard bash (2).
**Localisation:** `/home/heartmetal/Desktop/V42/execution/srcs/builtins/builtins.c:184-219`

**Modifications apportées:**

1. **Amélioration de la validation numérique (lignes 184-202):**
```c
// Avant:
static int is_str_num(char *str)
{
    int i = 0;
    if (str[i] == '-' || str[i] == '+')
        i++;
    while (str[i])
    {
        if (str[i] < '0' || str[i] > '9')
            return (1);
        i++;
    }
    return (0);
}

// Après:
static int is_str_num(char *str)
{
    int i = 0;
    if (!str || !str[0])        // Vérification string vide/null
        return (1);
    if (str[i] == '-' || str[i] == '+')
        i++;
    if (!str[i])               // Vérification si seulement +/- sans chiffres
        return (1);
    while (str[i])
    {
        if (str[i] < '0' || str[i] > '9')
            return (1);
        i++;
    }
    return (0);
}
```

2. **Correction du code d'erreur (ligne 218):**
```c
// Avant:
exit(255);

// Après:
exit(2);
```

**Explication:** J'ai renforcé la fonction `is_str_num` pour mieux gérer les cas limites (strings vides, seulement des signes +/-) et j'ai corrigé le code d'erreur pour correspondre au comportement de bash qui retourne 2 quand un argument non-numérique est passé à `exit`.

### Test 98: `echo hi >invalid_permission >outfile01 | echo bye` - Gestion des codes d'erreur des pipelines
**Problème:** Dans bash, le code d'erreur d'un pipeline correspond au code d'erreur de la dernière commande, même si des commandes précédentes ont des erreurs de redirection.
**Localisation:** `/home/heartmetal/Desktop/V42/execution/srcs/executor/executor.c:227-287`

**Modification apportée:**
```c
// Avant (lignes 227-273):
void execute_commands(t_minishell **s)
{
    int prev_fd, pipe_fd[2], stat;
    pid_t pid;
    
    // ... code d'exécution ...
    
    // Attente de tous les processus - problématique
    while (wait(&stat) > 0)
        (*s)->exit_status = WEXITSTATUS(stat);
}

// Après (lignes 227-287):
void execute_commands(t_minishell **s)
{
    int prev_fd, pipe_fd[2], stat;
    pid_t pid;
    pid_t last_pid;  // Nouveau: tracker le dernier processus
    
    // ... code d'exécution ...
    
    // Nouveau: identifier le dernier processus du pipeline
    if (!(*s)->commands->next)
        last_pid = pid;
    
    // ... code d'exécution ...
    
    // Nouvelle logique d'attente
    if (last_pid != -1)
    {
        waitpid(last_pid, &stat, 0);           // Attendre spécifiquement le dernier
        (*s)->exit_status = WEXITSTATUS(stat); // Utiliser son code d'erreur
        while (wait(NULL) > 0)                 // Nettoyer les autres processus
            ;
    }
    else
    {
        while (wait(&stat) > 0)                // Comportement original pour les cas simples
            (*s)->exit_status = WEXITSTATUS(stat);
    }
}
```

**Explication:** Le problème principal était que l'ancien code attendait tous les processus et utilisait le code d'erreur du dernier processus qui se terminait (pas forcément la dernière commande du pipeline). J'ai ajouté un système pour tracker spécifiquement le PID de la dernière commande du pipeline (`last_pid`) et utiliser `waitpid()` pour attendre ce processus en particulier et récupérer son code d'erreur. Cela respecte la sémantique bash où seul le code d'erreur de la dernière commande d'un pipeline compte.

## Résumé des changements

1. **Validation des arguments:** Amélioration de la vérification du nombre d'arguments pour `cd`
2. **Codes d'erreur standardisés:** Correction du code d'erreur `exit` pour correspondre à bash
3. **Gestion des pipelines:** Implémentation correcte de la sémantique des codes d'erreur des pipelines bash
4. **Robustesse:** Ajout de vérifications supplémentaires pour les cas limites

Ces modifications permettent au minishell de passer les 3 tests qui échouaient précédemment tout en maintenant la compatibilité avec le comportement bash standard.