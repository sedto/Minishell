/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_handlers.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 12:45:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/08 16:46:02 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
 * Ajoute un mot (argument) à la commande courante.
 * Utilisé pour chaque token de type WORD.
 */
void	handle_word_token(t_cmd *current_cmd, t_token *token, t_shell_ctx *ctx)
{
	(void)ctx;
	add_argument(current_cmd, token->value);
}

/*
 * Gère un token de type pipe : termine la commande courante
 * et en crée une nouvelle.
 * Ajoute la commande à la liste et réinitialise current_cmd.
 */
void	handle_pipe_token(t_cmd **commands, t_cmd **current_cmd,
		t_shell_ctx *ctx)
{
	(void)ctx;
	if (*current_cmd)
	{
		add_command_to_list(commands, *current_cmd);
		*current_cmd = new_command();
	}
}

/*
 * Valide la syntaxe initiale de la ligne de commande
 * (pas de pipe au début, tokens présents).
 * Retourne 1 si valide, 0 sinon et signale l'erreur dans le contexte.
 */
int	validate_initial_syntax(t_token *tokens, t_shell_ctx *ctx)
{
	if (!tokens)
	{
		printf("minishell: syntax error\n");
		ctx->syntax_error = 1;
		return (0);
	}
	if (tokens->type == TOKEN_PIPE)
	{
		printf("minishell: syntax error near unexpected token '|'\n");
		ctx->syntax_error = 1;
		return (0);
	}
	return (1);
}
