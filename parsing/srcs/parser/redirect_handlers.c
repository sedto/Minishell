/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   redirect_handlers.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static void	add_file_to_cmd(t_cmd *cmd, t_file *node)
{
	t_file	*tmp;

	if (cmd->files)
	{
		tmp = cmd->files;
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = node;
	}
	else
		cmd->files = node;
}

void	handle_redirect_out(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx)
{
	char	*new_file;
	t_file	*node;

	(void)ctx;
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			node = create_t_file_node(new_file);
			node->type = OUTPUT;
			add_file_to_cmd(current_cmd, node);
		}
	}
}

void	handle_redirect_append(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx)
{
	char	*new_file;
	t_file	*node;

	(void)ctx;
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			node = create_t_file_node(new_file);
			node->type = APPEND;
			add_file_to_cmd(current_cmd, node);
		}
	}
}
