/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_read.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/12 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

void	print_heredoc_warning(char *delimiter)
{
	printf("minishell: warning: here-document delimited by "
		"end-of-file (wanted '%s')\n", delimiter);
}

char	*process_heredoc_line(char *line, char *delimiter, int delim_len,
		t_minishell *s)
{
	(void)s;
	if (!line)
		return (NULL);
	if (is_delimiter_match(line, delimiter, delim_len))
	{
		free(line);
		return (NULL);
	}
	return (line);
}

char	*read_single_heredoc_line(char *delimiter, int *should_exit,
		char **content, t_minishell *s)
{
	char	*line;

	(void)s;
	if (handle_heredoc_signal_exit(should_exit, NULL, *content))
		return (NULL);
	line = readline("> ");
	if (!line)
	{
		print_heredoc_warning(delimiter);
		return (NULL);
	}
	if (handle_heredoc_signal_exit(should_exit, line, *content))
		return (NULL);
	return (line);
}

int	process_heredoc_line_content(char **content, char *line,
		t_minishell *s, int expand)
{
	line = process_line_expansion(line, s, expand);
	*content = append_line_to_content(*content, line);
	free(line);
	if (!*content)
		return (0);
	return (1);
}
