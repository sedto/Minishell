/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_support.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/12 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	should_expand_delimiter(char *delimiter)
{
	return (ft_strchr(delimiter, '\'') == NULL
		&& ft_strchr(delimiter, '"') == NULL);
}

void	add_file_to_command(t_cmd *current_cmd, t_file *node)
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

int	handle_heredoc_error(char *delimiter, t_shell_ctx *ctx)
{
	free(delimiter);
	ctx->syntax_error = 1;
	return (0);
}

t_file	*create_and_validate_heredoc_file(char *delimiter, char *content)
{
	t_file	*node;

	node = create_heredoc_file(delimiter, content);
	if (!node)
		free(content);
	return (node);
}

void	process_heredoc_token(t_cmd *current_cmd, char *token_value,
		t_shell_ctx *ctx, t_minishell *s)
{
	char	*delimiter;
	char	*content;
	t_file	*node;
	int		should_exit;

	delimiter = remove_quotes(token_value);
	content = read_heredoc_content(delimiter, &should_exit, s,
			should_expand_delimiter(token_value));
	if (should_exit || !content)
	{
		handle_heredoc_error(delimiter, ctx);
		return ;
	}
	node = create_and_validate_heredoc_file(delimiter, content);
	free(delimiter);
	if (!node)
		return ;
	add_file_to_command(current_cmd, node);
}
