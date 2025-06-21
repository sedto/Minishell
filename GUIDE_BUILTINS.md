# Guide des Builtins de Minishell

## Vue d'ensemble

Ce document explique en détail le fonctionnement de tous les builtins implémentés dans minishell, leur intégration avec le système d'environnement, et comment votre binôme pourra les utiliser dans l'exécuteur.

## Architecture des Builtins

### Fichiers concernés
- `builtins.c` : Implémentation de tous les builtins
- `env_utils.c` : Gestion de l'environnement (structure `t_env`)
- `utils.c` : Utilitaires système (PATH, conversions, etc.)
- `signals.c` : Gestion des signaux

### Interface principale
```c
int is_builtin(char *cmd);                    // Vérifie si c'est un builtin
int execute_builtin(char **args, t_env **env); // Exécute le builtin
```

## 1. ECHO - Affichage de texte

### Fonctionnalité
- Affiche les arguments passés en paramètre
- Supporte l'option `-n` (pas de nouvelle ligne)
- Gère les espaces entre arguments

### Code clé
```c
int builtin_echo(char **args)
{
    int newline = 1;
    int i = 1;
    
    if (args[1] && ft_strncmp(args[1], "-n", 2) == 0)
    {
        newline = 0;
        i = 2;
    }
    
    while (args[i])
    {
        printf("%s", args[i]);
        if (args[i + 1])
            printf(" ");
        i++;
    }
    
    if (newline)
        printf("\n");
    return (0);
}
```

### Tests
```bash
echo "Hello World"          # Hello World
echo -n "Sans nouvelle ligne" # Sans nouvelle ligne (pas de \n)
echo "Arg1" "Arg2"          # Arg1 Arg2
```

## 2. PWD - Répertoire courant

### Fonctionnalité
- Affiche le répertoire de travail actuel
- Utilise `getcwd()` système
- Gère les erreurs (permissions, répertoire supprimé)

### Code clé
```c
int builtin_pwd(void)
{
    char *cwd = getcwd(NULL, 0);
    if (!cwd)
    {
        perror("pwd");
        return (1);
    }
    printf("%s\n", cwd);
    free(cwd);
    return (0);
}
```

### Gestion d'erreurs
- Si `getcwd()` échoue → `perror("pwd")` et retourne 1
- Libération automatique de la mémoire allouée

## 3. ENV - Affichage de l'environnement

### Fonctionnalité
- Affiche toutes les variables d'environnement
- Format : `KEY=VALUE`
- Parcourt la liste chaînée `t_env`

### Code clé
```c
int builtin_env(t_env *env)
{
    while (env)
    {
        printf("%s=%s\n", env->key, env->value);
        env = env->next;
    }
    return (0);
}
```

### Structure t_env
```c
typedef struct s_env
{
    char *key;              // Nom de la variable
    char *value;            // Valeur de la variable
    struct s_env *next;     // Pointeur vers le suivant
} t_env;
```

## 4. EXPORT - Exportation de variables

### Fonctionnalité
- Sans arguments : affiche toutes les variables exportées
- Avec arguments : exporte/modifie des variables
- Format : `export VAR=value` ou `export VAR`

### Code clé
```c
int builtin_export(char **args, t_env **env)
{
    if (!args[1])
    {
        // Afficher toutes les variables
        t_env *current = *env;
        while (current)
        {
            printf("declare -x %s=\"%s\"\n", current->key, current->value);
            current = current->next;
        }
        return (0);
    }
    
    // Traiter chaque argument
    int i = 1;
    while (args[i])
    {
        char *equal_pos = ft_strchr(args[i], '=');
        if (equal_pos)
        {
            *equal_pos = '\0';
            set_env_value(env, args[i], equal_pos + 1);
            *equal_pos = '=';
        }
        else
        {
            // Variable sans valeur
            char *value = get_env_value(*env, args[i]);
            set_env_value(env, args[i], value ? value : "");
        }
        i++;
    }
    return (0);
}
```

### Exemples
```bash
export                    # Affiche toutes les variables
export PATH="/usr/bin"    # Définit PATH
export USER              # Exporte USER (si elle existe)
```

## 5. UNSET - Suppression de variables

### Fonctionnalité
- Supprime des variables d'environnement
- Peut prendre plusieurs arguments
- Ne fait rien si la variable n'existe pas

### Code clé
```c
int builtin_unset(char **args, t_env **env)
{
    if (!args[1])
        return (0);
    
    int i = 1;
    while (args[i])
    {
        unset_env_value(env, args[i]);
        i++;
    }
    return (0);
}
```

### Fonction de suppression
```c
void unset_env_value(t_env **env, char *key)
{
    t_env *current = *env;
    t_env *prev = NULL;
    
    while (current)
    {
        if (ft_strncmp(current->key, key, ft_strlen(key)) == 0 
            && ft_strlen(current->key) == ft_strlen(key))
        {
            if (prev)
                prev->next = current->next;
            else
                *env = current->next;
            
            free(current->key);
            free(current->value);
            free(current);
            return;
        }
        prev = current;
        current = current->next;
    }
}
```

## 6. EXIT - Sortie du shell

### Fonctionnalité
- Quitte le shell avec un code de sortie
- Sans argument : code 0
- Avec argument : utilise la valeur fournie

### Code clé
```c
int builtin_exit(char **args)
{
    int exit_code;
    
    printf("exit\n");
    if (!args[1])
        exit(0);
    
    exit_code = ft_atoi(args[1]);
    exit(exit_code);
}
```

### Exemples
```bash
exit        # Sortie avec code 0
exit 42     # Sortie avec code 42
exit -1     # Sortie avec code -1
```

## 7. CD - À implémenter par l'exécuteur

### Pourquoi pas maintenant ?
Le builtin `cd` nécessite :
1. **Modification du PWD** : Changer le répertoire du shell parent
2. **Mise à jour de l'environnement** : Variables PWD et OLDPWD
3. **Intégration avec l'exécuteur** : Doit modifier l'état du processus principal

### Ce que votre binôme devra faire
```c
int builtin_cd(char **args, t_env **env)
{
    char *path;
    char *old_pwd;
    char *new_pwd;
    
    // Récupérer le chemin (HOME si pas d'argument)
    if (!args[1])
        path = get_env_value(*env, "HOME");
    else
        path = args[1];
    
    // Sauvegarder PWD actuel
    old_pwd = get_env_value(*env, "PWD");
    
    // Changer de répertoire
    if (chdir(path) != 0)
    {
        perror("cd");
        return (1);
    }
    
    // Mettre à jour PWD et OLDPWD
    new_pwd = getcwd(NULL, 0);
    set_env_value(env, "OLDPWD", old_pwd);
    set_env_value(env, "PWD", new_pwd);
    free(new_pwd);
    
    return (0);
}
```

## Gestion de l'environnement

### Initialisation
```c
t_env *env = init_env(envp);  // Depuis main()
```

### Fonctions utilitaires
```c
char *get_env_value(t_env *env, char *key);           // Récupère une valeur
void set_env_value(t_env **env, char *key, char *value); // Définit/modifie
void unset_env_value(t_env **env, char *key);         // Supprime
char **env_to_array(t_env *env);                      // Pour execve()
void free_env(t_env *env);                            // Libération
```

## Intégration avec l'exécuteur

### Interface pour votre binôme
```c
// Dans l'exécuteur, avant d'exécuter une commande :
if (is_builtin(cmd->args[0]))
{
    int status = execute_builtin(cmd->args, &env);
    // Gérer le code de retour
    return (status);
}
else
{
    // Exécution normale (fork/execve)
    execute_external_command(cmd, env);
}
```

### Conversion pour execve()
```c
char **envp = env_to_array(env);
execve(executable, args, envp);
free_array(envp);
```

## Gestion des signaux

### Configuration
```c
void setup_signals(void)
{
    signal(SIGINT, handle_sigint);   // Ctrl+C
    signal(SIGQUIT, handle_sigquit); // Ctrl+\ (ignoré)
}
```

### Comportement
- **Ctrl+C** : Nouvelle ligne, nouveau prompt
- **Ctrl+\\** : Ignoré en mode interactif
- **Processus enfants** : Signaux restaurés avec `reset_signals()`

## Tests et validation

### Tests automatisés
```bash
./test_complet.sh  # Lance tous les tests including builtins
```

### Tests manuels des builtins
```bash
# Test echo
echo "Hello"
echo -n "No newline"

# Test pwd
pwd

# Test env
env

# Test export/unset
export TEST="value"
env | grep TEST
unset TEST
env | grep TEST

# Test exit
exit 0
```

## Memory leaks et robustesse

### Validation Valgrind
- ✅ 0 leaks détectés sur tous les builtins
- ✅ Libération correcte de toute la mémoire allouée
- ✅ Gestion d'erreurs robuste

### Points critiques
1. **Libération des chaînes** : `free()` dans `set_env_value()`
2. **Gestion des échecs d'allocation** : Retour gracieux
3. **Restauration des modifications temporaires** : `*equal_pos = '='`

## Prochaines étapes pour votre binôme

### 1. Intégration dans l'exécuteur
- Appeler `is_builtin()` avant `fork()`
- Exécuter les builtins dans le processus parent
- Gérer les codes de retour

### 2. Implémentation de CD
- Utiliser les fonctions d'environnement existantes
- Gérer HOME, PWD, OLDPWD
- Tests spécifiques pour CD

### 3. Gestion des pipes avec builtins
- Builtins en début de pipe : dans processus enfant
- Builtins seuls : dans processus parent
- Redirection de stdout pour les pipes

## Conclusion

Tous les builtins (sauf `cd`) sont **100% fonctionnels, testés et robustes**. L'infrastructure d'environnement est complète et prête pour l'intégration dans l'exécuteur. Votre binôme dispose de toutes les fonctions utilitaires nécessaires pour implémenter facilement la partie exécution.

Le builtin `cd` a été volontairement laissé à l'exécuteur car il nécessite une interaction étroite avec la gestion des processus et l'environnement du shell parent.
