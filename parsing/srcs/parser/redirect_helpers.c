/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   redirect_helpers.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/19 12:30:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/19 12:30:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static int	check_ambiguous_redirect(t_token **token, t_shell_ctx *ctx)
{
	if (!(*token)->value || ft_strlen((*token)->value) == 0)
	{
		write(2, "minishell: ambiguous redirect\n", 31);
		ctx->syntax_error = 2;
		return (1);
	}
	return (0);
}

static void	add_file_to_cmd(t_cmd *current_cmd, t_file *node)
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

void	process_redirect_token(t_cmd *current_cmd, t_token **token,
		t_shell_ctx *ctx, t_redir type)
{
	char	*new_file;
	t_file	*node;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		if (check_ambiguous_redirect(token, ctx))
			return ;
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			node = create_t_file_node(new_file);
			node->type = type;
			add_file_to_cmd(current_cmd, node);
		}
	}
}
