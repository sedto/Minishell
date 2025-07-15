/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
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

int	is_command_in_list(t_cmd *commands, t_cmd *target)
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

int	validate_token_syntax(t_token *tokens, t_cmd *commands,
		t_cmd *current_cmd, t_shell_ctx *ctx)
{
	if (tokens->type == TOKEN_PIPE)
		return (validate_pipe_token(tokens, commands, current_cmd, ctx));
	if (tokens->type >= TOKEN_REDIR_IN && tokens->type <= TOKEN_HEREDOC)
		return (validate_redirection_token(tokens, commands, current_cmd, ctx));
	return (validate_double_pipe(tokens, commands, current_cmd, ctx));
}

int	handle_token_type(t_token **tokens, t_cmd **commands,
		t_cmd **current_cmd, t_shell_ctx *ctx)
{
	if ((*tokens)->type == TOKEN_WORD)
		handle_word_token(*current_cmd, (*tokens), ctx);
	else if ((*tokens)->type == TOKEN_PIPE)
		handle_pipe_token(commands, current_cmd, ctx);
	*tokens = (*tokens)->next;
	return (1);
}

int	handle_redirection_type(t_token **tokens, t_cmd *current_cmd,
		t_shell_ctx *ctx, t_minishell *s)
{
	if ((*tokens)->type >= TOKEN_REDIR_IN
		&& (*tokens)->type <= TOKEN_HEREDOC)
		process_redirection_token(current_cmd, tokens, ctx, s);
	*tokens = (*tokens)->next;
	return (1);
}
