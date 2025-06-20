/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_utils.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:04 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 03:38:09 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Gère les redirections de sortie (>) */
void	handle_redirect_out(t_cmd *current_cmd, t_token **token)
{
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		if (current_cmd->output_file)
			free(current_cmd->output_file);
		current_cmd->output_file = ft_strdup((*token)->value);
		current_cmd->append = 0;
	}
}

/* Gère les redirections en append (>>) */
void	handle_redirect_append(t_cmd *current_cmd, t_token **token)
{
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		if (current_cmd->output_file)
			free(current_cmd->output_file);
		current_cmd->output_file = ft_strdup((*token)->value);
		current_cmd->append = 1;
	}
}

/* Gère les redirections d'entrée (<) */
void	handle_redirect_in(t_cmd *current_cmd, t_token **token)
{
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		if (current_cmd->input_file)
			free(current_cmd->input_file);
		current_cmd->input_file = ft_strdup((*token)->value);
		current_cmd->heredoc = 0;
	}
}

/* Gère les heredoc (<<) */
void	handle_heredoc(t_cmd *current_cmd, t_token **token)
{
	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		if (current_cmd->input_file)
			free(current_cmd->input_file);
		current_cmd->input_file = ft_strdup((*token)->value);
		current_cmd->heredoc = 1;
	}
}

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
