/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_helpers.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/24 15:56:40 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	is_delimiter_match(char *line, char *delimiter, int delim_len)
{
	return (ft_strncmp(line, delimiter, (size_t)delim_len) == 0
		&& ft_strlen(line) == (size_t)delim_len);
}

char	*process_line_expansion(char *line, t_minishell *s, int expand)
{
	char	**envp;
	char	*expanded_line;
	char	*temp_line;

	if (!expand)
		return (line);
	temp_line = prepare_heredoc_line(line);
	if (!temp_line)
		return (line);
	envp = env_to_tab(s->env);
	expanded_line = expand_string(temp_line, envp, s->exit_status);
	if (expanded_line)
		restore_heredoc_quotes(line, expanded_line);
	free_env_tab(envp);
	free(temp_line);
	free(line);
	return (expanded_line);
}

char	*append_line_to_content(char *content, char *line)
{
	char	*with_newline;
	char	*new_content;

	with_newline = ft_strjoin(line, "\n");
	if (!with_newline)
	{
		free(content);
		return (NULL);
	}
	new_content = ft_strjoin(content, with_newline);
	free(content);
	free(with_newline);
	return (new_content);
}

int	handle_heredoc_signal_exit(int *should_exit, char *line, char *content)
{
	if (g_signal == SIGINT)
	{
		free(line);
		free(content);
		*should_exit = 1;
		return (1);
	}
	return (0);
}
