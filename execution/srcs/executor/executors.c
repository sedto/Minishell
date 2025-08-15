/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executors.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 20:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/15 15:36:22 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

void	exec_in_child(t_minishell **s, t_cmd *cmd, int *pipe_fd, int prev_fd)
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

void	wait_all_children(t_minishell **s, int prev_fd, int last_pid)
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

void	run_builtin(t_minishell **s)
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

void	run_in_fork(t_minishell **s, int *pipe_fd, int *prev_fd, int *last)
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
