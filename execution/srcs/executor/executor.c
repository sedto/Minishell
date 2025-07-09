#include "minishell.h"

/* NOUVELLE FONCTION: Valide toutes les redirections comme bash */
// static int	validate_all_redirections(t_cmd *cmd)
// {
// 	// int	fd;
// 	t_file	*tmp;
// 	tmp = cmd->files;
// 	while (tmp)
// 	{
// 		if (tmp->type == INPUT)
// 		{
// 		/* Vérifier que le fichier existe et est lisible */
// 			if (access(tmp->name, R_OK) < 0)
// 			{
// 				perror(tmp->name);
// 				return (1);
// 			}
// 		}
// 		else if (tmp->type == OUTPUT || tmp->type == APPEND)
// 		{
// 			/* Si le fichier existe, vérifier permission écriture */
// 			if (access(tmp->name, F_OK) == 0)
// 			{
// 				if (access(tmp->name, W_OK) < 0)
// 				{
// 					perror(tmp->name);
// 					return (1);
// 				}
// 			}
// 		}
// 		tmp = tmp->next;
// 		// else
// 		// {
// 		// 	/* Fichier n'existe pas, tester création temporaire */
// 		// 	fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_EXCL, 0644);
// 		// 	if (fd < 0)
// 		// 	{
// 		// 		perror(cmd->output_file);
// 		// 		return (1);
// 		// 	}
// 		// 	/* Supprimer immédiatement le fichier test */
// 		// 	close(fd);
// 		// 	unlink(cmd->output_file);
// 		// }
// 	}	
// 	return (0);
// }

/* MODIFIÉE: Ajouter l'appel à validate_all_redirections */
static int	handle_redirections(t_cmd *cmd)
{
	int		fd;
	t_file	*tmp;

	/* D'abord valider toutes les redirections comme bash */
	// if (validate_all_redirections(cmd))
	// 	return (1);
	tmp = cmd->files;
	while (tmp)
	{
		if (tmp->type == INPUT)
		{
			fd = open(tmp->name, O_RDONLY); // en lecture seule
			if (fd < 0 || dup2(fd, STDIN_FILENO) == -1) // dup2 remplace stdin par fd
				return (perror("Error open input"), fd > 0 && close(fd), 1);
			close(fd);
		}
		else
		{
			if (tmp->type == APPEND)
				fd = open(tmp->name, O_WRONLY | O_CREAT | O_APPEND, 0644);
			else if (tmp->type == OUTPUT)
				fd = open(tmp->name, O_WRONLY | O_CREAT | O_TRUNC, 0644);
			if (fd < 0 || dup2(fd, STDOUT_FILENO) == -1) // dup2 remplace stdout par fd
				return (perror("Error open output"), fd > 0 && close(fd), 1);
			close(fd);
		}
		tmp = tmp->next;
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

static int	prepare_pipe(t_cmd *cmd, int *pipe_fd)
{
	if (cmd->next && pipe(pipe_fd) == -1)
	{
		perror("pipe");
		return (0);
	}
	return (1);
}

static int	has_pipe_or_input(t_cmd *cmd, int prev_fd)
{
	return (cmd->next || prev_fd != -1);
}

int has_access(const char *path, int mode)
{
	if (access(path, F_OK) != 0)
		exit(127);
    if (access(path, mode) != 0)
	{
        perror(path);
        exit(126);
    }
    return 0;
}

static void	path_stat(char *path)
{
	struct stat *buf;

	buf = malloc(sizeof(struct stat));
	if (stat(path, buf) < 0)
		perror(path);
    if (S_ISDIR(buf->st_mode))
	{
        fprintf(stderr, "%s: Is a directory\n", path);
		exit(126);
	}
	free(buf);
	has_access(path, X_OK);
}


static void	exec_in_child(t_minishell **s, t_cmd *cmd,
				int *pipe_fd, int prev_fd)
{
	char	*full_path;

	if (prev_fd != -1)
	{
		dup2(prev_fd, STDIN_FILENO);
	}
	if (cmd->next)
	{
		close(pipe_fd[0]);
		dup2(pipe_fd[1], STDOUT_FILENO);
	}
	if (handle_redirections(cmd))
		exit(1);
	if (is_builtin(cmd))
	{
		execute_builtin(s);
		exit((*s)->exit_status);
	}

	full_path = get_path(cmd->args[0], (*s)->env);
	if (full_path)
	{
		path_stat(full_path);
		execve(full_path, cmd->args, env_to_tab((*s)->env));
		perror(cmd->args[0]);
	}
	else
		command_not_found(cmd->args[0]);
	exit(127);
}

static void	run_child_process(t_minishell **s, t_cmd *cmd,
				int *pipe_fd, int *prev_fd)
{
	pid_t	pid;

	pid = fork();
	if (pid == -1)
	{
		perror("fork");
		return ;
	}
	if (pid == 0)
		exec_in_child(s, cmd, pipe_fd, *prev_fd);
	if (*prev_fd != -1)
		close(*prev_fd);
	if (cmd->next)
	{
		close(pipe_fd[1]);
		*prev_fd = pipe_fd[0];
	}
	else
	{
		close(pipe_fd[0]);
		close(pipe_fd[1]);
		*prev_fd = -1;
	}
}

void	execute_commands(t_minishell **s)
{
	int		prev_fd;
	int		pipe_fd[2];
	int		stat;

	prev_fd = -1;
	while ((*s)->commands)
	{
		if (!prepare_pipe((*s)->commands, pipe_fd))
			return ;
		if (!has_pipe_or_input((*s)->commands, prev_fd) && is_builtin((*s)->commands))
		{
			if (handle_redirections((*s)->commands))
			{
				(*s)->exit_status = 1;
				dup2((*s)->saved_stdout, STDOUT_FILENO);
				dup2((*s)->saved_stdin, STDIN_FILENO);
				return ;
			}
			execute_builtin(s);
			dup2((*s)->saved_stdout, STDOUT_FILENO);
			dup2((*s)->saved_stdin, STDIN_FILENO);
		}
		else
			run_child_process(s, (*s)->commands, pipe_fd, &prev_fd);
		(*s)->commands = (*s)->commands->next;
	}
	while (wait(&stat) > 0)
		(*s)->exit_status = WEXITSTATUS(stat);
}
