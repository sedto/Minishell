#include "minishell.h"

static int	handle_redirections(t_cmd *cmd)
{
	int	fd;

	if (cmd->input_file) // fichier en entrée ?
	{
		fd = open(cmd->input_file, O_RDONLY); // en lecture seule
		if (fd < 0 || dup2(fd, STDIN_FILENO) == -1) // dup2 remplace stdin par fd
			return (perror("Error open input"), fd > 0 && close(fd), 1);
		close(fd);
	}
	if (cmd->output_file) // fichier en sortie ?
	{
		if (cmd->append)
			fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_APPEND, 0644);
		else
			fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
		if (fd < 0 || dup2(fd, STDOUT_FILENO) == -1) // dup2 remplace stdout par fd
			return (perror("Error open output"), fd > 0 && close(fd), 1);
		close(fd);
	}
	return (0);
}
// Plus tard avec excve, on lira directement dans le fichier.txt et on ecrira dans sortie.txt

// SAVOIR SI CEST UN BUILTIN OU PAS
int is_builtin(t_cmd *cmd) //executer par nous et pas par execve
{
    if (!cmd->args || !cmd->args[0])//contient le nom de la commande
        return 0;

    return (
        	strcmp(cmd->args[0], "echo") == 0
		|| strcmp(cmd->args[0], "cd") == 0
		|| strcmp(cmd->args[0], "pwd") == 0
		|| strcmp(cmd->args[0], "export") == 0
		|| strcmp(cmd->args[0], "unset") == 0
		|| strcmp(cmd->args[0], "env") == 0
		|| strcmp(cmd->args[0], "exit") == 0
	);
}

static void	exec_child(t_minishell **s, int *pipe_fd, int prev_fd)
{
	char	*full_path;

	if (prev_fd != -1)
		dup2(prev_fd, STDIN_FILENO);
	if ((*s)->commands->next)
	{
		close(pipe_fd[0]);
		dup2(pipe_fd[1], STDOUT_FILENO);
	}
	if (handle_redirections((*s)->commands))
		exit(1);
	if (is_builtin((*s)->commands))
    {
		execute_builtin(s);
        return ;
    }
	full_path = get_path((*s)->commands->args[0], (*s)->env);
	if (full_path)
	{
		execve(full_path, (*s)->commands->args, env_to_tab((*s)->env));
	    perror((*s)->commands->args[0]);
	}
	else
		command_not_found((*s)->commands->args[0]);
    exit(1);
}

void	execute_commands(t_minishell **s)
{
	int		pipe_fd[2];
	int		prev_fd = -1;
	pid_t	pid;

	while ((*s)->commands)
	{
		if ((*s)->commands->next && pipe(pipe_fd) == -1)
			return (perror("pipe"));
        if (is_builtin((*s)->commands))
            exec_child(s, pipe_fd, prev_fd);
        else
        {
            pid = fork();
            if (pid == -1)
                return (perror("fork"));
            if (pid == 0)
                exec_child(s, pipe_fd, prev_fd);
            if (prev_fd != -1)
                close(prev_fd);
            if ((*s)->commands->next)
            {
                close(pipe_fd[1]);
                prev_fd = pipe_fd[0];
            }
            waitpid(pid, NULL, 0);
        }
		(*s)->commands = (*s)->commands->next;
	}
}
