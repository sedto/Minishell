/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/10 15:00:00 by Gemini          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	is_empty_command(t_cmd *cmd)
{
	if (!cmd)
		return (1);
	if (cmd->args && cmd->args[0])
		return (0);
	if (cmd->files)
		return (0);
	return (1);
}

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

static int	validate_token_syntax(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd, t_shell_ctx *ctx)
{
	if (tokens->type == TOKEN_PIPE)
		return (validate_pipe_token(tokens, commands, current_cmd, ctx));
	if (tokens->type >= TOKEN_REDIR_IN && tokens->type <= TOKEN_HEREDOC)
		return (validate_redirection_token(tokens, commands, current_cmd, ctx));
	return (validate_double_pipe(tokens, commands, current_cmd, ctx));
}

static int	process_token(t_token **tokens, t_cmd **commands,
				t_cmd **current_cmd, t_shell_ctx *ctx, t_minishell *s)
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
		process_redirection_token(*current_cmd, tokens, ctx, s);
	}
	*tokens = (*tokens)->next;
	return (1);
}

t_cmd	*parse_tokens_to_commands(t_token *tokens, t_shell_ctx *ctx, t_minishell *s)
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
		if (!process_token(&tokens, &commands, &current_cmd, ctx, s))
			return (NULL);
	}
	if (current_cmd)
		add_command_to_list(&commands, current_cmd);
	return (commands);
}