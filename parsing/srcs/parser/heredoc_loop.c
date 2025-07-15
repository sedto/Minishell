/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_loop.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static int	process_heredoc_input(char **line, char *delimiter, int delim_len)
{
	if (check_heredoc_delimiter(*line, delimiter, delim_len))
	{
		free(*line);
		return (1);
	}
	return (0);
}

static int	expand_and_append(char **line, char **content,
		t_minishell *s, int expand)
{
	char	*with_newline;

	with_newline = process_heredoc_line(*line, s, expand);
	if (!with_newline)
	{
		free(*content);
		*content = NULL;
		return (-1);
	}
	*content = append_line_to_content(*content, with_newline);
	if (!(*content))
		return (-1);
	return (0);
}

char	*read_heredoc_loop(char *delimiter, int *should_exit,
		t_minishell *s, int expand)
{
	char	*line;
	char	*content;
	int		delim_len;
	int		result;

	delim_len = ft_strlen(delimiter);
	content = ft_strdup("");
	if (!content)
		return (NULL);
	while (1)
	{
		result = handle_heredoc_readline(&line, delimiter,
				&content, should_exit);
		if (result == -1)
			return (NULL);
		if (result == 0)
			return (content);
		if (process_heredoc_input(&line, delimiter, delim_len))
			break ;
		if (expand_and_append(&line, &content, s, expand) == -1)
			return (NULL);
	}
	return (content);
}

char	*read_heredoc_content(char *delimiter, int *should_exit,
		t_minishell *s, int expand)
{
	if (!delimiter)
		return (NULL);
	*should_exit = 0;
	return (read_heredoc_loop(delimiter, should_exit, s, expand));
}
