# 🎯 PLAN DE TRAVAIL EXÉCUTEUR MINISHELL

**Roadmap complète pour l'implémentation de l'exécuteur**

---

## 📋 ÉTAT ACTUEL

### ✅ PARSER (100% TERMINÉ)
- ✅ Lexer robuste (tokenisation)
- ✅ Parser complet (validation syntaxique)
- ✅ Expander fonctionnel (variables, quotes)
- ✅ Gestion d'erreurs complète
- ✅ 0 memory leaks
- ✅ 0 segfaults
- ✅ Conforme norme 42

### 🔄 EXÉCUTEUR (À IMPLÉMENTER)
Interface claire disponible, structures `t_cmd` prêtes

---

## 🚀 PLAN D'IMPLÉMENTATION

### **PHASE 1: FONDATIONS** (Priorité: CRITIQUE)

#### 1.1 Structure de base
```bash
# Créer les fichiers
mkdir -p executor/builtins
touch executor/execute_commands.c
touch executor/execute_simple.c
touch executor/utils.c
```

#### 1.2 Fonction principale
```c
// Dans execute_commands.c
int execute_commands(t_cmd *commands)
{
    if (!commands)
        return (1);
    
    // Pour l'instant: juste afficher ce qui serait exécuté
    print_command_debug(commands);
    return (0);
}
```

#### 1.3 Intégration avec main
```c
// Dans main.c, remplacer la ligne qui affiche le parsing
// par l'appel à l'exécuteur:
if (commands)
{
    execute_commands(commands);  // Au lieu de print_commands_debug
    free_commands(commands);
}
```

**🎯 Résultat Phase 1**: Minishell qui parse et "simule" l'exécution

---

### **PHASE 2: BUILTINS ESSENTIELS** (Priorité: HAUTE)

#### 2.1 echo (le plus simple)
```c
// executor/builtins/builtin_echo.c
int builtin_echo(char **args)
{
    int i = 1;
    int newline = 1;
    
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

#### 2.2 pwd
```c
int builtin_pwd(char **args)
{
    (void)args;
    char *cwd = getcwd(NULL, 0);
    if (cwd)
    {
        printf("%s\n", cwd);
        free(cwd);
        return (0);
    }
    perror("pwd");
    return (1);
}
```

#### 2.3 env
```c
int builtin_env(char **args)
{
    (void)args;
    extern char **environ;
    int i = 0;
    
    while (environ[i])
        printf("%s\n", environ[i++]);
    return (0);
}
```

**🎯 Résultat Phase 2**: `echo`, `pwd`, `env` fonctionnels

---

### **PHASE 3: EXÉCUTION EXTERNE** (Priorité: HAUTE)

#### 3.1 Résolution des commandes
```c
char *resolve_command_path(char *command)
{
    // Si chemin absolu/relatif
    if (strchr(command, '/'))
        return (ft_strdup(command));
    
    // Chercher dans PATH
    char *path = getenv("PATH");
    // ... logique de recherche dans PATH
    return (NULL); // Si non trouvé
}
```

#### 3.2 Exécution avec fork/execve
```c
int execute_external_command(t_cmd *cmd)
{
    pid_t pid = fork();
    if (pid == 0)
    {
        // Processus enfant
        char *path = resolve_command_path(cmd->args[0]);
        if (!path)
            exit(127);
        execve(path, cmd->args, environ);
        exit(127);
    }
    else if (pid > 0)
    {
        // Processus parent
        int status;
        waitpid(pid, &status, 0);
        return (WEXITSTATUS(status));
    }
    return (1);
}
```

**🎯 Résultat Phase 3**: Commandes externes (`ls`, `cat`, etc.) fonctionnelles

---

### **PHASE 4: REDIRECTIONS** (Priorité: MOYENNE)

#### 4.1 Redirections simples
```c
void setup_redirections(t_cmd *cmd)
{
    if (cmd->input_file)
    {
        int fd = open(cmd->input_file, O_RDONLY);
        if (fd < 0)
        {
            perror(cmd->input_file);
            exit(1);
        }
        dup2(fd, STDIN_FILENO);
        close(fd);
    }
    
    if (cmd->output_file)
    {
        int fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd < 0)
        {
            perror(cmd->output_file);
            exit(1);
        }
        dup2(fd, STDOUT_FILENO);
        close(fd);
    }
    
    // Pareil pour append_file avec O_APPEND
    // Pareil pour heredoc_delim (plus complexe)
}
```

**🎯 Résultat Phase 4**: `<`, `>`, `>>` fonctionnels

---

### **PHASE 5: PIPES** (Priorité: MOYENNE)

#### 5.1 Pipeline simple
```c
int execute_pipe_sequence(t_cmd *commands)
{
    // Algorithme:
    // 1. Créer pipe() pour chaque commande sauf la dernière
    // 2. Fork pour chaque commande
    // 3. Dans chaque enfant: dup2 pour connecter pipes
    // 4. execve pour chaque commande
    // 5. Dans parent: attendre tous les enfants
}
```

**🎯 Résultat Phase 5**: `ls | grep txt | wc -l` fonctionnel

---

### **PHASE 6: BUILTINS AVANCÉS** (Priorité: BASSE)

#### 6.1 cd
```c
int builtin_cd(char **args)
{
    char *path = args[1] ? args[1] : getenv("HOME");
    
    if (strcmp(path, "-") == 0)
        path = getenv("OLDPWD");
    
    char *old_pwd = getcwd(NULL, 0);
    
    if (chdir(path) == -1)
    {
        perror("cd");
        free(old_pwd);
        return (1);
    }
    
    setenv("OLDPWD", old_pwd, 1);
    free(old_pwd);
    
    char *new_pwd = getcwd(NULL, 0);
    setenv("PWD", new_pwd, 1);
    free(new_pwd);
    
    return (0);
}
```

#### 6.2 export/unset
- `export`: modification des variables d'environnement
- `unset`: suppression des variables

#### 6.3 exit
```c
int builtin_exit(char **args)
{
    printf("exit\n");
    exit(args[1] ? ft_atoi(args[1]) : 0);
}
```

**🎯 Résultat Phase 6**: Tous les builtins fonctionnels

---

### **PHASE 7: SIGNAUX** (Priorité: BASSE)

#### 7.1 Configuration signaux
```c
void setup_signals(void)
{
    signal(SIGINT, handle_sigint);
    signal(SIGQUIT, SIG_IGN);
}

void handle_sigint(int sig)
{
    (void)sig;
    printf("\n");
    // Réafficher le prompt si en mode interactif
}
```

**🎯 Résultat Phase 7**: Ctrl+C et Ctrl+\ gérés

---

## 📅 PLANNING RECOMMANDÉ

### Semaine 1: Phases 1-2
- [ ] Structure de base
- [ ] Builtins: echo, pwd, env
- [ ] Tests: `echo hello`, `pwd`, `env`

### Semaine 2: Phase 3
- [ ] Exécution commandes externes
- [ ] Résolution PATH
- [ ] Tests: `ls`, `cat /etc/hosts`, `ls -la`

### Semaine 3: Phases 4-5
- [ ] Redirections de base
- [ ] Pipes simples
- [ ] Tests: `echo hello > file`, `cat < file`, `ls | head`

### Semaine 4: Phases 6-7
- [ ] Builtins avancés (cd, export, unset, exit)
- [ ] Signaux
- [ ] Tests finaux et debugging

---

## 🧪 TESTS CONTINUS

### Après chaque phase
```bash
# Compiler
make re

# Tests de base
./minishell
# Tester les nouvelles fonctionnalités

# Tests automatiques
chmod +x test_executeur.sh
./test_executeur.sh
```

### Tests memory
```bash
valgrind --leak-check=full ./minishell
# Puis tester quelques commandes
```

---

## 📚 RESSOURCES

### Documentation créée
- `GUIDE_IMPLEMENTATION_EXECUTEUR.md` - Interface et exemples
- `test_executeur.sh` - Tests automatiques
- `MISSION_ACCOMPLIE.md` - État du parser

### Fonctions utiles disponibles
- `parse_input()` - Parser principal
- `free_commands()` - Libération mémoire
- Toutes les fonctions libft

---

## 🎯 OBJECTIF FINAL

**Minishell fonctionnel avec:**
- ✅ Parsing robuste (TERMINÉ)
- 🔄 Exécution complète (À FAIRE)
- ✅ 7 builtins obligatoires
- ✅ Pipes et redirections
- ✅ Variables d'environnement
- ✅ Gestion signaux
- ✅ 0 memory leaks
- ✅ Conforme norme 42

**🚀 Avec cette roadmap, l'implémentation devrait être fluide et méthodique !**

---

*Documentation mise à jour le 20 Juin 2025*  
*Parser validé et prêt pour l'exécuteur*
