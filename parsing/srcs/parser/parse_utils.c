/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_utils.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:04 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/08 16:46:02 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/*
 * Traite un token de redirection (>, >>, <, <<) et appelle le handler correspondant.
 * Met à jour la commande courante avec les fichiers/redirections.
 */
void	process_redirection_token(t_cmd *current_cmd, t_token **tokens, t_shell_ctx *ctx)
{
	if ((*tokens)->type == TOKEN_REDIR_OUT)
		handle_redirect_out(current_cmd, tokens, ctx);
	else if ((*tokens)->type == TOKEN_APPEND)
		handle_redirect_append(current_cmd, tokens, ctx);
	else if ((*tokens)->type == TOKEN_REDIR_IN)
		handle_redirect_in(current_cmd, tokens, ctx);
	else if ((*tokens)->type == TOKEN_HEREDOC)
		handle_heredoc(current_cmd, tokens, ctx);
}

t_file	*create_t_file_node(char *str)
{
	t_file	*new;

	new = malloc(sizeof(t_file));
	new->name = str;
	new->fd = -1;
	new->next = NULL;
	return (new);
}
