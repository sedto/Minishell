/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_handlers.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

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

void	add_heredoc_to_files(t_cmd *current_cmd, t_file *node)
{
	t_file	*tmp;

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

int	process_heredoc_token(char *delimiter, char **content,
		int *should_exit, t_minishell *s)
{
	int		expand;
	char	*clean_delimiter;

	expand = (ft_strchr(delimiter, '\'') == NULL
			&& ft_strchr(delimiter, '"') == NULL);
	clean_delimiter = remove_quotes(delimiter);
	*content = read_heredoc_content(clean_delimiter, should_exit, s, expand);
	if (*should_exit || !(*content))
	{
		free(clean_delimiter);
		return (0);
	}
	free(clean_delimiter);
	return (1);
}

void	handle_heredoc(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx, t_minishell *s)
{
	char	*delimiter;
	char	*content;
	t_file	*node;
	int		should_exit;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		delimiter = (*token)->value;
		if (!process_heredoc_token(delimiter, &content, &should_exit, s))
		{
			ctx->syntax_error = 1;
			return ;
		}
		node = create_heredoc_file(delimiter, content);
		free(delimiter);
		if (!node)
		{
			free(content);
			return ;
		}
		add_heredoc_to_files(current_cmd, node);
	}
}
