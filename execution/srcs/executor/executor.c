void handle_redirections(t_cmd *cmd)
{
    int fd;

    if (cmd->input_file) // fichier en entre ?
    {
        fd = open(cmd->input_file, O_RDONLY);// en lecture seule 
        if (fd < 0)
        {
            perror("Erreur open input");
            exit(1);
        }
        //le stdin qui normalement lit le clavier, on le redirige vers le fichier
        dup2(fd, 0); //ou STdIN_FILENO mais je trouve que cets plus clair 0 
        close(fd);
    }

    if (cmd->output_file) // fichier en sortie ?
    {
        if (cmd->append)
            fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_APPEND, 0644);// 
        else
            fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        
        if (fd < 0)
        {
            perror("Erreur open output");
            exit(1);
        }
        dup2(fd, 0); // envois dans ce fichier tout ce que tu veux afficher dans le terminal
        close(fd);
    }
}
//Plus tard avec excve, on lira directement dans le fichier.txt et on ecrira dans sortie.txt


//SAVOIR SI CEST UN BUILTIN OU PAS
int is_builtin(t_cmd *cmd) //executer par nous et pas par execve
{
    if (!cmd->args || !cmd->args[0])//contient le nom de la commande
        return 0;

    return (
        strcmp(cmd->args[0], "cd") == 0 ||
        strcmp(cmd->args[0], "exit") == 0
        //EXEMPLE MAIS IöL FAUT LE FAIRE POUR TOUTES LES COMMANDES BUILTIN
    );
}
int execute_builtin(t_cmd *cmd) //plan de fonction pour les commandes builtin
{
    if (strcmp(cmd->args[0], "cd") == 0)//est ce que c egale a cd ? 
    {
        // changer de dossier
    }
    else if (strcmp(cmd->args[0], "exit") == 0)
    {
        exit(0); // quitter le shell
    }
    return -1; 
    //si c'ets pas un builtin
}
//CREATION FORK 
void execute_commands(t_cmd *cmds)
{ 
    while (cmds) 
{
    pid_t pid = fork(); // child process

    if (pid == 0) // seulement child exectura
    {
        handle_redirections(cmds); // redirection 

        if (is_builtin(cmds))
            exit(execute_builtin(cmds));
        else
        {
            execve(cmds->args[0], cmds->args, environ); // environ variable d'environnement comme PATH,HOME
            perror("execve"); // si ça échoue
            exit(1);
        }
    }
    else if (pid > 0) 
        waitpid(pid, NULL, 0); //waitpid attend que le process child arrete
    }
    else
    {
        perror("fork"); // fork a échoué
    }

    cmds = cmds->next; 
}
