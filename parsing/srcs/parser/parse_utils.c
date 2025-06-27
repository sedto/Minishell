/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_utils.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:04 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/24 01:15:46 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Traite les tokens de redirection (>, >>, <, <<) */
void	process_redirection_token(t_cmd *current_cmd, t_token **tokens)
{
	if ((*tokens)->type == TOKEN_REDIR_OUT)
		handle_redirect_out(current_cmd, tokens);
	else if ((*tokens)->type == TOKEN_APPEND)
		handle_redirect_append(current_cmd, tokens);
	else if ((*tokens)->type == TOKEN_REDIR_IN)
		handle_redirect_in(current_cmd, tokens);
	else if ((*tokens)->type == TOKEN_HEREDOC)
		handle_heredoc(current_cmd, tokens);
}
