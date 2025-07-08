/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/08 16:46:04 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
 * Vérifie si la commande passée en paramètre est vide (aucun argument ni redirection).
 * Retourne 1 si vide, 0 sinon.
 */
int	is_empty_command(t_cmd *cmd)
{
	if (!cmd)
		return (1);
	if (cmd->args && cmd->args[0])
		return (0);
	if (cmd->input_file || cmd->output_file)
		return (0);
	return (1);
}

/*
 * Vérifie si une commande (target) est présente dans la liste chainée de commandes.
 * Utile pour éviter les doublons lors de l'ajout.
 */
static int	is_command_in_list(t_cmd *commands, t_cmd *target)
{
	t_cmd	*current;

	if (!commands || !target)
		return (0);
	current = commands;
	while (current)
	{
		if (current == target)
			return (1);
		current = current->next;
	}
	return (0);
}

/*
 * Valide la syntaxe d'un token courant selon son type (pipe, redirection, etc).
 * Retourne 1 si valide, 0 sinon et signale l'erreur dans le contexte.
 */
static int	validate_token_syntax(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd, t_shell_ctx *ctx)
{
	if (tokens->type == TOKEN_PIPE)
		return (validate_pipe_token(tokens, commands, current_cmd, ctx));
	if (tokens->type >= TOKEN_REDIR_IN && tokens->type <= TOKEN_HEREDOC)
		return (validate_redirection_token(tokens, commands, current_cmd, ctx));
	return (validate_double_pipe(tokens, commands, current_cmd, ctx));
}

/*
 * Traite un token courant et met à jour la structure de commandes en conséquence.
 * Appelle le handler approprié selon le type de token (mot, pipe, redirection).
 */
static int	process_token(t_token **tokens, t_cmd **commands,
			t_cmd **current_cmd, t_shell_ctx *ctx)
{
	if ((*tokens)->type == TOKEN_WORD)
		handle_word_token(*current_cmd, (*tokens), ctx);
	else if ((*tokens)->type == TOKEN_PIPE)
	{
		handle_pipe_token(commands, current_cmd, ctx);
	}
	else if ((*tokens)->type >= TOKEN_REDIR_IN
		&& (*tokens)->type <= TOKEN_HEREDOC)
	{
		process_redirection_token(*current_cmd, tokens, ctx);
	}
	*tokens = (*tokens)->next;
	return (1);
}

/* Convertit une liste de tokens en liste de commandes structurées */
/* ctx est utilisé pour le flag d'erreur de syntaxe */
/* Retourne NULL si erreur de syntaxe */

t_cmd	*parse_tokens_to_commands(t_token *tokens, t_shell_ctx *ctx)
{
	t_cmd	*commands;
	t_cmd	*current_cmd;

	if (!validate_initial_syntax(tokens, ctx))
		return (NULL);
	commands = NULL;
	current_cmd = new_command();
	if (!current_cmd)
		return (NULL);
	while (tokens && tokens->type != TOKEN_EOF)
	{
		if (!validate_token_syntax(tokens, commands, current_cmd, ctx))
		{
			free_commands(commands);
			if (current_cmd && !is_command_in_list(commands, current_cmd))
				free_commands(current_cmd);
			return (NULL);
		}
		if (!process_token(&tokens, &commands, &current_cmd, ctx))
			return (NULL);
	}
	if (current_cmd)
		add_command_to_list(&commands, current_cmd);
	return (commands);
}
