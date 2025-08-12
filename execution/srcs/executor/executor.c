/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_buffer.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 20:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:06:45 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static void	heredoc_in_child(int *pipe_fd, t_file *file)
{
	close(pipe_fd[0]);
	if (file->heredoc_content)
	{
		write(pipe_fd[1], file->heredoc_content,
			ft_strlen(file->heredoc_content));
	}
	close(pipe_fd[1]);
	exit(0);
}

static int	handle_heredoc_execution(t_file *file)
{
	int		pipe_fd[2];
	pid_t	pid;
	int		status;

	if (!file || !file->heredoc_content)
		return (-1);
	if (pipe(pipe_fd) == -1)
	{
		perror("pipe");
		return (-1);
	}
	pid = fork();
	if (pid == -1)
	{
		perror("fork");
		close(pipe_fd[0]);
		close(pipe_fd[1]);
		return (-1);
	}
	if (pid == 0)
		heredoc_in_child(pipe_fd, file);
	close(pipe_fd[1]);
	waitpid(pid, &status, 0);
	return (pipe_fd[0]);
}

static int	handle_redir_in(t_file *f)
{
	int	fd;

	fd = open(f->name, O_RDONLY);
	if (fd < 0 || dup2(fd, STDIN_FILENO) == -1)
		return (perror("Error open input"), fd > 0 && close(fd), 1);
	close(fd);
	return (0);
}

static int	handle_redir_out(t_file *f)
{
	int	fd;

	fd = 0;
	if (f->type == APPEND)
		fd = open(f->name, O_WRONLY | O_CREAT | O_APPEND, 0644);
	else if (f->type == OUTPUT)
		fd = open(f->name, O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (fd < 0 || dup2(fd, STDOUT_FILENO) == -1)
		return (perror("Error open output"), fd > 0 && close(fd), 1);
	close(fd);
	return (0);
}

static int	handle_redirections(t_cmd *cmd)
{
	int		fd;
	t_file	*tmp;
	int		ret;

	ret = 0;
	tmp = cmd->files;
	while (tmp)
	{
		if (tmp->type == INPUT)
			ret = handle_redir_in(tmp);
		else if (tmp->type == HEREDOC)
		{
			fd = handle_heredoc_execution(tmp);
			if (fd < 0 || dup2(fd, STDIN_FILENO) == -1)
				return (perror("Error heredoc"), fd > 0 && close(fd), 1);
			close(fd);
		}
		else
			ret = handle_redir_out(tmp);
		if (ret != 0)
			return (ret);
		tmp = tmp->next;
	}
	return (0);
}

int	is_builtin(t_cmd *cmd)
{
	if (!cmd->args || !cmd->args[0])
		return (0);
	return (strcmp(cmd->args[0], "echo") == 0 || strcmp(cmd->args[0], "cd") == 0
		|| strcmp(cmd->args[0], "pwd") == 0 || strcmp(cmd->args[0],
			"export") == 0 || strcmp(cmd->args[0], "unset") == 0
		|| strcmp(cmd->args[0], "env") == 0 || strcmp(cmd->args[0],
			"exit") == 0);
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

int	has_access(const char *path, int mode)
{
	if (access(path, F_OK) != 0)
		exit(127);
	if (access(path, mode) != 0)
	{
		perror(path);
		exit(126);
	}
	return (0);
}

static void	path_stat(char *path)
{
	struct stat	*buf;

	buf = malloc(sizeof(struct stat));
	if (stat(path, buf) < 0)
	{
		perror(path);
		free(buf);
		exit(127);
	}
	if (S_ISDIR(buf->st_mode))
	{
		write(STDERR_FILENO, path, ft_strlen(path));
		write(STDERR_FILENO, ": Is a directory\n", 17);
		free(buf);
		exit(126);
	}
	free(buf);
	has_access(path, X_OK);
}

static void	exec_in_child(t_minishell **s, t_cmd *cmd, int *pipe_fd,
		int prev_fd)
{
	char	*full_path;

	if (prev_fd != -1)
		dup2(prev_fd, STDIN_FILENO);
	if (cmd->next)
	{
		close(pipe_fd[0]);
		dup2(pipe_fd[1], STDOUT_FILENO);
	}
	if (handle_redirections(cmd))
		exit(1);
	if (is_builtin(cmd))
		execute_builtin(s);
	if (is_builtin(cmd))
		exit((*s)->exit_status);
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

static void	wait_all_children(t_minishell **s, int prev_fd, int last_pid)
{
	int		stat;

	if (prev_fd != -1)
		close(prev_fd);
	if (last_pid != -1)
	{
		waitpid(last_pid, &stat, 0);
		(*s)->exit_status = WEXITSTATUS(stat);
		while (wait(NULL) > 0 && g_signal != SIGINT)
			;
	}
	else
	{
		while (wait(&stat) > 0 && g_signal != SIGINT)
			(*s)->exit_status = WEXITSTATUS(stat);
	}
	if (g_signal == SIGINT)
	{
		(*s)->exit_status = 130;
		while (wait(NULL) > 0)
			;
	}
}

static void	run_builtin(t_minishell **s)
{
	int		original_stdin;
	int		original_stdout;

	original_stdin = dup(STDIN_FILENO);
	original_stdout = dup(STDOUT_FILENO);
	if (handle_redirections((*s)->commands))
		(*s)->exit_status = 1;
	else
		execute_builtin(s);
	dup2(original_stdin, STDIN_FILENO);
	dup2(original_stdout, STDOUT_FILENO);
	close(original_stdin);
	close(original_stdout);
}

static void	run_in_fork(t_minishell **s, int *pipe_fd, int *prev_fd, int *last)
{
	pid_t	pid;

	pid = fork();
	if (pid == -1)
		return (perror("fork"));
	if (pid == 0)
		exec_in_child(s, (*s)->commands, pipe_fd, *prev_fd);
	if (!(*s)->commands->next)
		*last = pid;
	if (*prev_fd != -1)
		close(*prev_fd);
	if ((*s)->commands->next)
	{
		close(pipe_fd[1]);
		*prev_fd = pipe_fd[0];
	}
}

void	execute_commands(t_minishell **s)
{
	int		prev_fd;
	int		pipe_fd[2];
	pid_t	last_pid;

	prev_fd = -1;
	last_pid = -1;
	while ((*s)->commands && g_signal != SIGINT)
	{
		if (!prepare_pipe((*s)->commands, pipe_fd))
			return ;
		if (!has_pipe_or_input((*s)->commands, prev_fd)
			&& is_builtin((*s)->commands))
			run_builtin(s);
		else
			run_in_fork(s, pipe_fd, &prev_fd, &last_pid);
		(*s)->commands = (*s)->commands->next;
	}
	wait_all_children(s, prev_fd, last_pid);
}
