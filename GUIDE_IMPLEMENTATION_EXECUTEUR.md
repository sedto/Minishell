# 🚀 INTERFACE PARSER → EXÉCUTEUR

**Documentation pour l'implémentation de l'exécuteur minishell**

---

## 📋 STRUCTURES DE DONNÉES

### Structure `t_cmd` (Commande Parsée)
```c
typedef struct s_cmd
{
    char            **args;           // Arguments de la commande [cmd, arg1, arg2, ...]
    char            *input_file;      // Fichier d'entrée pour redirection <
    char            *output_file;     // Fichier de sortie pour redirection >
    char            *append_file;     // Fichier pour redirection d'ajout >>
    char            *heredoc_delim;   // Délimiteur pour heredoc <<
    int             pipe_out;         // 1 si la commande a un pipe de sortie
    struct s_cmd    *next;           // Commande suivante dans le pipeline
}   t_cmd;
```

### Structure `t_token` (Token du lexer)
```c
typedef enum e_token_type
{
    TOKEN_WORD,         // Mot simple
    TOKEN_PIPE,         // |
    TOKEN_REDIR_IN,     // <
    TOKEN_REDIR_OUT,    // >
    TOKEN_APPEND,       // >>
    TOKEN_HEREDOC,      // <<
    TOKEN_EOF           // Fin de chaîne
}   t_token_type;

typedef struct s_token
{
    t_token_type    type;
    char            *value;
    struct s_token  *next;
}   t_token;
```

---

## 🔗 API PARSER (Fonctions disponibles)

### Fonction principale
```c
t_cmd *parse_input(char *input);
```
- **Entrée**: Chaîne de caractères brute
- **Sortie**: Liste chaînée de commandes prêtes à exécuter
- **Retour**: `NULL` en cas d'erreur syntaxique

### Fonction de libération
```c
void free_commands(t_cmd *commands);
```
- **Usage**: Libère toute la mémoire allouée pour la liste de commandes
- **Important**: TOUJOURS appeler après utilisation

### Fonctions utilitaires
```c
int is_builtin(char *command);           // Vérifie si c'est un builtin
void print_error(char *message);        // Affiche erreur formatée
char *ft_getenv(char *var);             // Récupère variable d'environnement
```

---

## 🎯 EXEMPLES D'UTILISATION

### Exemple 1: Commande simple
```c
// Input: "echo hello world"
t_cmd *cmd = parse_input("echo hello world");
// cmd->args[0] = "echo"
// cmd->args[1] = "hello" 
// cmd->args[2] = "world"
// cmd->args[3] = NULL
// cmd->pipe_out = 0
// cmd->next = NULL
```

### Exemple 2: Pipeline
```c
// Input: "ls -la | grep txt | wc -l"
t_cmd *cmd = parse_input("ls -la | grep txt | wc -l");
// cmd1: args=["ls", "-la", NULL], pipe_out=1, next=cmd2
// cmd2: args=["grep", "txt", NULL], pipe_out=1, next=cmd3  
// cmd3: args=["wc", "-l", NULL], pipe_out=0, next=NULL
```

### Exemple 3: Redirections
```c
// Input: "cat < input.txt > output.txt"
t_cmd *cmd = parse_input("cat < input.txt > output.txt");
// cmd->args = ["cat", NULL]
// cmd->input_file = "input.txt"
// cmd->output_file = "output.txt"
// cmd->append_file = NULL
// cmd->heredoc_delim = NULL
```

---

## ⚡ ALGORITHME D'EXÉCUTION RECOMMANDÉ

### 1. Fonction principale
```c
int execute_commands(t_cmd *commands)
{
    if (!commands)
        return (1);
    
    if (!commands->next && !commands->pipe_out)
        return (execute_simple_command(commands));
    else
        return (execute_pipe_sequence(commands));
}
```

### 2. Exécution simple
```c
int execute_simple_command(t_cmd *cmd)
{
    // 1. Vérifier si c'est un builtin
    if (is_builtin(cmd->args[0]))
        return (execute_builtin(cmd));
    
    // 2. Fork pour exécution externe
    pid_t pid = fork();
    if (pid == 0)
    {
        // 3. Gérer redirections
        setup_redirections(cmd);
        
        // 4. Exécuter avec execve
        execve(resolve_command_path(cmd->args[0]), cmd->args, environ);
        exit(127); // Commande non trouvée
    }
    
    // 5. Attendre le processus enfant
    int status;
    waitpid(pid, &status, 0);
    return (WEXITSTATUS(status));
}
```

### 3. Pipeline
```c
int execute_pipe_sequence(t_cmd *commands)
{
    int pipe_fd[2];
    int prev_fd = 0;
    
    while (commands)
    {
        if (commands->next)
            pipe(pipe_fd);
        
        pid_t pid = fork();
        if (pid == 0)
        {
            // Enfant: configurer pipes et redirections
            if (prev_fd != 0)
            {
                dup2(prev_fd, STDIN_FILENO);
                close(prev_fd);
            }
            if (commands->next)
            {
                dup2(pipe_fd[1], STDOUT_FILENO);
                close(pipe_fd[0]);
                close(pipe_fd[1]);
            }
            
            setup_redirections(commands);
            
            if (is_builtin(commands->args[0]))
                exit(execute_builtin(commands));
            else
                execve(resolve_command_path(commands->args[0]), 
                       commands->args, environ);
        }
        
        // Parent: gérer les descripteurs
        if (prev_fd != 0)
            close(prev_fd);
        if (commands->next)
        {
            close(pipe_fd[1]);
            prev_fd = pipe_fd[0];
        }
        
        commands = commands->next;
    }
    
    // Attendre tous les processus
    while (wait(NULL) > 0);
    return (0);
}
```

---

## 🔧 BUILTINS À IMPLÉMENTER

### 1. **echo** (avec option -n)
```c
int builtin_echo(char **args)
{
    int newline = 1;
    int i = 1;
    
    if (args[1] && strcmp(args[1], "-n") == 0)
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

### 2. **cd** (avec gestion $HOME et $OLDPWD)
```c
int builtin_cd(char **args)
{
    char *path = args[1];
    char *oldpwd = getcwd(NULL, 0);
    
    if (!path || strcmp(path, "~") == 0)
        path = getenv("HOME");
    else if (strcmp(path, "-") == 0)
        path = getenv("OLDPWD");
    
    if (chdir(path) == -1)
    {
        perror("cd");
        free(oldpwd);
        return (1);
    }
    
    setenv("OLDPWD", oldpwd, 1);
    free(oldpwd);
    
    char *newpwd = getcwd(NULL, 0);
    setenv("PWD", newpwd, 1);
    free(newpwd);
    
    return (0);
}
```

### 3. **pwd**
```c
int builtin_pwd(char **args)
{
    (void)args;
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

### 4. **export** (sans valeur = affichage, avec valeur = définition)
```c
int builtin_export(char **args)
{
    if (!args[1])
    {
        // Afficher toutes les variables exportées
        extern char **environ;
        for (int i = 0; environ[i]; i++)
            printf("declare -x %s\n", environ[i]);
        return (0);
    }
    
    for (int i = 1; args[i]; i++)
    {
        char *equal = strchr(args[i], '=');
        if (equal)
        {
            *equal = '\0';
            setenv(args[i], equal + 1, 1);
        }
        else
        {
            // Variable sans valeur, juste l'exporter
            if (getenv(args[i]))
                setenv(args[i], getenv(args[i]), 1);
        }
    }
    return (0);
}
```

### 5. **unset**
```c
int builtin_unset(char **args)
{
    for (int i = 1; args[i]; i++)
        unsetenv(args[i]);
    return (0);
}
```

### 6. **env**
```c
int builtin_env(char **args)
{
    (void)args;
    extern char **environ;
    
    for (int i = 0; environ[i]; i++)
        printf("%s\n", environ[i]);
    return (0);
}
```

### 7. **exit**
```c
int builtin_exit(char **args)
{
    int exit_code = 0;
    
    if (args[1])
    {
        exit_code = ft_atoi(args[1]);
        if (!is_valid_number(args[1]))
        {
            printf("exit: %s: numeric argument required\n", args[1]);
            exit_code = 2;
        }
    }
    
    printf("exit\n");
    exit(exit_code);
}
```

---

## 🔄 GESTION DES SIGNAUX

```c
void setup_signals(void)
{
    signal(SIGINT, handle_sigint);   // Ctrl+C
    signal(SIGQUIT, SIG_IGN);        // Ctrl+\ ignoré en mode interactif
}

void handle_sigint(int sig)
{
    (void)sig;
    printf("\n");
    rl_on_new_line();
    rl_replace_line("", 0);
    rl_redisplay();
}
```

---

## 📁 STRUCTURE FICHIERS RECOMMANDÉE

```
executor/
├── execute_commands.c      // Fonction principale d'exécution
├── execute_simple.c        // Exécution commande simple
├── execute_pipes.c         // Gestion des pipelines
├── builtins/
│   ├── builtin_echo.c
│   ├── builtin_cd.c
│   ├── builtin_pwd.c
│   ├── builtin_export.c
│   ├── builtin_unset.c
│   ├── builtin_env.c
│   └── builtin_exit.c
├── redirections.c          // Gestion < > >> <<
├── signals.c              // Gestion SIGINT/SIGQUIT
└── utils.c                // Utilitaires (résolution PATH, etc.)
```

---

## ✅ CHECKLIST IMPLEMENTATION

### Phase 1: Base
- [ ] `execute_commands()` - Fonction principale
- [ ] `execute_simple_command()` - Commandes sans pipe
- [ ] `setup_redirections()` - Gestion < > >> <<
- [ ] Builtins: echo, pwd, env

### Phase 2: Pipes
- [ ] `execute_pipe_sequence()` - Pipelines complets
- [ ] Gestion des file descriptors
- [ ] Tests: `ls | grep txt | wc -l`

### Phase 3: Variables
- [ ] Builtins: export, unset
- [ ] Gestion variables d'environnement
- [ ] Builtin: cd (avec $HOME, $OLDPWD)

### Phase 4: Signaux
- [ ] SIGINT (Ctrl+C) 
- [ ] SIGQUIT (Ctrl+\)
- [ ] Builtin: exit

### Phase 5: Robustesse
- [ ] Gestion erreurs
- [ ] Tests edge cases
- [ ] Memory leaks check

---

## 🎯 OBJECTIF FINAL

Avec le parser robuste maintenant disponible, l'implémentation de l'exécuteur devrait être fluide. L'interface est claire et toutes les données nécessaires sont disponibles dans les structures `t_cmd`.

**🚀 Bonne implémentation !**
