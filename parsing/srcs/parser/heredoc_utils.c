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

static char	*init_heredoc_content(char *delimiter, int *should_exit)
{
	char	*content;

	if (!delimiter)
		return (NULL);
	*should_exit = 0;
	content = ft_strdup("");
	return (content);
}

char	*read_heredoc_content(char *delimiter, int *should_exit,
		t_minishell *s, int expand)
{
	char	*line;
	char	*content;
	int		delim_len;

	content = init_heredoc_content(delimiter, should_exit);
	if (!content)
		return (NULL);
	delim_len = ft_strlen(delimiter);
	while (1)
	{
		line = read_single_heredoc_line(delimiter, should_exit, &content, s);
		if (!line || *should_exit)
			break ;
		if (is_delimiter_match(line, delimiter, delim_len))
		{
			free(line);
			break ;
		}
		if (!process_heredoc_line_content(&content, line, s, expand))
			return (NULL);
	}
	return (content);
}

t_file	*create_heredoc_file(char *delimiter, char *content)
{
	t_file	*file;

	file = malloc(sizeof(t_file));
	if (!file)
		return (NULL);
	file->name = ft_strdup(delimiter);
	file->heredoc_content = content;
	file->fd = -1;
	file->type = HEREDOC;
	file->next = NULL;
	if (!file->name)
	{
		free(file->heredoc_content);
		free(file);
		return (NULL);
	}
	return (file);
}

void	handle_redirect_in(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx)
{
	char	*new_file;
	t_file	*node;
	t_file	*tmp;

	(void)ctx;
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			node = create_t_file_node(new_file);
			node->type = INPUT;
			if (current_cmd->files)
			{
				tmp = current_cmd->files;
				while (tmp->next)
					tmp = tmp->next;
				tmp->next = node;
			}
			else
				current_cmd->files = node;
		}
	}
}

void	handle_heredoc(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx, t_minishell *s)
{
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
		process_heredoc_token(current_cmd, (*token)->value, ctx, s);
}
