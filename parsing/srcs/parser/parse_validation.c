/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_validation.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 06:45:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 17:05:46 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Libère les ressources et affiche l'erreur de syntaxe */
static int	syntax_error_cleanup(t_cmd *commands, char *error_msg)
{
	printf("minishell: syntax error near unexpected token %s\n", error_msg);
	free_commands(commands);
	return (0);
}

/* Valide un token pipe */
int	validate_pipe_token(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd)
{
	if (!tokens->next || tokens->next->type == TOKEN_EOF)
		return (syntax_error_cleanup(commands, "'|'"));
	if (tokens->next->type == TOKEN_PIPE)
		return (syntax_error_cleanup(commands, "'|'"));
	if (is_empty_command(current_cmd))
		return (syntax_error_cleanup(commands, "'|'"));
	return (1);
}

/* Valide les redirections consécutives */
static int	validate_consecutive_redirections(t_token *tokens, t_cmd *commands)
{
	char	*error_token;

	(void)tokens; /* Paramètre utilisé pour l'accès next->next seulement */
	if (tokens->next->next->type == TOKEN_REDIR_OUT)
		error_token = "'>'";
	else if (tokens->next->next->type == TOKEN_REDIR_IN)
		error_token = "'<'";
	else if (tokens->next->next->type == TOKEN_APPEND)
		error_token = "'>>'";
	else if (tokens->next->next->type == TOKEN_HEREDOC)
		error_token = "'<<'";
	else
		error_token = "'newline'";
	return (syntax_error_cleanup(commands, error_token));
}

/* Valide un token de redirection */
int	validate_redirection_token(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd)
{
	char	*error_token;

	(void)current_cmd; /* Utilisé dans l'interface mais pas ici */
	if (!tokens->next || tokens->next->type == TOKEN_EOF)
	{
		if (tokens->type == TOKEN_REDIR_OUT)
			error_token = "'>'";
		else if (tokens->type == TOKEN_REDIR_IN)
			error_token = "'<'";
		else if (tokens->type == TOKEN_APPEND)
			error_token = "'>>'";
		else if (tokens->type == TOKEN_HEREDOC)
			error_token = "'<<'";
		else
			error_token = "'newline'";
		return (syntax_error_cleanup(commands, error_token));
	}
	if (tokens->next->type != TOKEN_WORD)
		return (syntax_error_cleanup(commands, "'newline'"));
	if (tokens->next && tokens->next->next
		&& tokens->next->next->type >= TOKEN_REDIR_IN
		&& tokens->next->next->type <= TOKEN_HEREDOC)
		return (validate_consecutive_redirections(tokens, commands));
	return (1);
}

/* Valide les doubles pipes consécutifs */
int	validate_double_pipe(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd)
{
	(void)current_cmd; /* Utilisé dans l'interface mais pas ici */
	if (tokens->type == TOKEN_PIPE && tokens->next
		&& tokens->next->type == TOKEN_PIPE)
		return (syntax_error_cleanup(commands, "'|'"));
	return (1);
}
