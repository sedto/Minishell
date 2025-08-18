/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executors_utils.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:22:55 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:23:48 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	is_builtin(t_cmd *cmd)
{
	if (!cmd->args || !cmd->args[0])
		return (0);
	return (ft_strncmp(cmd->args[0], "echo", 5) == 0
		|| ft_strncmp(cmd->args[0], "cd", 3) == 0
		|| ft_strncmp(cmd->args[0], "pwd", 4) == 0
		|| ft_strncmp(cmd->args[0], "export", 7) == 0
		|| ft_strncmp(cmd->args[0], "unset", 6) == 0
		|| ft_strncmp(cmd->args[0], "env", 4) == 0
		|| ft_strncmp(cmd->args[0], "exit", 5) == 0);
}

int	prepare_pipe(t_cmd *cmd, int *pipe_fd)
{
	if (cmd->next && pipe(pipe_fd) == -1)
	{
		perror("pipe");
		return (0);
	}
	return (1);
}

int	has_pipe_or_input(t_cmd *cmd, int prev_fd)
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

void	path_stat(char *path)
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
