/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_validation.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 06:45:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/08 16:46:03 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
 * Affiche une erreur de syntaxe sans libérer les ressources,
 * et marque l'erreur dans le contexte.
 * Utilisé pour signaler une erreur lors du parsing.
 */
static int	syntax_error_cleanup(t_cmd *commands, char *error_msg,
		t_shell_ctx *ctx)
{
	(void)commands;
	printf("minishell: syntax error near unexpected token %s\n", error_msg);
	ctx->syntax_error = 1;
	return (0);
}

/*
 * Valide la syntaxe d'un token de type pipe (|).
 * Vérifie qu'il n'est pas en début/fin de ligne, ni doublé,
 * ni après une commande vide.
 */
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

/*
 * Valide la syntaxe d'un token de redirection (<, >, <<, >>).
 * Vérifie la présence d'un mot après la redirection
 * et l'absence d'erreur de syntaxe.
 */
int	validatt_redirection_token(t_token *tokens, t_cmd *commands,
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

int	validate_redirection_token(t_token *tokens, t_cmd *commands,
		t_cmd *current_cmd, t_shell_ctx *ctx)
{
	(void)current_cmd;
	if (!tokens->next || tokens->next->type == TOKEN_EOF
		|| tokens->next->type == TOKEN_PIPE)
		return (syntax_error_cleanup(commands, "newline", ctx));
	return (1);
}
