/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 03:38:08 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Ajoute un mot/argument à la commande courante */
static void	handle_word_token(t_cmd *current_cmd, t_token *token)
{
	add_argument(current_cmd, token->value);
}

/* Gère un token pipe : termine la commande courante et en crée une nouvelle */
static void	handle_pipe_token(t_cmd **commands, t_cmd **current_cmd)
{
	if (*current_cmd)
	{
		add_command_to_list(commands, *current_cmd);
		*current_cmd = new_command();
	}
}

/* Valide la syntaxe initiale (pas de pipe au début, tokens présents) */
static int	validate_initial_syntax(t_token *tokens)
{
	if (!tokens)
	{
		printf("minishell: syntax error\n");
		return (0);
	}
	if (tokens->type == TOKEN_PIPE)
	{
		printf("minishell: syntax error near unexpected token '|'\n");
		return (0);
	}
	return (1);
}

/* Valide la syntaxe des redirections (fichier après >, <, >>, <<) */
static int	validate_token_syntax(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd)
{
	if (tokens->type >= TOKEN_REDIR_IN && tokens->type <= TOKEN_HEREDOC)
	{
		if (!tokens->next || tokens->next->type != TOKEN_WORD)
		{
			printf("minishell: syntax error near unexpected token ");
			printf("'newline'\n");
			free_commands(commands);
			if (current_cmd)
				free_commands(current_cmd);
			return (0);
		}
	}
	if (tokens->type == TOKEN_PIPE && tokens->next
		&& tokens->next->type == TOKEN_PIPE)
	{
		printf("minishell: syntax error near unexpected token '|'\n");
		free_commands(commands);
		if (current_cmd)
			free_commands(current_cmd);
		return (0);
	}
	return (1);
}

/* Convertit une liste de tokens en liste de commandes structurées */
t_cmd	*parse_tokens_to_commands(t_token *tokens)
{
	t_cmd	*commands;
	t_cmd	*current_cmd;

	if (!validate_initial_syntax(tokens))
		return (NULL);
	commands = NULL;
	current_cmd = new_command();
	if (!current_cmd)
		return (NULL);
	while (tokens && tokens->type != TOKEN_EOF)
	{
		if (!validate_token_syntax(tokens, commands, current_cmd))
			return (NULL);
		if (tokens->type == TOKEN_WORD)
			handle_word_token(current_cmd, tokens);
		else if (tokens->type == TOKEN_PIPE)
			handle_pipe_token(&commands, &current_cmd);
		else
			process_redirection_token(current_cmd, &tokens);
		if (tokens)
			tokens = tokens->next;
	}
	if (current_cmd)
		add_command_to_list(&commands, current_cmd);
	return (commands);
}
