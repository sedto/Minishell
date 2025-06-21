# Guide pour l'Implémentation de l'Exécuteur

## État Actuel du Projet

### ✅ Partie Parser (100% Terminée)
- **Lexer** : Tokenisation complète et robuste
- **Parser** : Analyse syntaxique, création des commandes
- **Expander** : Expansion des variables, quotes, etc.
- **Builtins** : Tous implémentés sauf `cd` (echo, pwd, env, export, unset, exit)
- **Infrastructure** : Environnement, signaux, utilitaires
- **Tests** : 121/121 tests réussis, 0 memory leaks, 0 segfaults

### 🔄 Partie Exécuteur (À Implémenter)
Voici ce qui reste à faire pour compléter minishell.

## 1. Architecture de l'Exécuteur

### Fichiers à créer
```
executor/
├── includes/
│   └── executor.h          # Headers spécifiques à l'exécuteur
├── srcs/
│   ├── executor.c          # Fonction principale d'exécution
│   ├── pipeline.c          # Gestion des pipes
│   ├── redirections.c      # Gestion des redirections
│   ├── processes.c         # fork/execve/wait
│   └── builtin_cd.c        # Implémentation du builtin cd
└── Makefile               # Compilation de l'exécuteur
```

### Interface principale
```c
int execute_command(t_cmd *commands, t_env **env);
```

## 2. Fonction Principale d'Exécution

### executor.c
```c
#include "../parsing/includes/minishell.h"
#include "includes/executor.h"

int execute_command(t_cmd *commands, t_env **env)
{
    int status = 0;
    
    if (!commands)
        return (0);
    
    // Commande unique
    if (!commands->next)
    {
        // Builtin dans le processus parent
        if (is_builtin(commands->args[0]))
            return (execute_builtin(commands->args, env));
        
        // Commande externe
        return (execute_single_command(commands, *env));
    }
    
    // Pipeline
    return (execute_pipeline(commands, *env));
}
```

## 3. Exécution de Commandes Simples

### processes.c
```c
int execute_single_command(t_cmd *cmd, t_env *env)
{
    pid_t pid;
    int status;
    char *executable;
    char **envp;
    
    // Chercher l'exécutable
    executable = find_executable(cmd->args[0], env);
    if (!executable)
    {
        command_not_found(cmd->args[0]);
        return (127);
    }
    
    // Fork
    pid = fork();
    if (pid == 0)
    {
        // Processus enfant
        reset_signals();                    // Restaurer signaux
        handle_redirections(cmd);           // Gérer redirections
        
        envp = env_to_array(env);
        execve(executable, cmd->args, envp);
        
        // Si on arrive ici, execve a échoué
        perror("execve");
        free_array(envp);
        exit(126);
    }
    else if (pid > 0)
    {
        // Processus parent
        waitpid(pid, &status, 0);
        free(executable);
        return (WEXITSTATUS(status));
    }
    else
    {
        perror("fork");
        free(executable);
        return (1);
    }
}
```

## 4. Gestion des Pipes

### pipeline.c
```c
int execute_pipeline(t_cmd *commands, t_env *env)
{
    int num_cmds = count_commands(commands);
    int pipefd[2 * (num_cmds - 1)];
    pid_t pids[num_cmds];
    int i = 0;
    t_cmd *current = commands;
    
    // Créer tous les pipes
    for (int j = 0; j < num_cmds - 1; j++)
    {
        if (pipe(pipefd + j * 2) == -1)
        {
            perror("pipe");
            return (1);
        }
    }
    
    // Lancer chaque commande
    while (current)
    {
        pids[i] = fork();
        if (pids[i] == 0)
        {
            // Processus enfant
            reset_signals();
            
            // Redirection des pipes
            setup_pipe_redirections(i, num_cmds, pipefd);
            
            // Fermer tous les pipes dans l'enfant
            close_all_pipes(pipefd, num_cmds - 1);
            
            // Gérer les redirections de fichiers
            handle_redirections(current);
            
            // Exécuter la commande
            if (is_builtin(current->args[0]))
            {
                // Note: builtins dans les pipes s'exécutent dans l'enfant
                exit(execute_builtin(current->args, &env));
            }
            else
            {
                char *executable = find_executable(current->args[0], env);
                if (!executable)
                {
                    command_not_found(current->args[0]);
                    exit(127);
                }
                
                char **envp = env_to_array(env);
                execve(executable, current->args, envp);
                perror("execve");
                exit(126);
            }
        }
        
        current = current->next;
        i++;
    }
    
    // Fermer tous les pipes dans le parent
    close_all_pipes(pipefd, num_cmds - 1);
    
    // Attendre tous les processus
    int last_status = 0;
    for (int j = 0; j < num_cmds; j++)
    {
        int status;
        waitpid(pids[j], &status, 0);
        if (j == num_cmds - 1)  // Statut de la dernière commande
            last_status = WEXITSTATUS(status);
    }
    
    return (last_status);
}

void setup_pipe_redirections(int cmd_index, int num_cmds, int *pipefd)
{
    // Redirection de stdin (sauf première commande)
    if (cmd_index > 0)
    {
        dup2(pipefd[(cmd_index - 1) * 2], STDIN_FILENO);
    }
    
    // Redirection de stdout (sauf dernière commande)
    if (cmd_index < num_cmds - 1)
    {
        dup2(pipefd[cmd_index * 2 + 1], STDOUT_FILENO);
    }
}

void close_all_pipes(int *pipefd, int num_pipes)
{
    for (int i = 0; i < num_pipes * 2; i++)
    {
        close(pipefd[i]);
    }
}
```

## 5. Gestion des Redirections

### redirections.c
```c
int handle_redirections(t_cmd *cmd)
{
    t_redir *redir = cmd->redirections;
    
    while (redir)
    {
        if (redir->type == REDIR_IN)
        {
            int fd = open(redir->file, O_RDONLY);
            if (fd == -1)
            {
                perror(redir->file);
                exit(1);
            }
            dup2(fd, STDIN_FILENO);
            close(fd);
        }
        else if (redir->type == REDIR_OUT)
        {
            int fd = open(redir->file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (fd == -1)
            {
                perror(redir->file);
                exit(1);
            }
            dup2(fd, STDOUT_FILENO);
            close(fd);
        }
        else if (redir->type == REDIR_APPEND)
        {
            int fd = open(redir->file, O_WRONLY | O_CREAT | O_APPEND, 0644);
            if (fd == -1)
            {
                perror(redir->file);
                exit(1);
            }
            dup2(fd, STDOUT_FILENO);
            close(fd);
        }
        else if (redir->type == REDIR_HEREDOC)
        {
            // Implementer heredoc avec pipe temporaire
            handle_heredoc(redir->delimiter);
        }
        
        redir = redir->next;
    }
    return (0);
}

void handle_heredoc(char *delimiter)
{
    int pipefd[2];
    char *line;
    
    if (pipe(pipefd) == -1)
    {
        perror("pipe");
        exit(1);
    }
    
    // Lire les lignes jusqu'au délimiteur
    while ((line = readline("> ")))
    {
        if (ft_strncmp(line, delimiter, ft_strlen(delimiter)) == 0 
            && ft_strlen(line) == ft_strlen(delimiter))
        {
            free(line);
            break;
        }
        
        write(pipefd[1], line, ft_strlen(line));
        write(pipefd[1], "\n", 1);
        free(line);
    }
    
    close(pipefd[1]);
    dup2(pipefd[0], STDIN_FILENO);
    close(pipefd[0]);
}
```

## 6. Implémentation du Builtin CD

### builtin_cd.c
```c
#include "../parsing/includes/minishell.h"

int builtin_cd(char **args, t_env **env)
{
    char *path;
    char *old_pwd;
    char *new_pwd;
    
    // Déterminer le chemin de destination
    if (!args[1])
    {
        path = get_env_value(*env, "HOME");
        if (!path)
        {
            printf("cd: HOME not set\n");
            return (1);
        }
    }
    else if (ft_strncmp(args[1], "-", 1) == 0 && ft_strlen(args[1]) == 1)
    {
        path = get_env_value(*env, "OLDPWD");
        if (!path)
        {
            printf("cd: OLDPWD not set\n");
            return (1);
        }
        printf("%s\n", path);  // Afficher le répertoire
    }
    else
    {
        path = args[1];
    }
    
    // Sauvegarder PWD actuel
    old_pwd = get_env_value(*env, "PWD");
    if (!old_pwd)
        old_pwd = getcwd(NULL, 0);
    
    // Changer de répertoire
    if (chdir(path) != 0)
    {
        perror("cd");
        return (1);
    }
    
    // Mettre à jour PWD et OLDPWD
    new_pwd = getcwd(NULL, 0);
    if (!new_pwd)
    {
        perror("getcwd");
        return (1);
    }
    
    set_env_value(env, "OLDPWD", old_pwd);
    set_env_value(env, "PWD", new_pwd);
    
    free(new_pwd);
    return (0);
}
```

### Mise à jour de builtins.c
```c
// Ajouter dans is_builtin() - déjà présent
// Ajouter dans execute_builtin() :
if (ft_strncmp(args[0], "cd", 2) == 0)
    return (builtin_cd(args, env));
```

## 7. Intégration dans le Main

### Mise à jour de main.c
```c
#include "executor/includes/executor.h"

int main(int argc, char **argv, char **envp)
{
    t_env *env;
    char *input;
    t_cmd *commands;
    int status = 0;
    
    // Initialisation
    env = init_env(envp);
    setup_signals();
    
    while (1)
    {
        input = readline("minishell$ ");
        if (!input)
        {
            printf("exit\n");
            break;
        }
        
        if (*input)
            add_history(input);
        
        // Parser (déjà implémenté)
        commands = parse_input(input, env);
        
        if (commands)
        {
            // NOUVEAU : Exécuter les commandes
            status = execute_command(commands, &env);
            free_commands(commands);
        }
        
        free(input);
    }
    
    free_env(env);
    return (status);
}
```

## 8. Gestion des Signaux pendant l'Exécution

### Améliorations dans signals.c
```c
// Variable globale pour le PID du processus en cours
volatile pid_t g_current_pid = 0;

void handle_sigint_execution(int sig)
{
    (void)sig;
    if (g_current_pid > 0)
    {
        kill(g_current_pid, SIGINT);
        printf("\n");
    }
}

void setup_execution_signals(void)
{
    signal(SIGINT, handle_sigint_execution);
    signal(SIGQUIT, SIG_DFL);  // Activer Ctrl+\ pendant l'exécution
}
```

## 9. Tests et Validation

### Tests spécifiques à l'exécuteur
```bash
# Test commandes simples
ls -la
cat /etc/passwd

# Test pipes
ls -la | grep minishell
cat /etc/passwd | head -5 | tail -3

# Test redirections
echo "test" > file.txt
cat < file.txt
echo "append" >> file.txt

# Test heredoc
cat << EOF
line1
line2
EOF

# Test builtins
cd /tmp
pwd
cd -
cd $HOME

# Test signaux
sleep 10  # Ctrl+C pour interrompre
```

### Makefile complet
```makefile
NAME = minishell
CC = gcc
CFLAGS = -Wall -Wextra -Werror -g

# Sources parser (existantes)
PARSER_SRCS = parsing/srcs/utils/main.c \
              parsing/srcs/lexer/*.c \
              parsing/srcs/parser/*.c \
              parsing/srcs/expander/*.c \
              # ... toutes les sources existantes

# Sources exécuteur (nouvelles)
EXECUTOR_SRCS = executor/srcs/executor.c \
                executor/srcs/pipeline.c \
                executor/srcs/redirections.c \
                executor/srcs/processes.c \
                executor/srcs/builtin_cd.c

# Sources système (existantes)
SYSTEM_SRCS = builtins.c env_utils.c utils.c signals.c

SRCS = $(PARSER_SRCS) $(EXECUTOR_SRCS) $(SYSTEM_SRCS)
OBJS = $(SRCS:.c=.o)

LIBFT = libft/libft.a
LIBS = -lreadline

all: $(NAME)

$(NAME): $(OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(OBJS) $(LIBFT) $(LIBS) -o $(NAME)

$(LIBFT):
	make -C libft

clean:
	rm -f $(OBJS)
	make -C libft clean

fclean: clean
	rm -f $(NAME)
	make -C libft fclean

re: fclean all

.PHONY: all clean fclean re
```

## 10. Checklist pour l'Implémentation

### Phase 1 : Commandes simples
- [ ] Créer la structure de l'exécuteur
- [ ] Implémenter `execute_single_command()`
- [ ] Tester avec des commandes externes (`ls`, `cat`, etc.)
- [ ] Tester avec les builtins existants

### Phase 2 : Builtin CD
- [ ] Implémenter `builtin_cd()`
- [ ] Gérer HOME, OLDPWD, PWD
- [ ] Tester `cd`, `cd -`, `cd $HOME`

### Phase 3 : Redirections
- [ ] Implémenter les redirections basiques (`<`, `>`, `>>`)
- [ ] Implémenter heredoc (`<<`)
- [ ] Tester toutes les combinaisons

### Phase 4 : Pipes
- [ ] Implémenter `execute_pipeline()`
- [ ] Gérer les pipes multiples
- [ ] Tester avec builtins et commandes externes

### Phase 5 : Signaux
- [ ] Améliorer la gestion des signaux
- [ ] Tester Ctrl+C pendant l'exécution
- [ ] Tester Ctrl+\\ avec core dumps

### Phase 6 : Tests exhaustifs
- [ ] Valgrind sur toutes les fonctionnalités
- [ ] Tests de robustesse (fichiers inexistants, permissions, etc.)
- [ ] Tests de performance

## Conseils d'Implémentation

1. **Commencer simple** : Implémentez d'abord les commandes simples
2. **Tester au fur et à mesure** : Chaque fonctionnalité doit être testée isolément
3. **Réutiliser l'existant** : Toutes les fonctions utilitaires sont prêtes
4. **Gérer les erreurs** : Chaque appel système doit être vérifié
5. **Memory leaks** : Tester avec Valgrind à chaque étape

## Interface avec le Parser

Le parser vous fournit déjà :
- **Structure `t_cmd`** : Commandes parsées et prêtes
- **Variables expandées** : Déjà traitées par l'expander
- **Quotes enlevées** : Prêtes pour l'exécution
- **Environnement** : Structure `t_env` complète

Vous n'avez qu'à exécuter !

## Conclusion

L'architecture est prête, les fondations sont solides. Il ne reste "que" l'implémentation de l'exécuteur selon ce plan. Toutes les fonctions utilitaires et l'infrastructure système sont déjà testées et robustes.

Bon courage pour cette dernière étape !
