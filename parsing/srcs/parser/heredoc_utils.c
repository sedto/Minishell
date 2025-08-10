/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_utils.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/10 10:52:38 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

char	*process_heredoc_expansion(char *line, t_minishell *s)
{
	char	**env_tab;
	char	*expanded_line;

	env_tab = env_to_tab(s->env);
	expanded_line = expand_string(line, env_tab, s->exit_status);
	free_env_tab(env_tab);
	if (!expanded_line)
		expanded_line = ft_strdup(line);
	free(line);
	return (expanded_line);
}

int	check_heredoc_delimiter(char *line, char *delimiter, int delim_len)
{
	if (ft_strncmp(line, delimiter, (size_t)delim_len) == 0
		&& ft_strlen(line) == (size_t)delim_len)
		return (1);
	return (0);
}

char	*process_heredoc_line(char *line, t_minishell *s, int expand)
{
	char	*with_newline;

	if (expand)
		line = process_heredoc_expansion(line, s);
	with_newline = ft_strjoin(line, "\n");
	if (line)
		free(line);
	return (with_newline);
}

char	*append_line_to_content(char *content, char *with_newline)
{
	char	*temp;

	temp = ft_strjoin(content, with_newline);
	free(content);
	free(with_newline);
	return (temp);
}

int	handle_heredoc_readline(char **line, char *delimiter,
		char **content, int *should_exit)
{
	*line = readline("> ");
	if (!(*line))
	{
		printf("minishell: warning: here-document delimited by "
			"end-of-file (wanted '%s')\n", delimiter);
		return (0);
	}
	if (g_signal == SIGINT)
	{
		free(*line);
		free(*content);
		*should_exit = 1;
		return (-1);
	}
	return (1);
}
