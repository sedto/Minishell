/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executors_redirections.c                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:22:50 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:23:45 by dibsejra         ###   ########.fr       */
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

int	handle_heredoc_execution(t_file *file)
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

int	handle_redir_in(t_file *f)
{
	int	fd;

	fd = open(f->name, O_RDONLY);
	if (fd < 0 || dup2(fd, STDIN_FILENO) == -1)
		return (perror("Error open input"), fd > 0 && close(fd), 1);
	close(fd);
	return (0);
}

int	handle_redir_out(t_file *f)
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

int	handle_redirections(t_cmd *cmd)
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
