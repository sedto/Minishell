/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executors_helpers.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/19 09:50:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/19 10:52:48 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static void	setup_pipes_and_redirections(t_cmd *cmd, int *pipe_fd, int prev_fd,
		t_minishell **s)
{
	if (prev_fd != -1)
		dup2(prev_fd, STDIN_FILENO);
	if (cmd->next)
	{
		close(pipe_fd[0]);
		dup2(pipe_fd[1], STDOUT_FILENO);
	}
	if (handle_redirections(cmd, s))
		shell_exit(1, *s);
}

static void	execute_external_command(t_minishell **s, t_cmd *cmd)
{
	char	*full_path;

	full_path = get_path(cmd->args[0], (*s)->env);
	if (full_path)
	{
		path_stat(full_path, s);
		execve(full_path, cmd->args, env_to_tab((*s)->env));
		perror(cmd->args[0]);
	}
	else
		command_not_found(cmd->args[0]);
	shell_exit(127, *s);
}

void	exec_in_child(t_minishell **s, t_cmd *cmd, int *pipe_fd, int prev_fd)
{
	reset_signals();
	setup_pipes_and_redirections(cmd, pipe_fd, prev_fd, s);
	if (!cmd->args || !cmd->args[0])
		shell_exit(0, *s);
	if (is_builtin(cmd))
	{
		execute_builtin(s);
		shell_exit((*s)->exit_status, *s);
	}
	execute_external_command(s, cmd);
}
