/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_validation.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 06:45:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 02:09:50 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Affiche l'erreur de syntaxe SANS libérer les ressources */
static int	syntax_error_cleanup(t_cmd *commands, char *error_msg, t_shell_ctx *ctx)
{
	(void)commands;
	printf("minishell: syntax error near unexpected token %s\n", error_msg);
	ctx->syntax_error = 1;  /* Marquer erreur de syntaxe */
	return (0);
}

/* Valide un token pipe */
int	validate_pipe_token(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd, t_shell_ctx *ctx)
{
	if (!tokens->next || tokens->next->type == TOKEN_EOF)
		return (syntax_error_cleanup(commands, "'|'", ctx));
	if (tokens->next->type == TOKEN_PIPE)
		return (syntax_error_cleanup(commands, "'|'", ctx));
	if (is_empty_command(current_cmd))
		return (syntax_error_cleanup(commands, "'|'", ctx));
	return (1);
}

/* Valide un token de redirection */
int	validate_redirection_token(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd, t_shell_ctx *ctx)
{
	char	*error_token;

	(void)current_cmd;
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
		return (syntax_error_cleanup(commands, error_token, ctx));
	}
	if (tokens->next->type != TOKEN_WORD)
		return (syntax_error_cleanup(commands, "'newline'", ctx));
	return (1);
}

/* Valide les doubles pipes consécutifs */
int	validate_double_pipe(t_token *tokens, t_cmd *commands,
			t_cmd *current_cmd, t_shell_ctx *ctx)
{
	(void)current_cmd;
	if (tokens->type == TOKEN_PIPE && tokens->next
		&& tokens->next->type == TOKEN_PIPE)
		return (syntax_error_cleanup(commands, "'|'", ctx));
	return (1);
}
